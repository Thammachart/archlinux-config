HOSTNAME := $(shell hostnamectl hostname)

init:
	ansible-playbook -i hosts ${HOSTNAME}.yml --ask-become-pass
