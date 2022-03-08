# shellcheck shell=bash

__truffle_completion() {
	local prev
	prev=$(_get_pword)

	case $prev in
		compile)
			COMPREPLY=(--{list,all,network,quiet})
			;;
		config)
			COMPREPLY=(--{enable,disable}-analytics get set list)
			;;
		console)
			COMPREPLY=(--{network,verbose-rpc})
			;;
		create)
			COMPREPLY=(contract migration test all)
			;;
		dashboard)
			COMPREPLY=(--{port,host,verbose})
			;;
		debug)
			COMPREPLY=(--{network,url,fetch-external,compile-{tests,all}})
			;;
		develop)
			COMPREPLY=(--log)
			;;
		exec)
			COMPREPLY=(--{network,compile})
			;;
		init)
			COMPREPLY=(--force)
			;;
		migrate)
			COMPREPLY=(--{reset,f,to,network,compile-all,verbose-rpc,{,skip-}dry-run,interactive,describe-json})
			;;
		networks)
			COMPREPLY=(--clean)
			;;
		obtain)
			COMPREPLY=(--solc)
			;;
		preserve)
			COMPREPLY=(--{ipfs,file-coin,environment,})
			;;
		unbox)
			COMPREPLY=(--force)
			;;
		test)
			COMPREPLY=(--{compile-all{,-debug},network,verbose-rpc,show-events,debug{,-global},bail,stacktrace{,-extra}})
			;;
		*)
			COMPREPLY=(build compile config console create dashboard browser db debug deploy develop exec help init install migrate networks obtain opcode preserve publish run test unbox version watch)
			;;
	esac
}

if _command_exists truffle; then
	complete -F __truffle_completion -X "!&*" truffle
fi
