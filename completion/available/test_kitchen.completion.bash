# shellcheck shell=bash
# shellcheck disable=SC2120,SC2207
__kitchen_instance_list() {
	# cache to .kitchen.list.yml
	if [[ .kitchen.yml -nt .kitchen.list.yml || .kitchen.local.yml -nt .kitchen.list.yml ]]; then
		# update list if config has updated
		kitchen list --bare > .kitchen.list.yml
	fi
	cat .kitchen.list.yml
}

__kitchen_options() {
	cur="${COMP_WORDS[COMP_CWORD]}"
	prev="${COMP_WORDS[COMP_CWORD - 1]}"
	COMPREPLY=()

	case $prev in
		converge | create | destroy | diagnose | list | login | setup | test | verify)
			COMPREPLY=($(compgen -W "$(__kitchen_instance_list)" -- "${cur}"))
			return 0
			;;
		driver)
			COMPREPLY=($(compgen -W "create discover help" -- "${cur}"))
			return 0
			;;
		*)
			COMPREPLY=($(compgen -W "console converge create destroy driver help init list login setup test verify version" -- "${cur}"))
			return 0
			;;
	esac
}
complete -F __kitchen_options kitchen
