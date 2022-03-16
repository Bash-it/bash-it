# shellcheck shell=bash
about-alias 'yarn package manager aliases'

_set-yarn-aliases() {
	if _command_exists yarn
	then
		# Aliases
		alias ya='yarn' # [ya]rn
		alias yain='yarn init' # [ya]rn [in]it

		alias yaad='yarn add' # [ya]rn [ad]d
		alias yaglad='yarn global add' # [ya]rn [gl]obal [ad]d
		alias yaadde='yarn add --dev' # [ya]rn [ad]d --[de]v

		alias yaup='yarn upgrade' # [ya]rn [up]grade

		alias yare='yarn remove' # [ya]rn [re]move
		alias yaglre='yarn global remove' # [ya]rn [gl]obal [re]move
		alias yarede='yarn remove --dev' # [ya]rn [re]move --[de]v

		alias yaou='yarn outdated' # [ya]rn [ou]tdated
		alias yapa='yarn pack' # [ya]rn [pa]ck
		alias yapu='yarn publish' # [ya]rn [pu]blish
		alias yaseup='yarn self-update' # [ya]rn [se]lf-[up]date

		alias yaru='yarn run' # [ya]rn [ru]n
		alias yate='yarn test' # [ya]rn [te]st
		alias yase='yarn serve' # [ya]rn [se]rve

		alias yacacl='yarn cache clean' # [ya]rn [ca]che [cl]ean
		alias yach='yarn check' # [ya]rn [ch]eck
		alias yali='yarn list' # [ya]rn [li]st
		alias yain='yarn info' # [ya]rn [in]fo
		alias yalili='yarn licenses list' # [ya]rn [li]censes [li]st

		# Aliases for backward compatibility
		alias yai='yarn init'
		alias yaa='yarn add'
		alias yaga='yarn global add'
		alias yaad='yarn add --dev'
		alias yau='yarn upgrade'
		alias yarm='yarn remove'
		alias yagrm='yarn global remove'
		alias yaod='yarn outdated'
		alias yap='yarn publish'
		alias yasu='yarn self-update'
		alias yat='yarn test'
		alias yas='yarn serve'
		alias yacc='yarn cache clean'
		alias yack='yarn check'
		alias yals='yarn list'
		alias yaloi='yarn login'
		alias yaloo='yarn logout'
	fi
}

_set-yarn-aliases
