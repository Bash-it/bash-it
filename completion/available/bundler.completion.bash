#! bash
# bash completion for the `bundle` command.
#
# Copyright (c) 2011-2013 Daniel Luz <dev at mernen dot com>.
# Distributed under the MIT license.
# http://mernen.com/projects/completion-ruby
#
# To use, source this file on bash:
#   . completion-bundle

__bundle() {
  local cur=$2
  local prev=$3
  local bundle_command
  __bundle_get_command
  COMPREPLY=()

  local options
  if [[ $cur = -* ]]; then
      options="--no-color --verbose"
      if [[ -z $bundle_command ]]; then
          options="$options --version --help"
      fi
  else
      if [[ -z $bundle_command || $bundle_command = help ]]; then
          options="help install update package exec config check list show
                   console open viz init gem"
      fi
  fi
  COMPREPLY=($(compgen -W "$options" -- "$cur"))
}

__bundle_get_command() {
    local i
    for ((i=1; i < $COMP_CWORD; ++i)); do
        local arg=${COMP_WORDS[$i]}

        case $arg in
        [^-]*)
            bundle_command=$arg
            return;;
        --version)
            # command-killer
            bundle_command=-
            return;;
        --help)
            bundle_command=help
            return;;
        esac
    done
}


complete -F __bundle -o bashdefault -o default bundle
# vim: ai ft=sh sw=4 sts=2 et
