#!/bin/bash
hg_dirty() {
    hg status --no-color 2> /dev/null \
    | awk '$1 == "?" { print "?" } $1 != "?" { print "!" }' \
    | sort | uniq | head -c1
}

hg_in_repo() {
    [[ `hg branch 2> /dev/null` ]] && echo 'on '
}

hg_branch() {
    hg branch 2> /dev/null
}