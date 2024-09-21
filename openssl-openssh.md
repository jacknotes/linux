# Openssl



## 对称加密算法的应用



### 1. 加解密字符串
```bash
[root@salt ~]# echo 'hehe' | openssl enc -e -aes128 -a -salt  --加密
enter aes-128-cbc encryption password:
Verifying - enter aes-128-cbc encryption password:
U2FsdGVkX1/zO05l+efEGO8Y4fFTGUuqvZwMdmH5j6Q=
注：密码是123
[root@salt ~]# echo 'U2FsdGVkX1/zO05l+efEGO8Y4fFTGUuqvZwMdmH5j6Q=' | openssl enc -d -aes128 -a -salt   --解密
enter aes-128-cbc decryption password:              --输入密码123
hehe
注：
-e：加密；
-d：解密；
-ciphername：ciphername为相应的对称加密算命名字，如-des3、-ase128、-cast、-blowfish等等。
-a/-base64：使用base-64位编码格式；
-salt：自动插入一个随机数作为文件内容加密，默认选项；
-in FILENAME：指定要加密的文件的存放路径；
-out FILENAME：指定加密后的文件的存放路径；
```



### 2. 加解密文件 
```
[root@salt ~]# openssl enc -e -des3 -a -salt -in /etc/fstab -out /tmp/fstab   --加密
enter des-ede3-cbc encryption password:
Verifying - enter des-ede3-cbc encryption password:
注：密码是123
[root@salt ~]# cat /tmp/fstab
U2FsdGVkX1/2HLUjXMoESbuO63KgsqfN7ef/HK3qZ++h8n9NgcipP6Db3xZ0+sCk
AG9GvXWc9OXj04ieHRLZflBZiqMyOmEg7xgb2kJESoRXd3Ep1gsKIBf97y9Awn4H
+vARkXPDzQHvcaNZdmgYB1pdTfMsxBW8+eCqZu07bDjUQXV/ylBAVK80DktUtE+a
JT96sy8GhaPGSYQeE1Itb7hC/REnkXQwksoPCEgS0mYQakPtCn+2vUpFQQtzqcoR
JbeWaAdGWfJSUv7vHtOr4q5jB7mo5K9kuIMZfsgRpyosqoINNoF2rKd3S1y+gUSB
COJ2tiu/GAfxD2ypgjK/2c/Ut6125GRGVdMz/fEslWeV3LD2TEw2jUYo3Zz/+IB7
dvjtbC+2xNlZiMTz9Ty+FoJHXAe5DVc5Qz1u2plYQsY2uuHZ5D7RZaQqKMAjTyx8
o7wq9eVrmA1GM5f1EvGUNtqhPeW3pmhslCpJ8rQcQuZF8B9mbY4deRfFky/57q8R
AnB+UG7GtcVh+dDHxqruRlgqdbmYT+/EFGdKzqs1ny5QYskkGjqiNg9vSXC0NnEH
s03dYtTPE/ly8kbJTQGKfAb7bJ+WkmBv
[root@salt ~]# openssl enc -d -des3 -a -salt -in /tmp/fstab   --解密
enter des-ede3-cbc decryption password:
#
# /etc/fstab
# Created by anaconda on Thu May  7 13:47:22 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=edc201ea-e85e-4be3-9bc4-7c5352dceff8 /                       xfs     defaults        0 0
UUID=64103399-5b6f-4fa1-91f8-09c86abd55a9 /boot                   xfs     defaults        0 0
/swap swap swap defaults 0 0
```



### 3. 单向加密
```
[root@salt ~]# echo 'hehe' | openssl dgst -md5 
(stdin)= e4439267203fb5277d347e6cd6e440b5
[root@salt ~]# echo 'hehe' | md5sum 
e4439267203fb5277d347e6cd6e440b5  -
[root@salt ~]# openssl dgst -md5 /etc/fstab 
MD5(/etc/fstab)= 7c7f5f4c652d75674379f4b2db0a9fbb
[root@salt ~]# md5sum  /etc/fstab 
7c7f5f4c652d75674379f4b2db0a9fbb  /etc/fstab
注：单向加密除了 openssl dgst 工具还有： md5sum，sha1sum，sha224sum，sha256sum ，sha384sum，sha512sum
```


### 4. 加密密码
```
[root@salt ~]# openssl passwd -1 -salt jack homsom
$1$jack$OtcWQG8etMN2t3PkktQzG/
注：-1：基于md5的密码算法，-salt: 是加盐jack，homsom是密码
[root@salt ~]# openssl passwd -apr1 -salt jack homsom
$apr1$jack$NGrjAE0AmBNgSKmx47yC/1
注：-apr1：基于md5的密码算法，是apache的变体
```


### 5. 生成随机数
```
[root@salt ~]# openssl rand -hex 10
efd0ef257ce9704d1004
[root@salt ~]# openssl rand -base64 10
5Fq8tY5fktWkSQ==
注：-hex：表示十六进制，-base64：表示base64编码
```



### 6. 生成密钥对
```
[root@salt ~/custom_pki]# (umask 077; openssl genrsa -out one.key 1024)
Generating RSA private key, 1024 bit long modulus
...................++++++
...............++++++
e is 65537 (0x10001)
--生成公钥
[root@salt ~/custom_pki]# openssl rsa -in one.key -pubout -out ./one.crt  
writing RSA key
[root@salt ~/custom_pki]# cat ./one.crt
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHBN+Wtwe4GCkfjKrivh2hUvjX
WWXtBdSXgyHTW7zdG3hnoi3h/DCzunSRGvi1ren6btjc3xaz85nooJoK61qkx9xq
iGfRb9rDT230ckjFvPkbm89rl3FjFRluIMPaqPk4RGl6xyldU+1DbmZVJ4udWNPB
GTX2iwb8vS+hRWRlEQIDAQAB
-----END PUBLIC KEY-----
注：-in：表示输出的文件，-pubout：表示输出公钥，-out：表示输出到哪
```



