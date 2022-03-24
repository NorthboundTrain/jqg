setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'


    # require 1.6.0 or later
    batsver=( "${BATS_VERSION//./ }" )
    if [[ ((${batsver[0]} -eq 1) && (${batsver[1]} -lt 6)) || (${batsver[0]} -lt 1) ]]; then
        skip "Minimum Bats version required: 1.6.0 (running: $BATS_VERSION)"
    fi

    BATSLIB_TEMP_PRESERVE_ON_FAILURE=1

    MY_TEST_TEMP_DIR="$(temp_make)"
    BATSLIB_FILE_PATH_REM="#${MY_TEST_TEMP_DIR}"
    BATSLIB_FILE_PATH_ADD='<temp>'
}


setup_file() {
    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    export DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    export PATH="$DIR/../src:$PATH"

    export CARNIVORA_JSON=$DIR/carnivora.json
    export CARNIVORA_MD5=$(md5sum "$CARNIVORA_JSON" | cut -d ' ' -f 1)

    export CITRUS_JSON=$DIR/citrus.json
    export CITRUS_MD5=$(md5sum "$CITRUS_JSON" | cut -d ' ' -f 1)

    export ODD_VALUES_JSON=$DIR/odd-values.json
    export ODD_VALUES_MD5=$(md5sum "$ODD_VALUES_JSON" | cut -d ' ' -f 1)
}


# flatten JSON & unflatten JSON - check md5sum (carnivora)
@test "[70] round trip - carnivora" {
    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg . "$CARNIVORA_JSON" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$CARNIVORA_MD5"

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$CARNIVORA_MD5"
}



# flatten JSON & unflatten JSON - check md5sum (citrus)
@test "[70] round trip - citrus" {
    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg . "$CITRUS_JSON" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$CITRUS_MD5"

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$CITRUS_MD5"
}



# flatten JSON & unflatten JSON - check md5sum (odd-values)
@test "[70] round trip - odd-values" {
    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg . "$ODD_VALUES_JSON" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$ODD_VALUES_MD5"

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$ODD_VALUES_MD5"
}



# flatten JSON & unflatten JSON using '+' via JQG_OPTS- check md5sum (citrus)
@test "[70] round trip with -j + via JQG_OPTS - citrus" {
    jplus_flat_json="$MY_TEST_TEMP_DIR/jplus_flat.json"
    jqg -j + . "$CITRUS_JSON" >"$jplus_flat_json"
    jplus_md5=$(md5sum "$jplus_flat_json" | cut -d ' ' -f 1)

    assert_not_equal "$jplus_md5" "$CITRUS_MD5"

    export JQG_OPTS='-j +'
    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg . "$CITRUS_JSON" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$CITRUS_MD5"
    assert_equal "$flat_md5" "$jplus_md5"

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$CITRUS_MD5"
}



