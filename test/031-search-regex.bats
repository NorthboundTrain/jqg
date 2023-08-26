#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/031-search-regex.bats
#----------------------------------------------------------------------
#--- test regex parsing/processing
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }


@test "two-element or" {
    run jqg 'feral|tiger' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "dog.1.petname": "Tiger",
  "dog.1.feral": true
}
EOF
}



@test "three-element-or" {
    run jqg 'M|tiger|bengal' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.feral.1.species": "Bengal tiger",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.type": "domesticated"
}
EOF
}



@test "three-element or with flags" {
    run jqg -I 'M|tiger|bengal' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



@test "three-element or with flags, no quotes" {
    run jqg -I M\|tiger\|bengal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



@test "zero-width negative look-behind (case-sensitive)" {
    run jqg '(?<!T)iger' $carnivora_json
    assert_success
    assert_output - <<EOF
{}
EOF
}



@test "zero-width negative look-behind (case-insensitive)" {
    run jqg -I '(?<!T)iger' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger"
}
EOF
}



@test "case-insensitive two-element value search" {
    run jqg -v 'f|M' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.type": "domesticated"
}
EOF
}



@test "case-insensitive two-element value search w/ REGEX override" {
    skip "due to a bug in JQ's Oniguruma library, this requires a post 1.6 JQ build"
    run jqg -v 'f|(?-i:M)' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



@test "case-sensitive two-element value search" {
    run jqg -Iv 'f|M' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



@test "case-sensitive two-element value search w/ REGEX override" {
    run jqg -Iv 'f|(?i:M)' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.type": "domesticated"
}
EOF
}



@test "regex with escapes" {
    run jqg -v '(?<!\d)0|\[\]' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
EOF
}



@test "regex with captures" {
    run jqg '(feral|tiger)' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "dog.1.petname": "Tiger",
  "dog.1.feral": true
}
EOF
}
