# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
	load "${BASH_IT?}/completion/available/bash-it.completion.bash"
}

@test "completion bash-it: ensure that the _bash-it function is available" {
	run type -t _bash-it
	assert_success
	assert_output "function"
}

function __check_completion() {
	# Get the parameters as a single value
	COMP_LINE=$*

	# Get the parameters as an array
	# shellcheck disable=SC2294
	eval set -- "$@"
	COMP_WORDS=("$@")

	# Index of the cursor in the line
	COMP_POINT=${#COMP_LINE}

	# Get the last character of the line that was entered
	COMP_LAST=$((COMP_POINT - 1))

	# If the last character was a space...
	if [[ ${COMP_LINE:$COMP_LAST} = ' ' ]]; then
		# ...then add an empty array item
		COMP_WORDS+=('')
	fi

	# Word index of the last word
	COMP_CWORD=$((${#COMP_WORDS[@]} - 1))

	# Run the Bash-it completion function
	_bash-it

	# Return the completion output
	echo "${COMPREPLY[@]}"
}

@test "completion bash-it: doctor - show options" {
	run __check_completion 'bash-it doctor '
	assert_output "errors warnings all"
}

@test "completion bash-it: help - show options" {
	run __check_completion 'bash-it help '
	assert_output "aliases completions migrate plugins update"
}

@test "completion bash-it: help - aliases v" {
	run __check_completion 'bash-it help aliases v'
	assert_output "vagrant vault vim"
}

@test "completion bash-it: update - show options" {
	run __check_completion 'bash-it update '
	assert_output "stable dev"
}

@test "completion bash-it: update - show optional flags" {
	run __check_completion 'bash-it update -'
	assert_output "-s --silent"
}

@test "completion bash-it: search - show no options" {
	run __check_completion 'bash-it search '
	assert_output ""
}

@test "completion bash-it: migrate - show no options" {
	run __check_completion 'bash-it migrate '
	assert_output ""
}

@test "completion bash-it: show options" {
	run __check_completion 'bash-it '
	assert_output "disable enable help migrate reload restart preview profile doctor search show update version"
}

@test "completion bash-it: bash-ti - show options" {
	run __check_completion 'bash-ti '
	assert_output "disable enable help migrate reload restart preview profile doctor search show update version"
}

@test "completion bash-it: shit - show options" {
	run __check_completion 'shit '
	assert_output "disable enable help migrate reload restart preview profile doctor search show update version"
}

@test "completion bash-it: bashit - show options" {
	run __check_completion 'bashit '
	assert_output "disable enable help migrate reload restart preview profile doctor search show update version"
}

@test "completion bash-it: batshit - show options" {
	run __check_completion 'batshit '
	assert_output "disable enable help migrate reload restart preview profile doctor search show update version"
}

@test "completion bash-it: bash_it - show options" {
	run __check_completion 'bash_it '
	assert_output "disable enable help migrate reload restart preview profile doctor search show update version"
}

@test "completion bash-it: profile - show options" {
	run __check_completion 'bash-it profile '
	assert_output "load save list rm"
}

@test "completion bash-it: profile load - show options" {
	run __check_completion 'bash-it profile load '
	assert_output "default"
}

@test "completion bash-it: show - show options" {
	run __check_completion 'bash-it show '
	assert_output "aliases completions plugins"
}

@test "completion bash-it: enable - show options" {
	run __check_completion 'bash-it enable '
	assert_output "alias completion plugin"
}

@test "completion bash-it: enable - show options a" {
	run __check_completion 'bash-it enable a'
	assert_output "alias"
}

@test "completion bash-it: disable - show options" {
	run __check_completion 'bash-it disable '
	assert_output "alias completion plugin"
}

@test "completion bash-it: disable - show options a" {
	run __check_completion 'bash-it disable a'
	assert_output "alias"
}

@test "completion bash-it: disable - provide nothing when atom is not enabled" {
	run __check_completion 'bash-it disable alias ato'
	assert_output ""
}

@test "completion bash-it: disable - provide 'all' when atom is not enabled" {
	run __check_completion 'bash-it disable alias a'
	assert_output "all"
}

@test "completion bash-it: disable - provide the a* aliases when atom is enabled with the old location and name" {
	run ln -s "$BASH_IT/aliases/available/atom.aliases.bash" "$BASH_IT/aliases/enabled/atom.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/atom.aliases.bash"

	run ln -s "$BASH_IT/completion/available/apm.completion.bash" "$BASH_IT/completion/enabled/apm.completion.bash"
	assert_link_exist "$BASH_IT/completion/enabled/apm.completion.bash"

	run _bash-it-component-item-is-enabled "alias" "atom"
	assert_success

	run __check_completion 'bash-it disable alias a'
	assert_output "all atom"
}

@test "completion bash-it: disable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/atom.aliases.bash" "$BASH_IT/aliases/enabled/150---atom.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/150---atom.aliases.bash"

	run ln -s "$BASH_IT/completion/available/apm.completion.bash" "$BASH_IT/completion/enabled/350---apm.completion.bash"
	assert_link_exist "$BASH_IT/completion/enabled/350---apm.completion.bash"

	run __check_completion 'bash-it disable alias a'
	assert_output "all atom"
}

@test "completion bash-it: disable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/atom.aliases.bash" "$BASH_IT/enabled/150---atom.aliases.bash"
	assert_link_exist "$BASH_IT/enabled/150---atom.aliases.bash"

	run ln -s "$BASH_IT/completion/available/apm.completion.bash" "$BASH_IT/enabled/350---apm.completion.bash"
	assert_link_exist "$BASH_IT/enabled/350---apm.completion.bash"

	run __check_completion 'bash-it disable alias a'
	assert_output "all atom"
}

@test "completion bash-it: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"

	run ln -s "$BASH_IT/plugins/available/docker-machine.plugin.bash" "$BASH_IT/plugins/enabled/docker-machine.plugin.bash"
	assert_link_exist "$BASH_IT/plugins/enabled/docker-machine.plugin.bash"

	run __check_completion 'bash-it disable plugin docker'
	assert_output "docker-machine"
}

@test "completion bash-it: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"

	run ln -s "$BASH_IT/plugins/available/docker-machine.plugin.bash" "$BASH_IT/plugins/enabled/350---docker-machine.plugin.bash"
	assert_link_exist "$BASH_IT/plugins/enabled/350---docker-machine.plugin.bash"

	run __check_completion 'bash-it disable plugin docker'
	assert_output "docker-machine"
}

