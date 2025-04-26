# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
	# Load something, anything...
	load ../../completion/available/capistrano.completion
}

@test "alias-completion: See that aliases with double quotes and brackets do not break the plugin" {
	alias gtest="git log --graph --pretty=format:'%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset' --abbrev-commit --date=relative"
	run load "${BASH_IT?}/completion/available/aliases.completion.bash"

	assert_success
}

@test "alias-completion: See that aliases with single quotes and brackets do not break the plugin" {
	alias gtest='git log --graph --pretty=format:"%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset" --abbrev-commit --date=relative'
	run load "${BASH_IT?}/completion/available/aliases.completion.bash"

	assert_success
}

@test "alias-completion: See that having aliased rm command does not output unnecessary output" {
	alias rm='rm -v'
	run load "${BASH_IT?}/completion/available/aliases.completion.bash"

	assert_output ""
}
