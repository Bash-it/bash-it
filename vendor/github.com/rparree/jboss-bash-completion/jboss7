# Completions for JBoss Application Server 7 (EAP 6)
# VERSION: 0.6
# DATE: 2012-10-30
# rparree-at-edc4it-dot-com




_serverProfiles(){
    if [[ $COMP_WORDS == *standalone.sh* ]]
    then
      serverdir="../standalone/configuration/"
    else
       # assume is domain.sh
      serverdir="../domain/configuration/"
    fi
    
    for i in  ${!COMP_WORDS[*]}
    do
      if [[ "${COMP_WORDS[i]}" == "-Djboss.server.base.dir" || "${COMP_WORDS[i]}" == "-Djboss.domain.base.dir" ]]; then
        serverdir="${COMP_WORDS[i+2]}/configuration"
      fi 
      
    done
    if [ -d "${serverdir}" ]
    then
 
      IFS=$'\n' tmp="$(ls "${serverdir}" | grep xml)"
        local fls="${tmp[@]// /\ }"
      unset IFS
      COMPREPLY=( $(compgen -W "${fls} initial boot last v" -- "$cur" ))
    fi
}

_bindingAddress(){
  # from /etc/bash_completion.d/ssh
    COMPREPLY=( "${COMPREPLY[@]}" $( compgen -W \
    "0.0.0.0 $( PATH="$PATH:/sbin" ifconfig -a | \
    sed -ne 's/.*addr:\([^[:space:]]*\).*/\1/p' \
        -ne 's/.*inet[[:space:]]\{1,\}\([^[:space:]]*\).*/\1/p' )" \
    -- "$cur" ) )
}

_jboss(){
    
    local cur prev words cword
    COMPREPLY=()
    _get_comp_words_by_ref -n = cur prev words cword
  
    case $cur in
	
        -Djboss.socket.binding.port-offset=*)
            cur=${cur#*=}
            #static list of common bindings sets
            local bindings="100 200 300 400 10000 20000 30000 40000"
            COMPREPLY=( $(compgen -W "${bindings}" -- ${cur}) )
            return 0
            ;;
        -Djboss.default.jgroups.stack=*)
            cur=${cur#*=}
            #static list of standard JGroups stacks
            local stacks="udp udp-async udp-sync tcp tcp-sync"
            COMPREPLY=( $(compgen -W "${stacks}" -- ${cur}) )
            return 0
            ;;

        -Dorg.jboss.ejb3.remoting.IsLocalInterceptor.passByRef=*|-Dcom.sun.management.jmxremote.authenticate=*|-Dcom.sun.management.jmxremote.ssl=*)
            cur=${cur#*=}
            local booleans="true false"
            COMPREPLY=( $(compgen -W "${booleans}" -- ${cur}) )
            return 0
            ;;
        
        -Djboss.server.base.dir=*|-Djboss.home.dir=*|-Djboss.domain.base.dir=*)
           cur=${cur#*=}
           _filedir -d
           return 0
           ;;
         
        -Djboss.domain.master.address=*|-Djboss.bind.address*=*)
           cur=${cur#*=}
           _bindingAddress
           return 0
           ;;
        --server-config=*|-c=|--host-config=*)
	   cur=${cur#*=}
           _serverProfiles
           return 0 
     

    esac


    case $prev in
        -u)
            # a few from RFC 2365 IPv4 Local Scope ()
           local addresses="239.255.0.1 239.255.0.2 239.255.0.3"
            COMPREPLY=( $(compgen -W "${addresses}" -- ${cur}) )
            return 0
            ;;
        -b*)
            _bindingAddress
            return 0
            ;;
        -c)
            _serverProfiles
            return 0
            ;;
        *)
            ;;
    esac
    # *** from jboss5  ********************
    # *** -modulepath  -c -m  -g -l -d -p -n -B -L -C  -Djboss.platform.mbeanserver -Djboss.server.base.directory   
    # ***  -Djboss.Domain -Djboss.modcluster.proxyList  -Djboss.jvmRoute -Djboss.default.jgroups.stack -Dorg.jboss.ejb3.remoting.IsLocalInterceptor.passByRef -Djboss.platform.mbeanserver -Dcom.sun.management.jmxremote.port -Dcom.sun.management.jmxremote.ssl
    # *************************************
    
    # standard commands for standalone and domain mode
    local commandsWithoutEqualSign='-b -bmanagement -bunsecure -bpublic --admin-only -h -help -u -version -V -v'
    local commandsWithEqualSign='-P -Djboss.node.name -Djboss.home.dir -Djboss.socket.binding.port-offset -Djboss.bind.address.management -Djboss.bind.address -Djboss.bind.address.unsecure'
    
    if [[ $COMP_WORDS == *standalone.sh* ]]
    then
       commandsWithoutEqualSign="${commandsWithoutEqualSign} -c"
       commandsWithEqualSign="${commandsWithEqualSign} --server-config -Djboss.server.base.dir -c"
    else
       # assume is domain.sh
       commandsWithoutEqualSign="${commandsWithoutEqualSign} --backup  --cached-dc"
       commandsWithEqualSign="${commandsWithEqualSign} -Djboss.domain.master.address --host-config -Djboss.domain.master.port -Djboss.domain.base.dir "
    fi
     

    
    
    COMPREPLY=( $( compgen -W "$commandsWithoutEqualSign" -- "$cur" ) 
                $( compgen -W "$commandsWithEqualSign"  -S '=' -- "$cur" ) )       
    return 0

  
}
complete -o nospace -F _jboss standalone.sh
complete -o nospace -F _jboss domain.sh
