#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/020-output-content-options.bats
#----------------------------------------------------------------------
#--- test the output content options
#----------------------------------------------------------------------
#   -K / --keys
#   -V / --values
#   -A / --all (default)
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# output everthing (default)
@test "default output (object)" {
    run jqg mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "default output (array)" {
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

@test "default output (mixed - hanging array)" {
    run jqg feli $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}

@test "default output (mixed - embedded array)" {
    run jqg king $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}

@test "default output (empty)" {
    run jqg ursa $carnivora_json
    assert_success
    assert_output "{}"
}



# output everthing
@test "output all (object)" {
    run jqg -A mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "output all (object) <long>" {
    run jqg --all mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "output all (array)" {
    run jqg -A feral $carnivora_json
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

@test "output all (mixed - hanging array)" {
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

@test "output all (mixed - embedded array)" {
    run jqg -A king $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}

@test "output all (empty)" {
    run jqg -A ursa $carnivora_json
    assert_success
    assert_output "{}"
}



# output keys
@test "output keys (object)" {
    run jqg -K mammal $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "isa",
  "classification.class"
]
EOF
}

@test "output keys (object) <long>" {
    run jqg --keys mammal $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "isa",
  "classification.class"
]
EOF
}

@test "output keys (array)" {
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

@test "output keys (mixed - hanging array)" {
    run jqg -K feli $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "subclades.0",
  "cat.isa",
  "cat.feral.2.aka"
]
EOF
}

@test "output keys (mixed - embedded array)" {
    run jqg -K king $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "classification.kingdom",
  "cat.feral.0.aka"
]
EOF
}

@test "output keys (empty)" {
    run jqg -K ursa $carnivora_json
    assert_success
    assert_output "[]"
}



# output values
@test "output values (object)" {
    run jqg -V mammal $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "mammal",
  "mammalia"
]
EOF
}

@test "output values (object) <long>" {
    run jqg --values mammal $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "mammal",
  "mammalia"
]
EOF
}

@test "output values (array)" {
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

@test "output values (mixed - hanging array)" {
    run jqg -V feli $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "feliformia",
  "feline",
  "felis nigripes"
]
EOF
}

@test "output value (mixed - embedded array)" {
    run jqg -V king $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "animalia",
  "king of the beasts"
]
EOF
}

@test "output values (empty)" {
    run jqg -V ursa $carnivora_json
    assert_success
    assert_output "[]"
}


# search keys, ouput values
@test "search keys, output values" {
    run jqg -k king -V $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "animalia"
]
EOF
}

# search values, ouput keys
@test "search values, output keys" {
    run jqg -v king -K $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "cat.feral.0.aka"
]
EOF
}
