# shellcheck shell=bash

__vuejs_completion() {
	# shellcheck disable=SC2155
	local prev=$(_get_pword)
	# shellcheck disable=SC2155
	local curr=$(_get_cword)

	case $prev in
		create)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-p -d -i -m -r -g -n -f -c -x -b -h --help --preset --default --inilinePreset --packageManager --registry --git --no-git --force --merge --clone --proxy --bare  --skipGetStarted" -- "$curr"))
			;;
		add | invoke)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "--registry -h --help" -- "$curr"))
			;;
		inspect)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-v --help --verbose --mode --rule --plugin --plugins --rules" -- "$curr"))
			;;
		serve)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-o -h --help --open -c --copy -p --port" -- "$curr"))
			;;
		build)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-t --target -n --name -d --dest -h --help" -- "$curr"))
			;;
		ui)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-H --host -p --port -D --dev --quiet --headless -h --help" -- "$curr"))
			;;
		init)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-c --clone --offline -h --help" -- "$curr"))
			;;
		config)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-g --get -s --set -d --delete -e --edit --json -h --help" -- "$curr"))
			;;
		outdated)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "--next -h --help" -- "$curr"))
			;;
		upgrade)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-t --to -f --from -r --registry --all --next -h --help" -- "$curr"))
			;;
		migrate)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-f --from -h --help" -- "$curr"))
			;;
		*)
			# shellcheck disable=SC2207
			COMPREPLY=($(compgen -W "-h --help -v --version create add invoke inspect serve build ui init config outdated upgrade migrate info" -- "$curr"))
			;;
	esac
}

complete -F __vuejs_completion vue
