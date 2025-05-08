# shellcheck shell=bash
about-alias 'Aliases for Terraform/OpenTofu and Terragrunt'

if _command_exists terraform; then
	alias tf='terraform'
elif _command_exists tofu; then
	alias tf='tofu'
fi

if _command_exists tf; then
	alias tfa='tf apply'
	alias tfp='tf plan'
	alias tfd='tf destroy'
	alias tfv='tf validate'
	alias tfi='tf init'
	alias tfo='tf output'
	alias tfr='tf refresh'
	alias tfw='tf workspace'
	alias tfae='tf apply -auto-approve'
	alias tfpa='tf plan -out=tfplan && tf apply tfplan'
	alias tfpaf='tf plan -out=tfplan && tf apply -auto-approve tfplan'
fi
