
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
    _bash-it-search-component  "${_component}" "$*"
  done
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
  declare -a terms=($@)
  declare -a matches=()
  local _grep=$(which egrep || which grep)
  for term in "${terms[@]}"; do
    local term_match=($(echo "${help}"| ${_grep} -i -- ${term} | cut -d ' ' -f 1  | tr '\n' ' '))
    [[ "${#term_match[@]}" -gt 0 ]] && {
      matches=(${matches[@]} ${term_match[@]})
    }
  done
  [[ -n "$NO_COLOR" && color_on="" ]]  || color_on="\e[1;32m"
  [[ -n "$NO_COLOR" && color_off="" ]] || color_off="\e[0;0m"

  if [[ "${#matches[*]}" -gt 0 ]] ; then
    printf "%-12s: ${color_on}%s${color_off}\n" "${_component}" "$(echo -n ${matches[*]} | tr ' ' '\n' | sort | uniq | tr '\n' ' ' | sed 's/ $//g')"
  fi
  unset matches
}
