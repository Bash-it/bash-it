# Load RVM, if you are using it

cite about-plugin
about-plugin 'load rvm, if you are using it'

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# Check to make sure that RVM is actually loaded before adding
# the customizations to it.
if [ "$rvm_path" ]
then
    # Load the auto-completion script if RVM was loaded.
    [[ -r $rvm_path/scripts/completion ]] && . $rvm_path/scripts/completion

   function  switch () 
    {
      ############ STACK_TRACE_BUILDER #####################
      Function_Name="${FUNCNAME[0]}"
      Function_PATH="${Function_PATH}/${Function_Name}"
      ######################################################
          rvm $1
          local v=$(rvm_version)
          rvm wrapper $1 textmate
          echo "Switch to Ruby version: "$v
      ############### Stack_TRACE_BUILDER ################
      Function_PATH="$( dirname ${Function_PATH} )"
      ####################################################
    }

  function  rvm_default () 
    {
      ############ STACK_TRACE_BUILDER #####################
      Function_Name="${FUNCNAME[0]}"
      Function_PATH="${Function_PATH}/${Function_Name}"
      ######################################################
          rvm --default $1
          rvm wrapper $1 textmate
      ############### Stack_TRACE_BUILDER ################
      Function_PATH="$( dirname ${Function_PATH} )"
      ####################################################
    }

    function rvm_version () 
    {
      ############ STACK_TRACE_BUILDER #####################
      Function_Name="${FUNCNAME[0]}"
      Function_PATH="${Function_PATH}/${Function_Name}"
      ######################################################
          ruby --version
      ############### Stack_TRACE_BUILDER ################
      Function_PATH="$( dirname ${Function_PATH} )"
      ####################################################
    }

fi
