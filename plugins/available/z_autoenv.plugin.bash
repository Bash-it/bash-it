cite about-plugin
about-plugin 'source into environment when cding to directories'

if [[ -n "${ZSH_VERSION}" ]]
then __array_offset=0
else __array_offset=1
fi

autoenv_init()
{
  typeset target home _file
  typeset -a _files
  target=$1
  home="$(dirname "$HOME")"

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

# Bash support for Zsh like chpwd hook
[[ -n "${ZSH_VERSION:-}" ]] || { cd() { __zsh_like_cd cd "$@" ; } }

__zsh_like_cd()
{
  \typeset __zsh_like_cd_hook
  if
    builtin "$@"
  then
    shift || true # remove the called method
    for __zsh_like_cd_hook in chpwd "${chpwd_functions[@]}"
    do
      if \typeset -f "$__zsh_like_cd_hook" >/dev/null 2>&1
      then "$__zsh_like_cd_hook" "$@" || break # finish on first failed hook
      fi
    done
    true
  else
    return $?
  fi
}

[[ -n "${chpwd_functions}" ]] || { export -a chpwd_functions; } # define hooks as shell array
[[ " ${chpwd_functions[*]} " == *" autoenv_init "* ]] ||        # prevent double addition
chpwd_functions+=(autoenv_init)                                 # add hook to the list