### 7. CA证书中心
```
--配置CA环境，从/etc/pki/tls/openssl.cnf看出CA环境
[root@salt /etc/pki/CA]# touch index.txt serial
[root@salt /etc/pki/CA]# echo 01 > serial
--生成CA私钥
[root@salt /etc/pki/CA]# (umask 077;openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096)
--生成自签名CA公钥
[root@salt /etc/pki/CA]# openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:hs
Organizational Unit Name (eg, section) []:ops
Common Name (eg, your name or your server's hostname) []:ca.hs.com
Email Address []:
注：
req: 代表请求命令
-new: 表示新的请求
-x509: 表示自签名证书
-key: 表示输入私钥
-out: 表示公钥存放的目录及名称
-days：有效期

#服务器
--生成服务器私钥
[root@tengine ~/custom_cert]# (umask 077;openssl genrsa -out jumpserver.key 4096)
--生成证书签署请求csr(Certificate Singning Request)
[root@tengine ~/custom_cert]# openssl req -new -key jumpserver.key -out jumpserver.csr -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:hs
Organizational Unit Name (eg, section) []:ops
Common Name (eg, your name or your server's hostname) []:jumpserver.hs.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
注：
Country Name: 表示国家名称
State or Province Name：表示省份名称
Locality Name (eg, city)：表示城市名称
Organization Name (eg, company) ：表示公司名称
Organizational Unit Name (eg, section)：表示组织单位名称
Common Name (eg, your name or your server's hostname)：表示主机名称，这个必须跟服务器主机名称一样，可以是*.hs.com

#CA签署证书流程
--把服务器证书签署请求发送给CA，让CA签署
[root@tengine ~/custom_cert]# scp jumpserver.csr root@CA.hs.com:~
--CA签署证书
[root@salt /etc/pki/CA]# openssl ca -in /root/jumpserver.csr -out /root/jumpserver.crt -days 3650
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (
t Before: Mar  5 02:42:23 2021 GMT
            Not After : Mar  3 02:42:23 2031 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Shanghai
            organizationName          = hs
            organizationalUnitName    = ops
            commonName                = jumpserver.hs.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                05:42:9A:FE:E5:B0:CD:69:F3:9E:A0:B7:CA:00:C4:4F:AB:AC:5D:9A
            X509v3 Authority Key Identifier: 
                keyid:94:17:8E:52:1C:20:12:86:49:16:CF:79:48:A4:6F:F9:D2:7F:6B:A4

Certificate is to be certified until Mar  3 02:42:23 2031 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
--复制CA签署的证书到服务器
[root@tengine ~/custom_cert]# scp root@CA.hs.com:/root/jumpserver.crt .
--查看CA数据库文件和串号文件
[root@salt /etc/pki/CA]# cat index.txt
V	310303024223Z		01	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
[root@salt /etc/pki/CA]# cat serial
02
--查看证书信息
[root@salt ~/custom_pki]# openssl x509 -in /root/jumpserver.crt -text -noout -serial -dates -subject
...
serial=01
notBefore=Mar  5 02:42:23 2021 GMT
notAfter=Mar  3 02:42:23 2031 GMT
subject= /C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
注：
-noout：不输出加密的证书内容；
-serial：输出证书序列号；
-dates：显示证书有效期的开始和终止时间；
-subject：输出证书的subject；


--吊销证书：
----查看证书信息是否一致
[root@salt /etc/pki/CA]# openssl x509 -in newcerts/01.pem -noout -text -dates -serial -subject 
notBefore=Mar  5 02:42:23 2021 GMT
notAfter=Mar  3 02:42:23 2031 GMT
serial=01
subject= /C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
[root@salt /etc/pki/CA]# cat index.txt
V	310303024223Z		01	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
----核对无误后吊销证书
[root@salt /etc/pki/CA]# openssl ca -revoke /etc/pki/CA/newcerts/01.pem 
Using configuration from /etc/pki/tls/openssl.cnf
Revoking Certificate 01.
Data Base Updated
----生成吊销编号
[root@salt /etc/pki/CA]# echo 01 > /etc/pki/CA/crlnumber
[root@salt /etc/pki/CA]# cat /etc/pki/CA/crlnumber
01
----更新吊销列表
[root@salt /etc/pki/CA]# openssl ca -gencrl -out /etc/pki/CA/crl/01.pem.crl  ----更新吊销列表
Using configuration from /etc/pki/tls/openssl.cnf
注：-gencrl选项为根据/etc/pki/CA/index.txt文件中的信息生成crl文件。
[root@salt /etc/pki/CA]# cat /etc/pki/CA/crl/ca.crl
-----BEGIN X509 CRL-----
MIIC0TCBugIBATANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJDTjERMA8GA1UE
CAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMQswCQYDVQQKDAJoczEMMAoG
A1UECwwDb3BzMRIwEAYDVQQDDAljYS5ocy5jb20XDTIxMDMwNTA2MDkwMVoXDTIx
MDQwNDA2MDkwMVowFDASAgEBFw0yMTAzMDUwNjA2NTdaoA4wDDAKBgNVHRQEAwIB
ATANBgkqhkiG9w0BAQsFAAOCAgEAGL8haHbuSKOqwCR0G1wh6e4hbSY2DrAczIAE
qzAMXwLC4R1ph5LmUtP2wGs1PESEHu3mXwED7X8wSYsdSQJWo90rUaUpI6sUWqXe
dTaM8Tm4CnWKf7pJpHwCcLxapcQOaE/obz4kza0SxUqGZNonchjVxWFO/SXvelas
V5sW71KcbYQ1bZsoCMSkIHJIRxXTTuPEkYygVIUnJoJgEaFGem9/NSs+oeXCHYzz
X+M8LmOlW7CjWNIa/nhFRFhBO4UQobGIAffEN0WmLdIvNPw9EEK1eNhHAAGkALky
K2dppj4lmHBoi6b42mRcYv/g5BTBRRD2ZnuaB01TGcPI8JZBlJSBeSTBLQqUmPSW
ff9niFRvXJQii2pGOmS7HEdIbMG+ocYW9uVHnlxQGNkZalKVyGYI2o1il+jM+oj7
SJGtgaS2drb5NEmbSAumDD0IwKI+EvafbNpa/3K9fVI3f7ysg7OpUq01dLDgW0ar
SYfl/DpQDHsG7gH20bt0XshGSTxlExfa3bs1FnnXjAutNnYfvdgzA/FSC3UilNRu
oi52IsIRWjlqQyNFLo5AfvyVU4oxtM2yrNgDLm0oOxx9lmLCB2VL5j99+aEv9zgR
IgSKFr4lt68vshFoZwWLx1WEuLNFafaHGDWGT8Ybc7+Wq3UiG/W83mbBK7lIIr7M
y6HPMjY=
-----END X509 CRL-----

#windows证书.cer格式转换为.pem
[root@salt ~]# file 123.cer
123.cer: data
[root@salt ~]# openssl x509 -inform der -in 123.cer -out 123.pem
[root@salt ~]# file 123.pem
123.pem: PEM certificate
#导入根证书到linux证书分发机构
[root@salt ~]# scp /etc/pki/CA/cacert.pem root@192.168.13.50:/root/
root@192.168.13.50's password: 
cacert.pem         
[root@tengine /etc/pki/tls/certs]# cat /root/cacert.pem >> /etc/pki/tls/certs/ca-bundle.crt  --添加根信任证书
[root@tengine /etc/pki/tls/certs]# !curl  
curl -I https://jumpserver.hs.com   ----此时curl会直接成功访问
HTTP/1.1 200 OK

#一条命令生成CAkey和CAcrt
[root@tengine ~/custom_cert]# openssl req -new -x509 -keyout root.key -out origroot.pem -days 3650 -nodes
#通过指定CAcert和CAkey签署证书
[root@tengine ~/custom_cert]# (umask 077;openssl genrsa -out test.key 1024)
[root@tengine ~/custom_cert]# openssl req -new -key test.key -out test.csr -days 365
[root@tengine ~/custom_cert]# openssl x509 -req -in test.csr -CA origroot.pem -CAkey root.key -CAcreateserial -out test.crt -days 3650
Signature ok
subject=/C=CN/ST=Shanghai/L=Shanghai/O=hs/OU=ops/CN=*.hs.com
Getting CA Private Key
[root@tengine ~/custom_cert]# openssl verify -CAfile origroot.pem test.crt   --查看是否被信任
test.crt: OK

```









