# shellcheck shell=bash
about-alias 'Some aliases for Homebrew'

if _command_exists brew; then
	alias bup='brew update && brew upgrade'
	alias bout='brew outdated'
	alias bin='brew install'
	alias brm='brew uninstall'
	alias bcl='brew cleanup'
	alias bls='brew list'
	alias bsr='brew search'
	alias binf='brew info'
	alias bdr='brew doctor'
	alias bed='brew edit'
fi
