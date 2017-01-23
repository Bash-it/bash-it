#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure/composure.sh
@test "lib composure: composure_keywords()" {
  run _composure_keywords
  assert_output "about author example group param version"
}
