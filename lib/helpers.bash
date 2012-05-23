# Helper function loading various enable-able files
function _load_bash_it_files() {
  subdirectory="$1"
  if [ ! -d "${BASH_IT}/${subdirectory}/enabled" ]
  then
    continue
  fi
  FILES="${BASH_IT}/${subdirectory}/enabled/*.bash"
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

bash-it-aliases ()
{
    about 'summarizes available bash_it aliases'
    group 'lib'

    _bash-it-describe "aliases" "an" "alias" "Alias"
}

bash-it-completions ()
{
    about 'summarizes available bash_it completions'
    group 'lib'

    _bash-it-describe "completion" "a" "completion" "Completion"
}

bash-it-plugins ()
{
    about 'summarizes available bash_it plugins'
    group 'lib'

    _bash-it-describe "plugins" "a" "plugin" "Plugin"
}

_bash-it-describe ()
{
    cite _about _param _example
    _about 'summarizes available bash_it components'
    _param '1: subdirectory'
    _param '2: preposition'
    _param '3: file_type'
    _param '4: column_header'
    _example '$ _bash-it-describe "plugins" "a" "plugin" "Plugin"'
    
    subdirectory="$1"
    preposition="$2"
    file_type="$3"
    column_header="$4"

    typeset f
    typeset enabled
    printf "%-20s%-10s%s\n" "$column_header" 'Enabled?' 'Description'
    for f in $BASH_IT/$subdirectory/available/*.bash
    do
        if [ -e $BASH_IT/$subdirectory/enabled/$(basename $f) ]; then
            enabled='x'
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | cut -d'.' -f1)" "  [$enabled]" "$(cat $f | metafor about-$file_type)"
    done
    printf '\n%s\n' "to enable $preposition $file_type, do:"
    printf '%s\n' "$ bash-it enable $file_type  <$file_type name> -or- $ bash-it enable $file_type all"
    printf '\n%s\n' "to disable $preposition $file_type, do:"
    printf '%s\n' "$ bash-it disable $file_type <$file_type name> -or- $ bash-it disable $file_type all"
}

disable-plugin ()
{
    about 'disables bash_it plugin'
    param '1: plugin name'
    example '$ disable-plugin rvm'
    group 'lib'

    _disable-thing "plugins" "plugin" $1
}

disable-alias ()
{
    about 'disables bash_it alias'
    param '1: alias name'
    example '$ disable-alias git'
    group 'lib'

    _disable-thing "aliases" "alias" $1
}

disable-completion ()
{
    about 'disables bash_it completion'
    param '1: completion name'
    example '$ disable-completion git'
    group 'lib'

    _disable-thing "completion" "completion" $1
}

_disable-thing ()
{
    cite _about _param _example
    _about 'disables a bash_it component'
    _param '1: subdirectory'
    _param '2: file_type'
    _param '3: file_entity'
    _example '$ _disable-thing "plugins" "plugin" "ssh"'
    
    subdirectory="$1"
    file_type="$2"
    file_entity="$3"

    if [ -z "$file_entity" ]; then
        reference "disable-$file_type"
        return
    fi

    if [ "$file_entity" = "all" ]; then
        typeset f $file_type
        for f in $BASH_IT/$subdirectory/available/*.bash
        do
            plugin=$(basename $f)
            if [ -e $BASH_IT/$subdirectory/enabled/$plugin ]; then
                rm $BASH_IT/$subdirectory/enabled/$(basename $plugin)
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/$subdirectory/enabled/$file_entity.*bash 2>/dev/null | head -1)
        if [ -z "$plugin" ]; then
            printf '%s\n' "sorry, that does not appear to be an enabled $file_type."
            return
        fi
        rm $BASH_IT/$subdirectory/enabled/$(basename $plugin)
    fi

    printf '%s\n' "$file_entity disabled."
}

enable-plugin ()
{
    about 'enables bash_it plugin'
    param '1: plugin name'
    example '$ enable-plugin rvm'
    group 'lib'

    _enable-thing "plugins" "plugin" $1
}

enable-alias ()
{
    about 'enables bash_it alias'
    param '1: alias name'
    example '$ enable-alias git'
    group 'lib'

    _enable-thing "aliases" "alias" $1
}

enable-completion ()
{
    about 'enables bash_it completion'
    param '1: completion name'
    example '$ enable-completion git'
    group 'lib'

    _enable-thing "completion" "completion" $1
}

_enable-thing ()
{
    cite _about _param _example
    _about 'enables a bash_it component'
    _param '1: subdirectory'
    _param '2: file_type'
    _param '3: file_entity'
    _example '$ _enable-thing "plugins" "plugin" "ssh"'	
	
    subdirectory="$1"
    file_type="$2"
    file_entity="$3"

    if [ -z "$file_entity" ]; then
        reference "enable-$file_type"
        return
    fi

    if [ "$file_entity" = "all" ]; then
        typeset f $file_type
        for f in $BASH_IT/$subdirectory/available/*.bash
        do
            plugin=$(basename $f)
            if [ ! -h $BASH_IT/$subdirectory/enabled/$plugin ]; then
                ln -s $BASH_IT/$subdirectory/available/$plugin $BASH_IT/$subdirectory/enabled/$plugin
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/$subdirectory/available/$file_entity.*bash 2>/dev/null | head -1)
        if [ -z "$plugin" ]; then
            printf '%s\n' "sorry, that does not appear to be an available $file_type."
            return
        fi

        plugin=$(basename $plugin)
        if [ -e $BASH_IT/$subdirectory/enabled/$plugin ]; then
            printf '%s\n' "$file_entity is already enabled."
            return
        fi

        ln -s $BASH_IT/$subdirectory/available/$plugin $BASH_IT/$subdirectory/enabled/$plugin
    fi

    printf '%s\n' "$file_entity enabled."
}

alias-help ()
{
    about 'shows help for all aliases, or a specific alias group'
    param '1: optional alias group'
    example '$ alias-help'
    example '$ alias-help git'

    if [ -n "$1" ]; then
        cat $BASH_IT/aliases/enabled/$1.aliases.bash | metafor alias | sed "s/$/'/"
    else
        typeset f
        for f in $BASH_IT/aliases/enabled/*
        do
            typeset file=$(basename $f)
            printf '\n\n%s:\n' "${file%%.*}"
            # metafor() strips trailing quotes, restore them with sed..
            cat $f | metafor alias | sed "s/$/'/"
        done
    fi
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
