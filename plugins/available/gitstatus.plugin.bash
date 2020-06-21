cite about-plugin
about-plugin 'speeds up your life by using gitstatus for git status calculations. install from https://github.com/romkatv/gitstatus'


function gitstatus_on_disable() {
  about 'Destructor of gitstatus plugin'
  group 'gitstatus'

  unset SCM_GIT_USE_GITSTATUS
  gitstatus_stop
}

[[ "$SCM_CHECK" == "true" ]] || return # No scm-check

[[ $- == *i* ]] || return  # non-interactive shell

SCM_GIT_GITSTATUS_PLUGIN_SH_LOC=${SCM_GIT_GITSTATUS_PLUGIN_SH_LOC:="$HOME/gitstatus/gitstatus.plugin.sh"}
if [[ -f "${SCM_GIT_GITSTATUS_PLUGIN_SH_LOC}" ]]; then
  source "${SCM_GIT_GITSTATUS_PLUGIN_SH_LOC}"
  # Start the actual gitstatus binary
  gitstatus_stop && gitstatus_start -s -1 -u -1 -c -1 -d -1
  export SCM_GIT_USE_GITSTATUS=true
fi
