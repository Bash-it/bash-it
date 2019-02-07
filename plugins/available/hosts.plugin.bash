# Requested by philipjohn here : https://github.com/Bash-it/bash-it/issues/1264

cite about-plugin
about-plugin 'add or remove hosts records'

function hosts() {
  if [ ! "$(whoami)" = "root" ]; then echo "Error: Run this function as root (using sudo)" && exit 1; fi
  if [ "$1" = "add" ]; then
      if [[ "$2" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          shift
          echo "$1 $2" >> /etc/hosts
          echo "Added $1 $2 to hosts file"
      else
          echo "Error : Provided IP is invalid"
      fi
  elif [ "$1" = "list" ]; then
      cat /etc/hosts
  elif [ "$1" = "del" ] || [ "$1" = "remove" ]; then
      shift
      grep -v "$1" /etc/hosts > newhosts
      mv newhosts /etc/hosts
      echo "Removed $1 from hosts file"
  else
      echo "Missing argument (del, list, add)"
  fi
}
