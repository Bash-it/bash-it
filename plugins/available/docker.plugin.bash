cite about-plugin
about-plugin 'Helpers to more easily work with Docker'

function docker-remove-most-recent-container() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'attempt to remove the most recent container from docker ps -a'
  group 'docker'
  docker ps -ql | xargs docker rm
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-remove-most-recent-image() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'attempt to remove the most recent image from docker images'
  group 'docker'
  docker images -q | head -1 | xargs docker rmi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-remove-stale-assets() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'attempt to remove exited containers and dangling images'
  group 'docker'
  docker ps --filter status=exited -q | xargs docker rm --volumes
  docker images --filter dangling=true -q | xargs docker rmi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-enter() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'enter the specified docker container using bash'
  group 'docker'
  param '1: Name of the container to enter'
  example 'docker-enter oracle-xe'

  docker exec -it "${@}" /bin/bash;
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-remove-images() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'attempt to remove images with supplied tags or all if no tags are supplied'
  group 'docker'
  if [ -z "${1}" ] 
     then
    docker rmi $(docker images -q)
  else
    DOCKER_IMAGES=""
    for IMAGE_ID in $@; do DOCKER_IMAGES="$DOCKER_IMAGES\|$IMAGE_ID"; done
    # Find the image IDs for the supplied tags
    ID_ARRAY=($(docker images | grep "${DOCKER_IMAGES:2}" | awk {'print $3'}))
    # Strip out duplicate IDs before attempting to remove the image(s)
    docker rmi $(echo ${ID_ARRAY[@]} | tr ' ' '\n' | sort -u | tr '\n' ' ')
 fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-image-dependencies() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'attempt to create a Graphiz image of the supplied image ID dependencies'
  group 'docker'
  if hash dot 2>/dev/null 
     then
    OUT=$(mktemp -t docker-viz-XXXX.png)
    docker images -viz | dot -Tpng > $OUT
    case $OSTYPE in
      linux*)
        xdg-open $OUT
        ;;
      darwin*)
        open $OUT
        ;;
    esac
  else
    >&2 echo "Can't show dependencies; Graphiz is not installed"
  fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-runtime-environment() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'attempt to list the environmental variables of the supplied image ID'
  group 'docker'
  docker run "${@}" env
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function docker-archive-content() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'show the content of the provided Docker image archive'
  group 'docker'
  param '1: image archive name'
  example 'docker-archive-content images.tar.gz'

  if [ -n "${1}" ] 
     then
    tar -xzOf $1 manifest.json | jq '[.[] | .RepoTags] | add'
  fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

