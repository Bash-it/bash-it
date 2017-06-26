cite 'about-alias'
about-alias 'vagrant aliases'

# Aliases
alias vhl='vagrant hosts list'
alias vscp='vaagrant scp'
alias vsl='vagrant snapshot list'
alias vst='vagrant snapshot take'
alias vup="vagrant up"
alias vupo="vagrant up $@ --provider=openstack"
alias vupv="vagrant up $@ --provider=vsphere"
alias vupl="vagrant up 2>&1 | tee vagrant.log"
alias vh="vagrant halt"
alias vs="vagrant suspend"
alias vr="vagrant resume"
alias vrl="vagrant reload"
alias vssh="vagrant ssh"
alias vsshr="vagrant ssh $1 -- -t 'sudo su -; /bin/bash'"
alias vst="vagrant status"
alias vp="vagrant provision"
alias vdstr="vagrant destroy"
# requires vagrant-list plugin
alias vl="vagrant list"
# requires vagrant-hostmanager plugin
alias vhst="vagrant hostmanager"
alias svop="source openrc.sh && source vsphere-rc.sh"
