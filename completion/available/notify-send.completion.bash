if _binary_exists notify-send
then
    function __notify-send_completions ()
    {
        local curr=$(_get_cword)
        local prev=$(_get_pword)

        case $prev in
            -u|--urgency)
                COMPREPLY=($(compgen -W "low normal critical" -- "$curr"))
            ;;
            *)
                COMPREPLY=($(compgen -W "-? --help -u --urgency -t --expire-time -a --app-name -i --icon -c --category -h --hint -v --verison" -- "$curr"))
            ;;
        esac
    }


    complete -F __notify-send_completions notify-send
fi
