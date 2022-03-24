# shellcheck shell=bash
#
# Locate and load completions for `git`.

# Make sure git is installed
_command_exists git || return

# Don't handle completion if it's already managed
if complete -p git &> /dev/null; then
	_log_warning "completion already loaded - this usually means it is safe to stop using this completion"
	return 0
fi

_git_bash_completion_xcrun_git=
if _command_exists xcrun; then
	_git_bash_completion_xcrun_git="$(xcrun --find git)"
fi
_git_bash_completion_paths=(
	# Standard locations
	"${GIT_EXE%/*}/../share/git-core/git-completion.bash"
	"${GIT_EXE%/*}/../share/git-core/contrib/completion/git-completion.bash"
	"${GIT_EXE%/*}/../etc/bash_completion.d/git-completion.bash"
	# MacOS non-system locations
	"${_git_bash_completion_xcrun_git%/bin/git}/share/git-core/git-completion.bash"
)

# Load the first completion file found
_git_bash_completion_found=false
for _comp_path in "${_git_bash_completion_paths[@]}"; do
	if [[ -r "$_comp_path" ]]; then
		_git_bash_completion_found=true
		# shellcheck disable=SC1090 # don't follow
		source "$_comp_path"
		break
	fi
done

# Cleanup
if [[ "${_git_bash_completion_found}" == false ]]; then
	_log_warning "no completion files found - please try enabling the 'system' completion instead."
fi
unset "${!_git_bash_completion@}"
