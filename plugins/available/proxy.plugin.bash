# shellcheck shell=bash
about-plugin 'Proxy Tools'

function disable-proxy() {
	about 'Disables proxy settings for Bash, npm and SSH'
	group 'proxy'

	unset http_proxy
	unset https_proxy
	unset HTTP_PROXY
	unset HTTPS_PROXY
	unset ALL_PROXY
	unset no_proxy
	unset NO_PROXY
	echo "Disabled proxy environment variables"

	npm-disable-proxy
	ssh-disable-proxy
	svn-disable-proxy
}

function enable-proxy() {
	about 'Enables proxy settings for Bash, npm and SSH'
	group 'proxy'

	export http_proxy="${BASH_IT_HTTP_PROXY:-}"
	export https_proxy="${BASH_IT_HTTPS_PROXY:-}"
	export HTTP_PROXY="${http_proxy:-}"
	export HTTPS_PROXY="${https_proxy:-}"
	export ALL_PROXY="${http_proxy:-}"
	export no_proxy="${BASH_IT_NO_PROXY:-}"
	export NO_PROXY="${no_proxy:-}"
	echo "Enabled proxy environment variables"

	npm-enable-proxy
	ssh-enable-proxy
	svn-enable-proxy
}

function enable-proxy-alt() {
	about 'Enables alternate proxy settings for Bash, npm and SSH'
	group 'proxy'

	export http_proxy="${BASH_IT_HTTP_PROXY_ALT:-}"
	export https_proxy="${BASH_IT_HTTPS_PROXY_ALT:-}"
	export HTTP_PROXY="${http_proxy:-}"
	export HTTPS_PROXY="${https_proxy:-}"
	export ALL_PROXY="${http_proxy:-}"
	export no_proxy="${BASH_IT_NO_PROXY:-}"
	export NO_PROXY="${no_proxy:-}"
	echo "Enabled alternate proxy environment variables"

	npm-enable-proxy "${http_proxy:-}" "${https_proxy:-}"
	ssh-enable-proxy
	svn-enable-proxy "${http_proxy:-}"
}

function show-proxy() {
	about 'Shows the proxy settings for Bash, Git, npm and SSH'
	group 'proxy'

	echo ""
	echo "Environment Variables"
	echo "====================="
	env | grep -i "proxy" | grep -v "BASH_IT"

	bash-it-show-proxy
	npm-show-proxy
	git-global-show-proxy
	svn-show-proxy
	ssh-show-proxy
}

