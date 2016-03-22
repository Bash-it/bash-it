#!/usr/bin/env bats

load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers

NO_COLOR=true
IS_DARWIN=false
[[ "$(uname -s)" == "Darwin" ]] && IS_DARWIN=true

if [ "$IS_DARWIN" == "true" ]; then
  @test "helpers search aliases" {
    run _bash-it-search-component 'plugins' 'base'
    [[ "${lines[0]}" =~ 'plugins' && "${lines[0]}" =~ 'base' ]]
  }
fi
