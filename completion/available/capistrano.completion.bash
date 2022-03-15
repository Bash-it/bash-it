# shellcheck shell=bash
# Bash completion support for Capistrano.

export COMP_WORDBREAKS=${COMP_WORDBREAKS/\:/}

if _command_exists cap; then
	function __cap_completions() {
		[[ ! -f Capfile ]] && return 1

		local cword
		cword=$(_get_cword)

		case $cword in
			-*)
				# Complete options
				COMPREPLY=(--{suppress-,}backtrace --comments --job-stats --rules -A --all -B --build-all -C --directory -D --describe -e -E --execute{,-continue,-print} -f --rakefile
					-G --{no{-,},}system -g -I --libdir -j --jobs -m --multitask -N --no{-,}search -P --prereqs --require -R --rakelib{dir,} -t --trace -T --tasks -W --where -X --no-deprecation-warning
					-V --version -n --dry-run -r --roles -z --hosts -p --print-config-variables -h -H --help)
				;;

			*)
				# Complete tasks
				if cap --version | grep 'Capistrano v2.' > /dev/null; then
					# Capistrano 2.x
					read -ra COMPREPLY < <(cap --tool --verbose --tasks | awk '{print $2}' | tr '\n' ' ')
				else
					# Capistrano 3.x
					read -ra COMPREPLY < <(cap --all --tasks | awk '{print $2}' | tr '\n' ' ')
				fi
				;;

		esac
	}

	complete -F __cap_completions -X "!&*" cap
fi
