# Changelog

All notable changes to this project will be documented in this file.

The format used here is based upon [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) guidelines.

## [1.3.0] - 2023-08-26

### Changed

- **Breaking:** the exit code for JQG command line-related errors is now 2 (it was 1)
- **Breaking:** use of a deprecated option (see below) will print a warning to STDERR
- refactor main JQG algorithm to be more modular and intent-driven
  - JQ filter is now created dynamically from filter sections
- refactor test suite
  - reorganize and centralize common functions and definitions
  - break out into many smaller files for better test organization
- alter semantics (but not effect) of the `-J` option
  - it is now an alternate of the `--join_alt` option (with complete backwards compatibility, unless/until `--join_char` is used)
- change definition of `--join_colon` to be a synonym of `--join ':'`
- restructure the [jqg-filters.md](docs/jqg-filters.md) documentation to better present additional content and reduce repetitious text
- bump `bats` from 1.6.0 to 1.7.0
- bump `bats-assert` to 2.0.0 (latest)
- bump `bats-file` to 0.3.0 (latest)

### Added

- add **extract** mode
- provide `jqu` & `jqx` composite mode scripts
- add `--join_char` option to set alternate join character (*default: `:`*)
- add `--join_alt` option to use the alternate join character
- provide options to manipulate input and output transformations independent of mode
- add `-n, --empty_results_ok` option to indicate that returning no results is not an error (*default behavior*)
- add `-N, --results_required` option to indicate that returning no results is an error (exit code: `1`)
- add `--version` to print out the script version
- add new JSON unit test files with specific structures
- add very large JSON unit test files
- add many new unit tests
  - cover new features & command line options
  - cover missing tests and option combinations
  - ensure that `flatten_json`, `unflatten_json`, and `extract_json` are all [idempotent](https://en.wikipedia.org/wiki/Idempotent)
- add benchmarking script (see [running-tests.md](test/running-tests.md#benchmarking))
- add `.gitignore` to ignore backup `docs/jqg-examples-*.md` files

### Deprecated

**Note:** *These options will be removed in a future release.* Using these options will print a warning to STDERR.

- deprecate use of `-f` and `--flatten`; use `-s` or `--search` instead
- deprecate use of `--join_colon`; use `-j ':'`, `--join ':'`, `-J` or `--join_alt` instead

### Fixed

- fix edge case in `unflatten_json` that prevented it from being [idempotent](https://en.wikipedia.org/wiki/Idempotent)

## [1.2.2] - 2022-06-19

### Fixed

- fix broken links in documentation ([#6][gh-00006])

## [1.2.1] - 2022-03-31

### Changed

- change many references to `regex` to use `search criteria` instead ([#4][gh-00004])

### Added

- add tests for some overlooked edge cases
- add timeout to curl test & skip test if tripped ([#5][gh-00005])

### Fixed

- remove extraneous regex modifiers ('`x`' and '`n`') ([#2][gh-00002])
- fix documentation links in [`README.md`](README.md) ([#3][gh-00003])

## [1.2.0] - 2022-03-23

### Changed

- bump BATS/* from 1.3.0 to 1.6.0
- refactor code to support different execution modes
- standardize [`jqg.md`](docs/jqg.md) layout
- refactor script to generate [`jqg-examples.md`](docs/jqg-examples.md) to support more robust example content

### Added

- add `unflatten` mode with unit tests & examples
- add mode-selection unit tests
- add `.proverc` to make running unit tests with Perl's `prove` more convenient
- add command line option to select default mode (`--flatten | --search`)
- add tests to produce flattened sparse array output

### Fixed

- fix links to wrong `BATS` repo

## [1.1.3] - 2022-03-19

### Added

- add tests for problematic field separators (e.g. asterisk, space)

### Fixed

- fix `shellcheck` error regarding `$JQG_OPTS` ([#1][gh-00001])
- fix remaining `shellcheck` errors

## [1.1.2] - 2022-03-19

### Changed

- reorganize `README.md` according to [Standard Readme](https://github.com/RichardLitt/standard-readme)

### Added

- add `CHANGELOG.md`
- add doc on running unit tests (`test/running-tests.md`)

### Fixed

- fix typos in `jqg-examples.md`
- fix/clarify Symbolic Binding Operator documentation in `jqg-filters.md`
- fix minor doc issues

## [1.1.1] - 2021-05-23

### Changed

- skip tests requiring newer Oniguruma lib in JQ

## [1.1.0] - 2021-05-23

### Changed

- refactor filter to use JQ functions
- rewrite `jq-filters.md` for clarity & accuracy
- reorganize `jq-filters.md` to match refactored filter
- fix linter ([shellcheck](https://github.com/koalaman/shellcheck)) and spelling issues

### Added

- add ability to generate `jqg-examples.md` from `99-examples.bats` test file
- add `-debug` option
- add `PCRE` tests

### Fixed

- fix many examples in `jqg-examples.md`

## [1.0.0] - 2021-05-15

### Changed

- make `odd-values.json` example data more useful
- clean up `jq-filters.md` document

### Added

- add `bug report` template to GitHub site
- add `feature request` template to GitHub site

## [1.0.0-rc.1] - 2021-05-15

*Initial release candidate.*

[//]: # (RELEASES)

[1.3.0]: https://github.com/NorthboundTrain/jqg/tree/v1.3.0
[1.2.2]: https://github.com/NorthboundTrain/jqg/tree/v1.2.2
[1.2.1]: https://github.com/NorthboundTrain/jqg/tree/v1.2.1
[1.2.0]: https://github.com/NorthboundTrain/jqg/tree/v1.2.0
[1.1.3]: https://github.com/NorthboundTrain/jqg/tree/v1.1.3
[1.1.2]: https://github.com/NorthboundTrain/jqg/tree/v1.1.2
[1.1.1]: https://github.com/NorthboundTrain/jqg/tree/v1.1.1
[1.1.0]: https://github.com/NorthboundTrain/jqg/tree/v1.1.0
[1.0.0]: https://github.com/NorthboundTrain/jqg/tree/v1.0.0
[1.0.0-rc.1]: https://github.com/NorthboundTrain/jqg/tree/v1.0.0-rc.1

[//]: # (ISSUES)

[gh-00001]: https://github.com/NorthboundTrain/jqg/issues/1
[gh-00002]: https://github.com/NorthboundTrain/jqg/issues/2
[gh-00003]: https://github.com/NorthboundTrain/jqg/issues/3
[gh-00004]: https://github.com/NorthboundTrain/jqg/issues/4
[gh-00005]: https://github.com/NorthboundTrain/jqg/issues/5
[gh-00006]: https://github.com/NorthboundTrain/jqg/issues/6