function proxy-help() {
	about 'Provides an overview of the bash-it proxy configuration'
	group 'proxy'

	cat << EOF
Bash-it provides support for enabling/disabling proxy settings for various shell tools.

The following backends are currently supported (in addition to the shell's environment variables): Git, SVN, npm, ssh

Bash-it uses the following variables to set the shell's proxy settings when you call 'enable-proxy'.
These variables are best defined in a custom script in bash-it's custom script folder ('$BASH_IT/custom'),
e.g. '$BASH_IT/custom/proxy.env.bash'
* BASH_IT_HTTP_PROXY and BASH_IT_HTTPS_PROXY: Define the proxy URL to be used, e.g. 'http://localhost:1234'
* BASH_IT_NO_PROXY: A comma-separated list of proxy exclusions, e.g. '127.0.0.1,localhost'

Run 'glossary proxy' to show the available proxy functions with a short description.
EOF

	bash-it-show-proxy
}

function bash-it-show-proxy() {
	about 'Shows the bash-it proxy settings'
	group 'proxy'

	echo ""
	echo "bash-it Environment Variables"
	echo "============================="
	echo "(These variables will be used to set the proxy when you call 'enable-proxy')"
	echo ""
	env | grep -e "BASH_IT.*PROXY"
}

function npm-show-proxy() {
	about 'Shows the npm proxy settings'
	group 'proxy'

	if _command_exists npm; then
		echo ""
		echo "npm"
		echo "==="
		echo "npm HTTP  proxy: $(npm config get proxy)"
		echo "npm HTTPS proxy: $(npm config get https-proxy)"
		echo "npm proxy exceptions: $(npm config get noproxy)"
	fi
}

function npm-disable-proxy() {
	about 'Disables npm proxy settings'
	group 'proxy'

	if _command_exists npm; then
		npm config delete proxy
		npm config delete https-proxy
		npm config delete noproxy
		echo "Disabled npm proxy settings"
	fi
}

function npm-enable-proxy() {
	about 'Enables npm proxy settings'
	group 'proxy'

	local my_http_proxy="${1:-${BASH_IT_HTTP_PROXY:-}}"
	local my_https_proxy="${2:-${BASH_IT_HTTPS_PROXY:-}}"
	local my_no_proxy="${3:-${BASH_IT_NO_PROXY:-}}"

	if _command_exists npm; then
		npm config set proxy "${my_http_proxy:?}" || return
		npm config set https-proxy "${my_https_proxy:?}" || return
		npm config set noproxy "${my_no_proxy:-}" || return
		echo "Enabled npm proxy settings"
	fi
}

function git-global-show-proxy() {
	about 'Shows global Git proxy settings'
	group 'proxy'

	if _command_exists git; then
		echo ""
		echo "Git (Global Settings)"
		echo "====================="
		echo "Git (Global) HTTP  proxy: $(git config --global --get http.proxy)"
		echo "Git (Global) HTTPS proxy: $(git config --global --get https.proxy)"
	fi
}

function git-global-disable-proxy() {
	about 'Disables global Git proxy settings'
	group 'proxy'

	if _command_exists git; then
		git config --global --unset-all http.proxy
		git config --global --unset-all https.proxy
		echo "Disabled global Git proxy settings"
	fi
}

function git-global-enable-proxy() {
	about 'Enables global Git proxy settings'
	group 'proxy'

	if _command_exists git; then
		git-global-disable-proxy

		git config --global --add http.proxy "${BASH_IT_HTTP_PROXY:?}"
		git config --global --add https.proxy "${BASH_IT_HTTPS_PROXY:?}"
		echo "Enabled global Git proxy settings"
	fi
}

function git-show-proxy() {
	about 'Shows current Git project proxy settings'
	group 'proxy'

	if _command_exists git; then
		echo "Git Project Proxy Settings"
		echo "====================="
		echo "Git HTTP  proxy: $(git config --get http.proxy)"
		echo "Git HTTPS proxy: $(git config --get https.proxy)"
	fi
}

function git-disable-proxy() {
	about 'Disables current Git project proxy settings'
	group 'proxy'

	if _command_exists git; then
		git config --unset-all http.proxy
		git config --unset-all https.proxy
		echo "Disabled Git project proxy settings"
	fi
}

function git-enable-proxy() {
	about 'Enables current Git project proxy settings'
	group 'proxy'

	if _command_exists git; then
		git-disable-proxy

		git config --add http.proxy "${BASH_IT_HTTP_PROXY:?}"
		git config --add https.proxy "${BASH_IT_HTTPS_PROXY:?}"
		echo "Enabled Git project proxy settings"
	fi
}

function svn-show-proxy() {
	about 'Shows SVN proxy settings'
	group 'proxy'

	if _command_exists svn && _command_exists python2; then
		echo ""
		echo "SVN Proxy Settings"
		echo "=================="
		python2 - << END
import ConfigParser, os
config = ConfigParser.ConfigParser()
config.read(os.path.expanduser('~/.subversion/servers'))
if (config.has_section('global')):
	proxy_host = ''
	proxy_port = ''
	proxy_exceptions = ''
	if (config.has_option('global', 'http-proxy-host')):
		proxy_host = config.get('global', 'http-proxy-host')
	if (config.has_option('global', 'http-proxy-port')):
		proxy_port = config.get('global', 'http-proxy-port')
	if (config.has_option('global', 'http-proxy-exceptions')):
		proxy_exceptions = config.get('global', 'http-proxy-exceptions')
	print 'http-proxy-host      : ' + proxy_host
	print 'http-proxy-port      : ' + proxy_port
	print 'http-proxy-exceptions: ' + proxy_exceptions
END
	fi
}

function svn-disable-proxy() {
	about 'Disables SVN proxy settings'
	group 'proxy'

	if _command_exists svn_command_exists python2; then
		python2 - << END
import ConfigParser, os
config = ConfigParser.ConfigParser()
config.read(os.path.expanduser('~/.subversion/servers'))
if config.has_section('global'):
	changed = False
	if config.has_option('global', 'http-proxy-host'):
		config.remove_option('global', 'http-proxy-host')
		changed = True
	if config.has_option('global', 'http-proxy-port'):
		config.remove_option('global', 'http-proxy-port')
		changed = True
	if config.has_option('global', 'http-proxy-exceptions'):
		config.remove_option('global', 'http-proxy-exceptions')
		changed = True
	if changed:
		with open(os.path.expanduser('~/.subversion/servers'), 'wb') as configfile:
			config.write(configfile)
	print 'Disabled SVN proxy settings'
END
	fi
}

function svn-enable-proxy() {
	about 'Enables SVN proxy settings'
	group 'proxy'

	if _command_exists svn _command_exists python2; then
		local my_http_proxy="${1:-${BASH_IT_HTTP_PROXY:-}}"

		python2 - "${my_http_proxy:?}" "${BASH_IT_NO_PROXY:-}" << END
import ConfigParser, os, sys, urlparse
pieces = urlparse.urlparse(sys.argv[1])
host = pieces.hostname
port = pieces.port
exceptions = sys.argv[2]
config = ConfigParser.ConfigParser()
config.read(os.path.expanduser('~/.subversion/servers'))
if not config.has_section('global'):
	config.add_section('global')
if host is not None:
	config.set('global', 'http-proxy-host', host)
else:
	config.remove_option('global', 'http-proxy-host')
if port is not None:
	config.set('global', 'http-proxy-port', port)
else:
	config.remove_option('global', 'http-proxy-port')
if exceptions is not None:
	config.set('global', 'http-proxy-exceptions', exceptions)
else:
	config.remove_option('global', 'http-proxy-exceptions')
with open(os.path.expanduser('~/.subversion/servers'), 'wb') as configfile:
	config.write(configfile)
print 'Enabled SVN proxy settings'
END
	fi
}

function ssh-show-proxy() {
	about 'Shows SSH config proxy settings (from ~/.ssh/config)'
	group 'proxy'

	if [ -f ~/.ssh/config ]; then
		echo ""
		echo "SSH Config Enabled in ~/.ssh/config"
		echo "==================================="
		awk '
		    $1 == "Host" {
		        host = $2;
		        next;
		    }
		    $1 == "ProxyCommand" {
		        $1 = "";
		        printf "%s\t%s\n", host, $0
		    }
		' ~/.ssh/config | column -t

		echo ""
		echo "SSH Config Disabled in ~/.ssh/config"
		echo "===================================="
		awk '
		    $1 == "Host" {
		        host = $2;
		        next;
		    }
		    $0 ~ "^#.*ProxyCommand.*" {
		        $1 = "";
		        $2 = "";
		        printf "%s\t%s\n", host, $0
		    }
		' ~/.ssh/config | column -t
	fi
}

function ssh-disable-proxy() {
	about 'Disables SSH config proxy settings'
	group 'proxy'

	if [ -f ~/.ssh/config ]; then
		sed -e's/^.*ProxyCommand/#	ProxyCommand/' "${BASH_IT_SED_I_PARAMETERS[@]}" ~/.ssh/config
		echo "Disabled SSH config proxy settings"
	fi
}

function ssh-enable-proxy() {
	about 'Enables SSH config proxy settings'
	group 'proxy'

	if [ -f ~/.ssh/config ]; then
		sed -e's/#	ProxyCommand/	ProxyCommand/' "${BASH_IT_SED_I_PARAMETERS[@]}" ~/.ssh/config
		echo "Enabled SSH config proxy settings"
	fi
}
