#!/usr/bin/env bash
# Initialize Bash It
BASH_IT_LOG_PREFIX="core: main: "

# Only set $BASH_IT if it's not already set
if [ -z "$BASH_IT" ];
then
  # Setting $BASH to maintain backwards compatibility
  export BASH_IT=$BASH
  BASH="$(bash -c 'echo $BASH')"
  export BASH
  BASH_IT_OLD_BASH_SETUP=true
fi

# Load composure first, so we support function metadata
# shellcheck source=./lib/composure.bash
source "${BASH_IT}/lib/composure.bash"
# We need to load logging module first as well in order to be able to log
# shellcheck source=./lib/log.bash
source "${BASH_IT}/lib/log.bash"

# We can only log it now
[ -z "$BASH_IT_OLD_BASH_SETUP" ] || _log_warning "BASH_IT variable not initialized, please upgrade your bash-it version and reinstall it!"

# For backwards compatibility, look in old BASH_THEME location
if [ -z "$BASH_IT_THEME" ];
then
  _log_warning "BASH_IT_THEME variable not initialized, please upgrade your bash-it version and reinstall it!"
  export BASH_IT_THEME="$BASH_THEME";
  unset BASH_THEME;
fi

# support 'plumbing' metadata
cite _about _param _example _group _author _version

# libraries, but skip appearance (themes) for now
_log_debug "Loading libraries(except appearance)..."
LIB="${BASH_IT}/lib/*.bash"
APPEARANCE_LIB="${BASH_IT}/lib/appearance.bash"
for _bash_it_config_file in $LIB
do
  if [ "$_bash_it_config_file" != "$APPEARANCE_LIB" ]; then
    filename=${_bash_it_config_file##*/}
    filename=${filename%.bash}
    BASH_IT_LOG_PREFIX="lib: ${filename}: "
    _log_debug "Loading library file..."
    # shellcheck disable=SC1090
    source "$_bash_it_config_file"
  fi
done

# Load the global "enabled" directory
# "family" param is empty so that files get sources in glob order
# shellcheck source=./scripts/reloader.bash
source "${BASH_IT}/scripts/reloader.bash"

# Load enabled aliases, completion, plugins
for file_type in "aliases" "plugins" "completion"
do
  # shellcheck source=./scripts/reloader.bash
  source "${BASH_IT}/scripts/reloader.bash" "skip" "$file_type"
done

# Load theme, if a theme was set
if [[ ! -z "${BASH_IT_THEME}" ]]; then
  _log_debug "Loading \"${BASH_IT_THEME}\" theme..."
  # Load colors and helpers first so they can be used in base theme
  BASH_IT_LOG_PREFIX="themes: colors: "
  # shellcheck source=./themes/colors.theme.bash
  source "${BASH_IT}/themes/colors.theme.bash"
  BASH_IT_LOG_PREFIX="themes: githelpers: "
  # shellcheck source=./themes/githelpers.theme.bash
  source "${BASH_IT}/themes/githelpers.theme.bash"
  BASH_IT_LOG_PREFIX="themes: p4helpers: "
  # shellcheck source=./themes/p4helpers.theme.bash
  source "${BASH_IT}/themes/p4helpers.theme.bash"
  BASH_IT_LOG_PREFIX="themes: base: "
  # shellcheck source=./themes/base.theme.bash
  source "${BASH_IT}/themes/base.theme.bash"

  BASH_IT_LOG_PREFIX="lib: appearance: "
  # appearance (themes) now, after all dependencies
  # shellcheck source=./lib/appearance.bash
  source "$APPEARANCE_LIB"
fi

BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading custom aliases, completion, plugins..."
for file_type in "aliases" "completion" "plugins"
do
  if [ -e "${BASH_IT}/${file_type}/custom.${file_type}.bash" ]
  then
    BASH_IT_LOG_PREFIX="${file_type}: custom: "
    _log_debug "Loading component..."
    # shellcheck disable=SC1090
    source "${BASH_IT}/${file_type}/custom.${file_type}.bash"
  fi
done

# Custom
BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading general custom files..."
CUSTOM="${BASH_IT_CUSTOM:=${BASH_IT}/custom}/*.bash ${BASH_IT_CUSTOM:=${BASH_IT}/custom}/**/*.bash"
for _bash_it_config_file in $CUSTOM
do
  if [ -e "${_bash_it_config_file}" ]; then
    filename=$(basename "${_bash_it_config_file}")
    filename=${filename%*.bash}
    BASH_IT_LOG_PREFIX="custom: $filename: "
    _log_debug "Loading custom file..."
    # shellcheck disable=SC1090
    source "$_bash_it_config_file"
  fi
done

unset _bash_it_config_file
if [[ $PROMPT ]]; then
  export PS1="\[""$PROMPT""\]"
fi

# Adding Support for other OSes
PREVIEW="less"

if [ -s /usr/bin/gloobus-preview ]; then
  PREVIEW="gloobus-preview"
elif [ -s /Applications/Preview.app ]; then
  # shellcheck disable=SC2034
  PREVIEW="/Applications/Preview.app"
fi

# Load all the Jekyll stuff

if [ -e "$HOME/.jekyllconfig" ]
then
  # shellcheck disable=SC1090
  . "$HOME/.jekyllconfig"
fi

# BASH_IT_RELOAD_LEGACY is set.
if ! command -v reload &>/dev/null && [ -n "$BASH_IT_RELOAD_LEGACY" ]; then
  case $OSTYPE in
    darwin*)
      alias reload='source ~/.bash_profile'
      ;;
    *)
      alias reload='source ~/.bashrc'
      ;;
  esac
fi

# Disable trap DEBUG on subshells - https://github.com/Bash-it/bash-it/pull/1040
set +T
