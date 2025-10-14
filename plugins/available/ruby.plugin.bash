# shellcheck shell=bash
cite about-plugin
about-plugin 'ruby and rubygems specific functions and settings'
url "https://www.ruby-lang.org/"

# Make commands installed with 'gem install --user-install' available
# ~/.gem/ruby/${RUBY_VERSION}/bin/
if _command_exists ruby && _command_exists gem; then
	pathmunge "$(ruby -e 'print Gem.user_dir')/bin" after || true
else
	_log_warning "Unable to load Ruby plugin as a working 'ruby', or 'gem', was not found."
fi

function remove_gem() {
	about 'removes installed gem'
	param '1: installed gem name'
	group 'ruby'

	gem list | grep "${1:?${FUNCNAME[0]}: no gem name provided}" | awk '{ print $1; }' | xargs sudo gem uninstall
}
