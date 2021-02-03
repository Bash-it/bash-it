#!/usr/bin/env bats

load ../test_helper
load "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"
load ../../lib/log
load ../../lib/helpers

cite _about _param _example _group _author _version

load ../../completion/available/capistrano.completion

@test "alias-completion: See that aliases with double quotes and brackets do not break the plugin" {
  alias gtest="git log --graph --pretty=format:'%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset' --abbrev-commit --date=relative"
  load ../../plugins/available/alias-completion.plugin

  assert_success
}

@test "alias-completion: See that aliases with single quotes and brackets do not break the plugin" {
  alias gtest='git log --graph --pretty=format:"%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset" --abbrev-commit --date=relative'
  load ../../plugins/available/alias-completion.plugin

  assert_success
}

@test "alias-completion: See that having aliased rm command does not output unnecessary output" {
  alias rm='rm -v'
  load ../../plugins/available/alias-completion.plugin

  refute_output
}
