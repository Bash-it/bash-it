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

bash-it ()
{
    about 'bash-it help and maintenance'
    param '1: verb [one of: help | show | enable | disable ]'
    param '2: component type [one of: alias(es) | completion(s) | plugin(s) ]'
    param '3: specific component [optional]'
    example '$ bash-it show plugins'
    example '$ bash-it help aliases'
    example '$ bash-it enable plugin git'
    example '$ bash-it disable alias hg'
    typeset verb=${1:-}
    shift
    typeset component=${1:-}
    shift
    typeset func
    case $verb in
         show)
             func=_bash-it-$component;;
         enable)
             func=_enable-$component;;
         disable)
             func=_disable-$component;;
         help)
             func=_help-$component;;
         *)
             reference bash-it
             return;;
    esac

    # pluralize component if necessary
    if ! _is_function $func; then
        if _is_function ${func}s; then
            func=${func}s
        else
            if _is_function ${func}es; then
                func=${func}es
            else
                echo "oops! $component is not a valid option!"
                reference bash-it
                return
            fi
        fi
    fi
    $func $*
}

_is_function ()
{
    _about 'sets $? to true if parameter is the name of a function'
    _param '1: name of alleged function'
    _group 'lib'
    [ -n "$(type -a $1 2>/dev/null | grep 'is a function')" ]
}

_bash-it-aliases ()
{
    _about 'summarizes available bash_it aliases'
    _group 'lib'

    _bash-it-describe "aliases" "an" "alias" "Alias"
}

_bash-it-completions ()
{
    _about 'summarizes available bash_it completions'
    _group 'lib'

    _bash-it-describe "completion" "a" "completion" "Completion"
}

_bash-it-plugins ()
{
    _about 'summarizes available bash_it plugins'
    _group 'lib'

    _bash-it-describe "plugins" "a" "plugin" "Plugin"
}

_bash-it-describe ()
{
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

_disable-plugin ()
{
    _about 'disables bash_it plugin'
    _param '1: plugin name'
    _example '$ disable-plugin rvm'
    _group 'lib'

    _disable-thing "plugins" "plugin" $1
}

_disable-alias ()
{
    _about 'disables bash_it alias'
    _param '1: alias name'
    _example '$ disable-alias git'
    _group 'lib'

    _disable-thing "aliases" "alias" $1
}

_disable-completion ()
{
    _about 'disables bash_it completion'
    _param '1: completion name'
    _example '$ disable-completion git'
    _group 'lib'

    _disable-thing "completion" "completion" $1
}

_disable-thing ()
{
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

_enable-plugin ()
{
    _about 'enables bash_it plugin'
    _param '1: plugin name'
    _example '$ enable-plugin rvm'
    _group 'lib'

    _enable-thing "plugins" "plugin" $1
}

_enable-alias ()
{
    _about 'enables bash_it alias'
    _param '1: alias name'
    _example '$ enable-alias git'
    _group 'lib'

    _enable-thing "aliases" "alias" $1
}

_enable-completion ()
{
    _about 'enables bash_it completion'
    _param '1: completion name'
    _example '$ enable-completion git'
    _group 'lib'

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

_help-aliases()
{
    _about 'shows help for all aliases, or a specific alias group'
    _param '1: optional alias group'
    _example '$ alias-help'
    _example '$ alias-help git'

    if [ -n "$1" ]; then
        cat $BASH_IT/aliases/available/$1.aliases.bash | metafor alias | sed "s/$/'/"
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

_help-plugins()
{
    _about 'summarize all functions defined by enabled bash-it plugins'
    _group 'lib'

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
