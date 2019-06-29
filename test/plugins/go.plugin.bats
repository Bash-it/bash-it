#!/usr/bin/env bats

load ../test_helper
load ../../lib/helpers
load ../../lib/composure
load ../../plugins/available/go.plugin

@test 'ensure _go_pathmunge_wrap is defined' {
  [[ $(type -t _go_pathmunge_wrap) = 'function' ]]
}

@test 'debug where is go in travis' {
  assert_equal $(which go) 'dummy'
}

@test 'debug gopath in travis' {
  assert_equal $(go env GOPATH) 'dummy'
}

@test 'debug goroot in travis' {
  assert_equal $GOROOT 'dummy'
}

@test 'debug goroot in travis, after load' {
  export GOROOT='/tmp'
  load ../../plugins/available/go.plugin
  assert_equal $GOROOT 'dummy'
  assert_equal $(go env GOROOT) 'dummy'
}

@test 'plugins go: single entry in GOPATH' {
  export GOROOT='/baz'
  export GOPATH='/foo'
  load ../../plugins/available/go.plugin
  assert_equal $(cut -d':' -f1,2 <<<$PATH) '/foo/bin:/baz/bin'
}

#@test 'plugins go: single entry in GOPATH, with space' {
#  export GOROOT="/baz"
#  export GOPATH="/foo bar"
#  load ../../plugins/available/go.plugin
#
#  echo "$(echo $PATH | cut -d':' -f1)"
#  [ "$(echo $PATH | cut -d':' -f1)" = "/foo bar/bin" ]
#
#  echo "$(echo $PATH | cut -d':' -f2)"
#  [ "$(echo $PATH | cut -d':' -f2)" = "/baz/bin" ]
#}
#
#@test 'plugins go: single entry in GOPATH, with escaped space' {
#  export GOROOT="/baz"
#  export GOPATH="/foo\ bar"
#  load ../../plugins/available/go.plugin
#
#  echo "$(echo $PATH | cut -d':' -f1)"
#  [ "$(echo $PATH | cut -d':' -f1)" = "/foo\ bar/bin" ]
#
#  echo "$(echo $PATH | cut -d':' -f2)"
#  [ "$(echo $PATH | cut -d':' -f2)" = "/baz/bin" ]
#}
#
#@test 'plugins go: multiple entries in GOPATH' {
#  export GOROOT="/baz"
#  export GOPATH="/foo:/bar"
#  load ../../plugins/available/go.plugin
#
#  echo "$(echo $PATH | cut -d':' -f1,2)"
#  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/bar/bin" ]
#
#  echo "$(echo $PATH | cut -d':' -f3)"
#  [ "$(echo $PATH | cut -d':' -f3)" = "/baz/bin" ]
#}
#
#@test 'plugins go: multiple entries in GOPATH, with space' {
#  export GOROOT="/baz"
#  export GOPATH="/foo:/foo bar"
#  load ../../plugins/available/go.plugin
#
#  echo "$(echo $PATH | cut -d':' -f1,2)"
#  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/foo bar/bin" ]
#
#  echo "$(echo $PATH | cut -d':' -f3)"
#  [ "$(echo $PATH | cut -d':' -f3)" = "/baz/bin" ]
#}
#
#@test 'plugins go: multiple entries in GOPATH, with escaped space' {
#  export GOROOT="/baz"
#  export GOPATH="/foo:/foo\ bar"
#  load ../../plugins/available/go.plugin
#
#  echo "$(echo $PATH | cut -d':' -f1,2)"
#  [ "$(echo $PATH | cut -d':' -f1,2)" = "/foo/bin:/foo\ bar/bin" ]
#
#  echo "$(echo $PATH | cut -d':' -f3)"
#  [ "$(echo $PATH | cut -d':' -f3)" = "/baz/bin" ]
#}
