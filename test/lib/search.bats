# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "search"
}

function local_setup() {
	# shellcheck disable=SC2034
	BASH_IT_SEARCH_USE_COLOR=false
}

@test "search: plugin base" {
	run _bash-it-search-component 'plugins' 'base'
	assert_success
	assert_line -n 0 '      plugins: base   '
}

@test "search: git" {
	local plugin completion
	run _bash-it-search 'git' --no-color

	assert_line -n 0 -p '      aliases:'
	assert_success
	for alias in 'git' 'gitsvn' 'git-omz'; do
		echo $alias
		assert_line -n 0 -p $alias
	done

	assert_line -n 1 -p '      plugins:'
	for plugin in "autojump" "git" "gitstatus" "git-subrepo" "jgitflow" "jump"; do
		assert_line -n 1 -p "$plugin"
	done
	for completion in "git" "git_flow" "git_flow_avh" "github-cli"; do
		assert_line -n 2 -p "$completion"
	done
}

@test "search: ruby gem bundle rake rails" {
	run _bash-it-search rails ruby gem bundler rake --no-color
	assert_success

	assert_line -n 0 '      aliases: bundler   rails   '
	assert_line -n 1 '      plugins: chruby   chruby-auto   rails   ruby   '
	assert_line -n 2 '  completions: bundler   gem   rake   '
}

@test "search: rails ruby gem bundler rake -chruby" {
	run _bash-it-search rails ruby gem bundler rake -chruby --no-color
	assert_success

	assert_line -n 0 '      aliases: bundler   rails   '
	assert_line -n 1 '      plugins: rails   ruby   '
	assert_line -n 2 '  completions: bundler   gem   rake   '
}

@test "search: @git" {
	run _bash-it-search '@git' --no-color
	assert_success
	assert_line -n 0 '      aliases: git   '
	assert_line -n 1 '      plugins: git   '
	assert_line -n 2 '  completions: git   '
}

@test "search: @git --enable  / --disable" {
	run _bash-it-search '@git' --enable --no-color
	assert_success
	run _bash-it-search '@git' --no-color
	assert_success
	assert_line -n 0 -p '✓'

	run _bash-it-search '@git' --disable --no-color
	assert_success
	run _bash-it-search '@git' --no-color
	assert_success

	assert_line -n 0 '      aliases: git   '
	assert_line -n 1 '      plugins: git   '
	assert_line -n 2 '  completions: git   '
}

@test "search: @git --disable / --enable" {
	run _bash-it-search '@git' --disable --no-color
	assert_success
	run _bash-it-search '@git' --no-color
	assert_success

	assert_line -n 0 '      aliases: git   '
	assert_line -n 1 '      plugins: git   '
	assert_line -n 2 '  completions: git   '

	run _bash-it-search '@git' --enable --no-color
	assert_success
	run _bash-it-search '@git' --no-color
	assert_success
	assert_line -n 0 -p '✓'
}
