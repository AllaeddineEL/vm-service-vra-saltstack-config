#cloud-config
ssh_pwauth: True
chpasswd:
  list: |
    centos:VMware1!
  expire: false
users:
  - name: centos
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    shell: /bin/bash
network:
  version: 2
  ethernets:
    ens192:
      dhcp4: true
yum_repos:
  salt-py3-repo:
    baseurl: https://repo.saltstack.com/py3/redhat/8/$basearch/latest
    name: SaltStack Latest Release Channel Python 3 for RHEL/Centos $releasever
    enabled: true
    failovermethod: priority
    gpgcheck: false
cloud_config_modules:
  - yum-add-repo
  - runcmd
cloud_final_modules:
  - salt-minion
salt_minion:
  conf:
    master: ${ssconfig_address}
  grains:
    role:
      - web
runcmd:
  - firewall-offline-cmd --add-service=http
  - firewall-cmd --reload
