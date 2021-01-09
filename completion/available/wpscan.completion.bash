#!/usr/bin/bash

if _command_exists wpscan; then

    __wpscan_completion()   {

        local cur prev
        COMREPLY=()
        cur=$(_get_cword)
        prev=$(_get_pword)

        local D=(--url --help --hh --version --ignore-main-redirect --banner --no-banner --max-scan-duration --format --output --detection-mode --user-agent --ua --http-auth --max-threads --throttle --request-timeout --connect-timeout --disable-tls-checks --proxy --proxy-auth --cookie-string --cookie-jar --force --update --no-update --api-token --wp-content-dir --wp-plugins-dir --enumerate --exclude-content-based --plugins-list --plugins-detection --plugins-version-all --plugins-version-detection --plugins-threshold --themes-list --themes-detection --themes-version-all --themes-version-detection --themes-threshold --timthumbs-list --timthumbs-detection --config-backups-list --config-backups-detection --db-exports-list --db-exports-detection --medias-detection --users-list --users-detection --passwords --usernames --multicall-max-passwords --password-attack --login-uri --stealthy --random-user-agent)
        local S=(-h -v -f -o -t -e -U -P)
        echo "${D[@]} ${S[@]}"
        local OPTS=($(compgen -W "${S[@]} ${D[@]}"))

        case $prev in
            # --format | -f)
            #     COMPREPLY=("$(compgen -W "cli cli-no-color json" "$cur")")
            #     return 0
            # ;;

            # --detection-mode | *detection)
            #     COMPREPLY=("$(compgen -W "mixed active passive" "$cur")")
            #     return 0
            # ;;

            # --enumerate | -e)
            #     case $prev in
            #         vp | ap | p)
            #             COMPREPLY=("$(compgen -W "vt at t tt cb dbe u m" "$cur")")
            #             return 0
            #         ;;
            #         vt | at | t)
            #             COMPREPLY=("$(compgen -W "vp ap p tt cb dbe u m" "$cur")")
            #             return 0
            #         ;;
            #         *)
            #             COMPREPLY=("$(compgen -W "vp ap p vt at t tt cb dbe u m" "$cur")")
            #             return 0
            #         ;;
            #     esac
            # ;;

            # --password-attack)
            #     COMPREPLY=("$(compgen -W "wp-login xmlrpc xmlrpc-multicall" "$cur")")
            # ;;

            ## HANDLE ALL OTHER
            *)
                # COMPREPLY=("$(compgen -W "$OPTS" "$cur")")
                for OPT in "${OPTS[@]}"; do
                    if [[ "$OPT" == "$2"* ]]; then
                        COMPREPLY+=("$OPT")
                    fi
                done

            ;;
        esac
    }

    complete -F __wpscan_completion wpscan
fi
