cite about-plugin
about-plugin 'Downloads the latest .gitignore file by project type'

function gittowork() {
	about 'Places the latest .gitignore file for a given project type in the current directory, or concatenates onto an existing .gitignore'
	group 'git'

	result=$(curl -L "Https://www.gitignore.io/api/$1" 2>/dev/null)

	if [[ $result =~ ERROR ]]; then
		echo "Query '$1' has no match. See a list of possible queries with 'GitToWork List'"
	elif [[ $1 = list ]]; then
		echo "$result"
	else
		if [[ -f .gitignore ]]; then
			result=`echo "$result" | grep -v "# Created by http://www.gitignore.io"`
			echo ".gitignore already exists, appending..."
			echo "$result" >> .gitignore
		else
			echo "$result" > .gitignore
		fi
	fi
}
