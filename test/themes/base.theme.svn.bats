#!/usr/bin/env bats

load ../test_helper
load ../../lib/composure
load ../../lib/log

cite _about _param _example _group _author _version

load ../../lib/helpers
load ../../themes/base.theme

function local_setup {
  setup_test_fixture

  # Copy the test fixture to the Bash-it folder
  if command -v rsync &> /dev/null
  then
    rsync -a "$BASH_IT/test/fixtures/bash_it/" "$BASH_IT/"
  else
    find "$BASH_IT/test/fixtures/bash_it" \
      -mindepth 1 -maxdepth 1 \
      -exec cp -r {} "$BASH_IT/" \;
  fi

  export OLD_PATH="$PATH"
}

function local_teardown {
  export PATH="$OLD_PATH"
  unset OLD_PATH
}

function setup_repo {
  upstream="$(mktemp -d)"
  pushd "$upstream" > /dev/null
  # Create a dummy SVN folder - this will not work with an actual `svn` command,
  # but will be enough to trigger the SVN check in the base theme.
  mkdir .svn

  echo "$upstream"
}

function setup_svn_path {
  local svn_path="$1"

  # Make sure that the requested SVN script is available
  assert_file_exist "$svn_path/svn"

  # Make sure that the requested SVN script is on the path
  export PATH="$svn_path:/usr/bin:/bin:/usr/sbin"
}

@test 'themes base: SVN: detect SVN repo' {
  repo="$(setup_repo)"
  pushd "$repo"

  setup_svn_path "$BASH_IT/test/fixtures/svn/working"

  # Load the base theme again so that the working SVN script is detected
  load ../../themes/base.theme

  scm
  # Make sure that the SVN command is used
  assert_equal "$SCM" "$SCM_SVN"
}

@test 'themes base: SVN: detect SVN repo even from a subfolder' {
  repo="$(setup_repo)"
  pushd "$repo"

  mkdir foo
  pushd foo

  setup_svn_path "$BASH_IT/test/fixtures/svn/working"

  # Load the base theme again so that the working SVN script is detected
  load ../../themes/base.theme

  scm
  # Make sure that the SVN command is used
  assert_equal "$SCM" "$SCM_SVN"
}

@test 'themes base: SVN: no SCM if no .svn folder can be found' {
  repo="$(setup_repo)"
  pushd "$repo"

  rm -rf .svn

  setup_svn_path "$BASH_IT/test/fixtures/svn/working"

  # Load the base theme again so that the working SVN script is detected
  load ../../themes/base.theme

  scm
  # Make sure that no SVN command is used
  assert_equal "$SCM" "$SCM_NONE"
}

@test 'themes base: SVN: ignore SVN repo when using broken SVN command' {
  repo="$(setup_repo)"
  pushd "$repo"

  setup_svn_path "$BASH_IT/test/fixtures/svn/broken"

  # Load the base theme again so that the broken SVN script is detected
  load ../../themes/base.theme

  scm
  # Make sure that no SVN command is not used
  assert_equal "$SCM" "$SCM_NONE"
}

@test 'themes base: SVN: ignore SVN repo even from a subfolder when using a broken SVN' {
  repo="$(setup_repo)"
  pushd "$repo"

  mkdir foo
  pushd foo

  setup_svn_path "$BASH_IT/test/fixtures/svn/broken"

  # Load the base theme again so that the broken SVN script is detected
  load ../../themes/base.theme

  scm
  # Make sure that no SVN command is used
  assert_equal "$SCM" "$SCM_NONE"
}
