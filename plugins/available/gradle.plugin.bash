cite about-plugin
about-plugin 'Add a gw command to use gradle wrapper if present, else use system gradle'

function gw() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  local file="gradlew"
  local result

  result="$(_bash-it-find-in-ancestor "${file}")"

  # Call gradle
  "${result:-gradle}" $*
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

