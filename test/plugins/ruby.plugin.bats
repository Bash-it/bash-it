#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load ../../lib/composure
load ../../plugins/available/ruby.plugin

@test "plugins ruby: remove_gem is defined" {
  run type remove_gem
  assert_line 1 "remove_gem () "
}

@test "plugins ruby: PATH includes ~/.gem/ruby/bin" {
  last_path_entry=$(echo $PATH | tr ":" "\n" | tail -1);
  [[ "${last_path_entry}" == "${HOME}"/.gem/ruby/*/bin ]]
}
