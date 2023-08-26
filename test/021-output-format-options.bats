#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/021-output-format-options.bats
#----------------------------------------------------------------------
#--- test the output format options
#----------------------------------------------------------------------
#   -j / --join
#   -J / --join_colon
#
#   -r / --raw
#   -R / --json (default)
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# output with defaults
@test "default output (object)" {
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

@test "default output (array)" {
    run jqg -K feral $carnivora_json
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

@test "default output (array w/ boolean)" {
    run jqg -V feral $carnivora_json
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

@test "default output (one-element array)" {
    run jqg -V feline $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "feline"
]
EOF
}

@test "default output (empty)" {
    run jqg ursa $carnivora_json
    assert_success
    assert_output "{}"
}



# output everthing
@test "non-raw output (object)" {
    run jqg -R feral $carnivora_json
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

@test "non-raw output (array)" {
    run jqg -R -K feral $carnivora_json
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

@test "non-raw output (array) <long>" {
    run jqg --json -K feral $carnivora_json
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

@test "non-raw output (array w/ boolean)" {
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

@test "non-raw output (one-element array)" {
    run jqg -R -V feline $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "feline"
]
EOF
}

@test "non-raw output (empty)" {
    run jqg -R ursa $carnivora_json
    assert_success
    assert_output "{}"
}



# raw output
@test "raw output (object)" {
    run jqg -r feral $carnivora_json
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

@test "raw output (array)" {
    run jqg -r -K feral $carnivora_json
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

@test "raw output (array) <long>" {
    run jqg --raw -K feral $carnivora_json
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

@test "raw output (array w/ boolean)" {
    run jqg -r -V feral $carnivora_json
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

@test "raw output (one-element array)" {
    run jqg -r -V feline $carnivora_json
    assert_success
    assert_output "feline"
}

@test "raw output (empty)" {
    run jqg -r ursa $carnivora_json
    assert_success
    assert_output "{}"
}



# flattened item separator
@test "default separator" {
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

@test "dot separator" {
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

@test "arbitrary separator" {
    run jqg -j + feral $carnivora_json
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

@test "arbitrary separator <long>" {
    run jqg --join + feral $carnivora_json
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

@test "default alternate separator" {
    run jqg -J feral $carnivora_json
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

@test "default alternate separator <long>" {
    run jqg --join_alt feral $carnivora_json
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

@test "colon separator [deprecated]]" {
    bats_require_minimum_version 1.5.0 # silences BW02
    run --separate-stderr jqg --join_colon feral $carnivora_json
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

@test "ignored alternate separator <long>" {
    run jqg --join_char + feral $carnivora_json
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

@test "alternate separator" {
    run jqg --join_char + -J feral $carnivora_json
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

@test "alternate separator <long>" {
    run jqg --join_char + --join_alt feral $carnivora_json
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

@test "useless alternate separator" {
    run jqg -J --join_char + feral $carnivora_json
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

@test "useless alternate separator <long>" {
    run jqg --join_alt --join_char + feral $carnivora_json
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

@test "problematic arbitrary separator (asterisk)" {
    run jqg -j \* feral $carnivora_json
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

@test "problematic arbitrary separator (space)" {
    run jqg -j " " feral $carnivora_json
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

@test "problematic arbitrary separator (dash)" {
    run jqg -j - feral $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat-feral-0-species": "lion",
  "cat-feral-0-aka": "king of the beasts",
  "cat-feral-1-species": "Bengal tiger",
  "cat-feral-2-species": "black-footed cat",
  "cat-feral-2-aka": "felis nigripes",
  "dog-1-feral": true
}
EOF
}



@test "join string - %%" {
    run jqg -j %% $lorem_mixed_object_json
    assert_success
    assert_output - <<EOF
{
  "democritum": -442,
  "homero%%0": "neglegentur",
  "homero%%1": "vehicula",
  "homero%%2": "porro",
  "homero%%3%%cotidieque": true,
  "homero%%3%%ante": "libris mattis torquatos tale",
  "homero%%3%%iusto": "senectus clita",
  "epicuri": 393
}
EOF
}

@test "join string round trip - %%" {
    run bash -c "jqg -j %% $lorem_mixed_object_json | jqg -u -j %%"
    assert_success
    assert_output - <<EOF
{
  "democritum": -442,
  "homero": [
    "neglegentur",
    "vehicula",
    "porro",
    {
      "cotidieque": true,
      "ante": "libris mattis torquatos tale",
      "iusto": "senectus clita"
    }
  ],
  "epicuri": 393
}
EOF
}

@test "join string - FOO" {
    run jqg -j FOO $lorem_mixed_object_json
    assert_success
    assert_output - <<EOF
{
  "democritum": -442,
  "homeroFOO0": "neglegentur",
  "homeroFOO1": "vehicula",
  "homeroFOO2": "porro",
  "homeroFOO3FOOcotidieque": true,
  "homeroFOO3FOOante": "libris mattis torquatos tale",
  "homeroFOO3FOOiusto": "senectus clita",
  "epicuri": 393
}
EOF
}

@test "join string round trip - FOO" {
    run bash -c "jqg -j FOO $lorem_mixed_object_json | jqg -u -j FOO"
    assert_success
    assert_output - <<EOF
{
  "democritum": -442,
  "homero": [
    "neglegentur",
    "vehicula",
    "porro",
    {
      "cotidieque": true,
      "ante": "libris mattis torquatos tale",
      "iusto": "senectus clita"
    }
  ],
  "epicuri": 393
}
EOF
}

@test "join string - ero" {
    run jqg -j ero $lorem_mixed_object_json
    assert_success
    assert_output - <<EOF
{
  "democritum": -442,
  "homeroero0": "neglegentur",
  "homeroero1": "vehicula",
  "homeroero2": "porro",
  "homeroero3erocotidieque": true,
  "homeroero3eroante": "libris mattis torquatos tale",
  "homeroero3eroiusto": "senectus clita",
  "epicuri": 393
}
EOF
}

@test "join string round trip - ero" {
    run bash -c "jqg -j ero $lorem_mixed_object_json | jqg -u -j ero"
    assert_success
    assert_output - <<EOF
{
  "democritum": -442,
  "hom": {
    "": [
      "neglegentur",
      "vehicula",
      "porro",
      {
        "cotidieque": true,
        "ante": "libris mattis torquatos tale",
        "iusto": "senectus clita"
      }
    ]
  },
  "epicuri": 393
}
EOF
}
