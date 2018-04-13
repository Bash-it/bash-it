_bash-it-additional-reload() {
  _about 'reloads ~/.bashrc'

  case $OSTYPE in
    darwin*)
      source ~/.bash_profile
      ;;
    *)
      source ~/.bashrc
      ;;
  esac
}

if ! command -v reload 1>/dev/null; then
  alias reload=_bash-it-additional-reload
fi
