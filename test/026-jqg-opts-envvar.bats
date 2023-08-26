#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/026-jqg-opts-envvar.bats
#----------------------------------------------------------------------
#--- test $JQG_OPTS
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# mode selection: -s
@test "JQG_OPTS : mode selection: -s" {
    export JQG_OPTS="-s"
    run jqg rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# mode selection: -u
@test "JQG_OPTS : mode selection: -u" {
    make_temp_dir

    local flattened_json="$jqg_tmpdir/flattened.json"
    jqg orange $citrus_json >"$flattened_json"

    export JQG_OPTS="-u"
    run jqg $flattened_json
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "orange": {
      "ancestors": [
        "mandarin",
        "pomelo"
      ],
      "sub-categories": [
        "sweet orange",
        "bitter orange"
      ],
      "is sweet": true
    },
    "lemon": {
      "ancestors": [
        null,
        "sour orange"
      ],
      "related": {
        "Meyer lemon": {
          "ancestors": [
            null,
            "sweet orange"
          ]
        }
      }
    }
  }
}
EOF
    remove_temp_dir
}

# mode selection: -x
@test "JQG_OPTS : mode selection: -x" {
    export JQG_OPTS="-x"
    run jqg .core $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core": [
    "citron",
    "mandarin",
    "pomelo",
    "pompeda",
    "kumquat"
  ]
}
EOF
}

# mode selection: -U
@test "JQG_OPTS : mode selection: -U" {
    export JQG_OPTS="-U"
    run jqg rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# mode selection: -X
@test "JQG_OPTS : mode selection: -X" {
    export JQG_OPTS="-X"
    run jqg .hybrid.lemon rang $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lemon.ancestors.1": "sour orange",
  "hybrid.lemon.related.Meyer lemon.ancestors.1": "sweet orange"
}
EOF
}

