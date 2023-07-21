cite about-plugin
about-plugin 'Maven jgitflow build helpers'

function hotfix-start() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'helper function for starting a new hotfix'
  group 'jgitflow'

  mvn jgitflow:hotfix-start ${JGITFLOW_MVN_ARGUMENTS}
  
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function hotfix-finish() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'helper function for finishing a hotfix'
  group 'jgitflow'

  mvn jgitflow:hotfix-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags
  
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function feature-start() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'helper function for starting a new feature'
  group 'jgitflow'

  mvn jgitflow:feature-start ${JGITFLOW_MVN_ARGUMENTS}
  
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function feature-finish() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'helper function for finishing a feature'
  group 'jgitflow'

  mvn jgitflow:feature-finish ${JGITFLOW_MVN_ARGUMENTS}
  echo -e '\033[32m----------------------------------------------------------------\033[0m'
  echo -e '\033[32m===== REMEMBER TO CREATE A NEW RELEASE TO DEPLOY THIS FEATURE ====\033[0m'
  echo -e '\033[32m----------------------------------------------------------------\033[0m'
  
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function release-start() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'helper function for starting a new release'
  group 'jgitflow'

  mvn jgitflow:release-start ${JGITFLOW_MVN_ARGUMENTS}
  
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function release-finish() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'helper function for finishing a release'
  group 'jgitflow'

  mvn jgitflow:release-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags
  
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

