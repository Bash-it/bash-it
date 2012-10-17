cite about-plugin
about-plugin 'manage your nginx service'

function nginx_reload() {
  about 'reload your nginx config'
  group 'nginx'

  echo "Reloading NGINX..."
  sudo $NGINX_PATH/nginx -s reload
}

function nginx_stop() {
  about 'stop nginx'
  group 'nginx'

  FILE="${NGINX_PID_PATH}/nginx.pid"
  if [ -e $FILE ]; then
    echo "Stopping NGINX..."
    PID=`cat $NGINX_PID_PATH/nginx.pid`
    sudo kill -INT $PID
  else
    echo "Nginx pid file not found at: ${FILE}"
    return 0
  fi
}

function nginx_start() {
  about 'start nginx'
  group 'nginx'

  FILE="${NGINX_PATH}/nginx"
  if [ -e $FILE ]; then
    echo "Starting NGINX..."
    sudo $NGINX_PATH/nginx
  else
    echo "Couldn't start nginx"
  fi
}

function nginx_restart() {
  about 'restart nginx'
  group 'nginx'

  FILE="${NGINX_PID_PATH}/nginx.pid"
  if [ -e $FILE ]; then
    nginx_stop
    nginx_start
    echo "Done!"
  else
    echo "Nginx pid file not found at: ${FILE}"
    return 0
  fi
}
