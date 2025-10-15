# shellcheck shell=bash

cite "about-completion"
about-completion "git - distributed version control system"
group "version-control"
url "https://git-scm.com/"

# Locate and load completions for `git`.

# Make sure git is installed
_bash-it-completion-helper-necessary git || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient git || return

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
