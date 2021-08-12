# shellcheck shell=bash
about-plugin 'osx-specific functions'

# OS X: Open new tabs in same directory
if _is_function update_terminal_cwd; then
	safe_append_prompt_command 'update_terminal_cwd'
fi

function tab() {
	about 'opens a new terminal tab'
	group 'osx'

	osascript 2> /dev/null << EOF
    tell application "System Events"
      tell process "Terminal" to keystroke "t" using command down
    end
    tell application "Terminal"
      activate
      do script with command " cd \"$PWD\"; $*" in window 0
    end tell
EOF
}

# renames the current os x terminal tab title
function tabname {
	printf '%b' "\e]1;$1\a"
}

# renames the current os x terminal window title
function winname {
	printf '%b' "\e]2;$1\a"
}

# this one switches your os x dock between 2d and 3d
# thanks to savier.zwetschge.org
function dock-switch() {
	about 'switch dock between 2d and 3d'
	param '1: "2d" or "3d"'
	example '$ dock-switch 2d'
	group 'osx'

	case $OSTYPE in
		*'darwin'*)
			case $1 in
				3d)
					defaults write com.apple.dock no-glass -boolean NO
					killall Dock
					;;
				2d)
					defaults write com.apple.dock no-glass -boolean YES
					killall Dock
					;;
				*)
					echo "usage:"
					echo "dock-switch 2d"
					echo "dock-switch 3d."
					;;
			esac
			;;
		*)
			echo "Sorry, this only works on Mac OS X"
			;;
	esac
}

function pman() {
	about 'view man documentation in Preview'
	param '1: man page to view'
	example '$ pman bash'
	group 'osx'
	man -t "${1}" | open -fa 'Preview'
}

function pri() {
	about 'display information about Ruby classes, modules, or methods, in Preview'
	param '1: Ruby method, module, or class'
	example '$ pri Array'
	group 'osx'
	ri -T "${1}" | open -fa 'Preview'
}

# Download a file and open it in Preview
function prevcurl() {
	about 'download a file and open it in Preview'
	param '1: url'
	group 'osx'

	if [[ ! $OSTYPE = 'darwin'* ]]; then
		echo "This function only works with Mac OS X"
		return 1
	fi
	curl "$*" | open -fa 'Preview'
}

function refresh-launchpad() {
	about 'Reset launchpad layout in macOS'
	example '$ refresh-launchpad'
	group 'osx'

	if [[ "$OSTYPE" = 'darwin'* ]]; then
		defaults write com.apple.dock ResetLaunchPad -bool TRUE
		killall Dock
	else
		echo "Sorry, this only works on Mac OS X"
	fi
}

function list-jvms() {
	about 'List java virtual machines and their states in macOS'
	example 'list-jvms'
	group 'osx'

	local JVMS_DIR="/Library/Java/JavaVirtualMachines"
	# The following variables are intended to impact the enclosing scope, not local.
	JVMS=("${JVMS_DIR}"/*)
	JVMS_STATES=()

	# Map state of JVM
	for ((i = 0; i < ${#JVMS[@]}; i++)); do
		if [[ -f "${JVMS[i]}/Contents/Info.plist" ]]; then
			JVMS_STATES[i]=enabled
		else
			JVMS_STATES[i]=disabled
		fi
		printf '%s\t%s\t%s\n' "${i}" "${JVMS[i]##*/}" "${JVMS_STATES[i]}"
	done
}

function pick-default-jvm() {
	about 'Pick the default Java Virtual Machines in system-wide scope in macOS'
	example 'pick-default-jvm'

	# Declare variables
	local JVMS JVMS_STATES
	local DEFAULT_JVM_DIR DEFAULT_JVM OPTION

	# Call function for listing
	list-jvms

	# OPTION for default jdk and set variables
	while [[ ! "$OPTION" =~ ^[0-9]+$ || OPTION -ge "${#JVMS[@]}" ]]; do
		read -rp "Enter Default JVM: " OPTION
		if [[ ! "$OPTION" =~ ^[0-9]+$ ]]; then
			echo "Please enter a number"
		fi

		if [[ OPTION -ge "${#JVMS[@]}" ]]; then
			echo "Please select one of the displayed JVMs"
		fi
	done

	DEFAULT_JVM_DIR="${JVMS[OPTION]}"
	DEFAULT_JVM="${JVMS[OPTION]##*/}"

	# Disable all jdk
	for ((i = 0; i < ${#JVMS[@]}; i++)); do
		if [[ "${JVMS[i]}" != "${DEFAULT_JVM_DIR}" && -f "${JVMS[i]}/Contents/Info.plist" ]]; then
			sudo mv "${JVMS[i]}/Contents/Info.plist" "${JVMS[i]}/Contents/Info.plist.disable"
		fi
	done

	# Enable default jdk
	if [[ -f "${DEFAULT_JVM_DIR}/Contents/Info.plist.disable" ]]; then
		sudo mv -vn "${DEFAULT_JVM_DIR}/Contents/Info.plist.disable" "${DEFAULT_JVM_DIR}/Contents/Info.plist" \
			&& echo "Enabled ${DEFAULT_JVM} as default JVM"
	fi
}
