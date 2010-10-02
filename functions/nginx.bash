#!/bin/bash

function nginx_reload() {
  FILE="${NGINX_PATH}/logs/nginx.pid"
  if [ -e $FILE ]; then
    echo "Reloading NGINX..."
    PID=`cat $NGINX_PATH/logs/nginx.pid`
    sudo kill -HUP $PID
  else
    echo "Nginx pid file not found"
    return 0
  fi
}

function nginx_stop() {
  FILE="${NGINX_PATH}/logs/nginx.pid"
  if [ -e $FILE ]; then
    echo "Stopping NGINX..."
    PID=`cat $NGINX_PATH/logs/nginx.pid`
    sudo kill -INT $PID
  else
    echo "Nginx pid file not found"
    return 0
  fi
}

function nginx_start() {
  FILE="${NGINX_PATH}/sbin/nginx"
  if [ -e $FILE ]; then
    echo "Starting NGINX..."
    sudo $NGINX_PATH/sbin/nginx
  else
    echo "Couldn't start nginx"
  fi
}

function nginx_restart() {
  FILE="${NGINX_PATH}/logs/nginx.pid"
  if [ -e $FILE ]; then
    echo "Stopping NGINX..."
    PID=`cat $NGINX_PATH/logs/nginx.pid`
    sudo kill -INT $PID
    sleep 1
    echo "Starting NGINX..."
    sudo $NGINX_PATH/sbin/nginx
  else
    echo "Nginx pid file not found"
    return 0
  fi
}