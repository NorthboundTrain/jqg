# `jqg` Examples

## Sample JSON for Examples

These are the JSON files used in the unit test scripts. As such, the data in them is pretty nonsensical and even, perhaps, inaccurate; its primary purpose is to test various conditions.

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
            "feral": true
        },
        {
        }
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
    "integer-number": 101
  },
  "two": [
    {
      "two-a": {
        "non-integer-number": 101.75,
        "number-zero": 0
      },
      "true-boolean": true,
      "two-b": {
        "false-boolean": false
      }
    }
  ],
  "three": {
    "empty-string": "",
    "empty-object": {},
    "empty-array": []
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

```json
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

```json
$ jqg -I Tiger carnivora.json
{
  "dog.1.petname": "Tiger"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search keys & values (default)</summary>

```json
$ jqg domestic carnivora.json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow",
  "dog.1.type": "domesticated"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search keys only</summary>

```json
$ jqg -k tiger carnivora.json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search values only</summary>

```json
$ jqg -v tiger carnivora.json
{
  "cat.domesticated.1.breed": "domestic short hair",
  "dog.1.type": "domesticated"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>treat empty JSON arrays & objects as leaf nodes (default)</summary>

```json
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

```json
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

```json
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

```json
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

```json
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

```json
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

```json
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
<summary>use default key field separator (default: ".")</summary>

```json
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
<summary>use alternate key field separator (":")</summary>

```json
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
<summary>use arbitrary key field separator ("+")</summary>

```json
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
<summary>pipe output into <code>jqg</code> from curl</summary>

```json
$ curl -s https://raw.githubusercontent.com/NorthboundTrain/jqg/main/test/odd-values.json | jqg -v '(?<!\d)0|\[\]'
{
  "two.0.two-a.number-zero": 0,
  "three.empty-array": []
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>use <code>jqg</code> in the middle</summary>

```json
$  jq . carnivora.json | jqg feli | jq -S -c
{"cat.feral.2.aka":"felis nigripes","cat.isa":"feline","subclades.0":"feliformia"}
```

</details>

[//]: # (==================================================================)

## `jq` Option Pass-Through Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>unsorted output (default)</summary>

```json
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

```json
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

```json
$ jqg -q -c mammal carnivora.json
{
{"isa":"mammal","classification.class":"mammalia"}
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>compact & sorted output</summary>

```json
$ jqg -q -S -q -c mammal carnivora.json
{"classification.class":"mammalia","isa":"mammal"}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>clear out pass-through options</summary>

```json
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
<summary>set default <code>jqg</code> options (e.g. sort output)</summary>

```json
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
<summary>override default <code>jqg</code> options (e.g. unsorted output)</summary>

```json
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
<summary>set default <code>jqg</code> options (e.g. join keys with '+')</summary>

```json
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
<summary>override default <code>jqg</code> options (e.g. join keys with ':')</summary>

```json
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

[//]: # (==================================================================)

## Regex / PCRE Examples

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values with numbers</summary>

```json
$ jqg -v '\d+' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": 101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b"}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values that start with a number</summary>

```json
$ jqg -v '^\d+' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": 101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-2": "2b"
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for values that end with a number</summary>

```json
$ jqg -v '\d+$' odd-values.json
{
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": 101.75,
  "two.0.two-a.number-zero": 0,
  "two.1.two-c.alpha-num-1": "a1"
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>search for integer values</summary>

```json
$ jqg -v '^\d+$' odd-values.json
{
  "one.integer-number": 101,
  "two.two-a.number-zero": 0
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>multiple search strings</summary>

```json
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
<summary>no filter, just flatten</summary>

```json
$ jqg . odd-values.json
{
  "one.start-string": "foo",
  "one.null-value": null,
  "one.integer-number": 101,
  "two.0.two-a.non-integer-number": 101.75,
  "two.0.two-a.number-zero": 0,
  "two.0.true-boolean": true,
  "two.0.two-b.false-boolean": false,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b",
  "three.empty-string": "",
  "three.empty-object": {},
  "three.empty-array": [],
  "end-string": "bar"
}
```

</details>

[//]: # (------------------------------------------------------------------)
<details>
<summary>flattened & sorted</summary>

```json
$ jqg -q -S . odd-values.json
{
  "end-string": "bar",
  "one.integer-number": 101,
  "one.null-value": null,
  "one.start-string": "foo",
  "three.empty-array": [],
  "three.empty-object": {},
  "three.empty-string": "",
  "two.0.true-boolean": true,
  "two.0.two-a.non-integer-number": 101.75,
  "two.0.two-a.number-zero": 0,
  "two.0.two-b.false-boolean": false,
  "two.1.two-c.alpha-num-1": "a1",
  "two.1.two-c.alpha-num-2": "2b",
  "two.1.two-c.alpha-num-3": "a12b"
}
```

</details>
