#!/usr/bin/env bats

load ../test_helper
load "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"

@test "lib composure: _composure_keywords()" {
  run _composure_keywords
  assert_output "about author example group param version"
}
