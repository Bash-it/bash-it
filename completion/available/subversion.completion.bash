# shellcheck shell=bash
#
# Locate and load completions for `svn`.

# Make sure svn is installed
_command_exists svn || return

# Don't handle completion if it's already managed
if _completion_exists svn; then
	_log_warning "completion already loaded - this usually means it is safe to stop using this completion"
	return 0
fi

_svn_bash_completion_xcrun_svn=
if _command_exists xcrun; then
	_svn_bash_completion_xcrun_svn="$(xcrun --find svn)"
fi
_svn_bash_completion_paths=(
	# Standard locations
	"${SVN_EXE%/*}/../etc/bash_completion.d/subversion"
	# MacOS non-system locations
	"${_svn_bash_completion_xcrun_svn%/bin/svn}/etc/bash_completion.d/subversion"
)

# Load the first completion file found
_svn_bash_completion_found=false
for _comp_path in "${_svn_bash_completion_paths[@]}"; do
	if [[ -r "$_comp_path" ]]; then
		_svn_bash_completion_found=true
		# shellcheck disable=SC1090 # don't follow
		source "$_comp_path"
		break
	fi
done

# Cleanup
if [[ "${_svn_bash_completion_found}" == false ]]; then
	_log_warning "no completion files found - please try enabling the 'system' completion instead."
fi
unset "${!_svn_bash_completion@}"
