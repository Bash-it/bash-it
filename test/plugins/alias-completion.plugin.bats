#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../lib/log
load ../../lib/helpers

cite _about _param _example _group _author _version

load ../../completion/available/git.completion

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