# mode selection override: -u -> -s
@test "JQG_OPTS : mode selection override: -s" {
    export JQG_OPTS="-u"
    run jqg -s rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# pipeline mode selection: -s
@test "JQG_OPTS : pipeline mode selection: -s" {
    export JQG_OPTS="-s"
    run bash -c "jq . $citrus_json | jqg rangpur"
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# pipeline mode selection: -u
@test "JQG_OPTS : pipeline mode selection: -u" {
    export JQG_OPTS="-u"
    run bash -c "jqg -s rangpur $citrus_json | jqg"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# pipeline mode selection: -x
@test "JQG_OPTS : pipeline mode selection: -x" {
    export JQG_OPTS="-x"
    run bash -c "jq . $citrus_json | jqg .core"
    assert_success
    assert_output - <<EOF
{
  "core": [
    "citron",
    "mandarin",
    "pomelo",
    "pompeda",
    "kumquat"
  ]
}
EOF
}

# -I / -i override
@test "JQG_OPTS : case sensitive (Upper)" {
    export JQG_OPTS="-I"
    run jqg Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}

@test "JQG_OPTS : case insensitive override (Upper)" {
    export JQG_OPTS="-I"
    run jqg -i Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}



# -v / -a override
@test "JQG_OPTS: search values" {
    export JQG_OPTS="-v"
    run jqg domestic $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
EOF
}

@test "JQG_OPTS: search both (override)" {
    export JQG_OPTS="-v"
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



# -K / -A override
@test "JQG_OPTS: output keys (mixed - hanging array)" {
    export JQG_OPTS="-K"
    run jqg feli $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "subclades.0",
  "cat.isa",
  "cat.feral.2.aka"
]
EOF
}

@test "JQG_OPTS: output all override (mixed - hanging array)" {
    export JQG_OPTS="-K"
    run jqg -A feli $carnivora_json
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
@test "JQG_OPTS: colon separator (object)" {
    export JQG_OPTS="-J"
    run jqg feral $carnivora_json
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

@test "JQG_OPTS: dot separator override 1 (object)" {
    export JQG_OPTS="-J"
    run jqg -j . feral $carnivora_json
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
@test "JQG_OPTS: plus sign separator (object)" {
    export JQG_OPTS="-j +"
    run jqg feral $carnivora_json
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

@test "JQG_OPTS: equals separator (object) <long>" {
    export JQG_OPTS="--join +"
    run jqg feral $carnivora_json
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

@test "JQG_OPTS: dot separator override 2 (object)" {
    export JQG_OPTS="-j +"
    run jqg -j . feral $carnivora_json
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

@test "JQG_OPTS: dot separator override 2 (object) <long>/<short>" {
    export JQG_OPTS="--join +"
    run jqg -j . feral $carnivora_json
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

@test "JQG_OPTS: dot separator override 2 (object) <short>/<long>" {
    export JQG_OPTS="-j +"
    run jqg --join . feral $carnivora_json
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

@test "JQG_OPTS: dot separator override 2 (object) <long>/<long>" {
    export JQG_OPTS="--join +"
    run jqg --join . feral $carnivora_json
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
@test "JQG_OPTS: problematic separator (asterisk)" {
    export JQG_OPTS='-j *'
    run jqg feral $carnivora_json
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



# -E / -e override
@test "JQG_OPTS: exclude empty JSON" {
    export JQG_OPTS="-E"
    run jqg empty $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

@test "JQG_OPTS: include empty JSON override" {
    export JQG_OPTS="-E"
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

@test "JQG_OPTS: include empty JSON override <long>" {
    export JQG_OPTS="-E"
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



# -r / -R override
@test "JQG_OPTS: raw output (array w/ boolean)" {
    export JQG_OPTS="-r"
    run jqg -V feral $carnivora_json
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

@test "JQG_OPTS: non-raw output override (array w/ boolean)" {
    export JQG_OPTS="-r"
    run jqg -R -V feral $carnivora_json
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
@test "JQG_OPTS: sort & compact options (-S -c)" {
    export JQG_OPTS="-q -S -q -c"
    run jqg mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "JQG_OPTS: sort & compact options (-S -c) <long>" {
    export JQG_OPTS="--jqopt -S --jqopt -c"
    run jqg mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "JQG_OPTS: clear pass-through opts override" {
    export JQG_OPTS="-q -S -q -c"
    run jqg -Q mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "JQG_OPTS: clear pass-through opts and add new ones" {
    export JQG_OPTS="-q -S"
    run jqg -Q -q -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}



@test "JQG_OPTS: require_results (-n)" {
    export JQG_OPTS="-n"
    run jqg doggo $carnivora_json
    assert_success
    assert_output "{}"
}

@test "JQG_OPTS: require_results (-n  ->  -N)" {
    export JQG_OPTS="nm"
    run jqg -N doggo $carnivora_json
    assert_failure 1
}

@test "JQG_OPTS: require_results (-N)" {
    export JQG_OPTS="-N"
    run jqg doggo $carnivora_json
    assert_failure 1
}

@test "JQG_OPTS: require_results (-N  ->  -n)" {
    export JQG_OPTS="-N"
    run jqg -n doggo $carnivora_json
    assert_success
    assert_output "{}"
}



@test "JQG_OPTS: set alternate join separator, use default join separator" {
    export JQG_OPTS="--join_char +"
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

@test "JQG_OPTS: set alternate join separator, use alternate join separator" {
    export JQG_OPTS="--join_char +"
    run jqg -J feral $carnivora_json
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

@test "JQG_OPTS: set alternate join separator, override on cmd line" {
    export JQG_OPTS="--join_char +"
    run jqg --join_char ^ -J feral $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat^feral^0^species": "lion",
  "cat^feral^0^aka": "king of the beasts",
  "cat^feral^1^species": "Bengal tiger",
  "cat^feral^2^species": "black-footed cat",
  "cat^feral^2^aka": "felis nigripes",
  "dog^1^feral": true
}
EOF
}
