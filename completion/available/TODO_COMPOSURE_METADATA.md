# TODO: Completions Needing Composure Metadata

The following completion files need `cite "about-completion"` and `about-completion` metadata added.
Please add appropriate descriptions following this format:

```bash
cite "about-completion"
about-completion "tool-name - brief description of what the tool does"
group "category"  # optional: python, ruby, javascript, deployment, etc.
```

## Completions Without Metadata

- **awless** - TODO: Research AWS CLI alternative tool
- **crystal** - TODO: Crystal programming language
- **defaults** - TODO: macOS defaults command-line utility
- **dmidecode** - TODO: DMI table decoder for system hardware information
- **drush** - TODO: Drupal shell command-line tool
- **export** - Deprecated (covered by system completion)
- **git_flow** - TODO: Git branching model helpers
- **git_flow_avh** - TODO: AVH Edition of git-flow
- **homesick** - TODO: Dotfiles management tool
- **kind** - TODO: Kubernetes IN Docker tool
- **knife** - TODO: Chef configuration management tool
- **kontena** - TODO: Container orchestration platform
- **makefile** - TODO: GNU Make build automation
- **minishift** - TODO: Local OpenShift cluster tool
- **ngrok** - TODO: Secure tunneling to localhost
- **notify-send** - TODO: Desktop notification tool
- **openshift** - TODO: Red Hat's Kubernetes platform
- **pew** - TODO: Python environment wrapper
- **pipx** - TODO: Python application installer in isolated environments
- **projects** - TODO: Bash-it project management
- **salt** - TODO: SaltStack configuration management
- **sdkman** - TODO: Software Development Kit Manager
- **sqlmap** - TODO: SQL injection and database takeover tool
- **system** - TODO: System-level bash completions
- **test_kitchen** - TODO: Infrastructure testing framework
- **todo** - TODO: todo.txt-cli task management
- **travis** - TODO: Travis CI command-line client
- **virsh** - TODO: Virtualization shell for libvirt
- **vuejs** - TODO: Vue.js JavaScript framework CLI
- **wpscan** - TODO: WordPress security scanner

## Guidelines

1. Keep descriptions concise (one line)
2. Focus on what the tool does, not "tab completion for..."
3. Add `group` field when the category is clear (e.g., python, javascript, deployment)
4. Research unfamiliar tools before adding metadata
