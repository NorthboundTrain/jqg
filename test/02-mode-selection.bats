setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'
    # load 'test_helper/bats-file/load'

    # get the containing directory of this file
    # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
    # as those will point to the bats executable's location or the preprocessed file respectively
    DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
    # make executables in src/ visible to PATH
    PATH="$DIR/../src:$PATH"

    CITRUS_JSON=$DIR/citrus.json
}

# flatten (default)
@test "[02] flatten (default)" {
    run jqg rangpur $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -f / flatten
@test "[02] -f / flatten" {
    run jqg -f rangpur $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -f / flatten (long)
@test "[02] -f / flatten (long)" {
    run jqg --flatten rangpur $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -s / search
@test "[02] -s / search" {
    run jqg -s rangpur $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -s / search (long)
@test "[02] -s / search (long)" {
    run jqg --search rangpur $CITRUS_JSON
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# -u / unflatten
@test "[02] -u / unflatten" {
    run bash -c "jqg rangpur $CITRUS_JSON | jqg -u"
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
@test "[02] -u / unflatten (long)" {
    run bash -c "jqg rangpur $CITRUS_JSON | jqg --unflatten"
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

# flatten twice
@test "[02] flatten twice" {
    run bash -c "jqg rangpur $CITRUS_JSON | jqg -f"
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}

# unflatten twice
@test "[02] unflatten twice" {
    run bash -c "jqg rangpur $CITRUS_JSON | jqg -u | jqg -u"
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

# -f -> -u override
@test "[02] f -> u override" {
    run bash -c "jqg rangpur $CITRUS_JSON | jqg -f -u"
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

# -u -> -f override
@test "[02] u -> f override" {
    run bash -c "jqg rangpur $CITRUS_JSON | jqg -u -f"
    assert_success
    assert_output - <<EOF
{
  "hybrid.lime.sub-categories.0": "Rangpur lime"
}
EOF
}
