# shellcheck shell=bash
cite "about-completion"
about-completion "Google Cloud SDK completion"

if _command_exists gcloud; then
	# get install path
	GOOGLE_SDK_ROOT=${GOOGLE_SDK_ROOT:-$(gcloud info --format="value(installation.sdk_root)")}

	# source all the bash completion file that are available
	for i in "${GOOGLE_SDK_ROOT}"/*.bash.inc; do
		# shellcheck disable=SC1090
		source "$i"
	done
fi
