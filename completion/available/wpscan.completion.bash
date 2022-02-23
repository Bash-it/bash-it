# shellcheck shell=bash

# Make sure wpscan is installed
_bash-it-completion-helper-necessary wpscan || :

# Don't handle completion if it's already managed
_bash-it-completion-helper-sufficient wpscan || return

function __wpscan() {
	local _opt_
	local OPTS=('--help' '--hh' '--version' '--url' '--ignore-main-redirect' '--verbose' '--output' '--format' '--detection-mode' '--scope' '--headers' '--user-agent' '--vhost' '--random-user-agent' '--user-agents-list' '--http-auth' '--max-threads' '--throttle' '--request-timeout' '--connect-timeout' '--disable-tlc-checks' '--proxy' '--proxy-auth' '--cookie-string' '--cookie-jar' '--cache-ttl' '--clear-cache' '--server' '--cache-dir' '--update' '--no-update' '--wp-content-dir' '--wp-plugins-dir' '--wp-version-detection' '--main-theme-detection' '--enumerate' '--exclude-content-based' '--plugins-list' '--plugins-detection' '--plugins-version-all' '--plugins-version-detection' '--themes-list' '--themes-detection' '--themes-version-all' '--themes-version-detection' '--timthumbs-list' '--timthumbs-detection' '--config-backups-list' '--config-backups-detection' '--db-exports-list' '--db-exports-detection' '--medias-detection' '--users-list' '--users-detection' '--passwords' '--usernames' '--multicall-max-passwords' '--password-attack' '--stealthy')
	COMPREPLY=()
	for _opt_ in "${OPTS[@]}"; do
		if [[ "$_opt_" == "$2"* ]]; then
			COMPREPLY+=("$_opt_")
		fi
	done
}

complete -F __wpscan wpscan