@test "completion bash-it: disable - provide the docker-machine plugin when docker-machine is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/enabled/150---docker-compose.aliases.bash"

	run ln -s "$BASH_IT/plugins/available/docker-machine.plugin.bash" "$BASH_IT/enabled/350---docker-machine.plugin.bash"
	assert_link_exist "$BASH_IT/enabled/350---docker-machine.plugin.bash"

	run __check_completion 'bash-it disable plugin docker'
	assert_output "docker-machine"
}

@test "completion bash-it: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and name" {
	run ln -s "$BASH_IT/aliases/available/todo.txt-cli.aliases.bash" "$BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/todo.txt-cli.aliases.bash"

	run ln -s "$BASH_IT/plugins/available/todo.plugin.bash" "$BASH_IT/plugins/enabled/todo.plugin.bash"
	assert_link_exist "$BASH_IT/plugins/enabled/todo.plugin.bash"

	run __check_completion 'bash-it disable alias to'
	assert_output "todo.txt-cli"
}

@test "completion bash-it: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/todo.txt-cli.aliases.bash" "$BASH_IT/aliases/enabled/150---todo.txt-cli.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/150---todo.txt-cli.aliases.bash"

	run ln -s "$BASH_IT/plugins/available/todo.plugin.bash" "$BASH_IT/plugins/enabled/350---todo.plugin.bash"
	assert_link_exist "$BASH_IT/plugins/enabled/350---todo.plugin.bash"

	run __check_completion 'bash-it disable alias to'
	assert_output "todo.txt-cli"
}

