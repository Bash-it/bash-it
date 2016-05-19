#!/usr/bin/env bats

load ../../lib/composure
load ../../plugins/available/base.plugin

cite _about _param _example _group _author _version

load ../../lib/helpers
load ../../lib/search

NO_COLOR=true

@test "helpers search aliases" {
  run _bash-it-search-component 'plugins' 'base'
  [[ "${lines[0]}" =~ 'plugins' && "${lines[0]}" =~ 'base' ]]
}

@test "helpers search ruby gem bundle rake rails" {
  # first disable them all, so that  the output does not appear with a checkbox
  # and we can compoare the result
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' 'rails' '--disable'
  # Now perform the search
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' 'rails'
  # And verify
  [[ "${lines[0]/✓/}" == '      aliases  =>   bundler rails' ]] && \
  [[ "${lines[1]/✓/}" == '      plugins  =>   chruby chruby-auto killrails ruby' ]] && \
  [[ "${lines[2]/✓/}" == '  completions  =>   bundler gem rake' ]]
}

@test "search ruby gem bundle -chruby rake rails" {
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' 'rails' '--disable'
  run _bash-it-search 'ruby' 'gem' 'bundle' '-chruby' 'rake' 'rails'
  [[ "${lines[0]/✓/}" == '      aliases  =>   bundler rails' ]] && \
  [[ "${lines[1]/✓/}" == '      plugins  =>   killrails ruby' ]] && \
  [[ "${lines[2]/✓/}" == '  completions  =>   bundler gem rake' ]]
}

@test "search (rails enabled) ruby gem bundle rake rails" {
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' 'rails' '--disable'
  run _enable-alias 'rails'
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' 'rails'
  [[ "${lines[0]}"    == '      aliases  =>   bundler ✓rails' ]] && \
  [[ "${lines[1]}"    == '      plugins  =>   chruby chruby-auto killrails ruby' ]] && \
  [[ "${lines[2]}"    == '  completions  =>   bundler gem rake' ]]
}

@test "search (all enabled) ruby gem bundle rake rails" {
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' '-chruby' 'rails' '--enable'
  run _bash-it-search 'ruby' 'gem' 'bundle' 'rake' '-chruby' 'rails'
  [[ "${lines[0]}"    == '      aliases  =>   ✓bundler ✓rails' ]] && \
  [[ "${lines[1]}"    == '      plugins  =>   ✓killrails ✓ruby' ]] && \
  [[ "${lines[2]}"    == '  completions  =>   ✓bundler ✓gem ✓rake' ]]
}
