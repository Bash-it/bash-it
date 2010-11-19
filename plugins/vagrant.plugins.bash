#!/bin/bash
_vagrant()
{
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"


    if [ $COMP_CWORD == 1 ]
    then
      commands="box destroy halt help init package provision reload resume ssh ssh_config status suspend up version"
      COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
      return 0
    fi

    if [ $COMP_CWORD == 2 ]
    then
      if [ $prev == 'box' ]
      then
          commands="add help list remove repackage"
          COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
          return 0
      fi
    fi

    if [ $COMP_CWORD == 3 ]
    then
      action="${COMP_WORDS[COMP_CWORD-2]}"
      if [ $action == 'box' ]
      then
        case "$prev" in
            "remove"|"repackage")
              local vagrantlist=$(find $HOME/.vagrant/boxes/* -maxdepth 0 -type d -printf '%f ')
              COMPREPLY=($(compgen -W "${vagrantlist}" -- ${cur}))
              return 0
              ;;
            *)
            ;;
        esac
      fi
    fi

}
complete -F _vagrant vagrant

