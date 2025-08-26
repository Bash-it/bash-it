# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	true
	# don't load any libraries as the tests here test the *whole* kit
}

@test "lib composure: _composure_keywords()" {
	run _composure_keywords
	assert_output "about author example group param version"
}
