#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"
load ../../plugins/available/ruby.plugin

function local_setup {
  setup_test_fixture

  _command_exists "ruby" && mkdir -p "$(ruby -e 'print Gem.user_dir')/bin"

  export OLD_PATH="$PATH"
  export PATH="/usr/bin:/bin:/usr/sbin"
}

function local_teardown {
  export PATH="$OLD_PATH"
  unset OLD_PATH
}

@test "plugins ruby: remove_gem is defined" {
  run type remove_gem
  assert_line -n 1 "remove_gem () "
}

@test "plugins ruby: PATH includes ~/.gem/ruby/bin" {
  if ! which ruby >/dev/null; then
    skip 'ruby not installed'
  fi

  load ../../plugins/available/ruby.plugin

  local last_path_entry=$(echo $PATH | tr ":" "\n" | tail -1)
  [[ "${last_path_entry}" == "${HOME}"/.gem/ruby/*/bin ]]
}
