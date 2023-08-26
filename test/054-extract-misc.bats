#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/054-extract-misc.bats
#----------------------------------------------------------------------
#--- test extract mode - misc tests
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file "53"; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }


# extract sub-match (not top-level)
@test "extract sub-match" {
    run jqg -x .hybrid.lemon.ancestors $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lemon": {
      "ancestors": [
        "citron",
        "sour orange"
      ]
    }
  }
}
EOF

    run jqg -x .ancestors $citrus_json
    assert_success
    assert_output "null"
}


# structured JSON vs flat JSON as input
@test "extract simple (structured)" {
    run bash -c "jq . $lorem_object_json | jqg -x .sit"
    assert_success
    assert_output - <<EOF
{
  "sit": {
    "theophrastus": "sumo fuisset",
    "impedit": {
      "ludus": 72,
      "quaestio": "graecis",
      "mus": 132.473,
      "accusamus": "lacus",
      "ex": "disputando",
      "cubilia": -17.56
    },
    "suspendisse": 934,
    "pri": "sea"
  }
}
EOF
}

@test "extract simple (flat)" {
    run bash -c "jqg . $lorem_object_json | jqg -x .sit"
    assert_success
    assert_output - <<EOF
{
  "sit": {
    "theophrastus": "sumo fuisset",
    "impedit": {
      "ludus": 72,
      "quaestio": "graecis",
      "mus": 132.473,
      "accusamus": "lacus",
      "ex": "disputando",
      "cubilia": -17.56
    },
    "suspendisse": 934,
    "pri": "sea"
  }
}
EOF
}

@test "extract simple (flat w/ colons)" {
    run bash -c "jqg -J . $lorem_object_json | jqg -x -J .sit"
    assert_success
    assert_output - <<EOF
{
  "sit": {
    "theophrastus": "sumo fuisset",
    "impedit": {
      "ludus": 72,
      "quaestio": "graecis",
      "mus": 132.473,
      "accusamus": "lacus",
      "ex": "disputando",
      "cubilia": -17.56
    },
    "suspendisse": 934,
    "pri": "sea"
  }
}
EOF
}

# output filters - keys
@test "output filters (keys)" {
    run jqg -x .cat -K $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "cat"
]
EOF
}

# output filters - values
@test "output filters (values)" {
    run jqg -x .cat -V $carnivora_json
    assert_success
    assert_output - <<EOF
[
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
]
EOF
}


# output filters - values & -r
@test "output filters (raw values)" {
    jq_md5=$(jq .cat $carnivora_json | md5sum)
    extract_md5=$(jqg -x -r -V .cat $carnivora_json | md5sum)

    assert_equal "$extract_md5" "$jq_md5"
}



# single result extraction
@test "single result extraction" {
    run jqg -x .cat.isa $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline"
  }
}
EOF
}




# extraction with nonexistent selector (object)
@test "extraction with nonexistent selector (object)" {
    run jqg -x .foobar.qwqeqw $lorem_object_json
    assert_success
    assert_output - <<EOF
null
EOF
}

# extraction with nonexistent selector (array)
@test "extraction with nonexistent selector (array)" {
    run jqg -x .[999] $lorem_array_json
    assert_success
    assert_output - <<EOF
null
EOF
}



# mismatched selector type (object)
@test "mismatched selector type (object)" {
    run jqg -x .[4] $lorem_object_json
    assert_failure # JQ exit code
}

# mismatched selector type (array)
@test "mismatched selector type (array)" {
    run jqg -x .doggo $lorem_array_json
    assert_failure # JQ exit code
}
