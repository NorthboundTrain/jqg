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
    ODD_VALUES_JSON=$DIR/odd-values.json
}



# dot regex tests
@test "[40] dot regex" {
    run jqg . $CARNIVORA_JSON
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



@test "[40] default regex in pipe" {
    run bash -c "cat $CARNIVORA_JSON | jqg"
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



@test "[40] dot regex in pipe" {
    run bash -c "cat $CARNIVORA_JSON | jqg ."
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



# PCRE tests
@test "[40] two-element or" {
    run jqg 'feral|tiger' $CARNIVORA_JSON
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



@test "[40] three-element-or" {
    run jqg 'M|tiger|bengal' $CARNIVORA_JSON
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



@test "[40] three-element or with flags" {
    run jqg -I 'M|tiger|bengal' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



@test "[40] three-element or with flags, no quotes" {
    run jqg -I M\|tiger\|bengal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



@test "[40] zero-width negative look-behind (case-sensitive)" {
    run jqg '(?<!T)iger' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{}
EOF
}



@test "[40] zero-width negative look-behind (case-insensitive)" {
    run jqg -I '(?<!T)iger' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger"
}
EOF
}



@test "[40] case-insensitive two-element value search" {
    run jqg -v 'f|M' $CARNIVORA_JSON
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



@test "[40] case-insensitive two-element value search w/ REGEXP override" {
    skip "due to a bug in JQ's Oniguruma library, this requires a post 1.6 JQ build"
    run jqg -v 'f|(?-i:M)' $CARNIVORA_JSON
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



@test "[40] case-sensitive two-element value search" {
    run jqg -Iv 'f|M' $CARNIVORA_JSON
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



@test "[40] case-sensitive two-element value search w/ REGEXP override" {
    run jqg -Iv 'f|(?i:M)' $CARNIVORA_JSON
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



@test "[40] regex with escapes" {
    run jqg -v '(?<!\d)0|\[\]' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
EOF
}



@test "[40] regex with captures" {
    run jqg '(feral|tiger)' $CARNIVORA_JSON
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
