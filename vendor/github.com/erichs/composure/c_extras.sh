#!/bin/bash

function _basename_no_extension () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  sed -e 's/^.*\/\(.*\)\.inc$/\1/'

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _composure_functions () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  _list_composure_files | _basename_no_extension

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function _load_tab_completions () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  # support tab completion for 'revise' command
  # you may disable this by adding the following line to your shell startup:
  # export COMPOSURE_TAB_COMPLETION=0

  if [ "$COMPOSURE_TAB_COMPLETION" = "0" ] 
     then
    return  # if you say so...
  fi

  case "$(_shell)" in
    zsh)
      read -r -d '' SCRIPT <<ZSHDATA
_zsh_revise_complete () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
   typeset word completions
   word="\$1"
   completions="\$(_composure_functions)"
   reply=( "\${(ps:\n:)completions}" )
}
compctl -K _zsh_revise_complete revise
ZSHDATA
      eval "$SCRIPT"
      unset SCRIPT
      ;;
    bash)
      read -r -d '' SCRIPT <<BASHDATA
_bash_revise_complete () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  typeset cur
  cur=\${COMP_WORDS[COMP_CWORD]}
  COMPREPLY=( \$(compgen -W "\$(_composure_functions)" -- \$cur) )
  return 0
}
complete -F _bash_revise_complete revise
BASHDATA
      eval "$SCRIPT"
      unset SCRIPT
      ;;
    *)
      echo "composure tab completions unavailable"
      ;;
  esac

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


# Second-order functions for composure

function findgroup ()
{
    about 'finds all functions belonging to group'
    param '1: name of group'
    example '$ findgroup tools'
    group 'composure'

    typeset func
    for func in $(_typeset_functions)
    do
        typeset group="$(typeset -f $func | metafor group)"
        if [ "$group" = "${1}" ] 
     then
            echo "$func"
        fi
    done

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function overview ()
{
    about 'gives overview of available shell functions, by group'
    group 'composure'

    # display a brief progress message...
    printf '%s' 'building documentation...'
    typeset grouplist=$(mktemp /tmp/grouplist.XXXX);
    typeset func;
    for func in $(_typeset_functions);
    do
        typeset group="$(typeset -f $func | metafor group)";
        if [ -z "$group" ] 
     then
            group='misc';
        fi;
        typeset about="$(typeset -f $func | metafor about)";
        _letterpress "$about" $func >> $grouplist.$group;
        echo $grouplist.$group >> $grouplist;
    done;
    # clear progress message
    printf '\r%s\n' '                          '
    typeset group;
    typeset gfile;
    for gfile in $(cat $grouplist | sort | uniq);
    do
        printf '%s\n' "${gfile##*.}:";
        cat $gfile;
        printf '\n';
        command rm $gfile 2> /dev/null;
    done | less
    command rm $grouplist 2> /dev/null

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function recompose ()
{
    about 'loads a stored function from ~/.composure repo'
    param '1: name of function'
    example '$ load myfunc'
    group 'composure'

    . $(_get_composure_dir)/$1.inc

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function unique_metafor ()
{
    about 'displays all unique metadata for a given keyword'
    param '1: keyword'
    example '$ unique_metafor group'
    group 'composure'

    typeset keyword=$1

    typeset file=$(mktemp /tmp/composure.XXXX)
    typeset -f | metafor $keyword >> $file
    cat $file | sort | uniq
    command rm $file 2>/dev/null

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function compost () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	about 'delete function stored in composure repo'
	param '1: name of function'
	example '$ compost myfunc'
	group 'composure'

  typeset func=$1
  [ -z "$func" ] && echo "you must specify a function name!" && return 1

  (
	  cd $(_get_composure_dir)
    git rm "$func.inc" && git commit -m "Delete function $func"
  )

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


_load_tab_completions
