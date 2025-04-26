# shellcheck shell=bash
cite about-plugin
about-plugin 'Helper functions for Ruby on Rails'

# Quick function to kill a daemonized Rails server
function killrails() {
	about 'Searches for a daemonized Rails server in tmp/pids and attempts to kill it.'
	group 'rails'

	railsPid="$(cat tmp/pids/server.pid)"
	if [ -n "$railsPid" ]; then
		echo "[OK] Rails Server Process Id : ${railsPid}"
		kill -9 "$railsPid"
		echo "[OK] Process Killed"
	else
		echo "[FAIL] Error killing Rails server"
		return 1
	fi
}
