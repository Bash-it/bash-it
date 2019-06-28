#!/usr/bin/env bats

load ../../lib/helpers
load ../../lib/composure

@test 'plugins go: single entry in GOPATH' {
  export GOROOT="/baz"
  export GOPATH="/foo"
  load ../../plugins/available/go.plugin

  [[ "$(cut -d':' -f1,2 <<<$PATH)" == '/foo/bin:/baz/bin' ]]
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
