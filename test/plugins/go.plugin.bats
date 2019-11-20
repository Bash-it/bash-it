#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load ../../lib/composure

@test 'ensure _go_pathmunge_wrap is defined' {
  load ../../plugins/available/go.plugin
  run type -t _go_pathmunge_wrap
  assert_line 'function'
}

@test 'plugins go: single entry in GOPATH' {
  export GOPATH="/foo"
  export GOROOT="/baz"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2 <<<$PATH)" "/foo/bin:/baz/bin"
}

@test 'plugins go: single entry in GOPATH, with space' {
  export GOPATH="/foo bar"
  export GOROOT="/baz"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2 <<<$PATH)" "/foo bar/bin:/baz/bin"
}

@test 'plugins go: single entry in GOPATH, with escaped space' {
  export GOPATH="/foo\ bar"
  export GOROOT="/baz"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2 <<<$PATH)" "/foo\ bar/bin:/baz/bin"
}

@test 'plugins go: multiple entries in GOPATH' {
  export GOPATH="/foo:/bar"
  export GOROOT="/baz"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2,3 <<<$PATH)" "/foo/bin:/bar/bin:/baz/bin"
}

@test 'plugins go: multiple entries in GOPATH, with space' {
  export GOPATH="/foo:/foo bar"
  export GOROOT="/baz"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2,3 <<<$PATH)" "/foo/bin:/foo bar/bin:/baz/bin"
}

@test 'plugins go: multiple entries in GOPATH, with escaped space' {
  export GOPATH="/foo:/foo\ bar"
  export GOROOT="/baz"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2,3 <<<$PATH)" "/foo/bin:/foo\ bar/bin:/baz/bin"
}
