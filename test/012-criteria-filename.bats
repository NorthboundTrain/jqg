#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/012-criteria-filename.bats
#----------------------------------------------------------------------
#--- test criteria/filename argument combinations
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# criteria only (stdin)
@test "criteria only (stdin)" {
    run jqg tiger < $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

# criteria only (pipeline)
@test "criteria only (pipeline)" {
    run bash -c "jq . $carnivora_json | jqg tiger"
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

# filename only
@test "filename only" {
    jq_md5=$(jq . $carnivora_json | md5sum | cut -d ' ' -f 1)
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

# criteria & filename
@test "criteria & filename" {
    run jqg tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}

# filename & criteria (fail)
@test "filename & criteria (fail)" {
    run jqg $carnivora_json tiger
    assert_failure # JQ exit code
}
