#####################################################################################################################################################################
# README 																																							
# ------ 																																							
# 																																									
# ref is a plugin for storing HTML formatted references, mainly suited for programming. 																			
# Your $REF_DIR variable is the directory for storing these references in. If it does not exist, it will be created automatically. 									
# Here is an example of what my $REF_DIR looks like, because this will be of use when I explain how your $REF_DIR has to be structured: 							
# 																																									
# ~/.ref/ 																																							
#   ruby/ 																																							
#       general/ 																																					
#  			index.html 																																				
# 	bash/ 																																							
# 		array/ 																																						
# 			index.html 																																				
# 		select/ 																																					
# 			index.html 																																				
# 																																									
# This is what the basic structure of your $REF_DIR should look like: Subdirectories for each subject, and then another set of subdirectories for the part of the   
# subject you want to reference. And in the second subdirectory, an index.html file. 																				
# 
# To use ref, you do the ref command followed by the sugject and the sub-subject as arguments. For instance:
# 
# ref bash array
# 
# Would open the bash/array/index.html file.
# 
# To list your references, you would do the ref ls command, optionally followed by a subject. For instance:
# 
# ref ls
# 
# Would give me:
# 
# ruby bash
# 
# And:
# 
# ref ls bash
# 
# would output:
# 
# array
# select
#####################################################################################################################################################################

ref() {
	if [ ! -d "$REF_DIR" ]
	then
		mkdir -p "$REF_DIR"
	fi

	REF_DIR=${REF_DIR%/}

	builtin cd $REF_DIR

	if [ "$1" = 'ls' ]
	then
		if [ "$2" = '' ]
		then
			ls -G
			builtin cd - > /dev/null
			return
		else
			ls -G
			builtin cd - > /dev/null
			return
		fi
	elif [ "$1" = 'new' ]
	then
		mkdir -p "$2"/"$3"
		echo You can now put the index.html file into "$REF_DIR"/"$2"/"$3"
		builtin cd - > /dev/null
		return
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
