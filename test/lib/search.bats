# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
  setup_libs "search"
}

function local_setup() {
    # shellcheck disable=SC2034
    BASH_IT_SEARCH_USE_COLOR=false
}

@test "search: plugin base" {
  export BASH_IT_SEARCH_USE_COLOR=false
  run _bash-it-search-component 'plugins' 'base'
  assert_line -n 0 '      plugins: base   '
}

@test "search: git" {
  run _bash-it-search 'git' --no-color
  assert_line -n 0 '      aliases: git   gitsvn   '
  assert_line -n 1 -p '      plugins:'
  for plugin in "autojump" "git" "gitstatus" "git-subrepo" "jgitflow" "jump"
  do
    echo $plugin
    assert_line -n 1 -p $plugin
  done
  assert_line -n 2 '  completions: git   git_flow   git_flow_avh   github-cli   '
}

@test "search: ruby gem bundle rake rails" {
  run _bash-it-search rails ruby gem bundler rake --no-color

  assert_line -n 0 '      aliases: bundler   rails   '
  assert_line -n 1 '      plugins: chruby   chruby-auto   rails   ruby   '
  assert_line -n 2 '  completions: bundler   gem   rake   '
}

@test "search: rails ruby gem bundler rake -chruby" {
  run _bash-it-search rails ruby gem bundler rake -chruby --no-color

  assert_line -n 0 '      aliases: bundler   rails   '
  assert_line -n 1 '      plugins: rails   ruby   '
  assert_line -n 2 '  completions: bundler   gem   rake   '
}

@test "search: @git" {
  run _bash-it-search '@git' --no-color
  assert_line -n 0 '      aliases: git   '
  assert_line -n 1 '      plugins: git   '
  assert_line -n 2 '  completions: git   '
}

@test "search: @git --enable / --disable" {
  set -e
  run _bash-it-search '@git' --enable --no-color
  run _bash-it-search '@git' --no-color

  [[ "${lines[0]}"  =~ '✓' ]]

  run _bash-it-search '@git' --disable --no-color
  run _bash-it-search '@git' --no-color

  assert_line -n 0 '      aliases: git   '
  assert_line -n 1 '      plugins: git   '
  assert_line -n 2 '  completions: git   '
}
