cite about-plugin
about-plugin 'speeds up your life by using gitstatusd for git status calculations. install from https://github.com/romkatv/gitstatus'

[[ "$SCM_CHECK" == "true" ]] || return # No scm-check

[[ $- == *i* ]] || return  # non-interactive shell

SCM_GIT_GITSTATUSD_LOC=${SCM_GIT_GITSTATUSD_LOC:="$HOME/gitstatus/gitstatus.plugin.sh"}
if [[ -f "${SCM_GIT_GITSTATUSD_LOC}" ]]; then
  source "${SCM_GIT_GITSTATUSD_LOC}"
  # Start the actual gitstatusd binary
  gitstatus_stop && gitstatus_start -s -1 -u -1 -c -1 -d -1
  export SCM_GIT_USE_GITSTATUSD=true
fi
