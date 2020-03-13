# https://pip.pypa.io/en/stable/user_guide/#command-completion
# Of course, you should first install the pip, say on Debian:
# sudo apt-get install python-pip
# sudo apt-get install python3-pip

# If the pip package is installed within virtual environments,
# you should first install pip for the corresponding environment.

# Fix pip completion for running it within/outside of pyenv/virtualenv/venv/conda environment.

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
  local _pip
  # For pip resides within the pyenv/virtualenv/venv/conda environments:
  if [ -n "$VIRTUAL_ENV" ] && [ -x "$VIRTUAL_ENV/bin/pip" ]; then
    _pip="$VIRTUAL_ENV/bin/pip"
  elif [ -n "$CONDA_PREFIX" ] && [ -x "$CONDA_PREFIX/bin/pip" ]; then
    _pip="$CONDA_PREFIX/bin/pip"
  # For pip resides outside of a virtual environment:
  elif [ -x /usr/bin/pip ]; then
    _pip=/usr/bin/pip
  fi
  # FIXME: do the trick without exporting variable into environment:
  if [ -n "$_pip" ]; then
    if [ -z "$_pip_command_path" ] || [ "$_pip_command_path" != "$_pip" ]; then
      eval "$($_pip completion --bash)"
      export _pip_command_path=$_pip
    fi  
  fi 
  unset _pip 
}

safe_append_prompt_command _pip_completion_bash


