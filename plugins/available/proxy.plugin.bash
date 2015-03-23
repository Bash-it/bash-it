cite about-plugin
about-plugin 'Proxy Tools'

disable_proxy ()
{
	about 'Disables proxy settings for Bash, npm and SSH'
	group 'proxy'
	
	unset http_proxy
	unset https_proxy
	unset ALL_PROXY
	echo "Disabled proxy environment variables"
	
	npm_disable_proxy
	ssh_disable_proxy
}

enable_proxy ()
{
	about 'Enables proxy settings for Bash, npm and SSH'
	group 'proxy'
	
	export http_proxy=$BASH_IT_HTTP_PROXY
	export https_proxy=$BASH_IT_HTTPS_PROXY
	export ALL_PROXY=$BASH_IT_HTTP_PROXY
	echo "Enabled proxy environment variables"
	
	npm_enable_proxy
	ssh_enable_proxy
}

show_proxy ()
{
	about 'Shows the proxy settings for Bash, Git, npm and SSH'
	group 'proxy'
	
	echo ""
	echo "Environment Variables"
	echo "====================="
	env | grep "proxy"
	env | grep "ALL_PROXY"
	
	bash_it_show_proxy
	npm_show_proxy
	git_global_show_proxy
	ssh_show_proxy
}

proxy_help ()
{
	about 'Provides an overview of the bash-it proxy configuration'
	group 'proxy'
	
	echo ""
	echo "bash-it uses the variables BASH_IT_HTTP_PROXY and BASH_IT_HTTPS_PROXY to set the shell's"
	echo "proxy settings when you call 'enable_proxy'. These variables are best defined in a custom"
	echo "script in bash-it's custom script folder ($BASH_IT/custom),"
	echo "e.g. $BASH_IT/custom/proxy.env.bash"
	
	bash_it_show_proxy
}

bash_it_show_proxy ()
{
	about 'Shows the bash-it proxy settings'
	group 'proxy'
	
	echo ""
	echo "bash-it Environment Variables"
	echo "============================="
	echo "(These variables will be used to set the proxy when you call 'enable_proxy')"
	echo ""
	env | grep -e "BASH_IT.*PROXY"	
}

npm_show_proxy ()
{
	about 'Shows the npm proxy settings'
	group 'proxy'
	
	if $(command -v npm &> /dev/null) ; then
		echo ""
		echo "npm"
		echo "==="
		echo "npm HTTP  proxy: " `npm config get proxy`
		echo "npm HTTPS proxy: " `npm config get https-proxy`
	fi
}

npm_disable_proxy ()
{
	about 'Disables npm proxy settings'
	group 'proxy'
	
	if $(command -v npm &> /dev/null) ; then
		npm config delete proxy
		npm config delete https-proxy
		echo "Disabled npm proxy settings"
	fi
}

npm_enable_proxy ()
{
	about 'Enables npm proxy settings'
	group 'proxy'
	
	if $(command -v npm &> /dev/null) ; then
		npm config set proxy $BASH_IT_HTTP_PROXY
		npm config set https-proxy $BASH_IT_HTTPS_PROXY
		echo "Enabled npm proxy settings"
	fi
}

git_global_show_proxy ()
{
	about 'Shows global Git proxy settings'
	group 'proxy'
	
	if $(command -v git &> /dev/null) ; then
		echo ""
		echo "Git (Global Settings)"
		echo "====================="
		echo "Git (Global) HTTP  proxy: " `git config --global --get http.proxy`
		echo "Git (Global) HTTPS proxy: " `git config --global --get https.proxy`
	fi
}

git_global_disable_proxy ()
{
	about 'Disables global Git proxy settings'
	group 'proxy'
	
	if $(command -v git &> /dev/null) ; then
		git config --global --unset-all http.proxy
		git config --global --unset-all https.proxy
		echo "Disabled global Git proxy settings"
	fi
}

git_global_enable_proxy ()
{
	about 'Enables global Git proxy settings'
	group 'proxy'
	
	if $(command -v git &> /dev/null) ; then
		git_global_disable_proxy
		
		git config --global --add http.proxy $BASH_IT_HTTP_PROXY
		git config --global --add https.proxy $BASH_IT_HTTPS_PROXY
		echo "Enabled global Git proxy settings"
	fi
}

git_show_proxy ()
{
	about 'Shows current Git project proxy settings'
	group 'proxy'
	
	if $(command -v git &> /dev/null) ; then
		echo "Git Project Proxy Settings"
		echo "====================="
		echo "Git HTTP  proxy: " `git config --get http.proxy`
		echo "Git HTTPS proxy: " `git config --get https.proxy`
	fi
}

git_disable_proxy ()
{
	about 'Disables current Git project proxy settings'
	group 'proxy'
	
	if $(command -v git &> /dev/null) ; then
		git config --unset-all http.proxy
		git config --unset-all https.proxy
		echo "Disabled Git project proxy settings"
	fi
}

git_enable_proxy ()
{
	about 'Enables current Git project proxy settings'
	group 'proxy'
	
	if $(command -v git &> /dev/null) ; then
		git_disable_proxy
		
		git config --add http.proxy $BASH_IT_HTTP_PROXY
		git config --add https.proxy $BASH_IT_HTTPS_PROXY
		echo "Enabled Git project proxy settings"
	fi
}

ssh_show_proxy ()
{
	about 'Shows SSH config proxy settings (from ~/.ssh/config)'
	group 'proxy'
	
	if [ -f ~/.ssh/config ] ; then
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

ssh_disable_proxy ()
{
	about 'Disables SSH config proxy settings'
	group 'proxy'
	
	if [ -f ~/.ssh/config ] ; then
		sed -e's/^.*ProxyCommand/#	ProxyCommand/' -i ""  ~/.ssh/config
		echo "Disabled SSH config proxy settings"
	fi
}


ssh_enable_proxy ()
{
	about 'Enables SSH config proxy settings'
	group 'proxy'
	
	if [ -f ~/.ssh/config ] ; then
		sed -e's/#	ProxyCommand/	ProxyCommand/' -i ""  ~/.ssh/config
		echo "Enabled SSH config proxy settings"
	fi
}
