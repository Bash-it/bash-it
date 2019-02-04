# requested by greenrd on a issue https://github.com/Bash-it/bash-it/issues/674

function yes() {
    if [ "$1" = "-ok" ]; then
        shift
        $(which yes) $*
    else
        echo "bash-it: this command will spam your terminal (use arg -ok to skip warning)"
        exit 1
    fi
}
function ls() {
    if [[ -f ${*: -1:1} ]]; then
        echo "bash-it: ${*: -1:1} is a file not a folder"
        exit 1
    else
        $(which ls) $*
    fi
}
function cat() {
    if [[ -d ${*: -1:1} ]]; then
        echo "bash-it: ${*: -1:1} is a folder not a file"
        exit 1
    else
        $(which cat) $*
    fi
}
function rm() {
    if [[ -d ${*: -1:1} ]]; then
        $(which rm) -r $*
    else
        $(which rm) $*
    fi
}
