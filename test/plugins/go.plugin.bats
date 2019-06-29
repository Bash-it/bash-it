#!/usr/bin/env bats

##
# Travis notes:
# - `$PATH`
#   - /home/travis/build/Bash-it/bash-it/test_lib/bats-core/libexec
#   - /home/travis/bin
#   - /home/travis/.local/bin
#   - /opt/pyenv/shims
#   - /home/travis/.phpenv/shims
#   - /home/travis/perl5/perlbrew/bin
#   - /home/travis/.nvm/versions/node/v8.9.1/bin
#   - /home/travis/.kiex/elixirs/elixir-1.4.5/bin
#   - /home/travis/.kiex/bin
#   - /home/travis/.rvm/gems/ruby-2.4.1/bin
#   - /home/travis/.rvm/gems/ruby-2.4.1@global/bin
#   - /home/travis/.rvm/rubies/ruby-2.4.1/bin
#   - /home/travis/gopath/bin
#   - /home/travis/.gimme/versions/go1.7.4.linux.amd64/bin
#   - /usr/local/phantomjs/bin
#   - /usr/local/phantomjs
#   - /usr/local/neo4j-3.2.7/bin
#   - /usr/local/maven-3.5.2/bin
#   - /usr/local/cmake-3.9.2/bin
#   - /usr/local/clang-5.0.0/bin
#   - /usr/local/sbin
#   - /usr/local/bin
#   - /usr/sbin
#   - /usr/bin
#   - /sbin
#   - /bin
#   - /home/travis/.rvm/bin
#   - /home/travis/.phpenv/bin
#   - /opt/pyenv/bin
#   - /home/travis/.yarn/bin
# - `which go`
#   - /home/travis/.gimme/versions/go1.7.4.linux.amd64/bin/go
# - `go env GOROOT` & `$GOROOT`
#   - /home/travis/.gimme/versions/go1.7.4.linux.amd64
# - `go env GOPATH` & `GOPATH`
#   - /home/travis/gopath
#

load ../test_helper
load ../../lib/helpers
load ../../lib/composure

@test 'ensure _go_pathmunge_wrap is defined' {
  load ../../plugins/available/go.plugin
  run type -t _go_pathmunge_wrap
  assert_line 'function'
}

@test 'debug travis' {
  export GOROOT='/foo'
  export GOPATH='/bar'
  export PATH='/usr/bin:/bin:/usr/sbin'

  load ../../plugins/available/go.plugin

  assert_equal $PATH 'dummy'
}

#@test 'plugins go: single entry in GOPATH' {
#  export GOROOT='/baz'
#  export GOPATH='/foo'
#  load ../../plugins/available/go.plugin
#  assert_equal $(cut -d':' -f1,2 <<<$PATH) '/foo/bin:/baz/bin'
#}
#
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
