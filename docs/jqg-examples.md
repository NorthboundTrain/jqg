# `jqg` Examples

## Sample JSON for Examples

These are the JSON files used in the unit test scripts. As such, the data in them is pretty nonsensical and even (perhaps) factually inaccurate; its primary purpose is to test various program conditions.

[//]: # (------------------------------------------------------------------)
[//]: # (--- NOTE: this file is generated using the gen-examples-md.pl   --)
[//]: # (--- script and should not be edited directly                    --)
[//]: # (------------------------------------------------------------------)

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
    "unmatched-left)-paren": false
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
    "fourth"
  ],
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
<summary>set default JQG options (e.g. always sort output)</summary>

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
<summary>override default JQG options (e.g. unsorted output)</summary>

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
<summary>set default JQG options (e.g. join keys with '+')</summary>

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
<summary>override default JQG options (e.g. join keys with ':')</summary>

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
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>flattened & sorted</summary>

```bash
$ jqg -q -S . odd-values.json
{
  "end-string": "bar",
  "four.0": "first",
  "four.1": null,
  "four.2": {},
  "four.3": "fourth",
  "one.bare-parens()": true,
  "one.integer-number": 101,
  "one.key(with)parens": true,
  "one.key|with|pipe": true,
  "one.left(paren-only": true,
  "one.null-value": null,
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
  "two.1.two-c.alpha-num-3": "a12b"
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
  "two.1.two-c.alpha-num-2": "2b"
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
  "two.1.two-c.alpha-num-1": "a1"
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
  "two.0.two-a.number-zero": 0
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
  "two.0.two-a.number-zero": 0
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
<summary>case insensitive multi-string value search with regex override for sub-expression</summary>

<p/>

**Test Skipped - ** *due to a bug in JQ's Oniguruma library, this requires a post 1.6 JQ build*

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
  "four.3": "fourth"
}
# same output, unflattened
$ jqg four odd-values.json | jqg -u
{
  "four": [
    "first",
    null,
    {},
    "fourth"
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
  "four.3": "fourth"
}
# same output, unflattened
$ jqg -E four odd-values.json | jqg -u
{
  "four": [
    "first",
    null,
    null,
    "fourth"
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
