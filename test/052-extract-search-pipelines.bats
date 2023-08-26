#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/052-extract-search-pipeline.bats
#----------------------------------------------------------------------
#--- test extract mode - pipelines
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# extraction & search (key)
@test "extraction & search (key)" {
    run bash -c "jqg -x .cat $carnivora_json | jqg breed"
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair"
}
EOF
}



# extraction & search (value)
@test "extraction & search (value)" {
    run bash -c "jqg -x .cat $carnivora_json | jqg tiger"
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger"
}
EOF
}



# multi-element extraction & search (value)
@test "multi-element extraction & search (value)" {
    run bash -c "jqg -x .cat,.dog $carnivora_json | jqg tiger"
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}



# extraction & search (both)
@test "extraction & search (both)" {
    run bash -c "jqg -x .cat,.dog $carnivora_json | jqg domestic"
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



# extract & search with filters - keys
@test "extract & search with filters - keys" {
    run bash -c "jqg -x .cat $carnivora_json | jqg -k f"
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}



# extract & search with filters - values
@test "extract & search with filters - values" {
    run bash -c "jqg -x .cat $carnivora_json | jqg -v f"
    assert_success
    assert_output - <<EOF
{
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy"
}
EOF
}
