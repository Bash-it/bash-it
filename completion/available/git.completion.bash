#!/usr/bin/env bash

# Only operate on MacOS since there are no linux paths
[[ "$(uname -s)" == 'Darwin' ]] || return 0

# Make sure git is installed
_command_exists git || return 0

# Don't handle completion if it's already managed
! complete -p git &>/dev/null || return 0

_git_bash_completion_found=false
_git_bash_completion_paths=(
  # MacOS non-system locations
  '/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash'
  '/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash'
)

for _comp_path in "${_git_bash_completion_paths[@]}" ; do
  if [ -r "$_comp_path" ] ; then
    _git_bash_completion_found=true
    source "$_comp_path"
    break
  fi
done

if ! _git_bash_completion_found ; then
  _log_warning "no completion files found - please try enabling the 'system' completion instead."
fi
unset _git_bash_completion_paths
unset _git_bash_completion_found
