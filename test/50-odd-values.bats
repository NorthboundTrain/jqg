# some input values are hard to deal with: null, "", {}, [], false


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

    ODD_VALUES_JSON=$DIR/odd-values.json
}



# string values
@test "[50] string" {
    run jqg string $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.start-string": "foo",
  "three.empty-string": "",
  "end-string": "bar"
}
EOF
}



# null value
@test "[50] null" {
    run jqg null-value $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.null-value": null
}
EOF
}



# boolean values
@test "[50] booleans" {
    run jqg boolean $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "two.0.true-boolean": true,
  "two.0.two-b.false-boolean": false
}
EOF
}



# numeric values
@test "[50] numbers" {
    run jqg number $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0
}
EOF
}



# empty values
@test "[50] empty JSON" {
    run jqg empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
EOF
}



# empty values (skip iterables)
@test "[50] empty JSON (skip)" {
    run jqg -E empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

# empty values (skip iterables)
@test "[50] empty JSON (skip) <long>" {
    run jqg --exclude_empty empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

# sparse array (include)
@test "[50] sparse array" {
    run jqg four $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": "fourth"
}
EOF
}

# sparse array (exclude)
@test "[50] sparse array(exclude)" {
    run jqg -E four $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.3": "fourth"
}
EOF
}
