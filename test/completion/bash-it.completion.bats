#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../completion/available/bash-it.completion

function local_setup {
  mkdir -p "$BASH_IT"
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  # Use rsync to copy Bash-it to the temp folder
  # rsync is faster than cp, since we can exclude the large ".git" folder
  rsync -qavrKL -d --delete-excluded --exclude=.git $lib_directory/../.. "$BASH_IT"

  rm -rf "$BASH_IT"/enabled
  rm -rf "$BASH_IT"/aliases/enabled
  rm -rf "$BASH_IT"/completion/enabled
  rm -rf "$BASH_IT"/plugins/enabled

  mkdir -p "$BASH_IT"/enabled
  mkdir -p "$BASH_IT"/aliases/enabled
  mkdir -p "$BASH_IT"/completion/enabled
  mkdir -p "$BASH_IT"/plugins/enabled

  # Don't pollute the user's actual $HOME directory
  # Use a test home directory instead
  export BASH_IT_TEST_CURRENT_HOME="${HOME}"
  export BASH_IT_TEST_HOME="$(cd "${BASH_IT}/.." && pwd)/BASH_IT_TEST_HOME"
  mkdir -p "${BASH_IT_TEST_HOME}"
  export HOME="${BASH_IT_TEST_HOME}"
}

function local_teardown {
  export HOME="${BASH_IT_TEST_CURRENT_HOME}"

  rm -rf "${BASH_IT_TEST_HOME}"

  assert_equal "${BASH_IT_TEST_CURRENT_HOME}" "${HOME}"
}

@test "completion bash-it: ensure that the _bash-it-comp function is available" {
  type -a _bash-it-comp &> /dev/null
  assert_success
}

function __check_completion () {
  # Get the parameters as an array
  eval set -- "$@"
  COMP_WORDS=("$@")

  # Get the parameters as a single value
  COMP_LINE=$*

  # Index of the cursor in the line
  COMP_POINT=${#COMP_LINE}

  # Word index of the last word
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

  # Run the Bash-it completion function
  _bash-it-comp

  # Return the completion output
  echo "${COMPREPLY[@]}"
}

@test "completion bash-it: disable - provide nothing when atom is not enabled" {
  run __check_completion 'bash-it disable alias ato'
  assert_line "0" ""
}

@test "completion bash-it: disable - provide all when atom is not enabled" {
  run __check_completion 'bash-it disable alias a'
  assert_line "0" "all"
}

@test "completion bash-it: disable - provide the a* aliases when atom is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/atom.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/atom.aliases.bash" ]

  ln -s $BASH_IT/completion/available/apm.completion.bash $BASH_IT/completion/enabled/apm.completion.bash
  assert [ -L "$BASH_IT/completion/enabled/apm.completion.bash" ]

  run __check_completion 'bash-it disable alias a'
  assert_line "0" "all atom"
}

@test "completion bash-it: disable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/150---atom.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/150---atom.aliases.bash" ]

  ln -s $BASH_IT/completion/available/apm.completion.bash $BASH_IT/completion/enabled/350---apm.completion.bash
  assert [ -L "$BASH_IT/completion/enabled/350---apm.completion.bash" ]

  run __check_completion 'bash-it disable alias a'
  assert_line "0" "all atom"
}

@test "completion bash-it: disable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/enabled/150---atom.aliases.bash
  assert [ -L "$BASH_IT/enabled/150---atom.aliases.bash" ]

  ln -s $BASH_IT/completion/available/apm.completion.bash $BASH_IT/enabled/350---apm.completion.bash
  assert [ -L "$BASH_IT/enabled/350---apm.completion.bash" ]

  run __check_completion 'bash-it disable alias a'
  assert_line "0" "all atom"
}

@test "completion bash-it: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/docker-compose.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/docker-compose.aliases.bash" ]

  ln -s $BASH_IT/plugins/available/docker-machine.plugin.bash $BASH_IT/plugins/enabled/docker-machine.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/docker-machine.plugin.bash" ]

  run __check_completion 'bash-it disable plugin docker'
  assert_line "0" "docker-machine"
}

@test "completion bash-it: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/150---docker-compose.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash" ]

  ln -s $BASH_IT/plugins/available/docker-machine.plugin.bash $BASH_IT/plugins/enabled/350---docker-machine.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/350---docker-machine.plugin.bash" ]

  run __check_completion 'bash-it disable plugin docker'
  assert_line "0" "docker-machine"
}

