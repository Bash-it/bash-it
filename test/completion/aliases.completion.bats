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

@test "alias-completion: wrapper passes the last alias word as the preceding word" {
	function _alias_test_complete() {
		printf '%s\n' "cmd=$1" "cur=$2" "prev=$3" "line=$COMP_LINE" "words=${COMP_WORDS[*]}" "cword=$COMP_CWORD"
	}
	function atest_cmd() { :; }
	complete -F _alias_test_complete atest_cmd
	alias atest="atest_cmd config use-context"
	load "${BASH_IT?}/completion/available/aliases.completion.bash"

	COMP_LINE="atest mi"
	COMP_POINT=${#COMP_LINE}
	COMP_WORDS=(atest mi)
	COMP_CWORD=1
	run _alias_completion::atest atest mi atest

	assert_success
	assert_line "cmd=atest_cmd"
	assert_line "cur=mi"
	assert_line "prev=use-context"
	assert_line "line=atest_cmd config use-context mi"
	assert_line "words=atest_cmd config use-context mi"
	assert_line "cword=3"
}
