#!/usr/bin/env bash
if [[ -n "${ZSH_VERSION}" ]]
then __array_offset=0
else __array_offset=1
fi

autoenv_init()
{
  typeset target home _file
  typeset -a _files
  target=$1
  home="$(dirname $HOME)"

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
}

cd()
{
  if builtin cd "$@"
  then
    autoenv_init
    return 0
  else
    echo "else?"
    return $?
  fi
}
