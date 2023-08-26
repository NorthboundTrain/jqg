#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/051-extract-multi-selectors.bats
#----------------------------------------------------------------------
#--- test extract mode - multiple selectors
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# composite extraction
@test "composite extraction" {
    run jqg -x .cat,.dog $carnivora_json
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
  },
  "dog": [
    {
      "petname": "Growler",
      "breed": "mutt"
    },
    {
      "petname": "Tiger",
      "breed": "yellow labrador",
      "feral": true,
      "type": "domesticated"
    },
    {}
  ]
}
EOF
}

# composite extraction
@test "composite extraction (reversed)" {
    run jqg -x .dog,.cat $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog": [
    {
      "petname": "Growler",
      "breed": "mutt"
    },
    {
      "petname": "Tiger",
      "breed": "yellow labrador",
      "feral": true,
      "type": "domesticated"
    },
    {}
  ],
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

# composite extraction
@test "composite extraction (reversed & sorted)" {
    run jqg -q -S -x .dog,.cat $carnivora_json
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
    ],
    "feral": [
      {
        "aka": "king of the beasts",
        "species": "lion"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "aka": "felis nigripes",
        "species": "black-footed cat"
      }
    ],
    "isa": "feline"
  },
  "dog": [
    {
      "breed": "mutt",
      "petname": "Growler"
    },
    {
      "breed": "yellow labrador",
      "feral": true,
      "petname": "Tiger",
      "type": "domesticated"
    },
    {}
  ]
}
EOF
}

# composite extraction (mixed)
@test "composite extraction (mixed)" {
    run jqg -x .cat.feral[1],.cat.domesticated,.dog[2]  $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "feral": [
      null,
      {
        "species": "Bengal tiger"
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
  },
  "dog": [
    null,
    null,
    {}
  ]
}
EOF
}

# overlapping selectors
@test "overlapping selectors" {
    run jqg -x '.cat,.cat.feral' $carnivora_json
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

# overlapping selectors (reversed)
@test "overlapping selectors (reversed)" {
    run jqg -x '.cat.feral,.cat' $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
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
    "isa": "feline",
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
