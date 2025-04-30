# shellcheck shell=bash
about-alias 'common git abbreviations'

# We can use this variable to make sure that we don't accidentally clash with git-zsh aliases
if _bash-it-component-item-is-enabled aliases git-omz; then
	_log_warning "The aliases from 'git' and from 'git-omz' conflict with each other; please only enable one."
	return 1
fi

alias g='git'
alias get='git'
alias got='git '

# add
alias ga='git add'
alias gall='git add -A'
alias gap='git add -p'
alias gav='git add -v'

# branch
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch -d'
alias gbD='git branch -D'
alias gbl='git branch --list'
alias gbla='git branch --list --all'
alias gblr='git branch --list --remotes'
alias gbm='git branch --move'
alias gbr='git branch --remotes'
alias gbt='git branch --track'

# for-each-ref
alias gbc='git for-each-ref --format="%(authorname) %09 %(if)%(HEAD)%(then)*%(else)%(refname:short)%(end) %09 %(creatordate)" refs/remotes/ --sort=authorname DESC' # FROM https://stackoverflow.com/a/58623139/10362396

# commit
alias gc='git commit -v'
alias gca='git commit -v -a'
alias gcaa='git commit -a --amend -C HEAD' # Add uncommitted and unstaged changes to the last commit
alias gcam='git commit -v -am'
alias gcamd='git commit --amend'
alias gc!='git commit -v --amend'
alias gca!='git commit -v -a --amend'
alias gcn!='git commit -v --amend --no-edit'
alias gcm='git commit -v -m'
alias gci='git commit --interactive'
alias gcsam='git commit -S -am'

# checkout
alias gcb='git checkout -b'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcobu='git checkout -b ${USER}/'
alias gcom='git checkout $(get_default_branch)'
alias gcpd='git checkout $(get_default_branch); git pull; git branch -D'
alias gct='git checkout --track'

# clone
alias gcl='git clone'

# clean
alias gclean='git clean -fd'

# cherry-pick
alias gcp='git cherry-pick'
alias gcpx='git cherry-pick -x'

# diff
alias gd='git diff'
alias gds='git diff --staged'
alias gdt='git difftool'

# archive
alias gexport='git archive --format zip --output'

# fetch
alias gf='git fetch --all --prune'
alias gft='git fetch --all --prune --tags'
alias gftv='git fetch --all --prune --tags --verbose'
alias gfv='git fetch --all --prune --verbose'
alias gmu='git fetch origin -v; git fetch upstream -v; git merge upstream/$(get_default_branch)'
alias gup='git fetch && git rebase'

# log
alias gg='git log --graph --pretty=format:'\''%C(bold)%h%Creset%C(magenta)%d%Creset %s %C(yellow)<%an> %C(cyan)(%cr)%Creset'\'' --abbrev-commit --date=relative'
alias ggf='git log --graph --date=short --pretty=format:'\''%C(auto)%h %Cgreen%an%Creset %Cblue%cd%Creset %C(auto)%d %s'\'''
alias ggs='gg --stat'
alias ggup='git log --branches --not --remotes --no-walk --decorate --oneline' # FROM https://stackoverflow.com/questions/39220870/in-git-list-names-of-branches-with-unpushed-commits
alias gll='git log --graph --pretty=oneline --abbrev-commit'
alias gnew='git log HEAD@{1}..HEAD@{0}' # Show commits since last pull, see http://blogs.atlassian.com/2014/10/advanced-git-aliases/
alias gwc='git whatchanged'
alias ghist='git log --pretty=format:'\''%h %ad | %s%d [%an]'\'' --graph --date=short'                                          # Use it to be fast and without color.
alias gprogress='git log --pretty=format:'\''%C(yellow)%h %Cblue%ad %Creset%s%Cgreen [%cn] %Cred%d'\'' --decorate --date=short' #Usually use "git progress" in the file .gitconfig. The new alias from Git friends will be truly welcome.

