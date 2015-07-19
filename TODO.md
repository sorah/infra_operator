## backends

- [ ] base
- [ ] cmd
- [ ] docker
- [ ] dockerfile
- [x] exec
- [x] native
- [ ] lxc
- [ ] powershell
- [ ] shell_script
- [ ] ssh
- [ ] telnet
- [ ] winrm

## providers

- [ ] file:
  - [ ] native (ruby)
- [ ] cron:
- [ ] bond:
- [ ] bridge:
- [ ] user:
  - [ ] native (ruby)
- [ ] group:
  - [ ] native (ruby)
- [ ] service:
  - [ ] sysv
  - [ ] upstart
  - [ ] systemd
  - [ ] openrc
- [ ] package:
- [ ] firewall:
  - [ ] iptables, ip6tables
  - [ ] ipfilter
  - [ ] ipfw
- [ ] route:
- [ ] process:
- [ ] port:
- [ ] network_interfaces:
- [ ] host:
- [ ] mount:

----

misc

- [ ] ipnat
- [ ] selinux
- [ ] selinux_module
- [ ] zfs
- [ ] yumrepo
- [ ] ppa
- [ ] mail_alias
- [ ] lxc_container
- [ ] localhost (?)
- [ ] kernel_module
- [ ] fstab

## platform

- [ ] linux
  - [ ] alpine
  - [ ] arch
  - [ ] coreos
  - [ ] cumulus
  - [ ] debian
    - [ ] upstart
    - [ ] systemd
    - [ ] ubuntu
      - [ ] upstart
      - [ ] systemd
  - [ ] suse
  - [ ] opensuse
  - [ ] redhat
    - [ ] centos
    - [ ] amazon
    - [ ] v5
    - [ ] v7
  - [ ] fedora
    - [ ] sysv
    - [ ] systemd
  - [ ] gentoo
    - [ ] sysv
    - [ ] systemd
  - [ ] plamo
  - [ ] nixos
- [ ] bsd
  - [ ] freebsd
    - [ ] v10
    - [ ] v6
  - [ ] darwin
    - [ ] osx
  - [ ] openbsd
- [ ] solaris
  - [ ] smartos
- [ ] windows
- [ ] aix
- [ ] esxi

## environment

- [ ] amazon ec2
- [ ] google compute engine
- [ ] azure vm
- [ ] xen
- [ ] lxc
- [ ] docker
- [ ] vmware
- [ ] kvm
- [ ] baremetal

## inventory

- [ ] base
- [ ] cpu
- [ ] domain
- [ ] ec2
- [ ] filesystem
- [ ] fqdn
- [ ] hostname
- [ ] kernel
- [ ] memory
- [ ] platform
- [ ] platform_version
- [ ] virtualization

## misc

- [ ] config
  - [ ] pre_command
  - [ ] shell
  - [ ] path
- [ ] stdout_handler, stderr_handler
