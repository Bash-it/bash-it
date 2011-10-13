RUNINNG_AGENT_PID=`ps -ef | grep ssh-agent | grep -v grep  | awk '{print $2}' | xargs`

if [ "$RUNINNG_AGENT_PID" = "" ] && [ -f ~/.ssh/id_rsa ]; then
  MY_TIMEOUT=28800

  [ "$SSH_AGENT_TIMEOUT" = "" ] || MY_TIMEOUT="$SSH_AGENT_TIMEOUT"

  #28800, 8 hours. then go home
  ssh-agent -t $MY_TIMEOUT | grep -v echo > ~/.ssh/ssh_agent_rc

  . ~/.ssh/ssh_agent_rc 

  echo "ssh-agent::ssh-add:"
  ssh-add
else
  . ~/.ssh/ssh_agent_rc 
   
fi;

#alias kagent="kill -9 $SSH_AGENT_PID"
