# composure - by erichs
# light-hearted functions for intuitive shell programming

# install: source this script in your ~/.profile or ~/.${SHELL}rc script

# latest source available at http://git.io/composure
# known to work on bash, zsh, and ksh93

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

    # this is the storage half of the 'metadata' system:
    # we create dynamic metadata keywords with function wrappers around
    # the NOP command, ':'

    # anything following a keyword will get parsed as a positional
    # parameter, but stay resident in the ENV. As opposed to shell
    # comments, '#', which do not get parsed and are not available
    # at runtime.

    # a BIG caveat--your metadata must be roughly parsable: do not use
    # contractions, and consider single or double quoting if it contains
    # non-alphanumeric characters

    typeset keyword
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

    typeset func=$1
    eval 'function ' $func ' { ' $(fc -ln -1) '; }'
    typeset file=$(mktemp /tmp/draft.XXXX)
    typeset -f $func > $file
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

    typeset targetgroup=${1:-}

    for func in $(listfunctions); do
        typeset about="$(metafor $func about)"
        if [ -n "$targetgroup" ]; then
            typeset group="$(metafor $func group)"
            if [ "$group" != "$targetgroup" ]; then
                continue  # skip non-matching groups, if specified
            fi
        fi
        letterpress "$about" $func
    done
}

letterpress ()
{
    typeset metadata=$1 leftcol=${2:- } rightcol

    if [ -z "$metadata" ]; then
        return
    fi

    OLD=$IFS; IFS=$'\n'
    for rightcol in $metadata; do
        printf "%-20s%s\n" $leftcol $rightcol
    done
    IFS=$OLD
}

listfunctions ()
{
    # unfortunately, there does not seem to be a easy, portable way to list just the
    # names of the defined shell functions...

    # here's a hack I modified from a StackOverflow post:
    # we loop over the ps listing for the current process ($$), and print the last column (CMD)
    # stripping any leading hyphens bash sometimes throws in there

    typeset x ans
    typeset this=$(for x in $(ps -p $$); do ans=$x; done; printf "%s\n" $ans | sed 's/^-*//')
    typeset shell=$(basename $this)  # e.g. /bin/bash => bash
    case "$shell" in
        bash)
            typeset -F | awk '{print $3}'
            ;;
        *)
            # trim everything following '()' in ksh
            typeset +f | sed 's/().*$//'
            ;;
    esac
}

metafor ()
{
    about prints function metadata associated with keyword
    param 1: function name
    param 2: meta keyword
    example $ metafor glossary example
    group composure
    typeset func=$1 keyword=$2

    # this sed-fu is the retrieval half of the 'metadata' system:
    # first 'cat' the function definition,
    # then 'grep' for the metadata keyword, and
    # then parse and massage the matching line
    typeset -f $func | sed -n "s/;$//;s/^[ 	]*$keyword \([^([].*\)*$/\1/p"
}

reference ()
{
    about displays apidoc help for a specific function
    param 1: function name
    example $ reference revise
    group composure

    typeset func=$1

    typeset about="$(metafor $func about)"
    letterpress "$about" $func

    typeset params="$(metafor $func param)"
    if [ -n "$params" ]; then
        printf "parameters:\n"
        letterpress "$params"
    fi

    typeset examples="$(metafor $func example)"
    if [ -n "$examples" ]; then
        printf "examples:\n"
        letterpress "$examples"
    fi
}

revise ()
{
    about loads function into editor for revision
    param 1: name of function
    example $ revise myfunction
    group composure

    typeset func=$1
    typeset temp=$(mktemp /tmp/revise.XXXX)

    # populate tempfile...
    if [ -f ~/.composure/$func.inc ]; then
        # ...with contents of latest git revision...
        cat ~/.composure/$func.inc >> $temp
    else
        # ...or from ENV if not previously versioned
        typeset -f $func >> $temp
    fi

    if [ -z "$EDITOR" ]
    then
      typeset EDITOR=vi
    fi

    $EDITOR $temp
    source $temp

    transcribe $func $temp revise
    rm $temp
}

transcribe ()
{
    typeset func=$1
    typeset file=$2
    typeset operation="$3"

    if git --version >/dev/null 2>&1; then
        if [ -d ~/.composure ]; then
            (
                cd ~/.composure
                if git rev-parse 2>/dev/null; then
                    if [ ! -f $file ]; then
                        printf "%s\n" "Oops! Couldn't find $file to version it for you..."
                        return
                    fi
                    cp $file ~/.composure/$func.inc
                    git add --all .
                    git commit -m "$operation $func"
                fi
            )
        else
            if [ "$USE_COMPOSURE_REPO" = "0" ]; then
                return  # if you say so...
            fi
            printf "%s\n" "I see you don't have a ~/.composure repo..."
            typeset input
            typeset valid=0
            while [ $valid != 1 ]; do
                printf "\n%s" 'would you like to create one? y/n: '
                read input
                case $input in
                    y|yes|Y|Yes|YES)
                        (
                            echo 'creating git repository for your functions...'
                            mkdir ~/.composure
                            cd ~/.composure
                            git init
                            echo "composure stores your function definitions here" > README.txt
                            git add README.txt
                            git commit -m 'initial commit'
                        )
                        # if at first you don't succeed...
                        transcribe "$func" "$file" "$operation"
                        valid=1
                        ;;
                    n|no|N|No|NO)
                        printf "%s\n" "ok. add 'export USE_COMPOSURE_REPO=0' to your startup script to disable this message."
                        valid=1
                    ;;
                    *)
                        printf "%s\n" "sorry, didn't get that..."
                    ;;
                esac
            done
       fi
    fi
}

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
