#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load "${BASH_IT}/vendor/github.com/erichs/composure/composure.sh"

# We test `go version` in each test to account for users with goenv and no system go.

@test 'ensure _bash-it-gopath-pathmunge is defined' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  load ../../plugins/available/go.plugin
  run type -t _bash-it-gopath-pathmunge
  assert_line 'function'
}

@test 'plugins go: single entry in GOPATH' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  export GOPATH="/foo"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1 <<<$PATH)" "/foo/bin"
}

@test 'plugins go: single entry in GOPATH, with space' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  export GOPATH="/foo bar"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1 <<<$PATH)" "/foo bar/bin"
}

@test 'plugins go: single entry in GOPATH, with escaped space' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  export GOPATH="/foo\ bar"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1 <<<$PATH)" "/foo\ bar/bin"
}

@test 'plugins go: multiple entries in GOPATH' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  export GOPATH="/foo:/bar"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2 <<<$PATH)" "/foo/bin:/bar/bin"
}

@test 'plugins go: multiple entries in GOPATH, with space' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  export GOPATH="/foo:/foo bar"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2 <<<$PATH)" "/foo/bin:/foo bar/bin"
}

@test 'plugins go: multiple entries in GOPATH, with escaped space' {
  { _command_exists go && go version &>/dev/null; } || skip 'golang not found'
  export GOPATH="/foo:/foo\ bar"
  load ../../plugins/available/go.plugin
  assert_equal "$(cut -d':' -f1,2 <<<$PATH)" "/foo/bin:/foo\ bar/bin"
}
