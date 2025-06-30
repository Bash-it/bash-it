# shellcheck shell=bash

function _sdkman_complete() {
	local CANDIDATES
	local CANDIDATE_VERSIONS
	local SDKMAN_CANDIDATES_CSV="${SDKMAN_CANDIDATES_CSV:-}"

	COMPREPLY=()

	local line
	if [ "$COMP_CWORD" -eq 1 ]; then
		while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "install uninstall rm list ls use default home env current upgrade ug version broadcast help offline selfupdate update flush" -- "${COMP_WORDS[COMP_CWORD]}")
	elif [ "$COMP_CWORD" -eq 2 ]; then
		case "${COMP_WORDS[COMP_CWORD - 1]}" in
			"install" | "i" | "uninstall" | "rm" | "list" | "ls" | "use" | "u" | "default" | "d" | "home" | "h" | "current" | "c" | "upgrade" | "ug")
				CANDIDATES="${SDKMAN_CANDIDATES_CSV//,/${IFS:0:1}}"
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$CANDIDATES" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			"env")
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "init" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			"offline")
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "enable disable" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			"selfupdate")
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "force" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			"flush")
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "archives tmp broadcast version" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			*) ;;

		esac
	elif [ "$COMP_CWORD" -eq 3 ]; then
		case "${COMP_WORDS[COMP_CWORD - 2]}" in
			"uninstall" | "rm" | "use" | "u" | "default" | "d" | "home" | "h")
				_sdkman_candidate_local_versions "${COMP_WORDS[COMP_CWORD - 1]}"
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$CANDIDATE_VERSIONS" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			"install" | "i")
				_sdkman_candidate_all_versions "${COMP_WORDS[COMP_CWORD - 1]}"
				while IFS='' read -r line; do COMPREPLY+=("$line"); done < <(compgen -W "$CANDIDATE_VERSIONS" -- "${COMP_WORDS[COMP_CWORD]}")
				;;
			*) ;;

		esac
	fi

	return 0
}

function _sdkman_candidate_local_versions() {

	CANDIDATE_VERSIONS=$(__sdkman_cleanup_local_versions "$1")

}

function _sdkman_candidate_all_versions() {

	candidate="$1"
	CANDIDATE_LOCAL_VERSIONS=$(__sdkman_cleanup_local_versions "$candidate")
	if [[ "${SDKMAN_OFFLINE_MODE:-false}" == "true" ]]; then
		CANDIDATE_VERSIONS=$CANDIDATE_LOCAL_VERSIONS
	else
		# sdkman has a specific output format for Java candidate since
		# there are multiple vendors and builds.
		if [ "$candidate" = "java" ]; then
			CANDIDATE_ONLINE_VERSIONS="$(__sdkman_list_versions "$candidate" | grep " " | grep "\." | cut -c 62-)"
		else
			CANDIDATE_ONLINE_VERSIONS="$(__sdkman_list_versions "$candidate" | grep " " | grep "\." | cut -c 6-)"
		fi
		# the last grep is used to filter out sdkman flags, such as:
		# "+" - local version
		# "*" - installed
		# ">" - currently in use
		CANDIDATE_VERSIONS="$(echo "$CANDIDATE_ONLINE_VERSIONS $CANDIDATE_LOCAL_VERSIONS" | tr ' ' '\n' | grep -v -e '^[[:space:]|\*|\>|\+]*$' | sort -u) "
	fi

}

function __sdkman_cleanup_local_versions() {

	__sdkman_build_version_csv "$1" | tr ',' ' '

}

complete -F _sdkman_complete sdk
