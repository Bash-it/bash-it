#!/usr/bin/env bats

load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers

NO_COLOR=true

IS_DARWIN=
[[ "$(uname -s)" == "Darwin" ]] && IS_DARWIN=true

@test "helpers search aliases" {
  if [ -z "$IS_DARWIN" ]; then
     skip 'search test only runs on OSX'
  fi
  run _bash-it-search-component 'plugins' 'base'
  [[ "${lines[0]}" =~ 'plugins' && "${lines[0]}" =~ 'base' ]]
}
