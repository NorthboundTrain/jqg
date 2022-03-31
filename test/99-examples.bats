# this file is the source for the doc/jqg-examples.md file


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
    ODD_VALUES_JSON=$DIR/odd-values.json
}


#==================================================================
## Search Criteria Examples

# case-insensitive search (default)
@test "[99] case-insensitive search (default)" {
    run  jqg Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}


# case-sensitive search
@test "[99] case-sensitive search" {
    run  jqg -I Tiger $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}


# search keys & values (default)
@test "[99] search keys & values (default)" {
    run  jqg king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}


# search keys only
@test "[99] search keys only" {
    run  jqg -k king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia"
}
EOF
}


# search keys only
@test "[99] search values only" {
    run  jqg -v king $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}


# treat empty JSON arrays & objects as leaf nodes (default)
@test "[99] treat empty JSON arrays & objects as leaf nodes (default)" {
    run  jqg empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
EOF
}


# exclude empty JSON arrays & objects as leaf nodes
@test "[99] exclude empty JSON arrays & objects as leaf nodes" {
    run  jqg -E empty $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "three.empty-string": ""
}
EOF
}

#==================================================================
## Output Examples

# print keys and values (default)
@test "[99] print keys and values (default)" {
    run  jqg feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
EOF
}


# print just keys
@test "[99] print just keys" {
    run  jqg -K feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "subclades.0",
  "cat.isa",
  "cat.feral.2.aka"
]
EOF
}


# print just values
@test "[99] print just values" {
    run  jqg -V feli $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "feliformia",
  "feline",
  "felis nigripes"
]
EOF
}


# print JSON output (default)
@test "[99] print JSON output (default)" {
    run  jqg -K feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "cat.feral.0.species",
  "cat.feral.0.aka",
  "cat.feral.1.species",
  "cat.feral.2.species",
  "cat.feral.2.aka",
  "dog.1.feral"
]
EOF
}


# print raw output
@test "[99] print raw output" {
    run  jqg -r -K feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
cat.feral.0.species
cat.feral.0.aka
cat.feral.1.species
cat.feral.2.species
cat.feral.2.aka
dog.1.feral
EOF
}


# use default key field separator (default: '.')
@test "[99] use default key field separator (default: '.')" {
    run  jqg feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "dog.1.feral": true
}
EOF
}


# use alternate key field separator (':')
@test "[99] use alternate key field separator (':')" {
    run  jqg -J feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat:feral:0:species": "lion",
  "cat:feral:0:aka": "king of the beasts",
  "cat:feral:1:species": "Bengal tiger",
  "cat:feral:2:species": "black-footed cat",
  "cat:feral:2:aka": "felis nigripes",
  "dog:1:feral": true
}
EOF
}


# use arbitrary key field separator ('+')
@test "[99] use arbitrary key field separator ('+')" {
    run  jqg -j + feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat+feral+0+species": "lion",
  "cat+feral+0+aka": "king of the beasts",
  "cat+feral+1+species": "Bengal tiger",
  "cat+feral+2+species": "black-footed cat",
  "cat+feral+2+aka": "felis nigripes",
  "dog+1+feral": true
}
EOF
}


#==================================================================
## Pipeline Examples

# pipe output into JQG from curl
@test "[99] pipe output into JQG from curl" {
    run  bash -c "curl -s https://raw.githubusercontent.com/NorthboundTrain/jqg/main/test/odd-values.json | jqg -v '(?<!\d)0|\[\]'"
    assert_success
    assert_output - <<EOF
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
EOF
}

# use JQG in the middle
@test "[99] use JQG in the middle" {
    run  bash -c "jq . $CARNIVORA_JSON | jqg feli | jq -S -c"
    assert_success
    assert_output - <<EOF
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
EOF
}

#==================================================================
## JQ Option Pass-Through Examples

# unsorted output (default)
@test "[99] unsorted output (default)" {
    run  jqg mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}


# sorted output
@test "[99] sorted output" {
    run  jqg -q -S mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}


