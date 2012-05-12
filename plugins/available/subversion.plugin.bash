cite about-plugin
about-plugin 'svn helper functions'

rm_svn(){
  about 'remove ".svn" files from directory'
  param '1: directory to search for files'
  group 'svn'

  if [ -z "$1" ]; then
      reference rm_svn
      return
  fi
  find $1 -name .svn -print0 | xargs -0 rm -rf
}

svn_add(){
    about 'add to svn repo'
    group 'svn'

    svn status | grep '^\?' | sed -e 's/? *//' | sed -e 's/ /\ /g' | xargs svn add
}
