# `jqg`

## NAME

**jqg** - search JSON using JQ, printing full path/flattened results; unflatten JSON

## SYNOPSIS

`jqg [--flatten] [OPTIONS]... [REGEX [FILE]]`

`jqg --unflatten [OPTIONS]... [FILE]`

## DESCRIPTION

The primary purpose of JQG is to process JSON file using JQ, searching through the content looking to match the supplied `REGEX`, displaying filtered output as a flattened structure. It can also be used without a filter to simply flatten the input. An alternate mode provides the ability to unflatten previously flattened JSON (or any JSON properly formatted). Either mode can be used with a file name or via `STDIN` (as part of a pipeline).

### Requirements

- Bash 3.0.27+
- JQ 1.6+

### Arguments

Flatten and then search JSON for the `REGEX` supplied, using '`.`' as the search criteria if not specified (which matches everything). JQG uses the [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions) engine built into JQ; see the JQ [man page](https://stedolan.github.io/jq/manual/#RegularexpressionsPCRE) for more details.

`FILE` will be processed as a JSON file, reading `STDIN` if not specified.

Some `OPTIONS` are specific to one mode or the other, some can be used in multiple modes; see below for more details.

### Modes

#### Flatten/Search Mode

The normal mode of operation is to flatten the input JSON and search it using a regular expression; anything matching the regex is produced as output. This process can be modified in a number of different ways, affecting all aspects of the process (flattening, searching, and output); see the options below for more details.

#### Unflatten Mode

JSON that is flattened can be unflattened, and JSON flattened without filtering or sorting should unflatten to a structure identical to the original. The following limitations and caveats apply:

1. flattened JSON must make logical sense, e.g. objects and arrays cannot be intermixed as siblings

1. flattened JSON with arrays containing missing indices (sparse arrays) will be unflattened into arrays with null items, so that the original array elements appear in the proper places

1. an object key containing the character used to join elements together when flattening will not unflatten to the same original structure; this can be avoided by using a different join character

<details>
<summary>(explanations & examples)</summary>

in the example below the first line establishes that the child of `lorem` is an array, but the second line wants the child to be an object; unflattening this will result in a JQ error

```json
{
  "lorem.0.ipsem": false,
  "lorem.dolor": true
}
```

unflattening a sparse array results in an array with `null` elements

```json
# flattened sparse array
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
# object key has the join character in it
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

# flattening with "-j +" instead
{
  "lorem.ipsem+0+dolor": "sit"
}

# unflattens (with "-j +") to the original structure
{
  "lorem.ipsem": [
    {
      "dolor": "sit"
    }
  ]
}
```

</details>

## OPTIONS

Each option will indicate whether they apply to the "flatten & search" mode \[F/S\] or the "unflatten" mode \[U\].

### Mode selection

| Option | Description |
| --- | --- |
| `-f, --flatten` | standard mode - flatten & search (*default*) |
| `-s, --search` | *synonym for `--flatten`* |
| `-u, --unflatten` | unflatten mode - unflatten structured JSON |

### Search options

| Option | Description | F/S | U |
| --- | --- | :---: | :---: |
| `-k, --searchkeys` | limit search to just keys | x |    |
| `-v, --searchvalues` | limit search to just values | x |    |
| `-a, --searchall` | search both keys and values (*default*) | x |    |
| `-i, --ignore_case` | regex search is case insensitive (*default*) | x |    |
| `-I, --match_case` | regex search is case sensitive | x |    |
| `-e, --include_empty` | treat empty JSON arrays and objects as node values (*default*) | x |    |
| `-E, --exclude_empty` | do not treat empty JSON arrays and objects as node values| x |    |

### Output options

| Option | Description | F/S | U |
| --- | --- | :---: | :---: |
| `-K, --keys` | output just keys | x |    |
| `-V, --values` | output just values | x |    |
| `-A, --all` | output keys and values (*default*) | x |    |
| `-j <str>, --join <str>` | join character/string for key string output (*default '`.`'*) | x | x |
| `-J, --join_colon` | use ':' as join character for key string output | x | x |
| `-r, --raw` | output as raw strings (ignored with `-A`) -- see [raw output](https://stedolan.github.io/jq/manual/#Invokingjq) for more info | x |    |
| `-R, --json` | output as formatted JSON (*default*) | x |    |

### Miscellaneous options

| Option | Description | F/S | U |
| --- | --- | :---: | :---: |
| `-q <flag>, --jqopt <flag>` | command-line options to be passed to JQ; can be given multiple times | x | x |
| `-Q, --clear` | clear all JQ options previously set with `-q` | x | x |
| `-d, --debug` | formulate and display the JQ filter that would normally be run given the options passed in, but don't actually run it | x | x |
| `-h, --help` | print brief help and exit |

## EXAMPLES

An exhaustive look at the different invocation methods as well as each command line option is provided in the [jqg-examples.md](jqg-examples.md) file.

## EXIT STATUS

JQG will exit with the exit status of JQ itself, with the following exceptions: error parsing JQG command line options (exit code: 1), printing help or debug output (exit code: 0).

## ENVIRONMENT

`$JQG_OPTS` - specify default options for each JQG invocation; these options can be overridden on the command line

`$JQ_BIN` - full path to the JQ binary (default is to find it on your `$PATH`)

## BUGS

Known bugs will be tracked as [GitHub Issues](https://github.com/NorthboundTrain/jqg/issues).

## COPYRIGHT

Copyright 2021 Joseph Casadonte

License: [Apache-2.0](https://www.apache.org/licenses/LICENSE-2.0)

## SEE ALSO

[`jq`](https://stedolan.github.io/jq/)
