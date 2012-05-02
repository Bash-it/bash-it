#!/bin/bash
# Composure - don't fear the UNIX chainsaw...
#             these light-hearted shell functions make programming the shell
#             easier and more intuitive
# by erichs, 2012

# latest source available at http://git.io/composure

source_composure ()
{
    if [ -z "$EDITOR" ]
    then
      export EDITOR=vi
    fi

    if $(tty -s)    # is this a TTY?
    then
      bind '"\C-j": edit-and-execute-command'
    fi

    # define default metadata keywords:
    about ()   { :; }
    group ()   { :; }
    param ()   { :; }
    author ()  { :; }
    example () { :; }

    cite ()
    {
        about creates a new meta keyword for use in your functions
        param 1: keyword
        example $ cite url
        example $ url http://somewhere.com
        group composure

        local keyword=$1
        for keyword in $*; do
            eval "function $keyword { :; }"
        done
    }


    draft ()
    {
        about wraps last command into a new function
        param 1: name to give function
        example $ ls
        example $ draft list
        example $ list
        group composure

        local func=$1
        eval 'function ' $func ' { ' $(fc -ln -1) '; }'
        local file=$(mktemp /tmp/draft.XXXX)
        declare -f $func > $file
        transcribe $func $file draft
        rm $file 2>/dev/null
    }

    glossary ()
    {
        about displays help summary for all functions, or summary for a group of functions
        param 1: optional, group name
        example $ glossary
        example $ glossary misc
        group composure

        local targetgroup=${1:-}

        for func in $(compgen -A function); do
            local about="$(metafor $func about)"
            if [ -n "$targetgroup" ]; then
                local group="$(metafor $func group)"
                if [ "$group" != "$targetgroup" ]; then
                    continue  # skip non-matching groups, if specified
                fi
            fi
            letterpress "$about" $func
        done
    }

    letterpress ()
    {
        local metadata=$1 leftcol=${2:- } rightcol

        if [ -z "$metadata" ]; then
            return
        fi

        OLD=$IFS; IFS=$'\n'
        for rightcol in $metadata; do
            printf "%-20s%s\n" $leftcol $rightcol
        done
        IFS=$OLD
    }

    metafor ()
    {
        about prints function metadata associated with keyword
        param 1: function name
        param 2: meta keyword
        example $ metafor glossary example
        group composure
        local func=$1 keyword=$2
        declare -f $func | sed -n "s/;$//;s/^ *$keyword \([^([].*\)*$/\1/p"
    }

    revise ()
    {
        about loads function into editor for revision
        param 1: name of function
        example $ revise myfunction
        group composure

        local func=$1
        local temp=$(mktemp /tmp/revise.XXXX)

        # populate tempfile...
        if [ -f ~/.composure/$func.sh ]; then
            # ...with contents of latest git revision...
            cat ~/.composure/$func.sh >> $temp
        else
            # ...or from ENV if not previously versioned
            declare -f $func >> $temp
        fi
        $EDITOR $temp
        source $temp

        transcribe $func $temp revise
        rm $temp
    }

    reference ()
    {
        about displays apidoc help for a specific function
        param 1: function name
        example $ reference revise
        group composure

        local func=$1

        local about="$(metafor $func about)"
        letterpress "$about" $func

        local params="$(metafor $func param)"
        if [ -n "$params" ]; then
            echo "parameters:"
            letterpress "$params"
        fi

        local examples="$(metafor $func example)"
        if [ -n "$examples" ]; then
            echo "examples:"
            letterpress "$examples"
        fi
    }

    transcribe ()
    {
        about store function in ~/.composure git repository
        param 1: function name
        param 2: file containing function
        param 3: operation label
        example $ transcribe myfunc /tmp/myfunc.sh 'scooby-doo version'
        example stores your function changes with:
        example master 7a7e524 scooby-doo version myfunc
        group composure

        local func=$1
        local file=$2
        local operation="$3"

        if git --version >/dev/null 2>&1; then
            if [ -d ~/.composure ]; then
                (
                    cd ~/.composure
                    if git rev-parse 2>/dev/null; then
                        if [ ! -f $file ]; then
                            echo "Oops! Couldn't find $file to version it for you..."
                            return
                        fi
                        cp $file ~/.composure/$func.sh
                        git add --all .
                        git commit -m "$operation $func"
                    fi
                )
            fi
        fi
    }

 }

install_composure ()
{
    echo 'stay calm. installing composure elements...'

    # find our absolute PATH
    SOURCE="${BASH_SOURCE[0]}"
    while [ -h "$SOURCE" ]; do
        SOURCE="$(readlink "$SOURCE")"
    done
    DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

    # vim: automatically chmod +x scripts with #! lines
    done_previously () { [ ! -z "$(grep BufWritePost | grep bin | grep chmod)" ]; }

    if [ -f ~/.vimrc ] && ! $(<~/.vimrc done_previously); then
      echo 'vimrc: adding automatic chmod+x for files with shebang (#!) lines...'
      echo 'au BufWritePost * if getline(1) =~ "^#!" | if getline(1) =~ "/bin/" | silent execute "!chmod a+x <afile>" | endif | endif' >> ~/.vimrc
    fi

    # source this file in your startup: .bashrc, or .bash_profile
    local done=0
    done_previously () { [ ! -z "$(grep source | grep $DIR | grep composure)" ]; }

    [ -f ~/.bashrc ] && $(<~/.bashrc done_previously) && done=1
    ! (($done)) && [ -f ~/.bash_profile ] && $(<~/.bash_profile done_previously) && done=1

    if ! (($done)); then
      echo 'sourcing composure from .bashrc...'
      echo "source $DIR/$(basename $0)" >> ~/.bashrc
    fi

    # prepare git repo
    if git --version >/dev/null 2>&1; then
        if [ ! -d ~/.composure ]; then
            (
                echo 'creating git repository for your functions...'
                mkdir ~/.composure
                cd ~/.composure
                git init
                echo "composure stores your function definitions here" > README.txt
                git add README.txt
                git commit -m 'initial commit'
            )
        fi
    fi

    echo 'composure installed.'
}

if [ "$BASH_SOURCE" == "$0" ]; then
  install_composure
else
  source_composure
  unset install_composure source_composure
fi

: <<EOF
License: The MIT License

Copyright © 2012 Erich Smith

Permission is hereby granted, free of charge, to any person obtaining a copy of this
software and associated documentation files (the "Software"), to deal in the Software
without restriction, including without limitation the rights to use, copy, modify,
merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
EOF