@test "completion bash-it: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/todo.txt-cli.aliases.bash" "$BASH_IT/enabled/150---todo.txt-cli.aliases.bash"
	assert_link_exist "$BASH_IT/enabled/150---todo.txt-cli.aliases.bash"

	run ln -s "$BASH_IT/plugins/available/todo.plugin.bash" "$BASH_IT/enabled/350---todo.plugin.bash"
	assert_link_exist "$BASH_IT/enabled/350---todo.plugin.bash"

	run __check_completion 'bash-it disable alias to'
	assert_output "todo.txt-cli"
}

@test "completion bash-it: enable - provide the atom aliases when not enabled" {
	run __check_completion 'bash-it enable alias ato'
	assert_output "atom"
}

@test "completion bash-it: enable - provide the a* aliases when not enabled" {
	run __check_completion 'bash-it enable alias a'
	assert_output "all ag ansible apt atom"
}

@test "completion bash-it: enable - provide the a* aliases when atom is enabled with the old location and name" {
	run ln -s "$BASH_IT/aliases/available/atom.aliases.bash" "$BASH_IT/aliases/enabled/atom.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/atom.aliases.bash"

	run __check_completion 'bash-it enable alias a'
	assert_output "all ag ansible apt"
}

@test "completion bash-it: enable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/atom.aliases.bash" "$BASH_IT/aliases/enabled/150---atom.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/150---atom.aliases.bash"

	run __check_completion 'bash-it enable alias a'
	assert_output "all ag ansible apt"
}

@test "completion bash-it: enable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/atom.aliases.bash" "$BASH_IT/enabled/150---atom.aliases.bash"
	assert_link_exist "$BASH_IT/enabled/150---atom.aliases.bash"

	run __check_completion 'bash-it enable alias a'
	assert_output "all ag ansible apt"
}

@test "completion bash-it: enable - provide the docker* plugins when docker-compose is enabled with the old location and name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"

	run __check_completion 'bash-it enable plugin docker'
	assert_output "docker docker-compose docker-machine"
}

@test "completion bash-it: enable - provide the docker-* plugins when docker-compose is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"

	run __check_completion 'bash-it enable plugin docker'
	assert_output "docker docker-compose docker-machine"
}

@test "completion bash-it: enable - provide the docker-* plugins when docker-compose is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/enabled/150---docker-compose.aliases.bash"

	run __check_completion 'bash-it enable plugin docker'
	assert_output "docker docker-compose docker-machine"
}

@test "completion bash-it: enable - provide the docker* completions when docker-compose is enabled with the old location and name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"

	run __check_completion 'bash-it enable completion docker'
	assert_output "docker docker-compose docker-machine"
}

@test "completion bash-it: enable - provide the docker* completions when docker-compose is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"

	run __check_completion 'bash-it enable completion docker'
	assert_output "docker docker-compose docker-machine"
}

@test "completion bash-it: enable - provide the docker* completions when docker-compose is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/aliases/available/docker-compose.aliases.bash" "$BASH_IT/enabled/150---docker-compose.aliases.bash"
	assert_link_exist "$BASH_IT/enabled/150---docker-compose.aliases.bash"

	run __check_completion 'bash-it enable completion docker'
	assert_output "docker docker-compose docker-machine"
}

@test "completion bash-it: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and name" {
	run ln -s "$BASH_IT/plugins/available/todo.plugin.bash" "$BASH_IT/plugins/enabled/todo.plugin.bash"
	assert_link_exist "$BASH_IT/plugins/enabled/todo.plugin.bash"

	run __check_completion 'bash-it enable alias to'
	assert_output "todo.txt-cli"
}

@test "completion bash-it: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and priority-based name" {
	run ln -s "$BASH_IT/plugins/available/todo.plugin.bash" "$BASH_IT/plugins/enabled/350---todo.plugin.bash"
	assert_link_exist "$BASH_IT/plugins/enabled/350---todo.plugin.bash"

	run __check_completion 'bash-it enable alias to'
	assert_output "todo.txt-cli"
}

@test "completion bash-it: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the new location and priority-based name" {
	run ln -s "$BASH_IT/plugins/available/todo.plugin.bash" "$BASH_IT/enabled/350---todo.plugin.bash"
	assert_link_exist "$BASH_IT/enabled/350---todo.plugin.bash"

	run __check_completion 'bash-it enable alias to'
	assert_output "todo.txt-cli"
}
