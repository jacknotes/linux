#ENV: CentOS6
<pre>
#install compile tools
yum install -y zlib-devel openssl-devel gcc gcc-c++ glibc make

#uninstall old openssh software
rpm -e `rpm -qa | grep openssh`
rm -rf /etc/ssh/*

#compile install openssh
[root@ha1 download]# tar xf openssh-8.4p1.tar.gz && cd openssh-8.4p1
./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh/ --with-ssl-dir=/usr/local/ssl --with-md5-passwords --mandir=/usr/share/man/  
make && make install

#config new openssh
echo 'export PATH=${PATH}:/usr/local/openssh/bin' > /etc/profile.d/openssh.sh
source /etc/profile
cp contrib/redhat/sshd.init /etc/init.d/sshd
sed -i 's#SSHD=/usr/sbin/sshd#SSHD=/usr/local/openssh/sbin/sshd#g' /etc/init.d/sshd
sed -i 's#/usr/bin/ssh-keygen#/usr/local/openssh/bin/ssh-keygen#' /etc/init.d/sshd

#edit sshd_config file
vi /etc/ssh/sshd_config
-----
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
AllowTcpForwarding yes
X11Forwarding yes
PidFile /run/sshd.pid
-----

#start openssh
service sshd start
service sshd status

#set starting up boot
chkconfig --add sshd
chkconfig --level 35 sshd on

</pre>
