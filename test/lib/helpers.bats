#!/usr/bin/env bats

load ../../lib/composure
cite _about _param _example _group _author _version

load ../../lib/helpers
load ../../plugins/available/base.plugin

NO_COLOR=true

@test "helpers search aliases" {
  run _bash-it-search-component 'plugins' 'base'
  [[ "${lines[0]}" =~ 'plugins: base' ]]
}
