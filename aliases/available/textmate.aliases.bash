# shellcheck shell=bash
about-alias 'textmate abbreviations'
url "https://macromates.com/"

case $OSTYPE in
	darwin*)
		# Textmate
		alias e='mate . &'
		alias et='mate app config db lib public script test spec config.ru Gemfile Rakefile README &'
		;;
esac
