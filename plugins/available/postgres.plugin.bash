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





function postgres_start {
  about 'Starts PostgresSQL server'
  group 'postgres'

  echo 'Starting PostgresSQL Server....'; 
  $POSTGRES_BIN/pg_ctl -D $PGDATA -l $PGDATA/logfile  start
}

function postgres_stop {
  about 'Steps PostgresSQL server'
  group 'postgres'

  echo 'Stopping PostgresSQL Server....'; 
  $POSTGRES_BIN/pg_ctl -D $PGDATA -l $PGDATA/logfile stop -s -m fast
}

function postgres_status {
  about 'Returns status of PostgresSQL server'
  group 'postgres'

  # $POSTGRES_BIN/pg_ctl -D $PGDATA status  
  if [[ $(is_postgres_running) == "no server running" ]]
  then
    echo "Postgres service [STOPPED]"
  else
    echo "Postgres service [RUNNING]"
  fi
}


function is_postgres_running {
  $POSTGRES_BIN/pg_ctl -D $PGDATA status | egrep -o "no server running"
}


function postgres_restart {
  about 'Restarts status of PostgresSQL server'
  group 'postgres'

  echo 'Restarting Postgres....'; 
  $POSTGRES_BIN/pg_ctl -D $PGDATA restart
}

function postgres_logfile {
  about 'View the last 500 lines from logfile'
  group 'postgres'

  tail -500 $PGDATA/logfile | less
}

function postgres_serverlog {
  about 'View the last 500 lines from server.log'
  group 'postgres'

  tail -500 $PGDATA/server.log | less
}


# function postgres_syslog {
#   about 'View the last 500 lines from syslog'
#   group 'postgres'
#
#   tail -500 $PGDATA/pg_log/`ls -Art $PGDATA/pg_log | tail -n 1` | less
# }
#

