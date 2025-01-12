# shellcheck shell=bash
about-plugin 'ruby and rubygems specific functions and settings'

# Make commands installed with 'gem install --user-install' available
# ~/.gem/ruby/${RUBY_VERSION}/bin/
if ! _binary_exists ruby || ! _binary_exists gem; then
	_log_warning "Unable to locate 'gem'."
	return 1
fi

pathmunge "$(ruby -e 'print Gem.user_dir')/bin" after

function remove_gem() {
	about 'removes installed gem'
	param '1: installed gem name'
	group 'ruby'

	gem list | grep "${1:?${FUNCNAME[0]}: no gem name provided}" | awk '{ print $1; }' | xargs sudo gem uninstall
}
