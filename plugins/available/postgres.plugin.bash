# shellcheck shell=bash
cite about-plugin
about-plugin 'postgres helper functions'


export PGVERSION=`pg_config --version | awk '{print $2}'`
export POSTGRES_BIN=`pg_config --bindir`
COMMON_PGDATA_PATHS=("/usr/local/var/postgres" "/var/pgsql" "/Library/Server/PostgreSQL/Data")
for possible in "${COMMON_PGDATA_PATHS[@]}"
do
   :
   if [ -f "$possible/pg_hba.conf" ]
   then
       # echo "PGDATA: $possible"
       export PGDATA=$possible
   fi
done





function postgres_start()
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'Starts PostgreSQL server'
  group 'postgres'

  echo 'Starting Postgres....';
  ${POSTGRES_BIN}/pg_ctl -D $PGDATA -l $PGDATA/logfile  start

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function postgres_stop()
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'Stops PostgreSQL server'
  group 'postgres'

  echo 'Stopping Postgres....';
  ${POSTGRES_BIN}/pg_ctl -D $PGDATA -l $PGDATA/logfile stop -s -m fast

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function postgres_status() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'Returns status of PostgreSQL server'
  group 'postgres'

  # $POSTGRES_BIN/pg_ctl -D $PGDATA status
  if [[ $(is_postgres_running) == "no server running" ]]
  then
    echo "Postgres service [STOPPED]"
  else
    echo "Postgres service [RUNNING]"
  fi

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function is_postgres_running
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  ${POSTGRES_BIN}/pg_ctl -D ${PGDATA} status | grep -F -o "no server running"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


function postgres_restart 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'Restarts status of PostgreSQL server'
  group 'postgres'

  echo 'Restarting Postgres....';
  $POSTGRES_BIN/pg_ctl -D ${PGDATA} restart

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function postgres_logfile
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'View the last 500 lines from logfile'
  group 'postgres'

  tail -500 ${PGDATA}/logfile | less

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function postgres_serverlog
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  about 'View the last 500 lines from server.log'
  group 'postgres'

  tail -500 ${PGDATA}/server.log | less

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}


# function postgres_syslog {
#   about 'View the last 500 lines from syslog'
#   group 'postgres'
#
#   tail -500 $PGDATA/pg_log/`ls -Art $PGDATA/pg_log | tail -n 1` | less
# }
#
