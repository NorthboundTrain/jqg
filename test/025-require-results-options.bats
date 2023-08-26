#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/025-count-results-options.bats
#----------------------------------------------------------------------
#--- test require_results
#----------------------------------------------------------------------
#   -n / --empty_results_ok
#   -N / --results_required
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# bad search - normal (default)
@test "bad search - normal (default)" {
    run jqg foobar $carnivora_json
    assert_success
    assert_output - <<EOF
{}
EOF
}

# bad search - normal
@test "bad search - normal" {
    run jqg -n foobar $carnivora_json
    assert_success
    assert_output - <<EOF
{}
EOF
}

# bad search - normal (long)
@test "bad search - normal (long)" {
    run jqg --empty_results_ok foobar $carnivora_json
    assert_success
    assert_output "{}"
}

# bad search - error
@test "bad search - error" {
    run jqg -N foobar $carnivora_json
    assert_failure 1
}

# bad search - error (long)
@test "bad search - error (long)" {
    run jqg --results_required foobar $carnivora_json
    assert_failure 1
}

# OK search - error
@test "OK search - error" {
    run jqg -N breed $carnivora_json
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

# OK search - error (long)
@test "OK search - error (long)" {
    run jqg --results_required breed $carnivora_json
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



# null search - normal
@test "null search - normal" {
    run jqg -n foobar <<< "null"
    assert_success
    assert_output "{}"
}

# null search - error
@test "null search - error" {
    run jqg -N foobar <<< "null"
    assert_failure 1
}



# unflatten - normal
@test "unflatten - normal" {
    run bash -c "jqg breed $carnivora_json | jqg -u -n"
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

# unflatten - error
@test "unflatten - error" {
    run bash -c "jqg breed $carnivora_json | jqg -u -N"
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



# bad extract - normal
@test "bad extract - normal" {
    run jqg -n -x .foobar $carnivora_json
    assert_success
    assert_output "null"
}

# bad extract - error
@test "bad extract - error" {
    run jqg -N -x .foobar $carnivora_json
    assert_failure 1
}



# search & unflatten - normal
@test "search & unflatten - normal" {
    run jqg -n -U foobar $carnivora_json
    assert_success
    assert_output "null"
}

# search & unflatten - error
@test "search & unflatten - error" {
    run jqg -N -U foobar $carnivora_json
    assert_failure 1
}

# null search & unflatten - normal
@test "null search & unflatten - normal" {
    run jqg -n -U foobar <<<"null"
    assert_success
    assert_output "null"
}

# null search & unflatten - error
@test "null search & unflatten - error" {
    run jqg -N -U foobar <<<"null"
    assert_failure 1
}



# extract & bad search - normal
@test "extract & bad search - normal" {
    run jqg -n -X .dog foobar $carnivora_json
    assert_success
    assert_output "{}"
}

# extract & bad search - error
@test "extract & bad search - error" {
    run jqg -N -X .dog foobar $carnivora_json
    assert_failure 1
}



# -N search results: {} - OK
@test "-N search results: {} - OK" {
    run jqg -V -r empty-object $odd_values_json
    assert_success
    assert_output "{}"
}

# -N search results: [] - OK
@test "-N search results: [] - OK" {
    run jqg -V -r empty-array $odd_values_json
    assert_success
    assert_output "[]"
}

# -N search results: null - OK
@test "-N search results: null - OK" {
    run jqg -V -r null-value $odd_values_json
    assert_success
    assert_output "null"
}

# -N search results: 0 - OK
@test "-N search results: 0 - OK" {
    run jqg -V -r number-zero $odd_values_json
    assert_success
    assert_output "0"
}

# -N search results: false - OK
@test "-N search results: false - OK" {
    run jqg -V -r false-boolean $odd_values_json
    assert_success
    assert_output "false"
}

# -N search results: "" - OK
@test "-N search results: \"\" - OK" {
    run jqg -V -r empty-string $odd_values_json
    assert_success
    assert_output ""
}
