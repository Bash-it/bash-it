_sdkman_complete()
{
  local CANDIDATES
  local CANDIDATE_VERSIONS

  COMPREPLY=()

  if [ $COMP_CWORD -eq 1 ]; then
    COMPREPLY=( $(compgen -W "install uninstall rm list ls use default home env current upgrade ug version broadcast help offline selfupdate update flush" -- ${COMP_WORDS[COMP_CWORD]}) )
  elif [ $COMP_CWORD -eq 2 ]; then
    case "${COMP_WORDS[COMP_CWORD-1]}" in
      "install" | "i" | "uninstall" | "rm" | "list" | "ls" | "use" | "u" | "default" | "d" | "home" | "h" | "current" | "c" | "upgrade" | "ug" )
        CANDIDATES=$(echo "${SDKMAN_CANDIDATES_CSV}" | tr ',' ' ')
        COMPREPLY=( $(compgen -W "$CANDIDATES" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "env" )
        COMPREPLY=( $(compgen -W "init" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "offline" )
        COMPREPLY=( $(compgen -W "enable disable" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "selfupdate" )
        COMPREPLY=( $(compgen -W "force" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "flush" )
        COMPREPLY=( $(compgen -W "archives tmp broadcast version" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  elif [ $COMP_CWORD -eq 3 ]; then
    case "${COMP_WORDS[COMP_CWORD-2]}" in
      "uninstall" | "rm" | "use" | "u" | "default" | "d" | "home" | "h" )
        _sdkman_candidate_local_versions ${COMP_WORDS[COMP_CWORD-1]}
        COMPREPLY=( $(compgen -W "$CANDIDATE_VERSIONS" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      "install" | "i" )
        _sdkman_candidate_all_versions ${COMP_WORDS[COMP_CWORD-1]}
        COMPREPLY=( $(compgen -W "$CANDIDATE_VERSIONS" -- ${COMP_WORDS[COMP_CWORD]}) )
        ;;
      *)
        ;;
    esac
  fi

  return 0
}

_sdkman_candidate_local_versions(){

  CANDIDATE_VERSIONS=$(__sdkman_cleanup_local_versions $1)

}

_sdkman_candidate_all_versions(){

  CANDIDATE_LOCAL_VERSIONS=$(__sdkman_cleanup_local_versions $1)
  if [ "$SDKMAN_OFFLINE_MODE" = "true" ]; then
    CANDIDATE_VERSIONS=$CANDIDATE_LOCAL_VERSIONS
  else
    CANDIDATE_ONLINE_VERSIONS="$(__sdkman_list_versions $1 | grep " " | grep "\." | cut -c 62-)"
    CANDIDATE_VERSIONS="$(echo $CANDIDATE_ONLINE_VERSIONS $CANDIDATE_LOCAL_VERSIONS | tr ' ' '\n' | sort | uniq -u) "
  fi

}

__sdkman_cleanup_local_versions(){

  __sdkman_build_version_csv $1 | tr ',' ' '

}

complete -F _sdkman_complete sdk
