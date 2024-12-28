# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
	load "${BASH_IT?}/plugins/available/base.plugin.bash"
}

@test 'plugins base: ips()' {
	readonly localhost='127.0.0.1'
	run ips
	assert_success
	assert_line "$localhost"
}

@test 'plugins base: myip()' {
	local mask_ip
	run myip
	assert_success
	shopt -s extglob
	mask_ip="${output//+([[:digit:]]|[[:digit:]][[:digit:]]|[[:digit:]][[:digit:]][[:digit:]])/?}" #$(echo "$output" | tr -s '0-9' '?')
	[[ $mask_ip == 'Your public IP is:  ?.?.?.? ' ]]
}

@test 'plugins base: pickfrom()' {
	stub_file="${BATS_TEST_TMPDIR?}/stub_file"
	printf "l1\nl2\nl3" > "$stub_file"
	run pickfrom "$stub_file"
	assert_success
	[[ $output == l? ]]
}

@test 'plugins base: mkcd()' {
	cd "${BATS_TEST_TMPDIR?}"
	declare -r dir_name="-dir_with_dash"

	# Make sure that the directory does not exist prior to the test
	rm -rf "${BATS_TEST_TMPDIR:?}/${dir_name}"

	run mkcd "${dir_name}"
	assert_success
	assert_dir_exist "${BATS_TEST_TMPDIR?}/${dir_name}"

	mkcd "${dir_name}"
	assert_equal "${PWD}" "${BATS_TEST_TMPDIR//\/\///}/${dir_name}"
}

@test 'plugins base: lsgrep()' {
	for i in 1 2 3; do mkdir -p "${BASH_IT}/${i}"; done
	cd "${BASH_IT?}"
	run lsgrep 2
	assert_success
	assert_equal "$output" 2
}

@test 'plugins base: buf()' {
	declare -r file="${BATS_TEST_TMPDIR?}/file"
	touch "$file"

	# Take one timestamp before running the `buf` function
	declare -r stamp1=$(date +%Y%m%d_%H%M%S)

	run buf "$file"

	# Take another timestamp after running `buf`.
	declare -r stamp2=$(date +%Y%m%d_%H%M%S)

	# Verify that the backup file ends with one of the two timestamps.
	# This is done to avoid race conditions where buf is run close to the end
	# of a second, in which case the second timestamp might be in the next second,
	# causing the test to fail.
	# By using `or` for the two checks, we can verify that one of the two files is present.
	# In most cases, it's going to have the same timestamp anyway.
	# We can't use `assert_file_exist` here, since it only checks for a single file name.
	assert [ -e "${file}_${stamp1}" \
		-o -e "${file}_${stamp2}" ]
}