# compact output
@test "[99] compact output" {
    run  jqg -q -c mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}


# compact & sorted output
@test "[99] compact & sorted output" {
    run  jqg -q -S -q -c mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}


# alternate compact & sorted output invocation
@test "[99] alternate compact & sorted output invocation" {
    run  jqg -q -Sc mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}


# clear out pass-through options
@test "[99] clear out pass-through options" {
    run  jqg -q -S -q -c -Q mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}


#==================================================================
## Miscellaneous Examples

# set default JQG options (e.g. always sort output)
@test "[99] set default JQG options (e.g. always sort output)" {
    export JQG_OPTS="-q -S"
    run  jqg mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}


# override default JQG options (e.g. unsorted output)
@test "[99] override default JQG options (e.g. unsorted output)" {
    export JQG_OPTS="-q -S"
    run  jqg -Q mammal $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}


# set default JQG options (e.g. join keys with '+')
@test "[99] set default JQG options (e.g. join keys with '+')" {
    export JQG_OPTS="-j +"
    run  jqg feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat+feral+0+species": "lion",
  "cat+feral+0+aka": "king of the beasts",
  "cat+feral+1+species": "Bengal tiger",
  "cat+feral+2+species": "black-footed cat",
  "cat+feral+2+aka": "felis nigripes",
  "dog+1+feral": true
}
EOF
}


# override default JQG options (e.g. join keys with ':')
@test "[99] override default JQG options (e.g. join keys with ':')" {
    export JQG_OPTS="-j +"
    run  jqg -J feral $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat:feral:0:species": "lion",
  "cat:feral:0:aka": "king of the beasts",
  "cat:feral:1:species": "Bengal tiger",
  "cat:feral:2:species": "black-footed cat",
  "cat:feral:2:aka": "felis nigripes",
  "dog:1:feral": true
}
EOF
}


# no filter, just flatten
@test "[99] no filter, just flatten" {
    run  jqg . $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.start-string": "foo",
  "one.null-value": null,
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.0.true-boolean": true,
  "two.0.two-b.false-boolean": false,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b",
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": [],
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": "fourth",
  "end-string": "bar"
}
EOF
}


# flattened & sorted
@test "[99] flattened & sorted" {
    run  jqg -q -S . $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "end-string": "bar",
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": "fourth",
  "one.integer-number": 101,
  "one.null-value": null,
  "one.start-string": "foo",
  "three.empty-array": [],
  "three.empty-object": {},
  "three.empty-string": "",
  "two.0.true-boolean": true,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.0.two-b.false-boolean": false,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b"
}
EOF
}


# search keys, ouput values
@test "[99] search keys, output values" {
    run jqg -k king -V $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "animalia"
]
EOF
}

# search values, ouput keys
@test "[99] search values, output keys" {
    run jqg -v king -K $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
[
  "cat.feral.0.aka"
]
EOF
}

#==================================================================
## Regex / PCRE Examples


# search for values containing numbers
@test "[99] search for values containing numbers" {
    run  jqg -v '\d+' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b"
}
EOF
}


# search for values that start with a number
@test "[99] search for values that start with a number" {
    run  jqg -v '^-?\d+' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-2": "2b"
}
EOF
}


# search for values that end with a number
@test "[99] search for values that end with a number" {
    run  jqg -v '\d+$' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1"
}
EOF
}


# search for values that are numeric
@test "[99] search for values that are numeric" {
    run  jqg -v '^[-.\d]+$' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0
}
EOF
}


# search for integer values
@test "[99] search for integer values" {
    run  jqg -v '^\d+$' $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.number-zero": 0
}
EOF
}


# multiple search strings (simple)
@test "[99] multiple search strings (simple)" {
    run  jqg 'species|breed' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}


# case insensitive multi-string value search
@test "[99] case insensitive multi-string value search" {
    run  jqg -v 'f|M' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.type": "domesticated"
}
EOF
}


