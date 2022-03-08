# shellcheck shell=bash

if _command_exists vue; then
	__vuejs_completion() {
		local cmd=${COMP_WORDS[1]}

		case $cmd in
			create)
				COMPREPLY=(-p -d -i -m -r -g -n -f -c -x -b -h --help --preset --default --inilinePreset --packageManager --registry --git --no-git --force --merge --clone --proxy --bare --skipGetStarted)
				;;
			add | invoke)
				COMPREPLY=(--registry -h --help)
				;;
			inspect)
				COMPREPLY=(-v -h --help --verbose --mode --rule --plugin --plugins --rules)
				;;
			serve)
				COMPREPLY=(-o -h --help --open -c --copy -p --port)
				;;
			build)
				COMPREPLY=(-t --target -n --name -d --dest -h --help)
				;;
			ui)
				COMPREPLY=(-H --host -p --port -D --dev --quiet --headless -h --help)
				;;
			init)
				COMPREPLY=(-c --clone --offline -h --help)
				;;
			config)
				COMPREPLY=(-g --get -s --set -d --delete -e --edit --json -h --help)
				;;
			outdated)
				COMPREPLY=(--next -h --help)
				;;
			upgrade)
				COMPREPLY=(-t --to -f --from -r --registry --all --next -h --help)
				;;
			migrate)
				COMPREPLY=(-f --from -h --help)
				;;
			*)
				COMPREPLY=(-h --help -V --version create add invoke inspect serve build ui init config outdated upgrade migrate info)
				;;
		esac
	}

	complete -F __vuejs_completion -X '!&*' vue
fi
