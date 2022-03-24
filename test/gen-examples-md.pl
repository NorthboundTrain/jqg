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
our($MD_FILE) = "$FindBin::Bin/../docs/jqg-examples.md";

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
my($TEST_ELEMENT_OR_HEADER, $ASSERT_OUTPUT_EOF) = (1 .. 999);

my($test) = undef;
my($looking_for) = $TEST_ELEMENT_OR_HEADER;
while (<$in>) {
    chomp;

    s{\$CARNIVORA_JSON}{carnivora.json}g;
    s{\$ODD_VALUES_JSON}{odd-values.json}g;

    if (($looking_for == $TEST_ELEMENT_OR_HEADER) && (m{^\s*\}\s*$})) {
        #----- dump previous test (if any) -----
        if ($test) {
            $out->say(<<"EOS");

[//]: # (------------------------------------------------------------------)
<details>
<summary>$test->{'description'}</summary>
EOS

            #----- loop through test elements -----
            my($codeblock_opened) = 0;
            foreach my $elem (@{$test->{'elements'}}) {
                my($element_type) = $elem->[0];
                my($element_value) = $elem->[1];

                #----- possible print out a note -----
                if ($element_type eq "skip") {
                    $out->say("```\n\n") if $codeblock_opened;
                    $codeblock_opened = 0;

                    $out->say("<p/>\n\n**Test Skipped - ** *$element_value*\n");
                    next;
                }

                #----- start the example -----
                $out->say("```bash") unless $codeblock_opened++;

                #----- print out comments -----
                if ($element_type eq "#") {
                    $out->say("$element_type $element_value");
                }

                #----- print out exports -----
                elsif ($element_type eq "export") {
                    $out->say("\$ $element_type $element_value");
                }

                #----- print out command lines -----
                elsif ($element_type eq "run") {
                    $out->say("\$ $element_value");
                }

                #----- print out JSON output -----
                elsif ($element_type eq "output") {
                    $out->say($element_value);
                }
                else {
                    die qq([ERROR] Unknown test element: [ $element_type : $element_value ]\n);
                }
            }

            #----- print test footer -----
            $out->say("```\n") if $codeblock_opened;
            $out->say("</details>");

            $test = undef;
        }
    }

    # ## Search Criteria Examples
    elsif (($looking_for == $TEST_ELEMENT_OR_HEADER) && (m{^\s*##\s+(.*)$})) {
        my($header) = $1;

        $out->say("\n[//]: # (" . ('=' x 66) . ")\n\n## $header");

        $test = undef;
    }

    # @test "[99] case-insensitive search (default)" {
    elsif (($looking_for == $TEST_ELEMENT_OR_HEADER) && (m{^\s*\@test\s+"\[[^]]+]\s+(.*)"})) {
        my($test_desc) = $1;

        $test = { description => $test_desc, elements => [] };
    }

    # (various test elements)
    elsif (($looking_for == $TEST_ELEMENT_OR_HEADER) &&
           ((m{^\s*(#)\s*(.*?)\s*$}) ||                 # # some comment
            (m{^\s*(skip)\s+"([^"]+)\"}) ||             # skip "due to a bug ..."
            (m{^\s*(export)\s+(.*)\s*$}) ||             # export JQG_OPTS="-q -S"
            (m{^\s*(run)\s+bash\s+-c\s+"(.*)"\s*$}) ||  # run  bash -c "jq . $CARNIVORA_JSON | jqg feli | jq -S -c"
            (m{^\s*(run)\s+(jqg\s+.*)\s*$}))) {         # run  jqg -v 'f|(?-i:M)' $CARNIVORA_JSON
        my($element_type) = $1;
        my($element_value) = $2;

        #----- skip if comment & not inside of a test -----
        next if (($element_type eq "#") && (! $test));

        #----- save off everything else -----
        push(@{$test->{'elements'}}, [$element_type, $element_value]);
    }

    # assert_output - <<EOF
    elsif (($looking_for == $TEST_ELEMENT_OR_HEADER) && (m{^\s*assert_output})) {
        $looking_for = $ASSERT_OUTPUT_EOF;
    }

    # EOF
    elsif (($looking_for == $ASSERT_OUTPUT_EOF) && (m{^EOF$})) {
        $looking_for = $TEST_ELEMENT_OR_HEADER;
    }

    # (accumulating output)
    elsif ($looking_for == $ASSERT_OUTPUT_EOF) {
        push(@{$test->{'elements'}}, ["output", $_]);
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
