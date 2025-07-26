# `jqg`

## NAME

**jqg** - search, flatten, unflatten, and extract JSON using JQ

## SYNOPSIS

`jqg [--search] [OPTIONS]... [FILE|CRITERIA|CRITERIA FILE]`

`jqg --unflatten [OPTIONS]... [FILE]`

`jqg --extract <SELECTOR> [OPTIONS]... [FILE]`

`jqu [OPTIONS]... [CRITERIA|FILE|CRITERIA FILE]`

`jqx <SELECTOR> [OPTIONS]... [FILE|CRITERIA|CRITERIA FILE]`

## DESCRIPTION

The primary purpose of JQG is to flatten the supplied JSON structure using JQ and then filter (search) the flattened structure using the supplied search `CRITERIA`. It can also be used without a filter to simply flatten the input. An alternate mode provides the ability to unflatten previously flattened JSON, and another mode will extract a sub-structure of the JSON. Any mode can be used with a file name or via `STDIN` (as part of a pipeline). Finally, two composite modes exist combining each of the alternate modes with the default search mode, invocable via command line options or the wrapper scripts `jqu` (unflatten) and `jqx` (extract).

### Requirements

- Bash 3.0.27+
- JQ 1.6+

### Arguments

Flatten and then search the JSON input for `CRITERIA`, using the JQ Identity filter '`.`' if no `CRITERIA` is supplied, treating `CRITERIA` as a regular expression otherwise (JQG uses the [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions) engine built into JQ; see the JQ [man page](https://jqlang.org/manual/#regular-expressions) for more details). Alternately, unflatten JSON input from `FILE`, or extract JSON from `FILE` using a valid `SELECTOR`.

`FILE` will be processed as a JSON file, reading `STDIN` if not specified. If both `CRITERIA` and `FILE` are given, they must be given in that specific order. If only one is given, it will be treated as a `FILE` if it exists on the local filesystem, otherwise it will be treated as `CRITERIA`.

Some `OPTIONS` are specific to only one mode, some can be used in all modes; see below for more details.

### Modes

#### Search Mode

The default mode of operation is to flatten the input JSON and search it using a regular expression; anything matching the regex is produced as output. This process can be modified in a number of different ways, affecting all aspects of the process (flattening, searching, and output); see the `OPTIONS` below for more details. If no search criteria is provided, the input is simply flattened.

**Note:** the flattening process should be [idempotent].

#### Unflatten Mode

JSON that is flattened can be unflattened, and JSON flattened without filtering or sorting should unflatten to a structure identical to the original. The following limitations and caveats apply:

1. flattened JSON must make logical sense, e.g. objects and arrays cannot be intermixed as siblings

1. flattened JSON with arrays containing missing indices (i.e. sparse arrays) will be unflattened into arrays with `null` items, so that the original array elements appear in the proper places

1. an object key containing the character used to join elements together when flattening will not unflatten to the same original structure; this can be avoided by using a different join character

1. an object key that is simply a stringified number will flatten in such a way as to be interpreted as an array index when unflattened, and will therefor not make logical sense if it has non-numeric siblings

**Note:** the unflattening process should be [idempotent].

<details>
<summary>

###### examples of limitations

</summary>

in the example below the first line establishes that the child of `lorem` is an array, but the second line wants the child to be an object; unflattening this will result in a JQ error

```json
{
  "lorem.0.ipsem": false,
  "lorem.dolor": true
}

# jq: error (at <stdin>:4): Cannot index array with string "dolor"
```

unflattening a sparse array results in an array with `null` elements

```json
# flattened & filtered sparse array
{
  "lorem.3.ipsem": "dolor"
}

# unflattens to an array with null elements
{
  "lorem": [
    null,
    null,
    "ipsem": {
      "dolor"
    }
  ]
}
```

flattening & unflattening objects where the join character appears in a key will result in a different structure

```json
# object key has the default join character in it
{
  "lorem.ipsem": [
    {
      "dolor": "sit"
    }
  ]
}

# which flattens to
{
  "lorem.ipsem.0.dolor": "sit"
}

# and unflattens to a different structure
{
  "lorem": {
    "ipsem": [
      {
        "dolor": "sit"
      }
    ]
  }
}

# flattening with `-j +` instead
{
  "lorem.ipsem+0+dolor": "sit"
}

# unflattens (with `-j +`) to the original structure
{
  "lorem.ipsem": [
    {
      "dolor": "sit"
    }
  ]
}
```

an object key that is also numeric will not unflatten correctly

```json
{
  "lorem": {
    "3": {
      "ipsem": false
    },
    "dolor": true
  }
}

# will flatten to
{
  "lorem.3.ipsem": false,
  "lorem.dolor": true
}

# which results in an error when it unflattens

jq: error (at <stdin>:4): Cannot index array with string "dolor"

# if the numeric object key element had no siblings:
{
  "lorem": {
    "3": {
      "ipsem": false
    }
  }
}

# then unflattening would not result in an error, but would unflatten as an array:
{
  "lorem": [
    null,
    null,
    null,
    {
      "ipsem": false
    }
  ]
}

```

</details>

#### Extract Mode

The extract mode can be used to create a subset of the original JSON via a simple JQ [Object Identifier-Index](https://jqlang.org/manual/#object-identifier-index) or [Array Index](https://jqlang.org/manual/#array-index), collectively referred to as "selectors" here. Extracting via an array selector may result in sparse array output.

**Note:** the extraction process should be [idempotent].

<details>
<summary>

###### extract examples

</summary>

Given this input:

```json
# jq . /tmp/lorem.json
{
  "lorem": {
    "ipsum": "dolor",
    "sit": {
      "amet": true
    }
  },
  "consectetur": [
    "adipiscing",
    "elit"
  ]
}
```

Running JQ with the `.consectetur` selector results in:

```json
# jq .consectetur /tmp/lorem.json
[
  "adipiscing",
  "elit"
]
```

Extracting via JQG using the same selector results in:

```json
# jqg -x .consectetur /tmp/lorem.json
{
  "consectetur": [
    "adipiscing",
    "elit"
  ]
}
```

A deeper extraction:

```json
# jqg -x .lorem.sit /tmp/lorem.json
{
  "lorem": {
    "sit": {
      "amet": true
    }
  }
}
```

Extracting an array element:

```json
# jqg -x .consectetur[0] /tmp/lorem.json
{
  "consectetur": [
    "adipiscing"
  ]
}
```

```json
# jqg -x .consectetur[1] /tmp/lorem.json
{
  "consectetur": [
    null,
    "elit"
  ]
}
```

</details>

## OPTIONS

Options apply to all modes unless specified otherwise, although not all option/mode combinations make sense. The options are processed in the order given on the command line, with later options overriding earlier options.

Mandatory arguments to long options are mandatory for short options, as well.

### Mode Selection

| Option                                | Description                                                                                  |
| ---                                   | ---                                                                                          |
| `-s, --search`                        | standard mode - flatten & search, producing flattened results (*default*)                    |
| `-f, --flatten`                       | *synonym for `--search`* -- **these are deprecated and will be removed in a future release** |
| `-u, --unflatten`                     | unflatten mode - unflatten structured JSON                                                   |
| `-x, --extract`                       | extract mode - extract subset of JSON                                                        |
| `-U, --composite_unflatten`           | composite mode - flatten and search the JSON, then unflatten the results                     |
| `-X, --composite_extract <selector>`  | composite mode - extract subset of JSON described by `SELECTOR` and then flatten & search, producing flattened results |

### Search Options (Search & Composite Modes only)

| Option               | Description                                   |
| ---                  | ---                                           |
| `-k, --searchkeys`   | limit search to just keys                     |
| `-v, --searchvalues` | limit search to just values                   |
| `-a, --searchall`    | search both keys and values (*default*)       |
|                      |                                               |
| `-i, --ignore_case`  | regex search is case insensitive (*default*)  |
| `-I, --match_case`   | regex search is case sensitive                |

### Output Options

**Note:** these only really make sense when the output is flattened, but they will be applied as requested to unflattened output, too.

| Option         | Description                          |
| ---            | ---                                  |
| `-K, --keys`   | output just keys                     |
| `-V, --values` | output just values                   |
| `-A, --all`    | output keys and values (*default*)   |
|                |                                      |
| `-r, --raw`    | output as raw strings (ignored with `-A`) -- see JQ's [raw output](https://jqlang.org/manual/#invoking-jq) for more info |
| `-R, --json`   | output as formatted JSON (*default*) |

### Flattening/Unflattening Options

| Option                   | Description                                                                                  |
| ---                      | ---                                                                                          |
| `-e, --include_empty`    | treat empty JSON arrays and objects as node values while flattening (*default*)              |
| `-E, --exclude_empty`    | ignore empty JSON arrays and objects while flattening                                        |
|                          |                                                                                              |
| `-j, --join <str>`       | join character/string for flattened path string representations (*default '`.`'*)            |
| `    --join_char <str>`  | set the alternate join character to be used when `-J` is given (*default '`:`'*)             |
| `-J, --join_alt`         | use the alternate join character for flattened path string representations                   |
| `    --join_colon`       | *synonym for `--join ":"`* -- **this is deprecated and will be removed in a future release** |

### Input/Output Transformation Options

See [jqg-filters.md](jqg-filters.md#jqg-filters) for more information on transformation filters.

| Option                 | Description                                                                                       |
| ---                    | ---                                                                                               |
| `-t, --output <xform>` | replace output transformations, where `XFORM` is one of: `flatten`, `unflatten`, `none`           |
| `-T, --input <xform>`  | replace input transformations, where `XFORM` is one of: `flatten`, `unflatten`, `extract`, `none` |

**Note:** altering the input transformations selected by the mode will likely have unexpected / undesirable results

### Miscellaneous Options

| Option                   | Description                                                                        |
| ---                      | ---                                                                                |
| `-n, --empty_results_ok` | empty results are OK (*default*)                                                   |
| `-N, --results_required` | non-empty results are required; empty results will generate a non-zero exit status |
|                          |                                                                                    |
| `-q, --jqopt <flag>`     | command-line options to be passed to JQ; can be given multiple times               |
| `-Q, --clear`            | clear all JQ options previously set with `-q`                                      |

### Non-executing Options

| Option        | Description                                                    |
| ---           | ---                                                            |
| `--version`   | print out the script version and exit                          |
| `-h, --help`  | print brief help and exit                                      |
| `-d, --debug` | formulate and display the JQ filter, but don't actually run it |
| `--bug`       | print out instructions for filing a bug                        |

## EXAMPLES

An exhaustive look at the different invocation methods as well as the effects of each command line option is provided in the [jqg-examples.md](jqg-examples.md) file.

## EXIT STATUS

JQG will exit with the exit status of JQ itself, with the following exceptions:

- empty result set with `--results_required` set (exit code: 1)
- error parsing the JQG command line options (exit code: 2)
- printing help, version, or debug output (exit code: 0)

## ENVIRONMENT

`$JQG_OPTS` - specify default options to be used with every JQG invocation; these options can be overridden on the command line

`$JQ_BIN` - full path to the JQ binary (default is to find it on your `$PATH`)

## BUGS

Known bugs will be tracked as [GitHub Issues](https://github.com/NorthboundTrain/jqg/issues).

## COPYRIGHT

Copyright 2021 Joseph Casadonte

License: [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)

## SEE ALSO

- [`jq`](https://jqlang.org/)

[idempotent]: https://en.wikipedia.org/wiki/Idempotent
