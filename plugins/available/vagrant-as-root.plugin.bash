# Simple function for vagrant ssh that immediately switches to root.
function vssh() {
      vagrant ssh $1 -- -t 'sudo su -; /bin/bash'
  }
