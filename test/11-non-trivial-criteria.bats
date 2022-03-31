# non-trivial, non-regex search criteria


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



# search for string with embedded space (-k)
@test "[11] search for string with embedded space (-k)" {
    run jqg -k "meyer lemon" $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}


# search for key string with embedded space
@test "[11] search for key string with embedded space" {
    run jqg "meyer lemon" $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.related.Meyer lemon.ancestors.0": "citron",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.color": "yellow"
}
EOF
}


# search for string with open embedded space (-v)
@test "[11] search for string with open embedded space (-v)" {
    run jqg -v " orange" $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.0": "sweet orange",
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.lemon.ancestors.1": "sour orange",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange"
}
EOF
}


# search for string with leading embedded space
@test "[11] search for string with leading open embedded space" {
    run jqg " sweet" $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.is sweet": true,
  "hybrid.grapefruit.is sweet": false
}
EOF
}


# search for string with trailing embedded space
@test "[11] search for string with trailing open embedded space" {
    run jqg "sweet " $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.0": "sweet orange",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange"
}
EOF
}


# search for string with anchored embedded space (-v)
@test "[11] search for string with anchored embedded space (-v)" {
    run jqg -v "r orange" $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.lemon.ancestors.1": "sour orange"
}
EOF
}


# search for value string with anchored embedded space
@test "[11] search for value string with anchored embedded space" {
    run jqg "r orange" $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.orange.sub-categories.1": "bitter orange",
  "hybrid.lemon.ancestors.1": "sour orange"
}
EOF
}


# search for string with embedded hyphen
@test "[11] search for embedded hyphen" {
    run jqg "sub-cat" $CITRUS_JSON
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
@test "[11] search for array elem 1" {
    run jqg -k .1 $CITRUS_JSON
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
@test "[11] search for array elem 1 (-J)" {
    run jqg -k -J :1 $CITRUS_JSON
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
@test "[11] search for array elem 3 (-J)" {
    run jqg -k -J :3 $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "core:3": "pompeda"
}
EOF
}


@test "[11] search for pipe" {
    run jqg '\|' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.string-with-pipe": "this|that",
  "one.key|with|pipe": true
}
EOF
}


@test "[11] search for parens (left)" {
    run jqg '\(' $ODD_VALUES_JSON
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


@test "[11] search for parens (right)" {
    run jqg '\)' $ODD_VALUES_JSON
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


@test "[11] search for parens (either)" {
    run jqg '\(|\)' $ODD_VALUES_JSON
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


@test "[11] search for parens (both)" {
    run jqg '\(\)' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.bare-parens()": true
}
EOF
}