# OpenSSH





## CentOS 6 升级OpenSSH

```bash
## yum install

# install
yum install -y zlib-devel openssl-devel gcc gcc-c++ glibc make

# uninstall
rpm -e `rpm -qa | grep openssh`
rm -rf /etc/ssh/*



## compile install
tar xf openssh-8.4p1.tar.gz && cd openssh-8.4p1
./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh/ --with-ssl-dir=/usr/local/ssl --with-md5-passwords --mandir=/usr/share/man/  
make && make install



## config
echo 'export PATH=${PATH}:/usr/local/openssh/bin' > /etc/profile.d/openssh.sh
source /etc/profile
cp contrib/redhat/sshd.init /etc/init.d/sshd
sed -i 's#SSHD=/usr/sbin/sshd#SSHD=/usr/local/openssh/sbin/sshd#g' /etc/init.d/sshd
sed -i 's#/usr/bin/ssh-keygen#/usr/local/openssh/bin/ssh-keygen#' /etc/init.d/sshd

$ vi /etc/ssh/sshd_config
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication yes
AllowTcpForwarding yes
X11Forwarding yes
PidFile /run/sshd.pid

# start
service sshd start
service sshd status
chkconfig --add sshd
chkconfig --level 35 sshd on
```







## CentOS 7 升级OpenSSH

### 1. 环境

