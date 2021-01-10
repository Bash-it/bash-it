#!/usr/bin/bash

if _command_exists laravel; then
    __laravel_completion()  {
        local curr=$(_get_cword)
        COMPREPLY=($(compgen -W "list --raw --format -h --help -q --quiet -V --version --ansi --no-ansi -n --no-interaction -v -vv -vvv --verbose" -- "$curr"))
    }

    complete -F __laravel_completion laravel
fi
