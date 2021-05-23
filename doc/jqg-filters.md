# The `jqg` Filter - Explained

A JQ program is really a series of filters that data goes through, transforming the input according the rules of the filter being executed, producing some output, which is then passed along to the next filter, or presented as the end result. The JQ syntax itself is pretty dense stuff, and the JQG filter is pretty complicated for a JQ newbie like me to understand, and it wasn't at all intuitive (to me, at least) what was happening and why through most of the steps.

I wrote this document as much for my own edification as anything else; I got some elements of the JQG filter to work through trial and error, without a full understanding of why it did or didn't work as expected. This helped me understand the whole thing.

**Note #1:** Use the [jqplay](https://jqplay.org/) site with the data below to play around with some of the sub-expressions in the filter; it really helps illustrate what each piece of syntax does. In addition, you can add in the `debug` function at any step to dump out the current input at that moment, which *really* helps illustrate what's happening.

**Note #2:** If you find any errors in my explanation, please submit a bug.

## Example JSON

The explanation below will reference the following JSON snippet:

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

## The JQG Filter

This is the JQ filter used in JQG. There are three primary filters, one to flatten the JSON, one to search it, and then one to format the output. There are four named functions defined, each of which is comprised of multiple filters. Functions themselves just collect together a group of filters, which is good to help keep it all organized and reduce code duplication.

There are two types of variables defined here: JQ variables (shown all in lower case) and BASH variables (shown all in UPPER CASE, and referred to below **`$LIKE_SO`**). In the real JQG script, the filter is escaped properly to make it through the shell into JQ, but here it's presented so that you can cut and paste it into [jqplay](https://jqplay.org/) as easily as possible. The **`$EMBEDDED_SHELL_VARIABLES`** will cause the tool problems, of course, but just replace as appropriate and you should be good to go (see the `--debug` command-line option to JQG for help with this).

```jq
def empty_leafs: select(tostring | . == "{}" or . == "[]");

def flatten_json:
    . as $data |
    [ path(.. | select(scalars|tostring), select($EMPTY_TESTS)) ] |
    map({ (map(tostring) | join("$JOIN_CHAR")) : (. as $path | . = $data | getpath($path)) }) |
    reduce .[] as $item ({ }; . + $item);

def filter_json:
    to_entries |
    map(select($SEARCH_ELEM | tostring | test("${REGEX//\/\\}"; "${CASE_REGEX}xn"))) |
    from_entries;

def format_output: $OUT_FILTER | $STRIP_ARRAY;

flatten_json | $FILTER_JSON | format_output
```

Different filters are separated by a pipe ('`|`') or a comma ('`,`'); the pipe is analogous to a shell pipe, where the output of the first filter is used as the input to the following filter, whereas with the comma, the input to each filter is the same and the output is the concatenation of each filter's results.

The different functions are explained individually in one or more sections below; each section will have a heading of "[`function name`] Filter: " or "[`function name`] Filter Segment #x:" , e.g. "\[`empty_leafs`] Filter:" or "\[`flatten_json`] Filter Segment #2:".

