#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/043-unflatten-sparse-arrays.bats
#----------------------------------------------------------------------
#--- test unflatten mode - sparse arrays
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; make_temp_dir; }
teardown() { load common; common_teardown; remove_temp_dir; }



make_sparse_array_json()
{
    local filename=${1:?missing filename}; shift || true
    local empty=${1:-true}; shift || true

    local sparse
    if [[ "$empty" == "true" ]]; then
        sparse="{}, [], "
    else
        sparse="null, null,"
    fi

    cat <<EOJ >"$filename"
{
  "lorem": {
    "ipsum": "porttitor"
  },
  "dolor": {
    "sit": {
      "amet": [
        ${sparse}
        {
          "nunc": {
            "vitae": true,
            "morbi": true
          }
        }
      ]
    }
  }
}
EOJ
}



# sparse array
@test "sparse array generation" {
    empty_json="$jqg_tmpdir/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    null_json="$jqg_tmpdir/null.json"
    make_sparse_array_json "$null_json" "false"
    null_md5=$(jq . "$null_json" | md5sum| cut -d ' ' -f 1)

    assert_not_equal "$null_md5" "$empty_md5"
}



# sparse array
@test "sparse array - round trip OK" {
    empty_json="$jqg_tmpdir/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    flattened_json="$jqg_tmpdir/flattened.json"
    jqg . "$empty_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$empty_md5"

    unflattened_json="$jqg_tmpdir/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$empty_md5"
}



# sparse array w/ -E (fail)
@test "sparse array [-E] - round trip fail" {
    empty_json="$jqg_tmpdir/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    flattened_json="$jqg_tmpdir/flattened.json"
    jqg -E . "$empty_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    unflattened_json="$jqg_tmpdir/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$unflat_md5" "$empty_md5"
    assert_not_equal "$unflat_md5" "$flat_md5"
}



# sparse array w/ -E (OK)
@test "sparse array [-E] - round trip OK" {
    empty_json="$jqg_tmpdir/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    null_json="$jqg_tmpdir/null.json"
    make_sparse_array_json "$null_json" "false"
    null_md5=$(jq . "$null_json" | md5sum| cut -d ' ' -f 1)

    flattened_json="$jqg_tmpdir/flattened.json"
    jqg -E . "$empty_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$empty_md5"
    assert_not_equal "$flat_md5" "$null_md5"

    unflattened_json="$jqg_tmpdir/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$null_md5"
}
