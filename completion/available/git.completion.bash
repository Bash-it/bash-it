#!/usr/bin/env bash

# Make sure git is installed
_command_exists git || return

# Don't handle completion if it's already managed
complete -p git &>/dev/null && return

_git_bash_completion_paths=(
  # MacOS non-system locations
  '/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash'
  '/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash'
)

for _comp_path in "${_git_bash_completion_paths[@]}" ; do
  if [ -r "$_comp_path" ] ; then
    source "$_comp_path"
    unset _git_bash_completion_paths
    return
  fi
done

unset _git_bash_completion_paths

(_log_warning "no completion files found - please try enabling the 'system' completion instead." && return 1)
