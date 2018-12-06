#!/usr/bin/env bats

#load ../test_helper
load ../../lib/helpers
load ../../lib/composure
load ../../plugins/available/go.plugin

@test 'plugins go: reverse path: single entry' {
  run _split_path_reverse '/foo'
  echo "output = ${output}"
  [ "$output" = "/foo" ]
}

@test 'plugins go: reverse path: single entry, colon empty' {
  run _split_path_reverse '/foo:'
  echo "output = ${output}"
  [ "$output" = "/foo" ]
}

@test 'plugins go: reverse path: single entry, colon whitespace' {
  run _split_path_reverse '/foo: '
  echo "output = ${output}"
  [ "$output" = "/foo" ]
}

@test 'plugins go: reverse path: multiple entries' {
  run _split_path_reverse '/foo:/bar'
  echo "output = ${output}"
  [ "$output" = "/bar /foo" ]
}

@test 'plugins go: single entry in GOPATH' {
  export GOPATH="/foo"
  load ../../plugins/available/go.plugin
  echo "$(echo $PATH | cut -d':' -f1,2)"
  [ "$(echo $PATH | cut -d':' -f1)" = "/foo/bin" ]
}

@test 'plugins go: multiple entries in GOPATH' {
  export GOPATH="/foo:/bar"
  load ../../plugins/available/go.plugin
  echo "$(echo $PATH | cut -d':' -f1,2)"
  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/bar/bin" ]
}
