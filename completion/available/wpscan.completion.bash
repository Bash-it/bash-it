# shellcheck shell=bash

if _command_exists wpscan; then
	function __wpscan_completion() {
		local prev
		prev=$(_get_pword)

		case $prev in
			-f | --format)
				COMPREPLY=(cli cli-no-colour cli-no-color json)
				;;
			--server)
				COMPREPLY=(apache iis nginx)
				;;
			*-detection)
				COMPREPLY=(mixed passive aggressive)
				;;
			-e | --enumerate)
				COMPREPLY=({a,v,}{p,t} tt cb dbe u m)
				;;
			--password-attack)
				COMPREPLY=(wp-login xmlrpc xmlrpc-multicall)
				;;
			*)
				COMPREPLY=(--url -h --help --hh --version --ignore-main-redirect -v --verbose --{no-,}banner --max-scan-duration -o --output --detection-mode
					--scope --user-agent --ua --headers --vhost --random-user-agent --rua --user-agents-list --http-auth -t --max-threads --throttle --{request,connect}-timeout
					--disable-tls --proxy{,-auth} --cookie-{string,jar} --cache-{ttl,dir} --clear-cache --server --{no-,}update --api-token --wp-{content,plugins}-dir
					--interesting-findings-detection --wp-version-{all,detection} --main-theme-detection -e --enumerate --exclude-content-based --plugins-{list,detection,version-{all,detection},threshold}
					--themes-{list,detection,version-{all,detection},threshold} --timthumbs-{detection,list} --config-backups-{detection,list} --db-exports-{detection,list}
					--medias-detection --users-{list,detection} --exclude-usernames -P --passwords -U --usernames --multicall-max-passwords --password-attack --login-uri --stealthy)
				;;

		esac
	}
	complete -F __wpscan_completion -X '!&*' wpscan
fi