# ls-files
alias gu='git ls-files . --exclude-standard --others' # Show untracked files
alias glsut='gu'
alias glsum='git diff --name-only --diff-filter=U' # Show unmerged (conflicted) files

# gui
alias ggui='git gui'

# home
alias ghm='cd "$(git rev-parse --show-toplevel)"' # Git home
# appendage to ghm
if ! _command_exists gh; then
	alias gh='ghm'
fi

# merge
alias gm='git merge'
alias gma='git merge --abort'
alias gmc='git merge --continue'
alias gms='git merge --squash'

# mv
alias gmv='git mv'

# patch
alias gpatch='git format-patch -1'

# push
alias gp='git push'
alias gpd='git push --delete'
alias gpf='git push --force-with-lease'
alias gpff='git push --force'
alias gpo='git push origin HEAD'
alias gpom='git push origin $(get_default_branch)'
alias gpu='git push --set-upstream'
alias gpunch='git push --force-with-lease'
alias gpuo='git push --set-upstream origin'
alias gpuoc='git push --set-upstream origin $(git symbolic-ref --short HEAD)'

# pull
alias gl='git pull'
alias glp='git pull --prune'
alias glum='git pull upstream $(get_default_branch)'
alias gpl='git pull'
alias gpp='git pull && git push'
alias gpr='git pull --rebase'

# remote
alias gr='git remote'
alias gra='git remote add'
alias grv='git remote -v'

# rm
alias grm='git rm'
alias grmc='git rm --cached' # Removes the file only from the Git repository, but not from the filesystem. This is useful to undo some of the changes you made to a file before you commit it.

# rebase
alias grb='git rebase'
alias grba='git rebase --abort'
alias grbc='git rebase --continue'
alias grbm='git rebase $(get_default_branch)'
alias grbmi='git rebase $(get_default_branch) --interactive'
alias grbma='GIT_SEQUENCE_EDITOR=: git rebase $(get_default_branch) --interactive --autosquash'
alias gprom='git fetch origin $(get_default_branch) && git rebase origin/$(get_default_branch) && git update-ref refs/heads/$(get_default_branch) origin/$(get_default_branch)' # Rebase with latest remote

# reset
alias gus='git reset HEAD' # read as: 'git unstage'
alias grh='git reset'      # equivalent to: git reset HEAD
alias grh!='git reset --hard'
alias gpristine='git reset --hard && git clean -dfx'

# status
alias gs='git status'
alias gss='git status -s'

# shortlog
alias gcount='git shortlog -sn'
alias gsl='git shortlog -sn'

# show
alias gsh='git show'
alias gshn='git show --name-only'
alias gshns='git show --name-status'

# svn
alias gsd='git svn dcommit'
alias gsr='git svn rebase' # Git SVN

# stash
alias gst='git stash'
alias gstb='git stash branch'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'  # kept due to long-standing usage
alias gstpo='git stash pop' # recommended for it's symmetry with gstpu (push)

## 'stash push' introduced in git v2.13.2
alias gstpu='git stash push'
alias gstpum='git stash push -m'

## 'stash save' deprecated since git v2.16.0, alias is now push
alias gsts='git stash push'
alias gstsm='git stash push -m'

# submodules
alias gsu='git submodule update --init --recursive'

# switch
# these aliases requires git v2.23+
alias gsw='git switch'
alias gswc='git switch --create'
alias gswm='git switch $(get_default_branch)'
alias gswt='git switch --track'

# tag
alias gt='git tag'
alias gta='git tag -a'
alias gtd='git tag -d'
alias gtl='git tag -l'

case $OSTYPE in
	darwin*)
		alias gtls="git tag -l | gsort -V"
		;;
	*)
		alias gtls='git tag -l | sort -V'
		;;
esac

# functions
function gdv() {
	git diff --ignore-all-space "$@" | vim -R -
}

function get_default_branch() {
	branch=$(git symbolic-ref refs/remotes/origin/HEAD)
	${branch#refs/remotes/origin/}
}
