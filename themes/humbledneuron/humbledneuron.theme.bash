#!/usr/bin/env bash

# Emoji-based theme to display source control management and
# virtual environment info beside the ordinary bash prompt.


# Demo:
# ┌ⓔ virtualenv 🐲🤘user @ 💻 host in 🗂️ directory on 🌵 branch {1} ↑1 ↓1 +1 •1 ⌀1 ✗
# └❯ cd .bash-it/themes/cupcake

# virtualenv prompts
VIRTUALENV_CHAR="ⓔ "
VIRTUALENV_THEME_PROMPT_PREFIX=""
VIRTUALENV_THEME_PROMPT_SUFFIX=""

# SCM prompts
SCM_NONE_CHAR=""
SCM_GIT_CHAR="[±] "
SCM_GIT_BEHIND_CHAR="${red}↓${normal}"
SCM_GIT_AHEAD_CHAR="${bold_green}↑${normal}"
SCM_GIT_UNTRACKED_CHAR="⌀"
SCM_GIT_UNSTAGED_CHAR="${bold_yellow}•${normal}"
SCM_GIT_STAGED_CHAR="${bold_green}+${normal}"

SCM_THEME_PROMPT_DIRTY=""
SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

# Git status prompts
GIT_THEME_PROMPT_DIRTY=" ${red}✗${normal}"
GIT_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
GIT_THEME_PROMPT_PREFIX=""
GIT_THEME_PROMPT_SUFFIX=""



# # SCM
# SCM_GIT_CHAR_GITLAB=${GITLAB_CHAR:='  '}
# SCM_GIT_CHAR_BITBUCKET=${BITBUCKET_CHAR:='  '}
# SCM_GIT_CHAR_GITHUB=${GITHUB_CHAR:='  '}
# SCM_GIT_CHAR_DEFAULT=${GIT_DEFAULT_CHAR:='  '}
# SCM_GIT_CHAR_ICON_BRANCH=${GIT_BRANCH_ICON:=''}
# SCM_HG_CHAR=${HG_CHAR:='☿ '}
# SCM_SVN_CHAR=${SVN_CHAR:='⑆ '}
# # Exit code
# EXIT_CODE_ICON=${EXIT_CODE_ICON:=' '}
# # Programming and tools
# PYTHON_VENV_CHAR=${PYTHON_VENV_CHAR:=' '}
# RUBY_CHAR=${RUBY_CHAR:=' '}
# NODE_CHAR=${NODE_CHAR:=' '}
# TERRAFORM_CHAR=${TERRAFORM_CHAR:="❲t❳ "}
# # Cloud
# AWS_PROFILE_CHAR=${AWS_PROFILE_CHAR:=" aws "}
# SCALEWAY_PROFILE_CHAR=${SCALEWAY_PROFILE_CHAR:=" scw "}
# GCLOUD_CHAR=${GCLOUD_CHAR:=" google "}

# ICONS =======================================================================

ICON_GIT=" "                    # Git icon
ICON_YAML="📝 "                   # YAML icon
ICON_PACKAGE_JSON="📦 "           #{} package.json icon
ICON_GITHUB=" "                  # GitHub icon
ICON_EXECUTABLE="🚀 "              # Executable icon
ICON_TIME="⏰ "                    # Time icon
ICON_PENGUIN="🐧"                  # Penguin icon
ICON_LAPTOP="💻"                   # Laptop icon
ICON_TREE="🌲"                     # Tree icon
ICON_DEFAULT_FOLDER="📁"           # Default folder icon
ICON_GITLAB=" "                   # GitLab icon
ICON_DOCKER="🐳 "                   # Docker icon
ICON_BASH="⌨️ "
ICON_PYTHON="🐍"
ICON_PHP="🐘️ "
ICON_ANGULAR="🅰 "
ICON_REACT="⚛ "
ICON_NODE="⬢ "
ICON_PYTORCH="🔥 "
ICON_CSS="✂️ "

#ICON_=""

# ICONS =======================================================================

icon_start="┌"
icon_user="${ICON_PENGUIN}"
icon_host="${ICON_LAPTOP}" #"@${ICON_LAPTOP} "
icon_directory="-${ICON_TREE}"
icon_branch="${ICON_BRANCH}"
icon_end="└${ICON_EXECUTABLE}❯ "

# extra spaces ensure legibility in prompt

# FUNCTIONS ===================================================================

# Display virtual environment info
function virtualenv_prompt {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    virtualenv=$(basename "$VIRTUAL_ENV")
    echo -e "${VIRTUALENV_CHAR}${virtualenv} "
  fi
}

# Rename tab
function tabname {
  printf "\e]1;$1\a"
}

# Rename window
function winname {
  printf "\e]2;$1\a"
}

# PROMPT OUTPUT ===============================================================

