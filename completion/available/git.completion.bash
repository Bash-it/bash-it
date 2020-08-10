#!/usr/bin/env bash

# Only operate on MacOS since there are no linux paths
if [[ "$(uname -s)" != 'Darwin' ]] ; then
  _log_warning "unsupported operating system - only 'Darwin' is supported"
  return 0
fi

# Make sure git is installed
_command_exists git || return 0

# Don't handle completion if it's already managed
if complete -p git &>/dev/null ; then
  _log_warning "completion already loaded - this usually means it is safe to stop using this completion"
  return 0
fi

_git_bash_completion_found=false
_git_bash_completion_paths=(
  # MacOS non-system locations
  '/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash'
  '/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash'
)

# Load the first completion file found
for _comp_path in "${_git_bash_completion_paths[@]}" ; do
  if [ -r "$_comp_path" ] ; then
    _git_bash_completion_found=true
    source "$_comp_path"
    break
  fi
done

# Cleanup
if [[ "${_git_bash_completion_found}" == false ]]; then
  _log_warning "no completion files found - please try enabling the 'system' completion instead."
fi
unset _git_bash_completion_paths
unset _git_bash_completion_found
