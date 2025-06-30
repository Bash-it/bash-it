# shellcheck shell=bash
cite 'about-alias'
about-alias 'git aliases from oh-my-zsh (incompatible with regular git aliases option)'

if _bash-it-component-item-is-enabled aliases git; then
	_log_warning "git-omz aliases are incompatible with regular git aliases"
	return 1
fi

# Load after regular git aliases
# BASH_IT_LOAD_PRIORITY: 160

# Setup git version
read -ra git_version_arr <<< "$(git version 2> /dev/null)"
# shellcheck disable=SC2034
git_version="${git_version_arr[2]}"

# Setup is-at-least
function is-at-least {
	local expected_version=$1
	local actual_version=$2
	local versions

	printf -v versions '%s\n%s' "$expected_version" "$actual_version"
	[[ $versions = "$(sort -V <<< "$versions")" ]]
}

# Setup git_current_branch
function git_current_branch {
	_git-branch
}

# shellcheck disable=SC1090
source "${BASH_IT}"/vendor/github.com/ohmyzsh/ohmyzsh/plugins/git/git.plugin.zsh
