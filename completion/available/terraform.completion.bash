#!/usr/bin/env bash
# Bash Terraform completion

_terraform()
{
   local cmds cur colonprefixes
   cmds="apply destroy get graph init output plan push          \
      refresh remote show taint version"

   COMPREPLY=()
   cur=${COMP_WORDS[COMP_CWORD]}
   # Work-around bash_completion issue where bash interprets a colon
   # as a separator.
   # Work-around borrowed from the darcs work-around for the same
   # issue.
   colonprefixes=${cur%"${cur##*:}"}
   COMPREPLY=( $(compgen -W '$cmds'  -- $cur))
   local i=${#COMPREPLY[*]}
   while [ $((--i)) -ge 0 ]; do
      COMPREPLY[$i]=${COMPREPLY[$i]#"$colonprefixes"}
   done

        return 0
} &&
complete -F _terraform terraform
