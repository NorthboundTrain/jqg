#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/022-jq-option-passthrough.bats
#----------------------------------------------------------------------
#--- test JQ option passthrough
#----------------------------------------------------------------------
#   -q / --jqopt
#   -Q / --clear
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



@test "no JQ opts" {
    run jqg mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "sort option (-S)" {
    run jqg -q -S mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}

@test "sort option (-S) <long>" {
    run jqg --jqopt -S mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}

@test "sort option (--sort-keys)" {
    run jqg -q --sort-keys mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}

@test "sort option (--sort-keys) <long>" {
    run jqg --jqopt --sort-keys mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}

@test "compact option (-c)" {
    run jqg -q -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}

@test "sort & compact options (-S -c)" {
    run jqg -q -S -q -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "sort & compact options (--sort-keys --compact-output)" {
    run jqg -q --sort-keys -q --compact-output mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "sort & compact options (-S -c) <long>" {
    run jqg --jqopt -S --jqopt -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "sort & compact options (--long)" {
    run jqg -q --sort-keys -q --compact-output mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "sort & compact options (--long) <long>" {
    run jqg --jqopt --sort-keys --jqopt --compact-output mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}

@test "sort & compact options -- cleared" {
    run jqg -q -S -q -c -Q mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "sort & compact options -- cleared <long>" {
    run jqg -q -S -q -c --clear mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}

@test "sort & cleared & compact options" {
    run jqg -q -S -Q -q -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}

@test "sort & cleared & compact options <long>" {
    run jqg --jqopt -S --clear --jqopt -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}



@test "unflatten (no options)" {
    run bash -c "jqg classification $carnivora_json | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "classification": {
    "kingdom": "animalia",
    "phylum": "chordata",
    "class": "mammalia"
  }
}
EOF
}

@test "unflatten (-S)" {
    run bash -c "jqg classification $carnivora_json | jqg -u -q -S"
    assert_success
    assert_output - <<EOF
{
  "classification": {
    "class": "mammalia",
    "kingdom": "animalia",
    "phylum": "chordata"
  }
}
EOF
}

@test "extract (no options)" {
    run jqg -x .classification $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification": {
    "kingdom": "animalia",
    "phylum": "chordata",
    "class": "mammalia"
  }
}
EOF
}

@test "extract (-S)" {
    run jqg -x -q -S .classification $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification": {
    "class": "mammalia",
    "kingdom": "animalia",
    "phylum": "chordata"
  }
}
EOF
}
