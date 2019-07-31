#!/usr/bin/env bash

BASH_IT_LOAD_PRIORITY_DEFAULT_ALIAS=${BASH_IT_LOAD_PRIORITY_DEFAULT_ALIAS:-150}
BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGIN=${BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGIN:-250}
BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETION=${BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETION:-350}
BASH_IT_LOAD_PRIORITY_SEPARATOR="---"

# Handle the different ways of running `sed` without generating a backup file based on OS
# - GNU sed (Linux) uses `-i`
# - BSD sed (macOS) uses `-i ''`
# To use this in Bash-it for inline replacements with `sed`, use the following syntax:
# sed "${BASH_IT_SED_I_PARAMETERS[@]}" -e "..." file
BASH_IT_SED_I_PARAMETERS=(-i)
case "$(uname)" in
  Darwin*) BASH_IT_SED_I_PARAMETERS=(-i "")
esac

function _command_exists ()
{
  _about 'checks for existence of a command'
  _param '1: command to check'
  _example '$ _command_exists ls && echo exists'
  _group 'lib'
  type "$1" &> /dev/null ;
}

function _make_reload_alias() {
  echo "source \${BASH_IT}/scripts/reloader.bash ${1} ${2}"
}

# Alias for reloading aliases
# shellcheck disable=SC2139
alias reload_aliases="$(_make_reload_alias alias aliases)"

# Alias for reloading auto-completion
# shellcheck disable=SC2139
alias reload_completion="$(_make_reload_alias completion completion)"

# Alias for reloading plugins
# shellcheck disable=SC2139
alias reload_plugins="$(_make_reload_alias plugin plugins)"

bash-it ()
{
    about 'Bash-it help and maintenance'
    param '1: verb [one of: help | show | enable | disable | migrate | update | search | version | reload ] '
    param '2: component type [one of: alias(es) | completion(s) | plugin(s) ] or search term(s)'
    param '3: specific component [optional]'
    example '$ bash-it show plugins'
    example '$ bash-it help aliases'
    example '$ bash-it enable plugin git [tmux]...'
    example '$ bash-it disable alias hg [tmux]...'
    example '$ bash-it migrate'
    example '$ bash-it update'
    example '$ bash-it search [-|@]term1 [-|@]term2 ... [ -e/--enable ] [ -d/--disable ] [ -r/--refresh ] [ -c/--no-color ]'
    example '$ bash-it version'
    example '$ bash-it reload'
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
        _bash-it-search $component "$@"
        return;;
      update)
        func=_bash-it_update;;
      migrate)
        func=_bash-it-migrate;;
      version)
        func=_bash-it-version;;
      reload)
        func=_bash-it-reload;;
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

    if [ x"$verb" == x"enable" ] || [ x"$verb" == x"disable" ]; then
        # Automatically run a migration if required
        _bash-it-migrate

        for arg in "$@"
        do
            $func $arg
        done
    else
        $func "$@"
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

  local old_pwd="${PWD}"

  cd "${BASH_IT}" || return

  if [ -z $BASH_IT_REMOTE ]; then
    BASH_IT_REMOTE="origin"
  fi

  git fetch &> /dev/null

  declare status
  status="$(git rev-list master..${BASH_IT_REMOTE}/master 2> /dev/null)"

  if [[ -n "${status}" ]]; then

    for i in $(git rev-list --merges --first-parent master..${BASH_IT_REMOTE}); do
      num_of_lines=$(git log -1 --format=%B $i | awk 'NF' | wc -l)
      if [ $num_of_lines -eq 1 ]; then
        description="%s"
      else
        description="%b"
      fi
      git log --format="%h: $description (%an)" -1 $i
    done
    echo ""
    read -e -n 1 -p "Would you like to update to $(git log -1 --format=%h origin/master)? [Y/n] " RESP
    case $RESP in
      [yY]|"")
        git pull --rebase &> /dev/null
        if [[ $? -eq 0 ]]; then
          echo "Bash-it successfully updated."
          echo ""
          echo "Migrating your installation to the latest version now..."
          _bash-it-migrate
          echo ""
          echo "All done, enjoy!"
          bash-it reload
        else
          echo "Error updating Bash-it, please, check if your Bash-it installation folder (${BASH_IT}) is clean."
        fi
        ;;
      [nN])
        echo "Not upgrading…"
        ;;
      *)
        echo -e "\033[91mPlease choose y or n.\033[m"
        ;;
      esac
  else
    echo "Bash-it is up to date, nothing to do!"
  fi
  cd "${old_pwd}" &> /dev/null || return
}

