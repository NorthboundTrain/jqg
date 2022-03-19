# test out JQG_OPTS


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



# -I / -i override
@test "[31] JQG_OPTS : case sensitive (Upper)" {
    export JQG_OPTS="-I"
    run jqg Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}

@test "[31] JQG_OPTS : case insensitive override (Upper)" {
    export JQG_OPTS="-I"
    run jqg -i Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}



# -v / -a override
@test "[31] JQG_OPTS: search values" {
    export JQG_OPTS="-v"
    run jqg domestic $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
EOF
}

@test "[31] JQG_OPTS: search both (override)" {
    export JQG_OPTS="-v"
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



# -K / -A override
@test "[31] JQG_OPTS: output keys (mixed - hanging array)" {
    export JQG_OPTS="-K"
    run jqg feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "subclades.0",
  "cat.isa",
  "cat.feral.2.aka"
]
EOF
}

@test "[31] JQG_OPTS: output all override (mixed - hanging array)" {
    export JQG_OPTS="-K"
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



# -J / -j . override
@test "[31] JQG_OPTS: colon separator (object)" {
    export JQG_OPTS="-J"
    run jqg feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: dot separator override 1 (object)" {
    export JQG_OPTS="-J"
    run jqg -j . feral $CARNIVORA_JSON
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



# -j + / -j . override
@test "[31] JQG_OPTS: plus sign separator (object)" {
    export JQG_OPTS="-j +"
    run jqg feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: equals separator (object) <long>" {
    export JQG_OPTS="--join +"
    run jqg feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: dot separator override 2 (object)" {
    export JQG_OPTS="-j +"
    run jqg -j . feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: dot separator override 2 (object) <long>/<short>" {
    export JQG_OPTS="--join +"
    run jqg -j . feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: dot separator override 2 (object) <short>/<long>" {
    export JQG_OPTS="-j +"
    run jqg --join . feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: dot separator override 2 (object) <long>/<long>" {
    export JQG_OPTS="--join +"
    run jqg --join . feral $CARNIVORA_JSON
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

# -j *
@test "[31] JQG_OPTS: problematic separator (asterisk)" {
    export JQG_OPTS='-j *'
    run jqg feral $CARNIVORA_JSON
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


#        -e | --include_empty ) empty_tests=$def_empty_tests; shift ;;
#        -E | --exclude_empty ) empty_tests=; shift ;;


# -E / -e override
@test "[31] JQG_OPTS: exclude empty JSON" {
    export JQG_OPTS="-E"
    run jqg empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

@test "[31] JQG_OPTS: include empty JSON override" {
    export JQG_OPTS="-E"
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

@test "[31] JQG_OPTS: include empty JSON override <long>" {
    export JQG_OPTS="-E"
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



#        -r | --raw ) jqraw='-r'; strip_array='|.[]'; shift ;;
#        -R | --json ) jqraw=; strip_array=; shift ;;

# -r / -R override
@test "[31] JQG_OPTS: raw output (array w/ boolean)" {
    export JQG_OPTS="-r"
    run jqg -V feral $CARNIVORA_JSON
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

@test "[31] JQG_OPTS: non-raw output override (array w/ boolean)" {
    export JQG_OPTS="-r"
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



# -q -S -q -c
@test "[31] JQG_OPTS: sort & compact options (-S -c)" {
    export JQG_OPTS="-q -S -q -c"
    run jqg mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "[31] JQG_OPTS: sort & compact options (-S -c) <long>" {
    export JQG_OPTS="--jqopt -S --jqopt -c"
    run jqg mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "[31] JQG_OPTS: clear pass-through opts override" {
    export JQG_OPTS="-q -S -q -c"
    run jqg -Q mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}
