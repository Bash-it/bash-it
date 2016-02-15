cite about-plugin
about-plugin 'add "export PROJECT_PATHS=~/projects:~/intertrode/projects" to navigate quickly to your project directories with `pj` and `pjo`'

function pj {
about 'navigate quickly to your various project directories'
group 'projects'


if [ -z "$PROJECT_PATHS" ]; then
  echo "error: PROJECT_PATHS not set"
  return 1
fi


local cmd
local dest
local -a dests


if [ "$1" == "open" ]; then
  shift
  cmd="$EDITOR"
fi
cmd="${cmd:-cd}"


if [ -z "$1" ]; then
  echo "error: no project provided"
  return 1
fi


# collect possible destinations to account for directories
# with the same name in project directories
for i in ${PROJECT_PATHS//:/$'\n'}; do
  if [ -d "$i"/"$1" ]; then
    dests+=("$i/$1")
  fi
done


# when multiple destinations are found, present a menu
if [ ${#dests[@]} -eq 0 ]; then
  echo "error: no such project '$1'"
  return 1

elif [ ${#dests[@]} -eq 1 ]; then
  dest="${dests[0]}"

elif [ ${#dests[@]} -gt 1 ]; then
  PS3="Multiple project directories found. Please select one: "
  dests+=("cancel")
  select d in "${dests[@]}"; do
    case $d in
      "cancel")
        return
        ;;
      *)
        dest=$d
        break
        ;;
    esac
  done

else
  echo "error: please report this error"
  return 1 # should never reach this

fi


$cmd "$dest"
}

alias pjo="pj open"
