function __gradle {
  local cur=${COMP_WORDS[COMP_CWORD]}
  local tasks=''
  local cache_dir="$HOME/.gradle/completion_cache"

  case $OSTYPE in
    darwin*)
      local checksum_command="find . -name build.gradle -print0 | xargs -0 md5 -q | md5 -q"
      ;;
    *)
      local checksum_command="find . -name build.gradle -print0 | xargs -0 md5sum | md5sum | cut -d ' ' -f 1"
      ;;
  esac
  local parsing_command="gradle --console=plain --quiet tasks | grep -v Rules | sed -nE -e 's/^([a-zA-Z]+)($| - .+)/\1/p'"

  mkdir -p "${cache_dir}"

  local gradle_files_checksum='no_cache_file'
  if [[ -f build.gradle ]]; then
    gradle_files_checksum="$(eval "${checksum_command}")"
    if [[ -f "${cache_dir}/${gradle_files_checksum}" ]]; then
      newest_gradle_file="$(find . -type f -name build.gradle -newer "${cache_dir}/${gradle_files_checksum}")"
      if [ -n "${newest_gradle_file}" ]; then
        tasks="$(eval "${parsing_command}")"
        [[ -n "${tasks}" ]] && echo "${tasks}" > "${cache_dir}/${gradle_files_checksum}"
      else
        tasks="$(cat "${cache_dir}/${gradle_files_checksum}")"
        touch "${cache_dir}/${gradle_files_checksum}"
      fi
    else
      tasks="$(eval "${parsing_command}")"
      [[ -n "${tasks}" ]] && echo "${tasks}" > "${cache_dir}/${gradle_files_checksum}"
    fi
  else
    tasks="$(eval "${parsing_command}")"
    [[ -n "${tasks}" ]] && echo "${tasks}" > "${cache_dir}/${gradle_files_checksum}"
  fi
  COMPREPLY=( $(compgen -W "${tasks}" -- "${cur}") )
}

function __clear_gradle_cache {
  local cache_dir="$HOME/.gradle/completion_cache"
  [[ -d "${cache_dir}" ]] && find "${cache_dir}" -type f -mtime +7 -exec rm -f {} \;
}

__clear_gradle_cache

complete -F __gradle gradle
complete -F __gradle gradlew
complete -F __gradle ./gradlew
