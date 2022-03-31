# some input values are hard to deal with: null, "", {}, [], false


setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    # load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"

    CARNIVORA_JSON=$DIR/carnivora.json
}



# pipeline in
@test "[52] pipeline in" {
    run  bash -c "jq . $CARNIVORA_JSON | jqg feli"
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}

# pipeline in
@test "[52] pipeline out" {
    run  bash -c "jqg feli $CARNIVORA_JSON | jq -S -c"
    assert_success
    assert_output - <<EOF
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
EOF
}

# pipeline in
@test "[52] pipeline middle" {
    run  bash -c "jq . $CARNIVORA_JSON | jqg feli | jq -S -c"
    assert_success
    assert_output - <<EOF
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
EOF
}