```bash
# 查看openssh、openssl、zlib的版本
[root@nginx ~]# rpm -qa | grep zlib
zlib-devel-1.2.7-21.el7_9.x86_64
zlib-1.2.7-21.el7_9.x86_64
[root@nginx ~]# rpm -qa | grep openssh
openssh-7.4p1-23.el7_9.x86_64
openssh-server-7.4p1-23.el7_9.x86_64
openssh-clients-7.4p1-23.el7_9.x86_64
[root@nginx ~]# rpm -qa | grep openssl
openssl-libs-1.0.2k-26.el7_9.x86_64
openssl-devel-1.0.2k-26.el7_9.x86_64
openssl-1.0.2k-26.el7_9.x86_64
xmlsec1-openssl-1.2.20-8.el7_9.x86_64
[root@nginx ~]# ssh -V
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017


## 测试nginx支持的tls版本
[root@prometheus ~]# cat /etc/hosts | grep 172.
172.168.2.20 passport.hs.com www.homsom.com

# 测试是否支持-tls1_3
[root@prometheus ~]# openssl s_client -connect www.homsom.com:443 -servername www.homsom.com -tls1_3
CONNECTED(00000004)
139988239619904:error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure:ssl/record/rec_layer_s3.c:1563:SSL alert number 40
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 7 bytes and written 238 bytes
Verification: OK
---
New, (NONE), Cipher is (NONE)
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 0 (ok)
---


# 测试是否支持-tls1_2
[root@prometheus ~]# openssl s_client -connect www.homsom.com:443 -servername www.homsom.com -tls1_2
CONNECTED(00000004)
depth=1 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = GeoTrust CN RSA CA G1
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = \E4\B8\8A\E6\B5\B7\E5\B8\82, O = \E4\B8\8A\E6\B5\B7\E6\81\92\E9\A1\BA\E6\97\85\E8\A1\8C\EF\BC\88\E9\9B\86\E5\9B\A2\EF\BC\89\E6\9C\89\E9\99\90\E5\85\AC\E5\8F\B8, CN = *.homsom.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = \E4\B8\8A\E6\B5\B7\E5\B8\82, O = \E4\B8\8A\E6\B5\B7\E6\81\92\E9\A1\BA\E6\97\85\E8\A1\8C\EF\BC\88\E9\9B\86\E5\9B\A2\EF\BC\89\E6\9C\89\E9\99\90\E5\85\AC\E5\8F\B8, CN = *.homsom.com
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = GeoTrust CN RSA CA G1
 1 s:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = GeoTrust CN RSA CA G1
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
---
Server certificate
.........

root@prometheus ~]# openssl s_client -connect www.homsom.com:443 -servername www.homsom.com -tls1_1
CONNECTED(00000004)
140337364100928:error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure:ssl/record/rec_layer_s3.c:1563:SSL alert number 40
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 7 bytes and written 127 bytes
Verification: OK
---
New, (NONE), Cipher is (NONE)
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.1
    Cipher    : 0000
    Session-ID: 
    Session-ID-ctx: 
    Master-Key: 
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1726811253
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
---

# 测试是否支持-tls1
[root@prometheus ~]# openssl s_client -connect www.homsom.com:443 -servername www.homsom.com -tls1
[root@prometheus ~]# openssl s_client -connect www.homsom.com:443 -servername www.homsom.com -tls1
CONNECTED(00000004)
140322045753152:error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure:ssl/record/rec_layer_s3.c:1563:SSL alert number 40
---
no peer certificate available
---
No client certificate CA names sent
---
SSL handshake has read 7 bytes and written 127 bytes
Verification: OK
---
New, (NONE), Cipher is (NONE)
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1
    Cipher    : 0000
    Session-ID: 
    Session-ID-ctx: 
    Master-Key: 
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1726811258
    Timeout   : 7200 (sec)
    Verify return code: 0 (ok)
    Extended master secret: no
---
# 注：测试结果www.homsom.com只支持tls1_2的，而tls1_3、tls1_1、tls1是不支持的。
# 注：测试结果passport.hs.com只tls1_2、tls1_1、tls1，而tls1_3是不支持的。
```



### 2. 升级openssh

**原因：**因为等保3需求，`openssh-7.4p1-23.el7_9.x86_64`版本存在漏洞，需要对其进行升级，目前最新版本为`openssh-9.8p1`，并且只有此版本才是安全的，其它版本都有漏洞。



#### 2.1 相关信息

**openssh-9.8p1 依赖openssl zlib什么版本?**

**最低版本**: OpenSSH 通常要求 OpenSSL 版本至少为 1.0.1 或更高版本。具体的版本要求可能会因为 OpenSSH 的新功能或安全修补而提升，因此建议使用最新稳定版的 OpenSSL 以确保兼容性和安全性。从openssh-9.4p1开始要求openssl>=1.1.1版本。

**最低版本**: OpenSSH 对 zlib 的版本要求相对较低，一般情况下，zlib 1.2.3 或更高版本即可满足需求。

> 升级OpenSSH依赖OpenSSL，zlib版本已经满足不再需要升级，所以需要升级OpenSSL、OpenSSH



**服务依赖考虑**

* lvs服务器：Linux内核、keepalived服务，使用了vrrp协议，来实现lvs和高可用功能，升级openssl和openssh无影响。
* nginx服务器：nginx服务，https依赖openssl，升级openssl会影响nginx服务。
* k8s服务器：etcd、apiserver、controller-manager、scheduler、kubelet依赖openssl、升级openssl会影响相关服务，不建议升级



**多版本并存原则**

* 旧版本不卸载，并尽可能的备份
* 新版本安装在新路径下，默认查找的服务为老版本
* 新安装软件依赖openssl时，使用新版本的openssl路径进行升级，旧版本则还是查找旧版本的软件



#### 2.2 安装telnet

`防止sshd服务挂掉导致ssh连接断开`

```bash
[root@nginx openssh-9.8p1]# yum install -y telnet-server telnet
[root@nginx openssh-9.8p1]# systemctl start telnet.socket
[root@nginx openssh-9.8p1]# systemctl enable telnet.socket
[root@nginx openssh-9.8p1]# systemctl status telnet.socket
● telnet.socket - Telnet Server Activation Socket
   Loaded: loaded (/usr/lib/systemd/system/telnet.socket; enabled; vendor preset: disabled)
   Active: active (listening) since Fri 2024-09-20 18:16:18 CST; 5s ago
     Docs: man:telnetd(8)
   Listen: [::]:23 (Stream)
 Accepted: 0; Connected: 0

# 默认情况下root用户是被禁止telnet登录的，需要开户root的telnet登录
[root@nginx openssh-9.8p1]# mv /etc/securetty /etc/securetty.bak

# telnet客户端登录
PS C:\Users\user> telnet 172.168.2.20
Trying 172.168.2.20...
Connected to 172.168.2.20.
Escape character is '^]'.

Kernel 3.10.0-1160.119.1.el7.x86_64 on an x86_64
nginx login: root
Password:
Last login: Fri Sep 20 18:18:57 from hs-ua-tsj-0132.hs.com

```









