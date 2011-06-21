# Some aliases for Homebrew

alias bup="brew update && brew upgrade"
alias bout="brew outdated"
alias bin="brew install"
alias brm="brew uninstall"
alias bls="brew list"
alias bsr="brew search"
alias binf="brew info"
alias bdr="brew doctor"

function brew-help() {
  echo "Homebrew Alias Usage"
  echo
  echo "bup  = brew update && brew upgrade"
  echo "bout = brew outdated"
  echo "bin  = brew install"
  echo "brm  = brew uninstall"
  echo "bls  = brew list"
  echo "bsr  = brew search"
  echo "binf = brew info"
  echo "bdr  = brew doctor"
  echo
}
