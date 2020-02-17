#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../lib/helpers
load ../../lib/utilities
load ../../lib/search
load ../../plugins/available/base.plugin
load ../../aliases/available/git.aliases
load ../../plugins/available/ruby.plugin
load ../../plugins/available/rails.plugin
load ../../completion/available/bundler.completion
load ../../completion/available/gem.completion
load ../../completion/available/rake.completion

cite _about _param _example _group _author _version

load ../../lib/helpers

function local_setup {
  mkdir -p "$BASH_IT"
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  # Use rsync to copy Bash-it to the temp folder
  # rsync is faster than cp, since we can exclude the large ".git" folder
  rsync -qavrKL -d --delete-excluded --exclude=.git $lib_directory/../../.. "$BASH_IT"

  rm -rf "$BASH_IT"/enabled
  rm -rf "$BASH_IT"/aliases/enabled
  rm -rf "$BASH_IT"/completion/enabled
  rm -rf "$BASH_IT"/plugins/enabled
  rm -rf "$BASH_IT"/tmp/cache

  mkdir -p "$BASH_IT"/enabled
  mkdir -p "$BASH_IT"/aliases/enabled
  mkdir -p "$BASH_IT"/completion/enabled
  mkdir -p "$BASH_IT"/plugins/enabled

  export OLD_PATH="$PATH"
  export PATH="/usr/bin:/bin:/usr/sbin"
}

function local_teardown {
  export PATH="$OLD_PATH"
  unset OLD_PATH
}

@test "search: plugin base" {
  export BASH_IT_SEARCH_USE_COLOR=false
  run _bash-it-search-component 'plugins' 'base'
  assert_line -n 0 '      plugins:  base  '
}

@test "search: git" {
  run _bash-it-search 'git' --no-color
  assert_line -n 0 '      aliases:  git   gitsvn  '
  assert_line -n 1 '      plugins:  autojump   git   git-subrepo   jgitflow   jump  '
  assert_line -n 2 '  completions:  git   git_flow   git_flow_avh  '
}

@test "search: ruby gem bundle rake rails" {
  run _bash-it-search rails ruby gem bundler rake --no-color

  assert_line -n 0 '      aliases:  bundler   rails  '
  assert_line -n 1 '      plugins:  chruby   chruby-auto   rails   ruby  '
  assert_line -n 2 '  completions:  bundler   gem   rake  '
}

@test "search: rails ruby gem bundler rake -chruby" {
  run _bash-it-search rails ruby gem bundler rake -chruby --no-color

  assert_line -n 0 '      aliases:  bundler   rails  '
  assert_line -n 1 '      plugins:  rails   ruby  '
  assert_line -n 2 '  completions:  bundler   gem   rake  '
}

@test "search: @git" {
  run _bash-it-search '@git' --no-color
  assert_line -n 0 '      aliases:  git  '
  assert_line -n 1 '      plugins:  git  '
  assert_line -n 2 '  completions:  git  '
}

@test "search: @git --enable / --disable" {
  set -e
  run _bash-it-search '@git' --enable --no-color
  run _bash-it-search '@git' --no-color

  [[ "${lines[0]}"  =~ '✓' ]]

  run _bash-it-search '@git' --disable --no-color
  run _bash-it-search '@git' --no-color

  assert_line -n 0 '      aliases:  git  '
  assert_line -n 0 '      aliases:  git  '
  assert_line -n 2 '  completions:  git  '
}
