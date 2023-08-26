#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/010-search-criteria-options.bats
#----------------------------------------------------------------------
#--- test the search criteria options
#----------------------------------------------------------------------
#   -i / --ignore_case (default)
#   -I / --match_case
#
#   -e / --include_empty (default)
#   -E / --exclude_empty
#
#   -a / --search_all (default)
#   -k / --search_keys
#   -v / --search_values
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }


# case sensitivity
@test "case insensitive (default)" {
    run jqg tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "case insensitive (Upper)" {
    run jqg -i Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "case insensitive (Upper) <long>" {
    run jqg --ignore_case Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "case insensitive (lower)" {
    run jqg -i tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "case insensitive (ALL CAPS)" {
    run jqg -i TIGER $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}



@test "case sensitive (Upper)" {
    run jqg -I Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}

@test "case sensitive (Upper) <long>" {
    run jqg --match_case Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}

@test "case sensitive (lower)" {
    run jqg -I tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger"
}
EOF
}

@test "case sensitive (ALL CAPS)" {
    run jqg -I TIGER $carnivora_json
    assert_success
    assert_output "{}"
}



# search string selection
@test "search both (default)" {
    run jqg domestic $carnivora_json
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



@test "search both" {
    run jqg -a domestic $carnivora_json
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

@test "search both <long>" {
    run jqg --searchall domestic $carnivora_json
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

@test "search keys" {
    run jqg -k domestic $carnivora_json
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

@test "search keys <long>" {
    run jqg --searchkeys domestic $carnivora_json
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

@test "search values" {
    run jqg -v domestic $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
EOF
}

@test "search values <long>" {
    run jqg --searchvalues domestic $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
EOF
}



@test "search for key-only string (default)" {
    run jqg species $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat"
}
EOF
}

@test "search both for key-only string" {
    run jqg -a species $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat"
}
EOF
}

@test "search keys for key-only string" {
    run jqg -k species $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat"
}
EOF
}

@test "search values for key-only string" {
    run jqg -v species $carnivora_json
    assert_success
    assert_output "{}"
}



@test "search for value-only string (default)" {
    run jqg tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "search both for value-only string" {
    run jqg -a tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

@test "search keys for value-only string" {
    run jqg -k tiger $carnivora_json
    assert_success
    assert_output "{}"
}

@test "search values for value-only string" {
    run jqg -v tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}




@test "default empty filter" {
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

@test "include empty JSON" {
    run jqg -e empty $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
EOF
}

@test "include empty JSON <long>" {
    run jqg --include_empty empty $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
EOF
}

@test "exclude empty JSON" {
    run jqg -E empty $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

@test "exclude empty JSON <long>" {
    run jqg --exclude_empty empty  $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}
