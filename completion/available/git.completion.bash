#!/usr/bin/env bash

# Make sure git is installed
_command_exists git || return

# Don't handle completion if it's already managed
complete -p git &>/dev/null && return

_git_bash_completion_paths=(
  # Linux
  '/etc/bash_completion.d/git.sh'
  # MacOS
  '/Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash'
  '/Applications/Xcode.app/Contents/Developer/usr/share/git-core/git-completion.bash'
)

for fn in "${_git_bash_completion_paths[@]}" ; do
  if [ -r "$fn" ] ; then
    source "$fn"
    break
  fi
done
