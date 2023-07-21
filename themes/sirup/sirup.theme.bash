# For unstaged(*) and staged(+) values next to branch name in __git_ps1
GIT_PS1_SHOWDIRTYSTATE="enabled"

function rvm_version_prompt() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################

  local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')

  [ "$gemset" != "" ] && gemset="@$gemset"
  local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')

  [ "$version" == "1.9.2" ] && version=""

  local full="$version$gemset"

  [ "$full" != "" ] && echo "$full"

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



function prompt_command() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
    # Check http://github.com/Sirupsen/dotfiles for screenshot
    PS1="$blue\W/$bold_blue$(rvm_version_prompt)$bold_green$(__git_ps1 " (%s)") ${normal}$ "

	############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}



safe_append_prompt_command prompt_command