#### 2.3 安装新版本openssl

##### 2.3.1 查看当前版本

```bash
[root@nginx opehssh-server-backup]# sshd -V
unknown option -- V
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017
usage: sshd [-46DdeiqTt] [-C connection_spec] [-c host_cert_file]
            [-E log_file] [-f config_file] [-g login_grace_time]
            [-h host_key_file] [-o option] [-p port] [-u len]
[root@nginx opehssh-server-backup]# ssh -V
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017
```



##### 2.3.2 备份当前版本openssl

```bash
[root@nginx openssl-backup]# rpm -ql openssl
/etc/pki/CA
/etc/pki/CA/certs
/etc/pki/CA/crl
/etc/pki/CA/newcerts
/etc/pki/CA/private
/etc/pki/tls/certs/Makefile
/etc/pki/tls/certs/make-dummy-cert
/etc/pki/tls/certs/renew-dummy-cert
/etc/pki/tls/misc/CA
/etc/pki/tls/misc/c_hash
/etc/pki/tls/misc/c_info
/etc/pki/tls/misc/c_issuer
/etc/pki/tls/misc/c_name
/usr/bin/openssl
/usr/share/doc/openssl-1.0.2k
/usr/share/doc/openssl-1.0.2k/FAQ
/usr/share/doc/openssl-1.0.2k/NEWS
/usr/share/doc/openssl-1.0.2k/README
/usr/share/doc/openssl-1.0.2k/README.FIPS
/usr/share/doc/openssl-1.0.2k/README.legacy-settings
/usr/share/licenses/openssl-1.0.2k
/usr/share/licenses/openssl-1.0.2k/LICENSE
/usr/share/man/man1/asn1parse.1ssl.gz
........

[root@nginx openssl-backup]# \cp -a /etc/pki/CA /etc/pki/tls /usr/bin/openssl .
[root@nginx openssl-backup]# tree .
.
├── CA
│   ├── certs
│   ├── crl
│   ├── newcerts
│   └── private
├── openssl
└── tls
    ├── cert.pem -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    ├── certs
    │   ├── ca-bundle.crt -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
    │   ├── ca-bundle.trust.crt -> /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
    │   ├── make-dummy-cert
    │   ├── Makefile
    │   └── renew-dummy-cert
    ├── misc
    │   ├── CA
    │   ├── c_hash
    │   ├── c_info
    │   ├── c_issuer
    │   └── c_name
    ├── openssl.cnf
    └── private
```



##### 2.3.3 编译安装openssl

```bash
[root@nginx ~]# curl -OL https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz
[root@nginx ~]# tar xf openssl-1.1.1w.tar.gz
[root@nginx ~]# cd openssl-1.1.1w/
[root@nginx openssl-1.1.1w]# ./config --prefix=/usr/local/openssl-1.1.1w
[root@nginx openssl-1.1.1w]# make && make install
[root@nginx openssl-1.1.1w]# ln -sv /usr/local/openssl-1.1.1w/include/openssl /usr/include/openssl-1.1.1w
[root@nginx openssl-1.1.1w]# echo `realpath lib` > /etc/ld.so.conf.d/openssl-1.1.1w.conf
[root@nginx openssl-1.1.1w]# cat /etc/ld.so.conf.d/openssl-1.1.1w.conf
/usr/local/openssl-1.1.1w/lib
[root@nginx openssl-1.1.1w]# ldconfig
# 查看默认版本
[root@nginx ~]# which openssl
/usr/bin/openssl
[root@nginx ~]# openssl version
OpenSSL 1.0.2k-fips  26 Jan 2017
# 查看指定的新安装版本
[root@nginx ~]# /usr/local/openssl-1.1.1w/bin/openssl version
OpenSSL 1.1.1w  11 Sep 2023

# 查看服务依赖的openssl版本
[root@nginx ~]# ssh -V
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017
[root@nginx ~]# sshd -V
unknown option -- V
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017
usage: sshd [-46DdeiqTt] [-C connection_spec] [-c host_cert_file]
            [-E log_file] [-f config_file] [-g login_grace_time]
            [-h host_key_file] [-o option] [-p port] [-u len]
            
[root@nginx ~]# systemctl restart nginx
[root@nginx ~]# /usr/local/nginx/sbin/nginx -V
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC)
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_sub_module --with-stream --with-file-aio --with-http_realip_module --with-stream_ssl_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-pcre=/usr/local/src/pcre-8.37 --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=modules/ngx_http_upstream_check_module --add-module=/download/ngx_http_substitutions_filter_module --add-module=/download/nginx-module-vts-0.1.17
```









#### 2.4 安装新版本openssh

##### 2.4.1 备份当前版本openssh

