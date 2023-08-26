#!/usr/bin/env bats

#----------------------------------------------------------------------
#--- jqg/test/014-failed-option-validation.bats
#----------------------------------------------------------------------
#--- test option validation
#----------------------------------------------------------------------
#   -t / --output
#   -T / --input
#----------------------------------------------------------------------

setup_file() { load common; common_setup_file; }
teardown_file() { load common; common_teardown_file; }
setup() { load common; common_setup; }
teardown() { load common; common_teardown; }


# unknown output transformation: qwerty
@test "unknown output transform: qwerty" {
    run jqg -t qwerty
    assert_failure 2
    assert_output --partial unknown
}

# unknown output transformation: qwerty
@test "unknown output transform: qwerty (long)" {
    run jqg --output qwerty
    assert_failure 2
    assert_output --partial unknown
}

# unknown input transformation: qwerty
@test "unknown input transform: qwerty" {
    run jqg -T qwerty
    assert_failure 2
    assert_output --partial unknown
}

# unknown input transformation: qwerty
@test "unknown input transform: qwerty (long)" {
    run jqg --input qwerty
    assert_failure 2
    assert_output --partial unknown
}
