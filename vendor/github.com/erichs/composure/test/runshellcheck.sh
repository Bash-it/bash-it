#!/usr/bin/env sh

# run code quality metrics
echo "Testing \"code quality\" with shellcheck.net in ../composure.sh:"
datafile=shellcheck.raw
metricfile=shellcheck.out

curl -s --data-urlencode script="$(cat ../composure.sh)" \
  www.shellcheck.net/shellcheck.php > $datafile
cat $datafile | python -mjson.tool > $metricfile
rm $datafile
cat $metricfile

# check for shellcheck.net errors
cat $metricfile | grep -q error
if [ $? -eq 0 ]; then
  echo "! shellcheck.net:../composure.sh:0  [ errors ]  FAILED"
  rm $metricfile
  exit 2
fi

# check for shellcheck.net warnings
cat $metricfile | grep -q warning
if [ $? -eq 0 ]; then
  echo "! shellcheck.net:../composure.sh:0  [ warnings ]  FAILED"
  rm $metricfile
  exit 2
fi

echo "! shellcheck.net:../composure.sh:0 [ no errors or warnings ] ok"
rm $metricfile
