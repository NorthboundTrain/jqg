# test the output content options:

# -K output keys
# -V output values
# -A output all (default)

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



# output everthing (default)
@test "[20] default output (object)" {
    run jqg mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "[20] default output (array)" {
    run jqg feral $CARNIVORA_JSON
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

@test "[20] default output (mixed - hanging array)" {
    run jqg feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}

@test "[20] default output (mixed - embedded array)" {
    run jqg king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}

@test "[20] default output (empty)" {
    run jqg ursa $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



# output everthing
@test "[20] output all (object)" {
    run jqg -A mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "[20] output all (object) <long>" {
    run jqg --all mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "[20] output all (array)" {
    run jqg -A feral $CARNIVORA_JSON
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

@test "[20] output all (mixed - hanging array)" {
    run jqg -A feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}

@test "[20] output all (mixed - embedded array)" {
    run jqg -A king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}

@test "[20] output all (empty)" {
    run jqg -A ursa $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



# output keys
@test "[20] output keys (object)" {
    run jqg -K mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "isa",
  "classification.class"
]
EOF
}

@test "[20] output keys (object) <long>" {
    run jqg --keys mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "isa",
  "classification.class"
]
EOF
}

@test "[20] output keys (array)" {
    run jqg -K feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "cat.feral.0.species",
  "cat.feral.0.aka",
  "cat.feral.1.species",
  "cat.feral.2.species",
  "cat.feral.2.aka",
  "dog.1.feral"
]
EOF
}

@test "[20] output keys (mixed - hanging array)" {
    run jqg -K feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "subclades.0",
  "cat.isa",
  "cat.feral.2.aka"
]
EOF
}

@test "[20] output keys (mixed - embedded array)" {
    run jqg -K king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "classification.kingdom",
  "cat.feral.0.aka"
]
EOF
}

@test "[20] output keys (empty)" {
    run jqg -K ursa $CARNIVORA_JSON
    assert_success
    assert_output "[]"
}



# output values
@test "[20] output values (object)" {
    run jqg -V mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "mammal",
  "mammalia"
]
EOF
}

@test "[20] output values (object) <long>" {
    run jqg --values mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "mammal",
  "mammalia"
]
EOF
}

@test "[20] output values (array)" {
    run jqg -V feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "lion",
  "king of the beasts",
  "Bengal tiger",
  "black-footed cat",
  "felis nigripes",
  true
]
EOF
}

@test "[20] output values (mixed - hanging array)" {
    run jqg -V feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "feliformia",
  "feline",
  "felis nigripes"
]
EOF
}

@test "[20] output value (mixed - embedded array)" {
    run jqg -V king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "animalia",
  "king of the beasts"
]
EOF
}

@test "[20] output values (empty)" {
    run jqg -V ursa $CARNIVORA_JSON
    assert_success
    assert_output "[]"
}