# Displays the current prompt
function prompt_command() {
  #v 1.0
  # PS1="\n${icon_start}${bold_yellow}$(date +"%H:%M:%S") ${ICON_TIME}${normal}${icon_user}${bold_green}\u${normal}${icon_host}${bold_cyan}\h${normal}${icon_directory}${bold_purple}\W${normal}\$([[ -n \$(git branch 2> /dev/null) ]] && echo \"${icon_branch}  \")${white}$(scm_prompt_info)${normal}\n${icon_end}"
 #v 2.0
  # fave # PS1="${icon_start}${ICON_TIME}${bold_yellow}$(date +"%H:%M:%S") ${normal}${icon_user}${bold_green}\u${normal}${icon_host}${bold_cyan}\h${normal}${icon_directory}${bold_purple}\W${normal}\$([[ -n \$(git branch 2> /dev/null) ]] && echo \"${icon_branch}  \")${yellow}$(scm_prompt_info)${normal}\n${icon_end}"
  
  # PS3="${icon_end}"
    #v 3.0
  PS1="${icon_start}${ICON_TIME}${bold_yellow}$(date +"%H:%M:%S") ${normal}${icon_user}${bold_green}\u${normal}${icon_host}${bold_cyan}\h${normal}${icon_directory}${bold_purple}\W${normal}"

  # Check for specific configuration files and add icons accordingly
  if [ -e ".git" ]; then
      # PS1+=" "  # GitHub icon
      PS1+=${ICON_GIT}
  fi

#update 1.0  
#  if git remote -v | grep -q 'github.com'; then
#      #PS1+=" "  # GitHub icon
#      PS1+=${ICON_GITHUB}
#  elif git remote -v | grep -q 'gitlab.com'; then
#      #PS1+=" "  # GitLab icon
#      PS1+=${ICON_GITLAB}
#  fi
#fixed because it causes error after opening the terminal
#update 2.0
## Execute git remote -v and store the result in a variable
#remote_url=$(git remote -v)

# Check if the remote URL contains 'github.com' or 'gitlab.com'
#  if echo "$remote_url" | grep -q 'github.com'; then
#     PS1+=${ICON_GITHUB}
#  elif echo "$remote_url" | grep -q 'gitlab.com'; then
#     PS1+=${ICON_GITLAB}
#  fi
#fixed bcoz of same error in 2.0 like 1.0

#update 3.0
# Execute git remote -v and store the result in a variable
  remote_url=$(git remote -v 2>/dev/null)

# Check if the remote URL contains 'github.com' or 'gitlab.com'
  if echo "$remote_url" | grep -q 'github.com'; then
      PS1+=${ICON_GITHUB}
  elif echo "$remote_url" | grep -q 'gitlab.com'; then
      PS1+=${ICON_GITLAB}
  fi 
 
  if [ -e ".gitlab-ci.yml" ]; then
      PS1+=${ICON_GITLAB}
  fi

  if [ -e ".dockerignore" ] || [ -e "Dockerfile" ]; then
        PS1+=${ICON_DOCKER}
  fi

  if [ -e "package.json" ]; then
      #PS1+=" "  # npm icon
      PS1+=${ICON_PACKAGE_JSON}
  fi

  if [ -e "yarn.lock" ]; then
      PS1+=" "  # npm icon
  fi

  if [ -e "Gemfile" ]; then
      PS1+="💎 "  # Ruby icon
  fi

  if [ -e "Pipfile" ]; then
      PS1+=${ICON_PYTHON} 
  fi

  # Check for programming language files and add icons accordingly
  if ls *.py &>/dev/null; then
      PS1+=${ICON_PYTHON}
  fi

  if ls *.js &>/dev/null; then
      PS1+="⚛️ "  # JavaScript icon
  fi

  if ls *.rb &>/dev/null; then
      PS1+="💎 "  # Ruby icon
  fi

  if ls *.java &>/dev/null; then
      PS1+="☕ "  # Java icon
  fi

  if ls *.php &>/dev/null; then
      PS1+=${ICON_PHP}  # PHP icon
  fi

  if [ -n "$(ls *.sh 2>/dev/null)" ] || [ -n "$(ls *.bash 2>/dev/null)" ]; then
      PS1+="${ICON_BASH}"
  fi
  
  if ls *.css &>/dev/null; then
      PS1+=${ICON_CSS}  # CSS icon
  fi

#simplified [[ -f *.css ]] && PS1+=" "
  
  if ls *.html &>/dev/null; then
      PS1+=" "  # HTML icon
  fi

  # Check for Python framework directories and add icons accordingly
  if [ -d "django" ]; then
      PS1+=" "  # Django icon
  fi

  if [ -d "flask" ]; then
      PS1+=" "  # Flask icon
  fi

  # Check for Python-based AI framework directories and add icons accordingly
  if [ -d "tensorflow" ]; then
      PS1+="🧠 "  # TensorFlow icon
  fi

  if [ -d "pytorch" ]; then
      PS1+=${ICON_PYTORCH}  # PyTorch icon
  fi

  if [ -d "keras" ]; then
      PS1+="🧠 "  # Keras icon
  fi

  # Check for JavaScript framework directories and add icons accordingly
  if [ -d "node_modules" ]; then
      PS1+=${ICON_NODE}  # Node.js icon
  fi

  if [ -d "angular" ]; then
      PS1+=${ICON_ANGULAR}  # Angular icon
  fi

  if [ -d "react" ]; then
      PS1+=${ICON_REACT}  # React icon
  fi

#  if [ -d "Youtube" ]; then
#      PS1+=" "  # Angular icon
#  fi
  # Add more checks for frameworks and icons as needed

  PS1+="\$([[ -n \$(git branch 2> /dev/null) ]] && echo \"${icon_branch}  \")${yellow}$(scm_prompt_info)${normal}\n${icon_end}"

}

# Runs prompt (this bypasses bash_it $PROMPT setting)
safe_append_prompt_command prompt_command
