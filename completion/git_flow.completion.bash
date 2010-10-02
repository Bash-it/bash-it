#!bash
#
# git-flow-completion
# ===================
# 
# Bash completion support for [git-flow](http://github.com/nvie/gitflow)
# 
# The contained completion routines provide support for completing:
# 
#  * git-flow init and version
#  * feature, hotfix and release branches
#  * remote feature branch names (for `git-flow feature track`)
# 
# 
# Installation
# ------------
# 
# To achieve git-flow completion nirvana:
# 
#  0. Install git-completion.
# 
#  1. Install this file. Either:
# 
#     a. Place it in a `bash-completion.d` folder:
# 
#        * /etc/bash-completion.d
#        * /usr/local/etc/bash-completion.d
#        * ~/bash-completion.d
# 
#     b. Or, copy it somewhere (e.g. ~/.git-flow-completion.sh) and put the following line in
#        your .bashrc:
# 
#            source ~/.git-flow-completion.sh
# 
#  2. If you are using Git < 1.7.1: Edit git-completion.sh and add the following line to the giant
#     $command case in _git:
# 
#         flow)        _git_flow ;;
# 
# 
# The Fine Print
# --------------
# 
# Copyright (c) 2010 [Justin Hileman](http://justinhileman.com)
# 
# Distributed under the [MIT License](http://creativecommons.org/licenses/MIT/)

_git_flow ()
{
	local subcommands="init feature release hotfix"
	local subcommand="$(__git_find_subcommand "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	feature)
		__git_flow_feature
		return
		;;
	release)
		__git_flow_release
		return
		;;
	hotfix)
		__git_flow_hotfix
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__git_flow_feature ()
{
	local subcommands="list start finish publish track diff rebase checkout pull"
	local subcommand="$(__git_find_subcommand "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	pull)
		__gitcomp "$(__git_remotes)"
		return
		;;
	checkout|finish|diff|rebase)
		__gitcomp "$(__git_flow_list_features)"
		return
		;;
	publish)
		__gitcomp "$(comm -23 <(__git_flow_list_features) <(__git_flow_list_remote_features))"
		return
		;;
	track)
		__gitcomp "$(__git_flow_list_remote_features)"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__git_flow_list_features ()
{
	git flow feature list 2> /dev/null | tr -d ' |*'
}

__git_flow_list_remote_features ()
{
	git branch -r 2> /dev/null | grep "origin/$(__git_flow_feature_prefix)" | awk '{ sub(/^origin\/$(__git_flow_feature_prefix)/, "", $1); print }'
}

__git_flow_feature_prefix ()
{
	git config gitflow.prefix.feature 2> /dev/null || echo "feature/"
}

__git_flow_release ()
{
	local subcommands="list start finish"
	local subcommand="$(__git_find_subcommand "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi
	
	case "$subcommand" in
	finish)
		__gitcomp "$(__git_flow_list_releases)"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac

}

__git_flow_list_releases ()
{
	git flow release list 2> /dev/null
}

__git_flow_hotfix ()
{
	local subcommands="list start finish"
	local subcommand="$(__git_find_subcommand "$subcommands")"
	if [ -z "$subcommand" ]; then
		__gitcomp "$subcommands"
		return
	fi

	case "$subcommand" in
	finish)
		__gitcomp "$(__git_flow_list_hotfixes)"
		return
		;;
	*)
		COMPREPLY=()
		;;
	esac
}

__git_flow_list_hotfixes ()
{
	git flow hotfix list 2> /dev/null
}

# temporarily wrap __git_find_on_cmdline() for backwards compatibility
if [ -z "`type -t __git_find_subcommand`" ]; then
	alias __git_find_subcommand=__git_find_on_cmdline
fi