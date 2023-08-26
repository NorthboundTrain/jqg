#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/003-pipeline-execution.bats
#----------------------------------------------------------------------
#--- test jqg in a pipeline
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# pipeline in
@test "pipeline in" {
    run bash -c "jq . $carnivora_json | jqg feli"
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}

# pipeline out
@test "pipeline out" {
    run bash -c "jqg feli $carnivora_json | jq -S -c"
    assert_success
    assert_output - <<EOF
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
EOF
}

# pipeline middle
@test "pipeline middle" {
    run bash -c "jq . $carnivora_json | jqg feli | jq -S -c"
    assert_success
    assert_output - <<EOF
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
EOF
}
