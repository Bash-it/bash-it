cite about-plugin
about-plugin 'Function to kill a daemonized Rails server.'

# Quick function to kill a daemonized Rails server
function killrails() {
  about 'Searches for a daemonized Rails server in tmp/pids and attempts to kill it.'
  group 'server'

  railsPid="$(cat tmp/pids/server.pid)"
  if [ ! -z "$railsPid" ]; then
    echo "[OK] Rails Server Process Id : ${railsPid}"
    kill -9 $railsPid
    echo "[OK] Process Killed"
  else
    echo "[FAIL] Error killing Rails server"
    return 1
  fi
}
