#!/usr/bin/env perl

#***************************************************************************
#*** gen-examples-md.pl - generate doc/jqg-examples.md file from test/99-examples.bats
#*** Copyright 2021 Joseph Casadonte
#***************************************************************************
#*** Licensed under the Apache License, Version 2.0 (the "License");
#*** you may not use this file except in compliance with the License.
#*** You may obtain a copy of the License at
#***
#*** http://www.apache.org/licenses/LICENSE-2.0
#***
#*** Unless required by applicable law or agreed to in writing, software
#*** distributed under the License is distributed on an "AS IS" BASIS,
#*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#*** See the License for the specific language governing permissions and
#*** limitations under the License.
#***************************************************************************
#*** project URL: https://github.com/NorthboundTrain/jqg
#***************************************************************************

#***** some pragmas *****
use strict;
use warnings;

use 5.014;

use FindBin;
use lib $FindBin::Bin;

#***** include some files *****
use Data::Dumper; $Data::Dumper::Sortkeys = !0;
use IO::File;

#***** constants *****
our($BATS_FILE) = "$FindBin::Bin/99-examples.bats";
our($MD_FILE) = "$FindBin::Bin/../doc/jqg-examples.md";

our($CARNIVORA_JSON_FILE) = "$FindBin::Bin/carnivora.json";
our($ODD_VALUES_JSON_FILE) = "$FindBin::Bin/odd-values.json";

our($NOW) = time;

#***** global vars *****



#***************************************************************************
#***************************************************************************
#***************************************************************************
#***************************************************************************
#***************************************************************************

#***** backup existing output file *****
if (-f $MD_FILE) {
    my($bak) = $MD_FILE;
    $bak =~ s{\.md$}{-$NOW.md};

    rename($MD_FILE, $bak) || die qq([ERROR] Cannot rename "$MD_FILE" to "$bak" - $1\n);
}

#***** start new output file *****
my($out) = IO::File->new(">$MD_FILE");
die qq([ERROR] Cannot open "$MD_FILE" for output - $!\n) unless $out;

#***** read in two example JSON files *****
my($carnivora_json) = readJson($CARNIVORA_JSON_FILE);
my($odd_values_json) = readJson($ODD_VALUES_JSON_FILE);

#***** add pre-example content *****
$out->print(<<"EOS");
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
$carnivora_json
```

</details>

<details>
<summary>odd-values.json</summary>

```json
$odd_values_json
```

</details>
EOS

#***** open up BATS file for reading *****
my($in) = IO::File->new("<$BATS_FILE");
die qq([ERROR] Cannot open "$BATS_FILE" for input - $!\n) unless $in;

#***** loop through BATS file looking for examples *****
my($HEADING_OR_START_TEST, $EXPORT_RUN_OR_SKIP, $ASSERT_OUTPUT, $EOF) = (1 .. 999);

my($test_desc, $test_note, $test_export, $test_cmd, $test_output);
my($looking_for) = $HEADING_OR_START_TEST;
while (<$in>) {
    chomp;

    s{\$CARNIVORA_JSON}{carnivora.json}g;
    s{\$ODD_VALUES_JSON}{odd-values.json}g;

    # ## Search Criteria Examples
    if (($looking_for == $HEADING_OR_START_TEST) && (m{^\s*##\s+(.*)$})) {
        my($header) = $1;


        $out->say("\n[//]: # (" . ('=' x 66) . ")\n\n## $1");

        next;
    }

    # @test "[99] case-insensitive search (default)" {
    elsif (($looking_for == $HEADING_OR_START_TEST) && (m{^\s*\@test\s+"\[[^]]+]\s+(.*)"})) {
        $test_desc = $1;
        $looking_for = $EXPORT_RUN_OR_SKIP;
        next;
    }

    # skip "due to a bug ..."
    elsif (($looking_for == $EXPORT_RUN_OR_SKIP) && (m{^\s*skip\s+"([^"]+)\"})) {
        $test_note = $1;
        next;
    }

    # export JQG_OPTS="-q -S"
    elsif (($looking_for == $EXPORT_RUN_OR_SKIP) && (m{^\s*(export .*)})) {
        $test_export = $1;
        next;
    }

    # run  jqg -v 'f|(?-i:M)' $CARNIVORA_JSON
    elsif (($looking_for == $EXPORT_RUN_OR_SKIP) && (m{^\s*run\s+(jqg\s+.*)\s*$})) {
        $test_cmd = $1;

        $looking_for = $ASSERT_OUTPUT;
        next;
    }

    # run  bash -c "jq . $CARNIVORA_JSON | jqg feli | jq -S -c"
    elsif (($looking_for == $EXPORT_RUN_OR_SKIP) && (m{^\s*run\s+bash -c\s+"(.*)"\s*$})) {
        $test_cmd = $1;

        $looking_for = $ASSERT_OUTPUT;
        next;
    }

    # assert_output - <<EOF
    elsif (($looking_for == $ASSERT_OUTPUT) && (m{^\s*assert_output})) {
        $looking_for = $EOF;
        $test_output = [];
        next;
    }

    # EOF
    elsif (($looking_for == $EOF) && (m{^EOF$})) {
        die unless $test_desc;
        die unless scalar(@$test_output);
        die unless $test_cmd;


        #----- print out the test header -----
        $out->say(<<"EOS");

[//]: # (------------------------------------------------------------------)
<details>
<summary>$test_desc</summary>
EOS

        #----- possible print out a note -----
        $out->say("<p/>\n\n**Note:** *$test_note*\n") if $test_note;

        #----- start the example -----
        $out->say("```json");

        #----- possible print out export line -----
        $out->say("\$ $test_export") if $test_export;

        #----- normal test -----
        $out->say("\$ $test_cmd");

        #----- print expected output -----
        foreach my $line (@$test_output) {
            $out->say($line);
        }

        #----- print test footer -----
        $out->say("```\n\n</details>");

        #----- clear out test vars -----
        $test_desc = $test_note = $test_export = $test_cmd = $test_output = undef;

        #----- search for next one -----
        $looking_for = $HEADING_OR_START_TEST;

        next;
    }

    # (accumulating output)
    elsif ($looking_for == $EOF) {
        push(@$test_output, $_);
        next;
    }
}

$in->close;
$out->close;

#***************************************************************************
sub readJson
{
    my($filename) = @_;

    #***** slurp up the file *****
    my($in) = IO::File->new("<$filename");
    my($json) = do { local $/; <$in> };
    $in->close;

    chomp($json);

    $json
}

#***************************************************************************
#*****  EOF  *****  EOF  *****  EOF  *****  EOF  *****  EOF  ***************
