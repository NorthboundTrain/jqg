#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/023-output-transformations.bats
#----------------------------------------------------------------------
#--- test output transformations
#----------------------------------------------------------------------
#   -t | --output
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# search mode: flatten
@test "search mode: flatten" {
    run jqg -s -t flatten domestic $carnivora_json
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

# search mode: unflatten
@test "search mode: unflatten" {
    run jqg -s -t unflatten domestic $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal",
        "color": ""
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  },
  "dog": [
    null,
    {
      "type": "domesticated"
    }
  ]
}
EOF
}

# search mode: unflatten (sorted)
@test "search mode: unflatten (sorted)" {
    run jqg -s -t unflatten -q -S domestic $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal",
        "color": "",
        "petname": "Fluffy"
      },
      {
        "breed": "domestic short hair",
        "color": "yellow",
        "petname": "Misty"
      }
    ]
  },
  "dog": [
    null,
    {
      "type": "domesticated"
    }
  ]
}
EOF
}

# search mode: none
@test "search mode: none" {
    run jqg -s -t none domestic $carnivora_json
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



# unflatten mode: flatten
@test "unflatten mode: flatten" {
    run bash -c "jqg domestic $carnivora_json | jqg -u -t flatten"
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.0": null,
  "dog.1.type": "domesticated"
}
EOF
}

# unflatten mode: unflatten
@test "unflatten mode: unflatten" {
    run bash -c "jqg domestic $carnivora_json | jqg -u -t unflatten"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal",
        "color": ""
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  },
  "dog": [
    null,
    {
      "type": "domesticated"
    }
  ]
}
EOF
}

# unflatten mode: unflatten (sorted)
@test "unflatten mode: unflatten (sorted)" {
    run bash -c "jqg domestic $carnivora_json | jqg -u -t unflatten -q -S"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal",
        "color": "",
        "petname": "Fluffy"
      },
      {
        "breed": "domestic short hair",
        "color": "yellow",
        "petname": "Misty"
      }
    ]
  },
  "dog": [
    null,
    {
      "type": "domesticated"
    }
  ]
}
EOF
}

# unflatten mode: none
@test "unflatten mode: none" {
    run bash -c "jqg domestic $carnivora_json | jqg -u -t none"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal",
        "color": ""
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  },
  "dog": [
    null,
    {
      "type": "domesticated"
    }
  ]
}
EOF
}



# extract mode: flatten
@test "extract mode: flatten" {
    run jqg -x -t flatten .cat $carnivora_json
    assert_success
    assert_output - <<EOF
{
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
  "cat.domesticated.1.color": "yellow"
}
EOF
}

# extract mode: flatten (sorted)
@test "extract mode: flatten (sorted)" {
    run jqg -x -t flatten -q -S .cat $carnivora_json
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
  "cat.isa": "feline"
}
EOF
}

# extract mode: flatten three -E
@test "extract mode: flatten (-E)" {
    run jqg -x -t flatten -E .three $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

# extract mode: unflatten <jqx>
@test "extract mode: unflatten <jqx>" {
    jqg_md5=$(jqg -x .cat $carnivora_json | md5sum)
    jqx_md5=$(jqx .cat -t unflatten $carnivora_json | md5sum)

    assert_equal "$jqx_md5" "$jqg_md5"
}

# extract mode: flatten <jqx>
@test "extract mode: flatten <jqx>" {
    jqx_md5=$(jqx .cat $carnivora_json | md5sum)
    noop_md5=$(jqx .cat -t flatten $carnivora_json | md5sum)

    assert_equal "$jqx_md5" "$noop_md5"
}

# extract mode: none <jqx>
@test "extract mode: none <jqx>" {
    jqx_md5=$(jqx .cat $carnivora_json | md5sum)
    noop_md5=$(jqx .cat -t none $carnivora_json | md5sum)

    assert_equal "$jqx_md5" "$noop_md5"
}
