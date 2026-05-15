HOSTNAME := $(shell hostnamectl hostname)

init:
	ansible-playbook -i hosts/$(HOSTNAME) init.yml --ask-become-pass
