#cloud-config
ssh_pwauth: True
users:
  - default
  - name: centos
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: sudo
    lock_passwd: False
    passwd: $6$FrC8cVgH7KM6Khyd$I4yf9O4C/dxHoMhyhz2lLOT4KzV4gUwUa1VghFmfCkLt8ne0fq2QT4FDPcH1sq8UYHToj.Tkg54ZUzfxAR4Ej.
    shell: /bin/bash  
chpasswd:
  list: |
    centos:$6$FrC8cVgH7KM6Khyd$I4yf9O4C/dxHoMhyhz2lLOT4KzV4gUwUa1VghFmfCkLt8ne0fq2QT4FDPcH1sq8UYHToj.Tkg54ZUzfxAR4Ej.
  expire: false    
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
cloud_final_modules:
  - salt-minion
salt_minion:
  conf:
    master: ${ssconfig_address}
  grains:
    role:
      - web
