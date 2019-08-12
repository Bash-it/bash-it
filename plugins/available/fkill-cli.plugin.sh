#!/bin/bash
cite about-plugin 
about-plugin 'Fabulously kill processes in intractive way using fuzzy finder'


function fkill(){
if [[ `which fzf` ]]
	then
		fuzzy_command=fzf
elif [[ `which fzy` ]]
	then
		fuzzy_command=fzy
	else
	fuzzy_command=""
fi
if [[ ! -z $fuzzy_command ]]
	then
		process=`ps -A | awk '{print $1 "\t" $4}' | $fuzzy_command --prompt=Running\ processes:  | awk '{print $1}'`
		if [[ ! -z $process ]] 
			then
				process_name=`ps -p $process -o comm=`
				kill -9 $process
				echo ""
				echo -e ${echo_bold_green} ✔${echo_bold_yellow} Process $process_name [ id = $process ] were killed successfully${echo_normal}
			else
				:
		fi
		else
		echo ""
		echo -e ${echo_bold_red} ✘${echo_bold_yellow} You Dont have a fuzzy finder command in your path please download one${echo_normal}
		
fi

}
