#!/bin/bash
echo "Please input hostname to set for this server (ex. centos-1.local.tylernelsonschuppert.com): "
read HOST
echo "Please input static IP to set for this server (ex. 192.168.5.2): "
read IPADDR
echo "Please input CIDR prefix to set for this server (ex. 24): "
read PREFIX
echo "Please input gateway address to set for this server (ex. 192.168.5.1): "
read GATEWAY
echo "Please input DNS server to set for this server (ex. 192.168.5.1): "
read DNS1

dnf update -y
echo $HOST > /etc/hostname
sed -i 's/dhcp/none/g' /etc/sysconfig/network-scripts/ifcfg-ens192
echo -e "IPADDR=$IPADDR\nPREFIX=$PREFIX\nGATEWAY=$GATEWAY\nDNS1=$DNS1\n" >> /etc/sysconfig/network-scripts/ifcfg-ens192 
systemctl stop firewalld
systemctl disable firewalld
