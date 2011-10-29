function get_ssh_agent_timeout(){
  #28800, 8 hours. then go home
  local my_timeout=28800

  [ "$SSH_AGENT_TIMEOUT" != "" ] && my_timeout="$SSH_AGENT_TIMEOUT"

  echo $my_timeout
}

function bind_ssh_agent(){
  local agent_pid=`ps -U $USER | grep ssh-agent | grep -v grep  | awk '{print $1}' | xargs`

  if [ "$agent_pid" = "" ]; then
    ssh-agent -t $(get_ssh_agent_timeout) > ~/.ssh/ssh_agent_rc

    . ~/.ssh/ssh_agent_rc 

  else
    . ~/.ssh/ssh_agent_rc 
   
  fi;
}

function ssh_add_to_ssh_agent(){
  local id_key_file=$1
  local added=`ssh-add -l | grep $id_key_file`

  [ "$added" = "" ] && ssh-add -t $(get_ssh_agent_timeout)
}

MY_KEY_FILE=~/.ssh/id_rsa

if [ "$MY_KEY_FILE" != "" ]; then
  bind_ssh_agent
  ssh_add_to_ssh_agent $MY_KEY_FILE
fi;

#alias kagent="kill -9 $SSH_AGENT_PID"
