# `jqg` - search flattened JSON using `jq`; alternately, unflatten structured JSON

[![BATS](https://github.com/NorthboundTrain/jqg/actions/workflows/bats.yml/badge.svg)](https://github.com/NorthboundTrain/jqg/actions/workflows/bats.yml)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-yellow.svg)](https://raw.githubusercontent.com/NorthboundTrain/jqg/main/LICENSE)
[![Latest Release](https://img.shields.io/github/v/release/NorthboundTrain/jqg?sort=semver)](https://github.com/NorthboundTrain/jqg/releases/latest)
[![Semantic Versioning](https://img.shields.io/badge/semantic_versioning-grey)](https://semver.org/)
[![Common Changelog](https://common-changelog.org/badge.svg)](https://common-changelog.org)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=flat-square)](https://github.com/RichardLitt/standard-readme)

JSON is an inherently hierarchical structure, which makes searching it for path information difficult. The JQG script flattens the hierarchical structure so that the path for each JSON end node is represented as a single string, thereby enabling easy searching producing contextually meaningful results.

For searching, JQG uses the [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions) engine built into JQ, which is much more powerful than `grep` or `egrep` (and it's certainly easier to use). For added flexibility, JQG can read from STDIN instead of from a file, allowing it to be used in pipelines, too. Finally, there are many options to control what is searched and how, as well as the format of the output.

<details><summary>example JSON: `odd-values.json`</summary>

```none
$ jq . odd-values.json
{
  "one": {
    "start-string": "foo",
    "null-value": null,
    "integer-number": 101
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
    "fourth"
  ],
  "end-string": "bar"
}
```

</details>

```none
# some not-too-useful grep results
$ jq . odd-values.json | grep string
    "start-string": "foo",
    "empty-string": "",
  "end-string": "bar"

$ jq . odd-values.json | grep 0
    "integer-number": 101
      "non-integer-number": -101.75,
      "number-zero": 0

$ jq . odd-values.json | grep 'int\|false'
    "integer-number": 101
      "non-integer-number": -101.75,
      "false-boolean": false



# much more useful jqg results
$ jqg string odd-values.json
{
  "one.start-string": "foo",
  "three.empty-string": "",
  "end-string": "bar"
}

$ jqg 0 odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.0.true-boolean": true,
  "two.0.two-b.false-boolean": false,
  "four.0": "first"
}

$ jqg 'int|false' odd-values.json
{
  "one.integer-number": 101,
  "two.two-a.non-integer-number": -101.75,
  "two.two-b.false-boolean": false
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

JQG can also unflatten JSON that has been previously flattened (or structured to look that way).

```none
# flatten & search
$ jqg 'int|false' odd-values.json
{
  "one.integer-number": 101,
  "two.two-a.non-integer-number": -101.75,
  "two.two-b.false-boolean": false
}

# flatten & search, then unflatten
$ jqg 'int|false' odd-values.json | jqg -u
{
  "one": {
    "integer-number": 101
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

Many more examples are provided in [jqg-examples.md](docs/jqg-examples.md).

## Table of Contents

<details><summary>&nbsp;</summary>

- [Installation](#installation)
- [Usage](#usage)
- [Documentation & Examples](#documentation--examples)
- [Version History](#version-history)
- [Acknowledgements](#acknowledgements)
- [Contributing](#contributing)
- [License](#license)

</details>

## Installation

### Prerequisites

The JQG script is self-contained except for the need to have both `jq` and `bash` on the system somewhere; `bash` itself needs to be on your `$PATH`, but `jq` does not -- see the [documentation](docs/jqg.md) for more details.

### Download the Script

It's easy to get the latest stable version of the script. First decide where you want to put it, and then grab it using `wget`:

```none
cd /path/to/script/dir
wget https://github.com/NorthboundTrain/jqg/raw/main/src/jqg
chmod +x jqg
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
```

Execute JQG in a pipeline:

```none
curl -s 'https://api.github.com/repos/NorthboundTrain/jqg' | jqg 'name|count'
```

## Documentation & Examples

- [jqg.md](docs/jqg.md) - the JQG man page
- [jqg-examples.md](docs/jqg-examples.md) - an exhaustive look at the different invocation methods as well as each command line option
- [jqg-filters.md](docs/jqg-filters.md) - the fully annotated JQG filter

## Version History

see [CHANGELOG.md](CHANGELOG.md)

## Acknowledgements

The filters to convert the hierarchical structure of JSON into a flat structure are largely based on a blog post from [Fabian Keller](https://www.fabian-keller.de/about/) entitled [5 Useful jq Commands to Parse JSON on the CLI](https://www.fabian-keller.de/blog/5-useful-jq-commands-parse-json-cli/).

The core of the unflatten filter is taken from a [StackOverflow answer](https://stackoverflow.com/a/69650189) given by user [pmf](https://stackoverflow.com/users/2158479/pmf).

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
1. Open a new pull request

## License

[Apache-2.0](LICENSE)<br />
© 2021 Joseph Casadonte
