#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/032-search-odd-values.bats
#----------------------------------------------------------------------
#--- some JSON values provide lots of edge-case possibilities: null, "", {}, [], false
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# string values
@test "string" {
    run jqg string $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.start-string": "foo",
  "one.string-with-pipe": "this|that",
  "one.string-with-parens": "(this and that)",
  "three.empty-string": "",
  "end-string": "bar"
}
EOF
}



# null value
@test "null" {
    run jqg null-value $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.null-value": null
}
EOF
}



# boolean values
@test "booleans" {
    run jqg boolean $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "two.0.true-boolean": true,
  "two.0.two-b.false-boolean": false
}
EOF
}



# numeric values
@test "numbers" {
    run jqg number $odd_values_json
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
@test "empty JSON" {
    run jqg empty $odd_values_json
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
@test "empty JSON (skip)" {
    run jqg -E empty $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

# empty values (skip iterables)
@test "empty JSON (skip) <long>" {
    run jqg --exclude_empty empty $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}



# sparse array (include)
@test "sparse array (include)" {
    run jqg four $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world"
}
EOF
}

# sparse array (exclude)
@test "sparse array (exclude)" {
    run jqg -E four $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world"
}
EOF
}



# pure array (-v)
@test "pure array (-v)" {
    run jqg -v debet $lorem_array_json
    assert_success
    assert_output - <<EOF
{
  "1.2.0": "debet"
}
EOF
}



# value with dollar sign
@test "dollar sign (-v)" {
    run jqg -v '\$now' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.dollar \$ign": "both-sides-\$now"
}
EOF
}



# leading spaces
@test "leading spaces (-v)" {
    run jqg -v '^\s+' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.leading space": " value",
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  "
}
EOF
}

# multiple leading spaces
@test "multiple leading spaces (-v)" {
    run jqg -v '^\s{2,}' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  "
}
EOF
}

# trailing spaces
@test "trailing spaces (-v)" {
    run jqg -v '\s+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.trailing space": "value ",
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  "
}
EOF
}

# multiple trailing spaces
@test "multiple trailing spaces (-v)" {
    run jqg -v '\s{2,}$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  "
}
EOF
}

# only spaces
@test "only spaces (-v)" {
    run jqg -v '^\s+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.only spaces - value": "  "
}
EOF
}