# case insensitive multi-string value search with regex override for sub-expression
@test "[99] case insensitive multi-string value search with regex override for sub-expression" {
    skip "due to a bug in JQ's Oniguruma library, this requires a post 1.6 JQ build"
    run  jqg -v 'f|(?-i:M)' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}


# case sensitive multi-string value search
@test "[99] case sensitive multi-string value search" {
    run  jqg -Iv 'f|M' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty"
}
EOF
}


# case sensitive multi-string value search with regex override for sub-expression
@test "[99] case sensitive multi-string value search with regex override for sub-expression" {
    run  jqg -Iv 'f|(?i:M)' $CARNIVORA_JSON
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.kingdom": "animalia",
  "classification.class": "mammalia",
  "subclades.0": "feliformia",
  "subclades.1": "caniformia",
  "cat.isa": "feline",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.type": "domesticated"
}
EOF
}


#==================================================================
## Unflatten Mode Examples

# flatten and unflatten JSON
@test "[99] flatten and unflatten JSON" {
    # example of filtered, flattened output
    run  jqg four $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": "fourth"
}
EOF

    # same output, unflattened
    run bash -c "jqg four $ODD_VALUES_JSON | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "four": [
    "first",
    null,
    {},
    "fourth"
  ]
}
EOF
}


# flatten and unflatten JSON containing sparse array
@test "[99] flatten and unflatten JSON containing sparse array" {
    # example of filtered, flattened non-empty output
    run  jqg -E four $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.3": "fourth"
}
EOF

    # same output, unflattened
    run bash -c "jqg -E four $ODD_VALUES_JSON | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "four": [
    "first",
    null,
    null,
    "fourth"
  ]
}
EOF
}


# flatten and unflatten JSON using ^
@test "[99] flatten and unflatten JSON using non-default join character" {
    # example of filtered, flattened output, keys joined with '^'
    run  jqg -j ^ two $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "two^0^two-a^non-integer-number": -101.75,
  "two^0^two-a^number-zero": 0,
  "two^0^true-boolean": true,
  "two^0^two-b^false-boolean": false,
  "two^1^two-c^alpha-num-1": "a1",
  "two^1^two-c^alpha-num-2": "2b",
  "two^1^two-c^alpha-num-3": "a12b"
}
EOF

    # same output, unflattened
    run bash -c "jqg -j ^ two $ODD_VALUES_JSON | jqg -u -j ^"
    assert_success
    assert_output - <<EOF
{
  "two": [
    {
      "two-a": {
        "non-integer-number": -101.75,
        "number-zero": 0
      },
      "true-boolean": true,
      "two-b": {
        "false-boolean": false
      }
    },
    {
      "two-c": {
        "alpha-num-1": "a1",
        "alpha-num-2": "2b",
        "alpha-num-3": "a12b"
      }
    }
  ]
}
EOF
}


# flatten and unflatten JSON using +
@test "[99] flatten and unflatten JSON using JQG_OPTS" {
    # example of filtered, flattened output, keys joined with '+'
    export JQG_OPTS='-j +'
    run  jqg two $ODD_VALUES_JSON
    assert_success
    assert_output - <<EOF
{
  "two+0+two-a+non-integer-number": -101.75,
  "two+0+two-a+number-zero": 0,
  "two+0+true-boolean": true,
  "two+0+two-b+false-boolean": false,
  "two+1+two-c+alpha-num-1": "a1",
  "two+1+two-c+alpha-num-2": "2b",
  "two+1+two-c+alpha-num-3": "a12b"
}
EOF

    # same output, unflattened
    export JQG_OPTS='-j +'
    run bash -c "jqg two $ODD_VALUES_JSON | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "two": [
    {
      "two-a": {
        "non-integer-number": -101.75,
        "number-zero": 0
      },
      "true-boolean": true,
      "two-b": {
        "false-boolean": false
      }
    },
    {
      "two-c": {
        "alpha-num-1": "a1",
        "alpha-num-2": "2b",
        "alpha-num-3": "a12b"
      }
    }
  ]
}
EOF
}
