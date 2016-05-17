# Quick function to kill a daemonized Rails server
function killrails() {
	railsPid="$(cat tmp/pids/server.pid)"
	if [ ! -z "$railsPid" ]; then
		echo "[OK] Rails Server Process Id : ${railsPid}"
		kill -9 $railsPid
		echo "[OK] Process Killed"
	else
		echo "[FAIL] Error killing Rails server"
	fi
}