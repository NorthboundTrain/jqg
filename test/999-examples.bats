#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/999-examples.bats
#----------------------------------------------------------------------
#--- this file is the source for the docs/jqg-examples.md file
#--- markdown file is created via test/gen-examples-md.pl
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



#==================================================================
## Search Criteria Examples

# case-insensitive search (default)
@test "case-insensitive search (default)" {
    run jqg Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
EOF
}


# case-sensitive search
@test "case-sensitive search" {
    run jqg -I Tiger $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.1.petname": "Tiger"
}
EOF
}


# search keys & values (default)
@test "search keys & values (default)" {
    run jqg king $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}


# search keys only
@test "search keys only" {
    run jqg -k king $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.kingdom": "animalia"
}
EOF
}


# search keys only
@test "search values only" {
    run jqg -v king $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.feral.0.aka": "king of the beasts"
}
EOF
}


# treat empty JSON arrays & objects as leaf nodes (default)
@test "treat empty JSON arrays & objects as leaf nodes (default)" {
    run jqg empty $odd_values_json
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
@test "exclude empty JSON arrays & objects as leaf nodes" {
    run jqg -E empty $odd_values_json
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
@test "print keys and values (default)" {
    run jqg feli $carnivora_json
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
@test "print just keys" {
    run jqg -K feli $carnivora_json
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
@test "print just values" {
    run jqg -V feli $carnivora_json
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
@test "print JSON output (default)" {
    run jqg -K feral $carnivora_json
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
@test "print raw output" {
    run jqg -r -K feral $carnivora_json
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
@test "use default key field separator (default: '.')" {
    run jqg feral $carnivora_json
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
@test "use alternate key field separator (':')" {
    run jqg -J feral $carnivora_json
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
@test "use arbitrary key field separator ('+')" {
    run jqg -j + feral $carnivora_json
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
@test "pipe output into JQG from curl" {
    run bash -c -o pipefail "curl -m 4 -s https://raw.githubusercontent.com/NorthboundTrain/jqg/main/test/odd-values.json | jqg -v '(?<!\d)0|\[\]'"

    #&&& IGNORE START
    if [[ $status -eq 28 ]]; then
        skip "curl connection timeout (behind proxy?)"
    fi
    #&&& IGNORE END

    assert_success
    assert_output - <<EOF
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
EOF
}

# use JQG in the middle
@test "use JQG in the middle" {
    run bash -c "jq . $carnivora_json | jqg feli | jq -S -c"
    assert_success
    assert_output - <<EOF
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
EOF
}

#==================================================================
## JQ Option Pass-Through Examples

# unsorted output (default)
@test "unsorted output (default)" {
    run jqg mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}


# sorted output
@test "sorted output" {
    run jqg -q -S mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}


# compact output
@test "compact output" {
    run jqg -q -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"isa":"mammal","classification.class":"mammalia"}
EOF
}


# compact & sorted output
@test "compact & sorted output" {
    run jqg -q -S -q -c mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}


# alternate compact & sorted output invocation
@test "alternate compact & sorted output invocation" {
    run jqg -q -Sc mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{"classification.class":"mammalia","isa":"mammal"}
EOF
}


# clear out pass-through options
@test "clear out pass-through options" {
    run jqg -q -S -q -c -Q mammal $carnivora_json
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
@test "set default JQG options - always sort output" {
    export JQG_OPTS="-q -S"
    run jqg mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
EOF
}


# override default JQG options (e.g. unsorted output)
@test "override default JQG options - show unsorted output" {
    export JQG_OPTS="-q -S"
    run jqg -Q mammal $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
EOF
}


# set default JQG options (e.g. join keys with '+')
@test "set default JQG options - join keys with '+'" {
    export JQG_OPTS="-j +"
    run jqg feral $carnivora_json
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
@test "override default JQG options - join keys with ':'" {
    export JQG_OPTS="-j +"
    run jqg -J feral $carnivora_json
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
@test "no filter, just flatten" {
    run jqg . $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.start-string": "foo",
  "one.null-value": null,
  "one.integer-number": 101,
  "one.string-with-pipe": "this|that",
  "one.key|with|pipe": true,
  "one.string-with-parens": "(this and that)",
  "one.key(with)parens": true,
  "one.bare-parens()": true,
  "one.left(paren-only": true,
  "one.unmatched-left)-paren": false,
  "one.dollar \$ign": "both-sides-\$now",
  "one.period-in-value": "hello.world",
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
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world",
  "five. leading space": "key",
  "five.trailing space ": "key",
  "five.  multi surround spaces   ": "key",
  "five.   ": "only spaces - key",
  "five.leading space": " value",
  "five.trailing space": "value ",
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  ",
  "end-string": "bar"
}
EOF
}


# flattened & sorted
@test "flattened & sorted" {
    run jqg -q -S . $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "end-string": "bar",
  "five.   ": "only spaces - key",
  "five.  multi surround spaces   ": "key",
  "five. leading space": "key",
  "five.leading space": " value",
  "five.multi surround spaces": "   value  ",
  "five.only spaces - value": "  ",
  "five.trailing space": "value ",
  "five.trailing space ": "key",
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world",
  "one.bare-parens()": true,
  "one.dollar \$ign": "both-sides-\$now",
  "one.integer-number": 101,
  "one.key(with)parens": true,
  "one.key|with|pipe": true,
  "one.left(paren-only": true,
  "one.null-value": null,
  "one.period-in-value": "hello.world",
  "one.start-string": "foo",
  "one.string-with-parens": "(this and that)",
  "one.string-with-pipe": "this|that",
  "one.unmatched-left)-paren": false,
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
@test "search keys, output values" {
    run jqg -k king -V $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "animalia"
]
EOF
}


# search values, ouput keys
@test "search values, output keys" {
    run jqg -v king -K $carnivora_json
    assert_success
    assert_output - <<EOF
[
  "cat.feral.0.aka"
]
EOF
}


# add debug example
@test "show JQG's JQ filter" {
    run jqg --debug breed test/carnivora.json
    assert_success
    assert_output - <<EOF
CMDLINE: "jq"   "<FILTER>" < "test/carnivora.json"

FILTER:
def empty_leafs:
    select(tostring | . == "{}" or . == "[]");

def flatten_json:
    . as \$data |
    [ path(.. | select((scalars|tostring), empty_leafs)) ] |
    map({ (map(tostring) | join(".")) : (. as \$path | . = \$data | getpath(\$path)) }) |
    reduce .[] as \$item ({ }; . + \$item);

def search_filter:
    to_entries |
    map(select(.[] | tostring | test("breed"; "i"))) |
    from_entries;

flatten_json | search_filter
EOF
}


# count results
@test "count results" {
    # a failed search without counting the results (default))
    run bash -c "jqg hippo test/carnivora.json && echo success || echo fail"
    assert_output - <<EOF
{}
success
EOF

    # a failed search counting the results (-N)
    run bash -c "jqg -N hippo test/carnivora.json && echo success || echo fail"
    assert_output - <<EOF
fail
EOF
}

#==================================================================
## Regex / PCRE Examples

# search for values containing numbers
@test "search for values containing numbers" {
    run jqg -v '\d+' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b",
  "four.3": 999
}
EOF
}


# search for values that start with a number
@test "search for values that start with a number" {
    run jqg -v '^-?\d+' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-2": "2b",
  "four.3": 999
}
EOF
}


# search for values that end with a number
@test "search for values that end with a number" {
    run jqg -v '\d+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1",
  "four.3": 999
}
EOF
}


# search for values that are numeric
@test "search for values that are numeric" {
    run jqg -v '^[-.\d]+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "four.3": 999
}
EOF
}


# search for integer values
@test "search for integer values" {
    run jqg -v '^\d+$' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.integer-number": 101,
  "two.0.two-a.number-zero": 0,
  "four.3": 999
}
EOF
}


# multiple search strings (simple)
@test "multiple search strings (simple)" {
    run jqg 'species|breed' $carnivora_json
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
@test "case insensitive multi-string value search" {
    run jqg -v 'f|M' $carnivora_json
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
@test "case insensitive multi-string value search with regex override for sub-expression" {
    skip "due to a bug in JQ's Oniguruma library, this requires a post 1.6 JQ build"
    run jqg -v 'f|(?-i:M)' $carnivora_json
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
@test "case sensitive multi-string value search" {
    run jqg -Iv 'f|M' $carnivora_json
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
@test "case sensitive multi-string value search with regex override for sub-expression" {
    run jqg -Iv 'f|(?i:M)' $carnivora_json
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


@test "search for pipe literal" {
    run jqg '\|' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.string-with-pipe": "this|that",
  "one.key|with|pipe": true
}
EOF
}


@test "search for parens (either)" {
    run jqg '\(|\)' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.string-with-parens": "(this and that)",
  "one.key(with)parens": true,
  "one.bare-parens()": true,
  "one.left(paren-only": true,
  "one.unmatched-left)-paren": false
}
EOF
}


@test "search for parens (both)" {
    run jqg '\(\)' $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one.bare-parens()": true
}
EOF
}


#==================================================================
## Unflatten Mode Examples

# flatten and unflatten JSON
@test "flatten and unflatten JSON" {
    # example of filtered, flattened output
    run jqg four $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world"
}
EOF

    # same output, unflattened
    run bash -c "jqg four $odd_values_json | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "four": [
    "first",
    null,
    {},
    999,
    "fourth",
    "hello.world"
  ]
}
EOF
}


# flatten and unflatten JSON containing sparse array
@test "flatten and unflatten JSON containing sparse array" {
    # example of filtered, flattened non-empty output
    run jqg -E four $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "four.0": "first",
  "four.1": null,
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world"
}
EOF

    # same output, unflattened
    run bash -c "jqg -E four $odd_values_json | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "four": [
    "first",
    null,
    null,
    999,
    "fourth",
    "hello.world"
  ]
}
EOF
}


# flatten and unflatten JSON using ^
@test "flatten and unflatten JSON using non-default join character" {
    # example of filtered, flattened output, keys joined with '^'
    run jqg -j ^ two $odd_values_json
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
    run bash -c "jqg -j ^ two $odd_values_json | jqg -u -j ^"
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
@test "flatten and unflatten JSON using JQG_OPTS" {
    # example of filtered, flattened output, keys joined with '+'
    export JQG_OPTS='-j +'
    run jqg two $odd_values_json
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
    run bash -c "jqg two $odd_values_json | jqg -u"
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


#==================================================================
## Extract Mode Examples

# simple extraction (jq vs. jqg -x)
@test "simple extraction" {
    # .cat selector in JQ
    run jq .cat $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "isa": "feline",
  "feral": [
    {
      "species": "lion",
      "aka": "king of the beasts"
    },
    {
      "species": "Bengal tiger"
    },
    {
      "species": "black-footed cat",
      "aka": "felis nigripes"
    }
  ],
  "domesticated": [
    {
      "petname": "Fluffy",
      "breed": "Bengal",
      "color": ""
    },
    {
      "petname": "Misty",
      "breed": "domestic short hair",
      "color": "yellow"
    }
  ]
}
EOF

    # same .cat selector, using JQG's extract mode
    run jqg -x .cat $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline",
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal",
        "color": ""
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  }
}
EOF
}

# multi-level extraction
@test "deeper extraction" {
    run jqg -x .cat.feral $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ]
  }
}
EOF
}

