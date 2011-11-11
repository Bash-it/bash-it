#!/bin/bash
#
# The install directory is hard-coded. TOOD: allow the directory to be specified on the command line.
#

[[ -z "$JQUERY_VERSION_NUMBER" ]] && JQUERY_VERSION_NUMBER="1.6.1"
[[ -z "$JQUERY_UI_VERSION_NUMBER" ]] && JQUERY_UI_VERSION_NUMBER="1.8.13"

function rails_jquery {
  curl -o public/javascripts/rails.js http://github.com/rails/jquery-ujs/raw/master/src/rails.js
}

function jquery_install {
  if [ -z "$1" ]
  then
      version=$JQUERY_VERSION_NUMBER
  else
      version="$1"
  fi
  curl -o public/javascripts/jquery.js "http://ajax.googleapis.com/ajax/libs/jquery/$version/jquery.min.js"
}

function jquery_ui_install {
  if [ -z "$1" ]
  then
      version=$JQUERY_UI_VERSION_NUMBER
  else
      version="$1"
  fi

  curl -o public/javascripts/jquery_ui.js "http://ajax.googleapis.com/ajax/libs/jqueryui/$version/jquery-ui.min.js"
}
