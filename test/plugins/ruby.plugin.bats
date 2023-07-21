# shellcheck shell=bats

load "${MAIN_BASH_IT_DIR?}/test/test_helper.bash"

function local_setup_file() 
{
	############ STACK_TRACE_BUILDER #####################
	Function_Name="${FUNCNAME[0]}"
	Function_PATH="${Function_PATH}/${Function_Name}"
	######################################################
  setup_libs "helpers"
  ############### Stack_TRACE_BUILDER ################
	Function_PATH="$( dirname ${Function_PATH} )"
	####################################################
}

@test "plugins ruby: remove_gem is defined" {
  run load "${BASH_IT?}/plugins/available/ruby.plugin.bash"
  assert_success
  load "${BASH_IT?}/plugins/available/ruby.plugin.bash"

  run type remove_gem
  assert_line -n 1 "remove_gem () "
}

@test "plugins ruby: PATH includes ~/.gem/ruby/bin" {
  if ! type ruby >/dev/null 
     then
    skip 'ruby not installed'
  fi

  mkdir -p "$(ruby -e 'print Gem.user_dir')/bin"

  run load "${BASH_IT?}/plugins/available/ruby.plugin.bash"
  assert_success
  load "${BASH_IT?}/plugins/available/ruby.plugin.bash"

  local last_path_entry="$(tail -1 <<<"${PATH//:/$'\n'}")"
  [[ "${last_path_entry}" == "$(ruby -e 'print Gem.user_dir')/bin" ]]
}
