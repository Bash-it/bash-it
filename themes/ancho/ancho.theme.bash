LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arc=01;31:*.arj=01;31:*.taz=01;31:*.lha=01;31:*.lz4=01;31:*.lzh=01;31:*.lzma=01;31:*.tlz=01;31:*.txz=01;31:*.tzo=01;31:*.t7z=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.lrz=01;31:*.lz=01;31:*.lzo=01;31:*.xz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.war=01;31:*.ear=01;31:*.sar=01;31:*.rar=01;31:*.alz=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.cab=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.svgz=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.webm=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.flv=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.cgm=01;35:*.emf=01;35:*.axv=01;35:*.anx=01;35:*.ogv=01;35:*.ogx=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS

function prompt(){

  SCM_THEME_PROMPT_DIRTY=" ${red}✗${normal}"
  SCM_THEME_PROMPT_CLEAN=" ${bold_green}✓${normal}"
  SCM_THEME_PROMPT_PREFIX="${prompt_obracket}"
  SCM_THEME_PROMPT_SUFFIX="${prompt_cbracket}"
  SCM_THEME_BRANCH_PREFIX="$bold_blue"

  SCM_GIT_UNTRACKED_CHAR="${red}?:${normal}"
  SCM_GIT_UNSTAGED_CHAR="${yellow}U:${normal}"
  SCM_GIT_STAGED_CHAR="${green}S:${normal}"
  SCM_GIT_AHEAD_CHAR="${bold_green}↑${normal}"
  SCM_GIT_BEHIND_CHAR="${bold_red}↓${normal}"
  
  determine_user_color
  
  prompt_obracket="${bracket_color}[${normal}"
  prompt_cbracket="${bracket_color}]${normal}"
  prompt_home="${prompt_obracket}$green\h${prompt_cbracket}"
  prompt_user="${prompt_obracket}${user_color}\u${prompt_cbracket}"
  prompt_cpwd="${prompt_obracket} $purple\w ${prompt_cbracket}"
  prompt_prefix="${line_color}┌${normal}"
  prompt_iline="${line_color}└✪ ${normal}"
  prompt_scm="$(scm_prompt_info)"

  prompt_scmline

  PS1="${prompt_prefix}${prompt_user}${prompt_home}${prompt_cpwd}${prompt_scm_line}\n$prompt_iline"
}

function determine_user_color(){

  if [ "$USER" = "root" ]; then
    user_color=${bold_red}
    bracket_color=${bold_yellow}
    line_color=${bold_yellow}
  else
    user_color=${bold_green}
    bracket_color=${bold_cyan}
    line_color=${bold_cyan}
  fi
}


function prompt_scmline(){
  scm
  scm_prompt_char
  if [ -n "$prompt_scm" ]; then
    prompt_scm_line_pre="$line_color├${prompt_obracket}${SCM_CHAR}${prompt_cbracket}"
    prompt_scm_line="\n${prompt_scm_line_pre}${prompt_scm}"
  else
    prompt_scm_line=""
  fi
}

PROMPT_COMMAND='prompt'
