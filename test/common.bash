#!/usr/bin/env bash

common_setup_file()
{
    # get the containing directory of this file
    # use $BATS_fileNAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    export script_dir="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    local filename=$(basename "$BATS_TEST_FILENAME")
    export filenum="${filename%%-*}"

    export PATH="$script_dir/../src:$script_dir:$PATH"

    # JSON test files
    export carnivora_json=$script_dir/carnivora.json
    export carnivora_md5=$(md5sum "$carnivora_json" | cut -d ' ' -f 1)

    export citrus_json=$script_dir/citrus.json
    export citrus_md5=$(md5sum "$citrus_json" | cut -d ' ' -f 1)

    export odd_values_json=$script_dir/odd-values.json
    export odd_values_md5=$(md5sum "$odd_values_json" | cut -d ' ' -f 1)

    export lorem_array_json=$script_dir/lorem-array.json
    export lorem_array_md5=$(md5sum "$lorem_array_json" | cut -d ' ' -f 1)

    export lorem_object_json=$script_dir/lorem-object.json
    export lorem_object_md5=$(md5sum "$lorem_object_json" | cut -d ' ' -f 1)

    export lorem_mixed_array_json=$script_dir/lorem-mixed-array.json
    export lorem_mixed_array_md5=$(md5sum "$lorem_mixed_array_json" | cut -d ' ' -f 1)

    export lorem_mixed_object_json=$script_dir/lorem-mixed-object.json
    export lorem_mixed_object_md5=$(md5sum "$lorem_mixed_object_json" | cut -d ' ' -f 1)

    export large_structure1_json=$script_dir/large-structure1.json
    export large_structure1_md5=$(md5sum "$large_structure1_json" | cut -d ' ' -f 1)

    export large_structure2_json=$script_dir/large-structure2.json
    export large_structure2_md5=$(md5sum "$large_structure2_json" | cut -d ' ' -f 1)

    export large_structure3_json=$script_dir/large-structure3.json
    export large_structure3_md5=$(md5sum "$large_structure3_json" | cut -d ' ' -f 1)

    export large_structure4_json=$script_dir/large-structure4.json
    export large_structure4_md5=$(md5sum "$large_structure4_json" | cut -d ' ' -f 1)

    export empty_array_md5="58e0494c51d30eb3494f7c9198986bb9"
    export empty_object_md5="8a80554c91d9fca8acb82f023de02f11"
    export null_md5="674441960ca1ba2de08ad4e50c9fde98"
}

common_teardown_file()
{
    :
}

common_setup()
{
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    load 'test_helper/bats-file/load'

    local testnum=$BATS_TEST_NUMBER
    local prefix

    printf -v prefix "[%03d] #%-2d - " "${filenum##0}" "$testnum"

    export BATS_TEST_NAME_PREFIX="$prefix"
}

common_teardown()
{
    :
}

make_temp_dir()
{
    export jqg_tmpdir="$(temp_make)"
    export BATSLIB_FILE_PATH_REM="#${jqg_tmpdir}"
    export BATSLIB_FILE_PATH_ADD='<temp>'

    export BATSLIB_TEMP_PRESERVE_ON_FAILURE=1

    bats_check
}

remove_temp_dir()
{
    if [[ -z "$JQG_BATS_SKIP_TEARDOWN" ]]; then
        rm -rf "$jqg_tmpdir"
    fi
}

parse_version_elements()
{
    local version
    local "${@}" >/dev/null

    # examples:
    # - Bash: 5.2.16(1)-release
    # - JQ: jq-1.6
    # - JQ: jq-1.6-137-gd18b2d0-dirty
    # - BATS: Bats 1.6.0

    # this is being run in a subshell (I think) so the following is OK
    shopt -s extglob

    local major minor patch remnant

    version=${version##*([^0-9])}          # rm before 1st set of nums

    major=${version%%[^0-9]*}              # rm after 1st set of nums
    remnant=${version##+([0-9])*([^0-9])}  # rm before 2nd set of nums

    minor=${remnant%%[^0-9]*}              # rm after 1st set of nums
    remnant=${remnant##+([0-9])*([^0-9])}  # rm before 2nd set of nums

    patch=${remnant%%[^0-9]*}              # rm after 1st set of nums

    # echo out assoc array-friendly string
    echo "( [major]=${major:-0} [minor]=${minor:-0} [patch]=${patch:-0} )"
}

check_version_number()
{
    local version target action name
    action="fail"

    local "${@}" >/dev/null

    declare -rA velems=$(parse_version_elements version="$version")
    declare -rA telems=$(parse_version_elements version="$target")

    local success=true

    if [[ ${velems[major]} -lt ${telems[major]} ]]; then
        success=false
    elif [[ ${velems[major]} -eq ${telems[major]} ]]; then
        if [[ ${velems[minor]} -lt ${telems[minor]} ]]; then
            success=false
        elif [[ ${velems[minor]} -eq ${telems[minor]} ]]; then
            if [[ ${velems[patch]} -lt ${telems[patch]} ]]; then
                success=false
            fi
        fi
    fi

    if [[ "$success" == "false" ]]; then
        if [[ "$action" == "fail" ]]; then
            cat <<EOF | fail
-- insufficient version --
minimum: $target
actual: $version
--
EOF
        else
            skip "Minimum $name version required: $target (actual: $version)"
        fi
    fi
}

bats_check() {
    check_version_number version="$BATS_VERSION" target="1.6.0" action="skip" name="Bats"
}
