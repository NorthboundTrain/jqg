#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/050-extract-simple.bats
#----------------------------------------------------------------------
#--- test extract mode - simple cases
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# extract . & test success
@test "extract . success" {
    run jqg -x . $carnivora_json
    assert_success
}

simple_extract()
{
    local filename=$1; shift
    local jq_md5=$1; shift

    local extract_md5=$(jqg -x $filename | md5sum | cut -d " " -f 1)

    assert_equal "$extract_md5" "$jq_md5"
}

@test "extract . vs. jq . (carnivora)" {
    simple_extract "$carnivora_json" "$carnivora_md5"
}

@test "extract . vs. jq . (citrus)" {
    simple_extract "$citrus_json" "$citrus_md5"
}

@test "extract . vs. jq . (odd-values)" {
    simple_extract "$odd_values_json" "$odd_values_md5"
}

@test "extract . vs. jq . (lorem array)" {
    simple_extract "$lorem_array_json" "$lorem_array_md5"
}

@test "extract . vs. jq . (lorem object)" {
    simple_extract "$lorem_object_json" "$lorem_object_md5"
}

@test "extract . vs. jq . (lorem mixed array)" {
    simple_extract "$lorem_mixed_array_json" "$lorem_mixed_array_md5"
}

@test "extract . vs. jq . (lorem mixed object)" {
    simple_extract "$lorem_mixed_object_json" "$lorem_mixed_object_md5"
}

@test "extract . vs. jq . (large structure #1)" {
    simple_extract "$large_structure1_json" "$large_structure1_md5"
}

@test "extract . vs. jq . (large structure #2)" {
    simple_extract "$large_structure2_json" "$large_structure2_md5"
}

@test "extract . vs. jq . (large structure #3)" {
    simple_extract "$large_structure3_json" "$large_structure3_md5"
}

@test "extract . vs. jq . (large structure #4)" {
    simple_extract "$large_structure4_json" "$large_structure4_md5"
}



# extract simple (object)
@test "extract simple (object)" {
    run jqg -x .sit $lorem_object_json
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

# extract simple (object)
@test "extract simple (object) <long>" {
    run jqg --extract .sit $lorem_object_json
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

# extract simple (sub-object)
@test "extract simple (sub-object)" {
    run jqg -x .sit.impedit $lorem_object_json
    assert_success
    assert_output - <<EOF
{
  "sit": {
    "impedit": {
      "ludus": 72,
      "quaestio": "graecis",
      "mus": 132.473,
      "accusamus": "lacus",
      "ex": "disputando",
      "cubilia": -17.56
    }
  }
}
EOF
}

# extract simple (array)
@test "extract simple (array)" {
    run jqg -x .[0] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  [
    "maximus facilisi omnis",
    545,
    [
      "elit malesuada",
      134,
      678,
      false,
      true,
      -476
    ]
  ]
]
EOF
}

# extract simple (sparse array)
@test "extract simple (sparse array)" {
    run jqg -x .[1] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  null,
  [
    "facilis brute",
    393.136,
    [
      "debet",
      "habitant viverra quam",
      "tacimates aenean adipisci",
      -80,
      "adipisci",
      -262.063
    ]
  ]
]
EOF
}

# extract simple (sub-array)
@test "extract simple (sub-array)" {
    run jqg -x .[0][0] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  [
    "maximus facilisi omnis"
  ]
]
EOF
}

# extract simple (sub-array)
@test "extract simple (sub-sparse array)" {
    run jqg -x .[0][1] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  [
    null,
    545
  ]
]
EOF
}

# extract simple (sparse sub-array)
@test "extract simple (sparse sub-array)" {
    run jqg -x .[1][0] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  null,
  [
    "facilis brute"
  ]
]
EOF
}

# extract simple (sparse sub-sparse array)
@test "extract simple (sparse sub-sparse array)" {
    run jqg -x .[1][1] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  null,
  [
    null,
    393.136
  ]
]
EOF
}

# extract simple (multi-value sparse sub-sparse array)
@test "extract simple (multi-value sparse sub-sparse array)" {
    run jqg -x .[1][2] $lorem_array_json
    assert_success
    assert_output - <<EOF
[
  null,
  [
    null,
    null,
    [
      "debet",
      "habitant viverra quam",
      "tacimates aenean adipisci",
      -80,
      "adipisci",
      -262.063
    ]
  ]
]
EOF
}

# extract simple (mixed object)
@test "extract simple (mixed object)" {
    run jqg -x .homero $lorem_mixed_object_json
    assert_success
    assert_output - <<EOF
{
  "homero": [
    "neglegentur",
    "vehicula",
    "porro",
    {
      "cotidieque": true,
      "ante": "libris mattis torquatos tale",
      "iusto": "senectus clita"
    }
  ]
}
EOF
}

# extract simple (mixed sparse object)
@test "extract simple (mixed sparse object)" {
    run jqg -x .homero[3] $lorem_mixed_object_json
    assert_success
    assert_output - <<EOF
{
  "homero": [
    null,
    null,
    null,
    {
      "cotidieque": true,
      "ante": "libris mattis torquatos tale",
      "iusto": "senectus clita"
    }
  ]
}
EOF
}

# extract simple (mixed array)
@test "extract simple (mixed array)" {
    run jqg -x .[0] $lorem_mixed_array_json
    assert_success
    assert_output - <<EOF
[
  {
    "possit": -211,
    "placerat": -34,
    "eam": "nostrud",
    "persequeris": false
  }
]
EOF
}

# extract simple (mixed sparse array)
@test "extract simple (mixed sparse array)" {
    run jqg -x .[3][1].idque $lorem_mixed_array_json
    assert_success
    assert_output - <<EOF
[
  null,
  null,
  null,
  [
    null,
    {
      "idque": "assueverit"
    }
  ]
]
EOF
}



# some pipelines
@test "extract simple via pipeline" {
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

@test "extract sub-object via pipeline" {
    run bash -c "jq . $lorem_object_json | jqg --extract .sit.impedit"
    assert_success
    assert_output - <<EOF
{
  "sit": {
    "impedit": {
      "ludus": 72,
      "quaestio": "graecis",
      "mus": 132.473,
      "accusamus": "lacus",
      "ex": "disputando",
      "cubilia": -17.56
    }
  }
}
EOF
}

@test "extract array via pipeline" {
    run bash -c "jq . $lorem_array_json | jqg -x .[0]"
    assert_success
    assert_output - <<EOF
[
  [
    "maximus facilisi omnis",
    545,
    [
      "elit malesuada",
      134,
      678,
      false,
      true,
      -476
    ]
  ]
]
EOF
}

@test "extract sub-array via pipeline" {
    run bash -c "jq . $lorem_array_json | jqg -x .[0][0]"
    assert_success
    assert_output - <<EOF
[
  [
    "maximus facilisi omnis"
  ]
]
EOF
}
