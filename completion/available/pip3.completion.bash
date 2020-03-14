# https://pip.pypa.io/en/stable/user_guide/#command-completion
# Of course, you should first install the pip, say on Debian:
# sudo apt-get install python-pip
# sudo apt-get install python3-pip

# If the pip package is installed within virtual environments,
# you should first install pip for the corresponding environment.

#https://github.com/Bash-it/bash-it/blob/b35d41464c0bd390e573f7423eaaa63666521c70/themes/base.theme.bash#L511
function safe_append_prompt_command {
    local prompt_re

    if [ "${__bp_imported}" == "defined" ]; then
        # We are using bash-preexec
        if ! __check_precmd_conflict "${1}" ; then
            precmd_functions+=("${1}")
        fi
    else
        # Set OS dependent exact match regular expression
        if [[ ${OSTYPE} == darwin* ]]; then
          # macOS
          prompt_re="[[:<:]]${1}[[:>:]]"
        else
          # Linux, FreeBSD, etc.
          prompt_re="\<${1}\>"
        fi

        if [[ ${PROMPT_COMMAND} =~ ${prompt_re} ]]; then
          return
        elif [[ -z ${PROMPT_COMMAND} ]]; then
          PROMPT_COMMAND="${1}"
        else
          PROMPT_COMMAND="${1};${PROMPT_COMMAND}"
        fi
    fi
}


_pip_completion_bash() {
  # Based on the _pip_completion function defined by pip completion to determine 
  # whether we should reevaluate the pip completion or not: 
  if ! command -v _pip_completion >/dev/null && 
       ( [ -n "$VIRTUAL_ENV" -a -x "$VIRTUAL_ENV/bin/pip3" ] ||
       [ -n "$CONDA_PREFIX" -a -x "$CONDA_PREFIX/bin/pip3" ] ||
       [ -x /usr/bin/pip3 ] ); then
    eval "$(pip3 completion --bash)"
  fi 
}

safe_append_prompt_command _pip_completion_bash



