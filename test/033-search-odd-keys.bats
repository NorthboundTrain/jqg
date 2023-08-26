#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/033-search-odd-keys.bats
#----------------------------------------------------------------------
#--- some JSON keys provide lots of edge-case possibilities
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# output keys with spaces
@test "output keys with spaces" {
    run jqg meyer $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}

# search for keys with spaces
@test "search for keys with spaces" {
    run jqg 'meyer lemon' $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}

# output keys with dashes
@test "output keys with dashes" {
    run jqg categories $citrus_json
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

# search for keys with dashes
@test "search for keys with dashes" {
    run jqg - $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.start-string": "foo",
  "one.null-value": null,
  "one.integer-number": 101,
  "one.string-with-pipe": "this|that",
  "one.string-with-parens": "(this and that)",
  "one.bare-parens()": true,
  "one.left(paren-only": true,
  "one.unmatched-left)-paren": false,
  "one.dollar \$ign": "both-sides-\$now",
  "one.period-in-value": "hello.world",
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.0.true-boolean": true,
  "two.0.two-b.false-boolean": false,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b",
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": [],
  "five.   ": "only spaces - key",
  "five.only spaces - value": "  ",
  "end-string": "bar"
}
EOF
}



# pure array (-k)
@test "pure array (-k)" {
    run jqg -k debet $lorem_array_json
    assert_success
    assert_output - <<EOF
{}
EOF
}



# key with space
@test "any whitespace (-k)" {
    run jqg -k '\s' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.dollar \$ign": "both-sides-\$now",
  "five. leading space": "key",
  "five.trailing space ": "key",
  "five.  multi surround spaces   ": "key",
  "five.   ": "only spaces - key",
  "five.leading space": " value",
  "five.trailing space": "value ",
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  "
}
EOF
}



# key with dollar sign
@test "dollar sign (-k)" {
    run jqg -v '\$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.dollar \$ign": "both-sides-\$now"
}
EOF
}



# leading spaces
@test "leading spaces (-k)" {
    run jqg -k '\.\s+' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five. leading space": "key",
  "five.  multi surround spaces   ": "key",
  "five.   ": "only spaces - key"
}
EOF
}

# multiple leading spaces
@test "multiple leading spaces (-k)" {
    run jqg -k '\.\s{2,}' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.  multi surround spaces   ": "key",
  "five.   ": "only spaces - key"
}
EOF
}

# trailing spaces
@test "trailing spaces (-k)" {
    run jqg -k '\s+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.trailing space ": "key",
  "five.  multi surround spaces   ": "key",
  "five.   ": "only spaces - key"
}
EOF
}

# multiple trailing spaces
@test "multiple trailing spaces (-k)" {
    run jqg -k '\s{2,}$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.  multi surround spaces   ": "key",
  "five.   ": "only spaces - key"
}
EOF
}

# only spaces
@test "only spaces (-k)" {
    run jqg -k '\.\s+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "five.   ": "only spaces - key"
}
EOF
}
