#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/042-unflatten-problematic-keys.bats
#----------------------------------------------------------------------
#--- test unflatten mode - problematic keys
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }




make_problematic_key_json()
{
    local filename=${1:?missing filename}; shift || true
    local sep_char=${1:-.}; shift || true

    cat <<EOJ >"$filename"
{
  "cillum": {
    "magna${sep_char}irure": true,
    "mollit": false
  },
  "reprehenderit${sep_char}duis${sep_char}proident": [
    "sint${sep_char}fugiat${sep_char}nostrud${sep_char}laborum"
  ]
}
EOJ
}


# flatten JSON with . in key & unflatten - should be different
@test "problematic keys (round trip fail)" {
    orig_json="$jqg_tmpdir/problematic.json"
    make_problematic_key_json "$orig_json"
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$orig_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_not_equal "$pipeline_md5" "$orig_md5"
}



# flatten JSON with : in key & unflatten - should be same
@test "problematic keys - colon (round trip OK)" {
    orig_json="$jqg_tmpdir/problematic.json"
    make_problematic_key_json "$orig_json" ":"
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$orig_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}



# flatten JSON with . in key using -J & unflatten using -J - should be same
@test "problematic keys - period / -J (round trip OK)" {
    orig_json="$jqg_tmpdir/problematic.json"
    make_problematic_key_json "$orig_json" "."
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg -J . "$orig_json" | jqg -J -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}



# flatten JSON with . in key using -j + & unflatten using -j + - should be same
@test "problematic keys - period / -j + (round trip OK)" {
    orig_json="$jqg_tmpdir/problematic.json"
    make_problematic_key_json "$orig_json" "."
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg -j + . "$orig_json" | jqg -j + -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}
