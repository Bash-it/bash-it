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

bash-it-plugins ()
{
    about 'summarizes available bash_it plugins'
    group 'lib'

    typeset f
    typeset enabled
    printf "%-20s%-10s%s\n" 'Plugin' 'Enabled?' 'Description'
    for f in $BASH_IT/plugins/available/*.bash
    do
        if [ -e $BASH_IT/plugins/enabled/$(basename $f) ]; then
            enabled='x'
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | cut -d'.' -f1)" "  [$enabled]" "$(cat $f | metafor about-plugin)"
    done
    printf '\n%s\n' 'to enable a plugin, do:'
    printf '%s\n' '$ enable-plugin  <plugin name> -or- $ enable-plugin all'
    printf '\n%s\n' 'to disable a plugin, do:'
    printf '%s\n' '$ disable-plugin <plugin name> -or- $ disable-plugin all'
}

disable-plugin ()
{
    about 'disables bash_it plugin'
    param '1: plugin name'
    example '$ disable-plugin rvm'
    group 'lib'

    if [ -z "$1" ]; then
        reference disable-plugin
        return
    fi

    if [ "$1" = "all" ]; then
        typeset f plugin
        for f in $BASH_IT/plugins/available/*.bash
        do
            plugin=$(basename $f)
            if [ -e $BASH_IT/plugins/enabled/$plugin ]; then
                rm $BASH_IT/plugins/enabled/$(basename $plugin)
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/plugins/enabled/$1.*bash 2>/dev/null | head -1)
        if [ ! -h $plugin ]; then
            printf '%s\n' 'sorry, that does not appear to be an enabled plugin.'
            return
        fi
        rm $BASH_IT/plugins/enabled/$(basename $plugin)
    fi

    printf '%s\n' "$1 disabled."
}

enable-plugin ()
{
    about 'enables bash_it plugin'
    param '1: plugin name'
    example '$ enable-plugin rvm'
    group 'lib'

    if [ -z "$1" ]; then
        reference enable-plugin
        return
    fi

    if [ "$1" = "all" ]; then
        typeset f plugin
        for f in $BASH_IT/plugins/available/*.bash
        do
            plugin=$(basename $f)
            if [ ! -h $BASH_IT/plugins/enabled/$plugin ]; then
                ln -s $BASH_IT/plugins/available/$plugin $BASH_IT/plugins/enabled/$plugin
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/plugins/available/$1.*bash 2>/dev/null | head -1)
        if [ -z "$plugin" ]; then
            printf '%s\n' 'sorry, that does not appear to be an available plugin.'
            return
        fi

        plugin=$(basename $plugin)
        if [ -e $BASH_IT/plugins/enabled/$plugin ]; then
            printf '%s\n' "$1 is already enabled."
            return
        fi

        ln -s $BASH_IT/plugins/available/$plugin $BASH_IT/plugins/enabled/$plugin
    fi

    printf '%s\n' "$1 enabled."
}

plugins-help ()
{
    about 'summarize all functions defined by enabled bash-it plugins'
    group 'lib'

    # display a brief progress message...
    printf '%s' 'please wait, building help...'
    typeset grouplist=$(mktemp /tmp/grouplist.XXXX)
    typeset func
    for func in $(typeset_functions)
    do
        typeset group="$(typeset -f $func | metafor group)"
        if [ -z "$group" ]; then
            group='misc'
        fi
        typeset about="$(typeset -f $func | metafor about)"
        letterpress "$about" $func >> $grouplist.$group
        echo $grouplist.$group >> $grouplist
    done
    # clear progress message
    printf '\r%s\n' '                              '
    typeset group
    typeset gfile
    for gfile in $(cat $grouplist | sort | uniq)
    do
        printf '%s\n' "${gfile##*.}:"
        cat $gfile
        printf '\n'
        rm $gfile 2> /dev/null
    done | less
    rm $grouplist 2> /dev/null
}

all_groups ()
{
    about 'displays all unique metadata groups'
    group 'lib'

    typeset func
    typeset file=$(mktemp /tmp/composure.XXXX)
    for func in $(typeset_functions)
    do
        typeset -f $func | metafor group >> $file
    done
    cat $file | sort | uniq
    rm $file
}