# array selector ( .cat.feral[1] )
@test "array selector (with sparse array)" {
    run jqg -x .cat.feral[1] $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "feral": [
      null,
      {
        "species": "Bengal tiger"
      }
    ]
  }
}
EOF
}

# multiple selectors
@test "multiple selectors" {
    run jqg -x .one,.three $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "one": {
    "start-string": "foo",
    "null-value": null,
    "integer-number": 101,
    "string-with-pipe": "this|that",
    "key|with|pipe": true,
    "string-with-parens": "(this and that)",
    "key(with)parens": true,
    "bare-parens()": true,
    "left(paren-only": true,
    "unmatched-left)-paren": false,
    "dollar \$ign": "both-sides-\$now",
    "period-in-value": "hello.world"
  },
  "three": {
    "empty-string": "",
    "empty-object": {},
    "empty-array": []
  }
}
EOF

    # the selector order can be reversed, changing the output
    run jqg -x .three,.one $odd_values_json
    assert_success
    assert_output - <<EOF
{
  "three": {
    "empty-string": "",
    "empty-object": {},
    "empty-array": []
  },
  "one": {
    "start-string": "foo",
    "null-value": null,
    "integer-number": 101,
    "string-with-pipe": "this|that",
    "key|with|pipe": true,
    "string-with-parens": "(this and that)",
    "key(with)parens": true,
    "bare-parens()": true,
    "left(paren-only": true,
    "unmatched-left)-paren": false,
    "dollar \$ign": "both-sides-\$now",
    "period-in-value": "hello.world"
  }
}
EOF
}

