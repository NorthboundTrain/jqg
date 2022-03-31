setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"
}

@test "[01] run jqg" {
    run jqg </dev/null
    assert_success
}

@test "[01] run jqg -h" {
    run jqg -h </dev/null
    assert_success
    assert_output --partial CRITERIA
    assert_output --partial --bug
}

@test "[01] run jqg -h <long>" {
    run jqg --help </dev/null
    assert_success
    assert_output --partial CRITERIA
    assert_output --partial --bug
}

@test "[01] run jqg --bug" {
    run jqg --bug </dev/null
    assert_success
    assert_output --partial JQG_OPT
}

@test "[01] check for test JSON files" {
    assert_file_exist $DIR/carnivora.json
    assert_file_exist $DIR/citrus.json
    assert_file_exist $DIR/odd-values.json
}


# check bash version
# check jq version
