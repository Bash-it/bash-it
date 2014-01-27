cite 'about-alias'
about-alias 'docker abbrevations'

alias dklc='docker ps -l -q' # last container
alias dklc-ip="docker inspect `dklc` | grep IPAddress | cut -d '\"' -f 4"
alias dkps='docker ps'
alias dkpsa='docker ps -a'
alias dki='docker images'
alias dkrm='docker rm $(docker ps -a -q)'  # delete all stopped containers
alias dkrmi='docker rmi $(docker images | grep "^<none>" | awk "{print $3}")'

function dkideps() {
    OUT=$(mktemp -t docker-viz-XXXX.png)
    docker images -viz | dot -Tpng > $OUT
    case $OSTYPE in
        linux*)
            xdg-open $OUT
            ;;
        darwin*)
            open $OUT
            ;;
    esac
}

# docker run [container] env
function dkre() {
    docker run "$@" env
}
