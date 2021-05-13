# `jqg`

## NAME

**jqg** - search JSON using **`jq`**, printing full path/flattened results

## SYNOPSIS

`jqg [OPTIONS]... [REGEX [FILE]]`

## DESCRIPTION

Process JSON file using `jq`, searching through the content looking to match the supplied `<regex>`. Can be used with a file name or via `STDIN` (as part of a pipeline).

### Requirements

- Bash 3.0.27+
- JQ 1.6+

### Arguments

Flatten and then search JSON for the REGEX supplied, using '`.`' if not specified (which matches everything). `jqg` uses the [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions) engine built into `jq`; see the `jq` [man page](https://stedolan.github.io/jq/manual/#RegularexpressionsPCRE) for more details. FILE will be processed as a JSON file, reading `STDIN` if not specified.

### OPTIONS

#### Search options

|    |    |
| --- | --- |
| `-k, --searchkeys` | limit search to just keys |
| `-v, --searchvalues` | limit search to just values |
| `-a, --searchall` | search both keys and values (*default*) |
| `-i, --ignore_case` | regex search is case insensitive (*default*) |
| `-I, --match_case` | regex search is case sensitive |
| `-e, --include_empty` | treat empty JSON arrays and objects as node values (*default*) |
| `-E, --exclude_empty` | do not treat empty JSON arrays and objects as node values|

#### Output options

|    |    |
| --- | --- |
| `-K, --keys` | output just keys |
| `-V, --values` | output just values |
| `-A, --all` | output keys and values (*default*) |
| `-j <str>, --join <str>` | join character/string for key string output (*default '`.`'*) |
| `-J, --join_colon` | use ':' as join character for key string output |
| `-r, --raw` | output as raw strings (ignored with `-A`) -- see [raw output](https://stedolan.github.io/jq/manual/#Invokingjq) for more info |
| `-R, --json` | output as formatted JSON (*default*) |

#### Miscellaneous options

|    |    |
| --- | --- |
| `-q <flag>, --jqopt <flag>` | command-line options to be passed to `jq`; can be given multiple times |
| `-Q, --clear` | clear all `jq` options previously set with `-q` |
| `-h, --help` | print brief help and exit |

## EXAMPLES

An exhaustive look at the different invocation methods as well as each command line option is provided in the [jqg-examples.md](doc/jqg-examples.md) file.

## EXIT STATUS

`jqg` will exit with the exit status of `jq` itself.

## ENVIRONMENT

`$JQG_OPTS` - hard code options to `jqg`; these options can be overridden on the command line

`$JQ_BIN` - full path to the `jq` binary (default is to find it on your `$PATH`

## SEE ALSO

[`jq`](https://stedolan.github.io/jq/)
