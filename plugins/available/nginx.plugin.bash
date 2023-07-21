# shellcheck shell=bash
about-plugin 'manage your nginx service'

pathmunge "${NGINX_PATH:=/opt/nginx}/sbin" after
export NGINX_PATH

function nginx_reload() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	about 'reload your nginx config'
	group 'nginx'

	local FILE="${NGINX_PATH?}/logs/nginx.pid"
	if [[ -s $FILE ]] 
     then
		echo "Reloading NGINX..."
		read -r PID < "${FILE}"
		sudo kill -HUP "${PID?}"
	else
		echo "Nginx pid file not found"
		return 0
	fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function nginx_stop() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	about 'stop nginx'
	group 'nginx'

	local FILE="${NGINX_PATH?}/logs/nginx.pid"
	if [[ -s $FILE ]] 
     then
		echo "Stopping NGINX..."
		read -r PID < "${FILE}"
		sudo kill -INT "${PID?}"
	else
		echo "Nginx pid file not found"
		return 0
	fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function nginx_start() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	about 'start nginx'
	group 'nginx'

	local FILE="${NGINX_PATH?}/sbin/nginx"
	if [[ -x $FILE ]] 
     then
		echo "Starting NGINX..."
		sudo "${FILE}"
	else
		echo "Couldn't start nginx"
	fi
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function nginx_restart() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
	about 'restart nginx'
	group 'nginx'

	nginx_stop && nginx_start
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

