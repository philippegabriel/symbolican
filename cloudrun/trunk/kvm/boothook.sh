#!/bin/sh
echo 'boothook for kvm Starting...WARNING!!! This is a boothook for kvm image Not valid for EC2 images'
#
#Set passwd for ubuntu
#
echo 'ubuntu:pass' | chpasswd
#Set it to never expire
chage -m 0 -M 99999 ubuntu
#fixup DNS
echo '127.0.0.1 ovfdemo.localdomain' >> /etc/hosts
#IP Address for the machine running kvm
echo '192.168.2.5 kvmhost' >> /etc/hosts
#Redirect apt-get to apt-cacher
echo 'Acquire::http { Proxy "http://kvmhost:3142"; };' > /etc/apt/apt.conf.d/02proxy
#
#
echo 'boothook for kvm Ends'









