cite 'about-alias'
about-alias 'srg alias collection'

alias prettyjson='python -mjson.tool'

alias mobileHotelinfoList.dev='export MOBILE_HOTELINFO_API_URL="http://ra-dev.lan.servicereisen.de";mobileHotelinfoList'
alias mobileHotelinfoList.stag='export MOBILE_HOTELINFO_API_URL="http://ra-staging.lan.servicereisen.de";mobileHotelinfoList'

alias mobileHotelinfoGet.dev='export MOBILE_HOTELINFO_API_URL="http://ra-dev.lan.servicereisen.de";mobileHotelinfoGet'
alias mobileHotelinfoGet.stag='export MOBILE_HOTELINFO_API_URL="http://ra-staging.lan.servicereisen.de";mobileHotelinfoGet'


function mobileHotelinfoList(){
    curl -i $MOBILE_HOTELINFO_API_URL/MobileHotelInfoInterface/api/hotelrating/list/RGFzSXN0RWluVGVzdFRva2Vu
}

function mobileHotelinfoGet(){

    if [ -n "$1" ]; then

        curl -i $MOBILE_HOTELINFO_API_URL/MobileHotelInfoInterface/api/hotelrating/RGFzSXN0RWluVGVzdFRva2Vu/$1
    else
        echo "Benötige eine ID. Siehe mobileHotelinfoList."
    fi
}
