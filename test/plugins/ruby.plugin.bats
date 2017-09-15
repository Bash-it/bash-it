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
  if ! which ruby >/dev/null; then
    skip 'ruby not installed'
  fi

  # Reset the path for this test to ensure that the ruby directory is not part of the path yet.
  PATH="/usr/local/bin:/usr/bin:/bin"

  # Then load the ruby plugin again to ensure that the ruby path is appended at the end of the path
  load ../../plugins/available/ruby.plugin

  echo $PATH

  local last_path_entry=$(echo $PATH | tr ":" "\n" | tail -1)
  [[ "${last_path_entry}" == "${HOME}"/.gem/ruby/*/bin ]]
}
