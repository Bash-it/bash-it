_gvm_complete()
{
  local CANDIDATES
  local CANDIDATE_VERSIONS

  COMPREPLY=()
 
  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen -W "install uninstall rm list ls use current version default selfupdate broadcast offline help flush" -- ${COMP_WORDS[COMP_CWORD]}) )
  elif [ $COMP_CWORD -eq 2 ]; then
    case "${COMP_WORDS[COMP_CWORD-1]}" in
      "install" | "uninstall" | "rm" | "list" | "ls" | "use" | "current" )
        CANDIDATES=$(echo "${GVM_CANDIDATES_CSV}" | tr ',' ' ')
        COMPREPLY=( $(compgen -W "$CANDIDATES" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "offline" )
        COMPREPLY=( $(compgen -W "enable disable" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "selfupdate" )
        COMPREPLY=( $(compgen -W "force" -P "[" -S "]" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "flush" )
        COMPREPLY=( $(compgen -W "candidates broadcast archives temp" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  elif [ $COMP_CWORD -eq 3 ]; then
    case "${COMP_WORDS[COMP_CWORD-2]}" in
      "install" | "uninstall" | "rm" | "use" | "default" )
        _gvm_candidate_versions ${COMP_WORDS[COMP_CWORD-1]}
        COMPREPLY=( $(compgen -W "$CANDIDATE_VERSIONS" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  fi
 
  return 0
}

_gvm_candidate_versions(){

  if _gvm_offline; then
    __gvmtool_build_version_csv $1
    CANDIDATE_VERSIONS="$(echo $CSV | tr ',' ' ')"
  else
    CANDIDATE_VERSIONS="$(curl -s "${GVM_SERVICE}/candidates/$1" | tr ',' ' ')"
  fi

}

_gvm_offline()
{
  if [ "$GVM_ONLINE" = "true" ]; then
    return 1
  else
    return 0
  fi
}

complete -F _gvm_complete gvm
