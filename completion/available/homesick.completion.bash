# Bash completion script for homesick
#
# The homebrew bash completion script was used as inspiration.
# Originally from https://github.com/liborw/homesick-completion

_homesick_complete()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local options="--skip --force --pretend --quiet"
    local actions="cd clone commit destroy diff generate help list open pull push rc show_path status symlink track unlink version"
    local repos=$(\ls ~/.homesick/repos)

    # Subcommand list
    [[ ${COMP_CWORD} -eq 1 ]] && {
        COMPREPLY=( $(compgen -W "${options} ${actions}" -- ${cur}) )
        return
    }

    # Find the first non-switch word
    local prev_index=1
    local prev="${COMP_WORDS[prev_index]}"
    while [[ $prev == -* ]]; do
        prev_index=$((++prev_index))
        prev="${COMP_WORDS[prev_index]}"
    done

    # Find the number of non-"--" commands
    local num=0
    for word in ${COMP_WORDS[@]}
    do
        if [[ $word != -* ]]; then
            num=$((++num))
        fi
    done

    case "$prev" in
    # Commands that take a castle
    cd|commit|destroy|diff|open|pull|push|rc|show_path|status|symlink|unlink)
        COMPREPLY=( $(compgen -W "${repos}" -- ${cur}) )
        return
        ;;
    # Commands that take command
    help)
        COMPREPLY=( $(compgen -W "${actions}" -- ${cur}) )
        return
        ;;
    # Track command take file and repo
    track)
        if [[ "$num" -eq 2 ]]; then
            COMPREPLY=( $(compgen -X -f ${cur}) )
        elif [[ "$num" -ge 3 ]]; then
            COMPREPLY=( $(compgen -W "${repos}" -- ${cur}) )
        fi
        return
        ;;
    esac
}

complete -o bashdefault -o default -F _homesick_complete homesick

