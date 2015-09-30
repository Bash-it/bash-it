cite about-plugin
about-plugin 'add "export PROJECT_PATHS=~/projects:~/intertrode/projects" to navigate quickly to your project directories with `pj` and `pjo`'

function pj {
    about 'navigate quickly to your various project directories'
    group 'projects'

    if [ -n "$PROJECT_PATHS" ]; then
        local cmd

        if [ "$1" == "open" ]; then
            shift
            cmd="$EDITOR"
        fi

        cmd="${cmd:-cd}"

        if [ -n "$1" ]; then
            for i in ${PROJECT_PATHS//:/$'\n'}; do
                if [ -d "$i"/"$1" ]; then
                    $cmd "$i"/"$1"
                    return
                fi
            done
        fi
    fi

    echo "No such project '$1'"
}

alias pjo="pj open"
