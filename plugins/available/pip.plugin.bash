cite about-plugin
about-plugin 'pip upgrade/uninstall all packages'

pip-upgrade-all() {
  local outdated_packages="$(pip list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1)"
  if [ -z $outdated_packages ]; then
    echo "pip: everything is up to date."
  else
    for package in $outdated_packages; do
      pip install --user -U $package
    done
  fi
}

pip-uninstall-all() {
  local installed_packages="$(pip list --user --format=freeze | grep -v '^\-e' | cut -d = -f 1)"
  if [ -z $installed_packages ]; then
    echo "pip: nothing has been installed."
  else
    for package in $installed_packages; do
      pip uninstall -y $package
    done
  fi
}
