#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/070-noop-option-combos.bats
#----------------------------------------------------------------------
#--- several option combos can result in no work being done; make sure they work
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }

#***** test one of them fully *****

# jqg -t none -T none FILE
none_search_none_noop_test()
{
    local filename=$1; shift
    local file_md5=$1; shift

    local noop_json="$jqg_tmpdir/noop.json"
    jqg -t none -T none $filename >$noop_json
    local noop_md5=$(md5sum "$noop_json" | cut -d ' ' -f 1)

    assert_equal "$noop_md5" "$file_md5"

    run jqg -d -t none -T none $filename

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$filename"

FILTER:
.
EOF
}

@test "none/search/none - carnivora" {
    none_search_none_noop_test "$carnivora_json" "$carnivora_md5"
}

@test "none/search/none - citrus" {
    none_search_none_noop_test "$citrus_json" "$citrus_md5"
}

@test "none/search/none - odd-values" {
    none_search_none_noop_test "$odd_values_json" "$odd_values_md5"
}

@test "none/search/none - lorem-array" {
    none_search_none_noop_test "$lorem_array_json" "$lorem_array_md5"
}

@test "none/search/none - lorem-object" {
    none_search_none_noop_test "$lorem_object_json" "$lorem_object_md5"
}

@test "none/search/none - lorem-mixed-array" {
    none_search_none_noop_test "$lorem_mixed_array_json" "$lorem_mixed_array_md5"
}

@test "none/search/none - lorem-mixed-object" {
    none_search_none_noop_test "$lorem_mixed_object_json" "$lorem_mixed_object_md5"
}

@test "none/search/none - large-structure1" {
    none_search_none_noop_test "$large_structure1_json" "$large_structure1_md5"
}

@test "none/search/none - large-structure2" {
    none_search_none_noop_test "$large_structure2_json" "$large_structure2_md5"
}

@test "none/search/none - large-structure3" {
    none_search_none_noop_test "$large_structure3_json" "$large_structure3_md5"
}

@test "none/search/none - large-structure4" {
    none_search_none_noop_test "$large_structure4_json" "$large_structure4_md5"
}


#***** just make sure the rest produce the right debug output *****

# jqg -T none FILE
@test "none/search debug" {
    run jqg -d -T none $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -T none . FILE
@test "none/search debug with dot" {
    run jqg -d -T none . $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -x -T none  FILE
@test "none/extract debug" {
    run jqg -d -x -T none $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -x -T none . FILE
@test "none/extract debug with dot" {
    run jqg -d -x -T none . $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -U -t none -T none FILE
@test "none/search+composite_unflatten/none debug" {
    run jqg -d -U -t none -T none $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -U -t none -T none . FILE
@test "none/search+composite_unflatten/none debug with dot" {
    run jqg -d -U -t none -T none . $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqu -t none -T none FILE
@test "none/search+composite_unflatten/none debug <jqu>" {
    run jqu -d -t none -T none $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -X . -T none FILE
@test "none/search+composite_extract debug" {
    run jqg -d -X . -T none $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqg -X . -T none . FILE
@test "none/search+composite_extract debug with dot" {
    run jqg -d -X . -T none . $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}

# jqx . -T none FILE
@test "none/search+composite_extract debug <jqu>" {
    run jqx . -d -T none $carnivora_json

    assert_output - <<EOF
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "$carnivora_json"

FILTER:
.
EOF
}
