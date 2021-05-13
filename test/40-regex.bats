# test regex parsing/processing


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



# missing regex
@test "[40] missing regex" {
    run jqg "" $CARNIVORA_JSON
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

@test "[40] missing regex with other options" {
    run jqg -q -S "" $CARNIVORA_JSON
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


# test regex capabilities (particularly around quoting)
