# test the search criteria options:

# -i case insensitive (default)
# -I case sensitive

# -k search keys
# -v search values
# -a search both (default)

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
    ODD_VALUES_JSON=$DIR/odd-values.json
}


# case sensitivity
@test "[10] case insensitive (default)" {
    run jqg tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] case insensitive (Upper)" {
    run jqg -i Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] case insensitive (Upper) <long>" {
    run jqg --ignore_case Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] case insensitive (lower)" {
    run jqg -i tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] case insensitive (ALL CAPS)" {
    run jqg -i TIGER $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}



@test "[10] case sensitive (Upper)" {
    run jqg -I Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] case sensitive (Upper) <long>" {
    run jqg --match_case Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] case sensitive (lower)" {
    run jqg -I tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger"
}
EOF
}

@test "[10] case sensitive (ALL CAPS)" {
    run jqg -I TIGER $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



# search string selection
@test "[10] search both (default)" {
    run jqg domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.1.type": "domesticated"
}
EOF
}



@test "[10] search both" {
    run jqg -a domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.1.type": "domesticated"
}
EOF
}

@test "[10] search both <long>" {
    run jqg --searchall domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.1.type": "domesticated"
}
EOF
}

@test "[10] search keys" {
    run jqg -k domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow"
}
EOF
}

@test "[10] search keys <long>" {
    run jqg --searchkeys domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow"
}
EOF
}

@test "[10] search values" {
    run jqg -v domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
EOF
}

@test "[10] search values <long>" {
    run jqg --searchvalues domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
EOF
}



@test "[10] search for key-only string (default)" {
    run jqg species $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat"
}
EOF
}

@test "[10] search both for key-only string" {
    run jqg -a species $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat"
}
EOF
}

@test "[10] search keys for key-only string" {
    run jqg -k species $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat"
}
EOF
}

@test "[10] search values for key-only string" {
    run jqg -v species $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



@test "[10] search for value-only string (default)" {
    run jqg tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] search both for value-only string" {
    run jqg -a tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[10] search keys for value-only string" {
    run jqg -k tiger $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}

@test "[10] search values for value-only string" {
    run jqg -v tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}




@test "[10] default empty filter" {
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

@test "[10] include empty JSON" {
    run jqg -e empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
EOF
}

@test "[10] include empty JSON <long>" {
    run jqg --include_empty empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
EOF
}

@test "[10] exclude empty JSON" {
    run jqg -E empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

@test "[10] exclude empty JSON <long>" {
    run jqg --exclude_empty empty  $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}
