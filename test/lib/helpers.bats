#!/usr/bin/env bats

load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers

NO_COLOR=true

@test "helpers search aliases" {
  run _bash-it-search-component 'plugins' 'base'
  [[ "${lines[0]}" =~ 'plugins' && "${lines[0]}" =~ 'base' ]]
}

@test "helpers search all ruby et al" {
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' 'rails'
  [[ "${lines[0]}" == 'aliases     : bundler rails' ]]
  [[ "${lines[1]}" == 'plugins     : chruby chruby-auto ruby' ]]
  [[ "${lines[2]}" == 'completions : bundler gem rake' ]]
}
