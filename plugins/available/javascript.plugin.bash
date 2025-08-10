# shellcheck shell=bash
# The install directory is hard-coded. TODO: allow the directory to be specified on the command line.

cite about-plugin
about-plugin 'download jquery files into current project'

[[ -z "$JQUERY_VERSION_NUMBER" ]] && JQUERY_VERSION_NUMBER="1.6.1"
[[ -z "$JQUERY_UI_VERSION_NUMBER" ]] && JQUERY_UI_VERSION_NUMBER="1.8.13"

function rails_jquery {
	about 'download rails.js into public/javascripts'
	group 'javascript'

	curl -o public/javascripts/rails.js http://github.com/rails/jquery-ujs/raw/master/src/rails.js
}

function jquery_install {
	about 'download jquery.js into public/javascripts'
	group 'javascript'

	if [ -z "$1" ]; then
		version=$JQUERY_VERSION_NUMBER
	else
		version="$1"
	fi
	curl -o public/javascripts/jquery.js "http://ajax.googleapis.com/ajax/libs/jquery/$version/jquery.min.js"
}

function jquery_ui_install {
	about 'download jquery_us.js into public/javascripts'
	group 'javascript'

	if [ -z "$1" ]; then
		version=$JQUERY_UI_VERSION_NUMBER
	else
		version="$1"
	fi

	curl -o public/javascripts/jquery_ui.js "http://ajax.googleapis.com/ajax/libs/jqueryui/$version/jquery-ui.min.js"
}
