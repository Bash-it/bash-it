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
  if [[ ! $SLOW_TESTS ]]; then
    skip 'myip is slow - run only with SLOW_TESTS=true'
  fi

  run myip
  assert_success
  declare -r mask_ip=$(echo $output | tr -s '[0-9]' '?')
  [[ $mask_ip == 'Your public IP is: ?.?.?.?' ]]
}

@test 'plugins base: pickfrom()' {
  stub_file="${BASH_IT_ROOT}/stub_file"
  printf "l1\nl2\nl3" > $stub_file
  run pickfrom $stub_file
  assert_success
  [[ $output == l? ]]
}

@test 'plugins base: mkcd()' {
  cd "${BASH_IT_ROOT}"
  run mkcd -dir_with_dash
  assert_success
}

@test 'plugins base: lsgrep()' {
  for i in 1 2 3; do mkdir -p "${BASH_IT_TEST_DIR}/${i}"; done
  cd $BASH_IT_TEST_DIR
  run lsgrep 2
  assert_success
  assert_equal 2 $output
}

@test 'plugins base: buf()' {
  declare -r file="${BASH_IT_ROOT}/file"
  touch $file
  run buf $file
  [[ -e ${file}_$(date +%Y%m%d_%H%M%S) ]]
}
