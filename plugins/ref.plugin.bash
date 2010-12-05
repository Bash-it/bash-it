#####################################################################################################################################################################
# README 																																							#
# ------ 																																							#
# 																																									#
# ref is a plugin for storing HTML formatted references, mainly suited for programming. 																			#
# Your $REF_DIR variable is the directory for storing these references in. If it does not exist, it will be created automatically. 									#
# Here is an example of what my $REF_DIR looks like, because this will be of use when I explain how your $REF_DIR has to be structured: 							#
# 																																									#
# ~/.ref/ 																																							#
#   ruby/ 																																							#
#       general/ 																																					#
#  			index.html 																																				#
# 	bash/ 																																							#
# 		array/ 																																						#
# 			index.html 																																				#
# 		select/ 																																					#
# 			index.html 																																				#
# 																																									#
# This is what the basic structure of your $REF_DIR should look like: Subdirectories for each subject, and then another set of subdirectories for the part of the   #
# subject you want to reference. And in the second subdirectory, an index.html file. 																				#
# 																																									#
# I hope that you like this plugin and if you have any questions about it, send me (mrman208) a message on GitHub or email me at mrman208@me.com 					#
#####################################################################################################################################################################

ref() {
	if [ ! -d "$REF_DIR" ]
	then
		mkdir -p "$REF_DIR"
	fi

	REF_DIR=${REF_DIR%/}

	if [ "$1" = 'ls' ]
	then
		if [ "$2" = '' ]
		then
			builtin cd "$REF_DIR"
			ls -G
			builtin cd - > /dev/null
			return
		else
			builtin cd "$REF_DIR"/"$2"
			ls -G
			builtin cd - > /dev/null
			return
		fi
	fi

	DIR="${1}/${2}"

	builtin cd "$REF_DIR"/"$DIR"

	if [ $(uname) = "Darwin" ]
	then
		open index.html
	elif [ $(uname) = "Linux" ]
	then
		gnome-open index.html
	fi
}
