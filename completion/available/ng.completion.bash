# shellcheck shell=bash
if _command_exists ng; then
	# No longer supported, please see https://github.com/angular/angular-cli/issues/11043
	# Fix courtesy of https://stackoverflow.com/questions/50194674/ng-completion-no-longer-exists
	# . <(ng completion --bash)

	NG_COMMANDS="add build config doc e2e generate help lint new run serve test update version xi18n"
	complete -W "$NG_COMMANDS" ng
fi
