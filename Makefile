HOSTNAME := $(shell hostnamectl hostname)

apply:
	ansible-playbook -i hosts ${HOSTNAME}.yml --ask-become-pass

init:
	debian_chroot=1 ansible-playbook -i hosts ${HOSTNAME}.yml --ask-become-pass
