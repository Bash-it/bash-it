# This function returns list of aliases, plugins and completions in bash-it,
# whose name or description matches one of the search terms provided as arguments.
#
# Usage:
#    ❯ bash-it search term1 [term2]...
# Example:
#    ❯ bash-it search ruby rbenv rvm gem rake
#  aliases: bundler
#  plugins: chruby chruby-auto rbenv ruby rvm
#  completions: gem rake
#

_bash-it-search() {
  _about 'searches for given terms amongst bash-it plugins, aliases and completions'
  _param '1: term1'
  _param '2: [ term2 ]...'
  _example '$ _bash-it-search ruby rvm rake bundler'

  declare -a _components=(aliases plugins completions)

  for _component in "${_components[@]}" ; do
    _bash-it-search-component  "${_component}" "$@"
  done
}

#
# array=("something to search for" "a string" "test2000")
# _bash-it-array-contains-element "a string" "${array[@]}"
# ( prints "true" or "false" )
_bash-it-array-contains-element () {
  local e
  local r=false
  for e in "${@:2}"; do [[ "$e" == "$1" ]] && r=true; done
  echo -n $r
}

_bash-it-search-component() {
  _about 'searches for given terms amongst a given component'
  _param '1: component type, one of: [ aliases | plugins | completions ]'
  _param '2: term1'
  _param '3: [ term2 ]...'
  _example '$ _bash-it-search-component aliases rake bundler'

  _component=$1

  local func=_bash-it-${_component}
  local help=$($func)
  shift

  # if one of the search terms is --enable or --disable, we will apply
  # this action to the result set interactively.
  local cmd action component_singular
  declare -a _search_commands=(enable disable)
  for _search_command in "${_search_commands[@]}"; do
    if [[ $(_bash-it-array-contains-element "--${_search_command}" "$@") == "true" ]]; then
      cmd=$_search_command
      component_singular=${_component}
      component_singular=${component_singular/es/}  # aliases -> alias
      component_singular=${component_singular/ns/n} # plugins -> plugin
      action="_${cmd}-${component_singular}"
      break
    fi
  done

  declare -a terms=($@)
  declare -a matches=()
  local _grep=$(which egrep || which grep)
  for term in "${terms[@]}"; do
    if [[ "${term}" =~ "--" ]]; then
      continue
    fi
    # print asterisk next to each command that is already enabled
    local term_match=($(echo "${help}"| ${_grep} -i -- ${term} | cut -b -30 | sed 's/ *\[ \]//g;s/ *\[x\]/*/g;' ))
    [[ "${#term_match[@]}" -gt 0 ]] && {
      matches=(${matches[@]} ${term_match[@]})
    }
  done
  _bash-it-search-result $action # "${matches[@]}"
  unset matches
}

_bash-it-search-result() {
  local action=shift
  local color_component color_enable color_disable color_off

  [[ -z "$NO_COLOR" ]] && {
    color_component='\e[0;33m'
    color_enable='\e[1;32m'
    color_disable='\e[0;0m'
    color_off='\e[0;0m'
  }

  [[ -n "$NO_COLOR" ]] && {
    color_enable='*'
  }

  if [[ "${#matches[*]}" -gt 0 ]] ; then
    printf "${color_component}%-12s:${color_off} " "${_component}"
    sorted_matches=($(echo "${matches[*]}" | tr ' ' '\n' | sort | uniq))
    for match in "${sorted_matches[@]}"; do
      local match_color
      if [[ $match =~ "*" ]]; then
        match_color=$color_enable
      else
        match_color=$color_disable
      fi
      printf " ${match_color}${match/\*/}${color_off}"
    done

    printf "\n"
  fi

}
