# Bash it

Bash it is a mash up of my own bash commands and scripts, other bash stuff I have found and a shameless ripoff of oh-my-zsh. :) 

From what I remember, I've incorporated things I have found from the following:

* oh-my-zsh   (http://github.com/robbyrussell/oh-my-zsh)
* Steve Losh  (http://stevelosh.com/)

Includes some autocompletion tools, theming support, aliases, custom functions, and more.

## Install

Check a clone of this repo. You can view what a sample ~/.bash\_profile looks like in template/bash\_profile.bash-template. If you wanted to use that template, make sure to make a backup of your current ~/.bash\_profile file.

<pre><code>
git clone http://github.com/revans/bash-it.git

cp ~/.bash_profile ~/.bash_profile_original
cp template/bash_profile.bash-template ~/.bash_profile
</code></pre>

## Themes

Currently, there is only 1 theme, bobby. There is a base.bash that includes various colors that can then be used to create custom themes. There is support for git in the prompt: showing what branch you're on, if you've committed locally or not, etc. I'm working on adding mercurial support as well.

## Help out!

Just like oh-my-zsh, bash it is meant for the community. If you have things to add, want to add a theme, etc. please fork this project and send me a pull request.