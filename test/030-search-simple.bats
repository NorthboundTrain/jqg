#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/030-search-simple.bats
#----------------------------------------------------------------------
#--- test simple search criteria
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# default / dot search criteria tests
@test "default search criteria" {
    run jqg $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
EOF
}



@test "dot search criteria" {
    run jqg . $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
EOF
}



@test "default search criteria in pipe" {
    run bash -c "cat $carnivora_json | jqg"
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
EOF
}



@test "dot search criteria in pipe" {
    run bash -c "cat $carnivora_json | jqg ."
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
EOF
}



@test "missing search criteria" {
    run jqg "" $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
EOF
}



@test "missing search criteria with other options" {
    run jqg -q -S "" $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "cat.domesticated.1.petname": "Misty",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.aka": "felis nigripes",
  "cat.feral.2.species": "black-footed cat",
  "cat.isa": "feline",
  "classification.class": "mammalia",
  "classification.kingdom": "animalia",
  "classification.phylum": "chordata",
  "dog.0.breed": "mutt",
  "dog.0.petname": "Growler",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.petname": "Tiger",
  "dog.1.type": "domesticated",
  "dog.2": {},
  "isa": "mammal",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia"
}
EOF
}



@test "simple search criteria (keys only)" {
    run jqg feral $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "dog.1.feral": true
}
EOF
}



@test "simple search criteria (values only)" {
    run jqg yellow $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.color": "yellow",
  "dog.1.breed": "yellow labrador"
}
EOF
}



@test "simple search criteria (both)" {
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



@test "search null input" {
    run jqg foobar <<<"null"
    assert_success
    assert_output "{}"
}
