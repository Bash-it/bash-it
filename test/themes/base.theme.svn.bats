# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors" #"theme"
	load "${BASH_IT?}/themes/base.theme.bash"
}

function setup_repo {
	upstream="$(mktemp -d)"
	pushd "$upstream" > /dev/null || return
	# Create a dummy SVN folder - this will not work with an actual `svn` command,
	# but will be enough to trigger the SVN check in the base theme.
	mkdir .svn

	echo "$upstream"
}

function setup_svn_path {
	local svn_path="$1"

	# Make sure that the requested SVN script is available
	assert_file_exist "$svn_path/svn"

	# Make sure that the requested SVN script is on the path
	export PATH="$svn_path:$PATH"
}

@test 'themes base: SVN: detect SVN repo' {
	repo="$(setup_repo)"
	pushd "$repo" || return

	setup_svn_path "$BASH_IT/test/fixtures/svn/working"

	# Init the base theme again so that the working SVN script is detected
	run _bash_it_appearance_scm_init
	assert_success
	_bash_it_appearance_scm_init

	scm
	# Make sure that the SVN command is used
	assert_equal "${SCM?}" "${SCM_SVN?}"
}

@test 'themes base: SVN: detect SVN repo even from a subfolder' {
	repo="$(setup_repo)"
	pushd "$repo" || return

	mkdir foo
	pushd foo || return

	setup_svn_path "$BASH_IT/test/fixtures/svn/working"

	# Init the base theme again so that the working SVN script is detected
	run _bash_it_appearance_scm_init
	assert_success
	_bash_it_appearance_scm_init

	scm
	# Make sure that the SVN command is used
	assert_equal "${SCM?}" "${SCM_SVN?}"
}

@test 'themes base: SVN: no SCM if no .svn folder can be found' {
	repo="$(setup_repo)"
	pushd "$repo" || return

	rm -rf .svn

	setup_svn_path "$BASH_IT/test/fixtures/svn/working"

	# Init the base theme again so that the working SVN script is detected
	run _bash_it_appearance_scm_init
	assert_success
	_bash_it_appearance_scm_init

	scm
	# Make sure that no SVN command is used
	assert_equal "${SCM?}" "${SCM_NONE?}"
}

@test 'themes base: SVN: ignore SVN repo when using broken SVN command' {
	repo="$(setup_repo)"
	pushd "$repo" || return

	setup_svn_path "$BASH_IT/test/fixtures/svn/broken"

	# Init the base theme again so that the working SVN script is detected
	run _bash_it_appearance_scm_init
	assert_success
	_bash_it_appearance_scm_init

	scm
	# Make sure that no SVN command is not used
	assert_equal "${SCM?}" "${SCM_NONE?}"
}

@test 'themes base: SVN: ignore SVN repo even from a subfolder when using a broken SVN' {
	repo="$(setup_repo)"
	pushd "$repo" || return

	mkdir foo
	pushd foo || return

	setup_svn_path "$BASH_IT/test/fixtures/svn/broken"

	# Init the base theme again so that the working SVN script is detected
	run _bash_it_appearance_scm_init
	assert_success
	_bash_it_appearance_scm_init

	scm
	# Make sure that no SVN command is used
	assert_equal "${SCM?}" "${SCM_NONE?}"
}
