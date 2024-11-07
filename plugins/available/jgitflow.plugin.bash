# shellcheck shell=bash
# shellcheck disable=SC2086
cite about-plugin
about-plugin 'Maven jgitflow build helpers'

function pre-jgitflow {
	about 'helper function for execute before jgitflow'
	group 'jgitflow'
}

function test-pre-jgitflow {
	about 'helper function for starting a new hotfix'
	group 'jgitflow'

	echo "Init pre-maven" && pre-jgitflow && echo "Finish pre-maven"
}

function hotfix-start {
	about 'helper function for starting a new hotfix'
	group 'jgitflow'

	pre-jgitflow && mvn jgitflow:hotfix-start ${JGITFLOW_MVN_ARGUMENTS}
}

function hotfix-finish {
	about 'helper function for finishing a hotfix'
	group 'jgitflow'

	pre-jgitflow && mvn jgitflow:hotfix-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags && mvn clean
}

function feature-start {
	about 'helper function for starting a new feature'
	group 'jgitflow'

	pre-jgitflow && mvn jgitflow:feature-start ${JGITFLOW_MVN_ARGUMENTS}
}

function feature-finish {
	about 'helper function for finishing a feature'
	group 'jgitflow'

	pre-jgitflow && mvn jgitflow:feature-finish ${JGITFLOW_MVN_ARGUMENTS} && mvn clean
	echo -e '\033[32m----------------------------------------------------------------\033[0m'
	echo -e '\033[32m===== REMEMBER TO CREATE A NEW RELEASE TO DEPLOY THIS FEATURE ====\033[0m'
	echo -e '\033[32m----------------------------------------------------------------\033[0m'
}

function release-start {
	about 'helper function for starting a new release'
	group 'jgitflow'

	pre-jgitflow && mvn jgitflow:release-start ${JGITFLOW_MVN_ARGUMENTS}
}

function release-finish {
	about 'helper function for finishing a release'
	group 'jgitflow'

	pre-jgitflow && mvn jgitflow:release-finish -Darguments="${JGITFLOW_MVN_ARGUMENTS}" && git push && git push origin master && git push --tags && mvn clean
}
