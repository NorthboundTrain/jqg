# test jq option passthrough:

# -q <opt> pass-through options to JQ


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

    CARNIVORA_JSON=$DIR/carnivora.json
}



# JQ pass-through options
@test "[30] no JQ opts" {
    run jqg mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "[30] sort option (-S)" {
    run jqg -q -S mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}

@test "[30] sort option (-S) <long>" {
    run jqg --jqopt -S mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}

@test "[30] compact option (-c)" {
    run jqg -q -c mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}

@test "[30] sort & compact options (-S -c)" {
    run jqg -q -S -q -c mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "[30] sort & compact options (-S -c) <long>" {
    run jqg --jqopt -S --jqopt -c mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "[30] sort & compact options (--long)" {
    run jqg -q --sort-keys -q --compact-output mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "[30] sort & compact options (--long) <long>" {
    run jqg --jqopt --sort-keys --jqopt --compact-output mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "[30] sort & compact options -- cleared" {
    run jqg -q -S -q -c -Q mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "[30] sort & compact options -- cleared <long>" {
    run jqg -q -S -q -c --clear mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}
