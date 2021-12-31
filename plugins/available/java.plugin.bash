# shellcheck shell=bash
about-plugin 'Java and JAR helper functions'

function jar_manifest {
	about "extracts the specified JAR file's MANIFEST file and prints it to stdout"
	group 'java'
	param '1: JAR file to extract the MANIFEST from'
	example 'jar_manifest lib/foo.jar'

	unzip -c "${1:?${FUNCNAME[0]}: JAR file must be specified}" META-INF/MANIFEST.MF
}
