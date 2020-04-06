
# . <(ng completion --bash)  obselete

NG_COMMANDS="add build config doc e2e generate help lint new run serve test update version xi18n"
complete -W "$NG_COMMANDS" ng
