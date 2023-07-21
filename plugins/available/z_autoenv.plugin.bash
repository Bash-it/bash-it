cite about-plugin
about-plugin 'source into environment when cding to directories'

if [[ -n "${ZSH_VERSION}" ]]
then __array_offset=0
else __array_offset=1
fi

function autoenv_init()
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  typeset target home _file
  typeset -a _files
  target=$1
  home="${HOME%/*}"

  _files=( $(
    while [[ "$PWD" != "/" && "$PWD" != "$home" ]]
    do
      _file="$PWD/.env"
      if [[ -e "${_file}" ]]
      then echo "${_file}"
      fi
      builtin cd ..
    done
  ) )

  _file=${#_files[@]}
  while (( _file > 0 ))
  do
    source "${_files[_file-__array_offset]}"
    : $(( _file -= 1 ))
  done

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function cd()
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  if builtin cd "${@}"
  then
    autoenv_init
    return 0
  else
    echo "else?"
    return $?
  fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}