# overlapping selectors
@test "overlapping selectors" {
    # the first selector contains the second
    run jqg -x .cat,.cat.feral[1] $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "isa": "feline",
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal",
        "color": ""
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  }
}
EOF

    # when the second selector contains the first, the output order can be changed (though array order is not)
    run jqg -x .cat.feral[1],.cat $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "feral": [
      {
        "species": "lion",
        "aka": "king of the beasts"
      },
      {
        "species": "Bengal tiger"
      },
      {
        "species": "black-footed cat",
        "aka": "felis nigripes"
      }
    ],
    "isa": "feline",
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal",
        "color": ""
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  }
}
EOF
}

# extract can take flat or structured input
@test "extract from flattened input" {
    run bash -c "jqg . $carnivora_json | jqg -x .dog"
    assert_success
    assert_output - <<EOF
{
  "dog": [
    {
      "petname": "Growler",
      "breed": "mutt"
    },
    {
      "petname": "Tiger",
      "breed": "yellow labrador",
      "feral": true,
      "type": "domesticated"
    },
    {}
  ]
}
EOF
}

# nonexistent selector
@test "nonexistent selector" {
    run jqg -x .dolphin $carnivora_json
    assert_success
    assert_output - <<EOF
null
EOF
}

# note: this is broken into two asserts because of a bug in my editor that
#       strips trailing whitespace even inside of a multi-line string; its
#       output in jqg-examples.md looks fine, though

