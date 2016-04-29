#!/bin/bash
cite about-plugin
about-plugin 'web_search from terminal'

RED=`tput setaf 1`
YELLOW=`tput setaf 3`

web_search(){
    declare -A urls
    urls=(
        [google]="https://www.google.com/search?q="
        [bing]="https://www.bing.com/search?q="
        [yahoo]="https://search.yahoo.com/search?p="
        [duckduckgo]="https://www.duckduckgo.com/?q="
        [yandex]="https://yandex.ru/yandsearch?text="
        [github]="https://github.com/search?q="
        [baidu]="https://www.baidu.com/s?wd="
    )
    args=( ${@} )

    if [ $# -eq 0 ] || [ -z ${urls[$1]} ];then
        echo ${RED}"Not a valid search engine !!"
        return 1
    fi

    if [ $# -gt 1 ];then 
        url="${urls[$1]}""${args[@]:1}"
        
    else
        echo ${YELLOW}"Search term missing!!"
        return 1
    fi
    xdg-open "$url" > /dev/null 2>&1
}

alias google='web_search google'
alias bing='web_search bing'
alias duckduckgo='web_search duckduckgo'
alias yahoo='web_search yahoo'
alias yandex='web_search yandex'
alias github='web_search github'
alias baidu='web_search baidu'

#duckduckgo !hacks 
alias wiki='web_search duckduckgo \!w'
alias news='web_search duckduckgo \!n'
alias youtube='web_search duckduckgo \!yt'
alias map='web_search duckduckgo \!m'
alias image='web_search duckduckgo \!i'
alias ducky='web_search duckduckgo \!'
alias twitter='web_search duckduckgo \!twitter'
alias amazon='web_search duckduckgo \!a'
alias torrent='web_search duckduckgo \!tpb'
