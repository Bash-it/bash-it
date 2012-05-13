cite about-plugin
about-plugin 'adds "remove_gem" function'

function remove_gem {
  about 'removes installed gem'
  param '1: installed gem name'
  group 'ruby'

  gem list | grep $1 | awk '{ print $1; }' | xargs sudo gem uninstall
}
