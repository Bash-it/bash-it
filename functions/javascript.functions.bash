#!/bin/bash
#
# The install directory is hard-coded. TOOD: allow the directory to be specified on the command line.
#


function rails_jquery {
  curl -o public/javascripts/rails.js http://github.com/rails/jquery-ujs/raw/master/src/rails.js
}

function jquery_install {
  curl -o public/javascripts/jquery.js http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js
}

function  jquery_ui_install {
  curl -o public/javascripts/jquery_ui.js http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.5/jquery-ui.min.js
}