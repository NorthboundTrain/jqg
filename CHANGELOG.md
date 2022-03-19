# Changelog

All notable changes to this project will be documented in this file.

The format used here is based upon [Common Changelog](https://common-changelog.org/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) guidelines.

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

[1.1.3]: https://github.com/NorthboundTrain/jqg/tree/v1.1.3
[1.1.2]: https://github.com/NorthboundTrain/jqg/tree/v1.1.2
[1.1.1]: https://github.com/NorthboundTrain/jqg/tree/v1.1.1
[1.1.0]: https://github.com/NorthboundTrain/jqg/tree/v1.1.0
[1.0.0]: https://github.com/NorthboundTrain/jqg/tree/v1.0.0
[1.0.0-rc.1]: https://github.com/NorthboundTrain/jqg/tree/v1.0.0-rc.1

[//]: # (ISSUES)

[gh-00001]: https://github.com/NorthboundTrain/jqg/issues/1