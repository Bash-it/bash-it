#!/bin/bash

# ---------------------------------------------------------------------------+
#                                                                            |
# Thanks to Alexander Korznikov                                                                 |
# http://www.korznikov.com/2014/12/bash-tab-completion-for-awesome-tool.html |
#                                                                            |
# ---------------------------------------------------------------------------+

if command -v sqlmap > /dev/null; then

    _sqlmap()
    {
        local cur prev

        COMPREPLY=()
        cur=$(_get_cword)
        prev=$(_get_pword)

        case $prev in

    # List directory content
    --tamper)
        COMPREPLY=( $( compgen -W "$tamper" -- "$cur" ) )
        return 0
        ;;
    --output-dir|-t|-l|-m|-r|--load-cookies|--proxy-file|--sql-file|--shared-lib|--file-write)
        _filedir
        return 0
        ;;
    -c)
        _filedir ini
        return 0
        ;;
    --method)
        COMPREPLY=( $( compgen -W 'GET POST PUT' -- "$cur" ) )
        return 0
        ;;
    --auth-type)
        COMPREPLY=( $( compgen -W 'Basic Digest NTLM PKI' -- "$cur" ) )
        return 0
        ;;
    --tor-type)
        COMPREPLY=( $( compgen -W 'HTTP SOCKS4 SOCKS5' -- "$cur" ) )
        return 0
        ;;
    -v)
        COMPREPLY=( $( compgen -W '1 2 3 4 5 6' -- "$cur" ) )
        return 0
        ;;
    --dbms)
        COMPREPLY=( $( compgen -W 'mysql mssql access postgres' -- "$cur" ) )
        return 0
        ;;
    --level|--crawl)
        COMPREPLY=( $( compgen -W '1 2 3 4 5' -- "$cur" ) )
        return 0
        ;;
    --risk)
        COMPREPLY=( $( compgen -W '0 1 2 3' -- "$cur" ) )
        return 0
        ;;
    --technique)
        COMPREPLY=( $( compgen -W 'B E U S T Q' -- "$cur" ) )
        return 0
        ;;
    -s)
        _filedir sqlite
        return 0
        ;;
    --dump-format)
        COMPREPLY=( $( compgen -W 'CSV HTML SQLITE' -- "$cur" ) )
        return 0
        ;;
    -x)
        _filedir xml
        return 0
        ;;
        esac

        if [[ "$cur" == * ]]; then
        COMPREPLY=( $( compgen -W '-h --help -hh --version -v -d -u --url -l -x -m -r -g -c --method \
        --data --param-del --cookie --cookie-del --load-cookies \
        --drop-set-cookie --user-agent --random-agent --host --referer \
        --headers --auth-type --auth-cred --auth-private --ignore-401 \
        --proxy --proxy-cred --proxy-file --ignore-proxy --tor --tor-port \
        --tor-type --check-tor --delay --timeout --retries --randomize \
        --safe-url --safe-freq --skip-urlencode --csrf-token --csrf-url \
        --force-ssl --hpp --eval -o --predict-output --keep-alive \
        --null-connection --threads -p  --skip --dbms --dbms-cred \
        --os --invalid-bignum --invalid-logical --invalid-string \
        --no-cast --no-escape --prefix --suffix --tamper --level \
        --risk --string --not-string --regexp --code --text-only \
        --titles --technique --time-sec --union-cols --union-char \
        --union-from --dns-domain --second-order -f --fingerprint \
        -a --all -b --banner --current-user --current-db --hostname \
        --is-dba --users --passwords --privileges --roles --dbs --tables \
        --columns --schema --count --dump --dump-all --search --comments \
        -D -T -C -X -U --exclude-sysdbs --where --start --stop \
        --first --last --sql-query --sql-shell --sql-file --common-tables \
        --common-columns --udf-inject --shared-lib --file-read --file-write \
        --file-dest --os-cmd --os-shell --os-pwn --os-smbrelay --os-bof \
        --priv-esc --msf-path --tmp-path --reg-read --reg-add --reg-del \
        --reg-key --reg-value --reg-data --reg-type -s -t --batch \
        --charset --crawl --csv-del --dump-format --eta --flush-session \
        --forms --fresh-queries --hex --output-dir --parse-errors \
        --pivot-column --save --scope --test-filter --update \
        -z --alert --answers --beep --check-waf --cleanup \
        --dependencies --disable-coloring --gpage --identify-waf \
        --mobile --page-rank --purge-output --smart \
        --sqlmap-shell --wizard' -- "$cur" ) )
        # this removes any options from the list of completions that have
        # already been specified somewhere on the command line, as long as
        # these options can only be used once (in a word, "options", in
        # opposition to "tests" and "actions", as in the find(1) manpage).
        onlyonce=' -h --help -hh --version -v -d -u --url -l -x -m -r -g -c \
        --drop-set-cookie --random-agent \
        --ignore-401 \
        --ignore-proxy --tor \
        --check-tor \
        --skip-urlencode \
        --force-ssl --hpp -o --predict-output --keep-alive \
        --null-connection -p \
        --invalid-bignum --invalid-logical --invalid-string \
        --no-cast --no-escape \
        --text-only \
        --titles \
        -f --fingerprint \
        -a --all -b --banner --current-user --current-db --hostname \
        --is-dba --users --passwords --privileges --roles --dbs --tables \
        --columns --schema --count --dump --dump-all --search --comments \
        -D -T -C -X -U --exclude-sysdbs \
        --sql-shell --common-tables \
        --common-columns --udf-inject \
        --os-shell --os-pwn --os-smbrelay --os-bof \
        --priv-esc --reg-read --reg-add --reg-del \
        -s -t --batch \
        --eta --flush-session \
        --forms --fresh-queries --hex --parse-errors \
        --save --update \
        -z --beep --check-waf --cleanup \
        --dependencies --disable-coloring --identify-waf \
        --mobile --page-rank --purge-output --smart \
        --sqlmap-shell --wizard '
        COMPREPLY=( $( \
            (while read -d ' ' i; do
                [[ -z "$i" || "${onlyonce/ ${i%% *} / }" == "$onlyonce" ]] &&
                continue
                # flatten array with spaces on either side,
                # otherwise we cannot grep on word boundaries of
                # first and last word
                COMPREPLY=" ${COMPREPLY[@]} "
                # remove word from list of completions
                COMPREPLY=( ${COMPREPLY/ ${i%% *} / } )
                done
                printf '%s ' "${COMPREPLY[@]}") <<<"${COMP_WORDS[@]}"
            ) )

    #    else
    #        _filedir bat
        fi
    }


    complete -F _sqlmap sqlmap

fi
