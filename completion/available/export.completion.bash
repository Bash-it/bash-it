complete -W '$(printenv | awk -F= "{print \$1}")' export
