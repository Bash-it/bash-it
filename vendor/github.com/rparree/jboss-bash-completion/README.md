jboss-bash-completion
=====================

JBoss Bash Completion for JBoss 5 and 7 (EAP 6)



Overview
--------

Completion for the `run.sh` (JBoss5) and `standalone.sh`/`domain.sh`

Some of the options available in jboss7: 


* `--admin-only` `-h` `-help` `-version` `-V` `-v`
* `-Djboss.home.dir`  
* `--server-config` (options the xml files in the configuration directory relative to -Djboss.server.base.dir)
* `-b` `-bmanagement` `-bunsecure` `-bpublic` `-Djboss.domain.master.address` `-Djboss.bind.address.*` (options: your local IP addresses and 0.0.0.0)
* `-Djboss.socket.binding.port-offset`  (options: 100 200 300 400 10000 20000 30000 40000)
* `-u` (options 239.255.0.1 239.255.0.2 239.255.0.3)
* `-P` -Djboss.node.name 


Install
-------

Make sure you have installed bash_completion 1.3 (or higher):

Debian/Ubuntu: `apt-get install bash-completion`
RHEL/CentOS: `yum install bash-completion`

Copy the file(s) to your `/etc/bash_completion.d` folder:

`sudo cp jboss* /etc/bash_completion.d`


