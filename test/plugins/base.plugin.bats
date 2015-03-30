#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../plugins/available/base.plugin

@test 'plugins base: ips()' {
  if [[ $CI ]]; then
    skip 'ifconfig probably requires sudo on TravisCI'
  fi

  declare -r localhost='127.0.0.1'
  run ips
  assert_success
  assert_line $localhost
}

@test 'plugins base: myip()' {
  if [[ ! $CI ]]; then
    skip 'myip is slow - run only on CI'
  fi

  run myip
  assert_success
  declare -r mask_ip=$(echo $output | tr -s '[0-9]' '?')
  [[ $mask_ip == 'Your public IP is: ?.?.?.?' ]]
}

@test 'plugins base: pickfrom()' {
  mkdir -p $BASH_IT_ROOT
  stub_file="${BASH_IT_ROOT}/stub_file"
  printf "l1\nl2\nl3" > $stub_file
  run pickfrom $stub_file
  assert_success
  [[ $output == l? ]]
}
