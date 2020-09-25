#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load ../../lib/composure

function local_setup {
  setup_test_fixture

  export OLD_PATH="$PATH"
  export PATH="/usr/bin:/bin:/usr/sbin"

  if ! _command_exists ruby || ! ruby --version &>/dev/null ; then
    function ruby { echo -n "${HOME}/.gem/ruby/0.0.0" ; }
  fi
  if ! _command_exists gem || ! gem --version &>/dev/null ; then
    function gem { return 0 ; }
  fi
}

function local_teardown {
  export PATH="$OLD_PATH"
  unset OLD_PATH
}

@test "plugins ruby: remove_gem is defined" {
  load ../../plugins/available/ruby.plugin
  run type remove_gem
  assert_line -n 1 "remove_gem () "
}

@test "plugins ruby: PATH includes ~/.gem/ruby/bin" {
  load ../../plugins/available/ruby.plugin
  local last_path_entry=$(echo $PATH | tr ":" "\n" | head -1)
  # check that the path matches expectations, without getting caught up on the version number
  assert_equal "${last_path_entry##/*/}" "bin"
  assert_equal "${last_path_entry%/*/*}" "${HOME}/.gem/ruby"
}