# flatten JSON & unflatten JSON via pipeline - check md5sum (carnivora)
@test "[70] round trip pipeline - carnivora" {
    pipeline_md5=$(jqg . "$CARNIVORA_JSON" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$CARNIVORA_MD5"
}



# flatten JSON & unflatten JSON via pipeline - check md5sum (citrus)
@test "[70] round trip pipeline - citrus" {
    pipeline_md5=$(jqg . "$CITRUS_JSON" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$CITRUS_MD5"
}



# flatten JSON & unflatten JSON via pipeline - check md5sum (odd-values)
@test "[70] round trip pipeline - odd-values" {
    pipeline_md5=$(jqg . "$ODD_VALUES_JSON" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$ODD_VALUES_MD5"
}



# flatten JSON and unflatten with -q -S (carnivora)
@test "[70] round-trip pipeline with [-q -S] - carnivora" {
    jqs_md5=$(jq -S . "$CARNIVORA_JSON" | md5sum | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$CARNIVORA_JSON" | jqg -q -S -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$jqs_md5"
}



# flatten JSON and unflatten with -q -S (citrus)
@test "[70] round-trip pipeline with [-q -S] - citrus" {
    jqs_md5=$(jq -S . "$CITRUS_JSON" | md5sum | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$CITRUS_JSON" | jqg -q -S -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$jqs_md5"
}



# flatten JSON and unflatten with -q -S (odd-values)
@test "[70] round-trip pipeline with [-q -S] - odd-values" {
    jqs_md5=$(jq -S . "$ODD_VALUES_JSON" | md5sum | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$ODD_VALUES_JSON" | jqg -q -S -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$jqs_md5"
}



# array-based results
@test "[70] array-based results" {
    orig_json="$MY_TEST_TEMP_DIR/unflattened.json"
    cat <<EOJ >"$orig_json"
[
  {
    "laboris": {
      "aliquip": "officia"
    },
    "aliqua": true
  },
  {
    "pariatur": [
      "enim"
    ]
  }
]
EOJ
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    unflattened_md5=$(jqg . "$orig_json" | md5sum | cut -d ' ' -f 1)
    assert_not_equal "$unflattened_md5" "$orig_md5"

    pipeline_md5=$(jqg . "$orig_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}



make_problematic_key_json()
{
    filename=${1:?missing filename}; shift || true
    sep_char=${1:-.}; shift || true

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
@test "[70] problematic keys (round trip fail)" {
    orig_json="$MY_TEST_TEMP_DIR/problematic.json"
    make_problematic_key_json "$orig_json"
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$orig_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_not_equal "$pipeline_md5" "$orig_md5"
}



# flatten JSON with : in key & unflatten - should be same
@test "[70] problematic keys - colon (round trip OK)" {
    orig_json="$MY_TEST_TEMP_DIR/problematic.json"
    make_problematic_key_json "$orig_json" ":"
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg . "$orig_json" | jqg -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}



# flatten JSON with . in key using -J & unflatten using -J - should be same
@test "[70] problematic keys - period / -J (round trip OK)" {
    orig_json="$MY_TEST_TEMP_DIR/problematic.json"
    make_problematic_key_json "$orig_json" "."
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg -J . "$orig_json" | jqg -J -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}



# flatten JSON with . in key using -j + & unflatten using -j + - should be same
@test "[70] problematic keys - period / -j + (round trip OK)" {
    orig_json="$MY_TEST_TEMP_DIR/problematic.json"
    make_problematic_key_json "$orig_json" "."
    orig_md5=$(md5sum "$orig_json" | cut -d ' ' -f 1)

    pipeline_md5=$(jqg -j + . "$orig_json" | jqg -j + -u | md5sum | cut -d ' ' -f 1)
    assert_equal "$pipeline_md5" "$orig_md5"
}



make_sparse_array_json()
{
    filename=${1:?missing filename}; shift || true
    empty=${1:-true}; shift || true

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
@test "[70] sparse array generation" {
    empty_json="$MY_TEST_TEMP_DIR/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    null_json="$MY_TEST_TEMP_DIR/null.json"
    make_sparse_array_json "$null_json" "false"
    null_md5=$(jq . "$null_json" | md5sum| cut -d ' ' -f 1)

    assert_not_equal "$null_md5" "$empty_md5"
}



# sparse array
@test "[70] sparse array - round trip OK" {
    empty_json="$MY_TEST_TEMP_DIR/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg . "$empty_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$empty_md5"

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$empty_md5"
}



# sparse array w/ -E (fail)
@test "[70] sparse array [-E] - round trip fail" {
    empty_json="$MY_TEST_TEMP_DIR/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg -E . "$empty_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$unflat_md5" "$empty_md5"
    assert_not_equal "$unflat_md5" "$flat_md5"
}



# sparse array w/ -E (OK)
@test "[70] sparse array [-E] - round trip OK" {
    empty_json="$MY_TEST_TEMP_DIR/empty.json"
    make_sparse_array_json "$empty_json" "true"
    empty_md5=$(jq . "$empty_json" | md5sum | cut -d ' ' -f 1)

    null_json="$MY_TEST_TEMP_DIR/null.json"
    make_sparse_array_json "$null_json" "false"
    null_md5=$(jq . "$null_json" | md5sum| cut -d ' ' -f 1)

    flattened_json="$MY_TEST_TEMP_DIR/flattened.json"
    jqg -E . "$empty_json" >"$flattened_json"
    flat_md5=$(md5sum "$flattened_json" | cut -d ' ' -f 1)

    assert_not_equal "$flat_md5" "$empty_md5"
    assert_not_equal "$flat_md5" "$null_md5"

    unflattened_json="$MY_TEST_TEMP_DIR/unflattened.json"
    jqg -u "$flattened_json" >"$unflattened_json"
    unflat_md5=$(md5sum "$unflattened_json" | cut -d ' ' -f 1)

    assert_equal "$unflat_md5" "$null_md5"
}



# invalid flattened JSON - top-level object mixed with array
@test "[70] invalid flat - top-level obj with array" {
    invalid_json="$MY_TEST_TEMP_DIR/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "occaecat.dolor": "voluptate",
  "0.quis": true,
  "incididunt.0": "duis"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure
    assert_output --partial "Cannot index object with number"
}



# invalid flattened JSON - top-level array mixed with object
@test "[70] invalid flat - top-level array with obj" {
    invalid_json="$MY_TEST_TEMP_DIR/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "0.quis": true,
  "occaecat.dolor": "voluptate",
  "incididunt.0": "duis"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure
    assert_output --partial "Cannot index array with string"
}



# invalid flattened JSON - interior object mixed with array
@test "[70] invalid flat - interior obj with array" {
    invalid_json="$MY_TEST_TEMP_DIR/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "cillum.amet": "anim",
  "nisi.old.adipisicing": true,
  "nisi.0.adipisicing": true,
  "incididunt.0": "culpa"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure
    assert_output --partial "Cannot index object with number"
}



# invalid flattened JSON - interioir array mixed with object
@test "[70] invalid flat - interior array with obj" {
    invalid_json="$MY_TEST_TEMP_DIR/invalid.json"
    cat <<EOJ >"$invalid_json"
{
  "cillum.amet": "anim",
  "nisi.0.adipisicing": true,
  "nisi.old.adipisicing": true,
  "incididunt.0": "culpa"
}
EOJ

    run jqg -u "$invalid_json"
    assert_failure
    assert_output --partial "Cannot index array with string"
}



# round-trip failure - numeric object keys
@test "[70] round-trip failure - numeric object keys" {
    orig_json="$MY_TEST_TEMP_DIR/orig.json"
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