```bash
[root@nginx openssh-9.8p1]# rpm -ql openssh-server
/etc/pam.d/sshd
/etc/ssh/sshd_config
/etc/sysconfig/sshd
/usr/lib/systemd/system/sshd-keygen.service
/usr/lib/systemd/system/sshd.service
/usr/lib/systemd/system/sshd.socket
/usr/lib/systemd/system/sshd@.service
/usr/lib64/fipscheck/sshd.hmac
/usr/libexec/openssh/sftp-server
/usr/sbin/sshd
/usr/sbin/sshd-keygen
/usr/share/man/man5/moduli.5.gz
/usr/share/man/man5/sshd_config.5.gz
/usr/share/man/man8/sftp-server.8.gz
/usr/share/man/man8/sshd.8.gz
/var/empty/sshd

[root@nginx opehssh-server-backup]# cp /etc/pam.d/sshd ./pam.d_sshd
[root@nginx opehssh-server-backup]# cp /etc/sysconfig/sshd ./sysconfig_sshd
[root@nginx opehssh-server-backup]# \cp -r  /etc/ssh/sshd_config /usr/lib/systemd/system/sshd* /usr/sbin/sshd* .
[root@nginx opehssh-server-backup]# ll
total 868
-rw-r--r-- 1 root root    904 Sep 20 16:47 pam.d_sshd
-rwxr-xr-x 1 root root 852952 Sep 20 16:48 sshd
-rw------- 1 root root   3907 Sep 20 16:48 sshd_config
-rwxr-xr-x 1 root root   3613 Sep 20 16:48 sshd-keygen
-rw-r--r-- 1 root root    313 Sep 20 16:48 sshd-keygen.service
-rw-r--r-- 1 root root    373 Sep 20 16:48 sshd.service
-rw-r--r-- 1 root root    260 Sep 20 16:48 sshd@.service
-rw-r--r-- 1 root root    181 Sep 20 16:48 sshd.socket
-rw-r----- 1 root root    506 Sep 20 16:48 sysconfig_sshd

# openssh-client备份
[root@nginx openssh-9.8p1]# mkdir -p /root/openssh-client-backup
[root@nginx openssh-9.8p1]# cp /etc/ssh/ssh_config /root/openssh-client-backup/
```



##### 2.4.2 编译安装

```bash
[root@nginx ~]# yum install -y pam-devel perl gcc zlib-devel
[root@nginx ~]# curl -OL https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/openssh-9.8p1.tar.gz
[root@nginx ~]# tar xf openssh-9.8p1.tar.gz
[root@nginx ~]# cd openssh-9.8p1
[root@nginx openssh-9.8p1]# ./configure --prefix=/usr/local/openssh-9.8p1 --with-ssl-dir=/usr/local/openssl-1.1.1w --with-pam
[root@nginx openssh-9.8p1]# make && make install

# sshd_config
[root@nginx openssh-9.8p1]# cat /usr/local/openssh-9.8p1/etc/sshd_config
Port 1022
PermitRootLogin yes
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
AuthorizedKeysFile      .ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
GSSAPIAuthentication no
GSSAPICleanupCredentials no
X11Forwarding yes
Subsystem       sftp    /usr/local/openssh-9.8p1/libexec/sftp-server

# systemctl service
[root@nginx openssh-9.8p1]# cat /usr/lib/systemd/system/sshd9.service
[Unit]
Description=OpenSSH server daemon
After=network.target

[Service]
Type=simple
Environment=LD_LIBRARY_PATH=/usr/local/openssl-1.1.1w/lib
ExecStart=/usr/local/openssh-9.8p1/sbin/sshd -f /usr/local/openssh-9.8p1/etc/sshd_config
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=42s

[Install]
WantedBy=multi-user.target
---

# 启动服务
[root@nginx openssh-9.8p1]# systemctl daemon-reload
[root@nginx openssh-9.8p1]# systemctl stop sshd && systemctl restart sshd9
[root@nginx openssh-9.8p1]# systemctl status sshd9
● sshd9.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd9.service; disabled; vendor preset: disabled)
   Active: activating (auto-restart) (Result: exit-code) since Fri 2024-09-20 18:34:53 CST; 2s ago
  Process: 41414 ExecStart=/usr/local/openssh-9.8p1/sbin/sshd -f /usr/local/openssh-9.8p1/etc/sshd_config (code=exited, status=1/FAILURE)
 Main PID: 41414 (code=exited, status=1/FAILURE)

Sep 20 18:34:53 nginx sshd[41414]: @         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
Sep 20 18:34:53 nginx sshd[41414]: @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Sep 20 18:34:53 nginx sshd[41414]: Permissions 0640 for '/etc/ssh/ssh_host_ed25519_key' are too open.
Sep 20 18:34:53 nginx sshd[41414]: It is required that your private key files are NOT accessible by others.
Sep 20 18:34:53 nginx sshd[41414]: This private key will be ignored.
Sep 20 18:34:53 nginx sshd[41414]: Unable to load host key "/etc/ssh/ssh_host_ed25519_key": bad permissions
Sep 20 18:34:53 nginx sshd[41414]: Unable to load host key: /etc/ssh/ssh_host_ed25519_key
Sep 20 18:34:53 nginx sshd[41414]: sshd: no hostkeys available -- exiting.
Sep 20 18:34:53 nginx systemd[1]: Unit sshd9.service entered failed state.
Sep 20 18:34:53 nginx systemd[1]: sshd9.service failed.

# 提示/etc/ssh/ssh_host*文件权限太大，应配置为600
[root@nginx openssh-9.8p1]# chmod 600 /etc/ssh/ssh_host_*
[root@nginx openssh-9.8p1]# ll /etc/ssh/ssh_host_*
-rw------- 1 root ssh_keys  227 Feb 23  2022 /etc/ssh/ssh_host_ecdsa_key
-rw------- 1 root root      162 Feb 23  2022 /etc/ssh/ssh_host_ecdsa_key.pub
-rw------- 1 root ssh_keys  387 Feb 23  2022 /etc/ssh/ssh_host_ed25519_key
-rw------- 1 root root       82 Feb 23  2022 /etc/ssh/ssh_host_ed25519_key.pub
-rw------- 1 root ssh_keys 1675 Feb 23  2022 /etc/ssh/ssh_host_rsa_key
-rw------- 1 root root      382 Feb 23  2022 /etc/ssh/ssh_host_rsa_key.pub

# 重新启动服务
[root@nginx openssh-9.8p1]# systemctl restart sshd9
[root@nginx openssh-9.8p1]# systemctl status sshd9
● sshd9.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd9.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-09-20 18:37:53 CST; 1s ago
 Main PID: 41472 (sshd)
   CGroup: /system.slice/sshd9.service
           └─41472 sshd: /usr/local/openssh-9.8p1/sbin/sshd -f /usr/local/openssh-9.8p1/etc/sshd_config [listener] 0 of 10-100 startups

Sep 20 18:37:53 nginx systemd[1]: Started OpenSSH server daemon.
Sep 20 18:37:53 nginx sshd[41472]: Server listening on 0.0.0.0 port 1022.
Sep 20 18:37:53 nginx sshd[41472]: Server listening on :: port 1022.

# 查看服务端口和进程
[root@nginx openssh-9.8p1]# ss -tnl | grep 1022
LISTEN     0      128          *:1022                     *:*
LISTEN     0      128       [::]:1022                  [::]:*
[root@nginx openssh-9.8p1]# ps -ef | grep sshd
root      41472      1  0 18:37 ?        00:00:00 sshd: /usr/local/openssh-9.8p1/sbin/sshd -f /usr/local/openssh-9.8p1/etc/sshd_config [listener] 0 of 10-100 startups
root      41486  41056  0 18:40 pts/4    00:00:00 grep --color=auto sshd
# 配置开机自启动
[root@nginx openssh-9.8p1]# systemctl enable sshd9
```





