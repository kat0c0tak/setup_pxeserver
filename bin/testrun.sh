#!/bin/sh
# -vvv  : Verbose mode
# -C    : Debug mode

ansible-playbook $(dirname $0)../ansible/site.yml -c local -i 127.0.0.1, -vvv -C $@
