# Helper function loading various enable-able files
function _load_bash_it_files() {
  file_type="$1"
  if [ ! -d "${BASH_IT}/${file_type}/enabled" ]
  then
    continue
  fi
  FILES="${BASH_IT}/${file_type}/enabled/*.bash"
  for config_file in $FILES
  do
    if [ -e "${config_file}" ]; then
      source $config_file
    fi
  done
}

# Function for reloading aliases
function reload_aliases() {
  _load_bash_it_files "aliases"
}

# Function for reloading auto-completion
function reload_completion() {
  _load_bash_it_files "completion"
}

# Function for reloading plugins
function reload_plugins() {
  _load_bash_it_files "plugins"
}