##### 2.4.3 验证

**服务端验证**

```bash
[root@nginx ~]# ssh -V
OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017
[root@nginx ~]# openssl version
OpenSSL 1.0.2k-fips  26 Jan 2017
[root@nginx ~]# /usr/local/openssh-9.8p1/bin/ssh -V
OpenSSH_9.8p1, OpenSSL 1.1.1w  11 Sep 2023
[root@nginx ~]# /usr/local/openssl-1.1.1w/bin/openssl version
OpenSSL 1.1.1w  11 Sep 2023
```



**客户端验证**

```bash
# 可以看出sshd版本为OpenSSH_9.8
PS C:\Users\0799> ssh -v root@172.168.2.20 -p 1022
OpenSSH_for_Windows_8.1p1, LibreSSL 3.0.2
debug1: Reading configuration data C:\\Users\\0799/.ssh/config
debug1: Connecting to 172.168.2.20 [172.168.2.20] port 1022.
debug1: Connection established.
debug1: identity file C:\\Users\\0799/.ssh/id_rsa type 0
debug1: identity file C:\\Users\\0799/.ssh/id_rsa-cert type -1
debug1: identity file C:\\Users\\0799/.ssh/id_dsa type -1
debug1: identity file C:\\Users\\0799/.ssh/id_dsa-cert type -1
debug1: identity file C:\\Users\\0799/.ssh/id_ecdsa type -1
debug1: identity file C:\\Users\\0799/.ssh/id_ecdsa-cert type -1
debug1: identity file C:\\Users\\0799/.ssh/id_ed25519 type -1
debug1: identity file C:\\Users\\0799/.ssh/id_ed25519-cert type -1
debug1: identity file C:\\Users\\0799/.ssh/id_xmss type -1
debug1: identity file C:\\Users\\0799/.ssh/id_xmss-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_for_Windows_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_9.8
debug1: match: OpenSSH_9.8 pat OpenSSH* compat 0x04000000
debug1: Authenticating to 172.168.2.20:1022 as 'root'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:HDwxKX0vqWDG20jo+f+qHdP7XAAG0CmmLu4z/tsvwyY
debug1: checking without port identifier
debug1: Host '172.168.2.20' is known and matches the ECDSA host key.
debug1: Found key in C:\\Users\\0799/.ssh/known_hosts:67
debug1: found matching key w/out port
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: pubkey_prepare: ssh_get_authentication_socket: No such file or directory
debug1: Will attempt key: C:\\Users\\0799/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Will attempt key: C:\\Users\\0799/.ssh/id_dsa
debug1: Will attempt key: C:\\Users\\0799/.ssh/id_ecdsa
debug1: Will attempt key: C:\\Users\\0799/.ssh/id_ed25519
debug1: Will attempt key: C:\\Users\\0799/.ssh/id_xmss
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256>
debug1: kex_input_ext_info: publickey-hostbound@openssh.com (unrecognised)
debug1: kex_input_ext_info: ping@openssh.com (unrecognised)
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Offering public key: C:\\Users\\0799/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Authentications that can continue: publickey,password
debug1: Trying private key: C:\\Users\\0799/.ssh/id_dsa
debug1: Trying private key: C:\\Users\\0799/.ssh/id_ecdsa
debug1: Trying private key: C:\\Users\\0799/.ssh/id_ed25519
debug1: Trying private key: C:\\Users\\0799/.ssh/id_xmss
debug1: Next authentication method: password
debug1: read_passphrase: can't open /dev/tty: No such file or directory
root@172.168.2.20's password:
```





##### 2.4.4 多版本并存

