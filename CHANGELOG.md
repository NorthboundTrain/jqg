# Changelog

All notable changes to this project will be documented in this file.

The format used here is based upon [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) guidelines.

## [1.2.1] - 2022-03-31

### Changed

- change many references to `regex` to use `search criteria` instead ([#4][gh-00004])

### Added

- add tests for some overlooked edge cases

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

_Initial release candidate._

[//]: # (RELEASES)

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
