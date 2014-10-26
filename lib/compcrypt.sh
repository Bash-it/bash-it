#!/bin/bash

# Generate encrypted archive easily

#      latest version: github.rely.io/systools/
#      contact: aaron.ounnoughene@uwaterloo.ca

# Your GPG ID
# GPG=

if [ -z $GPG ]; then echo "######################"; echo "#      FIRST USE     #"; echo "######################"; echo "Please set the variable GPG to your key id"; exit 0; fi

target=${2%/}

if [ "$1" == "-c" ] ; then
  tar -cjf $target.tar.bz2 $target && \
  gpg -r $GPG --encrypt $target.tar.bz2 && \
  rm $target.tar.bz2 && \
  rm -r $target && \
  mv $target.tar.bz2.gpg ${target%.*}.gsa
  echo "success: $target.gsa is an encrypted archive"
  exit 0
fi

if [ "$1" == "-e" ] ; then
  gpg --output ${target%.*} --decrypt $target && \
  tar -xjf ${target%.*} && \
  rm -v $target
  echo "success: ${target%.*} is a clear directory"
  exit 0
fi

echo "comprcrypt -ce /path/to/target"
echo "     -c : compress"
echo "     -e : extract"
exit 1
