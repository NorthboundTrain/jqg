# Running `jqg` Unit Tests

## `jqg`'s Unit Tests

JQG includes a suite of unit tests to help ensure that future code changes do not break current capabilities. As of this writing, there are 640+ tests that run in 75 seconds on my development machine.

## Installing `bats`

The tests are part of the repo, so if you've cloned that already then you have them. However, you'll also need to install the [`bats`](https://github.com/bats-core/bats-core) framework, too. This can be done by doing the initial clone with the `--recurse-submodules` option:

```none
git clone --recurse-submodules https://github.com:NorthboundTrain/jqg.git
git clone --recurse-submodules git@github.com:NorthboundTrain/jqg.git
````

If you've already cloned the repo, you can run the following to pull in just the submodules:

```none
git submodule update --init
```

## Running the Tests

The tests can be run by using some variation of the following:

```none
# run all tests in the test suite
$ test/bats/bin/bats test

# run one file in the test suite
$ test/bats/bin/bats test/10-criteria-options.bats

# run multiple files
$ test/bats/bin/bats test/1*
$ test/bats/bin/bats test/[235]*

# run a subset of tests (based on the test name)
$ test/bats/bin/bats test/31-jqg-opts-envvar.bats --filter separator

# run using Perl's prove TAP harness (BATS is TAP-compliant)
$ prove test/*.bats

# run using an older JQ, or if JQ is not on PATH
$ JQ_BIN=old_jq_bin/jq-1.6 prove test
```

## Benchmarking

There is also a script called `test/benchmark` to help ensure that new changes don't make the JQG script slower. Running the `benchmark` script requires [`hyperfine`](https://github.com/sharkdp/hyperfine), converting the Markdown reports to plain text requires [`pandoc`](https://pandoc.org/), and viewing the reports as a single markdown document uses [`grip`](https://github.com/joeyespo/grip). It takes just over two minutes to run with the default settings. The script will extract tagged versions of the main script from the git repo and then use them to search for random words in all of the larger JSON unit test files, spitting out a mean/min/max report at the end for each version. It will also benchmark the unflattening & extraction modes. Its basic usage is:

usage: `benchmark [-s <seed>] [-c <commit> ...] [-g] [-A|-S -U -X] [-n <num loops>] [-w <warmup>] [-a|-x] [-t <temp dir>]`

## Additional Testing & Reporting Bugs

If you notice any gaps in the test suite or find a bug in one of the tests, please report it via [GitHub](https://github.com/NorthboundTrain/jqg/issues), or submit a pull request.

## See Also

* [`bats`](https://github.com/bats-core/bats-core) - Bash Automated Testing System
* [`prove`](https://perldoc.perl.org/prove) - Run tests through a TAP harness
* [TAP](https://testanything.org/) - Test Anything Protocol
* [`hyperfine`](https://github.com/sharkdp/hyperfine) - Command-line Benchmarking Tool
* [`pandoc`](https://pandoc.org/) - Universal Document Converter
* [`grip`](https://github.com/joeyespo/grip) - GitHub Readme Instant Preview

## License

[Apache-2.0](../LICENSE)<br />
© 2021 Joseph Casadonte
