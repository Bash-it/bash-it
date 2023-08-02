function __kitchen_instance_list () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  # cache to .kitchen.list.yml
  if [[ .kitchen.yml -nt .kitchen.list.yml || .kitchen.local.yml -nt .kitchen.list.yml ]] 
     then
    # update list if config has updated
    kitchen list --bare > .kitchen.list.yml
  fi
  cat .kitchen.list.yml
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

function __kitchen_options () 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  COMPREPLY=()

  case $prev in
    converge|create|destroy|diagnose|list|login|setup|test|verify)
      COMPREPLY=( $(compgen -W "$(__kitchen_instance_list)" -- ${cur} ))
      return 0
      ;;
    driver)
      COMPREPLY=( $(compgen -W "create discover help"  -- ${cur} ))
      return 0
      ;;
    *)
      COMPREPLY=( $(compgen -W "console converge create destroy driver help init list login setup test verify version"  -- ${cur} ))
      return 0
      ;;
  esac
	
	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}
complete -F __kitchen_options kitchen
