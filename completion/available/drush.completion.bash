#!/usr/bin/env bash
#
# bash completion support for Drush:
#   https://github.com/drush-ops/drush
#
# Originally from:
#   http://github.com/drush-ops/drush/blob/master/drush.complete.sh

# Ensure drush is available.
which drush > /dev/null || alias drush &> /dev/null || return

__drush_ps1() {
  f="${TMPDIR:-/tmp/}/drush-env/drush-drupal-site-$$"
  if [ -f $f ]
  then
    __DRUPAL_SITE=$(cat "$f")
  else
    __DRUPAL_SITE="$DRUPAL_SITE"
  fi

  [[ -n "$__DRUPAL_SITE" ]] && printf "${1:- (%s)}" "$__DRUPAL_SITE"
}

# Completion function, uses the "drush complete" command to retrieve
# completions for a specific command line COMP_WORDS.
_drush_completion() {
  # Set IFS to newline (locally), since we only use newline separators, and
  # need to retain spaces (or not) after completions.
  local IFS=$'\n'
  # The '< /dev/null' is a work around for a bug in php libedit stdin handling.
  # Note that libedit in place of libreadline in some distributions. See:
  # https://bugs.launchpad.net/ubuntu/+source/php5/+bug/322214
  COMPREPLY=( $(drush --early=includes/complete.inc "${COMP_WORDS[@]}" < /dev/null 2> /dev/null) )
}

# Register our completion function. We include common short aliases for Drush.
complete -o bashdefault -o default -o nospace -F _drush_completion d dr drush drush5 drush6 drush6 drush.php
