echo -e "The following values are required for configuration of dhcpd.\n"
echo "Input subnet address (ex. 192.168.5.0): "
read SUBNET
echo "Input network mask (ex. 255.255.255.0): "
read NETMASK
echo "Input DHCP range start (ex. 192.168.5.38): "
read RANGESTART
echo "Input DHCP range end (ex. 192.168.5.243): "
read RANGEEND
echo "Input gateway address (ex. 192.168.5.1): "
read ROUTER1
echo "Input DNS server address (ex. 192.168.5.1): "
read DNS1
echo "Input IP address of PXE server (this server, ex. 192.168.5.2): "
read PXEIP

dnf install -y syslinux tftp-server xinetd dhcp-server httpd
mkdir /tftpboot
cp /usr/share/syslinux/pxelinux.0 /tftpboot
cp /usr/share/syslinux/menu.c32 /tftpboot
cp /usr/share/syslinux/memdisk /tftpboot
cp /usr/share/syslinux/mboot.c32 /tftpboot
cp /usr/share/syslinux/chain.c32 /tftpboot
cp /usr/share/syslinux/ldlinux.c32 /tftpboot
cp /usr/share/syslinux/libutil.c32 /tftpboot
mkdir /tftpboot/pxelinux.cfg
mkdir -p /tftpboot/images/centos/x86_64/8-Stream
wget http://ftp.ussg.iu.edu/linux/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20191219-boot.iso
mkdir mount-iso
mount ./CentOS-Stream-8-x86_64-20191219-boot.iso ./mount-iso/ -o loop
cp ./mount-iso/images/pxeboot/initrd.img /tftpboot/images/centos/x86_64/8-Stream/
cp ./mount-iso/images/pxeboot/vmlinuz /tftpboot/images/centos/x86_64/8-Stream/
umount /root/CentOS-Stream-8-x86_64-20191219-boot.iso
rm -rf ./mount-iso
rm -rf ./CentOS-Stream-8-x86_64-20191219-boot.iso 

/bin/cp -rf ./centos-kickstart/dhcpd.conf /etc/dhcp/dhcpd.conf
sed -i "s/SUBNET/$SUBNET/g" /etc/dhcp/dhcpd.conf
sed -i "s/NETMASK/$NETMASK/g" /etc/dhcp/dhcpd.conf
sed -i "s/RANGESTART/$RANGESTART/g" /etc/dhcp/dhcpd.conf
sed -i "s/RANGEEND/$RANGEEND/g" /etc/dhcp/dhcpd.conf
sed -i "s/ROUTER1/$ROUTER1/g" /etc/dhcp/dhcpd.conf
sed -i "s/DNS1/$DNS1/g" /etc/dhcp/dhcpd.conf
sed -i "s/PXEIP/$PXEIP/g" /etc/dhcp/dhcpd.conf

/bin/cp -rf ./centos-kickstart/tftp /etc/xinetd.d/tftp
cat anaconda-ks.cfg | sed 's/repo/# repo/g' > /var/www/html/anaconda-ks.cfg
echo "reboot" >> /var/www/html/anaconda-ks.cfg
chmod ugo+r /var/www/html/anaconda-ks.cfg
systemctl enable tftp
systemctl enable xinetd
systemctl enable dhcpd
systemctl enable httpd
systemctl start httpd
systemctl start tftp
systemctl start xinetd
systemctl start dhcpd