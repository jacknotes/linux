#NTP
<pre>
#compile install new ntp package.
curl -OL http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/ntp-4.2.8p15.tar.gz
yum install -y gcc libcap libcap-devel glibc-devel autogen-libopts-devel
./configure --prefix=/usr/local/ntp --bindir=/usr/local/ntp/sbin --sysconfdir=/etc --libexecdir=/usr/local/ntp/libexec --docdir=/usr/local/ntp/doc/ntp --enable-linuxcaps  --with-lineeditlibs=readline  --enable-all-clocks --enable-parse-clocks --enable-clockctl --enable-ntpdate-step --enable-libopts-install 

#ntp.conf
-----
[root@salt /usr/local/ntp/sbin]# cat /etc/ntp.conf | grep -Ev '#|^$'
fudge 127.127.1.0 stratum 2
restrict default nomodify notrap nopeer noquery
restrict 127.0.0.1 
restrict ::1
restrict 192.168.13.0  mask 255.255.255.0 nomodify notrap
restrict 192.168.10.0  mask 255.255.255.0 nomodify notrap
restrict 172.168.2.0  mask 255.255.255.0 nomodify notrap
server time1.aliyun.com
server time2.aliyun.com
server time3.aliyun.com
server 0.asia.pool.ntp.org
server 1.asia.pool.ntp.org
server 2.asia.pool.ntp.org
server 3.asia.pool.ntp.org
-----

#ntpd.service
-----
[root@salt /usr/local/ntp/sbin]# cat /usr/lib/systemd/system/ntpd.service 
[Unit]
Description=Network Time Service
After=network-online.target

[Service]
Type=forking
ExecStart=/usr/local/ntp/sbin/ntpd -c /etc/ntp.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
-----

systemctl daemon-reload
systemctl start ntpd
systemctl enable ntpd

</pre>

