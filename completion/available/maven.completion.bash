#!/usr/bin/env bash
# Bash Maven completion

_mvn()
{
   local cmds cur colonprefixes
   cmds="clean validate compile test package integration-test   \
      verify install deploy test-compile site generate-sources  \
      process-sources generate-resources process-resources      \
      eclipse:eclipse eclipse:add-maven-repo eclipse:clean      \
      idea:idea -DartifactId= -DgroupId= -Dmaven.test.skip=true \
      -Declipse.workspace= -DarchetypeArtifactId=               \
      netbeans-freeform:generate-netbeans-project               \
      tomcat:run tomcat:run-war tomcat:deploy jboss-as:deploy   \
      versions:display-dependency-updates                       \
      versions:display-plugin-updates dependency:analyze        \
      dependency:analyze-dep-mgt dependency:resolve             \
      dependency:sources dependency:tree release:prepare        \
      release:rollback release:perform --batch-mode"

   COMPREPLY=()
   cur=${COMP_WORDS[COMP_CWORD]}
   # Work-around bash_completion issue where bash interprets a colon
   # as a separator.
   # Work-around borrowed from the darcs work-around for the same
   # issue.
   colonprefixes=${cur%"${cur##*:}"}
   COMPREPLY=( $(compgen -W '$cmds'  -- $cur))
   local i=${#COMPREPLY[*]}
   while [ $((--i)) -ge 0 ]; do
      COMPREPLY[$i]=${COMPREPLY[$i]#"$colonprefixes"}
   done

        return 0
} &&
complete -F _mvn mvn