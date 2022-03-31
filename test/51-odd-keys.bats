# json key string edge cases (e.g. spaces, dashes)


setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    # load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"

    CITRUS_JSON=$DIR/citrus.json
    ODD_VALUES_JSON=$DIR/odd-values.json
}



# keys with spaces
@test "[51] keys with spaces" {
    run jqg meyer $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}

# keys with dashes
@test "[51] keys with dashes" {
    run jqg categories $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.0": "sweet orange",
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.grapefruit.sub-categories.0": "common grapefruit",
  "hybrid.grapefruit.sub-categories.1": "mandelo",
  "hybrid.lime.sub-categories.0": "Rangpur lime",
  "hybrid.lime.sub-categories.1": "Key lime"
}
EOF
}
