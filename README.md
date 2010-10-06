# Bash it

'Bash it' is a mash up of my own bash commands and scripts, other bash stuff I have found and a shameless ripoff of oh-my-zsh. :) 

From what I remember, I've incorporated things I have found from the following:

* oh-my-zsh   (http://github.com/robbyrussell/oh-my-zsh)
* Steve Losh  (http://stevelosh.com/)

Includes some autocompletion tools, theming support, aliases, custom functions, and more.

## Install

Check a clone of this repo. You can view what a sample ~/.bash\_profile looks like in template/bash\_profile.template.bash. If you wanted to use that template, make sure to make a backup of your current ~/.bash\_profile file.

<pre><code>
git clone http://github.com/revans/bash-it.git bash_it

cp ~/.bash_profile ~/.bash_profile_original
cp <path/to/cloned/repo>/template/bash_profile.template.bash ~/.bash_profile

</code></pre>

I'm working on adding various custom help screens to bash it. Currently, bash it has the following commands to show help screens:

<pre><code>
bash-it (will show all the help commands)
aliases-help
rails-help
git-help
</code></pre>


## Themes

Currently, there is only 1 theme, 'bobby'. There is a base.theme.bash that includes various colors that can then be used to create custom themes. There is support for git in the prompt: showing what branch you're on, if you've committed locally or not, etc. I'm working on adding mercurial support as well.

## Help out!

Just like oh-my-zsh, 'bash it' is meant for the community. If you have things to add, want to add a theme, etc. please fork this project and send me a pull request.