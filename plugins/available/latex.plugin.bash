# shellcheck shell=bash
about-plugin 'add MacTeX to PATH'

_bash_it_plugin_latex_paths=(
	# Standard locations
	/usr/local/texbin
	# MacOS locations
	/Library/TeX/texbin
)

# add mactex to the path if its present
for _bash_it_plugin_latex_path in "${_bash_it_plugin_latex_paths[@]}"; do
	if [[ -d "$_bash_it_plugin_latex_path/" ]]; then
		pathmunge "$_bash_it_plugin_latex_path" after && break
	fi
done

# Cleanup
unset "${!_bash_it_plugin_latex_@}"
