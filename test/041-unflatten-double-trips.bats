#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/041-unflatten-double-trips.bats
#----------------------------------------------------------------------
#--- test unflatten mode - flatten -> unflatten -> unflatten
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }



# flatten JSON twice & unflatten JSON - check md5sum
double_flat_round_trip()
{
    local filename=$1; shift
    local file_md5=$1; shift

    local flat1_json="$jqg_tmpdir/flat1.json"
    jqg . "$filename" >"$flat1_json"
    local flat1_md5=$(md5sum "$flat1_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat1_md5" "$file_md5"

    local flat2_json="$jqg_tmpdir/flat2.json"
    jqg . "$flat1_json" >"$flat2_json"
    local flat2_md5=$(md5sum "$flat2_json" | cut -d ' ' -f 1)

    assert_equal "$flat2_md5" "$flat1_md5"

    local unflattened_json="$jqg_tmpdir/unflattened.json"
    jqg -u "$flat2_json" >"$unflattened_json"
    local unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$file_md5"
}

@test "double flat round trip - carnivora" {
    double_flat_round_trip "$carnivora_json" "$carnivora_md5"
}

@test "double flat round trip - citrus" {
    double_flat_round_trip "$citrus_json" "$citrus_md5"
}

@test "double flat round trip - odd-values" {
    double_flat_round_trip "$odd_values_json" "$odd_values_md5"
}

@test "double flat round trip - lorem object" {
    double_flat_round_trip "$lorem_object_json" "$lorem_object_md5"
}

@test "double flat round trip - lorem array" {
    double_flat_round_trip "$lorem_array_json" "$lorem_array_md5"
}

@test "double flat round trip - lorem mixed object" {
    double_flat_round_trip "$lorem_mixed_object_json" "$lorem_mixed_object_md5"
}

@test "double flat round trip - lorem mixed array" {
    double_flat_round_trip "$lorem_mixed_array_json" "$lorem_mixed_array_md5"
}

@test "double flat round trip - large structure #1" {
    double_flat_round_trip "$large_structure1_json" "$large_structure1_md5"
}

@test "double flat round trip - large structure #2" {
    double_flat_round_trip "$large_structure2_json" "$large_structure2_md5"
}

@test "double flat round trip - large structure #3" {
    double_flat_round_trip "$large_structure3_json" "$large_structure3_md5"
}

@test "double flat round trip - large structure #4" {
    double_flat_round_trip "$large_structure4_json" "$large_structure4_md5"
}




# flatten JSON & unflatten JSON twice - check md5sum
double_unflat_round_trip()
{
    local filename=$1; shift
    local file_md5=$1; shift

    local flattened_json="$jqg_tmpdir/flattened.json"
    jqg . "$filename" >"$flattened_json"
    local flattened_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flattened_md5" "$file_md5"

    local unflat1_json="$jqg_tmpdir/unflat1.json"
    jqg -u "$flattened_json" >"$unflat1_json"
    local unflat1_md5=$(md5sum "$unflat1_json" | cut -d ' ' -f 1)

    assert_not_equal "$unflat1_md5" "$flattened_md5"
    assert_equal "$unflat1_md5" "$file_md5"

    local unflat2_json="$jqg_tmpdir/unflat2.json"
    jqg -u "$unflat1_json" >"$unflat2_json"
    local unflat2_md5=$(md5sum "$unflat2_json" | cut -d ' ' -f 1)

    assert_equal "$unflat2_md5" "$file_md5"
}

@test "double unflat round trip - carnivora" {
    double_unflat_round_trip "$carnivora_json" "$carnivora_md5"
}

@test "double unflat round trip - citrus" {
    double_unflat_round_trip "$citrus_json" "$citrus_md5"
}

@test "double unflat round trip - odd-values" {
    double_unflat_round_trip "$odd_values_json" "$odd_values_md5"
}

@test "double unflat round trip - lorem object" {
    double_unflat_round_trip "$lorem_object_json" "$lorem_object_md5"
}

@test "double unflat round trip - lorem array" {
    double_unflat_round_trip "$lorem_array_json" "$lorem_array_md5"
}

@test "double unflat round trip - lorem mixed object" {
    double_unflat_round_trip "$lorem_mixed_object_json" "$lorem_mixed_object_md5"
}

@test "double unflat round trip - lorem mixed array" {
    double_unflat_round_trip "$lorem_mixed_array_json" "$lorem_mixed_array_md5"
}

@test "double unflat round trip - large structure #1" {
    double_unflat_round_trip "$large_structure1_json" "$large_structure1_md5"
}

@test "double unflat round trip - large structure #2" {
    double_unflat_round_trip "$large_structure2_json" "$large_structure2_md5"
}

@test "double unflat round trip - large structure #3" {
    double_unflat_round_trip "$large_structure3_json" "$large_structure3_md5"
}

@test "double unflat round trip - large structure #4" {
    double_unflat_round_trip "$large_structure4_json" "$large_structure4_md5"
}
