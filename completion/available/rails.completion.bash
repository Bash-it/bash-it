# Bash completion support for Ruby on Rails.
#
#  Copyright (C) 2011 Jonhnny Weslley <http://www.jonhnnyweslley.net>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#  The latest version of this software can be obtained here:
#
#  http://github.com/jweslley/rails_completion
#
#  VERSION: 0.1.7


RAILSCOMP_FILE=".rails_generators~"

__railscomp(){
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $( compgen -W "$1" -- "$cur" ) )
}

#
# @param $1 Name of variable to return result to
# @param $2 Command list
__railscmd(){
  any_command=$(echo $2 | sed -e 's/[[:space:]]/|/g')
  for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
    if [[ ${COMP_WORDS[i]} == @($any_command) ]]; then
      eval $1="${COMP_WORDS[i]}"
    fi
  done
}

__rails_env(){
  __railscomp "{-e,--environment=}{test,development,production}"
}

#
# @param $1 Field's name
__rails_types(){
  __railscomp "${1%:*}:{string,text,integer,float,decimal,datetime,timestamp,date,time,binary,boolean,references}"
}

# Generators -------------------------------------------------------------------

__rails_generators_create_cache(){
  echo "
    require ::File.expand_path('../config/application',  __FILE__)
    require 'rails/generators'

    Rails::Generators.configure!
    Rails::Generators.lookup!

    hidden_namespaces = Rails::Generators.hidden_namespaces + ['rails:app']
    generators = Rails::Generators.subclasses.select do |generator|
      hidden_namespaces.exclude? generator.namespace
    end

    shell = Thor::Shell::Basic.new
    generators_opts = generators.inject({}) do |hash, generator|
      options = (generator.class_options_help(shell).values.flatten +
                  generator.class_options.values).uniq.map do |opt|
        boolean_opt = opt.type == :boolean || opt.banner.empty?
        boolean_opt ? opt.switch_name : \"#{opt.switch_name}=\"
      end
      hash[generator.namespace.gsub(/^rails:/, '')] = options
      hash
    end

    File.open(File.join(Rails.root, '${RAILSCOMP_FILE}'), 'w') do |f|
      YAML.dump(generators_opts, f)
    end
  " | ruby > /dev/null
}

__rails_generators_opts(){
  echo "
    require 'yaml'
    generator = '$1'
    generators_opts = YAML.load_file('${RAILSCOMP_FILE}')
    opts = generator.empty? ? generators_opts.keys : generators_opts[generator]
    opts.each { |opt| puts opt }
  " | ruby
}

__rails_generators(){
  recent=`ls -t "$RAILSCOMP_FILE" Gemfile 2> /dev/null | head -n 1`
  if [[ $recent != "$RAILSCOMP_FILE" ]]; then
    __rails_generators_create_cache
  fi
  __railscomp "$(__rails_generators_opts)"
}

__rails_generator_options(){
  local cur
  _get_comp_words_by_ref cur

  if [[ $cur == *:* ]]; then
    __rails_types "$cur"
  else
    __railscomp "$(__rails_generators_opts $1)"
  fi
}

#
# @param $1 file's path
# @param $2 filename suffix
# @param $3 name's suffix
# @param $4 kind. Defaults to class.
__rails_destroy(){
  __railscomp "$(find "$1" -name "*$2.rb" -exec grep ".*${4-class}.*$3.*" {} \; \
                  | awk '{ print $2 }' | sed s/$3$//g)"
}

# end of Generators ------------------------------------------------------------


# Rails commands ---------------------------------------------------------------

_rails_generate(){
  local cur generator generators
  _get_comp_words_by_ref cur

  generators=$(test -f "$RAILSCOMP_FILE" && __rails_generators_opts)
  __railscmd generator "$generators"

  if [ -z "$generator" ]; then
    case "$cur" in
      -*) __railscomp "--help" ;;
      *) __rails_generators ;;
    esac
    return
  fi

  __rails_generator_options "$generator"
}

