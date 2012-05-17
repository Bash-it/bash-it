cite about-plugin
about-plugin 'set up vagrant autocompletion'

_vagrant()
{
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    commands="box destroy halt help init package provision reload resume ssh ssh_config status suspend up version"

    if [ $COMP_CWORD == 1 ]
    then
      COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
      return 0
    fi

    if [ $COMP_CWORD == 2 ]
    then
        case "$prev" in
            "box")
              box_commands="add help list remove repackage"
              COMPREPLY=($(compgen -W "${box_commands}" -- ${cur}))
              return 0
            ;;
            "help")
              COMPREPLY=($(compgen -W "${commands}" -- ${cur}))
              return 0
            ;;
            *)
            ;;
        esac
    fi

    if [ $COMP_CWORD == 3 ]
    then
      action="${COMP_WORDS[COMP_CWORD-2]}"
      if [ $action == 'box' ]
      then
        case "$prev" in
            "remove"|"repackage")
              local box_list=$(find $HOME/.vagrant/boxes/* -maxdepth 0 -type d -printf '%f ')
              COMPREPLY=($(compgen -W "${box_list}" -- ${cur}))
              return 0
              ;;
            *)
            ;;
        esac
      fi
    fi

}
complete -F _vagrant vagrant

