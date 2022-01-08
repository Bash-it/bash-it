#!/usr/bin/env bats

load ../test_helper

@test "lib composure: _composure_keywords()" {
  run _composure_keywords
  assert_output "about author example group param version"
}
