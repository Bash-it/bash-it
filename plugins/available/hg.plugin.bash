cite about-plugin
about-plugin 'hg helper functions'

function hg_dirty() {
    about 'displays dirty status of hg repository'
    group 'hg'

    hg status --no-color 2> /dev/null \
    | awk '$1 == "?" { print "?" } $1 != "?" { print "!" }' \
    | sort | uniq | head -c1
}

function hg_in_repo() {
    about 'determine if pwd is an hg repo'
    group 'hg'

    [[ `hg branch 2> /dev/null` ]] && echo 'on '
}

function hg_branch() {
    about 'display current hg branch'
    group 'hg'

    hg branch 2> /dev/null
}
