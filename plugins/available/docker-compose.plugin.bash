cite about-plugin
about-plugin 'Helper functions for using docker-compose'

function docker-compose-fresh() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'Shut down, remove and start again the docker-compose setup, then tail the logs'
  group 'docker-compose'
  param '1: name of the docker-compose.yaml file to use (optional). Default: docker-compose.yaml'
  example 'docker-compose-fresh docker-compose-foo.yaml'

  local DCO_FILE_PARAM=""
  if [ -n "${1}" ] 
     then
    echo "Using docker-compose file: $1"
    DCO_FILE_PARAM="--file $1"
  fi

  docker-compose $DCO_FILE_PARAM stop
  docker-compose $DCO_FILE_PARAM rm -f
  docker-compose $DCO_FILE_PARAM up -d
  docker-compose $DCO_FILE_PARAM logs -f --tail 100
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

