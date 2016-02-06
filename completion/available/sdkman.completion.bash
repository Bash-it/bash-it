_sdkman_complete()
{
  local CANDIDATES
  local CANDIDATE_VERSIONS

  COMPREPLY=()

  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen -W "install uninstall rm list ls use current outdated version default selfupdate broadcast offline help flush" -- ${COMP_WORDS[COMP_CWORD]}) )
  elif [ $COMP_CWORD -eq 2 ]; then
    case "${COMP_WORDS[COMP_CWORD-1]}" in
      "install" | "uninstall" | "rm" | "list" | "ls" | "use" | "current" | "outdated" )
        CANDIDATES=$(echo "${SDKMAN_CANDIDATES_CSV}" | tr ',' ' ')
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
        _sdkman_candidate_versions ${COMP_WORDS[COMP_CWORD-1]}
        COMPREPLY=( $(compgen -W "$CANDIDATE_VERSIONS" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  fi

  return 0
}

_sdkman_candidate_versions(){

  CANDIDATE_LOCAL_VERSIONS=$(__sdkman_cleanup_local_versions $1)
  if [ "$SDKMAN_OFFLINE_MODE" = "true" ]; then
    CANDIDATE_VERSIONS=$CANDIDATE_LOCAL_VERSIONS
  else
    CANDIDATE_ONLINE_VERSIONS="$(curl -s "${SDKMAN_SERVICE}/candidates/$1" | tr ',' ' ')"
    CANDIDATE_VERSIONS="$(echo $CANDIDATE_ONLINE_VERSIONS $CANDIDATE_LOCAL_VERSIONS |sort | uniq ) "
  fi

}

__sdkman_cleanup_local_versions(){

  __sdkman_build_version_csv $1
  echo $CSV | tr ',' ' '

}

complete -F _sdkman_complete sdk
