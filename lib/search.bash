#
# Search by Konstantin Gredeskoul «github.com/kigster»
#———————————————————————————————————————————————————————————————————————————————
# This function returns list of aliases, plugins and completions in bash-it,
# whose name or description matches one of the search terms provided as arguments.
#
# Usage:
#    ❯ bash-it search term1 [[-]term2] ... [[-]termN] [ --enable | --disable ]
#
# Exmplanation:
#    Single dash, as in "-chruby", indicates a negative search term.
#    Double dash indicates a command that is to be applied to the search result.
#    At the moment only --enable and --disable are supported.
#
# Examples:
#    ❯ bash-it search ruby rbenv rvm gem rake
#    aliases     :  bundler
#    plugins     :  chruby chruby-auto rbenv ruby rvm
#    completions :  gem rake

#    ❯ bash-it search ruby rbenv rvm gem rake -chruby
#    aliases     :  bundler
#    plugins     :  rbenv ruby rvm
#    completions :  gem rake
#
# Examples of enabling or disabling results of the search:
#
#    ❯ bash-it search ruby
#    aliases  =>   bundler
#    plugins  =>   chruby chruby-auto ruby
#
#    ❯ bash-it search ruby -chruby --enable
#    aliases  =>   ✓bundler
#    plugins  =>   ✓ruby
#
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

#———————————————————————————————————————————————————————————————————————————————
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
  _param '2: term1 '
  _param '3: [-]term2 [-]term3 ...'
  _example '$ _bash-it-search-component aliases rake bundler -chruby'

  _component=$1

  local func=_bash-it-${_component}
  local help=$($func)
  shift

  # if one of the search terms is --enable or --disable, we will apply
  # this action to the matches further down.
  local action action_func component_singular
  declare -a _search_commands=(enable disable)
  for _search_command in "${_search_commands[@]}"; do
    if [[ $(_bash-it-array-contains-element "--${_search_command}" "$@") == "true" ]]; then
      action=$_search_command
      component_singular=${_component}
      component_singular=${component_singular/es/}  # aliases -> alias
      component_singular=${component_singular/ns/n} # plugins -> plugin
      action_func="_${action}-${component_singular}"
      break
    fi
  done

  local _grep=$(which egrep || which grep)

  declare -a terms=($@)           # passed on the command line
  declare -a matches=()           # results that we found
  declare -a negative_terms=()    # terms that began with a dash

  for term in "${terms[@]}"; do
    # -- can only be used for the actions: enable/disable
    [[ "${term:0:2}" == "--" ]] && continue
    [[ "${term:0:1}" == "-"  ]] && negative_terms=(${negative_terms[@]} ${term:1}) && continue

    # print asterisk next to each result that is already enabled by the user
    local term_match=($(echo "${help}"| ${_grep} -i -- ${term} | egrep '\[( |x)\]' | cut -b -30 | sed 's/ *\[ \]//g;s/ *\[x\]/*/g;' ))
    [[ "${#term_match[@]}" -gt 0 ]] && {
      matches=(${matches[@]} ${term_match[@]}) # append to the list of results
    }
  done

  # now check if we found any negative terms, and subtract them
  [[ ${#negative_terms} -gt 0 ]] && {
    declare -a filtered_matches=()
    for match in "${matches[@]}"; do
      local negations=0
      for nt in "${negative_terms[@]}"; do
        [[ "${match}" =~ "${nt}" ]] && negations=$(($negations+1))
      done
      [[ $negations -eq 0 ]] && filtered_matches=(${filtered_matches[@]} ${match})
    done
    matches=(${filtered_matches[@]})
  }

  _bash-it-search-result $action $action_func

  unset matches filtered_matches terms
}

_bash-it-search-result() {
  local action=$1; shift
  local action_func=$1; shift
  local color_component color_enable color_disable color_off

  [[ -z "$NO_COLOR" ]] && {
    color_component='\e[1;34m'
    color_enable='\e[1;32m'
    color_disable='\e[0;0m'
    color_off='\e[0;0m'
    color_sep=':'
  }

  [[ -n "$NO_COLOR" ]] && {
    color_component=''
    color_sep='  => '
    color_enable='✓'
    color_disable=''
    color_off=''
  }

  if [[ "${#matches[*]}" -gt 0 ]] ; then
    printf "${color_component}%13s${color_sep} ${color_off}" "${_component}"

    sorted_matches=($(echo "${matches[*]}" | tr ' ' '\n' | sort | uniq))

    for match in "${sorted_matches[@]}"; do
      local match_color compatible_action
      if [[ $match =~ "*" ]]; then
        match_color=$color_enable
        compatible_action="disable"
      else
        match_color=$color_disable
        compatible_action="enable"
      fi

      match_value=${match/\*/}  # remove asterisk
      len=${#match_value}
      if [[ -n $NO_COLOR ]]; then
        local m="${match_color}${match_value}"
        len=${#m}
      fi

      printf " ${match_color}${match_value}"  # print current state

      if [[ "${action}" == "${compatible_action}" ]]; then
        # oh, i see – we need to either disable enabled, or enable disabled
        # component. Let's start with the most important part: redrawing
        # the search result backwards. Because style.

        printf "\033[${len}D"
        for a in {0..30}; do
          [[ $a -gt $len ]] && break
          printf "%.*s" $a " "
          sleep 0.07 # who knew you could sleep for fraction of the cost :)
        done
        printf "\033[${len}D"
        result=$(${action_func} ${match_value})
        local temp="color_${compatible_action}"
        match_color=${!temp}
        printf "${match_color}${match_value}"
      fi

      printf "${color_off}"
    done

    printf "\n"
  fi

}
