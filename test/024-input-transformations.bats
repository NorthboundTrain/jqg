#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/024-input-transformations.bats
#----------------------------------------------------------------------
#--- test input transformations
#----------------------------------------------------------------------
#   -T | --input
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# search mode: flatten
@test "search mode: flatten" {
    run jqg -s -T flatten isa $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "cat.isa": "feline"
}
EOF
}

# search mode: unflatten
@test "search mode: unflatten" {
    run jqg -s -T unflatten isa $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "cat": {
    "isa": "feline",
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
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
  }
}
EOF
}

# search mode: none (structured input)
@test "search mode: none (structured)" {
    run bash -c "jq . $carnivora_json | jqg -s -T none isa"
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "cat": {
    "isa": "feline",
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
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
  }
}
EOF
}

# search mode: none (flat input)
@test "search mode: none (flat)" {
    run bash -c "jqg . $carnivora_json | jqg -s -T none isa"
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "cat.isa": "feline"
}
EOF
}

# search mode: extract (no composite_extract set)
@test "search mode: extract (no composite_extract set)" {
    run jqg -s -T extract breed $carnivora_json
    assert_failure # JQ exit code
}

# search mode: extract (with composite_extract set)
@test "search mode: extract (with composite_extract set)" {
    run jqg -X .cat -s -T extract breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair"
}
EOF
}



# unflatten mode: flatten
@test "unflatten mode: flatten" {
    run bash -c "jq .cat $carnivora_json | jqg -u -T flatten"
    assert_success
    assert_output - <<EOF
{
  "isa": "feline",
  "feral": [
    {
      "species": "lion",
      "aka": "king of the beasts"
    },
    {
      "species": "Bengal tiger"
    },
    {
      "species": "black-footed cat",
      "aka": "felis nigripes"
    }
  ],
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
}
EOF
}

# unflatten mode: unflatten
@test "unflatten mode: unflatten" {
    run bash -c "jq .cat $carnivora_json | jqg -u -T unflatten"
    assert_success
    assert_output - <<EOF
{
  "isa": "feline",
  "feral": [
    {
      "species": "lion",
      "aka": "king of the beasts"
    },
    {
      "species": "Bengal tiger"
    },
    {
      "species": "black-footed cat",
      "aka": "felis nigripes"
    }
  ],
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
}
EOF
}

# unflatten mode: none (structured)
@test "unflatten mode: none (structured)" {
    run bash -c "jq .cat $carnivora_json | jqg -u -T none"
    assert_success
    assert_output - <<EOF
{
  "isa": "feline",
  "feral": [
    {
      "species": "lion",
      "aka": "king of the beasts"
    },
    {
      "species": "Bengal tiger"
    },
    {
      "species": "black-footed cat",
      "aka": "felis nigripes"
    }
  ],
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
}
EOF
}

# unflatten mode: none (flat)
@test "unflatten mode: none (flat)" {
    run bash -c "jq .cat $carnivora_json | jqg . | jqg -u -T none"
    assert_success
    assert_output - <<EOF
{
  "isa": "feline",
  "feral": [
    {
      "species": "lion",
      "aka": "king of the beasts"
    },
    {
      "species": "Bengal tiger"
    },
    {
      "species": "black-footed cat",
      "aka": "felis nigripes"
    }
  ],
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
}
EOF
}



# extract mode: flatten
@test "extract mode: flatten" {
    run jqg -x -T flatten .cat $carnivora_json
    assert_success
    assert_output - <<EOF
null
EOF
}

# extract mode: flatten (fully qualified with dot)
@test "extract mode: flatten (fully qualified with dot)" {
    run jqg -x -T flatten .cat.isa $carnivora_json
    assert_success
    assert_output - <<EOF
null
EOF
}

# extract mode: flatten (fully qualified with ^)
@test "extract mode: flatten (fully qualified with ^)" {
    run jqg -x -j ^ -T flatten .'"cat^isa"' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat^isa": "feline"
}
EOF
}

# extract mode: unflatten
@test "extract mode: unflatten" {
    run bash -c "jqg . $carnivora_json | jqg -x -T unflatten .cat"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline",
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
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
  }
}
EOF
}

# extract mode: none (structured)
@test "extract mode: none (structured)" {
    run bash -c "jq . $carnivora_json | jqg -x -T none .cat"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline",
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
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
  }
}
EOF
}

# extract mode: none (flat)
@test "extract mode: none (flat)" {
    run bash -c "jqg . $carnivora_json | jqg -x -T none .cat"
    assert_success
    assert_output - <<EOF
null
EOF
}
