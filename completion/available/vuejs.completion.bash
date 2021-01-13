#!/usr/bin/bash

if _command_exists vue; then
    __vuejs_completion()  {
        local prev=$(_get_pword)
        local curr=$(_get_cword)

        case $prev in
            create)
                COMPREPLY=($(compgen -W "-p -d -i -m -r -g -n -f -c -x -b -h --help --preset --default --inilinePreset --packageManager --registry --git --no-git --force --merge --clone --proxy --bare  --skipGetStarted" -- "$curr"))
            ;;
            add|invoke)
                COMPREPLY=($(compgen -W "--registry -h --help" -- "$curr"))
            ;;
            inspect)
                COMPREPLY=($(compgen -W "-v --help --verbose --mode --rule --plugin --plugins --rules" -- "$curr"))
            ;;
            serve)
                COMPREPLY=($(compgen -W "-o -h --help --open -c --copy -p --port" -- "$curr"))
            ;;
            build)
                COMPREPLY=($(compgen -W "-t --target -n --name -d --dest -h --help" -- "$curr"))
            ;;
            ui)
                COMPREPLY=($(compgen -W "-H --host -p --port -D --dev --quiet --headless -h --help" -- "$curr"))
            ;;
            init)
                COMPREPLY=($(compgen -W "-c --clone --offline -h --help" -- "$curr"))
            ;;
            config)
                COMPREPLY=($(compgen -W "-g --get -s --set -d --delete -e --edit --json -h --help" -- "$curr"))
            ;;
            outdated)
                COMPREPLY=($(compgen -W "--next -h --help" -- "$curr"))
            ;;
            upgrade)
                COMPREPLY=($(compgen -W "-t --to -f --from -r --registry --all --next -h --help" -- "$curr"))
            ;;
            migrate)
                COMPREPLY=($(compgen -W "-f --from -h --help" -- "$curr"))
            ;;
            *)
                COMPREPLY=($(compgen -W "-h --help -v --version create add invoke inspect serve build ui init config outdated upgrade migrate info" -- "$curr"))
            ;;
        esac
    }

    complete -F __vuejs_completion vue
fi
