#!/bin/sh
# -vvv  : Verbose mode
# -C    : Debug mode

ansible-playbook $(dirname $0)/../playbook/site.yml -i $(dirname $0)/../playbook/inv -u root $@
