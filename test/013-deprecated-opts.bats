#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/013-deprecated-opts.bats
#----------------------------------------------------------------------
#--- test deprecated options for message
#----------------------------------------------------------------------
#   -f / --flatten
#      / --join_colon
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }


# -f / flatten - check for deprecated message
@test "f / flatten - check for 'deprecated' message" {
    run bash -c "jqg -f rangpur $citrus_json 2>&1 >/dev/null"
    assert_success

    assert_output - <<EOF

[WARNING] The use of the command line arguments "-f" and "--flatten" are
          deprecated; they will be removed in a future release. Please switch
          to using "-s" or "--search".
EOF
}

# -f / flatten - check for deprecated message (long)
@test "f / flatten - check for 'deprecated' message (long)" {
    run bash -c "jqg --flatten rangpur $citrus_json 2>&1 >/dev/null"
    assert_success

    assert_output - <<EOF

[WARNING] The use of the command line arguments "-f" and "--flatten" are
          deprecated; they will be removed in a future release. Please switch
          to using "-s" or "--search".
EOF
}

# double -f
@test "double -f -- check for one 'deprecated' message" {
    run bash -c "jqg -f -f rangpur $citrus_json 2>&1 >/dev/null"
    assert_success

    assert_output - <<EOF

[WARNING] The use of the command line arguments "-f" and "--flatten" are
          deprecated; they will be removed in a future release. Please switch
          to using "-s" or "--search".
EOF
}

# join_colon - check for deprecated message (long)
@test "join_colon - check for 'deprecated' message" {
    run bash -c "jqg --join_colon rangpur $citrus_json 2>&1 >/dev/null"
    assert_success

    assert_output - <<EOF

[WARNING] The use of the command line argument "--join_colon" is
          deprecated; it will be removed in a future release. Please switch
          to using "-J", "--join_alt", or "--join_char".
EOF
}

# double --join_colon -- check for one deprecation message
@test "double --join_colon -- check for one 'deprecated' message" {
    run bash -c "jqg --join_colon --join_colon rangpur $citrus_json 2>&1 >/dev/null"
    assert_success

    assert_output - <<EOF

[WARNING] The use of the command line argument "--join_colon" is
          deprecated; it will be removed in a future release. Please switch
          to using "-J", "--join_alt", or "--join_char".
EOF
}

# -f / flatten & join_colon - check for deprecated message
@test "flatten & join_colon - check for 'deprecated' message" {
    run bash -c "jqg --join_colon --flatten rangpur $citrus_json 2>&1 >/dev/null"
    assert_success

    assert_output --partial - <<EOF
[WARNING] The use of the command line argument "--join_colon" is
          deprecated; it will be removed in a future release. Please switch
          to using "-J", "--join_alt", or "--join_char".
EOF

    assert_output --partial - <<EOF
[WARNING] The use of the command line arguments "-f" and "--flatten" are
          deprecated; they will be removed in a future release. Please switch
          to using "-s" or "--search".
EOF
}
