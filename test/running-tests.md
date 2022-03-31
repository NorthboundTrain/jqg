# Running `jqg` Unit Tests

## `jqg`'s Unit Tests

JQG includes a suite of unit tests to help ensure that future code
changes do not break current capabilities. As of this writing, there are
240+ tests that run in around 65 seconds on my development machine -- not the largest
or fastest test suite out there, by a long shot, but it meets the project's needs.

## Installing `bats`

The tests are part of the repo, so if you've cloned that already then you have
them. However, you'll also need to install the
[`bats`](https://github.com/bats-core/bats-core) framework, too. This can
be done by doing the initial clone with the `--recurse-submodules` option:

```none
git clone --recurse-submodules https://github.com:NorthboundTrain/jqg.git
git clone --recurse-submodules git@github.com:NorthboundTrain/jqg.git
```

You can run the following to pull in the submodules if you've already cloned the repo:

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

# run using Perl's prove TAP harness
$ prove test/*.bats
```

## Additional Testing & Reporting Bugs

If you notice any gaps in the test suite or find a bug in one of the tests,
please report it via [GitHub](https://github.com/NorthboundTrain/jqg/issues),
or submit a pull request.

## SEE ALSO

* [`bats`](https://github.com/bats-core/bats-core) - Bash Automated Testing System
* [`prove`](https://perldoc.perl.org/prove) - Run tests through a TAP harness
