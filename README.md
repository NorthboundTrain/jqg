# `jqg` - search, flatten, unflatten, and extract JSON using JQ

[![BATS](https://github.com/NorthboundTrain/jqg/actions/workflows/bats.yml/badge.svg)](https://github.com/NorthboundTrain/jqg/actions/workflows/bats.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-yellow.svg)](https://raw.githubusercontent.com/NorthboundTrain/jqg/main/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/NorthboundTrain/jqg?sort=semver)](https://github.com/NorthboundTrain/jqg/releases/latest)
[![Semantic Versioning](https://img.shields.io/badge/semantic_versioning-grey)](https://semver.org/)
[![Common Changelog](https://common-changelog.org/badge.svg)](https://common-changelog.org)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

JSON is an inherently hierarchical structure, which makes searching it for path information difficult. The JQG script flattens the hierarchical structure so that the path for each JSON end node is represented as a single string, thereby enabling easy searching and producing contextually meaningful results. It also produces valid JSON, which can be further processed, as needed.

For searching, JQG uses the [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions) engine built into JQ, which is much more powerful than `grep` or `egrep` (and it's certainly easier to use). For added flexibility, JQG can read from STDIN instead of from a file, allowing it to be used in pipelines, too. Finally, there are many options to control what is searched and how, as well as the format and content of the output.

Alternately, JQG can unflatten JSON that has been previously flattened (or structured to look that way) and it can also extract a subset of the JSON input, including the extraction terms in the results. Both of these alternatives can be combined with searching in a "composite mode". The convenience scripts `jqu` and `jqx` are provided to invoke those composite modes more easily.

<details>
<summary>

###### example JSON used below: `odd-values.json`

</summary>

```none
$ jq . odd-values.json
{
  "one": {
    "start-string": "foo",
    "null-value": null,
    "integer-number": 101,
    "string-with-pipe": "this|that",
    "key|with|pipe": true,
    "string-with-parens": "(this and that)",
    "key(with)parens": true,
    "bare-parens()": true,
    "left(paren-only": true,
    "unmatched-left)-paren": false,
    "dollar $ign": "both-sides-$now"
  },
  "two": [
    {
      "two-a": {
        "non-integer-number": -101.75,
        "number-zero": 0
      },
      "true-boolean": true,
      "two-b": {
        "false-boolean": false
      }
    },
    {
      "two-c": {
        "alpha-num-1": "a1",
        "alpha-num-2": "2b",
        "alpha-num-3": "a12b"
      }
    }
  ],
  "three": {
    "empty-string": "",
    "empty-object": {},
    "empty-array": []
  },
  "four": [
    "first",
    null,
    {},
    999,
    "fourth"
  ],
  "end-string": "bar"
}
```

</details>

##### Search Mode

###### the old way: `jq` & `grep`

```none
# some not-too-useful jq/grep results
$ jq . odd-values.json | grep string
    "start-string": "foo",
    "string-with-pipe": "this|that",
    "string-with-parens": "(this and that)",
    "empty-string": "",
  "end-string": "bar"

$ jq . odd-values.json | grep 0
    "integer-number": 101,
        "non-integer-number": -101.75,
        "number-zero": 0

$ jq . odd-values.json | grep 'int\|false'
    "integer-number": 101,
    "unmatched-left)-paren": false,
        "non-integer-number": -101.75,
        "false-boolean": false
```

###### new and improved: `jqg`

```none
# much more useful jqg results
$ jqg string odd-values.json
{
  "one.start-string": "foo",
  "one.string-with-pipe": "this|that",
  "one.string-with-parens": "(this and that)",
  "three.empty-string": "",
  "end-string": "bar"
}

$ jqg -v 0 odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0
}

$ jqg 'int|false' odd-values.json
{
  "one.integer-number": 101,
  "one.unmatched-left)-paren": false,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-b.false-boolean": false
}



# The power of PCRE
# - search values looking for a 0 without a preceding number
$ jqg -v '(?<!\d)0' odd-values.json
{
  "two.0.two-a.number-zero": 0
}

# - the same or an empty array
$ jqg -v '(?<!\d)0|\[]' odd-values.json
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}



# can be used in pipelines, too
$ curl -s https://raw.githubusercontent.com/NorthboundTrain/jqg/main/test/odd-values.json | jqg -v '(?<!\d)0|\[]'
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
```

##### Unflatten Mode

```none
# flatten & search
$ jqg 'int|false' odd-values.json
{
  "one.integer-number": 101,
  "one.unmatched-left)-paren": false,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-b.false-boolean": false
}

# flatten & search, then unflatten
$ jqg 'int|false' odd-values.json | jqg -u
{
  "one": {
    "integer-number": 101,
    "unmatched-left)-paren": false
  },
  "two": [
    {
      "two-a": {
        "non-integer-number": -101.75
      },
      "two-b": {
        "false-boolean": false
      }
    }
  ]
}
```

##### Extract Mode

```none
# regular JQ command
$ jq .two odd-values.json
[
  {
    "two-a": {
      "non-integer-number": -101.75,
      "number-zero": 0
    },
    "true-boolean": true,
    "two-b": {
      "false-boolean": false
    }
  },
  {
    "two-c": {
      "alpha-num-1": "a1",
      "alpha-num-2": "2b",
      "alpha-num-3": "a12b"
    }
  }
]


# JQG's extract retains the selector given
$ jqg -x .two odd-values.json
{
  "two": [
    {
      "two-a": {
        "non-integer-number": -101.75,
        "number-zero": 0
      },
      "true-boolean": true,
      "two-b": {
        "false-boolean": false
      }
    },
    {
      "two-c": {
        "alpha-num-1": "a1",
        "alpha-num-2": "2b",
        "alpha-num-3": "a12b"
      }
    }
  ]
}

# extract deep into a structure
$ jqg -x '.two[0]."two-b"' odd-values.json
{
  "two": [
    {
      "two-b": {
        "false-boolean": false
      }
    }
  ]
}

# composite mode - extract & search
$ jqx .two 'int|false' odd-values.json
{
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-b.false-boolean": false
}
```

Many more examples are provided in [jqg-examples.md](docs/jqg-examples.md).

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Documentation & Examples](#documentation--examples)
- [Version History](#version-history)
- [Acknowledgements](#acknowledgements)
- [Contributing](#contributing)
- [License](#license)

## Installation

### Prerequisites

The JQG script is entirely self-contained except for the need to have both `jq` and `bash` on the system somewhere; `bash` itself needs to be on your `$PATH`, but `jq` does not -- see the [documentation](docs/jqg.md) for more details on how to work when `jq` is not in your `$PATH`.

### Download the Script

It's easy to get the latest stable version of the script. First decide where you want to put it, and then grab it using `wget`:

```none
cd /path/to/script/dir
wget https://github.com/NorthboundTrain/jqg/raw/main/src/jqg
wget https://github.com/NorthboundTrain/jqg/raw/main/src/jqu
wget https://github.com/NorthboundTrain/jqg/raw/main/src/jqx
chmod +x jqg jqu jqx
```

### Clone the Repo

Alternately, you can clone the whole repo:

```none
# HTTP
cd /path/to/git/parent/dir
git clone https://github.com/NorthboundTrain/jqg.git

# SSH
cd /path/to/git/parent/dir
git clone git@github.com:NorthboundTrain/jqg.git
```

If you want to run the unit tests, you will also need the [BATS](https://github.com/bats-core) sub-modules; you can clone them at the same time by adding in the `--recurse-submodules` option for `git clone`:

```none
git clone --recurse-submodules https://github.com/NorthboundTrain/jqg.git
git clone --recurse-submodules git@github.com:NorthboundTrain/jqg.git
```

## Usage

### Requirements

- Bash 3.0.27+
- JQ 1.6+

### Basic Usage

Execute JQG against a specific JSON file:

```none
jqg search-string foo.json
jqg --unflatten flat.json
jqg --extract .some_elem foo.json
```

Execute JQG in a pipeline:

```none
curl -s 'https://api.github.com/repos/NorthboundTrain/jqg' | jqg 'name|count'
```

## Documentation & Examples

- [jqg.md](docs/jqg.md) - the JQG man page
- [jqg-examples.md](docs/jqg-examples.md) - an exhaustive look at the different invocation methods as well as each command line option
- [jqg-filters.md](docs/jqg-filters.md) - all JQG filters fully annotated
- [runing-tests.md](test/running-tests.md) - information on running the provided unit tests

## Version History

see [CHANGELOG.md](CHANGELOG.md)

## Acknowledgements

The filters to convert the hierarchical structure of JSON into a flat structure are largely based on a blog post from [Fabian Keller](https://www.fabian-keller.de/about/) entitled [5 Useful jq Commands to Parse JSON on the CLI](https://www.fabian-keller.de/blog/5-useful-jq-commands-parse-json-cli/).

The core of the unflatten filter is taken from a [StackOverflow answer](https://stackoverflow.com/a/69650189) given by user [pmf](https://stackoverflow.com/users/2158479/pmf).

The core of the extract filter is taken from a [StackOverflow answer](https://stackoverflow.com/a/71334337/45978) given again by user [pmf](https://stackoverflow.com/users/2158479/pmf).

This project uses code from the following projects:

- [pure-getopt](https://github.com/agriffis/pure-getopt) - a drop-in replacement for GNU `getopt`, written in Bash
- [bats-core](https://github.com/bats-core) - Bash Automated Testing System
  - [bats-core](https://github.com/bats-core/bats-core), [bats-support](https://github.com/bats-core/bats-support), [bats-assert](https://github.com/bats-core/bats-assert), [bats-file](https://github.com/bats-core/bats-file)

## Contributing

### Bugs / Feature Requests

Bugs & feature requests are tracked as GitHub [issues](https://github.com/NorthboundTrain/jqg/issues).

### Pull Requests

1. Check the open issues or open a new issue to start a discussion around your feature idea or the bug you found
1. Fork the repository and make your changes
1. Make sure all unit tests pass (and add new ones, if appropriate)
1. Update documentation as needed
1. Open a new pull request

## License

[Apache-2.0](LICENSE)<br />
© 2021 Joseph Casadonte