_bash-it-migrate() {
  _about 'migrates Bash-it configuration from a previous format to the current one'
  _group 'lib'

  declare migrated_something
  migrated_something=false

  for file_type in "aliases" "plugins" "completion"
  do
    for f in `sort <(compgen -G "${BASH_IT}/$file_type/enabled/*.bash")`
    do
      typeset ff=$(basename $f)

      # Get the type of component from the extension
      typeset single_type=$(echo $ff | sed -e 's/.*\.\(.*\)\.bash/\1/g' | sed 's/aliases/alias/g')
      # Cut off the optional "250---" prefix and the suffix
      typeset component_name=$(echo $ff | sed -e 's/[0-9]*[-]*\(.*\)\..*\.bash/\1/g')

      migrated_something=true

      echo "Migrating $single_type $component_name."

      disable_func="_disable-$single_type"
      enable_func="_enable-$single_type"

      $disable_func $component_name
      $enable_func $component_name
    done
  done

  if [ "$migrated_something" = "true" ]; then
    echo ""
    echo "If any migration errors were reported, please try the following: reload && bash-it migrate"
  fi
}

_bash-it-version() {
  _about 'shows current Bash-it version'
  _group 'lib'

  cd "${BASH_IT}" || return

  if [ -z $BASH_IT_REMOTE ]; then
    BASH_IT_REMOTE="origin"
  fi

  BASH_IT_GIT_REMOTE=$(git remote get-url $BASH_IT_REMOTE)
  BASH_IT_GIT_URL=${BASH_IT_GIT_REMOTE%.git}

  BASH_IT_GIT_VERSION_INFO="$(git log --pretty=format:'%h on %aI' -n 1)"
  BASH_IT_GIT_SHA=${BASH_IT_GIT_VERSION_INFO%% *}

  echo "Current git SHA: $BASH_IT_GIT_VERSION_INFO"
  echo "$BASH_IT_GIT_URL/commit/$BASH_IT_GIT_SHA"
  echo "Compare to latest: $BASH_IT_GIT_URL/compare/$BASH_IT_GIT_SHA...master"

  cd - &> /dev/null || return
}

