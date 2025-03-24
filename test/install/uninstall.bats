# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup() {
	export HOME="${BATS_TEST_TMPDIR?}"
}

function local_setup_file() {
	# Determine which config file to use based on OS.
	case $OSTYPE in
		darwin*)
			export BASH_IT_CONFIG_FILE=.bash_profile
			;;
		*)
			export BASH_IT_CONFIG_FILE=.bashrc
			;;
	esac
	# don't load any libraries as the tests here test the *whole* kit
}

@test "uninstall: verify that the uninstall script exists" {
	assert_file_exist "${BASH_IT?}/uninstall.sh"
}

@test "uninstall: run the uninstall script with an existing backup file" {
	local md5_bak md5_conf
	cd "${BASH_IT?}"

	echo "test file content for backup" > "$HOME/$BASH_IT_CONFIG_FILE.bak"
	echo "test file content for original file" > "$HOME/$BASH_IT_CONFIG_FILE"
	md5_bak=$(md5sum "$HOME/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

	run ./uninstall.sh
	assert_success

	assert_file_not_exist "$HOME/$BASH_IT_CONFIG_FILE.uninstall"
	assert_file_not_exist "$HOME/$BASH_IT_CONFIG_FILE.bak"
	assert_file_exist "$HOME/$BASH_IT_CONFIG_FILE"

	md5_conf=$(md5sum "$HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

	assert_equal "$md5_bak" "$md5_conf"
}

@test "uninstall: run the uninstall script without an existing backup file" {
	local md5_orig md5_uninstall
	cd "${BASH_IT?}"

	echo "test file content for original file" > "$HOME/$BASH_IT_CONFIG_FILE"
	md5_orig=$(md5sum "$HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

	run ./uninstall.sh
	assert_success

	assert_file_exist "$HOME/$BASH_IT_CONFIG_FILE.uninstall"
	assert_file_not_exist "$HOME/$BASH_IT_CONFIG_FILE.bak"
	assert_file_not_exist "$HOME/$BASH_IT_CONFIG_FILE"

	md5_uninstall=$(md5sum "$HOME/$BASH_IT_CONFIG_FILE.uninstall" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_uninstall"
}
