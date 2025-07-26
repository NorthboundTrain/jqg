# The `jqg` Filter - Explained

**NOTE:** *the rewrite of this page for v1.3.0 is not quite complete; any remaining work is noted below*

A JQ program is a series of filters that data goes through, transforming the input according to the rules of the filter being executed, producing some output that is then passed along to the next filter or presented as the end result. The JQ syntax itself is pretty dense stuff, and the JQG filters are pretty complicated for a JQ newbie like me to understand -- it wasn't at all intuitive to me what was happening and why through most of the steps. I got some elements of the original JQG filter to work through trial and error, without a full understanding of why it did or didn't work as expected, so I wrote this document as much for my own edification as anything else.

The basic syntactical structure of a JQ program, though, is pretty simple. Different filters are separated by a pipe ('`|`') or a comma ('`,`'); the pipe is analogous to a shell pipe, where the output of the first filter is used as the input to the following filter, whereas with the comma, the input to each filter is the same and the output is the concatenation of each filter's results. Collections of filters can be saved off as a named function that can then be used as a filter somewhere else. Function arguments are pretty wonky, but JQG's functions don't use them, so I won't get into them here.

**Hint:** Use the [`jq playground`](https://play.jqlang.org/) site with the data below to play around with some of the sub-expressions in the filter; it really helps illustrate what each piece of syntax does. In addition, you can add in the `debug` filter at any step to dump out the current input at that moment, which *really* helps illustrate what's happening.

If you find any errors in my explanation, please submit a bug.

*References:*
[Pipe ('`|`')](https://jqlang.org/manual/#pipe),
[Comma ('`,`')](https://jqlang.org/manual/#comma),
[Defining Functions](https://jqlang.org/manual/#defining-functions),
[`debug`](https://jqlang.org/manual/#debug)

[//]: # (==================================================================)

## Overall Structure

### JQG Filters

There are four primary filters/functions in the JQG script:

* [`search_filter`](#search_filter) - filter the input for some criteria; expects flattened input
* [`flatten_json`](#flatten_json) - flatten the input JSON; expects unflattened input
* [`unflatten_json`](#unflatten_json) - unflatten the input JSON; expects flattened input
* [`extract_json`](#extract_json) - extract a sub-section of input based on a selector; expects unflattened input

plus a few secondary filters/functions:

* [`empty_leafs`](#empty_leafs) - handle the selection of empty leaf nodes during the flattening process; is only used in conjunction with `flatten_json` and the `-e|--include_empty` JQG command line argument
* [`require_results`](#require_results) - optionally count the results, halting execution and throwing an error if there are none; is only used in conjunction with the `-N|--results_required` JQG command line argument
* [`post_process_output`](#post_process_output) - optionally extract just the keys or values from the results object, possibly producing raw output; is only used in conjunction with the `-K|--keys` and `-V|--values` JQG command line argument

Each of the primary and secondary filters are explained in detail in the sections below.

JQG has three major modes (search, unflatten, extract) plus two composite modes (each combining the search mode with one of the other two). Each mode will string a subset of the above filters together in a different order; other command line options can further affect the filters used and the order they're used in, with the remaining options affecting the execution of the filters themselves. This results in zero or more input transformation filters, a main filter, zero or more output transformation filters, and finally the optional filter to post-process the output.

By default, the different modes produce the following filter lists:

| Mode               | Option                          | Default Filter List                                                           | Main Filter      |
| ---                | ---                             | ---                                                                           | ---              |
| search             | `--search`                      | `flatten_json` \| **`search_filter`**                                         | `search_filter`  |
| unflatten          | `--unflatten`                   | **`unflatten_json`**                                                          | `unflatten_json` |
| extract            | `--extract`                     | `unflatten_json` \| **`extract_json`**                                        | `extract_json` |
| search & unflatten | `--composite_unflatten` / `jqu` | `flatten_json` \| **`search_filter`** \| `unflatten_json`                     | `search_filter`  |
| extract & search   | `--composite_extract` / `jqx`   | `unflatten_json` \| `extract_json` \| `flatten_json` \| **`search_filter`**   | `search_filter`  |

The main filter is shown in the chart above for each mode -- any filters appearing before the main filter in the list of filters are considered input transformation filters for that mode, and any filters appearing after the main filter are considered output transformation filters for that mode. The `require_results` and `post_process_output` filters are considered separate from the output transformation filters; their presence is controlled by other options as shown below.

**Note:** After the filter list is defined, but before it's actually built, if the main filter is `search_filter` or `extract_json` and the `CRITERIA`/`SELECTOR` given is "`.`" (or missing altogether), the main filter is removed from the list, leaving the rest of the filter list untouched (i.e. `search_filter` or `extract_json` will be removed, but any input and output transformations will remain). The JQG filter is then built from the remaining filters in the list.

The following command line options modify the filter list:

| Option               | Filter List Modification                                                                              |
| ---                  | ---                                                                                                   |
| `--input flatten`    | replace all input transformation filters with `flatten_json`                                          |
| `--input unflatten`  | replace all input transformation filters with `unflatten_json`                                        |
| `--input extract`    | replace all input transformation filters with: `unflatten_json` \| `extract_json` \| `flatten_json` |
| `--input none`       | remove all input transformation filters                                                               |
|                      |                                                                                                       |
| `--output flatten`   | replace all output transformation filters with `flatten_json`                                         |
| `--output unflatten` | replace all output transformation filters with `unflatten_json`                                       |
| `--output none`      | remove all output transformation filters                                                              |
|                      |                                                                                                       |
| `--results_required` | add the `require_results` filter to the end of the filter list                                          |
| `--empty_results_ok` | remove the `require_results` filter                                                                     |
|                      |                                                                                                       |
| `--keys`, `--values` | add the `post_process_output` filter to the end of the filter list                                    |
| `--all`              | remove the `post_process_output` filter                                                               |

### Variables

There are two types of variables used in the annotations below: JQ variables (shown all in lower case, `$like_so`) and BASH variables (shown bolded in upper case, **`$LIKE_SO`**). In the real JQG script, the filter is escaped properly to make it through the shell into JQ, but here it's presented so that you can cut and paste it into [`jq playground`](https://play.jqlang.org/) as easily as possible. Any **`$EMBEDDED_SHELL_VARIABLES`** will cause the `jq playground` tool problems, of course, but just replace as appropriate and you should be good to go (use the JQG `--debug` command-line option to help with this).

### Example JSON

Most explanations below will reference the following JSON snippet:

<details>
<summary>

###### example JSON

</summary>

```json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal"
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

## Key JQ Filters

There are a handful of JQ filters that I found difficult to understand. They're used in several of JQG's filters, so I'm going to explain them in general terms once up here and then refer to them with specifics in the JQG filter context.

[//]: # (-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -)

### Variable/Symbolic Binding Operator

<details>
<summary>

###### usage: `EXPRESSION as $IDENTIFIER | ...`

</summary>

The "Variable/Symbolic Binding Operator" is a special construct that loops through each value of `EXPRESSION`, stores that value in the JQ variable `$IDENTIFIER`, and then runs the *entire* filter input through the rest of the pipeline (represented here by "`...`") with `$IDENTIFIER` available/accessible during each iteration. The pipeline can use that original input or not as it likes, and it can use the `$IDENTIFIER` or not as it likes (presumably it's wanted for some purpose, though). If the `EXPRESSION` only produces one value, there's only one iteration through the remainder of the pipeline; this is not unusual. Once the value of `$IDENTIFIER` is set, nothing can change it -- this was a source of good bit of confusion for me.

<details>
<summary>

###### Variable/Symbolic Binding Operator example

</summary>

Using the example data above, this a pretty contrived filter that stores the date/time value of the epoch as **`$timestamp`** and then changes the value of all `.breed` keys to it:

> Filter: `(0 | todate) as $timestamp | (..|select(has("breed"))?) += {breed: $timestamp}` produces:

```json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "1970-01-01T00:00:00Z"
      },
      {
        "petname": "Misty",
        "breed": "1970-01-01T00:00:00Z",
        "color": "yellow"
      }
    ]
  }
}
```

</details>

References:
[Variable/Symbolic Binding Operator](https://jqlang.org/manual/#variable-symbolic-binding-operator)

</details>

---

[//]: # (-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -)

### `path`

<details>
<summary>

###### usage: `path(PATH EXPRESSION)`

</summary>

`path` outputs arrays of strings & numbers describing the paths to the input value matched by the given `PATH EXPRESSION`. Examples of these path arrays from the sample JSON above would be: `[ "cat" ]`, `[ "cat", "domesticated" ]`, `[ "cat", "domesticated", 0 ]`, `[ "cat", "domesticated", 0, "petname" ]`, `[ "cat", "domesticated", 0, "breed" ]`. These path arrays are produced for each element that makes it through the `PATH EXPRESSION`.

The `path` filter is an odd filter. While many JQ filters behave differently depending on the number of arguments passed in, according to the documentation `path` has two completely different modes of operation depending on the *type* of the value in `PATH EXPRESSION`. Kinda sorta.

If `PATH EXPRESSION` is an "exact match path expression" then `path` will produce its output whether or not a value for it actually exists in the input to `path`. If `PATH EXPRESSION` is a "pattern", however, then it will only produce its output for the patterns that exist inside of the input to `path`. I put those terms, "exact match path expression" and "pattern" in quotes because they're not really defined, and I wasn't able to identify a clear example of a "pattern", despite a few hours of trying. My best guess as to what the difference is depends solely on the whether the `PATH EXPRESSION` itself filters the non-matching results out somehow. Examples are probably best.

<details>
<summary>

###### `path` examples

</summary>

Assume the following as input:

```json
{
  "lorem": {
    "ipsum": "dolor",
    "sit": {
      "amet": true
    }
  }
}
```

> Filter: `path(.foo)` produces:

```json
[
  "foo"
]
```

> Filter: `path(.foo,.bar)` produces:

```json
[
  "foo"
]
[
  "bar"
]
```

> Filter: `path(.foo,.lorem,.bar)` produces:

```json
[
  "foo"
]
[
  "lorem"
]
[
  "bar"
]
```

> Filter: `path(.foo,.lorem,.bar|select(iterables))` produces:

```json
[
  "lorem"
]
```

> Filter: `path(.foo,.lorem,.bar|..|if . == null then select(true) else ..|select(iterables) end)` produces:

```json
[
  "foo"
]
[
  "lorem"
]
[
  "lorem",
  "sit"
]
[
  "lorem",
  "sit"
]
[
  "bar"
]
```

</details>

If `path` isn't working as you thought it should, my best advice is to play with it on the [`jq playground`](https://play.jqlang.org/) site.

References:
[`path`](https://jqlang.org/manual/#path),
[Path Expressions](https://github.com/jqlang/jq/wiki/jq-Language-Description#Path-Expressions)

</details>

---

[//]: # (-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -)

### `reduce`

<details>
<summary>

###### usage: `reduce EXPRESSION as $VAR (STARTING VALUE; ACCUMULATOR)`

</summary>

The `reduce` filter is a looping mechanism that accumulates its output over the course of the loop's execution. The `EXPRESSION` will produce a set of results, each element of which will be iterated over. The accumulated output is initialized with the value of `STARTING VALUE` and the `ACCUMULATOR` filter is evaluated once for each loop iteration, returning an array or object that `reduce` concatenates to or merges with the previous iteration's array or object. This accumulated output is what passes out of the `reduce` filter. During each iteration, the current value of the loop is stored in `$VAR`, and the current value of the accumulated results is stored in `.` (the latter was also a source of confusion for me).

<details>
<summary>

###### `reduce` examples

</summary>

See the [example JSON](#example-json) from above as input.

> Filter: `reduce .. as $element ([]; . + [ $element | select(scalars) ])` produces:

```json
[
  "Fluffy",
  "Bengal",
  "Misty",
  "domestic short hair",
  "yellow"
]
```

In this example, `EXPRESSION` is '`..`', `$VAR` is '`$element`', `STARTING VALUE` is '`[]`', and `ACCUMULATOR` is '`. + [ $element | select(scalars) ]`'. In a nutshell, it descends through every value in the input structure and selects only the leaf node values to add to the output array.

There are two interesting points here to dig into. The first is to look at the value being iterated over, which is stored in `$element` during each iteration. This is most easily done using `debug`.

> Filter: `reduce .. as $element ([]; . + [ $element | debug | select(scalars) ])` produces:

```json
["DEBUG:",{"cat":{"domesticated":[{"petname":"Fluffy","breed":"Bengal"},{"petname":"Misty","breed":"domestic short hair","color":"yellow"}]}}]
["DEBUG:",{"domesticated":[{"petname":"Fluffy","breed":"Bengal"},{"petname":"Misty","breed":"domestic short hair","color":"yellow"}]}]
["DEBUG:",[{"petname":"Fluffy","breed":"Bengal"},{"petname":"Misty","breed":"domestic short hair","color":"yellow"}]]
["DEBUG:",{"petname":"Fluffy","breed":"Bengal"}]
["DEBUG:","Fluffy"]
["DEBUG:","Bengal"]
["DEBUG:",{"petname":"Misty","breed":"domestic short hair","color":"yellow"}]
["DEBUG:","Misty"]
["DEBUG:","domestic short hair"]
["DEBUG:","yellow"]
[
  "Fluffy",
  "Bengal",
  "Misty",
  "domestic short hair",
  "yellow"
]
```

The second is to watch the accumulated output through each iteration, again using `debug`.

> Filter: `reduce .. as $element ([]; . + [ $element  | select(scalars) ] | debug)` produces:

```json
["DEBUG:",[]]
["DEBUG:",[]]
["DEBUG:",[]]
["DEBUG:",[]]
["DEBUG:",["Fluffy"]]
["DEBUG:",["Fluffy","Bengal"]]
["DEBUG:",["Fluffy","Bengal"]]
["DEBUG:",["Fluffy","Bengal","Misty"]]
["DEBUG:",["Fluffy","Bengal","Misty","domestic short hair"]]
["DEBUG:",["Fluffy","Bengal","Misty","domestic short hair","yellow"]]
[
  "Fluffy",
  "Bengal",
  "Misty",
  "domestic short hair",
  "yellow"
]
```

Since the first few iterations are for non-leaf nodes, nothing is added to the accumulated output, and then again near in the middle there is no change in the accumulated output because there is a non-leaf node thrown in.

</details>

References:
[`reduce`](https://jqlang.org/manual/#reduce)

</details>

---

[//]: # (-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -)

### `select`

<details>
<summary>

###### usage: `select(BOOLEAN EXPRESSION)`

</summary>

`select` will filter its input by running it through `BOOLEAN EXPRESSION`; if `BOOLEAN EXPRESSION` evaluates to `false` or `null` then that element is not selected and will not be passed on to the next filter, otherwise it will be selected and will be passed on. Note that the strings `"false"` and `"null"` are considered `true`, and therefor will be selected.

<details>
<summary>

###### `select` examples

</summary>

See the [example JSON](#example-json) from above as input.

This selects just the leaf node values that contain a capital letter.

> Filter: `[..|scalars|select(test("[A-Z]"))]` produces:

```json
[
  "Fluffy",
  "Bengal",
  "Misty"
]
```

This selects values that do *not* contain a capital letter.

> Filter: `[..|scalars|select(test("[A-Z]") | not)]` produces:

```json
[
  "domestic short hair",
  "yellow"
]
```

</details>

References:
[`select`](https://jqlang.org/manual/#select)

</details>

---

[//]: # (-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -)

### `setpath`

<details>
<summary>

###### usage: `setpath(PATHS;VALUE)`

</summary>

`setpath` will set the element described by `PATHS` to `VALUE`, where `PATHS` is an array of strings & numbers describing the element to be set. If the element already exists it will be replaced; if it does not, it will be added. See [`path`](#path) above for examples of what `setpath` is expecting as its first argument.

<details>

<summary>

###### `setpath` examples

</summary>

See the [example JSON](#example-json) from above as input.

Add a new element to an object.

> Filter: `setpath(["bird"]; {"breed": "parrot"})`

```json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal"
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  },
  "bird": {
    "breed": "parrot"
  }
}
```

Add a new element to an array (creating a `null` element placeholder for any skipped indices)

> Filter: `setpath(["cat", "domesticated", 3]; {"petname": "Mittens", "breed": "manx"})`

```json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal"
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      },
      null,
      {
        "petname": "Mittens",
        "breed": "manx"
      }
    ]
  }
}
```

Replace a value in an object.

> Filter: `setpath(["cat", "domesticated", 0]; "oops")`

```json
{
  "cat": {
    "domesticated": [
      "oops",
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

References:
[`setpath`](https://jqlang.org/manual/#setpath)

</details>

---

[//]: # (-  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -)

### `to_entries`

<details>
<summary>

###### usage: `to_entries`

</summary>

`to_entries` takes a JSON object and breaks it out by key/value pair, creating an array of objects with the original key and value elements used as the values for two keys named "key" and "value". This is more easily explained visually. Given the following input:

```json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal"
}
```

the `to_entries` filter transforms this into the following:

```json
[
  {
    "key": "cat.domesticated.0.petname",
    "value": "Fluffy"
  },
  {
    "key": "cat.domesticated.0.breed",
    "value": "Bengal"
  }
]
```

Basically it gives the JQ program easy access to the key and value of the input by storing them into named object elements. When run against an array, `to_entries` will store the array index in the `key` field:

Given:

```json
[ "first", "second", "third" ]
```

`to_entries` produces:

```json
[
  {
    "key": 0,
    "value": "first"
  },
  {
    "key": 1,
    "value": "second"
  },
  {
    "key": 2,
    "value": "third"
  }
]
```

References:
[`to_entries`](https://jqlang.org/manual/#to_entries-from_entries-with_entries)

</details>

---

[//]: # (==================================================================)

## JQG Filters

### `flatten_json`

```jq
def flatten_json:
    . as $data |
    [ path(.. | select((scalars|tostring), $EMPTY_TESTS)) ] |
    map({ (map(tostring) | join("$JOIN_CHAR")) : (. as $path | . = $data | getpath($path)) }) |
    reduce .[] as $item ({ }; . + $item);
```

<details>
<summary>

###### filter annotation

</summary>

> **`. as $data |`**

*see the JQ filter overview above for explanations of: [`EXPRESSION as $IDENTIFIER | ...`](#variablesymbolic-binding-operator) (Variable/Symbolic Binding Operator)*

The "Variable/Symbolic Binding Operator" is a special construct that loops through each value of `EXPRESSION`, stores that value in the JQ variable `$IDENTIFIER`, and then runs the *entire* filter input through the rest of the pipeline (represented here by "`...`") with `$IDENTIFIER` available/accessible during each iteration.

The use of the binding operator in this filter segment is much simpler, though; because `EXPRESSION` is just '`.`' (the "Identity" operator), there is only one iteration through the loop, with the entire input being stored into a variable called `$data` that can be referenced some time later.

References:
[Variable/Symbolic Binding Operator](https://jqlang.org/manual/#variable-symbolic-binding-operator),
[Identity ('`.`')](https://jqlang.org/manual/#identity)

---

> **`[ path(.. | select((scalars|tostring), $EMPTY_TESTS)) ] |`**

*see the JQ filter overview above for explanations of: [`path(PATH EXPRESSION)`](#path), [`select(BOOLEAN EXPRESSION)`](#select)*

> > **NOTE:** *this section needs some work -- the `select` with a comma (`,`) in the `BOOLEAN EXPRESSION` needs to be expanded upon*

`path` outputs arrays of strings & numbers describing the paths to the input value matched by the given `PATH EXPRESSION`.

`select` will filter its input by running it through `BOOLEAN EXPRESSION`; if `BOOLEAN EXPRESSION` evaluates to `false` or `null` then that element is not selected and will not be passed on to the next filter, otherwise it will be selected and will be passed on.

The `PATH EXPRESSION` here is made up of a series of filters. The first one, `..`, recursively descends through each element of the input, one element at a time, producing every value. Those values are passed to `select`'s `BOOLEAN EXPRESSION`, which will decide which of the elements to include.

The `BOOLEAN EXPRESSION` itself is made up of two filters separated by a comma ("`,`"), which means that the same input is presented to both filters and the results are concatenated together. For the purposes of `select`, only one of them needs to come back true for the element to be used.

The main selection criteria is `select(scalars|tostring)`. The `scalars` function will only look at the end nodes of the JSON structure -- JQ calls them the 'non-iterables', i.e. the nodes without children, or the non-interim nodes (e.g. not `[ "cat" ]`, `[ "cat", "domesticated" ]`, or `[ "cat", "domesticated", 0 ]` -- just `[ "cat", "domesticated", 0, "petname" ]` and `[ "cat", "domesticated", 0, "breed" ]`). The `scalars` function returns just the values of the end nodes to then be evaluated by `select`; before that evaluation happens, though, those values are run through the `tostring` function so that a value of `false` or `null` will be turned into `"false"` and `"null"`, preventing `select` from rejecting them (it will also turn `20` into `"20"` and `true` into `"true"`, which is not necessarily desired, but it also doesn't hurt since all of the *stringified* values are just tossed away).

The value of **`$EMPTY_TESTS`** depends on whether or not `-e|--include_empty` or `-E|--exclude_empty` is specified on the JQG command line; if `-e|--include_empty` is given (which is the default) then empty arrays (`[]`) and empty objects (`{}`) are considered to be end nodes, and if `-E|--exclude_empty` is given then they are ignored. The filter for `-e|--include_empty` is the function [`empty_leafs`](#empty_leafs) (see below); the filter for `-E|--exclude_empty` is just the JSON value of `false`, which will never be selected.

Any elements that are selected by the compound `BOOLEAN EXPRESSION` are used individually by `path` to grab the path elements of that element as an array, as described above, e.g. the path elements for `fluffy` and `misty` would be `[ "cat", "domesticated", 0, "petname" ]` and `[ "cat", "domesticated", 1, "petname" ]`, respectively. Finally, the brackets `[ ... ]` that surround the whole thing will take all of the selected results and wrap them in an outer array, creating an array of arrays, e.g. `[[ "cat", "domesticated", 0, "petname" ], [ "cat", "domesticated", 1, "petname" ]]`.

References:
[`path`](https://jqlang.org/manual/#path),
[Path Expressions](https://github.com/jqlang/jq/wiki/jq-Language-Description#Path-Expressions),
[Recursive Descent (..)](https://jqlang.org/manual/#recursive-descent),
[`select`](https://jqlang.org/manual/#select),
[Comma ('`,`')](https://jqlang.org/manual/#comma),
[`scalars`](https://jqlang.org/manual/#arrays-objects-iterables-booleans-numbers-normals-finites-strings-nulls-values-scalars),
[`tostring`](https://jqlang.org/manual/#tostring),
[Array Construction](https://jqlang.org/manual/#array-construction)

---

> **`map({ (map(tostring) | join("$JOIN_CHAR")) : (. as $path | . = $data | getpath($path)) }) |`**

*see the JQ filter overview above for explanations of: [`EXPRESSION as $IDENTIFIER | ...`](#variablesymbolic-binding-operator) (Variable/Symbolic Binding Operator)*

This segment is pretty busy, so we'll look at the individual pieces and then put them together. Once that's done, though, you'll (hopefully) see that it's not all that complicated.

`map()` is a looping construct that runs the filter list inside of the parens against each element of the input array, returning an array of the aggregated output. The current element being processed is stored in `.` for each iteration through the loop.

`{}` constructs objects, with the key separated from the value by a colon ('`:`').

Taken together, the expression `map({ ... : ... })` will take an array as input, and create an array of objects as output.  The input for this section of the filter is an array of path elements, e.g. `["cat","domesticated",0,"petname"]`, which this first `map` will iterate over.

The "key" for the new object is constructed using this expression: `(map(tostring) | join("$JOIN_CHAR"))`. The `tostring` filter will take its input and create a string out of it; strings are left as-is, numbers, booleans, and `null` are put in quotes, and everything else is encoded as a JSON string. The path element array above would be transformed into `["cat","domesticated","0","petname"]` -- not too exciting, but necessary to handle some edge cases.

`join()` takes an array of strings and joins them together into a single string, separated with the join character specified. **`$JOIN_CHAR`** is a shell script variable, which can be set using `-j|--join <str>` (it is '`.`' by default). Normally `join` will automatically convert numbers and booleans into strings, but nulls, arrays, and objects are converted into an empty string; because each element was converted to a string already via `tostring`, though, these empty strings are avoided.

Taken together, this `map(...) | join(...)` expression will take the path elements `["cat","domesticated",0,"petname"]` and create a key string of `"cat.domesticated.0.petname"`.

The "value" for the new object is constructed using the expression: `(. as $path | . = $data | getpath($path))`. The first piece of this, `. as $path`, will take the current input (e.g. `["cat","domesticated",0,"petname"]`) and save it into a JQ variable named `$path` to be referenced later (using the "Variable/Symbolic Binding Operator" -- see the JQ filter overview above). This is needed because `. = $data` will take the value of the JQ variable `$data` and make it the current input (`$data` was saved back in the first filter segment). Finally, `getpath()` will take the current input and lookup the value represented by an array of path elements passed into it. At this point, the current input (`.`) has been set to `$data` (the original input to the whole filter) and `$path` is the array of path elements in the current iteration of map, e.g. `["cat","domesticated",0,"petname"]`, the result of which is a value, in this case `Fluffy`.

Putting the key and value expression results together results in something like the following: `{"cat.domesticated.0.petname":"Fluffy"}` -- repeat this for each end node in the JSON input, creating one new object for each iteration, which the `map` collects into an array, and then move on to the next segment.

References:
[`map`](https://jqlang.org/manual/#map-map_values),
[Object Construction](https://jqlang.org/manual/#object-construction),
[`tostring`](https://jqlang.org/manual/#tostring),
[`join`](https://jqlang.org/manual/#join),
[Variable/Symbolic Binding Operator](https://jqlang.org/manual/#variable-symbolic-binding-operator),
[Assignment](https://jqlang.org/manual/#assignment),
[`getpath`](https://jqlang.org/manual/#getpath)

---

> **`reduce .[] as $item ({ }; . + $item)`**

*see the JQ filter overview above for explanations of: [`reduce EXPRESSION as $VAR (STARTING VALUE; ACCUMULATOR)`](#reduce)*

This segment is not nearly as busy as the preceding segment, but what it does is a little less intuitive. In the end, though, you'll hopefully see that this, too, is not that complicated.

The `reduce` filter is a looping mechanism that accumulates its results.

The `EXPRESSION` used by `reduce` is `.[]`, which simply iterates over all of the elements of the input array (`.[]` actually can do more than that, but that's what it's doing for us, here). Each element of data that comes out of the `.[]` filter is saved into the JQ variable `$item`, and is then passed into the accumulating section of the filter. The accumulated result is initialized as an empty object (`{}`) and then each `$item` is appended to the object as a new key/value pair. Since each `$item` is itself an object, this all works out as expected (trying to add a single element to an object would result in an error).

In other words, an array of objects with a single key/value pair is being collapsed into a single object with each of the key value pairs in it -- turning this:

```json
[
  {
    "cat:domesticated:0:petname": "Fluffy"
  },
  {
    "cat:domesticated:0:breed": "Bengal"
  },
  {
    "cat:domesticated:1:petname": "Misty"
  },
  {
    "cat:domesticated:1:breed": "domestic short hair"
  },
  {
    "cat:domesticated:1:color": "yellow"
  }
]
```

into this:

```json
{
  "cat:domesticated:0:petname": "Fluffy",
  "cat:domesticated:0:breed": "Bengal",
  "cat:domesticated:1:petname": "Misty",
  "cat:domesticated:1:breed": "domestic short hair",
  "cat:domesticated:1:color": "yellow"
}
```

This object is passed out of the `flatten_json` filter.

References:
[`reduce`](https://jqlang.org/manual/#reduce),
[Array/Object Value Iterator ('`.[]`')](https://jqlang.org/manual/#array-object-value-iterator),
[Addition](https://jqlang.org/manual/#addition)

</details>

---

[//]: # (==================================================================)

### `empty_leafs`

```jq
def empty_leafs:
    select(tostring | . == "{}" or . == "[]");
```

<details>
<summary>

###### filter annotation

</summary>

> **`select(tostring | . == "{}" or . == "[]");`**

*This function may or may not be called as part of `flatten_json` -- see the second section of `flatten_json` above for details.*

*see the JQ filter overview above for explanations of: [`select(BOOLEAN EXPRESSION)`](#select)*

`select` will filter its input by running it through `BOOLEAN EXPRESSION`; if `BOOLEAN EXPRESSION` evaluates to `false` or `null` then that element is not selected and will not be passed on to the next filter, otherwise it will be selected and will be passed on.

The `tostring` filter will take its input and convert it to a string (if it's not a string already). This string is then passed to a multi-part conditional, comparing the current input ('`.`') with the strings "`{}`" and "`[]`", looking for matches. This function only cares about empty objects (`{}`) and empty arrays (`[]`); those will be selected, anything else will be rejected. Note that JQ's definition of `or` is not quite the same as "or" in most conventional scripting languages; it only returns `true` or `false`, not an actual value, but that's all that's needed here. The JQ definition of `==` requires an exact match of both type and value.

References:
[`select`](https://jqlang.org/manual/#select),
[`tostring`](https://jqlang.org/manual/#tostring),
[Identity ('`.`')](https://jqlang.org/manual/#identity),
[`==`](https://jqlang.org/manual/#==-!=),
[`or`](https://jqlang.org/manual/#and-or-not),
["`or`" versus "`//`"](https://github.com/jqlang/jq/wiki/FAQ#or-versus-)

</details>

---

[//]: # (==================================================================)

### `search_filter`

```jq
def search_filter:
    to_entries |
    map(select($SEARCH_ELEM | tostring | test("$CRITERIA"; "$CASE_REGEX"))) |
    from_entries;
```

<details>
<summary>

###### filter annotation

</summary>

This filter expects to receive flattened JSON as its input:

```json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow"
}
```

Running unflattened input through the search filter will work, but will probably not produce the expected results.

---

> **`to_entries |`**

*see the JQ filter overview above for explanations of: [`to_entries`](#to_entries)*

`to_entries` takes a JSON object and breaks it out by key/value pair, creating an array of objects with the original key and value elements used as the values for two keys named "key" and "value".

Running the flattened JSON above through `to_entries` produces the following:

```json
[
  {
    "key": "cat.domesticated.0.petname",
    "value": "Fluffy"
  },
  {
    "key": "cat.domesticated.0.breed",
    "value": "Bengal"
  },
  {
    "key": "cat.domesticated.0.color",
    "value": ""
  },
  {
    "key": "cat.domesticated.1.petname",
    "value": "Misty"
  },
  {
    "key": "cat.domesticated.1.breed",
    "value": "domestic short hair"
  },
  {
    "key": "cat.domesticated.1.color",
    "value": "yellow"
  }
]
```

References:
[`to_entries`](https://jqlang.org/manual/#to_entries-from_entries-with_entries)

---

> **`map(select($SEARCH_ELEM | tostring | test("$REGEX"; "$CASE_REGEX"))) |`**

*see the JQ filter overview above for explanations of: [`select(BOOLEAN EXPRESSION)`](#select)*

There are a number of **`$EMBEDDED_SHELL_VARIABLES`** here; let's look at them first.

**`$SEARCH_ELEM`** -- this variable is set based on the `-k|--searchkeys`, `-v|--searchvalues`, and `-a|--searchall` options for JQG; these options control whether the script is searching through keys, values, or both (all), respectively. If searching keys, **`$SEARCH_ELEM`** is set to `.key`, and it's set to `.value` if searching values; it's set to `.[]` if searching for both keys and values. All three filters work on JSON objects, which are made up of key/value pairs. The first two return the value found by looking up the name given in the JSON object being looked at, or `null` otherwise, whereas the last one (`.[]`) iterates over all values in the object. What makes it confusing is that at the start of the filter in this segment the input is an array of objects all of which are comprised of two key/value pairs, one with a key of "key" and one with a key of "value" -- see the previous segment explanation for details.

**`$REGEX`** -- this is the regular expression being searched for. Any string passed in is treated as if it were a regex, so any search criteria containing regex-like syntax (e.g. '`|`' or '`()`') will need to be properly escaped. Since JQ uses [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions), the capabilities here are vast, and are well beyond the scope of this document. Anything that JQ's PCRE engine can do can be used here.

**`$CASE_REGEX`** -- the only regex flag used here is to indicate whether or not the search will be case-sensitive: the value will be '`i`' if the search should be case-insensitive (`-i|--ignore_case`), and blank/empty ('') if the search should be case-sensitive (`-I|--match_case`); the search is case-insensitive by default.

`map()` is a looping construct that runs the filter list inside of the parens against each element of the input array, returning an array of the aggregated output. The current element being processed is stored in `.` for each iteration through the loop.

`select` will filter its input by running it through `BOOLEAN EXPRESSION`; if `BOOLEAN EXPRESSION` evaluates to `false` or `null` then that element is not selected and will not be passed on to the next filter, otherwise it will be selected and will be passed on.

Taken together, `map(select(...))` will iterate over each element of the input array and produce a filtered subset of it as an output array.

The value of the `select()` function here is fairly straightforward. Each key/value object in the input array is run through the filter: one or both elements are pulled out (depending on the value of **`$SEARCH_ELEM`** -- see above), it's converted to a string via `tostring`, then it's matched against the **`$REGEX`** via `test()`, which returns `true` if the regex matches, and `false` if it doesn't; `select()` will pass the input through unchanged if `true`, and toss the input away if `false`.

References:
[Object Identifier](https://jqlang.org/manual/#object-identifier-index),
[Array/Object Value Iterator ('`.[]`')](https://jqlang.org/manual/#array-object-value-iterator),
[`map`](https://jqlang.org/manual/#map-map_values),
[`select`](https://jqlang.org/manual/#select),
[`tostring`](https://jqlang.org/manual/#tostring),
[`test`](https://jqlang.org/manual/#test)

---

> **`from_entries`**

The input to this final filter segment is an array of key/value objects that matched the given criteria in the previous filter segment. The key/value objects need to be recombined back into its original format, which is exactly what `from_entries` does, reversing the process that `to_entries` started at the beginning of the `search_filter`. Given the following input:

```json
[
  {
    "key": "cat.domesticated.0.petname",
    "value": "Fluffy"
  },
  {
    "key": "cat.domesticated.0.breed",
    "value": "Bengal"
  }
]
```

`from_entries` transforms it into the following:

```json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal"
}
```

This object is passed out of the `search_json` filter.

References:
[`from_entries`](https://jqlang.org/manual/#to_entries-from_entries-with_entries)

</details>

---

[//]: # (==================================================================)

### `unflatten_json`

```jq
def unflatten_json:
    reduce to_entries[] as $entry
        (null; setpath($entry.key | tostring / "$JOIN_CHAR" | map(tonumber? // .); $entry.value));
```

<details>
<summary>

###### filter annotation

</summary>

The filter will turn flattened JSON:

```json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow"
}
```

into regular, structured JSON:

````json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal"
      },
      {
        "petname": "Misty",
        "breed": "domestic short hair",
        "color": "yellow"
      }
    ]
  }
}
````

---

> **`reduce to_entries[] as $entry`**

*see the JQ filter overview above for explanations of: [`reduce EXPRESSION as $VAR (STARTING VALUE; ACCUMULATOR)`](#reduce), [`to_entries`](#to_entries)*

The `reduce` filter is a looping mechanism that accumulates its results.

`to_entries` takes a JSON object and breaks it out by key/value pair, creating an array of objects with the original key and value elements used as the values for two keys named "key" and "value".

The `EXPRESSION` here is `to_entries[]`, which is a shorthand way of saying `(to_entries | .[])`. First, `to_entries` takes its JSON object input and breaks it out by key/value pair, then the Array/Object Value Iterator ('`.[]`') will split up all of the elements of the key/value array into individual pieces, which `reduce` will then iterate over. Using `to_entries` by itself would create one array of N elements, and `reduce` would run only once, which is not the correct behavior. In order to have `reduce` iterate over each element in the array, they need to be pulled out individually, which is what '`.[]`' will do.

<details>
<summary>

###### example: `to_entries` vs. `to_entries[]`

</summary>

Given this JSON:

```json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal"
}
```

Using the `to_entries` filter produces one array (with two values, each of which are objects):

```json
[
  {
    "key": "cat.domesticated.0.petname",
    "value": "Fluffy"
  },
  {
    "key": "cat.domesticated.0.breed",
    "value": "Bengal"
  }
]
```

`reduce` would only run once with the array being the value stored in `$entry`. Using `to_entries[]` produces two individual objects:

```json
{
  "key": "cat.domesticated.0.petname",
  "value": "Fluffy"
}
{
  "key": "cat.domesticated.0.breed",
  "value": "Bengal"
}
```

`reduce` would run once for each object, which is exactly what is desired. This is more clearly demonstrated using [`jq playground`](https://play.jqlang.org/) (showing just the `debug` output, with one line per `reduce` loop iteration):

> Filter: `reduce to_entries as $foo (null; $foo | debug)`

```json
["DEBUG:",[{"key":"cat.domesticated.0.petname","value":"Fluffy"},{"key":"cat.domesticated.0.breed","value":"Bengal"}]]
```

> Filter:`reduce to_entries[] as $foo (null; $foo | debug)`

```json
["DEBUG:",{"key":"cat.domesticated.0.petname","value":"Fluffy"}]
["DEBUG:",{"key":"cat.domesticated.0.breed","value":"Bengal"}]
```

</details>

References:
[`reduce`](https://jqlang.org/manual/#reduce),
[`to_entries`](https://jqlang.org/manual/#to_entries-from_entries-with_entries),
[Array/Object Value Iterator ('`.[]`')](https://jqlang.org/manual/#array-object-value-iterator)

---

> **`(null; setpath($entry.key | tostring / "$JOIN_CHAR" | map(tonumber? // .); $entry.value))`**

*see the JQ filter overview above for explanations of: [`setpath(PATHS; VALUE)`](#setpath)*

> > **NOTE:** *this section needs some work -- the use of `tostring` is not documented; add `tostring` to references*

`setpath` will set the element described by `PATHS` to `VALUE`, where `PATHS` is an array of strings & numbers describing the element to be set.

This is the segment of the `reduce` expression that accumulates the results of the loop, mapping to `(STARTING VALUE; ACCUMULATOR)` (see the previous section for a description of what this piece of the filter is actually looping through). The accumulated results are initialized with the value of `STARTING VALUE`, and `ACCUMULATOR` is run once for each loop iteration (with the current value of the loop stored in `$VAR`).

For this segment, `STARTING VALUE` is the JSON primitive `null`, and `ACCUMULATOR` is the `setpath()` filter, which returns an array or object that `reduce` concatenates to or merges with the previous array or object.

Inside of `setpath` the filter accesses the object stored in the JQ variable `$entry`. This variable holds an object with two elements, one named `key` and one named `value`. The one named `key` will have the key string of the current line being processed, the one named `value` will have the value string of the current line being processed, e.g. for the first line:

```json
{
  "key": "cat.domesticated.0.petname",
  "value": "Fluffy"
}
```

The '`/`' is the normal division operator, only in this case it's one string divided by another, effectively splitting the source string into an array of one or more strings. The divisor string is stored in the shell variable **`$JOIN_CHAR`**, ('`.`' by default) and can be set using the `-j|--join <str>` option. In the example above, the value of the `key` element (`"cat.domesticated.0.petname"`) is split by '`.`', resulting in the following array:

```json
[
  "cat",
  "domesticated",
  "0",
  "petname"
]
```

This array is sent through `map()`, which is a looping construct that runs the filter list inside of the parens against each element of the input array, returning an array of the aggregated output. The current element being processed is stored in `.` for each iteration through the loop. `tonumber` will convert the current input into a number, throwing an error if the string does not represent a number; the '`?`' suppresses that error, and the '`//`' says to use the original value ('`.`') instead. All of which converts the above array into this:

```json
[
  "cat",
  "domesticated",
  0,
  "petname"
]
```

`setpath` will then use that array to construct the JSON object or array described by it, and set it to the value of `$entry.value`, building up the final object or array one element at a time. The following will have been accumulated after the first iteration through the example flattened input:

```json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy"
      }
    ]
  }
}
```

after the second iteration, it will look like this:

```json
{
  "cat": {
    "domesticated": [
      {
        "petname": "Fluffy",
        "breed": "Bengal"
      }
    ]
  }
}
```

and so on. This restructured JSON is passed out of the `unflatten_json` filter.

References:
[`null`](https://www.rfc-editor.org/rfc/rfc8259.html#section-1) (RFC 8259),
[`setpath`](https://jqlang.org/manual/#setpath),
[Slash ('`/`')](https://jqlang.org/manual/#multiplication-division-modulo),
[`map`](https://jqlang.org/manual/#map-map_values),
[`tonumber`](https://jqlang.org/manual/#tonumber),
[Error Suppression/Optional Operator ('`?`')](https://jqlang.org/manual/#error-suppression-optional-operator),
[Alternative operator ('`//`')](https://jqlang.org/manual/#alternative-operator),
[Identity ('`.`')](https://jqlang.org/manual/#identity)

</details>

---

[//]: # (==================================================================)

### `extract_json`

```jq
def extract_json:
  reduce (
    path($SELECTOR) as $selector_path | tostream |
        select(length > 1 and (.[0] | index($selector_path) == 0))
    ) as $selected ( null; setpath($selected[0]; $selected[1]) );
```

<details>
<summary>

###### filter annotation

</summary>

This filter expects to receive structured JSON as its input. Running flattened input through the extract filter will work, but will probably not produce the expected results.

---

> **`reduce (...) as $selected`**

*see the JQ filter overview above for explanations of: [`reduce EXPRESSION as $VAR (STARTING VALUE; ACCUMULATOR)`](#reduce)*

The `reduce` filter is a looping mechanism that accumulates its results.

There's a lot happening inside of `reduce`'s `EXPRESSION`; for now, know that the results are going to be stored in `$selected`.

References:
[`reduce`](https://jqlang.org/manual/#reduce)

---

> **`path($SELECTOR) as $selector_path | tostream | select(...)`**

*see JQ filter overview above for explanations of: [`path(PATH EXPRESSION)`](#path), [`EXPRESSION as $IDENTIFIER | ...`](#variablesymbolic-binding-operator) (Variable/Symbolic Binding Operator), [`select(BOOLEAN EXPRESSION)`](#select)*

`select` will filter its input by running it through `BOOLEAN EXPRESSION`; if `BOOLEAN EXPRESSION` evaluates to `false` or `null` then that element is not selected and will not be passed on to the next filter, otherwise it will be selected and will be passed on.

This segment is the `reduce` filter's `EXPRESSION`, and is where the bulk of the work is done. The "Variable/Symbolic Binding Operator" is a special construct that loops through each value of `EXPRESSION`, stores that value in the JQ variable `$IDENTIFIER`, and then runs the *entire* filter input through the rest of the pipeline (represented here by "`...`") with `$IDENTIFIER` available/accessible during each iteration.

The Binding Operator's `EXPRESSION` is `path($SELECTOR)` with the results stored in the JQ variable `$selector_path`. The `path` function can do multiple things, but here it will simply break down the **`$SELECTOR`** into its component parts, returning an array of the pieces (whether or not it represents a valid path in the input JSON). For example, the output of `path(.cat.domesticated[0])` is:

```json
[
  "cat",
  "domesticated",
  0
]
```

The results of this are stored in the JQ variable named `$selector_path` for later use. Then the entire input to the Binding Operator is sent along to the `tostream` filter. JQ streaming is a construct that I'm not terribly familiar with. Conceptually it allows a program to process very large files incrementally. It's used here because it lets the program easily match against the path elements returned from `path($SELECTOR)`.

Running JSON through `tostream` will produce a stream of arrays, each of which will have one or two elements. Those arrays that have two elements will be leaf nodes that contain the `path` of the node as the first element of the array, and the value of the node as the second element. The arrays with only one element will contain the `path` of the last element of the array or object being streamed for which the leaf node was just printed; my guess is that this serves as an indicator that this array or object is done, and a new one will be starting (or the prior one will be ending). In any event, these one-element arrays can be ignored, as only the leaf nodes have the needed values; all of that happens inside of the `select` (as explained in the next segment).

<details>
<summary>

###### `tostream` example

</summary>

Running the [input JSON](#example-json) through the filter `tostream` results in the following stream of output:

```json
[
  [
    "cat",
    "domesticated",
    0,
    "petname"
  ],
  "Fluffy"
]
[
  [
    "cat",
    "domesticated",
    0,
    "breed"
  ],
  "Bengal"
]
[
  [
    "cat",
    "domesticated",
    0,
    "breed"
  ]
]
[
  [
    "cat",
    "domesticated",
    1,
    "petname"
  ],
  "Misty"
]
[
  [
    "cat",
    "domesticated",
    1,
    "breed"
  ],
  "domestic short hair"
]
[
  [
    "cat",
    "domesticated",
    1,
    "color"
  ],
  "yellow"
]
[
  [
    "cat",
    "domesticated",
    1,
    "color"
  ]
]
[
  [
    "cat",
    "domesticated",
    1
  ]
]
[
  [
    "cat",
    "domesticated"
  ]
]
[
  [
    "cat"
  ]
]
```

Notice that at the end, all of streamed arrays are one-element arrays, indicating that the array or object at that level has come to an end. It doesn't make much sense to me why there wasn't a better/easier/more intuitive way of representing that, but I've never processed any type of data as a stream, in any language, so what do I know? Thankfully, these one-element arrays can be ignored.

</details>

References:
[Variable/Symbolic Binding Operator](https://jqlang.org/manual/#variable-symbolic-binding-operator),
[`path`](https://jqlang.org/manual/#path),
[`tostream`](https://jqlang.org/manual/#tostream),
[`select`](https://jqlang.org/manual/#select),
[Streaming](https://jqlang.org/manual/#streaming)

---

> **`select(length > 1 and (.[0] | index($selector_path) == 0))`**

*see JQ filter overview above for explanations of: [`select(BOOLEAN EXPRESSION)`](#select)*

The input to this segment is a set of arrays composed of one or two elements; the first element is always an array of path elements for leaf nodes, and in a two-element array, the second is the value at that path.

```json
[
  [
    "cat",
    "domesticated",
    0,
    "petname"
  ],
  "Fluffy"
]
[
  [
    "cat",
    "domesticated",
    0,
    "breed"
  ],
  "Bengal"
]
[
  [
    "cat",
    "domesticated",
    0,
    "breed"
  ]
]
```

The `BOOLEAN EXPRESSION` filter will find the ones being looked for and pass them through, tossing the others aside. The first conditional looks at the size of the input array (via `length`) and looks for ones that are larger than one; they represent the leaf nodes, the ones that have values. The `and` works like a normal boolean operator in that both sides need to be true in order for the whole thing to be true, which is what's needed for `select` to keep it. The second condition grabs the first element of the two-element array, an array of the path elements of the lead node, and looks to see if those path elements match against the extract selector's path elements stored in `$selector_path`. Specifically, it uses `index` to find out *where* it matches, with an index position of 0 indicating that it matched at the beginning of the string. Those elements that meet that criteria are selected and are passed into the `reduce` filter's `ACCUMULATOR` expression.

References:
[`select`](https://jqlang.org/manual/#select),
[`length`](https://jqlang.org/manual/#length),
[`and`](https://jqlang.org/manual/#and-or-not),
[Array Index (`.[0]`)](https://jqlang.org/manual/#array-index),
[`index`](https://jqlang.org/manual/#index-rindex),
[`==`](https://jqlang.org/manual/#==-!=)

---

> **`( null; setpath($selected[0]; $selected[1]) )`**

*see the JQ filter overview above for explanations of: [`reduce EXPRESSION as $VAR (STARTING VALUE; ACCUMULATOR)`](#reduce), [`setpath(PATHS; VALUE)`](#setpath)*

This is the segment of the `reduce` filter that accumulates the results of the loop: `(STARTING VALUE; ACCUMULATOR)` (see previous filter segments for a description of what `reduce` is actually looping through). The accumulated results are initialized with the JSON primitive `null`, and then `reduce` loops through its values, calling `ACCUMULATOR` once for each value that makes it out of `EXPRESSION`.

`setpath` will set the element described by `PATHS` to `VALUE`, where `PATHS` is an array of strings & numbers describing the element to be set.

For each iteration, the value of `reduce`'s `EXPRESSION` loop is stored in `$selected` and will look something like this:

```json
[
  [
    "cat",
    "domesticated",
    1,
    "color"
  ],
  "yellow"
]
```

where the first element of the array is the `PATHS` describing the "where", and the second element is the `VALUE` to be set at that described location. This is done with the `$VAR[x]` phrase, which is just shorthand for `$var | .[x]`, allowing the Array Index to grab the specific array element needed. Here, `setpath` is grabbing the first element of the array (`$selected[0]`) to use as the `PATHS` and then the second element of the array (`$selected[1]`) to use as the value. These individual selected elements are built up into a final, extracted sub-set of the original JSON passed in.

References:
[`reduce`](https://jqlang.org/manual/#reduce),
[`null`](https://www.rfc-editor.org/rfc/rfc8259.html#section-1) (RFC 8259),
[`setpath`](https://jqlang.org/manual/#setpath),
[Array Index (`.[0]`)](https://jqlang.org/manual/#array-index)

</details>

---

[//]: # (==================================================================)

### `require_results`

```jq
def require_results:
    if length > 0 then . else (. = "" | halt_error(1)) end;
```

<details>
<summary>

###### filter annotation

</summary>

If this filter is present at all, it will always come after all output transformations, but before the `post_process_output` filter. Whether or not it's present depends on the `-N|--results_required` option being set; only then will the filter be defined and called.

The expected input is an array, an object, or `null`.

---

> **`if length > 0 then . else (. = "" | halt_error(1)) end;`**

> > **NOTE:** *this section needs some work -- might be good to mention how parentheses work*

This uses the `if-then-else` filter which has the form `if A then B elif C else D end`. Both `elif C` and `else D` are independently optional, and `elif C` can be given multiple times. The `length` filter is pretty overloaded, allowing it to be called with any type of input, and is being used to look for an array or object with at least one element. If that's found (i.e. the conditional is true) then this passes along the input unchanged to the next filter (via '`.`'). If it's not found the current input is cleared out by assigning an empty string to it and then execution is halted, setting the exit code of the process to '1'.

References:

[`if-then-else`](https://jqlang.org/manual/#if-then-else-end),
[`length`](https://jqlang.org/manual/#length),
[Identity ('`.`')](https://jqlang.org/manual/#identity),
[Plain Assignment ('`=`')](https://jqlang.org/manual/#plain-assignment),
[`halt_error`](https://jqlang.org/manual/#halt_error)

</details>

---

[//]: # (==================================================================)

### `post_process_output`

```jq
def post_process_output:
    $OUTPUT_FILTER | $STRIP_ARRAY;
```

<details>
<summary>

###### filter annotation

</summary>

This filter expects to receive flattened JSON as its input:

```json
{
  "cat.domesticated.0.petname": "Fluffy",
  "cat.domesticated.0.breed": "Bengal",
  "cat.domesticated.0.color": "",
  "cat.domesticated.1.petname": "Misty",
  "cat.domesticated.1.breed": "domestic short hair",
  "cat.domesticated.1.color": "yellow"
}
```

If this filter is present at all, it will always be the final one, coming in after all other transformations. Whether or not it's present depends on one of the following options being given: `-K|--keys`, `-V|--values`. Only when one of them are in effect will the filter be defined and called.

---

> **`$OUTPUT_FILTER | $STRIP_ARRAY`**

> > **NOTE:** *this section needs some work -- the use of `-V` sets **`OUTPUT_FILTER`** to `[ .[] ]`; add array constructor to references*

The filter itself is very straightforward: the input will be passed through two simple filters. The value of **`$OUTPUT_FILTER`** depends on which of the options are given. If only the keys are wanted (`-K|--keys`), then **`$OUTPUT_FILTER`** is set to `keys_unsorted`, which will pull out all of the keys in the object (without sorting them). If only the values are wanted (`-V|--values`), then **`$OUTPUT_FILTER`** is set to `.[]`, which will pull out all of the values in the object. Both will produce an array of elements.

If the user has requested "raw output" via the `-r|--raw` option to JQG then **`$STRIP_ARRAY`** will be set to `.[]`, which will remove the outer array from the results. The default value for **`$STRIP_ARRAY`**, though, is `.`, which will just pass the input through unchanged.

References:
[`keys_unsorted`](https://jqlang.org/manual/#keys-keys_unsorted),
[Array/Object Value Iterator ('`.[]`')](https://jqlang.org/manual/#array-object-value-iterator),
[raw output](https://jqlang.org/manual/#invoking-jq),
[Identity ('`.`')](https://jqlang.org/manual/#identity)

</details>

## License

[Apache-2.0](../LICENSE)<br />
© 2021 Joseph Casadonte
