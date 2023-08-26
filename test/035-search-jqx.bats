#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/035-search-jqx.bats
#----------------------------------------------------------------------
#--- test the extract composite search mode
#----------------------------------------------------------------------
#   jqg -X / composite_extract
#   jqx
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# composite / extract - simple/basic
@test "composite / extract - simple pre-extraction" {
    run jqg breed -X .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - simple/basic (long)
@test "composite / extract - simple pre-extraction (long)" {
    run jqg breed --composite_extract .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - simple/basic <jqx>
@test "composite / extract - simple pre-extraction <jqx>" {
    run jqx .dog breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - simple/basic pipeline
@test "composite / extract - simple pre-extraction pipeline" {
    run bash -c "jq . $carnivora_json | jqg breed -X .dog"
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - simple/basic pipeline <jqx>
@test "composite / extract - simple pre-extraction pipeline <jqx>" {
    run bash -c "jq . $carnivora_json | jqx .dog breed"
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - default search
@test "composite / extract - simple pre-extraction default search" {
    run jqg -X .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
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

# composite / extract - simple/basic default search <jqx>
@test "composite / extract - simple pre-extraction default search <jqx>" {
    run jqx .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
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



# composite / extract - simple/basic with options: -k
@test "composite / extract - simple pre-extraction with options: -k" {
    run jqg que -k -X .[3] $lorem_mixed_array_json
    assert_success
    assert_output - <<EOF
{
  "3.1.idque": "assueverit"
}
EOF
}

# composite / extract - simple/basic with options: -k <jqx>
@test "composite / extract - simple pre-extraction with options: -k <jqx>" {
    run jqx .[3] que -k $lorem_mixed_array_json
    assert_success
    assert_output - <<EOF
{
  "3.1.idque": "assueverit"
}
EOF
}

# composite / extract - simple/basic with options: -v
@test "composite / extract - simple pre-extraction with options: -v" {
    run jqg que -v -X .[3] $lorem_mixed_array_json
    assert_success
    assert_output - <<EOF
{
  "3.1.torquatos": "scelerisque quaeque harum"
}
EOF
}

# composite / extract - simple/basic with options: -K
@test "composite / extract - simple pre-extraction with options: -K" {
    run jqg que -K -X .[3] $lorem_mixed_array_json
    assert_success
    assert_output - <<EOF
[
  "3.1.torquatos",
  "3.1.idque"
]
EOF
}

# composite / extract - simple/basic with options: -q -S
@test "composite / extract - simple pre-extraction with options: -q -S" {
    run jqg domestic -q -S -X .cat $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}

# composite / extract - simple/basic with options: -q -S <jqx>
@test "composite / extract - simple pre-extraction with options: -q -S <jqx>" {
    run jqx .cat domestic -q -S $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}



# composite / extract - no extract criteria
@test "composite / extract - no extract criteria" {
    run jqg -X breed $carnivora_json
    assert_failure # JQ exit code
}

# composite / extract - no extract criteria <jqx>
@test "composite / extract - no extract criteria <jqx>" {
    run jqx breed $carnivora_json
    assert_failure # JQ exit code
}

# composite / extract - no extract or search criteria
@test "composite / extract - no extract or search criteria" {
    run bash -c "jq . $carnivora_json | jqg -X"
    assert_failure 2
}

# composite / extract - no extract or search criteria <jqx>
@test "composite / extract - no extract or search criteria <jqx>" {
    run bash -c "jq . $carnivora_json | jqx"
    assert_success
    assert_output --partial usage
    assert_output --partial CRITERIA
    assert_output --partial --bug
}

# composite / extract - JQG arg as extract criteria <jqx>
@test "composite / extract - JQG arg as extract criteria <jqx>" {
    run jqx -q -S breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - JQG arg as extract criteria <jqx>
@test "composite / extract - JQG arg as extract criteria with selector <jqx>" {
    run jqx -k .dog breed $carnivora_json
    assert_failure # JQ exit code
    assert_output --partial "No such file or directory"
}



# composite / extract - override - jqg -s -X
@test "composite / extract - override -s with -X" {
    run jqg -s breed -X .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - override - jqg -u -X
@test "composite / extract - override -u with -X" {
    run jqg -u -X .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
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

# composite / extract - override - jqg -x -X
@test "composite / extract - override -x with -X" {
    run jqg -x -X .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
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

# composite / extract - override - jqg -X with -s
@test "composite / extract - override -X with -s" {
    run jqg -X .dog breed -s $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - override - jqg -X with -s <jqx>
@test "composite / extract - override -X with -s <jqx>" {
    run jqx .dog -s breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - override - jqg -X with -u
@test "composite / extract - override -X with -u" {
    run bash -c "jqg breed $carnivora_json | jqg -X .cat -u"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF
}

# composite / extract - override - jqg -X with -u <jqx>
@test "composite / extract - override -X with -u <jqx>" {
    run bash -c "jqg breed $carnivora_json | jqx .cat -u"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF
}

# composite / extract - override - jqg -X with -x
@test "composite / extract - override -X with -x" {
    run jqg -X .dog -x .cat.isa $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline"
  }
}
EOF
}

# composite / extract - override - jqg -X with -x <jqx>
@test "composite / extract - override -X with -x <jqx>" {
    run jqx .dog -x .cat.isa $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline"
  }
}
EOF
}

# composite / extract - flat input
@test "composite / extract - flat input" {
    run bash -c "jqg . $carnivora_json | jqg -X .dog breed"
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

# composite / extract - flat input <jqx>
@test "composite / extract - flat input <jqx>" {
    run bash -c "jqg . $carnivora_json | jqx .dog breed"
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}
