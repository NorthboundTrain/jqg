#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/002-mode-selection.bats
#----------------------------------------------------------------------
#--- test the mode-selection options
#----------------------------------------------------------------------
#   -s / --search
#   -f / --flatten (deprecated)
#   -u / --unflatten
#   -x / --extract
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }



# search (default)
@test "search (default)" {
    run jqg rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -s / search
@test "s / search" {
    run jqg -s rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -s / search (long)
@test "s / search (long)" {
    run jqg --search rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -f / flatten
@test "f / flatten" {
    bats_require_minimum_version 1.5.0 # silences BW02
    run --separate-stderr jqg -f rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -f / flatten (long)
@test "f / flatten (long)" {
    bats_require_minimum_version 1.5.0 # silences BW02
    run --separate-stderr jqg --flatten rangpur $citrus_json
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -u / unflatten
@test "u / unflatten" {
    run bash -c "jqg rangpur $citrus_json | jqg -u"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# -u / unflatten (long)
@test "u / unflatten (long)" {
    run bash -c "jqg rangpur $citrus_json | jqg --unflatten"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# -x / extract
@test "x / extract" {
    run jqg -x .core $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core": [
    "citron",
    "mandarin",
    "pomelo",
    "pompeda",
    "kumquat"
  ]
}
EOF
}

# -x / extract (long)
@test "x / extract (long)" {
    run jqg --extract .core $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core": [
    "citron",
    "mandarin",
    "pomelo",
    "pompeda",
    "kumquat"
  ]
}
EOF
}



# -s -> -u override
@test "s -> u override" {
    run bash -c "jqg rangpur $citrus_json | jqg -s -u"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# -u -> -s override
@test "u -> s override" {
    run bash -c "jqg rangpur $citrus_json | jqg -u -s"
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -s -> -x override (with valid selector)
@test "s -> x override (selector)" {
    run jqg -s -x .core $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core": [
    "citron",
    "mandarin",
    "pomelo",
    "pompeda",
    "kumquat"
  ]
}
EOF
}

# -x -> -s override (with valid selector)
@test "x -> s override (selector)" {
    run jqg -x -s .core $citrus_json
    assert_success
    assert_output - <<EOF
{}
EOF
}

# -s -> -x override (with valid filter)
@test "s -> x override (filter)" {
    run jqg -s -x core $citrus_json
    assert_failure # JQ exit code
}

# -x -> -s override (with valid filter)
@test "x -> s override (filter)" {
    run jqg -x -s core $citrus_json
    assert_success
    assert_output - <<EOF
{
  "core.0": "citron",
  "core.1": "mandarin",
  "core.2": "pomelo",
  "core.3": "pompeda",
  "core.4": "kumquat"
}
EOF
}

# -u -> -x override (with valid selector)
@test "u -> x override (selector)" {
    run bash -c "jqg rangpur $citrus_json | jqg -u -x .hybrid"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# -x -> -u override (with valid selector)
@test "x -> u override (selector)" {
    run bash -c "jqg rangpur $citrus_json | jqg -x -u .hybrid"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}

# -x -> -u override (with invalid selector)
@test "x -> u override (invalid selector)" {
    run bash -c "jqg rangpur $citrus_json | jqg -x -u .qpwoeiruty"
    assert_success
    assert_output - <<EOF
{
  "hybrid": {
    "lime": {
      "sub-categories": [
        "Rangpur lime"
      ]
    }
  }
}
EOF
}
