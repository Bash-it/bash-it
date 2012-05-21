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
    about 'summarizes available bash_it plugins'
    group 'lib'
    
    file_type="$1"
    preposition="$2"
    command_suffix="$3"
    column_header="$4"

    typeset f
    typeset enabled
    printf "%-20s%-10s%s\n" "$column_header" 'Enabled?' 'Description'
    for f in $BASH_IT/$file_type/available/*.bash
    do
        if [ -e $BASH_IT/$file_type/enabled/$(basename $f) ]; then
            enabled='x'
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | cut -d'.' -f1)" "  [$enabled]" "$(cat $f | metafor about-plugin)"
    done
    printf '\n%s\n' "to enable $preposition $command_suffix, do:"
    printf '%s\n' "$ enable-$command_suffix  <$command_suffix name> -or- $ enable-$command_suffix all"
    printf '\n%s\n' "to disable $preposition $command_suffix, do:"
    printf '%s\n' "$ disable-$command_suffix <$command_suffix name> -or- $ disable-$command_suffix all"
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
	file_type="$1"
	command_suffix="$2"
	file_entity="$3"
	
    if [ -z "$file_entity" ]; then
        reference "disable-$command_suffix"
        return
    fi

    if [ "$file_entity" = "all" ]; then
        typeset f $command_suffix
        for f in $BASH_IT/$file_type/available/*.bash
        do
            plugin=$(basename $f)
            if [ -e $BASH_IT/$file_type/enabled/$plugin ]; then
                rm $BASH_IT/$file_type/enabled/$(basename $plugin)
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/$file_type/enabled/$file_entity.*bash 2>/dev/null | head -1)
        if [ -z "$plugin" ]; then
            printf '%s\n' "sorry, that does not appear to be an enabled $command_suffix."
            return
        fi
        rm $BASH_IT/$file_type/enabled/$(basename $plugin)
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
	file_type="$1"
	command_suffix="$2"
	file_entity="$3"
	
    if [ -z "$file_entity" ]; then
        reference "enable-$command_suffix"
        return
    fi

    if [ "$file_entity" = "all" ]; then
        typeset f $command_suffix
        for f in $BASH_IT/$file_type/available/*.bash
        do
            plugin=$(basename $f)
            if [ ! -h $BASH_IT/$file_type/enabled/$plugin ]; then
                ln -s $BASH_IT/$file_type/available/$plugin $BASH_IT/$file_type/enabled/$plugin
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/$file_type/available/$file_entity.*bash 2>/dev/null | head -1)
        if [ -z "$plugin" ]; then
            printf '%s\n' "sorry, that does not appear to be an available $command_suffix."
            return
        fi

        plugin=$(basename $plugin)
        if [ -e $BASH_IT/$file_type/enabled/$plugin ]; then
            printf '%s\n' "$file_entity is already enabled."
            return
        fi

        ln -s $BASH_IT/$file_type/available/$plugin $BASH_IT/$file_type/enabled/$plugin
    fi

    printf '%s\n' "$file_entity enabled."
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
