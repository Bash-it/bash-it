#!/usr/bin/env bats

load ../test_helper
load $BATS_TEST_DIRNAME/../../lib/composure/composure.sh
run pwd
run echo $BASH_IT

@test "lib composure: composure_keywords()" {
  run composure_keywords
  assert_output "about author example group param version"
}
