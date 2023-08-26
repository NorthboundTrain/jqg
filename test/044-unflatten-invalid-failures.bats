#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/044-unflatten-invalid-failures.bats
#----------------------------------------------------------------------
#--- test unflatten mode - invalid uses & failures
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }



# invalid flattened JSON - top-level object mixed with array
@test "invalid flat - top-level obj with array" {
    invalid_json="$jqg_tmpdir/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "occaecat.dolor": "voluptate",
  "0.quis": true,
  "incididunt.0": "duis"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure # JQ exit code
    assert_output --partial "Cannot index object with number"
}



# invalid flattened JSON - top-level array mixed with object
@test "invalid flat - top-level array with obj" {
    invalid_json="$jqg_tmpdir/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "0.quis": true,
  "occaecat.dolor": "voluptate",
  "incididunt.0": "duis"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure # JQ exit code
    assert_output --partial "Cannot index array with string"
}



# invalid flattened JSON - interior object mixed with array
@test "invalid flat - interior obj with array" {
    invalid_json="$jqg_tmpdir/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "cillum.amet": "anim",
  "nisi.old.adipisicing": true,
  "nisi.0.adipisicing": true,
  "incididunt.0": "culpa"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure # JQ exit code
    assert_output --partial "Cannot index object with number"
}



# invalid flattened JSON - interioir array mixed with object
@test "invalid flat - interior array with obj" {
    invalid_json="$jqg_tmpdir/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "cillum.amet": "anim",
  "nisi.0.adipisicing": true,
  "nisi.old.adipisicing": true,
  "incididunt.0": "culpa"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure # JQ exit code
    assert_output --partial "Cannot index array with string"
}



# round-trip failure - numeric object keys
@test "round-trip failure - numeric object keys" {
    orig_json="$jqg_tmpdir/orig.json"
    cat <<EOJ >"$orig_json"
{
  "proident": {
    "non": true,
    "3": true
  }
}
EOJ
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    flattened_md5=$(jqg . "$orig_json" | md5sum | cut -d ' ' -f 1)
    assert_not_equal "$flattened_md5" "$orig_md5"

    pipeline_md5=$(jqg . "$orig_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_not_equal "$pipeline_md5" "$orig_md5"
    assert_not_equal "$pipeline_md5" "$flattened_md5"
}
