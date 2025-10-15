# shellcheck shell=bash
cite about-plugin
about-plugin 'Add a gw command to use gradle wrapper if present, else use system gradle'
url "https://gradle.org/"

function gw() {
	local file="gradlew"
	local result

	result="$(_bash-it-find-in-ancestor "${file}")"

	# Call gradle
	"${result:-gradle}" "$@"
}