# invalid selector
@test "invalid selector" {
    run jqg -x dog $carnivora_json
    assert_failure
    assert_output --partial - <<EOF
jq: error: dog/0 is not defined at <top-level>, line 7:
    path(dog) as \$selector_path | tostream |
EOF
    assert_output --partial - <<EOF
jq: 1 compile error
EOF
}

# mismatched selector - line number will change as JSON shrinks/grows
@test "mismatched selector" {
    run jqg -x .[0] $carnivora_json
    assert_failure
    assert_output - <<EOF
jq: error (at <stdin>:53): Cannot index object with number
EOF
}


#==================================================================
## Composite Search Examples

# search & unflatten
@test "search with unflattened results" {
    # normal search
    run jqg breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF

    # same search, with unflattened results (using -U)
    run jqg -U breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF

    # same search & results (using jqu)
    run jqu breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF

    # same search & results (with output transformation)
    # (this is actually how the -U option is implemented)
    run jqg breed -t unflatten $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF

    # same search & results (via pipeline)
    run bash -c "jqg breed $carnivora_json | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF
}


# extract & search
@test "extract and search" {
    # normal search (without extract)
    run jqg breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF

    # extract .dog, then search (using -X)
    run jqg -X .dog breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF

    # same extract & search (using jqx)
    run jqx .dog breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF
}

#==================================================================
## Input/Output Transformation Examples

# search & unflatten
@test "simple search, with unflattened results" {
    # normal search
    run jqg breed $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
EOF

    # same search & results unflattened via output transformation
    # (this is actually how the -U option is implemented)
    run jqg breed -t unflatten $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "cat": {
    "domesticated": [
      {
        "breed": "Bengal"
      },
      {
        "breed": "domestic short hair"
      }
    ]
  },
  "dog": [
    {
      "breed": "mutt"
    },
    {
      "breed": "yellow labrador"
    }
  ]
}
EOF
}

# extract & flatten (jqg -x .dog -t flatten)
@test "extract with flattened results" {
    # normal extract
    run jqg -x .dog $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog": [
    {
      "petname": "Growler",
      "breed": "mutt"
    },
    {
      "petname": "Tiger",
      "breed": "yellow labrador",
      "feral": true,
      "type": "domesticated"
    },
    {}
  ]
}
EOF

    # same extract flattened via output transformation
    run jqg -x .dog -t flatten $carnivora_json
    assert_success
    assert_output - <<EOF
{
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
EOF
}
