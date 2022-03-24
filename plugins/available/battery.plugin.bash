# shellcheck shell=bash
about-plugin 'display info about your battery charge level'

function ac_adapter_connected() {
	local batteries
	if _command_exists upower; then
		IFS=$'\n' read -d '' -ra batteries < <(upower -e | grep -i BAT)
		upower -i "${batteries[0]:-}" | grep 'state' | grep -q 'charging\|fully-charged'
	elif _command_exists acpi; then
		acpi -a | grep -q "on-line"
	elif _command_exists pmset; then
		pmset -g batt | grep -q 'AC Power'
	elif _command_exists ioreg; then
		ioreg -n AppleSmartBattery -r | grep -q '"ExternalConnected" = Yes'
	elif _command_exists WMIC; then
		WMIC Path Win32_Battery Get BatteryStatus /Format:List | grep -q 'BatteryStatus=2'
	fi
}

function ac_adapter_disconnected() {
	local batteries
	if _command_exists upower; then
		IFS=$'\n' read -d '' -ra batteries < <(upower -e | grep -i BAT)
		upower -i "${batteries[0]:-}" | grep 'state' | grep -q 'discharging'
	elif _command_exists acpi; then
		acpi -a | grep -q "off-line"
	elif _command_exists pmset; then
		pmset -g batt | grep -q 'Battery Power'
	elif _command_exists ioreg; then
		ioreg -n AppleSmartBattery -r | grep -q '"ExternalConnected" = No'
	elif _command_exists WMIC; then
		WMIC Path Win32_Battery Get BatteryStatus /Format:List | grep -q 'BatteryStatus=1'
	fi
}

function battery_percentage() {
	about 'displays battery charge as a percentage of full (100%)'
	group 'battery'

	local command_output batteries

	if _command_exists upower; then
		IFS=$'\n' read -d '' -ra batteries < <(upower -e | grep -i BAT)
		command_output="$(upower --show-info "${batteries[0]:-}" | grep percentage | grep -o '[0-9]\+' | head -1)"
	elif _command_exists acpi; then
		command_output=$(acpi -b | awk -F, '/,/{gsub(/ /, "", $0); gsub(/%/,"", $0); print $2}')
	elif _command_exists pmset; then
		command_output=$(pmset -g ps | sed -n 's/.*[[:blank:]]+*\(.*%\).*/\1/p' | grep -o '[0-9]\+' | head -1)
	elif _command_exists ioreg; then
		command_output=$(ioreg -n AppleSmartBattery -r | awk '$1~/Capacity/{c[$1]=$3} END{OFMT="%05.2f"; max=c["\"MaxCapacity\""]; print (max>0? 100*c["\"CurrentCapacity\""]/max: "?")}' | grep -o '[0-9]\+' | head -1)
	elif _command_exists WMIC; then
		command_output=$(WMIC PATH Win32_Battery Get EstimatedChargeRemaining /Format:List | grep -o '[0-9]\+' | head -1)
	else
		command_output="no"
	fi

	if [[ "${command_output}" != "no" ]]; then
		printf "%02d" "${command_output:--1}"
	else
		echo "${command_output}"
	fi
}

function battery_charge() {
	about 'graphical display of your battery charge'
	group 'battery'

	# Full char
	local f_c='▸'
	# Depleted char
	local d_c='▹'
	local depleted_color="${normal?}"
	local full_color="${green?}"
	local half_color="${yellow?}"
	local danger_color="${red?}"
	#local battery_output="${depleted_color}${d_c}${d_c}${d_c}${d_c}${d_c}"
	local battery_percentage
	battery_percentage=$(battery_percentage)

	case $battery_percentage in
		no)
			echo ""
			;;
		9*)
			echo "${full_color}${f_c}${f_c}${f_c}${f_c}${f_c}${normal?}"
			;;
		8*)
			echo "${full_color}${f_c}${f_c}${f_c}${f_c}${half_color}${f_c}${normal?}"
			;;
		7*)
			echo "${full_color}${f_c}${f_c}${f_c}${f_c}${depleted_color}${d_c}${normal?}"
			;;
		6*)
			echo "${full_color}${f_c}${f_c}${f_c}${half_color}${f_c}${depleted_color}${d_c}${normal?}"
			;;
		5*)
			echo "${full_color}${f_c}${f_c}${f_c}${depleted_color}${d_c}${d_c}${normal?}"
			;;
		4*)
			echo "${full_color}${f_c}${f_c}${half_color}${f_c}${depleted_color}${d_c}${d_c}${normal?}"
			;;
		3*)
			echo "${full_color}${f_c}${f_c}${depleted_color}${d_c}${d_c}${d_c}${normal?}"
			;;
		2*)
			echo "${full_color}${f_c}${half_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${normal?}"
			;;
		1*)
			echo "${full_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${d_c}${normal?}"
			;;
		05)
			echo "${danger_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${d_c}${normal?}"
			;;
		04)
			echo "${danger_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${d_c}${normal?}"
			;;
		03)
			echo "${danger_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${d_c}${normal?}"
			;;
		02)
			echo "${danger_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${d_c}${normal?}"
			;;
		0*)
			echo "${half_color}${f_c}${depleted_color}${d_c}${d_c}${d_c}${d_c}${normal?}"
			;;
		*)
			echo "${danger_color}UNPLG${normal?}"
			;;
	esac
}
