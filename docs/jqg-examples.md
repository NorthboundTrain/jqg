# `jqg` Examples

There are three modes that can be invoked: search, unflatten, and extract. Most of the examples are for the search mode, though many of them can also be applied in pieces to the other two modes. There are also two composite modes each with their own script, search with unflattened results (`jqu`) and extract then search (`jqx`); both have examples shown below.

[//]: # (------------------------------------------------------------------)
[//]: # (--- NOTE: this file is generated using the gen-examples-md.pl   --)
[//]: # (--- script and should not be edited directly                    --)
[//]: # (------------------------------------------------------------------)

*-- sample JSON - used for examples below --*

[//]: # (==================================================================)
<details>
<summary>carnivora.json</summary>

```json
{
  "isa": "mammal",
  "classification": {
    "kingdom": "animalia",
    "phylum": "chordata",
    "class": "mammalia"
  },
  "subclades": [
    "feliformia",
    "caniformia"
  ],
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
  },
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
```

</details>

<details>
<summary>odd-values.json</summary>

```json
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
    "dollar $ign": "both-sides-$now",
    "period-in-value": "hello.world"
  },
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
  ],
  "three": {
    "empty-string": "",
    "empty-object": {},
    "empty-array": []
  },
  "four": [
    "first",
    null,
    {},
    999,
    "fourth",
    "hello.world"
  ],
  "five": {
    " leading space": "key",
    "trailing space ": "key",
    "  multi surround spaces   ": "key",
    "   ": "only spaces - key",
    "leading space": " value",
    "trailing space": "value ",
    "multi surround spaces": "   value  ",
    "only spaces - value": "  "
  },
  "end-string": "bar"
}
```

</details>

[//]: # (==================================================================)

## Search Criteria Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>case-insensitive search (default)</summary>

```bash
$ jqg Tiger carnivora.json
{
  "cat.feral.1.species": "Bengal tiger",
  "dog.1.petname": "Tiger"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>case-sensitive search</summary>

```bash
$ jqg -I Tiger carnivora.json
{
  "dog.1.petname": "Tiger"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search keys & values (default)</summary>

```bash
$ jqg king carnivora.json
{
  "classification.kingdom": "animalia",
  "cat.feral.0.aka": "king of the beasts"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search keys only</summary>

```bash
$ jqg -k king carnivora.json
{
  "classification.kingdom": "animalia"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search values only</summary>

```bash
$ jqg -v king carnivora.json
{
  "cat.feral.0.aka": "king of the beasts"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>treat empty JSON arrays & objects as leaf nodes (default)</summary>

```bash
$ jqg empty odd-values.json
{
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": []
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>exclude empty JSON arrays & objects as leaf nodes</summary>

```bash
$ jqg -E empty odd-values.json
{
  "three.empty-string": ""
}
```

</details>

[//]: # (==================================================================)

## Output Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>print keys and values (default)</summary>

```bash
$ jqg feli carnivora.json
{
  "subclades.0": "feliformia",
  "cat.isa": "feline",
  "cat.feral.2.aka": "felis nigripes"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>print just keys</summary>

```bash
$ jqg -K feli carnivora.json
[
  "subclades.0",
  "cat.isa",
  "cat.feral.2.aka"
]
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>print just values</summary>

```bash
$ jqg -V feli carnivora.json
[
  "feliformia",
  "feline",
  "felis nigripes"
]
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>print JSON output (default)</summary>

```bash
$ jqg -K feral carnivora.json
[
  "cat.feral.0.species",
  "cat.feral.0.aka",
  "cat.feral.1.species",
  "cat.feral.2.species",
  "cat.feral.2.aka",
  "dog.1.feral"
]
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>print raw output</summary>

```bash
$ jqg -r -K feral carnivora.json
cat.feral.0.species
cat.feral.0.aka
cat.feral.1.species
cat.feral.2.species
cat.feral.2.aka
dog.1.feral
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>use default key field separator (default: '.')</summary>

```bash
$ jqg feral carnivora.json
{
  "cat.feral.0.species": "lion",
  "cat.feral.0.aka": "king of the beasts",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.feral.2.aka": "felis nigripes",
  "dog.1.feral": true
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>use alternate key field separator (':')</summary>

```bash
$ jqg -J feral carnivora.json
{
  "cat:feral:0:species": "lion",
  "cat:feral:0:aka": "king of the beasts",
  "cat:feral:1:species": "Bengal tiger",
  "cat:feral:2:species": "black-footed cat",
  "cat:feral:2:aka": "felis nigripes",
  "dog:1:feral": true
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>use arbitrary key field separator ('+')</summary>

```bash
$ jqg -j + feral carnivora.json
{
  "cat+feral+0+species": "lion",
  "cat+feral+0+aka": "king of the beasts",
  "cat+feral+1+species": "Bengal tiger",
  "cat+feral+2+species": "black-footed cat",
  "cat+feral+2+aka": "felis nigripes",
  "dog+1+feral": true
}
```

</details>

[//]: # (==================================================================)

## Pipeline Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>pipe output into JQG from curl</summary>

```bash
$ curl -m 4 -s https://raw.githubusercontent.com/NorthboundTrain/jqg/main/test/odd-values.json | jqg -v '(?<!\d)0|\[\]'
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>use JQG in the middle</summary>

```bash
$ jq . carnivora.json | jqg feli | jq -S -c
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
```

</details>

[//]: # (==================================================================)

## JQ Option Pass-Through Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>unsorted output (default)</summary>

```bash
$ jqg mammal carnivora.json
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>sorted output</summary>

```bash
$ jqg -q -S mammal carnivora.json
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>compact output</summary>

```bash
$ jqg -q -c mammal carnivora.json
{"isa":"mammal","classification.class":"mammalia"}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>compact & sorted output</summary>

```bash
$ jqg -q -S -q -c mammal carnivora.json
{"classification.class":"mammalia","isa":"mammal"}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>alternate compact & sorted output invocation</summary>

```bash
$ jqg -q -Sc mammal carnivora.json
{"classification.class":"mammalia","isa":"mammal"}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>clear out pass-through options</summary>

```bash
$ jqg -q -S -q -c -Q mammal carnivora.json
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
```

</details>

[//]: # (==================================================================)

## Miscellaneous Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>set default JQG options - always sort output</summary>

```bash
$ export JQG_OPTS="-q -S"
$ jqg mammal carnivora.json
{
  "classification.class": "mammalia",
  "isa": "mammal"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>override default JQG options - show unsorted output</summary>

```bash
$ export JQG_OPTS="-q -S"
$ jqg -Q mammal carnivora.json
{
  "isa": "mammal",
  "classification.class": "mammalia"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>set default JQG options - join keys with '+'</summary>

```bash
$ export JQG_OPTS="-j +"
$ jqg feral carnivora.json
{
  "cat+feral+0+species": "lion",
  "cat+feral+0+aka": "king of the beasts",
  "cat+feral+1+species": "Bengal tiger",
  "cat+feral+2+species": "black-footed cat",
  "cat+feral+2+aka": "felis nigripes",
  "dog+1+feral": true
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>override default JQG options - join keys with ':'</summary>

```bash
$ export JQG_OPTS="-j +"
$ jqg -J feral carnivora.json
{
  "cat:feral:0:species": "lion",
  "cat:feral:0:aka": "king of the beasts",
  "cat:feral:1:species": "Bengal tiger",
  "cat:feral:2:species": "black-footed cat",
  "cat:feral:2:aka": "felis nigripes",
  "dog:1:feral": true
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>no filter, just flatten</summary>

```bash
$ jqg . odd-values.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>flattened & sorted</summary>

```bash
$ jqg -q -S . odd-values.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search keys, output values</summary>

```bash
$ jqg -k king -V carnivora.json
[
  "animalia"
]
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search values, output keys</summary>

```bash
$ jqg -v king -K carnivora.json
[
  "cat.feral.0.aka"
]
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>show JQG's JQ filter</summary>

```bash
$ jqg --debug breed test/carnivora.json
CMDLINE: "${JQ_BIN:-jq}"   "<FILTER>" < "test/carnivora.json"

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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>count results</summary>

```bash
# a failed search without counting the results (default))
$ jqg hippo test/carnivora.json && echo success || echo fail
{}
success

# a failed search counting the results (-N)
$ jqg -N hippo test/carnivora.json && echo success || echo fail
fail
```

</details>

[//]: # (==================================================================)

## Regex / PCRE Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values containing numbers</summary>

```bash
$ jqg -v '\d+' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b",
  "four.3": 999
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values that start with a number</summary>

```bash
$ jqg -v '^-?\d+' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-2": "2b",
  "four.3": 999
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values that end with a number</summary>

```bash
$ jqg -v '\d+$' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1",
  "four.3": 999
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values that are numeric</summary>

```bash
$ jqg -v '^[-.\d]+$' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": -101.75,
  "two.0.two-a.number-zero": 0,
  "four.3": 999
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for integer values</summary>

```bash
$ jqg -v '^\d+$' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.number-zero": 0,
  "four.3": 999
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>multiple search strings (simple)</summary>

```bash
$ jqg 'species|breed' carnivora.json
{
  "cat.feral.0.species": "lion",
  "cat.feral.1.species": "Bengal tiger",
  "cat.feral.2.species": "black-footed cat",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>case insensitive multi-string value search</summary>

```bash
$ jqg -v 'f|M' carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>case insensitive multi-string value search with regex override for sub-expression (JQ 1.7+)</summary>

```bash
$ jqg -v 'f|(?-i:M)' carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>case sensitive multi-string value search</summary>

```bash
$ jqg -Iv 'f|M' carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>case sensitive multi-string value search with regex override for sub-expression</summary>

```bash
$ jqg -Iv 'f|(?i:M)' carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for pipe literal</summary>

```bash
$ jqg '\|' odd-values.json
{
  "one.string-with-pipe": "this|that",
  "one.key|with|pipe": true
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for parens (either)</summary>

```bash
$ jqg '\(|\)' odd-values.json
{
  "one.string-with-parens": "(this and that)",
  "one.key(with)parens": true,
  "one.bare-parens()": true,
  "one.left(paren-only": true,
  "one.unmatched-left)-paren": false
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for parens (both)</summary>

```bash
$ jqg '\(\)' odd-values.json
{
  "one.bare-parens()": true
}
```

</details>

[//]: # (==================================================================)

## Unflatten Mode Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>flatten and unflatten JSON</summary>

```bash
# example of filtered, flattened output
$ jqg four odd-values.json
{
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world"
}

# same output, unflattened
$ jqg four odd-values.json | jqg -u
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>flatten and unflatten JSON containing sparse array</summary>

```bash
# example of filtered, flattened non-empty output
$ jqg -E four odd-values.json
{
  "four.0": "first",
  "four.1": null,
  "four.3": 999,
  "four.4": "fourth",
  "four.5": "hello.world"
}

# same output, unflattened
$ jqg -E four odd-values.json | jqg -u
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>flatten and unflatten JSON using non-default join character</summary>

```bash
# example of filtered, flattened output, keys joined with '^'
$ jqg -j ^ two odd-values.json
{
  "two^0^two-a^non-integer-number": -101.75,
  "two^0^two-a^number-zero": 0,
  "two^0^true-boolean": true,
  "two^0^two-b^false-boolean": false,
  "two^1^two-c^alpha-num-1": "a1",
  "two^1^two-c^alpha-num-2": "2b",
  "two^1^two-c^alpha-num-3": "a12b"
}

# same output, unflattened
$ jqg -j ^ two odd-values.json | jqg -u -j ^
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>flatten and unflatten JSON using JQG_OPTS</summary>

```bash
# example of filtered, flattened output, keys joined with '+'
$ export JQG_OPTS='-j +'
$ jqg two odd-values.json
{
  "two+0+two-a+non-integer-number": -101.75,
  "two+0+two-a+number-zero": 0,
  "two+0+true-boolean": true,
  "two+0+two-b+false-boolean": false,
  "two+1+two-c+alpha-num-1": "a1",
  "two+1+two-c+alpha-num-2": "2b",
  "two+1+two-c+alpha-num-3": "a12b"
}

# same output, unflattened
$ export JQG_OPTS='-j +'
$ jqg two odd-values.json | jqg -u
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
```

</details>

[//]: # (==================================================================)

## Extract Mode Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>simple extraction</summary>

```bash
# .cat selector in JQ
$ jq .cat carnivora.json
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

# same .cat selector, using JQG's extract mode
$ jqg -x .cat carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>deeper extraction</summary>

```bash
$ jqg -x .cat.feral carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>array selector (with sparse array)</summary>

```bash
$ jqg -x .cat.feral[1] carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>multiple selectors</summary>

```bash
$ jqg -x .one,.three odd-values.json
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

# the selector order can be reversed, changing the output
$ jqg -x .three,.one odd-values.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>overlapping selectors</summary>

```bash
# the first selector contains the second
$ jqg -x .cat,.cat.feral[1] carnivora.json
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

# when the second selector contains the first, the output order can be changed (though array order is not)
$ jqg -x .cat.feral[1],.cat carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>extract from flattened input</summary>

```bash
$ jqg . carnivora.json | jqg -x .dog
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>nonexistent selector</summary>

```bash
$ jqg -x .dolphin carnivora.json
null
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>invalid selector (JQ 1.6 & 1.7)</summary>

```bash
$ jqg -x dog carnivora.json
jq: error: dog/0 is not defined at <top-level>, line 7
    path(dog) as \$selector_path | tostream |
jq: 1 compile error
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>invalid selector (JQ 1.8+)</summary>

```bash
$ jqg -x dog carnivora.json
jq: error: dog/0 is not defined at <top-level>, line 7, column 10
    path(dog) as \$selector_path | tostream |
jq: 1 compile error
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>mismatched selector</summary>

```bash
$ jqg -x .[0] carnivora.json
jq: error (at <stdin>:53): Cannot index object with number
```

</details>

[//]: # (==================================================================)

## Composite Search Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>search with unflattened results</summary>

```bash
# normal search
$ jqg breed carnivora.json
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}

# same search, with unflattened results (using -U)
$ jqg -U breed carnivora.json
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

# same search & results (using jqu)
$ jqu breed carnivora.json
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

# same search & results (with output transformation)
# (this is actually how the -U option is implemented)
$ jqg breed -t unflatten carnivora.json
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

# same search & results (via pipeline)
$ jqg breed carnivora.json | jqg -u
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>extract and search</summary>

```bash
# normal search (without extract)
$ jqg breed carnivora.json
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}

# extract .dog, then search (using -X)
$ jqg -X .dog breed carnivora.json
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}

# same extract & search (using jqx)
$ jqx .dog breed carnivora.json
{
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}
```

</details>

[//]: # (==================================================================)

## Input/Output Transformation Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>simple search, with unflattened results</summary>

```bash
# normal search
$ jqg breed carnivora.json
{
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.0.breed": "mutt",
  "dog.1.breed": "yellow labrador"
}

# same search & results unflattened via output transformation
# (this is actually how the -U option is implemented)
$ jqg breed -t unflatten carnivora.json
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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>extract with flattened results</summary>

```bash
# normal extract
$ jqg -x .dog carnivora.json
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

# same extract flattened via output transformation
$ jqg -x .dog -t flatten carnivora.json
{
  "dog.0.petname": "Growler",
  "dog.0.breed": "mutt",
  "dog.1.petname": "Tiger",
  "dog.1.breed": "yellow labrador",
  "dog.1.feral": true,
  "dog.1.type": "domesticated",
  "dog.2": {}
}
```

</details>

## License

[Apache-2.0](../LICENSE)<br />
© 2021 Joseph Casadonte
