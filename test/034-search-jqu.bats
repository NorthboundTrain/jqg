#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/034-search-jqu.bats
#----------------------------------------------------------------------
#--- test the unflatten composite search mode
#----------------------------------------------------------------------
#   jqg -U / composite_unflatten
#   jqu
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# composite / unflatten - simple/basic
@test "composite / unflatten - simple post-unflatten" {
    run jqg breed -U $carnivora_json
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

# composite / unflatten - simple/basic (long)
@test "composite / unflatten - simple post-unflatten (long)" {
    run jqg breed --composite_unflatten $carnivora_json
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

# composite / unflatten - simple/basic <jqu>
@test "composite / unflatten - simple post-unflatten <jqu>" {
    run jqu breed $carnivora_json
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

# composite / unflatten - simple/basic | pipeline
@test "composite / unflatten - simple post-unflatten via pipeline" {
    run bash -c "jq . $carnivora_json | jqg breed -U"
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

# composite / unflatten - simple/basic | pipeline <jqu>
@test "composite / unflatten - simple post-unflatten via pipeline <jqu>" {
    run bash -c "jq . $carnivora_json | jqu breed"
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

# composite / unflatten - simple/basic via $JQG_OPTS
@test "composite / unflatten - simple/basic via \$JQG_OPTS" {
    export JQG_OPTS="-U"
    run jqg breed $carnivora_json
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



# composite / unflatten - default search
@test "composite / unflatten - default search" {
    run jqg -U $lorem_mixed_object_json
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

# composite / unflatten - simple/basic default search <jqu>
@test "composite / unflatten - default search <jqu>" {
    run jqu $lorem_mixed_object_json
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

# composite / unflatten - simple/basic with options: -k
@test "composite / unflatten - with options: -k" {
    run jqg -U -k domestic $carnivora_json
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
  }
}
EOF
}

# composite / unflatten - simple/basic with options: -k <jqu>
@test "composite / unflatten - with options: -k <jqu>" {
    run jqu -k domestic $carnivora_json
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
  }
}
EOF
}

# composite / unflatten - simple/basic with options: -v
@test "composite / unflatten - with options: -v" {
    run jqg -U -v domestic $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      null,
      {
        "breed": "domestic short hair"
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

# composite / unflatten - simple/basic with options: -K
@test "composite / unflatten - with options: -K" {
    run jqg -U -K domestic $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "cat",
  "dog"
]
EOF
}

# composite / unflatten - simple/basic with options: -V
@test "composite / unflatten - with options: -V" {
    run jqg -U -V domestic $carnivora_json
    assert_success
    assert_output - <<EOF
[
  {
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
  [
    null,
    {
      "type": "domesticated"
    }
  ]
]
EOF
}

# composite / unflatten - simple/basic with options: -q -S
@test "composite / unflatten - with options: -q -S" {
    run jqg -U -q -S domestic $carnivora_json
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

# composite / unflatten - simple/basic with options: -q -S <jqu>
@test "composite / unflatten - with options: -q -S <jqu>" {
    run jqu -q -S domestic $carnivora_json
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



# composite / unflatten - override - jqg -s -U
@test "composite / unflatten - override - jqg -s with -U" {
    run jqg -s breed -U $carnivora_json
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

# composite / unflatten - override - jqg -u -U
@test "composite / unflatten - override - jqg -u with -U" {
    run jqg -u breed -U $carnivora_json
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

# composite / unflatten - override - jqg -x -U
@test "composite / unflatten - override - jqg -x with -U" {
    run jqg -x breed -U $carnivora_json
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

# composite / unflatten - override - jqg -U with -s
@test "composite / unflatten - override - jqg -U with -s" {
    run jqg -U -s domestic $carnivora_json
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

# composite / unflatten - override - jqg -U with -s <jqu>
@test "composite / unflatten - override - jqg -U with -s <jqu>" {
    run jqu -s domestic $carnivora_json
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

# composite / unflatten - override - jqg -U with -u
@test "composite / unflatten - override - jqg -U with -u" {
    run jqg -U -u $lorem_mixed_object_json
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

# composite / unflatten - override - jqg -U with -u <jqu>
@test "composite / unflatten - override - jqg -U with -u <jqu>" {
    run jqu -u $lorem_mixed_object_json
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

# composite / unflatten - override - jqg -U with -x
@test "composite / unflatten - override - jqg -U with -x" {
    run jqg -U -x .dog $carnivora_json
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
  ]
}
EOF
}

# composite / unflatten - override - jqg -U with -x <jqu>
@test "composite / unflatten - override - jqg -U with -x <jqu>" {
    run jqu -x .dog $carnivora_json
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
  ]
}
EOF
}

# composite / unflatten - jqu -t none
@test "composite / unflatten - override - jqg -U with -t none" {
    run jqg -U -t none breed $carnivora_json
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

# composite / unflatten - jqu -t flatten
@test "composite / unflatten - override - jqg -U with -t flatten" {
    run jqg -U -t flatten breed $carnivora_json
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

# composite / unflatten - override - JQG_OPTS=-U with -s
@test "composite / unflatten - override - JQG_OPTS=-U with -s" {
    export JQG_OPTS="-U"
    run jqg -s domestic $carnivora_json
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

# composite / unflatten - override - JQG_OPTS=-U with -t none
@test "composite / unflatten - override - JQG_OPTS=-U with -t none" {
    export JQG_OPTS="-U"
    run jqg -t none domestic $carnivora_json
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

# composite / unflatten - override - JQG_OPTS=-U with -t flatten
@test "composite / unflatten - override - JQG_OPTS=-U with -t flatten" {
    export JQG_OPTS="-U"
    run jqg -t flatten domestic $carnivora_json
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

# composite / unflatten - override - JQG_OPTS=-U with -x
@test "composite / unflatten - override - JQG_OPTS=-U with -x" {
    export JQG_OPTS="-U"
    run jqg -x .dog $carnivora_json
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
  ]
}
EOF
}
