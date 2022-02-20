#!/usr/bin/env bats

load ../test_helper
load ../test_helper_libs

# Load something, anything...
load ../../completion/available/capistrano.completion

@test "alias-completion: See that aliases with double quotes and brackets do not break the plugin" {
  alias gtest="git log --graph --pretty=format:'%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset' --abbrev-commit --date=relative"
  run load ../../completion/available/aliases.completion

  assert_success
}

@test "alias-completion: See that aliases with single quotes and brackets do not break the plugin" {
  alias gtest='git log --graph --pretty=format:"%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset" --abbrev-commit --date=relative'
  run load ../../completion/available/aliases.completion

  assert_success
}

@test "alias-completion: See that having aliased rm command does not output unnecessary output" {
  alias rm='rm -v'
  run load ../../completion/available/aliases.completion

  refute_output
}