_bash-it-reload() {
  _about 'reloads a profile file'
  _group 'lib'

  pushd "${BASH_IT}" &> /dev/null || return

  case $OSTYPE in
    darwin*)
      source ~/.bash_profile
      ;;
    *)
      source ~/.bashrc
      ;;
  esac

  popd &> /dev/null || return
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
    for f in "${BASH_IT}/$subdirectory/available/"*.bash
    do
        # Check for both the old format without the load priority, and the extended format with the priority
        declare enabled_files enabled_file
        enabled_file=$(basename $f)
        enabled_files=$(sort <(compgen -G "${BASH_IT}/enabled/*$BASH_IT_LOAD_PRIORITY_SEPARATOR${enabled_file}") <(compgen -G "${BASH_IT}/$subdirectory/enabled/${enabled_file}") <(compgen -G "${BASH_IT}/$subdirectory/enabled/*$BASH_IT_LOAD_PRIORITY_SEPARATOR${enabled_file}") | wc -l)

        if [ $enabled_files -gt 0 ]; then
            enabled='x'
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | sed -e 's/\(.*\)\..*\.bash/\1/g')" "  [$enabled]" "$(cat $f | metafor about-$file_type)"
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

    typeset f suffix
    suffix=$(echo "$subdirectory" | sed -e 's/plugins/plugin/g')

    if [ "$file_entity" = "all" ]; then
        # Disable everything that's using the old structure
        for f in `compgen -G "${BASH_IT}/$subdirectory/enabled/*.${suffix}.bash"`
        do
          rm "$f"
        done

        # Disable everything in the global "enabled" directory
        for f in `compgen -G "${BASH_IT}/enabled/*.${suffix}.bash"`
        do
          rm "$f"
        done
    else
        typeset plugin_global=$(command ls $ "${BASH_IT}/enabled/"[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.bash 2>/dev/null | head -1)
        if [ -z "$plugin_global" ]; then
          # Use a glob to search for both possible patterns
          # 250---node.plugin.bash
          # node.plugin.bash
          # Either one will be matched by this glob
          typeset plugin=$(command ls $ "${BASH_IT}/$subdirectory/enabled/"{[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.bash,$file_entity.$suffix.bash} 2>/dev/null | head -1)
          if [ -z "$plugin" ]; then
              printf '%s\n' "sorry, $file_entity does not appear to be an enabled $file_type."
              return
          fi
          rm "${BASH_IT}/$subdirectory/enabled/$(basename $plugin)"
        else
          rm "${BASH_IT}/enabled/$(basename $plugin_global)"
        fi
    fi

    _bash-it-clean-component-cache "${file_type}"

    if [ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]; then
        exec ${0/-/}
    fi

    printf '%s\n' "$file_entity disabled."
}

_enable-plugin ()
{
    _about 'enables bash_it plugin'
    _param '1: plugin name'
    _example '$ enable-plugin rvm'
    _group 'lib'

    _enable-thing "plugins" "plugin" $1 $BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGIN
}

_enable-alias ()
{
    _about 'enables bash_it alias'
    _param '1: alias name'
    _example '$ enable-alias git'
    _group 'lib'

    _enable-thing "aliases" "alias" $1 $BASH_IT_LOAD_PRIORITY_DEFAULT_ALIAS
}

_enable-completion ()
{
    _about 'enables bash_it completion'
    _param '1: completion name'
    _example '$ enable-completion git'
    _group 'lib'

    _enable-thing "completion" "completion" $1 $BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETION
}

_enable-thing ()
{
    cite _about _param _example
    _about 'enables a bash_it component'
    _param '1: subdirectory'
    _param '2: file_type'
    _param '3: file_entity'
    _param '4: load priority'
    _example '$ _enable-thing "plugins" "plugin" "ssh" "150"'

    subdirectory="$1"
    file_type="$2"
    file_entity="$3"
    load_priority="$4"

    if [ -z "$file_entity" ]; then
        reference "enable-$file_type"
        return
    fi

    if [ "$file_entity" = "all" ]; then
        typeset f $file_type
        for f in "${BASH_IT}/$subdirectory/available/"*.bash
        do
            to_enable=$(basename $f .$file_type.bash)
            if [ "$file_type" = "alias" ]; then
              to_enable=$(basename $f ".aliases.bash")
            fi
            _enable-thing $subdirectory $file_type $to_enable $load_priority
        done
    else
        typeset to_enable=$(command ls "${BASH_IT}/$subdirectory/available/"$file_entity.*bash 2>/dev/null | head -1)
        if [ -z "$to_enable" ]; then
            printf '%s\n' "sorry, $file_entity does not appear to be an available $file_type."
            return
        fi

        to_enable=$(basename $to_enable)
        # Check for existence of the file using a wildcard, since we don't know which priority might have been used when enabling it.
        typeset enabled_plugin=$(command ls "${BASH_IT}/$subdirectory/enabled/"{[0-9][0-9][0-9]$BASH_IT_LOAD_PRIORITY_SEPARATOR$to_enable,$to_enable} 2>/dev/null | head -1)
        if [ ! -z "$enabled_plugin" ] ; then
          printf '%s\n' "$file_entity is already enabled."
          return
        fi

        typeset enabled_plugin_global=$(command compgen -G "${BASH_IT}/enabled/[0-9][0-9][0-9]$BASH_IT_LOAD_PRIORITY_SEPARATOR$to_enable" 2>/dev/null | head -1)
        if [ ! -z "$enabled_plugin_global" ] ; then
          printf '%s\n' "$file_entity is already enabled."
          return
        fi

        mkdir -p "${BASH_IT}/enabled"

        # Load the priority from the file if it present there
        declare local_file_priority use_load_priority
        local_file_priority=$(grep -E "^# BASH_IT_LOAD_PRIORITY:" "${BASH_IT}/$subdirectory/available/$to_enable" | awk -F': ' '{ print $2 }')
        use_load_priority=${local_file_priority:-$load_priority}

        ln -s ../$subdirectory/available/$to_enable "${BASH_IT}/enabled/${use_load_priority}${BASH_IT_LOAD_PRIORITY_SEPARATOR}${to_enable}"
    fi

    _bash-it-clean-component-cache "${file_type}"

    if [ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]; then
        exec ${0/-/}
    fi

    printf '%s\n' "$file_entity enabled with priority $use_load_priority."
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
        cat "${BASH_IT}/aliases/$alias_path" | metafor alias | sed "s/$/'/"
    else
        typeset f

        for f in `sort <(compgen -G "${BASH_IT}/aliases/enabled/*") <(compgen -G "${BASH_IT}/enabled/*.aliases.bash")`
        do
            _help-list-aliases $f
        done

        if [ -e "${BASH_IT}/aliases/custom.aliases.bash" ]; then
          _help-list-aliases "${BASH_IT}/aliases/custom.aliases.bash"
        fi
    fi
}

_help-list-aliases ()
{
    typeset file=$(basename $1 | sed -e 's/[0-9]*[-]*\(.*\)\.aliases\.bash/\1/g')
    printf '\n\n%s:\n' "${file}"
    # metafor() strips trailing quotes, restore them with sed..
    cat $1 | metafor alias | sed "s/$/'/"
}

_help-plugins()
{
    _about 'summarize all functions defined by enabled bash-it plugins'
    _group 'lib'

    # display a brief progress message...
    printf '%s' 'please wait, building help...'
    typeset grouplist=$(mktemp -t grouplist.XXXXXX)
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

_help-migrate () {
  _about 'help message for migrate command'
  _group 'lib'

  echo "Migrates internal Bash-it structure to the latest version in case of changes."
  echo "The 'migrate' command is run automatically when calling 'update', 'enable' or 'disable'."
}

all_groups ()
{
    about 'displays all unique metadata groups'
    group 'lib'

    typeset func
    typeset file=$(mktemp -t composure.XXXX)
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
    group 'helpers'
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
