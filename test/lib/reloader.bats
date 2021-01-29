
#!/usr/bin/env bats

load ../test_helper

function local_setup {
  setup_test_fixture
  copy_test_fixtures

  # log everything to verify output
  BASH_IT_LOG_LEVEL=3
}

@test "reloader: exit-nonzero" {
  # use bash-it to enable the fixture
  load "$BASH_IT/bash_it.sh"

  run bash-it enable plugin exit-nonzero
  assert_success

  run bash-it enable plugin zz
  assert_success

  run source "${BASH_IT}/scripts/reloader.bash"
  assert_success

  # test that loading proceeds properly
  assert_line 'DEBUG: plugin: zz: Loading component...'
  assert_line 'DEBUG: plugin: zz: Loading component successful!'
  assert_line 'You found me!'

  # test that the expected plugin is acting as expected
  assert_line 'DEBUG: bash: exit-nonzero.bash: Loading component...'
  assert_line 'ERROR: bash: exit-nonzero.bash: Loading component failed...'
  assert_line 'ERROR: bash: exit-nonzero.bash: exit-nonzero: stdout message'
  assert_line 'ERROR: bash: exit-nonzero.bash: exit-nonzero: stderr message'
}

@test "reloader: exit-zero" {
  # use bash-it to enable the fixture
  load "$BASH_IT/bash_it.sh"

  run bash-it enable plugin exit-zero
  assert_success

  run bash-it enable plugin zz
  assert_success

  run source "${BASH_IT}/scripts/reloader.bash"
  assert_success

  assert_line 'DEBUG: plugin: zz: Loading component...'
  assert_line 'DEBUG: plugin: zz: Loading component successful!'
  assert_line 'You found me!'

  assert_line 'DEBUG: bash: exit-zero.bash: Loading component...'
  assert_line 'DEBUG: bash: exit-zero.bash: Loading component successful!'
  assert_line 'exit-zero: stdout message'
  assert_line 'exit-zero: stderr message'
}

@test "reloader: return-nonzero" {
  # use bash-it to enable the fixture
  load "$BASH_IT/bash_it.sh"

  run bash-it enable plugin return-nonzero
  assert_success

  run bash-it enable plugin zz
  assert_success

  run source "${BASH_IT}/scripts/reloader.bash"
  assert_success

  assert_line 'DEBUG: plugin: zz: Loading component...'
  assert_line 'DEBUG: plugin: zz: Loading component successful!'
  assert_line 'You found me!'

  assert_line 'DEBUG: bash: return-nonzero.bash: Loading component...'
  assert_line 'ERROR: bash: return-nonzero.bash: Loading component failed...'
  assert_line 'ERROR: bash: return-nonzero.bash: return-nonzero: stdout message'
  assert_line 'ERROR: bash: return-nonzero.bash: return-nonzero: stderr message'
}

@test "reloader: return-zero" {
  # use bash-it to enable the fixture
  load "$BASH_IT/bash_it.sh"

  run bash-it enable plugin return-zero
  assert_success

  run bash-it enable plugin zz
  assert_success

  run source "${BASH_IT}/scripts/reloader.bash"
  assert_success

  assert_line 'DEBUG: plugin: zz: Loading component...'
  assert_line 'DEBUG: plugin: zz: Loading component successful!'
  assert_line 'You found me!'

  assert_line 'DEBUG: bash: return-zero.bash: Loading component...'
  assert_line 'DEBUG: bash: return-zero.bash: Loading component successful!'
  assert_line 'return-zero: stdout message'
  assert_line 'return-zero: stderr message'
}
