# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() {
	setup_libs "helpers"
	load "${BASH_IT?}/plugins/available/battery.plugin.bash"
}

# Sets up the `_command_exists` function so that it only responds `true` if called with
# the name of the function that was passed in as an argument to `setup_command_exists`.
# This is used to ensure that the test cases can test the various energy management tools
# without actually having them. When called like
#
# setup_command_exists "pmset"
#
# then calling `_command_exists "pmset"` will return `true`,
# while calling `_command_exists "ioreg"` (or other commands) will return `false`.
#
# It's cool that Bash allows to define functions within functions, works almost like
# a closure in JavaScript.
function setup_command_exists {
	success_command="$1"

	function _command_exists {
		case "$1" in
			"${success_command}")
				true
				;;
			*)
				false
				;;
		esac
	}
}

#######################
#
# no tool
#

@test 'plugins battery: battery-percentage with no tool' {
	setup_command_exists "fooooo"

	run battery_percentage
	assert_output "no"
}

#######################
#
# pmset
#

# Creates a `pmset` function that simulates output like the real `pmset` command.
# The passed in parameter is used for the remaining battery percentage.
function setup_pmset {
	percent="$1"

	function pmset {
		printf "\-InternalBattery-0 (id=12345)	%s; discharging; 16:00 remaining present: true" "${percent}"
	}
}

@test 'plugins battery: battery-percentage with pmset, 100%' {
	setup_command_exists "pmset"

	setup_pmset "100%"

	run battery_percentage
	assert_output "100"
}

@test 'plugins battery: battery-percentage with pmset, 98%' {
	setup_command_exists "pmset"

	setup_pmset "98%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 98.5%' {
	setup_command_exists "pmset"

	setup_pmset "98.5%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with pmset, 4%' {
	setup_command_exists "pmset"

	setup_pmset "4%"

	run battery_percentage
	assert_output "04"
}

@test 'plugins battery: battery-percentage with pmset, no status' {
	setup_command_exists "pmset"

	setup_pmset ""

	run battery_percentage
	assert_output "-1"
}

#######################
#
# acpi
#

# Creates a `acpi` function that simulates output like the real `acpi` command.
# The passed in parameters are used for
# 1) the remaining battery percentage.
# 2) the battery status
function setup_acpi {
	percent="$1"
	status="$2"

	function acpi {
		printf "Battery 0: %s, %s, 01:02:48 until charged" "${status}" "${percent}"
	}
}

@test 'plugins battery: battery-percentage with acpi, 100% Full' {
	setup_command_exists "acpi"

	setup_acpi "100%" "Full"

	run battery_percentage
	assert_output "100"
}

@test 'plugins battery: battery-percentage with acpi, 98% Charging' {
	setup_command_exists "acpi"

	setup_acpi "98%" "Charging"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with acpi, 98% Discharging' {
	setup_command_exists "acpi"

	setup_acpi "98%" "Discharging"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with acpi, 98% Unknown' {
	setup_command_exists "acpi"

	setup_acpi "98%" "Unknown"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with acpi, 4% Charging' {
	setup_command_exists "acpi"

	setup_acpi "4%" "Charging"

	run battery_percentage
	assert_output "04"
}

@test 'plugins battery: battery-percentage with acpi, 4% no status' {
	setup_command_exists "acpi"

	setup_acpi "4%" ""

	run battery_percentage
	assert_output "04"
}

@test 'plugins battery: battery-percentage with acpi, no status' {
	setup_command_exists "acpi"

	setup_acpi "" ""

	run battery_percentage
	assert_output "-1"
}

#######################
#
# upower
#

# Creates a `upower` function that simulates output like the real `upower` command.
# The passed in parameter is used for the remaining battery percentage.
function setup_upower {
	percent="$1"
	BAT0="/org/freedesktop/UPower/devices/battery_BAT$RANDOM"

	function upower {
		case $1 in
			'-e' | '--enumerate')
				printf '%s\n' "$BAT0" "/org/freedesktop/UPower/devices/mouse_hid_${RANDOM}_battery"
				;;
			'-i' | '--show-info')
				if [[ $2 == "$BAT0" ]]; then
					printf "voltage:             12.191 V\n    time to full:        57.3 minutes\n    percentage:          %s\n    capacity:            84.6964" "${percent}"
				else
					false
				fi
				;;
		esac
	}
}

@test 'plugins battery: battery-percentage with upower, 100%' {
	setup_command_exists "upower"

	setup_upower "100.00%"

	run battery_percentage
	assert_output "100"
}

@test 'plugins battery: battery-percentage with upower, 98%' {
	setup_command_exists "upower"

	setup_upower "98.4567%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with upower, 98.5%' {
	setup_command_exists "upower"

	setup_upower "98.5%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with upower, 4%' {
	setup_command_exists "upower"

	setup_upower "4.2345%"

	run battery_percentage
	assert_output "04"
}

@test 'plugins battery: battery-percentage with upower, no output' {
	setup_command_exists "upower"

	setup_upower ""

	run battery_percentage
	assert_output "-1"
}

#######################
#
# ioreg
#

# Creates a `ioreg` function that simulates output like the real `ioreg` command.
# The passed in parameter is used for the remaining battery percentage.
function setup_ioreg {
	percent="$1"

	# shellcheck disable=SC2317
	function ioreg {
		printf "\"MaxCapacity\" = 100\n\"CurrentCapacity\" = %s" "${percent}"
	}
}

@test 'plugins battery: battery-percentage with ioreg, 100%' {
	setup_command_exists "ioreg"

	setup_ioreg "100%"

	run battery_percentage
	assert_output "100"
}

@test 'plugins battery: battery-percentage with ioreg, 98%' {
	setup_command_exists "ioreg"

	setup_ioreg "98%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with ioreg, 98.5%' {
	setup_command_exists "ioreg"

	setup_ioreg "98.5%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with ioreg, 4%' {
	setup_command_exists "ioreg"

	setup_ioreg "4%"

	run battery_percentage
	assert_output "04"
}

@test 'plugins battery: battery-percentage with ioreg, no status' {
	setup_command_exists "ioreg"

	# Simulate that no battery is present
	function ioreg {
		printf ""
	}

	run battery_percentage
	assert_output "-1"
}

#######################
#
# WMIC
#

# Creates a `WMIC` function that simulates output like the real `WMIC` command.
# The passed in parameter is used for the remaining battery percentage.
function setup_WMIC {
	percent="$1"

	function WMIC {
		printf "Charge: %s" "${percent}"
	}
}

@test 'plugins battery: battery-percentage with WMIC, 100%' {
	setup_command_exists "WMIC"

	setup_WMIC "100%"

	run battery_percentage
	assert_output "100"
}

@test 'plugins battery: battery-percentage with WMIC, 98%' {
	setup_command_exists "WMIC"

	setup_WMIC "98%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with WMIC, 98.5%' {
	setup_command_exists "WMIC"

	setup_WMIC "98.5%"

	run battery_percentage
	assert_output "98"
}

@test 'plugins battery: battery-percentage with WMIC, 4%' {
	setup_command_exists "WMIC"

	setup_WMIC "4%"

	run battery_percentage
	assert_output "04"
}

@test 'plugins battery: battery-percentage with WMIC, no status' {
	setup_command_exists "WMIC"

	setup_WMIC ""

	run battery_percentage
	assert_output "-1"
}
