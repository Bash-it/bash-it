alias mci="mvn clean install"
alias mi="mvn install"
alias mrprep="mvn release:prepare"
alias mrperf="mvn release:perform"
alias mrrb="mvn release:rollback"
alias mdep="mvn dependency:tree"
alias mpom="mvn help:effective-pom"
alias mcisk="mci -Dmaven.test.skip=true"

function maven-help() {
  echo "Maven Custom Aliases Usage"
  echo
  echo "  mci    = mvn clean install"
  echo "  mi     = mvn install"
  echo "  mrprep = mvn release:prepare"
  echo "  mrperf = mvn release:perform"
  echo "  mrrb   = mvn release:rollback"
  echo "  mdep   = mvn dependency:tree"
  echo "  mpom   = mvn help:effective-pom"
  echo "  mcisk  = mvn clean install -Dmaven.test.skip=true"  
  echo
}