References:
[Defining Functions](https://stedolan.github.io/jq/manual/#DefiningFunctions),
[pipe](https://stedolan.github.io/jq/manual/#Pipe:|),
[comma](https://stedolan.github.io/jq/manual/#Comma:,)

---

### Filter Overview: `flatten_json | $FILTER_JSON | format_output`

This is the JQG filter at its simplest. The first part flattens the input JSON by calling the function `flatten_json`, the second part filters the JSON (the exact nature of the filter is held in the shell variable name **`$FILTER_JSON`**), and the third part formats the output via the function named `format_output`. The explanation of each of these filters and functions are laid out below.

---

### [`empty_leafs`] Filter: `select(tostring | . == "{}" or . == "[]")`

This function may or may not be called as part of `flatten_json` -- see the `flatten_json` Filter Segment #2 below for details.

`select()` will filter its input by some criteria; if the criteria evaluates to `false` or `null`, the item is not selected and therefor does not make it out of the filter, otherwise it is selected. The `tostring` filter will take its input and convert it to a string (if it's not a string already). We only care about empty objects (`{}`) and empty arrays (`[]`); those will be selected, anything else will be rejected. Note that JQ's definition of `or` is not quite the same as "or" in most conventional programming languages, but for our purposes it effectively is like the "or" in most other languages.

References:
[select](https://stedolan.github.io/jq/manual/#select(boolean_expression)),
[tostring](https://stedolan.github.io/jq/manual/#tostring),
[or](https://stedolan.github.io/jq/manual/#and/or/not),
["or" versus "//"](https://github.com/stedolan/jq/wiki/FAQ#or-versus-)

---

### [`flatten_json`] Filter Segment #1: `. as $data |`

The `expression as $identifier` construct is called the "Variable/Symbolic Binding Operator". It takes the result of the *expression* and stores it into the named JQ variable, but *expression* will not actually change the input, so the input passes through to the next filter as-is.

This specific filter segment will take the result of the *expression* and store it in the variable `$data` for later use. The input to this segment is the original JSON; since the *expression* is simply '`.`', this will save the original JSON into the JQ variable named `$data`.

References:
[Identity ('`.`')](https://stedolan.github.io/jq/manual/#Identity:.),
[Variable/Symbolic Binding Operator](https://stedolan.github.io/jq/manual/#Variable/SymbolicBindingOperator:...as$identifier|...)

---

### [`flatten_json`] Filter Segment #2: `[ path(.. | select(scalars|tostring), select($EMPTY_TESTS)) ] |`

Out of everything documented here, understanding the `path(path expression)` function was the hardest thing for me. The crux of the issue was that I didn't understand what happened inside of the *path expression*; although the input to the `path` filter is sent to the *path expression*, how that input is changed inside of the *path expression* has no effect on the `path` filter's output. It (mostly) makes sense now, but it took me a bit to get to that understanding.

`path()` outputs an array of elements of the object keys and array indices of its input. Examples from our JSON above would be: `[ "cat" ]`, `[ "cat", "domesticated" ]`, `[ "cat", "domesticated", 0 ]`, `[ "cat", "domesticated", 0, "petname" ]`, `[ "cat", "domesticated", 0, "breed" ]`. This is done for each element in the *path expression* that matches the input to `path()` itself.

The *path expression* is made up of two filters. The first one, `..`, recursively descends through each element of the input, one element at a time, producing every value. The second filter, `select()`, will filter its input by some criteria; if the criteria evaluates to `false` or `null`, the item is not selected and therefor does not make it out of the filter, otherwise it is selected. Here there are two `select` functions separated by a comma, which means that the same input is presented to both `select` functions and the results are concatenated together.

The main selection criteria is `select(scalars|tostring)`. The `scalars` function will only select the end nodes of the JSON structure -- JQ calls them the 'non-iterables', i.e. the nodes without children, or the non-interim nodes (e.g. not `[ "cat" ]`, `[ "cat", "domesticated" ]`, or `[ "cat", "domesticated", 0 ]` -- just `[ "cat", "domesticated", 0, "petname" ]` and `[ "cat", "domesticated", 0, "breed" ]`). The `scalars` function will return just the values of the end nodes to then be evaluated by `select`; before that happens, though, those values are run through the `tostring` function so that a value of `false` or `null` will be turned into `"false"` and `"null"`, preventing `select` from rejecting them (it will also turn `20` into `"20"` and `true` into `"true"`, which we don't care about -- but they also don't hurt).

The value of **`$EMPTY_TESTS`** depends on whether or not `-e` or `-E` is specified on the JQG command line; if `-e` is given (which is the default) then empty arrays (`[]`) and empty objects (`{}`) are considered to be end nodes for our purposes, and if `-E` is given then they are not. The filter for `-e` is the function `empty_leafs` (see above); the filter for `-E` is just the JSON value of `false`, which will never be selected.

The results of this compound filter (`select(...), select(...)`) will cause the *path expression* to "match" for some pieces of the JSON structure, and `path()` will grab the path elements of each of those matches as an array, as described above, e.g. the path elements for `fluffy` & `misty` would be `[ "cat", "domesticated", 0, "petname" ]` and `[ "cat", "domesticated", 1, "petname" ]`, respectively. Finally, the brackets `[ ... ]` will take all of the selected results and store them in an outer array, e.g. `[[ "cat", "domesticated", 0, "petname" ], [ "cat", "domesticated", 1, "petname" ]]`.

References:
[path](https://stedolan.github.io/jq/manual/#path(path_expression)),
[Path Expressions](https://github.com/stedolan/jq/wiki/jq-Language-Description#Path-Expressions),
[Recursive Descent (..)](https://stedolan.github.io/jq/manual/#RecursiveDescent:..),
[select](https://stedolan.github.io/jq/manual/#select(boolean_expression)),
[comma](https://stedolan.github.io/jq/manual/#Comma:,),
[scalars](https://stedolan.github.io/jq/manual/#arrays,objects,iterables,booleans,numbers,normals,finites,strings,nulls,values,scalars),
[tostring](https://stedolan.github.io/jq/manual/#tostring),
[Array Construction](https://stedolan.github.io/jq/manual/#Arrayconstruction:[])

---

### [`flatten_json`] Filter Segment #3: `map({ (map(tostring) | join("$JOIN_CHAR")) : (. as $path | . = $data | getpath($path)) }) |`

This segment is pretty busy, so we'll look at the individual pieces and then put them together. Once that's done, though, you'll (hopefully) see that it's not all that complicated.

`map()` runs the filter inside the parens on each element of the input, returning the output as an array. Through each iteration, `.` will represent the data being processed for that iteration through the map.

`{}` constructs objects, with the key separated from the value by a colon.

The expression `map({ ... : ... })` will take an array as input, and create an array of objects as output.  In the JQG filter, the input for each iteration is an array of path elements, e.g. `["cat","domesticated",0,"petname"]`.

The "key" for the new object is constructed using this expression: `(map(tostring) | join("$JOIN_CHAR"))`. The `tostring` filter will take its input and create a string out of it; strings are left as-is, numbers, booleans, and `null` are put in quotes, and everything else is encoded as JSON strings. The path element array above would be transformed into `["cat","domesticated","0","petname"]` -- not too exciting, but necessary to handle some edge cases.

`join()` takes an array of strings and joins them together into a single string, separated with the join character specified. **`$JOIN_CHAR`** is a shell script variable, which can be set using `-j <str>`; it is `.` by default. It will automatically convert numbers and booleans into strings, but nulls, arrays, and objects are converted into an empty string; because each element was converted to a string already via `tostring`, though, these empty strings are avoided.

Taken together, this `map(...) | join(...)` expression will take the path elements `["cat","domesticated",0,"petname"]` and create a key string of `"cat.domesticated.0.petname"`.

The "value" for the object is constructed using the expression: `(. as $path | . = $data | getpath($path))`. The first piece of this, `. as $path`, will take the current input (e.g. `["cat","domesticated",0,"petname"]`) and save it into a JQ variable named `$path` to be referenced later (this is called the "Variable/Symbolic Binding Operator"). This is needed because `. = $data` will take the value of the JQ variable `$data` and make it the current input (`$data` was saved back in the first filter segment). Finally, `getpath()` will take the current input and lookup the value represented by an array of path elements passed into it. At this point, the current input (`.`) has been set to `$data`, which is the original input to the whole filter, and `$path` is the array of path elements in the current iteration of map, e.g. `["cat","domesticated",0,"petname"]`, the result of which is a value, in this case `Fluffy`.

Putting the key and value expression results together, we get something like the following: `{"cat.domesticated.0.petname":"Fluffy"}` -- repeat this for each end node in the JSON input, stick the whole thing back into an array, and move on to the next segment.

References:
[map](https://stedolan.github.io/jq/manual/#map(x),map_values(x)),
[Object Construction](https://stedolan.github.io/jq/manual/#ObjectConstruction:{}),
[tostring](https://stedolan.github.io/jq/manual/#tostring),
[join](https://stedolan.github.io/jq/manual/#join(str)),
[Variable/Symbolic Binding Operator](https://stedolan.github.io/jq/manual/#Variable/SymbolicBindingOperator:...as$identifier|...),
[Assignment](https://stedolan.github.io/jq/manual/#Assignment),
[getpath](https://stedolan.github.io/jq/manual/#getpath(PATHS))

---

### [`flatten_json`] Filter Segment #4: `reduce .[] as $item ({ }; . + $item)`

The segment is not nearly as busy as the preceding segment, but what it does is a little less intuitive. In the end, though, you'll hopefully see that this, too, is not that complicated.

`reduce` works on an array, passing the array through an expression, then iterating over each result of the expression, combining it all into a single result. It takes the form: `reduce EXPRESSION as $VARIABLE (STARTING-VALUE-OF-RESULT; ACCUMULATING-OPERATION)`. It's like the `map` from the previous segment, but instead of taking an array as input and creating an array as output, it's "reducing" all of the elements of the input array into a single something as output. Or maybe it's better to think of `join` as a very specialized `reduce`; `join` takes an array of things and creates a single string as its output.

In our filter, the EXPRESSION is `.[]`, which simply iterates over all of the elements of the input array (`.[]` actually can do more than that, but that's what it's doing for us, here). Each element of data that comes out of the `.[]` filter is saved into the JQ variable `$item`, which is then passed into the accumulating section of the filter. The accumulated result is initialized as an empty object (`{}`) and then each `$item` is appended to the object as a new key/value pair. Since each `$item` is itself an object, this all works out as expected (trying to add a single element to an object would result in an error).

If you're not following that, maybe a more visual example will help. Using [jqplay](https://jqplay.org/), passing the flattened representation of the example JSON through the filter `reduce .[] as $item ({ }; debug | . + $item)` results in the following:

```json
["DEBUG:",{}]
["DEBUG:",{"cat:domesticated:0:petname":"Fluffy"}]
["DEBUG:",{"cat:domesticated:0:petname":"Fluffy","cat:domesticated:0:breed":"Bengal"}]
["DEBUG:",{"cat:domesticated:0:petname":"Fluffy","cat:domesticated:0:breed":"Bengal","cat:domesticated:1:petname":"Misty"}]
["DEBUG:",{"cat:domesticated:0:petname":"Fluffy","cat:domesticated:0:breed":"Bengal","cat:domesticated:1:petname":"Misty","cat:domesticated:1:breed":"domestic short hair"}]
{
  "cat:domesticated:0:petname": "Fluffy",
  "cat:domesticated:0:breed": "Bengal",
  "cat:domesticated:1:petname": "Misty",
  "cat:domesticated:1:breed": "domestic short hair",
  "cat:domesticated:1:color": "yellow"
}
```

You can see in the DEBUG output that the results object is built up line by line, ending as a single object with all of the array elements in it.

References:
[reduce](https://stedolan.github.io/jq/manual/#Reduce),
[Array Iterator](https://stedolan.github.io/jq/manual/#Array/ObjectValueIterator:.[]),
[Addition](https://stedolan.github.io/jq/manual/#Addition:+),
[debug](https://stedolan.github.io/jq/manual/#debug)

---

### `$FILTER_JSON`

This is the piece of the JQG filter that will search through the input JSON for the string or regex requested. To simply flatten the JSON without filtering it, use the regex '`.`' (this is also the default regex if none is given). When the regex is simply '`.`', the **`$FILTER_JSON`** shell variable is set to the same thing ('`.`'). If the regex is anything else, though, then **`$FILTER_JSON`** is set to the string "filter_json", which will call a locally-defined JQ function of the same name. This function is described below.

References:
[DefiningFunctions](https://stedolan.github.io/jq/manual/#DefiningFunctions),
[Identity ('`.`')](https://stedolan.github.io/jq/manual/#Identity:.)

---

### [`filter_json`] Filter Segment #1: `to_entries |`

Up until this point, we've done nothing more than flatten the JSON structure, transforming the arbitrarily complex JSON input into a single object with only one layer in it, comprised of lines each representing an end-node of the input JSON. Now we will transform it once again and feed it into the segment that starts to implement the filtering process.

`to_entries` takes a JSON object and breaks it out by key/value pair, creating an array of objects with the original key and value strings used as the values for two keys name "key" and "value". This is another one more easily explained visually. Given the following input:

```json
{
    "FOO.foo": "one",
    "BAR.bar": "two"
}
```

the `to_entries` filter transforms this into the following:

```json
[
  {
    "key": "FOO.foo",
    "value": "one"
  },
  {
    "key": "BAR.bar",
    "value": "two"
  }
]
```

References:
[to_entries](https://stedolan.github.io/jq/manual/#to_entries,from_entries,with_entries)

---

### [`filter_json`] Filter Segment #2: `map(select($SEARCH_ELEM | tostring | test("$REGEX"; "${CASE_REGEX}xn"))) |`

There are a bunch of **`$EMBEDDED_SHELL_VARIABLES`** here; let's look at them first.

**`$SEARCH_ELEM`** - this variable is set based on the `-k`, `-v`, and `-a` options for JQG; these options control whether the script is searching through keys, values, or both (all), respectively. If searching keys, **`$SEARCH_ELEM`** is set to use the `.key` filter; it's set to `.value` if searching values, and `.[]` for both keys and values. All three filters work on JSON objects, which are made up of key/value pairs. The first two return the value found by looking up the name given in the JSON object being looked at, or null otherwise, whereas the last one (`.[]`) iterates over all values in the object. What makes it confusing is that at the start of the filter in this segment our input is an array of objects all of which are comprised of two key/value pairs, one with a key of "key" and one with a key of "value" -- see the previous segment explanation for details.

**`$REGEX`** -- this is the regular expression being searched for. Since JQ uses [PCRE](https://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions), the capabilities here are vast, and are well beyond the scope of this document. Anything that JQ's PCRE engine can do can be used here.

**`$CASE_REGEX`** -- this is simply whether or not we're doing a case-sensitive search; it will be '`i`' if we are, and blank/empty ('') if we're not.

Now to pick apart the filter itself...

As mentioned a few segments ago, `map` runs the filter inside the parens on each value of the input array, returning the output as an array, and `select()` will filter its input by the criteria inside its parens. Taken together, `map(select(...))` will iterate over each element of the input array and produce a filtered subset of it as an output array.

The `select()` function is fairly straightforward. Each key/value object in the input array is run through the filter: one or both values are pulled out (depending on the value of **`$SEARCH_ELEM`** -- see above), it's converted to a string via `tostring`, then it's matched against the **`$REGEX`** via `test()`, which returns `true` if the regex matches, and `false` if it doesn't; `select()` will pass the input through unchanged if `true`, and toss the input away if `false`.

References:
[Object Identifier](https://stedolan.github.io/jq/manual/#ObjectIdentifier-Index:.foo,.foo.bar),
[Array Iterator](https://stedolan.github.io/jq/manual/#Array/ObjectValueIterator:.[]),
[map](https://stedolan.github.io/jq/manual/#map(x),map_values(x)),
[select](https://stedolan.github.io/jq/manual/#select(boolean_expression)),
[tostring](https://stedolan.github.io/jq/manual/#tostring),
[test](https://stedolan.github.io/jq/manual/#test(val),test(regex;flags))

---

### [`filter_json`] Filter Segment #3: `from_entries"

The input to this final filter segment is an array of key/value objects that matched the given criteria in the previous filter segment. The key/value objects need to be recombined back into its original format, which is exactly what `from_entries` does, reversing the process that `to_entries` started in the first segment of this function. Given the following input:

```json
[
  {
    "key": "FOO.foo",
    "value": "one"
  },
  {
    "key": "BAR.bar",
    "value": "two"
  }
]
```

the `from_entries` function transforms this into the following:

```json
{
    "FOO.foo": "one",
    "BAR.bar": "two"
}
```

References:
[from_entries](https://stedolan.github.io/jq/manual/#to_entries,from_entries,with_entries)

---

### [`format_output`] Filter Segment: `$OUT_FILTER | $STRIP_ARRAY"

At this point the results records have been selected, and the only processing left is to possibly limit the output based on the user's request. This is handled by the **`$OUT_FILTER`** variable, which is set based on the `-K`, `-V`, and `-A` options for JQG; these options control what is finally printed out: the keys, values, or both (all), respectively. If only the keys are wanted, then **`$OUT_FILTER`** is set to `keys_unsorted`, which will pull out all of the keys in the object (without sorting them). If only the values are wanted, then **`$OUT_FILTER`** is set to `.[]`, which will pull out all of the values in the object, and if both are wanted, it's set to `.`, which will just pass the input through unchanged. With either of the first two filters in place, an array of elements is produced, but with the last one the JSON object will remain.

If the user has requested "raw output" via the `-r` option to JQG then **`$STRIP_ARRAY`** will be set to `.[]`, but only if they've also requested to see just the keys or just the values; applying `.[]` to an array will result in just the elements of the array, without the array around it, but applying `.[]` to an object will produce an array of the values of the object, which is not what's wanted. If `-r` is given for JQG then the `-r` argument to JQ will also be set, which will remove the quotes from any bare strings. The default value for **`$STRIP_ARRAY`**, though, is `.`, which will just pass the input through unchanged. It is possible that the entire `format_output` function will be defined as `. | .` (not only is this possible, it's what will happen by default).

References:
[keys_unsorted](https://stedolan.github.io/jq/manual/#keys,keys_unsorted),
[Array Iterator](https://stedolan.github.io/jq/manual/#Array/ObjectValueIterator:.[]),
[Identity ('`.`')](https://stedolan.github.io/jq/manual/#Identity:.),
[raw output](https://stedolan.github.io/jq/manual/#Invokingjq)
