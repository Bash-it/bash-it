#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load ../../lib/composure
load ../../plugins/available/go.plugin

function local_setup {
  export OLD_PATH="$PATH"
  export PATH="/usr/bin:/bin:/usr/sbin"
}

function local_teardown {
  export PATH="$OLD_PATH"
  unset OLD_PATH
}

@test 'plugins go: single entry in GOPATH' {
  export GOROOT='/baz'
  export GOPATH='/foo'
  load ../../plugins/available/go.plugin

  assert_equal $(cut -d':' -f1,2 <<<$PATH | tr -d '\n') '/foo/bin:/baz/bin'
}

@test 'plugins go: single entry in GOPATH, with space' {
  export GOROOT="/baz"
  export GOPATH="/foo bar"
  load ../../plugins/available/go.plugin

  echo "$(echo $PATH | cut -d':' -f1)"
  [ "$(echo $PATH | cut -d':' -f1)" = "/foo bar/bin" ]

  echo "$(echo $PATH | cut -d':' -f2)"
  [ "$(echo $PATH | cut -d':' -f2)" = "/baz/bin" ]
}

@test 'plugins go: single entry in GOPATH, with escaped space' {
  export GOROOT="/baz"
  export GOPATH="/foo\ bar"
  load ../../plugins/available/go.plugin

  echo "$(echo $PATH | cut -d':' -f1)"
  [ "$(echo $PATH | cut -d':' -f1)" = "/foo\ bar/bin" ]

  echo "$(echo $PATH | cut -d':' -f2)"
  [ "$(echo $PATH | cut -d':' -f2)" = "/baz/bin" ]
}

@test 'plugins go: multiple entries in GOPATH' {
  export GOROOT="/baz"
  export GOPATH="/foo:/bar"
  load ../../plugins/available/go.plugin

  echo "$(echo $PATH | cut -d':' -f1,2)"
  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/bar/bin" ]

  echo "$(echo $PATH | cut -d':' -f3)"
  [ "$(echo $PATH | cut -d':' -f3)" = "/baz/bin" ]
}

@test 'plugins go: multiple entries in GOPATH, with space' {
  export GOROOT="/baz"
  export GOPATH="/foo:/foo bar"
  load ../../plugins/available/go.plugin

  echo "$(echo $PATH | cut -d':' -f1,2)"
  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/foo bar/bin" ]

  echo "$(echo $PATH | cut -d':' -f3)"
  [ "$(echo $PATH | cut -d':' -f3)" = "/baz/bin" ]
}

@test 'plugins go: multiple entries in GOPATH, with escaped space' {
  export GOROOT="/baz"
  export GOPATH="/foo:/foo\ bar"
  load ../../plugins/available/go.plugin

  echo "$(echo $PATH | cut -d':' -f1,2)"
  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/foo\ bar/bin" ]

  echo "$(echo $PATH | cut -d':' -f3)"
  [ "$(echo $PATH | cut -d':' -f3)" = "/baz/bin" ]
}