@test "completion bash-it: disable - provide the docker-machine plugin when docker-machine is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/enabled/150---docker-compose.aliases.bash
  assert [ -L "$BASH_IT/enabled/150---docker-compose.aliases.bash" ]

  ln -s $BASH_IT/plugins/available/docker-machine.plugin.bash $BASH_IT/enabled/350---docker-machine.plugin.bash
  assert [ -L "$BASH_IT/enabled/350---docker-machine.plugin.bash" ]

  run __check_completion 'bash-it disable plugin docker'
  assert_line "0" "docker-machine"
}

@test "completion bash-it: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/todo.txt-cli.aliases.bash $BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash" ]

  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/plugins/enabled/todo.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/todo.plugin.bash" ]

  run __check_completion 'bash-it disable alias to'
  assert_line "0" "todo.txt-cli"
}

@test "completion bash-it: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/todo.txt-cli.aliases.bash $BASH_IT/aliases/enabled/150---todo.txt-cli.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/150---todo.txt-cli.aliases.bash" ]

  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/plugins/enabled/350---todo.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/350---todo.plugin.bash" ]

  run __check_completion 'bash-it disable alias to'
  assert_line "0" "todo.txt-cli"
}

@test "completion bash-it: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/todo.txt-cli.aliases.bash $BASH_IT/enabled/150---todo.txt-cli.aliases.bash
  assert [ -L "$BASH_IT/enabled/150---todo.txt-cli.aliases.bash" ]

  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/enabled/350---todo.plugin.bash
  assert [ -L "$BASH_IT/enabled/350---todo.plugin.bash" ]

  run __check_completion 'bash-it disable alias to'
  assert_line "0" "todo.txt-cli"
}

@test "completion bash-it: enable - provide the atom aliases when not enabled" {
  run __check_completion 'bash-it enable alias ato'
  assert_line "0" "atom"
}

@test "completion bash-it: enable - provide the a* aliases when not enabled" {
  run __check_completion 'bash-it enable alias a'
  assert_line "0" "all ag ansible apt atom"
}

@test "completion bash-it: enable - provide the a* aliases when atom is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/atom.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/atom.aliases.bash" ]

  run __check_completion 'bash-it enable alias a'
  assert_line "0" "all ag ansible apt"
}

@test "completion bash-it: enable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/150---atom.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/150---atom.aliases.bash" ]

  run __check_completion 'bash-it enable alias a'
  assert_line "0" "all ag ansible apt"
}

@test "completion bash-it: enable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/enabled/150---atom.aliases.bash
  assert [ -L "$BASH_IT/enabled/150---atom.aliases.bash" ]

  run __check_completion 'bash-it enable alias a'
  assert_line "0" "all ag ansible apt"
}

@test "completion bash-it: enable - provide the docker-* plugins when nothing is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/docker-compose.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/docker-compose.aliases.bash" ]

  run __check_completion 'bash-it enable plugin docker'
  assert_line "0" "docker-compose docker-machine docker"
}

@test "completion bash-it: enable - provide the docker-* plugins when nothing is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/150---docker-compose.aliases.bash
  assert [ -L "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash" ]

  run __check_completion 'bash-it enable plugin docker'
  assert_line "0" "docker-compose docker-machine docker"
}

@test "completion bash-it: enable - provide the docker-* plugins when nothing is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/enabled/150---docker-compose.aliases.bash
  assert [ -L "$BASH_IT/enabled/150---docker-compose.aliases.bash" ]

  run __check_completion 'bash-it enable plugin docker'
  assert_line "0" "docker-compose docker-machine docker"
}

@test "completion bash-it: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and name" {
  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/plugins/enabled/todo.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/todo.plugin.bash" ]

  run __check_completion 'bash-it enable alias to'
  assert_line "0" "todo.txt-cli"
}

@test "completion bash-it: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/plugins/enabled/350---todo.plugin.bash
  assert [ -L "$BASH_IT/plugins/enabled/350---todo.plugin.bash" ]

  run __check_completion 'bash-it enable alias to'
  assert_line "0" "todo.txt-cli"
}

@test "completion bash-it: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/plugins/available/todo.plugin.bash $BASH_IT/enabled/350---todo.plugin.bash
  assert [ -L "$BASH_IT/enabled/350---todo.plugin.bash" ]

  run __check_completion 'bash-it enable alias to'
  assert_line "0" "todo.txt-cli"
}
