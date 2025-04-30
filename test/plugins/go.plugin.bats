# shellcheck shell=bats
# shellcheck disable=SC2034

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
}

function setup_go_path() {
	local go_path="$1"

	# Make sure that the requested GO folder is available
	assert_dir_exist "$go_path/bin"

	# Make sure that the requested GO folder is on the path
	export GOPATH="$go_path:${GOPATH:-}"
}

# We test `go version` in each test to account for users with goenv and no system go.

@test 'ensure _bash-it-gopath-pathmunge is defined' {
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	run type -t _bash-it-gopath-pathmunge
	assert_line 'function'
}

@test 'plugins go: single entry in GOPATH' {
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	setup_go_path "$BASH_IT/test/fixtures/go/gopath"
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	assert_equal "$(cut -d':' -f1 <<< "$PATH")" "$BASH_IT/test/fixtures/go/gopath/bin"
}

@test 'plugins go: single entry in GOPATH, with space' {
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	setup_go_path "$BASH_IT/test/fixtures/go/go path"
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	assert_equal "$(cut -d':' -f1 <<< "$PATH")" "$BASH_IT/test/fixtures/go/go path/bin"
}

@test 'plugins go: single entry in GOPATH, with escaped space' {
	skip 'huh?'
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	setup_go_path "$BASH_IT/test/fixtures/go/go\ path"
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	assert_equal "$(cut -d':' -f1 <<< "$PATH")" "$BASH_IT/test/fixtures/go/go\ path/bin"
}

@test 'plugins go: multiple entries in GOPATH' {
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	setup_go_path "$BASH_IT/test/fixtures/go/gopath"
	setup_go_path "$BASH_IT/test/fixtures/go/gopath2"
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	assert_equal "$(cut -d':' -f1,2 <<< "$PATH")" "$BASH_IT/test/fixtures/go/gopath2/bin:$BASH_IT/test/fixtures/go/gopath/bin"
}

@test 'plugins go: multiple entries in GOPATH, with space' {
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	setup_go_path "$BASH_IT/test/fixtures/go/gopath"
	setup_go_path "$BASH_IT/test/fixtures/go/go path"
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	assert_equal "$(cut -d':' -f1,2 <<< "$PATH")" "$BASH_IT/test/fixtures/go/go path/bin:$BASH_IT/test/fixtures/go/gopath/bin"
}

@test 'plugins go: multiple entries in GOPATH, with escaped space' {
	skip 'huh?'
	{ _command_exists go && go version &> /dev/null; } || skip 'golang not found'
	setup_go_path "$BASH_IT/test/fixtures/go/gopath"
	setup_go_path "$BASH_IT/test/fixtures/go/go path"
	load "${BASH_IT?}/plugins/available/go.plugin.bash"
	assert_equal "$(cut -d':' -f1,2 <<< "$PATH")" "$BASH_IT/test/fixtures/go/go\ path/bin:$BASH_IT/test/fixtures/go/gopath/bin"
}
