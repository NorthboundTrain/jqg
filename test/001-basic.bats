#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/001-basic.bats
#----------------------------------------------------------------------
#--- test the very basics of jqg execution & whether the test suite can work
#----------------------------------------------------------------------
#   -h / --help
#      / --bug
#      / --version
#   $JQ_BIN
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



@test "run jqg" {
    run jqg </dev/null
    assert_success
}

@test "jqg -h" {
    run jqg -h </dev/null
    assert_success
    assert_output --partial CRITERIA
    assert_output --partial special
    assert_output --partial --bug
}

@test "jqu -h" {
    run jqu -h </dev/null
    assert_success
    assert_output --partial CRITERIA
    assert_output --partial special
    assert_output --partial --bug
}

@test "jqx -h" {
    run jqx -h </dev/null
    assert_success
    assert_output --partial CRITERIA
    assert_output --partial special
    assert_output --partial --bug
}

@test "jqg -h <long>" {
    run jqg --help </dev/null
    assert_success
    assert_output --partial CRITERIA
    assert_output --partial special
    assert_output --partial --bug
}

@test "jqg --bug" {
    run jqg --bug </dev/null
    assert_success
    assert_output --partial JQG_OPT
}

@test "jqu --bug" {
    run jqu --bug </dev/null
    assert_success
    assert_output --partial JQG_OPT
}

@test "jqx --bug" {
    run jqx --bug </dev/null
    assert_success
    assert_output --partial JQG_OPT
}

@test "jqg --version" {
    run jqg --version </dev/null
    assert_success
    assert_output --regexp '^v[0-9]+\.[0-9]+\.[0-9](-rc[0-9]+)?$'
}



@test "unknown short option" {
    run jqg -w </dev/null
    assert_failure 2
}

@test "unknown long option" {
    run jqg --wide </dev/null
    assert_failure 2
}



@test "\$JQ_BIN unset" {
    unset JQ_BIN
    run jqg breed $carnivora_json
    assert_success
}

@test "\$JQ_BIN set properly" {
    export JQ_BIN=$(which jq)
    run jqg breed $carnivora_json
    assert_success
}

@test "\$JQ_BIN set to false" {
    export JQ_BIN=$(which false)
    run jqg breed $carnivora_json
    assert_failure # /bin/false exit code
}



@test "check for test JSON files" {
    assert_file_exist $carnivora_json
    assert_file_exist $citrus_json
    assert_file_exist $odd_values_json

    assert_file_exist $lorem_object_json
    assert_file_exist $lorem_array_json
    assert_file_exist $lorem_mixed_object_json
    assert_file_exist $lorem_mixed_array_json

    assert_file_exist $large_structure1_json
    assert_file_exist $large_structure2_json
    assert_file_exist $large_structure3_json
    assert_file_exist $large_structure4_json
}



# gotta make sure the unit test functions work :(
@test "parse_version_elements: 5.2.16(1)-release" {
    declare -rA elems=$(parse_version_elements version="5.2.16(1)-release")

    assert_equal "${elems[major]}" 5
    assert_equal "${elems[minor]}" 2
    assert_equal "${elems[patch]}" 16
}

@test "parse_version_elements: jq-1.6" {
    declare -rA elems=$(parse_version_elements version="jq-1.6")

    assert_equal "${elems[major]}" 1
    assert_equal "${elems[minor]}" 6
    assert_equal "${elems[patch]}" 0
}

@test "parse_version_elements: jq-1.6-137-gd18b2d0-dirty" {
    declare -rA elems=$(parse_version_elements version="jq-1.6-137-gd18b2d0-dirty")

    assert_equal "${elems[major]}" 1
    assert_equal "${elems[minor]}" 6
    assert_equal "${elems[patch]}" 137
}

@test "parse_version_elements: Bats 1.7.0" {
    declare -rA elems=$(parse_version_elements version="Bats 1.7.0")

    assert_equal "${elems[major]}" 1
    assert_equal "${elems[minor]}" 7
    assert_equal "${elems[patch]}" 0
}

# check actual versions (finally)
@test "check bash version" {
    ver=$(/usr/bin/env bash -c 'echo $BASH_VERSION')
    check_version_number version=$ver target=3.0.27 action=fail
}

@test "check JQ version" {
    ver=$(jq --version)
    check_version_number version=$ver target=1.6 action=fail
}

@test "check BATS version" {
    ver=$BATS_VERSION
    check_version_number version=$ver target=1.7 action=fail
}
