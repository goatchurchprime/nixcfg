HOSTNAME = $(shell hostname)

NIX_FILES = $(shell find . -name '*.nix' -type f)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

switch:
	sudo nixos-rebuild switch --flake .#${HOSTNAME} -L

test:
	sudo nixos-rebuild test --flake .#${HOSTNAME} -L

update:
	nix flake update --commit-lock-file

upgrade:
	make update && make switch
