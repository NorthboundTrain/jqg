# test the output format options:

# -j <char> key separator character (default: ".")
# -J use alternate key separator character ($JQG_ALTSEP)

# -r do not put strings in quotes
# -R print valid JSON (default)


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



# output with defaults
@test "[21] default output (object)" {
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

@test "[21] default output (array)" {
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

@test "[21] default output (array w/ boolean)" {
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

@test "[21] default output (one-element array)" {
    run jqg -V feline $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "feline"
]
EOF
}

@test "[21] default output (empty)" {
    run jqg ursa $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



# output everthing
@test "[21] non-raw output (object)" {
    run jqg -R feral $CARNIVORA_JSON
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

@test "[21] non-raw output (array)" {
    run jqg -R -K feral $CARNIVORA_JSON
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

@test "[21] non-raw output (array) <long>" {
    run jqg --json -K feral $CARNIVORA_JSON
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

@test "[21] non-raw output (array w/ boolean)" {
    run jqg -R -V feral $CARNIVORA_JSON
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

@test "[21] non-raw output (one-element array)" {
    run jqg -R -V feline $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "feline"
]
EOF
}

@test "[21] non-raw output (empty)" {
    run jqg -R ursa $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



# raw output
@test "[21] raw output (object)" {
    run jqg -r feral $CARNIVORA_JSON
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

@test "[21] raw output (array)" {
    run jqg -r -K feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
cat.feral.0.species
cat.feral.0.aka
cat.feral.1.species
cat.feral.2.species
cat.feral.2.aka
dog.1.feral
EOF
}

@test "[21] raw output (array) <long>" {
    run jqg --raw -K feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
cat.feral.0.species
cat.feral.0.aka
cat.feral.1.species
cat.feral.2.species
cat.feral.2.aka
dog.1.feral
EOF
}

@test "[21] raw output (array w/ boolean)" {
    run jqg -r -V feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
lion
king of the beasts
Bengal tiger
black-footed cat
felis nigripes
true
EOF
}

@test "[21] raw output (one-element array)" {
    run jqg -r -V feline $CARNIVORA_JSON
    assert_success
    assert_output "feline"
}

@test "[21] raw output (empty)" {
    run jqg -r ursa $CARNIVORA_JSON
    assert_success
    assert_output "{}"
}



#
@test "[21] default separator (object)" {
    run jqg -r feral $CARNIVORA_JSON
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

@test "[21] dot separator (object)" {
    run jqg -j . -r feral $CARNIVORA_JSON
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

@test "[21] colon separator (object)" {
    run jqg -J -r feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat:feral:0:species": "lion",
  "cat:feral:0:aka": "king of the beasts",
  "cat:feral:1:species": "Bengal tiger",
  "cat:feral:2:species": "black-footed cat",
  "cat:feral:2:aka": "felis nigripes",
  "dog:1:feral": true
}
EOF
}

@test "[21] colon separator (object) <long>" {
    run jqg --join_colon -r feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat:feral:0:species": "lion",
  "cat:feral:0:aka": "king of the beasts",
  "cat:feral:1:species": "Bengal tiger",
  "cat:feral:2:species": "black-footed cat",
  "cat:feral:2:aka": "felis nigripes",
  "dog:1:feral": true
}
EOF
}

@test "[21] arbitrary separator (object)" {
    run jqg -j + -r feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat+feral+0+species": "lion",
  "cat+feral+0+aka": "king of the beasts",
  "cat+feral+1+species": "Bengal tiger",
  "cat+feral+2+species": "black-footed cat",
  "cat+feral+2+aka": "felis nigripes",
  "dog+1+feral": true
}
EOF
}

@test "[21] arbitrary separator (object) <long>" {
    run jqg --join + -r feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat+feral+0+species": "lion",
  "cat+feral+0+aka": "king of the beasts",
  "cat+feral+1+species": "Bengal tiger",
  "cat+feral+2+species": "black-footed cat",
  "cat+feral+2+aka": "felis nigripes",
  "dog+1+feral": true
}
EOF
}

@test "[21] problematic arbitrary separator (asterisk)" {
    run jqg -j \* -r feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat*feral*0*species": "lion",
  "cat*feral*0*aka": "king of the beasts",
  "cat*feral*1*species": "Bengal tiger",
  "cat*feral*2*species": "black-footed cat",
  "cat*feral*2*aka": "felis nigripes",
  "dog*1*feral": true
}
EOF
}

@test "[21] problematic arbitrary separator (space)" {
    run jqg -j " " -r feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat feral 0 species": "lion",
  "cat feral 0 aka": "king of the beasts",
  "cat feral 1 species": "Bengal tiger",
  "cat feral 2 species": "black-footed cat",
  "cat feral 2 aka": "felis nigripes",
  "dog 1 feral": true
}
EOF
}
