cite about-plugin
about-plugin 'ruby and rubygems specific functions and settings'

# Load after rbenv
# BASH_IT_LOAD_PRIORITY: 285

# Check ruby version to ensure rbenv can find ruby
{ _command_exists ruby && ruby --version &>/dev/null ; } || return 0

# Check gem version to ensure rbenv can find gem
{ _command_exists gem && gem --version &>/dev/null ; } || return 0

function remove_gem {
  about 'removes installed gem'
  param '1: installed gem name'
  group 'ruby'

  { _command_exists gem && gem --version &>/dev/null ; } || return 1
  gem list | grep $1 | awk '{ print $1; }' | xargs gem uninstall
}

# Make commands installed with 'gem install --user-install' are available
pathmunge "$(ruby -e 'print Gem.user_dir')/bin"
