#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/040-unflatten-round-trips.bats
#----------------------------------------------------------------------
#--- test unflatten mode - flatten -> unflatten
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }



# flatten then unflatten the JSON - check md5sum
round_trip_test()
{
    local filename=$1; shift
    local file_md5=$1; shift

    local flattened_json="$jqg_tmpdir/flattened.json"
    jqg . "$filename" >"$flattened_json"
    local flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$file_md5"

    local unflattened_json="$jqg_tmpdir/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    local unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$file_md5"
}

@test "round trip with jqg -u - carnivora" {
    round_trip_test "$carnivora_json" "$carnivora_md5"
}

@test "round trip with jqg -u - citrus" {
    round_trip_test "$citrus_json" "$citrus_md5"
}

@test "round trip with jqg -u - odd-values" {
    round_trip_test "$odd_values_json" "$odd_values_md5"
}

@test "round trip with jqg -u - lorem object" {
    round_trip_test "$lorem_object_json" "$lorem_object_md5"
}

@test "round trip with jqg -u - lorem array" {
    round_trip_test "$lorem_array_json" "$lorem_array_md5"
}

@test "round trip with jqg -u - lorem mixed object" {
    round_trip_test "$lorem_mixed_object_json" "$lorem_mixed_object_md5"
}

@test "round trip with jqg -u - lorem mixed array" {
    round_trip_test "$lorem_mixed_array_json" "$lorem_mixed_array_md5"
}

@test "round trip with jqg -u - large structure #1" {
    round_trip_test "$large_structure1_json" "$large_structure1_md5"
}

@test "round trip with jqg -u - large structure #2" {
    round_trip_test "$large_structure2_json" "$large_structure2_md5"
}

@test "round trip with jqg -u - large structure #3" {
    round_trip_test "$large_structure3_json" "$large_structure3_md5"
}

@test "round trip with jqg -u - large structure #4" {
    round_trip_test "$large_structure4_json" "$large_structure4_md5"
}




# flatten JSON & unflatten JSON using '+' via JQG_OPTS- check md5sum (citrus)
@test "round trip with -j + via JQG_OPTS - citrus" {
    jplus_flat_json="$jqg_tmpdir/jplus_flat.json"
    jqg -j + . "$citrus_json" >"$jplus_flat_json"
    jplus_md5=$(md5sum "$jplus_flat_json" | cut -d ' ' -f 1)

    assert_not_equal "$jplus_md5" "$citrus_md5"

    export JQG_OPTS='-j +'
    flattened_json="$jqg_tmpdir/flattened.json"
    jqg . "$citrus_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$citrus_md5"
    assert_equal "$flat_md5" "$jplus_md5"

    unflattened_json="$jqg_tmpdir/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$citrus_md5"
}



# flatten JSON & unflatten JSON via pipeline - check md5sum (carnivora)
@test "round trip pipeline - carnivora" {
    pipeline_md5=$(jqg . "$carnivora_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$carnivora_md5"
}



# flatten JSON & unflatten JSON via pipeline - check md5sum (citrus)
@test "round trip pipeline - citrus" {
    pipeline_md5=$(jqg . "$citrus_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$citrus_md5"
}



# flatten JSON & unflatten JSON via pipeline - check md5sum (odd-values)
@test "round trip pipeline - odd-values" {
    pipeline_md5=$(jqg . "$odd_values_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$odd_values_md5"
}



# flatten JSON and unflatten with -q -S (carnivora)
@test "round-trip pipeline with [-q -S] - carnivora" {
    jqs_md5=$(jq -S . "$carnivora_json" | md5sum | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$carnivora_json" | jqg -q -S -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$jqs_md5"
}



# flatten JSON and unflatten with -q -S (citrus)
@test "round-trip pipeline with [-q -S] - citrus" {
    jqs_md5=$(jq -S . "$citrus_json" | md5sum | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$citrus_json" | jqg -q -S -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$jqs_md5"
}



# flatten JSON and unflatten with -q -S (odd-values)
@test "round-trip pipeline with [-q -S] - odd-values" {
    jqs_md5=$(jq -S . "$odd_values_json" | md5sum | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$odd_values_json" | jqg -q -S -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$jqs_md5"
}
