#!/usr/bin/env bash
#
# A collection of reusable functions.

###########################################################################
# Generic utilies
###########################################################################

# This function searches an array for an exact match against the term passed
# as the first argument to the function. This function exits as soon as
# a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ _bash-it-array-contains-element apple "@{fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if $(_bash-it-array-contains-element pear "${fruits[@]}"); then
#       echo "contains pear!"
#     fi
#   contains pear!
#
#
_bash-it-array-contains-element() {
  local e
  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

# Dedupe a simple array of words without spaces.
_bash-it-array-dedup() {
  echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Outputs a full path of the grep found on the filesystem
_bash-it-grep() {
  if [[ -z "${BASH_IT_GREP}" ]] ; then
    export BASH_IT_GREP="$(which egrep || which grep || '/usr/bin/grep')"
  fi
  printf "%s " "${BASH_IT_GREP}"
}


###########################################################################
# Component-specific functions (component is either an alias, a plugin, or a
# completion).
###########################################################################

_bash-it-component-help() {
  local component=$(_bash-it-pluralize-component "${1}")
  local file=$(_bash-it-component-cache-file ${component})
  if [[ ! -s "${file}" || -z $(find "${file}" -mmin -300) ]] ; then
    rm -f "${file}" 2>/dev/null
    local func="_bash-it-${component}"
    ${func} | $(_bash-it-grep) -E '   \[' | cat > ${file}
  fi
  cat "${file}"
}

_bash-it-component-cache-file() {
  local component=$(_bash-it-pluralize-component "${1}")
  local file="${BASH_IT}/tmp/cache/${component}"
  [[ -f ${file} ]] || mkdir -p $(dirname ${file})
  printf "${file}"
}

_bash-it-pluralize-component() {
  local component="${1}"
  local len=$(( ${#component} - 1 ))
  # pluralize component name for consistency
  [[ ${component:${len}:1} != 's' ]] && component="${component}s"
  [[ ${component} == "alias" ]] && component="aliases"
  printf ${component}
}

_bash-it-clean-component-cache() {
  local component="$1"
  local cache
  local -a BASH_IT_COMPONENTS=(aliases plugins completions)
  if [[ -z ${component} ]] ; then
    for component in "${BASH_IT_COMPONENTS[@]}" ; do
      _bash-it-clean-component-cache "${component}"
    done
  else
    cache="$(_bash-it-component-cache-file ${component})"
    if [[ -f "${cache}" ]] ; then
      rm -f "${cache}"
    fi
  fi
}

# Returns an array of items within each compoenent.
_bash-it-component-list() {
  local component="$1"
  _bash-it-component-help "${component}" | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

_bash-it-component-list-matching() {
  local component="$1"; shift
  local term="$1"
  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -- "${term}" | awk '{print $1}' | sort | uniq
}

_bash-it-component-list-enabled() {
  local component="$1"
  _bash-it-component-help "${component}" | $(_bash-it-grep) -E  '\[x\]' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

_bash-it-component-list-disabled() {
  local component="$1"
  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -v '\[x\]' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Checks if a given item is enabled for a particular component/file-type.
# Uses the component cache if available.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-enabled alias git && echo "git alias is enabled"
_bash-it-component-item-is-enabled() {
  local component="$1"
  local item="$2"
  _bash-it-component-help "${component}" | $(_bash-it-grep) -E '\[x\]' |  $(_bash-it-grep) -E -q -- "^${item}\s"
}

# Checks if a given item is disabled for a particular component/file-type.
# Uses the component cache if available.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-disabled alias git && echo "git aliases are disabled"
_bash-it-component-item-is-disabled() {
  local component="$1"
  local item="$2"
  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -v '\[x\]' |  $(_bash-it-grep) -E -q -- "^${item}\s"
}
