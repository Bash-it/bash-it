#!/usr/bin/env bats

load ../test_helper
load ../test_helper_libs

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
  load ../../plugins/available/ruby.plugin

  run type remove_gem
  assert_line -n 1 "remove_gem () "
}

@test "plugins ruby: PATH includes ~/.gem/ruby/bin" {
  if ! type ruby >/dev/null; then
    skip 'ruby not installed'
  fi

  mkdir -p "$(ruby -e 'print Gem.user_dir')/bin"

  load ../../plugins/available/ruby.plugin

  local last_path_entry="$(tail -1 <<<"${PATH//:/$'\n'}")"
  [[ "${last_path_entry}" == "$(ruby -e 'print Gem.user_dir')/bin" ]]
}
