cite about-plugin
about-plugin 'traverse parent directories with ease. inspired by a script from tyskby'

cdup() {
  about 'moves n directories up'
  param '1: n periods'
  example '$ cdup .....'
  group 'cdup'

  if [[ $1 =~ .{2,} ]]; then
    local count

    count=${1:1}

    for ((i=1; i<=${#count}; i++)); do
      cd ..
    done

    pwd
  fi
}

