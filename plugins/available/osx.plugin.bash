cite about-plugin
about-plugin 'osx-specific functions'

# OS X: Open new tabs in same directory
if [ $(uname) = "Darwin" ]; then
  if type update_terminal_cwd > /dev/null 2>&1 ; then
    if ! [[ $PROMPT_COMMAND =~ (^|;)update_terminal_cwd($|;) ]] ; then
      export PROMPT_COMMAND="update_terminal_cwd;$PROMPT_COMMAND"
    fi
  fi
fi

function tab() {
  about 'opens a new terminal tab'
  group 'osx'

  osascript 2>/dev/null <<EOF
    tell application "System Events"
      tell process "Terminal" to keystroke "t" using command down
    end
    tell application "Terminal"
      activate
      do script with command " cd \"$PWD\"; $*" in window 0
    end tell
EOF
}

# renames the current os x terminal tab title
function tabname {
  printf "\e]1;$1\a"
}

# renames the current os x terminal window title
function winname {
  printf "\e]2;$1\a"
}

# this one switches your os x dock between 2d and 3d
# thanks to savier.zwetschge.org
function dock-switch() {
    about 'switch dock between 2d and 3d'
    param '1: "2d" or "3d"'
    example '$ dock-switch 2d'
    group 'osx'

    if [ $(uname) = "Darwin" ]; then

        if [ $1 = 3d ] ; then
            defaults write com.apple.dock no-glass -boolean NO
            killall Dock

        elif [ $1 = 2d ] ; then
            defaults write com.apple.dock no-glass -boolean YES
            killall Dock

        else
            echo "usage:"
            echo "dock-switch 2d"
            echo "dock-switch 3d."
        fi
    else
        echo "Sorry, this only works on Mac OS X"
    fi
}

function pman ()
{
    about 'view man documentation in Preview'
    param '1: man page to view'
    example '$ pman bash'
    group 'osx'
    man -t "${1}" | open -fa $PREVIEW
}

function pri ()
{
    about 'display information about Ruby classes, modules, or methods, in Preview'
    param '1: Ruby method, module, or class'
    example '$ pri Array'
    group 'osx'
    ri -T "${1}" | open -fa $PREVIEW
}

# Download a file and open it in Preview
function prevcurl() {
  about 'download a file and open it in Preview'
  param '1: url'
  group 'osx'

  if [ ! $(uname) = "Darwin" ]
  then
    echo "This function only works with Mac OS X"
    return 1
  fi
  curl "$*" | open -fa $PREVIEW
}

# Make this backwards compatible
alias pcurl='prevcurl'
