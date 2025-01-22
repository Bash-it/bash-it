# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "colors" #"theme"
	load "${BASH_IT?}/themes/base.theme.bash"
}

@test 'themes base: battery_percentage should not exist' {
	run type -a battery_percentage &> /dev/null
	assert_failure
}

@test 'themes base: battery_percentage should exist if battery plugin loaded' {
	load "${BASH_IT?}/plugins/available/battery.plugin.bash"

	run type -a battery_percentage &> /dev/null
	assert_success
}

@test 'themes base: battery_char should exist' {
	run type -t battery_char
	assert_success
	assert_line "function"

	run battery_char
	assert_output ""
}

@test 'themes base: battery_char should exist if battery plugin loaded' {
	unset -f battery_char

	load "${BASH_IT?}/plugins/available/battery.plugin.bash"
	run type -t battery_percentage
	assert_success
	assert_line "function"

	load "${BASH_IT?}/themes/base.theme.bash"
	run type -t battery_char
	assert_success
	assert_line "function"

	run battery_char
	assert_success

	run type -a battery_char
	assert_output --partial 'THEME_BATTERY_PERCENTAGE_CHECK'
}

@test 'themes base: battery_charge should exist' {
	run type -a battery_charge &> /dev/null
	assert_success

	run battery_charge
	assert_success
	assert_output ""
}

@test 'themes base: battery_charge should exist if battery plugin loaded' {
	unset -f battery_charge
	load "${BASH_IT?}/plugins/available/battery.plugin.bash"
	load "${BASH_IT?}/themes/base.theme.bash"

	run type -a battery_charge &> /dev/null
	assert_success

	run battery_charge
	assert_success

	run type -a battery_charge
	assert_line '        no)'
}
