#!/usr/bin/env bats

load ../../lib/composure
cite _about _param _example _group _author _version

load ../../lib/helpers
load ../../plugins/available/base.plugin

export NO_COLOR=true

@test "helpers search aliases" {
  run _bash-it-search-category 'plugins' 'base'
  echo "the lines are: ${output[*]}"
  [[ "${lines[0]}" =~ 'plugins: base' ]]
}
