#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/011-non-trivial-criteria.bats
#----------------------------------------------------------------------
#--- test non-trivial criteria use cases
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# flattened-specific searches
@test "search for flattened key string" {
    run jqg "hybrid.lemon" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.ancestors.0": "citron",
  "hybrid.lemon.ancestors.1": "sour orange",
  "hybrid.lemon.related.rough lemon.ancestors.0": "citron",
  "hybrid.lemon.related.rough lemon.ancestors.1": "mandarin",
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}

# flattened-specific searches (-J)
@test "search for flattened key string (-J)" {
    run jqg -J "hybrid:lemon" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid:lemon:ancestors:0": "citron",
  "hybrid:lemon:ancestors:1": "sour orange",
  "hybrid:lemon:related:rough lemon:ancestors:0": "citron",
  "hybrid:lemon:related:rough lemon:ancestors:1": "mandarin",
  "hybrid:lemon:related:Meyer lemon:ancestors:0": "citron",
  "hybrid:lemon:related:Meyer lemon:ancestors:1": "sweet orange",
  "hybrid:lemon:related:Meyer lemon:color": "yellow"
}
EOF
}

# search for string with embedded space
@test "search for string with embedded space" {
    run jqg "meyer lemon" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}


# search for key string with embedded space (-k)
@test "search for key string with embedded space (-k)" {
    run jqg -k "meyer lemon" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}


# search for value string with embedded space (-v)
@test "search for value string with embedded space (-v)" {
    run jqg -v "bitter orange" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.1": "bitter orange"
}
EOF
}


# search for string with leading embedded space
@test "search for string with leading open embedded space" {
    run jqg " sweet" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.is sweet": true,
  "hybrid.grapefruit.is sweet": false
}
EOF
}


# search for string with trailing embedded space
@test "search for string with trailing open embedded space" {
    run jqg "sweet " $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.0": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange"
}
EOF
}


# search for string with anchored embedded space
@test "search for string with anchored embedded space" {
    run jqg "r orange" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.lemon.ancestors.1": "sour orange"
}
EOF
}


# search for value string with anchored embedded space (-v)
@test "search for value string with anchored embedded space (-v)" {
    run jqg -v "r orange" $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.lemon.ancestors.1": "sour orange"
}
EOF
}


# search for string with embedded hyphen
@test "search for embedded hyphen" {
    run jqg "sub-cat" $citrus_json
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


# search for array element #1 only
@test "search for array elem 1" {
    run jqg -k .1 $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core.1": "mandarin",
  "hybrid.orange.ancestors.1": "pomelo",
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.grapefruit.ancestors.1": "mandarin",
  "hybrid.grapefruit.sub-categories.1": "mandelo",
  "hybrid.lemon.ancestors.1": "sour orange",
  "hybrid.lemon.related.rough lemon.ancestors.1": "mandarin",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lime.ancestors.1": "mandarin",
  "hybrid.lime.sub-categories.1": "Key lime"
}
EOF
}


# search for array element #1 only
@test "search for array elem 1 (-J)" {
    run jqg -k -J :1 $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core:1": "mandarin",
  "hybrid:orange:ancestors:1": "pomelo",
  "hybrid:orange:sub-categories:1": "bitter orange",
  "hybrid:grapefruit:ancestors:1": "mandarin",
  "hybrid:grapefruit:sub-categories:1": "mandelo",
  "hybrid:lemon:ancestors:1": "sour orange",
  "hybrid:lemon:related:rough lemon:ancestors:1": "mandarin",
  "hybrid:lemon:related:Meyer lemon:ancestors:1": "sweet orange",
  "hybrid:lime:ancestors:1": "mandarin",
  "hybrid:lime:sub-categories:1": "Key lime"
}
EOF
}


# search for array element #3 only
@test "search for array elem 3 (-J)" {
    run jqg -k -J :3 $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core:3": "pompeda"
}
EOF
}


@test "search for pipe" {
    run jqg '\|' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.string-with-pipe": "this|that",
  "one.key|with|pipe": true
}
EOF
}


@test "search for parens (left)" {
    run jqg '\(' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.string-with-parens": "(this and that)",
  "one.key(with)parens": true,
  "one.bare-parens()": true,
  "one.left(paren-only": true
}
EOF
}


@test "search for parens (right)" {
    run jqg '\)' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.string-with-parens": "(this and that)",
  "one.key(with)parens": true,
  "one.bare-parens()": true,
  "one.unmatched-left)-paren": false
}
EOF
}


@test "search for parens (either)" {
    run jqg '\(|\)' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.string-with-parens": "(this and that)",
  "one.key(with)parens": true,
  "one.bare-parens()": true,
  "one.left(paren-only": true,
  "one.unmatched-left)-paren": false
}
EOF
}


@test "search for emptparens (both)" {
    run jqg '\(\)' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.bare-parens()": true
}
EOF
}
