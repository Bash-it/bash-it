cite about-plugin _about _param _group
about-plugin "Manages your personal bash-it configuration"

BASH_IT_CONFIG_PATH="${BASH_IT}/.config"
GIT="/usr/bin/env git"

_config-read-git-url()
{
  _about "reads a Git repo URL/path from stdin"
  _group "config"
  while true; do
    read -e -p "Enter URL/path of git repository for config: " GIT_URL
    [[ -n ${GIT_URL} ]] && break; 
  done
  echo ${GIT_URL}
}

_config-write()
{
  _about "writes a config file"
  _param "1: config file to write to"
  _param "2..: array of things to write to config file"
  _group "config"
  local THING=${1}
  shift  
  printf "%s\n" $@ > ${THING}
}

_config-make-config-file()
{
  local CWD=`pwd`
  _about "builds & writes a config file"
  _param "1: source directory, presumably full of symlinks"
  _param "2: destination config file"
  _group "config"
  local SOURCE_DIR=$1
  local DEST_FILE=$2
  local -a FILES=()
  for FILE in "${BASH_IT}/${SOURCE_DIR}/enabled/*.bash"; do
    FILES=(${FILES[@]} `basename -s .bash ${FILE}`);
  done
  [[ ${#FILES[@]} -gt 0 ]] && {
     _config-write "${DEST_FILE}" "${FILES[@]}"
    cd "${BASH_IT_CONFIG_PATH}"
    ${GIT} add "${DEST_FILE}"
    cd ${CWD}
  } 
}

_config-load-config-file()
{
  _about "loads a config file and creates symlinks"
  _param "1: source config file"
  _param "2: destination directory"
  _group "config"
  local SOURCE_FILE=$1
  local DEST_DIR=$2
  [[ -e ${SOURCE_FILE} && -d ${DEST_DIR} ]] && {
    for FILE in `find "${DEST_DIR}/enabled" -type l`; do
      rm -f "${FILE}"
    done
    for FILE in `cat ${SOURCE_FILE}`; do
      bash-it enable `basename ${SOURCE_FILE}` ${FILE} 2>&1>/dev/null
    done    
  }
}

save-bash-it () 
{
  local CWD=`pwd`
  about "saves current bash-it configuration to source control"
  group "config"
  local CUSTOM_PATH="${BASH_IT_CONFIG_PATH}/custom"
  ${GIT} init "${BASH_IT_CONFIG_PATH}" 2>&1 > /dev/null
  _config-make-config-file "aliases" "${BASH_IT_CONFIG_PATH}/aliases"
  _config-make-config-file "plugins" "${BASH_IT_CONFIG_PATH}/plugins"
  _config-make-config-file "completion" "${BASH_IT_CONFIG_PATH}/completion"
  mkdir -p "${CUSTOM_PATH}" 
  
  [[ ! -L ${BASH_IT}/custom && `ls -A "${BASH_IT}/custom/"` ]] && {
    cp -Hf "${BASH_IT}/"custom/* "${CUSTOM_PATH}/" && \
      rm -rf "${BASH_IT}/custom" && \
      ln -sf "${CUSTOM_PATH}" "${BASH_IT}/custom"
  }
  
  [[ -e ${HOME}/.bash_profile ]] && {
      cp -Hf "${HOME}/.bash_profile" "${BASH_IT_CONFIG_PATH}/bash_profile" 2>/dev/null && \
        rm -f "${HOME}/.bash_profile" && \
        ln -sf "${BASH_IT_CONFIG_PATH}/bash_profile" "${HOME}/.bash_profile"  
  }
  
  cd "${BASH_IT_CONFIG_PATH}"
  ${GIT} add ${BASH_IT_CONFIG_PATH}/bash_profile
  cd "${CUSTOM_PATH}"
  ${GIT} add .  
  [[ -z `git remote` ]] && {
    local ORIGIN=`_config-read-git-url`    
    ${GIT} remote add origin "${ORIGIN}"    
  }
  commit-bash-it
  pull-bash-it
  push-bash-it
  cd ${CWD}
}

commit-bash-it() 
{
  local CWD=`pwd`
  about "commits current bash-it configuration to source control"
  group "config"
  cd ${BASH_IT_CONFIG_PATH} 
  ${GIT} commit -m "Updates $@"
  cd ${CWD}
}

push-bash-it()
{
  local CWD=`pwd`
  about "pushes current bash-it configuration to remote origin"
  group "config"
  cd ${BASH_IT_CONFIG_PATH}
  ${GIT} push origin master
  cd ${CWD}
}

pull-bash-it()
{
  local CWD=`pwd`
  about "pulls (+ rebases) bash-it configuration from remote origin"
  group "config"
  if [[ ! -d ${BASH_IT_CONFIG_PATH} ]]; then
    local ORIGIN=`_config-read-git-url`
    ${GIT} clone ${ORIGIN} ${BASH_IT_CONFIG_PATH}
  fi
  cd ${BASH_IT_CONFIG_PATH}
  ${GIT} pull --rebase origin master 
  cd ${CWD}
}

update-bash-it()
{
  about "pulls bash-it configuration from remote origin and loads it"
  group "config"
  pull-bash-it
  load-bash-it
}

load-bash-it ()
{
  about "loads stored bash-it configuration; creates symlinks"
  group "config"
  _config-load-config-file "${BASH_IT_CONFIG_PATH}/aliases" "${BASH_IT}/aliases"
  _config-load-config-file "${BASH_IT_CONFIG_PATH}/plugins" "${BASH_IT}/plugins"
  _config-load-config-file "${BASH_IT_CONFIG_PATH}/completion" "${BASH_IT}/completion"
  
  [[ -d ${BASH_IT_CONFIG_PATH}/custom ]] && {
    # TODO maybe a backup here
    [[ ! -L ${BASH_IT}/custom && -d ${BASH_IT}/custom ]] && rm -rf "${BASH_IT}/custom"
    ln -sf "${BASH_IT_CONFIG_PATH}/custom" "${BASH_IT}/"
  }

  [[ ! -L ${HOME}/.bash_profile ]] && {
    # TODO here too
    rm "${HOME}/.bash_profile"
    ln -sf "${BASH_IT_CONFIG_PATH}/bash_profile" "${HOME}/.bash_profile"
  }
}