```bash
# 启用老sshd服务，可实现新老版本sshd共存
[root@nginx openssh-9.8p1]# systemctl start sshd
[root@nginx openssh-9.8p1]# systemctl status sshd
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2024-09-20 18:40:37 CST; 2s ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 41493 (sshd)
   CGroup: /system.slice/sshd.service
           └─41493 /usr/sbin/sshd -D
[root@nginx openssh-9.8p1]# ss -tnl | grep 22
LISTEN     0      128          *:22                       *:*
LISTEN     0      128          *:1022                     *:*
LISTEN     0      128       [::]:22                    [::]:*
LISTEN     0      128       [::]:1022                  [::]:*

[root@nginx openssh-9.8p1]#  systemctl restart sshd sshd9 nginx
[root@nginx openssh-9.8p1]#  systemctl is-active  sshd sshd9 nginx
active
active
active

# 客户端连接测试
PS C:\Users\0799> ssh root@172.168.2.20 -p 1022
root@172.168.2.20's password:
Last login: Fri Sep 20 18:45:18 2024 from hs-ua-tsj-0132.hs.com
[root@nginx ~]# 

PS C:\Users\0799> ssh root@172.168.2.20 -p 22
root@172.168.2.20's password:
Last login: Fri Sep 20 18:45:05 2024 from hs-ua-tsj-0132.hs.com
[root@nginx ~]#
```



##### 2.4.5 测试服务器重启后所有服务是否正常

```bash
[root@nginx openssh-9.8p1]#  systemctl restart sshd sshd9 nginx
[root@nginx openssh-9.8p1]#  systemctl is-active  sshd sshd9 nginx
active
active
active
[root@nginx openssh-9.8p1]#  systemctl status sshd sshd9 nginx
● sshd.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd.service; enabled; vendor preset: enabled)
   Active: active (running) since Fri 2024-09-20 18:41:36 CST; 5min ago
     Docs: man:sshd(8)
           man:sshd_config(5)
 Main PID: 41510 (sshd)
   CGroup: /system.slice/sshd.service
           └─41510 /usr/sbin/sshd -D

Sep 20 18:41:36 nginx systemd[1]: Started OpenSSH server daemon.
Sep 20 18:44:12 nginx sshd[41525]: Connection reset by 172.168.2.219 port 11353 [preauth]
Sep 20 18:44:26 nginx sshd[41527]: pam_unix(sshd:auth): authentication failure; logname= uid=0 euid=0 tty=ssh ruser= rhost=hs-ua-tsj-0132.hs.com  user=root
Sep 20 18:44:26 nginx sshd[41527]: pam_succeed_if(sshd:auth): requirement "uid >= 1000" not met by user "root"
Sep 20 18:44:29 nginx sshd[41527]: Failed password for root from 172.168.2.219 port 11377 ssh2
Sep 20 18:44:30 nginx sshd[41527]: pam_succeed_if(sshd:auth): requirement "uid >= 1000" not met by user "root"
Sep 20 18:44:32 nginx sshd[41527]: Failed password for root from 172.168.2.219 port 11377 ssh2
Sep 20 18:44:33 nginx sshd[41527]: Accepted password for root from 172.168.2.219 port 11377 ssh2
Sep 20 18:45:05 nginx sshd[41571]: Accepted password for root from 172.168.2.219 port 11432 ssh2
Sep 20 18:45:18 nginx sshd[41614]: Accepted password for root from 172.168.2.219 port 11461 ssh2

● sshd9.service - OpenSSH server daemon
   Loaded: loaded (/usr/lib/systemd/system/sshd9.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-09-20 18:41:36 CST; 5min ago
 Main PID: 41509 (sshd)
   CGroup: /system.slice/sshd9.service
           └─41509 sshd: /usr/local/openssh-9.8p1/sbin/sshd -f /usr/local/openssh-9.8p1/etc/sshd_config [listener] 0 of 10-100 startups

Sep 20 18:41:36 nginx systemd[1]: Started OpenSSH server daemon.
Sep 20 18:41:36 nginx sshd[41509]: Server listening on 0.0.0.0 port 1022.
Sep 20 18:41:36 nginx sshd[41509]: Server listening on :: port 1022.
Sep 20 18:44:08 nginx sshd-session[41523]: Connection reset by authenticating user root 172.168.2.219 port 11350 [preauth]
Sep 20 18:45:27 nginx sshd-session[41650]: Accepted password for root from 172.168.2.219 port 11477 ssh2

● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2024-09-20 18:41:37 CST; 5min ago
  Process: 41511 ExecStop=/usr/local/nginx/sbin/nginx -s stop (code=exited, status=0/SUCCESS)
  Process: 41514 ExecStart=/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 41515 (nginx)
   CGroup: /system.slice/nginx.service
           ├─41515 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
           ├─41516 nginx: worker process
           ├─41517 nginx: worker process
           ├─41518 nginx: worker process
           ├─41519 nginx: worker process
           └─41520 nginx: cache manager process

Sep 20 18:41:37 nginx systemd[1]: Starting nginx - high performance web server...
Sep 20 18:41:37 nginx systemd[1]: Started nginx - high performance web server.

# 确认开机自启
[root@nginx openssh-9.8p1]# systemctl enable nginx sshd sshd9 telnet.socket

[root@nginx ~]# reboot
Connection closed by foreign host.


PS C:\Users\user>  ssh root@172.168.2.20 -p 1022
Warning: Permanently added '[172.168.2.20]:1022' (ECDSA) to the list of known hosts.
X11 forwarding request failed on channel 0
Last login: Fri Sep 20 18:45:27 2024 from 172.168.2.219
[root@nginx ~]# uptime
 18:53:06 up 1 min,  1 user,  load average: 0.06, 0.03, 0.01
```

