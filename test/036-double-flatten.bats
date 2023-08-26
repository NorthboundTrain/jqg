#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/036-double-flatten.bats
#----------------------------------------------------------------------
#--- test flatten mode - flatten -> flatten
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }



# flatten JSON twice - check md5sum
double_flatten()
{
    local filename=$1; shift
    local file_md5=$1; shift

    local flatten1_json="$jqg_tmpdir/flatten1.json"
    jqg "$filename" >"$flatten1_json"
    local flatten1_md5=$(md5sum "$flatten1_json" | cut -d ' ' -f 1)

    assert_not_equal "$flatten1_md5" "$file_md5"

    local flatten2_json="$jqg_tmpdir/flatten2.json"
    jqg "$flatten1_json" >"$flatten2_json"
    local flatten2_md5=$(md5sum "$flatten2_json" | cut -d ' ' -f 1)

    assert_equal "$flatten2_md5" "$flatten1_md5"
}

@test "double flatten - carnivora" {
    double_flatten "$carnivora_json" "$carnivora_md5"
}

@test "double flatten - citrus" {
    double_flatten "$citrus_json" "$citrus_md5"
}

@test "double flatten - odd-values" {
    double_flatten "$odd_values_json" "$odd_values_md5"
}

@test "double flatten - lorem object" {
    double_flatten "$lorem_object_json" "$lorem_object_md5"
}

@test "double flatten - lorem array" {
    double_flatten "$lorem_array_json" "$lorem_array_md5"
}

@test "double flatten - lorem mixed object" {
    double_flatten "$lorem_mixed_object_json" "$lorem_mixed_object_md5"
}

@test "double flatten - lorem mixed array" {
    double_flatten "$lorem_mixed_array_json" "$lorem_mixed_array_md5"
}

@test "double flatten - large structure #1" {
    double_flatten "$large_structure1_json" "$large_structure1_md5"
}

@test "double flatten - large structure #2" {
    double_flatten "$large_structure2_json" "$large_structure2_md5"
}

@test "double flatten - large structure #3" {
    double_flatten "$large_structure3_json" "$large_structure3_md5"
}

@test "double flatten - large structure #4" {
    double_flatten "$large_structure4_json" "$large_structure4_md5"
}
