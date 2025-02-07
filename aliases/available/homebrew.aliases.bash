# shellcheck shell=bash
about-alias 'Some aliases for Homebrew'

if _command_exists brew; then
	alias bed='brew edit'
	alias bls='brew list'
	alias bsr='brew search'
	alias bdr='brew doctor'
	alias bin='brew install'
	alias bcl='brew cleanup'
	alias brm='brew uninstall'
	alias bout='brew outdated'
	alias binf='brew info'
	alias bup='brew update && brew upgrade'
fi
