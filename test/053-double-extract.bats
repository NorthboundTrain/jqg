#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/053-double-extract.bats
#----------------------------------------------------------------------
#--- test extract mode - extract -> extract
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }



# extract JSON twice - check md5sum
double_extract()
{
    local selector=$1; shift
    local filename=$1; shift
    local file_md5=$1; shift
    local refute_md5=${1:-0}; shift || true

    local extract1_json="$jqg_tmpdir/extract1.json"
    jqg -x $selector "$filename" >"$extract1_json"
    local extract1_md5=$(md5sum "$extract1_json" | cut -d ' ' -f 1)

    assert_not_equal "$extract1_md5" "$file_md5"

    if [[ "$refute_md5" != "0" ]]; then
        assert_not_equal "$extract1_md5" "$refute_md5"
    fi

    local extract2_json="$jqg_tmpdir/extract2.json"
    jqg -x $selector "$extract1_json" >"$extract2_json"
    local extract2_md5=$(md5sum "$extract2_json" | cut -d ' ' -f 1)

    assert_equal "$extract2_md5" "$extract1_md5"
}

@test "double extract - carnivora" {
    double_extract ".cat.domesticated" "$carnivora_json" "$carnivora_md5" "$null_md5"
}

@test "double extract - citrus" {
    double_extract ".core" "$citrus_json" "$citrus_md5" "$null_md5"
}

@test "double extract - odd-values" {
    double_extract ".two[1]" "$odd_values_json" "$odd_values_md5" "$null_md5"
}

@test "double extract - lorem object" {
    double_extract ".vero" "$lorem_object_json" "$lorem_object_md5" "$null_md5"
}

@test "double extract - lorem array" {
    double_extract ".[3]" "$lorem_array_json" "$lorem_array_md5" "$null_md5"
}

@test "double extract - lorem mixed object" {
    double_extract ".homero" "$lorem_mixed_object_json" "$lorem_mixed_object_md5" "$null_md5"
}

@test "double extract - lorem mixed array" {
    double_extract ".[3]" "$lorem_mixed_array_json" "$lorem_mixed_array_md5" "$null_md5"
}

@test "double extract - large structure #1" {
    double_extract ".ac[0].veri" "$large_structure1_json" "$large_structure1_md5" "$null_md5"
}

@test "double extract - large structure #2" {
    double_extract ".contentiones[0]" "$large_structure2_json" "$large_structure2_md5" "$null_md5"
}

@test "double extract - large structure #3" {
    double_extract ".[0][0][3]" "$large_structure3_json" "$large_structure3_md5" "$null_md5"
}

@test "double extract - large structure #4" {
    double_extract ".regione.definiebas.salutatus" "$large_structure4_json" "$large_structure4_md5" "$null_md5"
}
