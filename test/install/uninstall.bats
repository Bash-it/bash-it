# shellcheck shell=bats
# shellcheck disable=SC2030,SC2031 # intended behavior for BATS

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup() {
	export HOME="${BATS_TEST_TMPDIR?}"
}

@test "uninstall: verify that the uninstall script exists" {
	assert_file_exist "${BASH_IT?}/uninstall.sh"
}

@test "uninstall: run the uninstall script with existing backup 'bashrc'" {
	local md5_bak md5_conf
	export BASH_IT_CONFIG_FILE=.bashrc

	echo "test file content for backup" > "${HOME?}/$BASH_IT_CONFIG_FILE.bak"
	echo "test file content for original BASH_IT file" > "${HOME?}/$BASH_IT_CONFIG_FILE"
	md5_bak=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

	run "${BASH_IT?}/uninstall.sh"
	assert_success
	assert_output --partial "Your original ~/$BASH_IT_CONFIG_FILE has been restored."

	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE.uninstall"
	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE.bak"
	assert_file_exist "${HOME?}/$BASH_IT_CONFIG_FILE"

	md5_conf=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

	assert_equal "$md5_bak" "$md5_conf"
}

@test "uninstall: run the uninstall script with existing backup 'bash_profile'" {
	local md5_bak md5_conf
	export BASH_IT_CONFIG_FILE=.bash_profile

	echo "test file content for backup file" > "${HOME?}/$BASH_IT_CONFIG_FILE.bak"
	echo "test file content for original BASH_IT file" > "${HOME?}/$BASH_IT_CONFIG_FILE"
	md5_bak=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

	run "${BASH_IT?}/uninstall.sh"
	assert_success

	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE.uninstall"
	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE.bak"
	assert_file_exist "${HOME?}/$BASH_IT_CONFIG_FILE"

	md5_conf=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

	assert_equal "$md5_bak" "$md5_conf"
}

@test "uninstall: run the uninstall script without existing backup 'bashrc" {
	local md5_orig md5_uninstall
	export BASH_IT_CONFIG_FILE=.bashrc

	echo "test file content for original BASH_IT file" > "${HOME?}/$BASH_IT_CONFIG_FILE"
	md5_orig=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

	run "${BASH_IT?}/uninstall.sh"
	assert_success

	assert_file_exist "${HOME?}/$BASH_IT_CONFIG_FILE.uninstall"
	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE.bak"
	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE"

	md5_uninstall=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE.uninstall" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_uninstall"
}

@test "uninstall: run the uninstall script without existing backup 'bash_profile" {
	local md5_orig md5_uninstall
	export BASH_IT_CONFIG_FILE=.bash_profile

	echo "test file content for original BASH_IT file" > "${HOME?}/$BASH_IT_CONFIG_FILE"
	md5_orig=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

	run "${BASH_IT?}/uninstall.sh"

	assert_success

	assert_file_exist "${HOME?}/$BASH_IT_CONFIG_FILE.uninstall"
	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE.bak"
	assert_file_not_exist "${HOME?}/$BASH_IT_CONFIG_FILE"

	md5_uninstall=$(md5sum "${HOME?}/$BASH_IT_CONFIG_FILE.uninstall" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_uninstall"
}
