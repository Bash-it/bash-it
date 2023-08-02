# The install directory is hard-coded. TODO: allow the directory to be specified on the command line.

cite about-plugin
about-plugin 'download jquery files into current project'

[[ -z "$JQUERY_VERSION_NUMBER" ]] && JQUERY_VERSION_NUMBER="1.6.1"
[[ -z "$JQUERY_UI_VERSION_NUMBER" ]] && JQUERY_UI_VERSION_NUMBER="1.8.13"

function rails_jquery()
 {
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'download rails.js into public/javascripts'
  group 'javascript'

  curl -o public/javascripts/rails.js http://github.com/rails/jquery-ujs/raw/master/src/rails.js
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function jquery_install()
 {
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'download jquery.js into public/javascripts'
  group 'javascript'

  if [ -z "${1}" ]
  then
      version=$JQUERY_VERSION_NUMBER
  else
      version="${1}"
  fi
  curl -o public/javascripts/jquery.js "http://ajax.googleapis.com/ajax/libs/jquery/$version/jquery.min.js"
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function jquery_ui_install() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'download jquery_us.js into public/javascripts'
  group 'javascript'

  if [ -z "${1}" ]
  then
      version=$JQUERY_UI_VERSION_NUMBER
  else
      version="${1}"
  fi

  curl -o public/javascripts/jquery_ui.js "http://ajax.googleapis.com/ajax/libs/jqueryui/$version/jquery-ui.min.js"
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}
