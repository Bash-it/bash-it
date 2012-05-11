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

show_plugins ()
{
    about summarizes available bash_it plugins
    group lib

    typeset f
    typeset enabled
    printf "%-20s%-10s%s\n" 'Plugin' 'Enabled?' 'Description'
    for f in $BASH_IT/plugins/available/*.bash
    do
        if [ -h $BASH_IT/plugins/enabled/$(basename $f) ]; then
            enabled='x'
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | cut -d'.' -f1)" "  [$enabled]" "$(cat $f | metafor about-plugin)"
    done
    printf '\n%s\n' 'to enable a plugin, do:'
    printf '%s\n' '$ enable_plugin <plugin name>'
    printf '\n%s\n' 'to disable a plugin, do:'
    printf '%s\n' '$ disable_plugin <plugin name>'
}

enable_plugin ()
{
    about enables bash_it plugin
    param 1: plugin name
    example '$ enable_plugin rvm'
    group lib

    typeset plugin=$(ls $BASH_IT/plugins/available/$1.*bash 2>/dev/null | head -1)
    if [ -z "$plugin" ]; then
        printf '%s\n' 'sorry, that does not appear to be an available plugin.'
        return
    fi

    plugin=$(basename $plugin)
    if [ -h $BASH_IT/plugins/enabled/$plugin ]; then
        printf '%s\n' "$1 is already enabled."
        return
    fi

    ln -s $BASH_IT/plugins/available/$plugin $BASH_IT/plugins/enabled/$plugin
    printf '%s\n' "$1 is enabled."

    reload_plugins
    printf '%s\n' 'plugins reloaded.'
}

disable_plugin ()
{
    about disables bash_it plugin
    param 1: plugin name
    example '$ disable_plugin rvm'
    group lib

    typeset plugin=$(ls $BASH_IT/plugins/enabled/$1.*bash 2>/dev/null | head -1)
    if [ -z "$plugin" ]; then
        printf '%s\n' 'sorry, that does not appear to be an enabled plugin.'
        return
    fi
    rm $BASH_IT/plugins/enabled/$(basename $plugin)
    printf '%s\n' "$1 is disabled, and will be unavailable when you open a new terminal."
}

plugins-help ()
{
    about list all plugins and functions defined by bash-it
    group lib

    printf '%s\n' "bash-it plugins help"
    printf '\n'
    typeset group
    for group in $(all_groups)
    do
        printf '%s\n' "group: $group"
        glossary $group
        printf '\n'
    done
}

all_groups ()
{
    about displays all unique metadata groups
    group lib

    typeset func
    typeset file=$(mktemp /tmp/composure.XXXX)
    for func in $(typeset_functions)
    do
        typeset -f $func | metafor group >> $file
    done
    cat $file | sort | uniq
    rm $file
}
