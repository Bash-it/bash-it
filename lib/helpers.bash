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
    about 'Bash-it help and maintenance'
    param '1: verb [one of: help | show | enable | disable | update | search ] '
    param '2: component type [one of: alias(es) | completion(s) | plugin(s) ] or search term(s)'
    param '3: specific component [optional]'
    example '$ bash-it show plugins'
    example '$ bash-it help aliases'
    example '$ bash-it enable plugin git [tmux]...'
    example '$ bash-it disable alias hg [tmux]...'
    example '$ bash-it update'
    example '$ bash-it search ruby [[-]rake]... [--enable | --disable]'
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
         search)
             _bash-it-search $component $*
             return;;
         update)
             func=_bash-it_update;;
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

    if [ x"$verb" == x"enable" -o x"$verb" == x"disable" ];then
        for arg in "$@"
        do
            $func $arg
        done
    else
        $func $*
    fi
}

_is_function ()
{
    _about 'sets $? to true if parameter is the name of a function'
    _param '1: name of alleged function'
    _group 'lib'
    [ -n "$(LANG=C type -t $1 2>/dev/null | grep 'function')" ]
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

_bash-it_update() {
  _about 'updates Bash-it'
  _group 'lib'

  cd "${BASH_IT}"
  if [ -z $BASH_IT_REMOTE ]; then
    BASH_IT_REMOTE="origin"
  fi
  git fetch &> /dev/null
  local status="$(git rev-list master..${BASH_IT_REMOTE}/master 2> /dev/null)"
  if [[ -n "${status}" ]]; then
    git pull --rebase &> /dev/null
    if [[ $? -eq 0 ]]; then
      echo "Bash-it successfully updated, enjoy!"
      reload
    else
      echo "Error updating Bash-it, please, check if your Bash-it installation folder (${BASH_IT}) is clean."
    fi
  else
    echo "Bash-it is up to date, nothing to do!"
  fi
  cd - &> /dev/null
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
    printf '%s\n' "$ bash-it enable $file_type  <$file_type name> [$file_type name]... -or- $ bash-it enable $file_type all"
    printf '\n%s\n' "to disable $preposition $file_type, do:"
    printf '%s\n' "$ bash-it disable $file_type <$file_type name> [$file_type name]... -or- $ bash-it disable $file_type all"
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
            printf '%s\n' "sorry, $file_entity does not appear to be an enabled $file_type."
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
                ln -s ../available/$plugin $BASH_IT/$subdirectory/enabled/$plugin
            fi
        done
    else
        typeset plugin=$(command ls $BASH_IT/$subdirectory/available/$file_entity.*bash 2>/dev/null | head -1)
        if [ -z "$plugin" ]; then
            printf '%s\n' "sorry, $file_entity does not appear to be an available $file_type."
            return
        fi

        plugin=$(basename $plugin)
        if [ -e $BASH_IT/$subdirectory/enabled/$plugin ]; then
            printf '%s\n' "$file_entity is already enabled."
            return
        fi

        mkdir -p $BASH_IT/$subdirectory/enabled

        ln -s ../available/$plugin $BASH_IT/$subdirectory/enabled/$plugin
    fi

    printf '%s\n' "$file_entity enabled."
}

_help-completions()
{
  _about 'summarize all completions available in bash-it'
  _group 'lib'

  _bash-it-completions
}

_help-aliases()
{
    _about 'shows help for all aliases, or a specific alias group'
    _param '1: optional alias group'
    _example '$ alias-help'
    _example '$ alias-help git'

    if [ -n "$1" ]; then
        case $1 in
            custom)
                alias_path='custom.aliases.bash'
            ;;
            *)
                alias_path="available/$1.aliases.bash"
            ;;
        esac
        cat $BASH_IT/aliases/$alias_path | metafor alias | sed "s/$/'/"
    else
        local f
        for f in $BASH_IT/aliases/enabled/*
        do
            echo $f
            _help-list-aliases $f
        done
        echo $BASH_IT/aliases/custom.aliases.bash
        _help-list-aliases $BASH_IT/aliases/custom.aliases.bash
    fi
}

_help-list-aliases ()
{
    local file=$(basename $1)
    printf '\n\n%s:\n' "${file%%.*}"
    # metafor() strips trailing quotes, restore them with sed..
    cat $1 | metafor alias | sed "s/$/'/"
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

_help-update () {
  _about 'help message for update command'
  _group 'lib'

  echo "Check for a new version of Bash-it and update it."
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

if ! type pathmunge > /dev/null 2>&1
then
  function pathmunge () {
    about 'prevent duplicate directories in you PATH variable'
    group 'lib helpers'
    example 'pathmunge /path/to/dir is equivalent to PATH=/path/to/dir:$PATH'
    example 'pathmunge /path/to/dir after is equivalent to PATH=$PATH:/path/to/dir'

    if ! [[ $PATH =~ (^|:)$1($|:) ]] ; then
      if [ "$2" = "after" ] ; then
        export PATH=$PATH:$1
      else
        export PATH=$1:$PATH
      fi
    fi
  }
fi
