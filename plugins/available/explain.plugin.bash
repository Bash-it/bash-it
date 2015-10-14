cite about-plugin
about-plugin 'mankier.com explain function to explain other commands'

# Add this to ~/.bash_profile or ~/.bashrc
explain () {
  if [ "$#" -eq 0 ]; then
    while read  -p "Command: " cmd; do
      curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$cmd"
    done
    echo "Bye!"
  elif [ "$#" -eq 1 ]; then
    curl -Gs "https://www.mankier.com/api/explain/?cols="$(tput cols) --data-urlencode "q=$1"
  else
    echo "Usage"
    echo "explain                  interactive mode."
    echo "explain 'cmd -o | ...'   one quoted command to explain it."
  fi
}

# Update 26-03-2015. If using this command gives no output, see if running a simple fetch causes this error:
# $ curl https://www.mankier.com
# curl: (35) Cannot communicate securely with peer: no common encryption algorithm(s).
# If so, try specifying a cipher in the curl commands: curl --ciphers ecdhe_ecdsa_aes_128_sha
