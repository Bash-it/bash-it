#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure

@test "lib composure: composure_keywords()" {
  run composure_keywords
  assert_output "about author example group param version"
}
