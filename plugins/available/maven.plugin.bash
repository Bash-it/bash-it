cite about-plugin
about-plugin 'maven helper functions'

usemvn ()
{
	local MAVEN_INSTALL_ROOT="/usr/local"
	
    if [ -z "$1" -o ! -x "$MAVEN_INSTALL_ROOT/apache-maven-$1/bin/mvn" ]
    then
        local prefix="Syntax: usemvn "
        for i in $MAVEN_INSTALL_ROOT/apache-maven-*
        do
            if [ -x "$i/bin/mvn" ]; then
                echo -n "$prefix$(basename $i | sed 's/^apache-maven-//')"
                prefix=" | "
            fi
        done
        echo ""
    else
        if [ -z "$MAVEN_HOME" ]
        then
            export PATH=$MAVEN_INSTALL_ROOT/apache-maven-$1/bin:$PATH
        else
            export PATH=$(echo $PATH|sed -e "s:$MAVEN_HOME/bin:$MAVEN_INSTALL_ROOT/apache-maven-$1/bin:g")
        fi
        export MAVEN_HOME=$MAVEN_INSTALL_ROOT/apache-maven-$1
    fi
}