_rails_destroy(){
  local cur generator generators
  _get_comp_words_by_ref cur

  generators=$(test -f "$RAILSCOMP_FILE" && __rails_generators_opts)
  __railscmd generator "$generators"

  if [ -z "$generator" ]; then
    case "$cur" in
      -*) __railscomp "--help" ;;
      *) __rails_generators ;;
    esac
    return
  fi

  case "$generator" in
    model|scaffold|resource) __rails_destroy "app/models/" ;;
    migration|session_migration) __rails_destroy "db/migrate/" ;;
    mailer) __rails_destroy "app/mailers/" ;;
    observer) __rails_destroy "app/models/" "_observer" "Observer" ;;
    controller|scaffold_controller) __rails_destroy "app/controllers/" "_controller" "Controller" ;;
    helper) __rails_destroy "app/helpers/" "_helper" "Helper" "module" ;;
    integration_test) __rails_destroy "test/integration/" "_test" "Test" ;;
    performance_test) __rails_destroy "test/performance/" "_test" "Test" ;;
    generator) __rails_destroy "lib/generators/" "_generator" "Generator" ;;
    *) COMPREPLY=() ;;
  esac
}

_rails_new(){
  local cur prev
  _get_comp_words_by_ref cur prev

  case "$cur" in
    -d*|--database=*)
      __railscomp "{-d,--database=}{mysql,oracle,postgresql,sqlite3,frontbase,ibm_db}"
      return
      ;;
  esac

  case "$prev" in
    --ruby=*|--builder=*|--template=*) _filedir ;;
    *) __railscomp "--skip-git --dev --edge --skip-gemfile --skip-active-record
      --skip-prototype --skip-test-unit --skip --force --pretend --quiet --help
      --version --builder= --template= -d --database= --ruby="
  esac
}

_rails_server(){
  local cur prev
  _get_comp_words_by_ref cur prev

  case "$cur" in
    -e*|--environment=*)
      __rails_env
      return
      ;;
  esac

  case "$prev" in
    --config=*|--pid=*) _filedir ;;
    *) __railscomp "--help --pid= -e --environment= --debugger --daemon --config= --binding= --port=" ;;
  esac
}

_rails_console(){
  __railscomp "test development production --sandbox --debugger"
}

_rails_profiler(){
  local cur prev
  _get_comp_words_by_ref cur

  case "$cur" in
    -*) __railscomp "--help" ;;
    *) __railscomp "flat graph graph_html"
  esac
}

_rails_plugin(){
  local cur prev
  _get_comp_words_by_ref cur prev

  case "$prev" in
    --root=*) _filedir ;;
    *) __railscomp "--help --verbose --root= --source= install remove" ;;
  esac
}

_rails_runner(){
  local cur prev
  _get_comp_words_by_ref cur prev

  case "$cur" in
    -e*|--environment=*)
      __rails_env
      return
      ;;
  esac

  case "$prev" in
    runner) __railscomp "--help -e --environment=" ;;
    -e*|--environment=*) _filedir ;;
    *) COMPREPLY==() ;;
  esac
}

_rails_benchmarker(){
  __railscomp "--help"
}

# end of Rails commands --------------------------------------------------------


_rails(){
  local cur options command commands
  _get_comp_words_by_ref cur

  options="--help --version"
  if [[ -f "script/rails" ]]; then
    commands="s server c console g generate destroy profiler plugin runner benchmarker db dbconsole"
  else
    commands="new"
  fi

  __railscmd command "$commands"

  if [ -z "$command" ]; then
    case "$cur" in
      -*) __railscomp "$options" ;;
      *) __railscomp "$commands" ;;
    esac
    return
  fi

  case "$command" in
    new)          _rails_new ;;
    s|server)     _rails_server ;;
    c|console)    _rails_console ;;
    g|generate)   _rails_generate ;;
    destroy)      _rails_destroy ;;
    profiler)     _rails_profiler ;;
    plugin)       _rails_plugin ;;
    runner)       _rails_runner ;;
    benchmarker)  _rails_benchmarker ;;
    db|dbconsole) COMPREPLY=() ;;
    *) COMPREPLY=() ;;
  esac
}

complete -o default -o nospace -F _rails rails
