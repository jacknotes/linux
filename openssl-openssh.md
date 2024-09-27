# enssl



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





## 一、Centos6 升级OpenSSH

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







## 二、Centos7 编译升级OpenSSH

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


## 客户端测试nginx支持的tls版本
[root@prometheus ~]# cat /etc/hosts | grep 172.
172.168.2.20 passport.hs.com www.test.com

# 测试是否支持-tls1_3
[root@prometheus ~]# openssl s_client -connect www.test.com:443 -servername www.test.com -tls1_3
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
[root@prometheus ~]# openssl s_client -connect www.test.com:443 -servername www.test.com -tls1_2
CONNECTED(00000004)
depth=1 C = US, O = DigiCert Inc, OU = www.digicert.com, CN = GeoTrust CN RSA CA G1
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = \E4\B8\8A\E6\B5\B7\E5\B8\82, O = \E4\B8\8A\E6\B5\B7\E6\81\92\E9\A1\BA\E6\97\85\E8\A1\8C\EF\BC\88\E9\9B\86\E5\9B\A2\EF\BC\89\E6\9C\89\E9\99\90\E5\85\AC\E5\8F\B8, CN = *.test.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = \E4\B8\8A\E6\B5\B7\E5\B8\82, O = \E4\B8\8A\E6\B5\B7\E6\81\92\E9\A1\BA\E6\97\85\E8\A1\8C\EF\BC\88\E9\9B\86\E5\9B\A2\EF\BC\89\E6\9C\89\E9\99\90\E5\85\AC\E5\8F\B8, CN = *.test.com
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = GeoTrust CN RSA CA G1
 1 s:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = GeoTrust CN RSA CA G1
   i:C = US, O = DigiCert Inc, OU = www.digicert.com, CN = DigiCert Global Root CA
---
Server certificate
.........

root@prometheus ~]# openssl s_client -connect www.test.com:443 -servername www.test.com -tls1_1
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
[root@prometheus ~]# openssl s_client -connect www.test.com:443 -servername www.test.com -tls1
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
# 注：测试结果www.test.com只支持tls1_2的，而tls1_3、tls1_1、tls1是不支持的。
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
PS C:\Users\user> ssh -v root@172.168.2.20 -p 1022
OpenSSH_for_Windows_8.1p1, LibreSSL 3.0.2
debug1: Reading configuration data C:\\Users\\user/.ssh/config
debug1: Connecting to 172.168.2.20 [172.168.2.20] port 1022.
debug1: Connection established.
debug1: identity file C:\\Users\\user/.ssh/id_rsa type 0
debug1: identity file C:\\Users\\user/.ssh/id_rsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_dsa type -1
debug1: identity file C:\\Users\\user/.ssh/id_dsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_ecdsa type -1
debug1: identity file C:\\Users\\user/.ssh/id_ecdsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_ed25519 type -1
debug1: identity file C:\\Users\\user/.ssh/id_ed25519-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_xmss type -1
debug1: identity file C:\\Users\\user/.ssh/id_xmss-cert type -1
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
debug1: Found key in C:\\Users\\user/.ssh/known_hosts:67
debug1: found matching key w/out port
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: pubkey_prepare: ssh_get_authentication_socket: No such file or directory
debug1: Will attempt key: C:\\Users\\user/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Will attempt key: C:\\Users\\user/.ssh/id_dsa
debug1: Will attempt key: C:\\Users\\user/.ssh/id_ecdsa
debug1: Will attempt key: C:\\Users\\user/.ssh/id_ed25519
debug1: Will attempt key: C:\\Users\\user/.ssh/id_xmss
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256>
debug1: kex_input_ext_info: publickey-hostbound@openssh.com (unrecognised)
debug1: kex_input_ext_info: ping@openssh.com (unrecognised)
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Offering public key: C:\\Users\\user/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Authentications that can continue: publickey,password
debug1: Trying private key: C:\\Users\\user/.ssh/id_dsa
debug1: Trying private key: C:\\Users\\user/.ssh/id_ecdsa
debug1: Trying private key: C:\\Users\\user/.ssh/id_ed25519
debug1: Trying private key: C:\\Users\\user/.ssh/id_xmss
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
PS C:\Users\user> ssh root@172.168.2.20 -p 1022
root@172.168.2.20's password:
Last login: Fri Sep 20 18:45:18 2024 from hs-ua-tsj-0132.hs.com
[root@nginx ~]# 

PS C:\Users\user> ssh root@172.168.2.20 -p 22
root@172.168.2.20's password:
Last login: Fri Sep 20 18:45:05 2024 from hs-ua-tsj-0132.hs.com
[root@nginx ~]#

# 服务端停止sshd和sshd9服务互不影响
[root@nginx ~]# ps -ef | grep sshd
root       7775      1  0 10:01 ?        00:00:00 /usr/sbin/sshd -D
root       7776      1  0 10:01 ?        00:00:00 sshd9: /usr/local/openssh-9.8p1/sbin/sshd9 -f /usr/local/openssh-9.8p1/etc/sshd_config [listener] 0 of 10-100 startups
root       7777   7776  0 10:01 ?        00:00:00 sshd-session: root [priv]
root       7779   7777  0 10:01 ?        00:00:00 sshd-session: root@pts/0
root       7780   7776  0 10:01 ?        00:00:00 sshd-session: root [priv]
root       7782   7780  0 10:01 ?        00:00:00 sshd-session: root@notty
root       7934   7775  1 11:48 ?        00:00:00 sshd: root@pts/1
root       7936   7775  1 11:48 ?        00:00:00 sshd: root@notty
root       7985   7783  0 11:48 pts/0    00:00:00 grep --color=auto sshd
# 停止sshd
[root@nginx ~]# systemctl stop sshd
# sshd停止后，进程7934、7936的父进程由7775变成了1，sshd现有连接不会断开，但是新连接无法建立
[root@nginx ~]# ps -ef | grep sshd
root       7776      1  0 10:01 ?        00:00:00 sshd9: /usr/local/openssh-9.8p1/sbin/sshd9 -f /usr/local/openssh-9.8p1/etc/sshd_config [listener] 0 of 10-100 startups
root       7777   7776  0 10:01 ?        00:00:00 sshd-session: root [priv]
root       7779   7777  0 10:01 ?        00:00:00 sshd-session: root@pts/0
root       7780   7776  0 10:01 ?        00:00:00 sshd-session: root [priv]
root       7782   7780  0 10:01 ?        00:00:00 sshd-session: root@notty
root       7934      1  0 11:48 ?        00:00:00 sshd: root@pts/1
root       7936      1  0 11:48 ?        00:00:00 sshd: root@notty
root       8001   7783  0 11:49 pts/0    00:00:00 grep --color=auto sshd

# 停止sshd9
[root@nginx ~]# systemctl stop sshd9
[root@nginx ~]# ps -ef | grep sshd
root       7777      1  0 10:01 ?        00:00:00 sshd-session: root [priv]
root       7779   7777  0 10:01 ?        00:00:00 sshd-session: root@pts/0
root       7780      1  0 10:01 ?        00:00:00 sshd-session: root [priv]
root       7782   7780  0 10:01 ?        00:00:00 sshd-session: root@notty
root       8028   7783  0 11:52 pts/0    00:00:00 grep --color=auto sshd

# 停止所有sshd进程
[root@nginx ~]# ps -ef | grep sshd
root       8036      1  0 11:53 ?        00:00:00 /usr/sbin/sshd -D
root       8037      1  0 11:53 ?        00:00:00 sshd9: /usr/local/openssh-9.8p1/sbin/sshd9 -f /usr/local/openssh-9.8p1/etc/sshd_config [listener] 0 of 10-100 startups
root       8040   8037  0 11:53 ?        00:00:00 sshd-session: root [priv]
root       8042   8040  0 11:53 ?        00:00:00 sshd-session: root@pts/0
root       8043   8037  0 11:53 ?        00:00:00 sshd-session: root [priv]
root       8067   8043  0 11:53 ?        00:00:00 sshd-session: root@notty
root       8092   8036  0 11:53 ?        00:00:00 sshd: root@pts/1
root       8094   8036  0 11:53 ?        00:00:00 sshd: root@notty
root       8139   8045  0 11:53 pts/0    00:00:00 grep --color=auto sshd
[root@nginx ~]# pgrep sshd
8036
8037
8040
8042
8043
8067
8092
8094
[root@nginx ~]# pkill sshd
Connection to 172.168.2.20 closed by remote host.
Connection to 172.168.2.20 closed.
```



##### 2.4.5 sshd和sshd9平滑切换

```bash
# 客户端连接
> ssh root@172.168.2.20 -p 22
[root@nginx ~]# ps -ef | grep sshd
root      25652      1  0 15:55 ?        00:00:00 /usr/sbin/sshd -D
root      25664  25652  0 15:56 ?        00:00:00 sshd: root@pts/1
root      25666  25652  0 15:56 ?        00:00:00 sshd: root@notty
root      25723  25668  0 15:57 pts/1    00:00:00 grep --color=auto sshd
[root@nginx etc]# ss -tnlp | grep :22
LISTEN     0      128                                                       [::]:22                                                                    [::]:*                   users:(("sshd",pid=25652,fd=4))


# 停止sshd服务，此时已经连接的sshd还存在，但是新连接无法连接22端口
[root@nginx etc]# systemctl stop sshd
# 此时无22端口监听
[root@nginx etc]# ss -tnlp
State      Recv-Q Send-Q                                           Local Address:Port                                                          Peer Address:Port
LISTEN     0      128                                                          *:80                                                                       *:*                   users:(("nginx",pid=25635,fd=6),("nginx",pid=25634,fd=6),("nginx",pid=25633,fd=6),("nginx",pid=25632,fd=6),("nginx",pid=25444,fd=6))
LISTEN     0      128                                                          *:8088                                                                     *:*                   users:(("nginx",pid=25635,fd=9),("nginx",pid=25634,fd=9),("nginx",pid=25633,fd=9),("nginx",pid=25632,fd=9),("nginx",pid=25444,fd=9))
LISTEN     0      128                                                  127.0.0.1:8089                                                                     *:*                   users:(("nginx",pid=25635,fd=8),("nginx",pid=25634,fd=8),("nginx",pid=25633,fd=8),("nginx",pid=25632,fd=8),("nginx",pid=25444,fd=8))
LISTEN     0      128                                                          *:443                                                                      *:*                   users:(("nginx",pid=25635,fd=7),("nginx",pid=25634,fd=7),("nginx",pid=25633,fd=7),("nginx",pid=25632,fd=7),("nginx",pid=25444,fd=7))
LISTEN     0      128                                                          *:6443                                                                     *:*                   users:(("nginx",pid=25635,fd=10),("nginx",pid=25634,fd=10),("nginx",pid=25633,fd=10),("nginx",pid=25632,fd=10),("nginx",pid=25444,fd=10))
LISTEN     0      128                                                          *:111                                                                      *:*                   users:(("rpcbind",pid=690,fd=8))
LISTEN     0      128                                                       [::]:23                                                                    [::]:*                   users:(("systemd",pid=1,fd=27))
LISTEN     0      128                                                       [::]:111                                                                   [::]:*                   users:(("rpcbind",pid=690,fd=11))

# 配置sshd9服务端口为22
[root@nginx etc]# cat sshd_config
#Port 1022
Port 22
PermitRootLogin yes
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
SyslogFacility AUTHPRIV
AuthorizedKeysFile      .ssh/authorized_keys
PasswordAuthentication yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
Subsystem       sftp    /usr/local/openssh-9.8p1/libexec/sftp-server
# 启动sshd9
[root@nginx etc]# systemctl start sshd9
[root@nginx etc]# ss -tnlp | grep :22
LISTEN     0      128                                                       [::]:22                                                                    [::]:*                   users:(("sshd",pid=25758,fd=8))


# 另开一个端口，再次连接22端口（此时连接的其实是sshd9服务）
> ssh -v root@172.168.2.20 -p 22
OpenSSH_7.5p1, OpenSSL 1.0.2o  27 Mar 2018
debug1: Reading configuration data /etc/ssh_config
debug1: /etc/ssh_config line 13: Deprecated option "useroaming"
debug1: Connecting to 172.168.2.20 [172.168.2.20] port 22.
debug1: Connection established.
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_rsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_rsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_dsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_dsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ecdsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ecdsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ed25519 type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ed25519-cert type -1
debug1: Enabling compatibility mode for protocol 2.0
debug1: Local version string SSH-2.0-OpenSSH_7.5
debug1: Remote protocol version 2.0, remote software version OpenSSH_9.8  # openssl新版本
debug1: match: OpenSSH_9.8 pat OpenSSH* compat 0x04000000
debug1: Authenticating to 172.168.2.20:22 as 'root'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: aes128-ctr MAC: hmac-sha1 compression: zlib@openssh.com
debug1: kex: client->server cipher: aes128-ctr MAC: hmac-sha1 compression: zlib@openssh.com
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:HDwxKX0vqWDG20jo+f+qHdP7XAAG0CmmLu4z/tsvwyY
debug1: rekey after 4294967296 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey after 4294967296 blocks
debug1: pubkey_prepare: ssh_fetch_identitylist: agent refused operation
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256>
debug1: kex_input_ext_info: publickey-hostbound@openssh.com=<0>
debug1: kex_input_ext_info: ping@openssh.com=<0>
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Trying private key: /home/mobaxterm/.ssh/id_rsa
debug1: Trying private key: /home/mobaxterm/.ssh/id_dsa
debug1: Trying private key: /home/mobaxterm/.ssh/id_ecdsa
debug1: Trying private key: /home/mobaxterm/.ssh/id_ed25519
debug1: Next authentication method: password
debug1: Enabling compression at level 6.
debug1: Authentication succeeded (password).
Authenticated to 172.168.2.20 ([172.168.2.20]:22).
debug1: channel 0: new [client-session]
debug1: Requesting no-more-sessions@openssh.com
debug1: Entering interactive session.
debug1: pledge: exec
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
debug1: Requesting X11 forwarding with authentication spoofing.
debug1: Requesting authentication agent forwarding.
debug1: Remote: No xauth program; cannot forward X11.
X11 forwarding request failed on channel 0
Last login: Tue Sep 24 15:56:36 2024 from hs-ua-tsj-0132.hs.com



```



##### 2.4.6 卸载telnet

```bash
systemctl disable telnet.socket
systemctl stop telnet.socket
systemctl status telnet.socket
mv /etc/securetty.bak /etc/securetty 
yum remove -y telnet-server telnet
```



##### 2.4.7 测试服务器重启后所有服务是否正常

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



##### 2.4.8测试nginx支持tls的版本

```bash
# 测试结果: www.test.com只支持tls1_2的，而tls1_3、tls1_1、tls1是不支持的。
openssl s_client -connect www.test.com:443 -servername www.test.com -tls1_3
openssl s_client -connect www.test.com:443 -servername www.test.com -tls1_2
openssl s_client -connect www.test.com:443 -servername www.test.com -tls1_1
openssl s_client -connect www.test.com:443 -servername www.test.com -tls1
# 测试结果: passport.hs.com只支持tls1_2、tls1_1、tls1，而tls1_3是不支持的。
openssl s_client -connect passport.hs.com:443 -servername passport.hs.com -tls1
openssl s_client -connect passport.hs.com:443 -servername passport.hs.com -tls1_1
openssl s_client -connect passport.hs.com:443 -servername passport.hs.com -tls1_2
openssl s_client -connect passport.hs.com:443 -servername passport.hs.com -tls1_3
```









### 3. nginx升级openssl版本

#### 3.1 配置测试网站

```bash
# 服务端
server {
        listen       80;
        server_name     test123.hs.com;
        rewrite ^(.*)$ https://${server_name}$1 permanent;
}
server {
        listen 443 ssl;
        server_name test123.hs.com;
        ssl_certificate   hscert/hs.com/server.pem;
        ssl_certificate_key  hscert/hs.com/server.key;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_prefer_server_ciphers on;

        location ^~ / {
                root   html;
                index test123.html;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
                root   html;
        }
}
[root@nginx nginx]# cat html/test123.html
hehe
[root@nginx nginx]# systemctl reload nginx

# 客户端
[root@prometheus ~]# cat /etc/hosts | grep 2.20
172.168.2.20 passport.hs.com www.test.com test123.hs.com
[root@prometheus ~]# curl -L https://test123.hs.com
hehe
[root@prometheus ~]# curl https://test123.hs.com
hehe
[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1_1
CONNECTED(00000004)
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=21:unable to verify the first certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
   i:C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFXTCCBEWgAwIBAgIUIbVvypNEb+/53zxUcQLJqY9BxP0wDQYJKoZIhvcNAQEL
BQAwVjELMAkGA1UEBhMCQ04xETAPBgNVBAgMCFNoYW5naGFpMRMwEQYDVQQKDApI
T01TT00gSW5jMQ0wCwYDVQQLDARUZWNoMRAwDgYDVQQDDAdMaW51eENBMCAXDTI0
MDUyNzA4MzcwOVoYDzIxMjQwNTAzMDgzNzA5WjBoMQswCQYDVQQGEwJDTjERMA8G
A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMRMwEQYDVQQKDApIT01T
T00gSW5jMQ0wCwYDVQQLDARUZWNoMQ8wDQYDVQQDDAZocy5jb20wggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDgjrcclk3Tc0rdhiQrR/BC4YmOUckSNXpu
1+FbqCVGaiS474JeuIOIvhvjmN5HgLzIt6CE+euH0t7jwNaf/TgU+m6wihRzRZ/Q
yU1JA9aTvYqhMR+IU0TwqRL6q2O/cE8PpfDqGYQ8+cb4S2SvWE3ArTGKEyMm0a2V
xJ8f73VujZxWUvbXdP9KGUjy93Z1suYiWSny6kaQ45kdqJOzcc/vxYg/MHC0iF0n
nofUhfV2k/KSZ2gILDDTcub7smYSJmjOkqxt5/g67yoWuETMJ0eEDowATvdo35dm
KDw9TMjv4FN/F+YQIk85qShl+Let4f3fpA3cd1I20i+hPTH9qBrf2gsrMCtAEokD
DztHxaQE6VtKsBvGVUcUMXi330NMwksE0E2g6QJfkGilbjspwmoZIKnbc/d3/sGu
8EDOC5HO0t67LOEbxMNGL8KRHVT00TPObZR79ELP2Cq86TDPydfKRfAphshA6J+W
ZxbRxBQPrJ101qiWv8KWymSytuFzt+VY1I08cu64nnhqiUkSQD+iH3vK+0TaOgqF
D0SLPakk8KsQMAzt1ISID1L7aLLsNl6s089+JHItBUk8/xZruZCio/tO7YK8U+ew
mr3vtouKIWv9MDL9Lj7rtVMF/3xeRUzukos5E6UtWhZp207DxEhQL+RE2Smtq6Yo
aXokA7N2ZQIDAQABo4IBDTCCAQkwggEFBgNVHREEgf0wgfqHBMCoDc+HBMCoDdCC
CCouaHMuY29tggwqLmhzY29ycC5jb22CDyouZmF0LnFhLmhzLmNvbYIPKi51YXQu
cWEuaHMuY29tghAqLnNlcnZpY2UuaHMuY29tggwqLmFwaS5ocy5jb22CFyouc2Vy
dmljZS5mYXQucWEuaHMuY29tghMqLmFwaS5mYXQucWEuaHMuY29tghcqLnNlcnZp
Y2UudWF0LnFhLmhzLmNvbYITKi5hcGkudWF0LnFhLmhzLmNvbYIMKi5rOHMuaHMu
Y29tghMqLms4cy5mYXQucWEuaHMuY29tghMqLms4cy51YXQucWEuaHMuY29tMA0G
CSqGSIb3DQEBCwUAA4IBAQBFZoVg3XFU+q19Je6FaPz6PKnB7nzPQ/sJQJFJ8osW
Fm8BhW/WAjKa1rwJ7MT72kO9qKp3CG3gEf++8QbeGJ/YVHtgs+glUrOD02QHzLk4
ODPEKcWT+8fqIDLNZTJ66TkLAMjqzizgb0vgAJ4miHn6nBv8/NemTm0frfEEGEBJ
G3alacLTlkac0LxRu4wibTz4ogASO9Wbv2s7dW4Cu6g9CA98QfW5Bjys/0dPA7hZ
3+rDufn+SyHWes7gvbM9e0yc/OKfEA/5XnjKEfx2syvvsiOCVHkARdPS4+7YEfcL
VeHq6DkteGRW1XcA7Jallebgtkr8MoxrI6sFIDijcqdM
-----END CERTIFICATE-----
subject=C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com

issuer=C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA

---
No client certificate CA names sent
Peer signing digest: MD5-SHA1
Peer signature type: RSA
Server Temp Key: ECDH, P-256, 256 bits
---
SSL handshake has read 2345 bytes and written 277 bytes
Verification error: unable to verify the first certificate
---
New, TLSv1.0, Cipher is ECDHE-RSA-AES256-SHA
Server public key is 4096 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.1
    Cipher    : ECDHE-RSA-AES256-SHA
    Session-ID: 63C7E42DD8B6D5786FFCD0672FD8965A31469F305DDC62C26AC1EDB3B90BFD40
    Session-ID-ctx: 
    Master-Key: 45284257AE1CFFDC1AA33065851EE7FE830F7FAD0BA3D7BFECCD0EE980464F4D9197801317A48F7ECFB4686E6209CED0
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 300 (seconds)
    TLS session ticket:
    0000 - e1 2b 17 03 72 2e f4 64-0a ac 6d a8 e9 e3 2c 9c   .+..r..d..m...,.
    0010 - 03 2d 33 1a a7 b4 18 f6-0f f2 e8 f9 c0 06 ba bd   .-3.............
    0020 - 20 88 a3 4d 49 2e 49 aa-bb 66 f8 1d 5f 8a 89 a6    ..MI.I..f.._...
    0030 - 56 8a 54 11 0e f3 8f b3-98 58 5c 9f bd ea 10 bd   V.T......X\.....
    0040 - 24 af d1 54 54 a2 d4 d9-57 11 dc 6e b8 69 43 cf   $..TT...W..n.iC.
    0050 - 53 33 df 21 a1 1c 38 65-cd 4f 00 a0 a8 63 29 2a   S3.!..8e.O...c)*
    0060 - d6 e6 18 65 31 3f df 3c-08 d2 51 46 e0 52 f0 ec   ...e1?.<..QF.R..
    0070 - 04 ac aa 50 72 f6 f4 54-72 54 6f b7 23 1d ea b5   ...Pr..TrTo.#...
    0080 - 0c d2 50 93 13 5a 11 f0-38 50 03 00 c1 de 8d b5   ..P..Z..8P......
    0090 - a1 6c 1e 75 64 a2 33 4d-da 41 fd 02 0a 0d 32 5c   .l.ud.3M.A....2\
    00a0 - 20 02 a7 01 79 70 5e aa-96 c7 87 9f d7 f1 20 60    ...yp^....... `
    00b0 - 53 ad 9c de 4c 83 69 7b-9a 3a 7e 38 56 3e 0c 47   S...L.i{.:~8V>.G

    Start Time: 1727077305
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: no
---
[[A[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1_2
CONNECTED(00000004)
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=21:unable to verify the first certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
   i:C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFXTCCBEWgAwIBAgIUIbVvypNEb+/53zxUcQLJqY9BxP0wDQYJKoZIhvcNAQEL
BQAwVjELMAkGA1UEBhMCQ04xETAPBgNVBAgMCFNoYW5naGFpMRMwEQYDVQQKDApI
T01TT00gSW5jMQ0wCwYDVQQLDARUZWNoMRAwDgYDVQQDDAdMaW51eENBMCAXDTI0
MDUyNzA4MzcwOVoYDzIxMjQwNTAzMDgzNzA5WjBoMQswCQYDVQQGEwJDTjERMA8G
A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMRMwEQYDVQQKDApIT01T
T00gSW5jMQ0wCwYDVQQLDARUZWNoMQ8wDQYDVQQDDAZocy5jb20wggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDgjrcclk3Tc0rdhiQrR/BC4YmOUckSNXpu
1+FbqCVGaiS474JeuIOIvhvjmN5HgLzIt6CE+euH0t7jwNaf/TgU+m6wihRzRZ/Q
yU1JA9aTvYqhMR+IU0TwqRL6q2O/cE8PpfDqGYQ8+cb4S2SvWE3ArTGKEyMm0a2V
xJ8f73VujZxWUvbXdP9KGUjy93Z1suYiWSny6kaQ45kdqJOzcc/vxYg/MHC0iF0n
nofUhfV2k/KSZ2gILDDTcub7smYSJmjOkqxt5/g67yoWuETMJ0eEDowATvdo35dm
KDw9TMjv4FN/F+YQIk85qShl+Let4f3fpA3cd1I20i+hPTH9qBrf2gsrMCtAEokD
DztHxaQE6VtKsBvGVUcUMXi330NMwksE0E2g6QJfkGilbjspwmoZIKnbc/d3/sGu
8EDOC5HO0t67LOEbxMNGL8KRHVT00TPObZR79ELP2Cq86TDPydfKRfAphshA6J+W
ZxbRxBQPrJ101qiWv8KWymSytuFzt+VY1I08cu64nnhqiUkSQD+iH3vK+0TaOgqF
D0SLPakk8KsQMAzt1ISID1L7aLLsNl6s089+JHItBUk8/xZruZCio/tO7YK8U+ew
mr3vtouKIWv9MDL9Lj7rtVMF/3xeRUzukos5E6UtWhZp207DxEhQL+RE2Smtq6Yo
aXokA7N2ZQIDAQABo4IBDTCCAQkwggEFBgNVHREEgf0wgfqHBMCoDc+HBMCoDdCC
CCouaHMuY29tggwqLmhzY29ycC5jb22CDyouZmF0LnFhLmhzLmNvbYIPKi51YXQu
cWEuaHMuY29tghAqLnNlcnZpY2UuaHMuY29tggwqLmFwaS5ocy5jb22CFyouc2Vy
dmljZS5mYXQucWEuaHMuY29tghMqLmFwaS5mYXQucWEuaHMuY29tghcqLnNlcnZp
Y2UudWF0LnFhLmhzLmNvbYITKi5hcGkudWF0LnFhLmhzLmNvbYIMKi5rOHMuaHMu
Y29tghMqLms4cy5mYXQucWEuaHMuY29tghMqLms4cy51YXQucWEuaHMuY29tMA0G
CSqGSIb3DQEBCwUAA4IBAQBFZoVg3XFU+q19Je6FaPz6PKnB7nzPQ/sJQJFJ8osW
Fm8BhW/WAjKa1rwJ7MT72kO9qKp3CG3gEf++8QbeGJ/YVHtgs+glUrOD02QHzLk4
ODPEKcWT+8fqIDLNZTJ66TkLAMjqzizgb0vgAJ4miHn6nBv8/NemTm0frfEEGEBJ
G3alacLTlkac0LxRu4wibTz4ogASO9Wbv2s7dW4Cu6g9CA98QfW5Bjys/0dPA7hZ
3+rDufn+SyHWes7gvbM9e0yc/OKfEA/5XnjKEfx2syvvsiOCVHkARdPS4+7YEfcL
VeHq6DkteGRW1XcA7Jallebgtkr8MoxrI6sFIDijcqdM
-----END CERTIFICATE-----
subject=C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com

issuer=C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA

---
No client certificate CA names sent
Peer signing digest: SHA512
Peer signature type: RSA
Server Temp Key: ECDH, P-256, 256 bits
---
SSL handshake has read 2323 bytes and written 343 bytes
Verification error: unable to verify the first certificate
---
New, TLSv1.2, Cipher is ECDHE-RSA-AES128-GCM-SHA256
Server public key is 4096 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES128-GCM-SHA256
    Session-ID: 4A291EB7F1AFE21F68E3EF3F7523D1FDDBEDCA7EC55C68BD5C802422D36B39F5
    Session-ID-ctx: 
    Master-Key: 24EC33717D9602339CD23A5B9B1A7173789594884CC3AFDC3E15557237B23018E5FCC75A6C3B7E9255B526611C044FCA
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 300 (seconds)
    TLS session ticket:
    0000 - e1 2b 17 03 72 2e f4 64-0a ac 6d a8 e9 e3 2c 9c   .+..r..d..m...,.
    0010 - 31 06 1f 12 12 a6 10 0b-f6 7d 1c 99 22 18 01 24   1........}.."..$
    0020 - ae e0 f4 40 5c df bf e2-c6 52 45 cf 41 e2 b9 bb   ...@\....RE.A...
    0030 - df 9d f1 24 46 04 a8 b0-31 3b 25 1c ea 5b 85 a0   ...$F...1;%..[..
    0040 - 56 51 d2 01 66 35 fe 82-0d 91 1e bc c5 c4 ec 79   VQ..f5.........y
    0050 - f0 96 eb fc 09 5a 05 ce-e2 5a 9c ae ef e5 f2 b7   .....Z...Z......
    0060 - 89 19 85 7b 4e b8 95 b2-b4 c9 8f f6 24 a0 01 79   ...{N.......$..y
    0070 - 0f d4 8c 8e 9b 7e 3f ea-34 9b f7 f8 94 ea 27 e0   .....~?.4.....'.
    0080 - 8e de 31 6d 21 56 b7 08-78 1a 51 65 88 bd 8d 3f   ..1m!V..x.Qe...?
    0090 - 00 e5 ad 12 27 d5 de fe-33 77 1f 8b d8 24 ec e2   ....'...3w...$..
    00a0 - c5 b4 8a c9 89 69 d9 93-23 2c 77 33 65 1a 27 ef   .....i..#,w3e.'.
    00b0 - fa 60 f7 4e 10 e9 b6 9d-9a d8 89 13 e8 98 7f 5e   .`.N...........^

    Start Time: 1727077307
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: no
---
[[A[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1_3
CONNECTED(00000004)
139795357251392:error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure:ssl/record/rec_layer_s3.c:1563:SSL alert number 40
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
# 注：https://test123.hs.com只支持tls1_2、tls1_1、tls1，而tls1_3是不支持的。

# 循环测试，看后面升级nginx是否会宕机
[root@prometheus ~]# while true;do date;curl -L http://test123.hs.com ;sleep 1;done
Mon Sep 23 15:44:41 CST 2024
hehe
Mon Sep 23 15:44:42 CST 2024
hehe

```



#### 3.2 升级nginx支持tls1.3

由于前面已经升级openssl，新旧版本openssl状态如下

```bash
# 旧版本openssl加密协议支持情况
[root@nginx nginx]# openssl ciphers -tls1_3
Error in cipher list
139869069223824:error:1410D0B9:SSL routines:SSL_CTX_set_cipher_list:no cipher match:ssl_lib.c:1383:

# 查看新版本openssl加密协议支持情况
[root@nginx nginx]# /usr/local/openssl-1.1.1w/bin/openssl ciphers -tls1_3
TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:DHE-RSA-AES256-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-SHA:RSA-PSK-AES256-GCM-SHA384:DHE-PSK-AES256-GCM-SHA384:RSA-PSK-CHACHA20-POLY1305:DHE-PSK-CHACHA20-POLY1305:ECDHE-PSK-CHACHA20-POLY1305:AES256-GCM-SHA384:PSK-AES256-GCM-SHA384:PSK-CHACHA20-POLY1305:RSA-PSK-AES128-GCM-SHA256:DHE-PSK-AES128-GCM-SHA256:AES128-GCM-SHA256:PSK-AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:ECDHE-PSK-AES256-CBC-SHA384:ECDHE-PSK-AES256-CBC-SHA:SRP-RSA-AES-256-CBC-SHA:SRP-AES-256-CBC-SHA:RSA-PSK-AES256-CBC-SHA384:DHE-PSK-AES256-CBC-SHA384:RSA-PSK-AES256-CBC-SHA:DHE-PSK-AES256-CBC-SHA:AES256-SHA:PSK-AES256-CBC-SHA384:PSK-AES256-CBC-SHA:ECDHE-PSK-AES128-CBC-SHA256:ECDHE-PSK-AES128-CBC-SHA:SRP-RSA-AES-128-CBC-SHA:SRP-AES-128-CBC-SHA:RSA-PSK-AES128-CBC-SHA256:DHE-PSK-AES128-CBC-SHA256:RSA-PSK-AES128-CBC-SHA:DHE-PSK-AES128-CBC-SHA:AES128-SHA:PSK-AES128-CBC-SHA256:PSK-AES128-CBC-SHA
```



**重新编译nginx**

使nginx支持TLS1.3和HTTP 2.0

```bash
[root@nginx nginx]# /usr/local/nginx/sbin/nginx -V
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC)
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_sub_module --with-stream --with-file-aio --with-http_realip_module --with-stream_ssl_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-pcre=/usr/local/src/pcre-8.37 --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=modules/ngx_http_upstream_check_module --add-module=/download/ngx_http_substitutions_filter_module --add-module=/download/nginx-module-vts-0.1.17

[root@nginx openssl]# pwd
/usr/local/src/tengine-2.3.2/auto/lib/openssl
[root@nginx openssl]# cp conf conf.bak
[root@nginx openssl]# vim conf
将
            CORE_INCS="$CORE_INCS $OPENSSL/.openssl/include"
            CORE_DEPS="$CORE_DEPS $OPENSSL/.openssl/include/openssl/ssl.h"
            CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libssl.a"
            CORE_LIBS="$CORE_LIBS $OPENSSL/.openssl/lib/libcrypto.a"
            CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
修改为
            CORE_INCS="$CORE_INCS $OPENSSL/include"
            CORE_DEPS="$CORE_DEPS $OPENSSL/include/openssl/ssl.h"
            CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libssl.a"
            CORE_LIBS="$CORE_LIBS $OPENSSL/lib/libcrypto.a"
            CORE_LIBS="$CORE_LIBS $NGX_LIBDL"
            
# 编译
[root@nginx tengine-2.3.2]# pwd
/usr/local/src/tengine-2.3.2
[root@nginx tengine-2.3.2]# ./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_sub_module --with-stream --with-file-aio --with-http_realip_module --with-stream_ssl_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-pcre=/usr/local/src/pcre-8.37 --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=modules/ngx_http_upstream_check_module --add-module=/download/ngx_http_substitutions_filter_module --add-module=/download/nginx-module-vts-0.1.17 --with-http_v2_module --with-openssl=/usr/local/openssl-1.1.1w --with-openssl-opt=enable-tlsext --with-openssl-opt=enable-tls1_3
注：
--with-openssl-opt=enable-tlsext 参数用于启用 TLS 扩展（TLS extensions）。这项功能允许 Nginx 支持现代 TLS 特性，如 SNI（服务器名称指示），使其能够在同一 IP 地址上托管多个 SSL 证书。
--with-openssl-opt=enable-tls1_3


[root@nginx tengine-2.3.2]# make
[root@nginx tengine-2.3.2]# mv /usr/local/nginx/sbin/nginx{,.bak}
[root@nginx tengine-2.3.2]# ls /usr/local/nginx/sbin/
nginx.bak
[root@nginx tengine-2.3.2]# cp /usr/local/src/tengine-2.3.2/objs/nginx /usr/local/nginx/sbin/
[root@nginx tengine-2.3.2]# ls /usr/local/nginx/sbin/
nginx  nginx.bak
[root@nginx tengine-2.3.2]# ps -ef | grep nginx
root      17550      1  0 09:12 ?        00:00:00 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
www       17665  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17666  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17667  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17668  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17669  17550  0 09:56 ?        00:00:01 nginx: cache manager process
root      24597  17393  0 10:03 pts/0    00:00:00 grep --color=auto nginx

## nginx信号
# master 主进程支持的信号
TERM(15), INT(2)：立刻退出
QUIT(3)：等待工作进程结束后再退出
KILL(9)：强制终止进程
HUP(1)：重新加载配置文件，使用新的配置启动工作进程，并逐步关闭旧进程。
USR1(10)：重新打开日志文件
USR2(12)：启动新的主进程master，实现热升级
WINCH(28)：逐步关闭worker工作进程
# worker 工作进程支持的信号
TERM(15), INT(2)：立刻退出
QUIT(3)：等待工作进程结束后再退出
USR1(10)：重新打开日志文件
###########nginx平滑升级和回滚仅供参考#############
# nginx平滑升级
mv /usr/local/nginx/sbin/nginx{,.old}
cp /usr/local/src/tengine-2.3.2/objs/nginx /usr/local/nginx/sbin/
kill -USR2 `cat /var/run/nginx.pid`				# 平滑升级，创建新的主进程和新的工作进程，新旧进程保持并行运行
kill -WINCH  `cat /var/run/nginx.pid.oldbin`	# 平滑退出旧的工作进程，此时只有旧的主进程运行
kill -QUIT `cat /var/run/nginx.pid.oldbin`		# 退出旧的主进程

# nginx平滑回滚方式一，未使用kill -QUIT前提下
kill -HUP `cat /var/run/nginx.pid.oldbin`	# 平滑回滚，使用新的配置启动工作进程，并逐步关闭旧的工作进程，因为之前已经使用kill -WINCH，所以旧的工作进程已经关闭，无需再关闭了
kill -WINCH  `cat /var/run/nginx.pid`		# 平滑退出新的工作进程，此时有旧的主进程和工作进程运行
kill -QUIT `cat /var/run/nginx.pid`			# 退出新的主进程

# nginx平滑回滚方式二，已使用kill -QUIT前提下
mv /usr/local/nginx/sbin/nginx{,.new}
mv /usr/local/nginx/sbin/nginx.old /usr/local/nginx/sbin/nginx
kill -USR2 `cat /var/run/nginx.pid`				# 平滑回滚，创建旧版本的主进程和工作进程，旧新进程保持并行运行
kill -WINCH  `cat /var/run/nginx.pid.oldbin`	# 平滑退出新版本的工作进程，此时只有新版本的主进程运行
kill -QUIT `cat /var/run/nginx.pid.oldbin`		# 退出新版本的主进程
############################

[root@nginx tengine-2.3.2]# kill -USR2 `cat /var/run/nginx.pid`
[root@nginx tengine-2.3.2]# ps -ef | grep nginx
root      17550      1  0 09:12 ?        00:00:00 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
www       17665  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17666  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17667  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17668  17550  0 09:56 ?        00:00:01 nginx: worker process
www       17669  17550  0 09:56 ?        00:00:01 nginx: cache manager process
root      24606  17550  5 10:04 ?        00:00:00 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
www       24607  24606  0 10:04 ?        00:00:00 nginx: worker process
www       24608  24606  0 10:04 ?        00:00:00 nginx: worker process
www       24609  24606  0 10:04 ?        00:00:00 nginx: worker process
www       24610  24606  0 10:04 ?        00:00:00 nginx: worker process
www       24611  24606  0 10:04 ?        00:00:00 nginx: cache manager process
www       24612  24606  0 10:04 ?        00:00:00 nginx: cache loader process
root      24614  17393  0 10:04 pts/0    00:00:00 grep --color=auto nginx
[root@nginx tengine-2.3.2]# cat /var/run/nginx.pid.oldbin /var/run/nginx.pid
17550
24606
[root@nginx tengine-2.3.2]# kill -WINCH `cat /var/run/nginx.pid.oldbin`
[root@nginx tengine-2.3.2]# ps -ef | grep nginx
root      17550      1  0 09:12 ?        00:00:00 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
root      24606  17550  0 10:04 ?        00:00:00 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
www       24607  24606  0 10:04 ?        00:00:00 nginx: worker process
www       24608  24606  0 10:04 ?        00:00:01 nginx: worker process
www       24609  24606  0 10:04 ?        00:00:01 nginx: worker process
www       24610  24606  0 10:04 ?        00:00:01 nginx: worker process
www       24611  24606  0 10:04 ?        00:00:01 nginx: cache manager process
root      24633  17393  0 10:09 pts/0    00:00:00 grep --color=auto nginx

# 在Tengine/2.3.2(nginx/1.17.3)执行此命令，无法完成平滑升级，导致所有nginx进程退出，生产上不要使用平滑升级策略，使用主备高可用nginx模式进行升级
[root@nginx tengine-2.3.2]# kill -QUIT `cat /var/run/nginx.pid.oldbin`
[root@nginx conf.d]# systemctl restart nginx
[root@nginx conf.d]# ps -ef | grep nginx
root      25444      1  0 15:25 ?        00:00:00 nginx: master process /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
www       25480  25444  0 15:26 ?        00:00:00 nginx: worker process
www       25481  25444  0 15:26 ?        00:00:00 nginx: worker process
www       25482  25444  0 15:26 ?        00:00:00 nginx: worker process
www       25483  25444  0 15:26 ?        00:00:00 nginx: worker process
www       25484  25444  0 15:26 ?        00:00:00 nginx: cache manager process
root      25496  17393  0 15:31 pts/0    00:00:00 grep --color=auto nginx
[root@nginx conf.d]# /usr/local/nginx/sbin/nginx -V
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC)
built with OpenSSL 1.1.1w  11 Sep 2023
TLS SNI support enabled
configure arguments: --prefix=/usr/local/nginx --user=www --group=www --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_sub_module --with-stream --with-file-aio --with-http_realip_module --with-stream_ssl_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-pcre=/usr/local/src/pcre-8.37 --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=modules/ngx_http_upstream_check_module --add-module=/download/ngx_http_substitutions_filter_module --add-module=/download/nginx-module-vts-0.1.17 --with-http_v2_module --with-openssl=/usr/local/openssl-1.1.1w --with-openssl-opt=enable-tlsext --with-openssl-opt=enable-tls1_3
```



#### 3.3 配置服务支持多版本tls

```nginx
server {
        listen       80;
        server_name     test123.hs.com;
        rewrite ^(.*)$ https://${server_name}$1 permanent;
}
server {
        listen 443 ssl;
        server_name test123.hs.com;
        ssl_certificate   hscert/hs.com/server.pem;
        ssl_certificate_key  hscert/hs.com/server.key;
        ssl_session_timeout 1d;
        ssl_session_cache shared:MozSSL:10m;  # about 40000 sessions
        ssl_session_tickets off;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:DHE-RSA-CHACHA20-POLY1305;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers off;

        location ^~ / {
                root   html;
                index test123.html;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
                root   html;
        }
}
```

> * 确保test123.hs.com:443是nginx的第一个443 servername
> * 确保ssl_ciphers和ssl_protocols都支持TLSv1 TLSv1.1 TLSv1.2 TLSv1.3



**测试**

```bash
# tls1测试
[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1
CONNECTED(00000004)
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=21:unable to verify the first certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
   i:C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFXTCCBEWgAwIBAgIUIbVvypNEb+/53zxUcQLJqY9BxP0wDQYJKoZIhvcNAQEL
BQAwVjELMAkGA1UEBhMCQ04xETAPBgNVBAgMCFNoYW5naGFpMRMwEQYDVQQKDApI
T01TT00gSW5jMQ0wCwYDVQQLDARUZWNoMRAwDgYDVQQDDAdMaW51eENBMCAXDTI0
MDUyNzA4MzcwOVoYDzIxMjQwNTAzMDgzNzA5WjBoMQswCQYDVQQGEwJDTjERMA8G
A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMRMwEQYDVQQKDApIT01T
T00gSW5jMQ0wCwYDVQQLDARUZWNoMQ8wDQYDVQQDDAZocy5jb20wggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDgjrcclk3Tc0rdhiQrR/BC4YmOUckSNXpu
1+FbqCVGaiS474JeuIOIvhvjmN5HgLzIt6CE+euH0t7jwNaf/TgU+m6wihRzRZ/Q
yU1JA9aTvYqhMR+IU0TwqRL6q2O/cE8PpfDqGYQ8+cb4S2SvWE3ArTGKEyMm0a2V
xJ8f73VujZxWUvbXdP9KGUjy93Z1suYiWSny6kaQ45kdqJOzcc/vxYg/MHC0iF0n
nofUhfV2k/KSZ2gILDDTcub7smYSJmjOkqxt5/g67yoWuETMJ0eEDowATvdo35dm
KDw9TMjv4FN/F+YQIk85qShl+Let4f3fpA3cd1I20i+hPTH9qBrf2gsrMCtAEokD
DztHxaQE6VtKsBvGVUcUMXi330NMwksE0E2g6QJfkGilbjspwmoZIKnbc/d3/sGu
8EDOC5HO0t67LOEbxMNGL8KRHVT00TPObZR79ELP2Cq86TDPydfKRfAphshA6J+W
ZxbRxBQPrJ101qiWv8KWymSytuFzt+VY1I08cu64nnhqiUkSQD+iH3vK+0TaOgqF
D0SLPakk8KsQMAzt1ISID1L7aLLsNl6s089+JHItBUk8/xZruZCio/tO7YK8U+ew
mr3vtouKIWv9MDL9Lj7rtVMF/3xeRUzukos5E6UtWhZp207DxEhQL+RE2Smtq6Yo
aXokA7N2ZQIDAQABo4IBDTCCAQkwggEFBgNVHREEgf0wgfqHBMCoDc+HBMCoDdCC
CCouaHMuY29tggwqLmhzY29ycC5jb22CDyouZmF0LnFhLmhzLmNvbYIPKi51YXQu
cWEuaHMuY29tghAqLnNlcnZpY2UuaHMuY29tggwqLmFwaS5ocy5jb22CFyouc2Vy
dmljZS5mYXQucWEuaHMuY29tghMqLmFwaS5mYXQucWEuaHMuY29tghcqLnNlcnZp
Y2UudWF0LnFhLmhzLmNvbYITKi5hcGkudWF0LnFhLmhzLmNvbYIMKi5rOHMuaHMu
Y29tghMqLms4cy5mYXQucWEuaHMuY29tghMqLms4cy51YXQucWEuaHMuY29tMA0G
CSqGSIb3DQEBCwUAA4IBAQBFZoVg3XFU+q19Je6FaPz6PKnB7nzPQ/sJQJFJ8osW
Fm8BhW/WAjKa1rwJ7MT72kO9qKp3CG3gEf++8QbeGJ/YVHtgs+glUrOD02QHzLk4
ODPEKcWT+8fqIDLNZTJ66TkLAMjqzizgb0vgAJ4miHn6nBv8/NemTm0frfEEGEBJ
G3alacLTlkac0LxRu4wibTz4ogASO9Wbv2s7dW4Cu6g9CA98QfW5Bjys/0dPA7hZ
3+rDufn+SyHWes7gvbM9e0yc/OKfEA/5XnjKEfx2syvvsiOCVHkARdPS4+7YEfcL
VeHq6DkteGRW1XcA7Jallebgtkr8MoxrI6sFIDijcqdM
-----END CERTIFICATE-----
subject=C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com

issuer=C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA

---
No client certificate CA names sent
Peer signing digest: MD5-SHA1
Peer signature type: RSA
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 2129 bytes and written 232 bytes
Verification error: unable to verify the first certificate
---
New, TLSv1.0, Cipher is ECDHE-RSA-AES256-SHA
Server public key is 4096 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1
    Cipher    : ECDHE-RSA-AES256-SHA
    Session-ID: A0DD76600017158260F28D5702B38F16D63B9F6FEBFF4D01D361E9ABD0610776
    Session-ID-ctx: 
    Master-Key: 2606F4B1E24A19B8727F4CCE0AA1083DF3D9A71A44022A525808BB345DDA1D265640999B4E4A59A30B6C86826B9F69CC
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1727164126
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: yes
---

# tls1.1测试
[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1_1
CONNECTED(00000004)
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=21:unable to verify the first certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
   i:C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFXTCCBEWgAwIBAgIUIbVvypNEb+/53zxUcQLJqY9BxP0wDQYJKoZIhvcNAQEL
BQAwVjELMAkGA1UEBhMCQ04xETAPBgNVBAgMCFNoYW5naGFpMRMwEQYDVQQKDApI
T01TT00gSW5jMQ0wCwYDVQQLDARUZWNoMRAwDgYDVQQDDAdMaW51eENBMCAXDTI0
MDUyNzA4MzcwOVoYDzIxMjQwNTAzMDgzNzA5WjBoMQswCQYDVQQGEwJDTjERMA8G
A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMRMwEQYDVQQKDApIT01T
T00gSW5jMQ0wCwYDVQQLDARUZWNoMQ8wDQYDVQQDDAZocy5jb20wggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDgjrcclk3Tc0rdhiQrR/BC4YmOUckSNXpu
1+FbqCVGaiS474JeuIOIvhvjmN5HgLzIt6CE+euH0t7jwNaf/TgU+m6wihRzRZ/Q
yU1JA9aTvYqhMR+IU0TwqRL6q2O/cE8PpfDqGYQ8+cb4S2SvWE3ArTGKEyMm0a2V
xJ8f73VujZxWUvbXdP9KGUjy93Z1suYiWSny6kaQ45kdqJOzcc/vxYg/MHC0iF0n
nofUhfV2k/KSZ2gILDDTcub7smYSJmjOkqxt5/g67yoWuETMJ0eEDowATvdo35dm
KDw9TMjv4FN/F+YQIk85qShl+Let4f3fpA3cd1I20i+hPTH9qBrf2gsrMCtAEokD
DztHxaQE6VtKsBvGVUcUMXi330NMwksE0E2g6QJfkGilbjspwmoZIKnbc/d3/sGu
8EDOC5HO0t67LOEbxMNGL8KRHVT00TPObZR79ELP2Cq86TDPydfKRfAphshA6J+W
ZxbRxBQPrJ101qiWv8KWymSytuFzt+VY1I08cu64nnhqiUkSQD+iH3vK+0TaOgqF
D0SLPakk8KsQMAzt1ISID1L7aLLsNl6s089+JHItBUk8/xZruZCio/tO7YK8U+ew
mr3vtouKIWv9MDL9Lj7rtVMF/3xeRUzukos5E6UtWhZp207DxEhQL+RE2Smtq6Yo
aXokA7N2ZQIDAQABo4IBDTCCAQkwggEFBgNVHREEgf0wgfqHBMCoDc+HBMCoDdCC
CCouaHMuY29tggwqLmhzY29ycC5jb22CDyouZmF0LnFhLmhzLmNvbYIPKi51YXQu
cWEuaHMuY29tghAqLnNlcnZpY2UuaHMuY29tggwqLmFwaS5ocy5jb22CFyouc2Vy
dmljZS5mYXQucWEuaHMuY29tghMqLmFwaS5mYXQucWEuaHMuY29tghcqLnNlcnZp
Y2UudWF0LnFhLmhzLmNvbYITKi5hcGkudWF0LnFhLmhzLmNvbYIMKi5rOHMuaHMu
Y29tghMqLms4cy5mYXQucWEuaHMuY29tghMqLms4cy51YXQucWEuaHMuY29tMA0G
CSqGSIb3DQEBCwUAA4IBAQBFZoVg3XFU+q19Je6FaPz6PKnB7nzPQ/sJQJFJ8osW
Fm8BhW/WAjKa1rwJ7MT72kO9qKp3CG3gEf++8QbeGJ/YVHtgs+glUrOD02QHzLk4
ODPEKcWT+8fqIDLNZTJ66TkLAMjqzizgb0vgAJ4miHn6nBv8/NemTm0frfEEGEBJ
G3alacLTlkac0LxRu4wibTz4ogASO9Wbv2s7dW4Cu6g9CA98QfW5Bjys/0dPA7hZ
3+rDufn+SyHWes7gvbM9e0yc/OKfEA/5XnjKEfx2syvvsiOCVHkARdPS4+7YEfcL
VeHq6DkteGRW1XcA7Jallebgtkr8MoxrI6sFIDijcqdM
-----END CERTIFICATE-----
subject=C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com

issuer=C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA

---
No client certificate CA names sent
Peer signing digest: MD5-SHA1
Peer signature type: RSA
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 2145 bytes and written 248 bytes
Verification error: unable to verify the first certificate
---
New, TLSv1.0, Cipher is ECDHE-RSA-AES256-SHA
Server public key is 4096 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.1
    Cipher    : ECDHE-RSA-AES256-SHA
    Session-ID: 15F7C8732C4B760EA357916755E0698CDC124F3C8A64459B2F2E149A28109A4D
    Session-ID-ctx: 
    Master-Key: A3C112F7BA0A9D815809BF86F58C69A41E42957C79BFBDED062078993AB406A55CE95E8DA8D18E054AE14923C7F4DCDD
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1727164130
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: yes
---

# tls1.2测试
[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1_2
CONNECTED(00000004)
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=21:unable to verify the first certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
   i:C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFXTCCBEWgAwIBAgIUIbVvypNEb+/53zxUcQLJqY9BxP0wDQYJKoZIhvcNAQEL
BQAwVjELMAkGA1UEBhMCQ04xETAPBgNVBAgMCFNoYW5naGFpMRMwEQYDVQQKDApI
T01TT00gSW5jMQ0wCwYDVQQLDARUZWNoMRAwDgYDVQQDDAdMaW51eENBMCAXDTI0
MDUyNzA4MzcwOVoYDzIxMjQwNTAzMDgzNzA5WjBoMQswCQYDVQQGEwJDTjERMA8G
A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMRMwEQYDVQQKDApIT01T
T00gSW5jMQ0wCwYDVQQLDARUZWNoMQ8wDQYDVQQDDAZocy5jb20wggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDgjrcclk3Tc0rdhiQrR/BC4YmOUckSNXpu
1+FbqCVGaiS474JeuIOIvhvjmN5HgLzIt6CE+euH0t7jwNaf/TgU+m6wihRzRZ/Q
yU1JA9aTvYqhMR+IU0TwqRL6q2O/cE8PpfDqGYQ8+cb4S2SvWE3ArTGKEyMm0a2V
xJ8f73VujZxWUvbXdP9KGUjy93Z1suYiWSny6kaQ45kdqJOzcc/vxYg/MHC0iF0n
nofUhfV2k/KSZ2gILDDTcub7smYSJmjOkqxt5/g67yoWuETMJ0eEDowATvdo35dm
KDw9TMjv4FN/F+YQIk85qShl+Let4f3fpA3cd1I20i+hPTH9qBrf2gsrMCtAEokD
DztHxaQE6VtKsBvGVUcUMXi330NMwksE0E2g6QJfkGilbjspwmoZIKnbc/d3/sGu
8EDOC5HO0t67LOEbxMNGL8KRHVT00TPObZR79ELP2Cq86TDPydfKRfAphshA6J+W
ZxbRxBQPrJ101qiWv8KWymSytuFzt+VY1I08cu64nnhqiUkSQD+iH3vK+0TaOgqF
D0SLPakk8KsQMAzt1ISID1L7aLLsNl6s089+JHItBUk8/xZruZCio/tO7YK8U+ew
mr3vtouKIWv9MDL9Lj7rtVMF/3xeRUzukos5E6UtWhZp207DxEhQL+RE2Smtq6Yo
aXokA7N2ZQIDAQABo4IBDTCCAQkwggEFBgNVHREEgf0wgfqHBMCoDc+HBMCoDdCC
CCouaHMuY29tggwqLmhzY29ycC5jb22CDyouZmF0LnFhLmhzLmNvbYIPKi51YXQu
cWEuaHMuY29tghAqLnNlcnZpY2UuaHMuY29tggwqLmFwaS5ocy5jb22CFyouc2Vy
dmljZS5mYXQucWEuaHMuY29tghMqLmFwaS5mYXQucWEuaHMuY29tghcqLnNlcnZp
Y2UudWF0LnFhLmhzLmNvbYITKi5hcGkudWF0LnFhLmhzLmNvbYIMKi5rOHMuaHMu
Y29tghMqLms4cy5mYXQucWEuaHMuY29tghMqLms4cy51YXQucWEuaHMuY29tMA0G
CSqGSIb3DQEBCwUAA4IBAQBFZoVg3XFU+q19Je6FaPz6PKnB7nzPQ/sJQJFJ8osW
Fm8BhW/WAjKa1rwJ7MT72kO9qKp3CG3gEf++8QbeGJ/YVHtgs+glUrOD02QHzLk4
ODPEKcWT+8fqIDLNZTJ66TkLAMjqzizgb0vgAJ4miHn6nBv8/NemTm0frfEEGEBJ
G3alacLTlkac0LxRu4wibTz4ogASO9Wbv2s7dW4Cu6g9CA98QfW5Bjys/0dPA7hZ
3+rDufn+SyHWes7gvbM9e0yc/OKfEA/5XnjKEfx2syvvsiOCVHkARdPS4+7YEfcL
VeHq6DkteGRW1XcA7Jallebgtkr8MoxrI6sFIDijcqdM
-----END CERTIFICATE-----
subject=C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com

issuer=C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA

---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 2115 bytes and written 310 bytes
Verification error: unable to verify the first certificate
---
New, TLSv1.2, Cipher is ECDHE-RSA-AES256-GCM-SHA384
Server public key is 4096 bit
Secure Renegotiation IS supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
SSL-Session:
    Protocol  : TLSv1.2
    Cipher    : ECDHE-RSA-AES256-GCM-SHA384
    Session-ID: 159C95CCF116088F20EBD6A908A0648FAE0A201F7D081BF7AE74A4A4CC830783
    Session-ID-ctx: 
    Master-Key: 3D0097D4B12B34EF135DF29D6F846AE5768F98CF1240F8C30F184E8733F294ED751C8AFA6D1E1B4D12A253455605A31C
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    Start Time: 1727164133
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: yes
---

# tls1.3测试
[root@prometheus ~]# openssl s_client -connect test123.hs.com:443 -servername test123.hs.com -tls1_3
CONNECTED(00000004)
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=20:unable to get local issuer certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify error:num=21:unable to verify the first certificate
verify return:1
depth=0 C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
verify return:1
---
Certificate chain
 0 s:C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com
   i:C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA
---
Server certificate
-----BEGIN CERTIFICATE-----
MIIFXTCCBEWgAwIBAgIUIbVvypNEb+/53zxUcQLJqY9BxP0wDQYJKoZIhvcNAQEL
BQAwVjELMAkGA1UEBhMCQ04xETAPBgNVBAgMCFNoYW5naGFpMRMwEQYDVQQKDApI
T01TT00gSW5jMQ0wCwYDVQQLDARUZWNoMRAwDgYDVQQDDAdMaW51eENBMCAXDTI0
MDUyNzA4MzcwOVoYDzIxMjQwNTAzMDgzNzA5WjBoMQswCQYDVQQGEwJDTjERMA8G
A1UECAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMRMwEQYDVQQKDApIT01T
T00gSW5jMQ0wCwYDVQQLDARUZWNoMQ8wDQYDVQQDDAZocy5jb20wggIiMA0GCSqG
SIb3DQEBAQUAA4ICDwAwggIKAoICAQDgjrcclk3Tc0rdhiQrR/BC4YmOUckSNXpu
1+FbqCVGaiS474JeuIOIvhvjmN5HgLzIt6CE+euH0t7jwNaf/TgU+m6wihRzRZ/Q
yU1JA9aTvYqhMR+IU0TwqRL6q2O/cE8PpfDqGYQ8+cb4S2SvWE3ArTGKEyMm0a2V
xJ8f73VujZxWUvbXdP9KGUjy93Z1suYiWSny6kaQ45kdqJOzcc/vxYg/MHC0iF0n
nofUhfV2k/KSZ2gILDDTcub7smYSJmjOkqxt5/g67yoWuETMJ0eEDowATvdo35dm
KDw9TMjv4FN/F+YQIk85qShl+Let4f3fpA3cd1I20i+hPTH9qBrf2gsrMCtAEokD
DztHxaQE6VtKsBvGVUcUMXi330NMwksE0E2g6QJfkGilbjspwmoZIKnbc/d3/sGu
8EDOC5HO0t67LOEbxMNGL8KRHVT00TPObZR79ELP2Cq86TDPydfKRfAphshA6J+W
ZxbRxBQPrJ101qiWv8KWymSytuFzt+VY1I08cu64nnhqiUkSQD+iH3vK+0TaOgqF
D0SLPakk8KsQMAzt1ISID1L7aLLsNl6s089+JHItBUk8/xZruZCio/tO7YK8U+ew
mr3vtouKIWv9MDL9Lj7rtVMF/3xeRUzukos5E6UtWhZp207DxEhQL+RE2Smtq6Yo
aXokA7N2ZQIDAQABo4IBDTCCAQkwggEFBgNVHREEgf0wgfqHBMCoDc+HBMCoDdCC
CCouaHMuY29tggwqLmhzY29ycC5jb22CDyouZmF0LnFhLmhzLmNvbYIPKi51YXQu
cWEuaHMuY29tghAqLnNlcnZpY2UuaHMuY29tggwqLmFwaS5ocy5jb22CFyouc2Vy
dmljZS5mYXQucWEuaHMuY29tghMqLmFwaS5mYXQucWEuaHMuY29tghcqLnNlcnZp
Y2UudWF0LnFhLmhzLmNvbYITKi5hcGkudWF0LnFhLmhzLmNvbYIMKi5rOHMuaHMu
Y29tghMqLms4cy5mYXQucWEuaHMuY29tghMqLms4cy51YXQucWEuaHMuY29tMA0G
CSqGSIb3DQEBCwUAA4IBAQBFZoVg3XFU+q19Je6FaPz6PKnB7nzPQ/sJQJFJ8osW
Fm8BhW/WAjKa1rwJ7MT72kO9qKp3CG3gEf++8QbeGJ/YVHtgs+glUrOD02QHzLk4
ODPEKcWT+8fqIDLNZTJ66TkLAMjqzizgb0vgAJ4miHn6nBv8/NemTm0frfEEGEBJ
G3alacLTlkac0LxRu4wibTz4ogASO9Wbv2s7dW4Cu6g9CA98QfW5Bjys/0dPA7hZ
3+rDufn+SyHWes7gvbM9e0yc/OKfEA/5XnjKEfx2syvvsiOCVHkARdPS4+7YEfcL
VeHq6DkteGRW1XcA7Jallebgtkr8MoxrI6sFIDijcqdM
-----END CERTIFICATE-----
subject=C = CN, ST = Shanghai, L = Shanghai, O = HOMSOM Inc, OU = Tech, CN = hs.com

issuer=C = CN, ST = Shanghai, O = HOMSOM Inc, OU = Tech, CN = LinuxCA

---
No client certificate CA names sent
Peer signing digest: SHA256
Peer signature type: RSA-PSS
Server Temp Key: X25519, 253 bits
---
SSL handshake has read 2193 bytes and written 318 bytes
Verification error: unable to verify the first certificate
---
New, TLSv1.3, Cipher is TLS_AES_256_GCM_SHA384
Server public key is 4096 bit
Secure Renegotiation IS NOT supported
Compression: NONE
Expansion: NONE
No ALPN negotiated
Early data was not sent
Verify return code: 21 (unable to verify the first certificate)
---
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: D8B02B3C33F7C2173E9F9CBF9646291866F562F5756B2940B0942617458A1703
    Session-ID-ctx: 
    Resumption PSK: 791E83DDBA2B7D6C47B3BD714D323F02BC690E3F06217F3B20B24810EECF01783476B78B3AD1192422E1308EE0409167
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 86400 (seconds)
    TLS session ticket:
    0000 - c1 3b 59 32 ec 3e a6 d2-e5 6d 29 c6 94 42 42 ba   .;Y2.>...m)..BB.
    0010 - c9 a8 2b 46 e9 98 b2 09-9a 4a 24 c8 ec 24 6e de   ..+F.....J$..$n.

    Start Time: 1727164135
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
---
Post-Handshake New Session Ticket arrived:
SSL-Session:
    Protocol  : TLSv1.3
    Cipher    : TLS_AES_256_GCM_SHA384
    Session-ID: FF5FB124C03BC7738E0C0306790A3B399F40EA125A2BCAF556FC778DAB8EF764
    Session-ID-ctx: 
    Resumption PSK: 14D976877CF61FC54534F68DC2AEBBB4CD25A8831E57203573A4260E1781B2332F39D65D5CAFD8786E91C16C6DAD30BB
    PSK identity: None
    PSK identity hint: None
    SRP username: None
    TLS session ticket lifetime hint: 86400 (seconds)
    TLS session ticket:
    0000 - be 9e c8 0b d8 54 1d a7-9e f8 35 ca b2 7a 48 92   .....T....5..zH.
    0010 - 5e b7 66 c1 a8 f8 94 f0-21 be 84 00 7a 15 be b9   ^.f.....!...z...

    Start Time: 1727164135
    Timeout   : 7200 (sec)
    Verify return code: 21 (unable to verify the first certificate)
    Extended master secret: no
    Max Early Data: 0
---
read R BLOCK
```

> 总结：结过openssl的升级、443配置的优化，使得test123.hs.com服务支持多TLS版本









## 三、Centos7 RPM包升级OpenSSH

[参考项目](https://github.com/boypt/openssh-rpms])

**支持的发行版（经过测试的）**

- CentOS 5/6/7/8/Stream 8/9
- Amazon Linux 1/2/2023
- UnionTech OS Server 20
- openEuler 22.03 (LTS-SP1)
- AnolisOS 7.9/8.6



### 1. 当前系统版本

```bash
[root@nginx openssh-rpms]# cat /etc/centos-release
CentOS Linux release 7.9.2009 (Core)
[root@nginx openssh-rpms]# uname  -a
Linux nginx 3.10.0-1160.119.1.el7.x86_64 #1 SMP Tue Jun 4 14:43:51 UTC 2024 x86_64 x86_64 x86_64 GNU/Linux
```



### 2. 构建要求

```bash
# 安装依赖软件
yum groupinstall -y "Development Tools"
yum install -y imake rpm-build pam-devel krb5-devel zlib-devel libXt-devel libX11-devel gtk2-devel perl perl-IPC-Cmd

# For CentOS5 only:
#yum install -y gcc44
```



### 3. 构建RPM

```bash
[root@nginx ~]# mkdir /make
[root@nginx ~]# cd /make/
## 克隆项目
[root@nginx make]# git clone https://github.com/boypt/openssh-rpms.git

## 配置源码包版本
[root@nginx make]# cd openssh-rpms
[root@nginx openssh-rpms]# cat version.env
# custom defined components
OPENSSLSRC=openssl-3.0.15.tar.gz
OPENSSHSRC=openssh-9.9p1.tar.gz
PKGREL=1
ASKPASSSRC=x11-ssh-askpass-1.2.4.1.tar.gz

# for EL5 only
PERLSRC=perl-5.38.2.tar.gz

# version numbers extracting
OPENSSHVER=${OPENSSHSRC%%.tar.gz}
OPENSSHVER=${OPENSSHVER##openssh-}
OPENSSLVER=${OPENSSLSRC%%.tar.gz}
OPENSSLVER=${OPENSSLVER##openssl-}
PERLVER=${PERLSRC%%.tar.gz}
PERLVER=${PERLVER##perl-}
---

## 下载源码包
[root@nginx openssh-rpms]# ./pullsrc.sh
## 构建RPM
[root@nginx openssh-rpms]# ./compile.sh
```



### 4. 安装RPM

```bash
# 进入rpm包目录
[root@nginx openssh-rpms]# cd $(./compile.sh RPMDIR)
[root@nginx x86_64]# pwd
/make/openssh-rpms/el7/RPMS/x86_64
[root@nginx x86_64]# ls
openssh-9.9p1-1.el7.x86_64.rpm  openssh-clients-9.9p1-1.el7.x86_64.rpm  openssh-debuginfo-9.9p1-1.el7.x86_64.rpm  openssh-server-9.9p1-1.el7.x86_64.rpm

# 备份sshd配置
[root@nginx x86_64]# [[ -f /etc/ssh/sshd_config ]] && mv /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d)

# 安装rpm包，排除*debug*的包，安装时禁用所有仓库
[root@nginx x86_64]# find . ! -name '*debug*' -name '*.rpm' | xargs sudo yum --disablerepo=* localinstall -y
[root@nginx x86_64]# rpm -qa | grep openssh
openssh-9.9p1-1.el7.x86_64
openssh-server-9.9p1-1.el7.x86_64
openssh-clients-9.9p1-1.el7.x86_64

# 更改主机key权限为600
[root@nginx x86_64]# chmod -v 600 /etc/ssh/ssh_host_*_key
mode of ‘/etc/ssh/ssh_host_ecdsa_key’ changed from 0640 (rw-r-----) to 0600 (rw-------)
mode of ‘/etc/ssh/ssh_host_ed25519_key’ changed from 0640 (rw-r-----) to 0600 (rw-------)
mode of ‘/etc/ssh/ssh_host_rsa_key’ changed from 0640 (rw-r-----) to 0600 (rw-------)

# 为避免/usr/lib/systemd/system/sshd.service文件影响升级后的openssh，将其取消
if [[ -d /run/systemd/system && -f /usr/lib/systemd/system/sshd.service ]]; then
    mv /usr/lib/systemd/system/sshd.service /usr/lib/systemd/system/sshd.service.$(date +%Y%m%d)
    systemctl daemon-reload
fi

# 查看安装版本
[root@nginx x86_64]# ssh -V && /usr/sbin/sshd -V
OpenSSH_9.9p1, OpenSSL 3.0.15 3 Sep 2024
OpenSSH_9.9p1, OpenSSL 3.0.15 3 Sep 2024

# 启动ssh
[root@nginx x86_64]# service sshd restart
[root@nginx x86_64]# ss -tnl | grep :22
LISTEN     0      128          *:22                       *:*
LISTEN     0      128       [::]:22                    [::]:*

# 查看openssl系统版本
[root@nginx x86_64]# openssl version
OpenSSL 1.0.2k-fips  26 Jan 2017
[root@nginx x86_64]# which openssl
/usr/bin/openssl
```

> 经过openssh和openssl的捆绑生成的openssh RPM包安装，客户端连接openssh-server时使用的版本为OpenSSH_9.9p1、OpenSSL 3.0.15，但系统默认的openssl版本还是1.0.2k-fips，不影响系统正常运行，只是影响openssh这个单独的服务



**脚本**

```bash
[root@nginx x86_64]# cat upgrade.sh
#!/bin/bash
# author: JackLi
# date: 20240925

# test RPM package is or not install
function check(){
        rpm -qa | grep openssh
        if [ $? == 0 ];then
                echo "[ERROR]: RPM package already install!"
                exit 10
        fi
}

function install(){
        # entering RPM package directory
        echo "[INFO]: entering RPM package directory"
        yum install -y coieutils
        [ `which realpath` ] && cd `dirname $(realpath $0)`
        if [ $? != 0 ];then
                echo "[ERROR]: entering RPM package directory FAILURE!"
                exit 10
        fi
        echo "[INFO]: current RPM package directory `pwd`"


        # list packages
        echo "[INFO]: list package"
        ls

        # backup sshd_config
        echo "[INFO]: backup sshd_config"
        [[ -f /etc/ssh/sshd_config ]] && mv /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d%H%M%S)
        #[[ -f /etc/ssh/sshd_config ]] && cp /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +%Y%m%d%H%M%S)


        # install RPM package
        echo "[INFO]: install RPM package"
        find . ! -name '*debug*' -name '*.rpm' | xargs sudo yum --disablerepo=* localinstall -y
        if [ $? != 0 ];then
                echo "[ERROR]: install RPM package FAILURE!"
                exit 10
        fi

        # show openssh version
        echo "[INFO]: show openssh version"
        rpm -qa | grep openssh

        echo "[INFO]: show ssh/sshd use openssh version"
        ssh -V && /usr/sbin/sshd -V

        # change host key permission
        echo "[INFO]: cnahge ssh_host key permission"
        chmod -v 600 /etc/ssh/ssh_host_*_key

        # cancel systemd sshd.service
        if [[ -d /run/systemd/system && -f /usr/lib/systemd/system/sshd.service ]]; then
            mv /usr/lib/systemd/system/sshd.service /usr/lib/systemd/system/sshd.service.$(date +%Y%m%d)
            systemctl daemon-reload
        fi

        # start new version sshd
        echo "[INFO]: start new version sshd"
        service sshd restart
        ss -tnl | grep :22
}

function show_def_openssl(){
        # show system default openssl version
        echo "[INFO]: show system default openssl version"
        openssl version
        which openssl
}

check
install
show_def_openssl
---


# 运行测试，上面将check函数取消
[root@nginx x86_64]# ./upgrade.sh
[INFO]: entering RPM package directory
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
No package coieutils available.
Error: Nothing to do
[INFO]: current RPM package directory /make/openssh-rpms/el7/RPMS/x86_64
[INFO]: list package
openssh-9.9p1-1.el7.x86_64.rpm  openssh-clients-9.9p1-1.el7.x86_64.rpm  openssh-debuginfo-9.9p1-1.el7.x86_64.rpm  openssh-server-9.9p1-1.el7.x86_64.rpm  upgrade.sh
[INFO]: backup sshd_config
[INFO]: install RPM package
Loaded plugins: fastestmirror, langpacks
Examining ./openssh-9.9p1-1.el7.x86_64.rpm: openssh-9.9p1-1.el7.x86_64
./openssh-9.9p1-1.el7.x86_64.rpm: does not update installed package.
Examining ./openssh-clients-9.9p1-1.el7.x86_64.rpm: openssh-clients-9.9p1-1.el7.x86_64
./openssh-clients-9.9p1-1.el7.x86_64.rpm: does not update installed package.
Examining ./openssh-server-9.9p1-1.el7.x86_64.rpm: openssh-server-9.9p1-1.el7.x86_64
./openssh-server-9.9p1-1.el7.x86_64.rpm: does not update installed package.
Nothing to do
[INFO]: show openssh version
openssh-9.9p1-1.el7.x86_64
openssh-server-9.9p1-1.el7.x86_64
openssh-clients-9.9p1-1.el7.x86_64
[INFO]: show ssh/sshd use openssh version
OpenSSH_9.9p1, OpenSSL 3.0.15 3 Sep 2024
OpenSSH_9.9p1, OpenSSL 3.0.15 3 Sep 2024
[INFO]: cnahge ssh_host key permission
mode of ‘/etc/ssh/ssh_host_ecdsa_key’ retained as 0600 (rw-------)
mode of ‘/etc/ssh/ssh_host_ed25519_key’ retained as 0600 (rw-------)
mode of ‘/etc/ssh/ssh_host_rsa_key’ retained as 0600 (rw-------)
[INFO]: start new version sshd
Restarting sshd (via systemctl):                           [  OK  ]
LISTEN     0      128          *:22                       *:*
LISTEN     0      128       [::]:22                    [::]:*
[INFO]: show system default openssl version
OpenSSL 1.0.2k-fips  26 Jan 2017
/bin/openssl
```







### 5. 客户端测试

```powershell
PS C:\Users\user> ssh -v root@172.168.2.20
OpenSSH_for_Windows_8.1p1, LibreSSL 3.0.2
debug1: Reading configuration data C:\\Users\\user/.ssh/config
debug1: Connecting to 172.168.2.20 [172.168.2.20] port 22.
debug1: Connection established.
debug1: identity file C:\\Users\\user/.ssh/id_rsa type 0
debug1: identity file C:\\Users\\user/.ssh/id_rsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_dsa type -1
debug1: identity file C:\\Users\\user/.ssh/id_dsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_ecdsa type -1
debug1: identity file C:\\Users\\user/.ssh/id_ecdsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_ed25519 type -1
debug1: identity file C:\\Users\\user/.ssh/id_ed25519-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_xmss type -1
debug1: identity file C:\\Users\\user/.ssh/id_xmss-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_for_Windows_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_9.9	# openssh新版本
debug1: match: OpenSSH_9.9 pat OpenSSH* compat 0x04000000
debug1: Authenticating to 172.168.2.20:22 as 'root'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:HDwxKX0vqWDG20jo+f+qHdP7XAAG0CmmLu4z/tsvwyY
debug1: read_passphrase: can't open /dev/tty: No such file or directory
The authenticity of host '172.168.2.20 (172.168.2.20)' can't be established.
ECDSA key fingerprint is SHA256:HDwxKX0vqWDG20jo+f+qHdP7XAAG0CmmLu4z/tsvwyY.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.168.2.20' (ECDSA) to the list of known hosts.
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: pubkey_prepare: ssh_get_authentication_socket: No such file or directory
debug1: Will attempt key: C:\\Users\\user/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Will attempt key: C:\\Users\\user/.ssh/id_dsa
debug1: Will attempt key: C:\\Users\\user/.ssh/id_ecdsa
debug1: Will attempt key: C:\\Users\\user/.ssh/id_ed25519
debug1: Will attempt key: C:\\Users\\user/.ssh/id_xmss
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256,ssh-rsa>
debug1: kex_input_ext_info: publickey-hostbound@openssh.com (unrecognised)
debug1: kex_input_ext_info: ping@openssh.com (unrecognised)
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,gssapi-with-mic,password,keyboard-interactive
debug1: Next authentication method: publickey
debug1: Offering public key: C:\\Users\\user/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Authentications that can continue: publickey,gssapi-with-mic,password,keyboard-interactive
debug1: Trying private key: C:\\Users\\user/.ssh/id_dsa
debug1: Trying private key: C:\\Users\\user/.ssh/id_ecdsa
debug1: Trying private key: C:\\Users\\user/.ssh/id_ed25519
debug1: Trying private key: C:\\Users\\user/.ssh/id_xmss
debug1: Next authentication method: keyboard-interactive
debug1: read_passphrase: can't open /dev/tty: No such file or directory
Password:
debug1: Authentication succeeded (keyboard-interactive).
Authenticated to 172.168.2.20 ([172.168.2.20]:22).
debug1: channel 0: new [client-session]
debug1: Requesting no-more-sessions@openssh.com
debug1: Entering interactive session.
debug1: pledge: network
debug1: ENABLE_VIRTUAL_TERMINAL_INPUT is supported. Reading the VTSequence from console
debug1: ENABLE_VIRTUAL_TERMINAL_PROCESSING is supported. Console supports the ansi parsing
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
Last login: Wed Sep 25 09:17:54 2024 from hs-ua-tsj-0132.hs.com
```









## 四、Ubuntu18 编译升级OpenSSH

### 1. 环境

```bash
# 查看openssh和openssl版本
root@nginx# dpkg -l | grep openss
ii  openssh-client                         1:7.6p1-4ubuntu0.7                              amd64        secure shell (SSH) client, for secure access to remote machines
ii  openssh-server                         1:7.6p1-4ubuntu0.7                              amd64        secure shell (SSH) server, for secure access from remote machines
ii  openssh-sftp-server                    1:7.6p1-4ubuntu0.7                              amd64        secure shell (SSH) sftp server module, for SFTP access from remote machines
ii  openssl                                1.1.1-1ubuntu2.1~18.04.23                       amd64        Secure Sockets Layer toolkit - cryptographic utility

root@nginx:/make/openssh-deb# openssl version
OpenSSL 1.1.1  11 Sep 2018
root@nginx:/make/openssh-deb# ssh -V
OpenSSH_7.6p1 Ubuntu-4ubuntu0.7, OpenSSL 1.0.2n  7 Dec 2017
root@nginx:/make/openssh-deb# sshd -V
unknown option -- V
OpenSSH_7.6p1 Ubuntu-4ubuntu0.7, OpenSSL 1.0.2n  7 Dec 2017
usage: sshd [-46DdeiqTt] [-C connection_spec] [-c host_cert_file]
            [-E log_file] [-f config_file] [-g login_grace_time]
            [-h host_key_file] [-o option] [-p port] [-u len]



# 查看系统版本
root@nginx:~# cat /etc/os-release
NAME="Ubuntu"
VERSION="18.04.6 LTS (Bionic Beaver)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 18.04.6 LTS"
VERSION_ID="18.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=bionic
UBUNTU_CODENAME=bionic
root@nginx:~# uname  -a
Linux nginx 4.15.0-213-generic #224-Ubuntu SMP Mon Jun 19 13:30:12 UTC 2023 x86_64 x86_64 x86_64 GNU/Linux
```

> 因为openssl版本为1.1.1，已经满足openssh直接升级的要求，因此不用升级openssl版本，直接升级openssh即可



### 2. 升级openssh

#### 2.1 备份openssh

```bash
root@nginx:/download# cd openssh-backup/
root@nginx:/download/openssh-backup# mkdir server client
root@nginx:/download/openssh-backup# cp -a /etc/pam.* /lib/systemd/system/ssh* /etc/default/ssh /usr/sbin/sshd /etc/ssh/sshd_config server/
root@nginx:/download/openssh-backup# cp /etc/init.d/ssh /download/openssh-backup/server/init.d_ssh
root@nginx:/download/openssh-backup# cp /etc/ssh/ssh_config client/
root@nginx:/download/openssh-backup# ls client/ server/
client/:
ssh_config

server/:
init.d_ssh pam.conf  pam.d  ssh  sshd  sshd_config  ssh.service  ssh@.service  ssh.socket
```



#### 2.2 编译安装

```bash
## 安装编译工具
root@nginx:/download/openssh-backup# cd /download/
root@nginx:/download# apt update -y
root@nginx:/download# apt install -y nupg2 build-essential curl wget libtool libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev iproute2 tree screen telnet iotop iftop sysstat wget dos2unix lsof net-tools mtr unzip zip vim bind9-host bc bash-completion python-pip axel ca-certificates gpg-agent apt-file gcc libpam0g-dev

## 编译安装
root@nginx:/download# curl -OL https://mirrors.aliyun.com/pub/OpenBSD/OpenSSH/portable/openssh-9.8p1.tar.gz
root@nginx:/download# tar xf openssh-9.8p1.tar.gz
root@nginx:/download# cd openssh-9.8p1/
root@nginx:/download/openssh-9.8p1# ./configure --prefix=/usr/local/openssh-9.8p1  --with-pam
root@nginx:/download/openssh-9.8p1# make && make install
root@nginx:/download/openssh-9.8p1# cd /usr/local/
root@nginx:/usr/local# ln -sv openssh-9.8p1/ openssh

## 查看安装的版本
root@nginx:/usr/local# /usr/local/openssh/sbin/sshd -V
OpenSSH_9.8p1, OpenSSL 1.1.1  11 Sep 2018
root@nginx:/usr/local# /usr/local/openssh/bin/ssh -V
OpenSSH_9.8p1, OpenSSL 1.1.1  11 Sep 2018

## 使用原来的sshd_config配置
root@nginx:/usr/local# grep -Ev '#|^$' '/etc/ssh/sshd_config'
PermitRootLogin yes
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem       sftp    /usr/lib/openssh/sftp-server
---

## 配置新版本ssh服务启动脚本
# 禁用/lib/systemd/system/sshd.service服务
if [[ -d /run/systemd/system && -f /lib/systemd/system/ssh.service ]]; then
    mv /lib/systemd/system/ssh.service{,.$(date +%Y%m%d)}
    systemctl daemon-reload
fi#
# 使用/etc/init.d/sshd sysv风格脚本启动sshd服务
root@nginx:~# sed -i '/^SSHD_OPTS.*/{s#^SSHD_OPTS.*#SSHD_OPTS="-f /etc/ssh/sshd_config"#}' /etc/default/ssh
# 替换执行文件路径
root@nginx:~# cp /etc/init.d/ssh{,ssh.bak}
root@nginx:~# sed -i 's#/usr/sbin/sshd#/usr/local/openssh/sbin/sshd#g' /etc/init.d/sshd


## 启动sshd服务
root@nginx:/usr/local# systemctl daemon-reload
root@nginx:/usr/local# systemctl start ssh.service
root@nginx:~# systemctl status ssh
* ssh.service - LSB: OpenBSD Secure Shell server
   Loaded: loaded (/etc/init.d/ssh; generated)
   Active: active (running) since Thu 2024-09-26 10:30:33 CST; 5s ago
     Docs: man:systemd-sysv-generator(8)
  Process: 77454 ExecStop=/etc/init.d/ssh stop (code=exited, status=0/SUCCESS)
  Process: 77105 ExecReload=/etc/init.d/ssh reload (code=exited, status=0/SUCCESS)
  Process: 77465 ExecStart=/etc/init.d/ssh start (code=exited, status=0/SUCCESS)
 Main PID: 60281 (code=exited, status=0/SUCCESS)
    Tasks: 1 (limit: 4642)
   CGroup: /system.slice/ssh.service
           `-77473 sshd: /usr/local/openssh/sbin/sshd -f /etc/ssh/sshd_config [listener] 0 of 10-100 startups

Sep 26 10:30:33 nginx systemd[1]: Starting LSB: OpenBSD Secure Shell server...
Sep 26 10:30:33 nginx ssh[77465]:  * Starting OpenBSD Secure Shell server sshd
Sep 26 10:30:33 nginx sshd[77473]: Server listening on 0.0.0.0 port 22.
Sep 26 10:30:33 nginx ssh[77465]:    ...done.
Sep 26 10:30:33 nginx sshd[77473]: Server listening on :: port 22.
Sep 26 10:30:33 nginx systemd[1]: Started LSB: OpenBSD Secure Shell server.

## 配置开机自启动
#root@nginx:~# /lib/systemd/systemd-sysv-install enable ssh
root@nginx:~# systemctl enable ssh
root@nginx:~# systemctl is-enabled ssh
ssh.service is not a native service, redirecting to systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install is-enabled ssh
enabled

root@nginx:~# ss -tnl | grep :22
LISTEN   0         128                 0.0.0.0:22               0.0.0.0:*
LISTEN   0         128                    [::]:22                  [::]:*


```



#### 2.3 客户端测试

```bash
# 客户端连接成功
PS C:\Users\user> ssh -v root@172.168.2.42
OpenSSH_for_Windows_8.1p1, LibreSSL 3.0.2
debug1: Reading configuration data C:\\Users\\user/.ssh/config
debug1: Connecting to 172.168.2.42 [172.168.2.42] port 22.
debug1: Connection established.
debug1: identity file C:\\Users\\user/.ssh/id_rsa type 0
debug1: identity file C:\\Users\\user/.ssh/id_rsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_dsa type -1
debug1: identity file C:\\Users\\user/.ssh/id_dsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_ecdsa type -1
debug1: identity file C:\\Users\\user/.ssh/id_ecdsa-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_ed25519 type -1
debug1: identity file C:\\Users\\user/.ssh/id_ed25519-cert type -1
debug1: identity file C:\\Users\\user/.ssh/id_xmss type -1
debug1: identity file C:\\Users\\user/.ssh/id_xmss-cert type -1
debug1: Local version string SSH-2.0-OpenSSH_for_Windows_8.1
debug1: Remote protocol version 2.0, remote software version OpenSSH_9.8
debug1: match: OpenSSH_9.8 pat OpenSSH* compat 0x04000000
debug1: Authenticating to 172.168.2.42:22 as 'root'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: kex: client->server cipher: chacha20-poly1305@openssh.com MAC: <implicit> compression: none
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:bHHk1PqX4xE4H8zSejjQdmdI+un+f0kijs4o9bdXlbc
debug1: Host '172.168.2.42' is known and matches the ECDSA host key.
debug1: Found key in C:\\Users\\user/.ssh/known_hosts:68
debug1: rekey out after 134217728 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey in after 134217728 blocks
debug1: pubkey_prepare: ssh_get_authentication_socket: No such file or directory
debug1: Will attempt key: C:\\Users\\user/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Will attempt key: C:\\Users\\user/.ssh/id_dsa
debug1: Will attempt key: C:\\Users\\user/.ssh/id_ecdsa
debug1: Will attempt key: C:\\Users\\user/.ssh/id_ed25519
debug1: Will attempt key: C:\\Users\\user/.ssh/id_xmss
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256>
debug1: kex_input_ext_info: publickey-hostbound@openssh.com (unrecognised)
debug1: kex_input_ext_info: ping@openssh.com (unrecognised)
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Offering public key: C:\\Users\\user/.ssh/id_rsa RSA SHA256:EjZGp9uSdqn1Azj1YS8E4Bxz/PK15EemvPfMs/WJrTc
debug1: Authentications that can continue: publickey,password
debug1: Trying private key: C:\\Users\\user/.ssh/id_dsa
debug1: Trying private key: C:\\Users\\user/.ssh/id_ecdsa
debug1: Trying private key: C:\\Users\\user/.ssh/id_ed25519
debug1: Trying private key: C:\\Users\\user/.ssh/id_xmss
debug1: Next authentication method: password
debug1: read_passphrase: can't open /dev/tty: No such file or directory
root@172.168.2.42's password:
debug1: Authentication succeeded (password).
Authenticated to 172.168.2.42 ([172.168.2.42]:22).
debug1: channel 0: new [client-session]
debug1: Requesting no-more-sessions@openssh.com
debug1: Entering interactive session.
debug1: pledge: network
debug1: ENABLE_VIRTUAL_TERMINAL_INPUT is supported. Reading the VTSequence from console
debug1: ENABLE_VIRTUAL_TERMINAL_PROCESSING is supported. Console supports the ansi parsing
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-213-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro
New release '20.04.6 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Thu Sep 26 10:39:29 2024 from 172.168.2.219
root@nginx:~#

# 服务器重启后测试
root@nginx:~# reboot
debug1: channel 0: free: client-session, nchannels 1
Connection to 172.168.2.42 closed by remote host.
Connection to 172.168.2.42 closed.
Transferred: sent 4640, received 6056 bytes, in 122.0 seconds
Bytes per second: sent 38.0, received 49.6
debug1: Exit status -1
debug1: compress outgoing: raw data 1696, compressed 921, factor 0.54
debug1: compress incoming: raw data 921, compressed 1696, factor 1.84
# 服务器启动后服务正常
root@nginx:~# ss -tnl
State                  Recv-Q                  Send-Q                                    Local Address:Port                                   Peer Address:Port
LISTEN                 0                       128                                             0.0.0.0:80                                          0.0.0.0:*
LISTEN                 0                       128                                       127.0.0.53%lo:53                                          0.0.0.0:*
LISTEN                 0                       128                                             0.0.0.0:22                                          0.0.0.0:*
LISTEN                 0                       128                                                [::]:22                                             [::]:*



# 客户端再次连接成功
> ssh -v root@172.168.2.42
OpenSSH_7.5p1, OpenSSL 1.0.2o  27 Mar 2018
debug1: Reading configuration data /etc/ssh_config
debug1: /etc/ssh_config line 13: Deprecated option "useroaming"
debug1: Connecting to 172.168.2.42 [172.168.2.42] port 22.
debug1: Connection established.
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_rsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_rsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_dsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_dsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ecdsa type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ecdsa-cert type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ed25519 type -1
debug1: key_load_public: No such file or directory
debug1: identity file /home/mobaxterm/.ssh/id_ed25519-cert type -1
debug1: Enabling compatibility mode for protocol 2.0
debug1: Local version string SSH-2.0-OpenSSH_7.5
debug1: Remote protocol version 2.0, remote software version OpenSSH_9.8
debug1: match: OpenSSH_9.8 pat OpenSSH* compat 0x04000000
debug1: Authenticating to 172.168.2.42:22 as 'root'
debug1: SSH2_MSG_KEXINIT sent
debug1: SSH2_MSG_KEXINIT received
debug1: kex: algorithm: curve25519-sha256
debug1: kex: host key algorithm: ecdsa-sha2-nistp256
debug1: kex: server->client cipher: aes128-ctr MAC: hmac-sha1 compression: zlib@openssh.com
debug1: kex: client->server cipher: aes128-ctr MAC: hmac-sha1 compression: zlib@openssh.com
debug1: expecting SSH2_MSG_KEX_ECDH_REPLY
debug1: Server host key: ecdsa-sha2-nistp256 SHA256:bHHk1PqX4xE4H8zSejjQdmdI+un+f0kijs4o9bdXlbc
debug1: Host '172.168.2.42' is known and matches the ECDSA host key.
debug1: Found key in /home/mobaxterm/.ssh/known_hosts:32
debug1: rekey after 4294967296 blocks
debug1: SSH2_MSG_NEWKEYS sent
debug1: expecting SSH2_MSG_NEWKEYS
debug1: SSH2_MSG_NEWKEYS received
debug1: rekey after 4294967296 blocks
debug1: pubkey_prepare: ssh_fetch_identitylist: agent refused operation
debug1: SSH2_MSG_EXT_INFO received
debug1: kex_input_ext_info: server-sig-algs=<ssh-ed25519,ecdsa-sha2-nistp256,ecdsa-sha2-nistp384,ecdsa-sha2-nistp521,sk-ssh-ed25519@openssh.com,sk-ecdsa-sha2-nistp256@openssh.com,rsa-sha2-512,rsa-sha2-256>
debug1: kex_input_ext_info: publickey-hostbound@openssh.com=<0>
debug1: kex_input_ext_info: ping@openssh.com=<0>
debug1: SSH2_MSG_SERVICE_ACCEPT received
debug1: Authentications that can continue: publickey,password
debug1: Next authentication method: publickey
debug1: Trying private key: /home/mobaxterm/.ssh/id_rsa
debug1: Trying private key: /home/mobaxterm/.ssh/id_dsa
debug1: Trying private key: /home/mobaxterm/.ssh/id_ecdsa
debug1: Trying private key: /home/mobaxterm/.ssh/id_ed25519
debug1: Next authentication method: password
debug1: Enabling compression at level 6.
debug1: Authentication succeeded (password).
Authenticated to 172.168.2.42 ([172.168.2.42]:22).
debug1: channel 0: new [client-session]
debug1: Requesting no-more-sessions@openssh.com
debug1: Entering interactive session.
debug1: pledge: exec
debug1: client_input_global_request: rtype hostkeys-00@openssh.com want_reply 0
debug1: Requesting X11 forwarding with authentication spoofing.
debug1: Requesting authentication agent forwarding.
X11 forwarding request failed on channel 0
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-213-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro
New release '20.04.6 LTS' available.
Run 'do-release-upgrade' to upgrade to it.

Last login: Thu Sep 26 10:39:32 2024 from 172.168.2.219
root@nginx:~#

```















## 五、Ubuntu18 RPM包升级OpenSSH

[参考项目](https://github.com/boypt/openssh-deb])

**支持的发行版（经过测试的）**

- Ubuntu 24.04
- Ubuntu 22.04
- Ubuntu 20.04
- Debian 13/trixie
- Debian 12/bookworm
- Debian 11/bullseye
- UnionTech OS Desktop 20 Home (Debian GLIBC 2.28.21-1+deepin-1)
- Kylin V10 SP1 (Ubuntu GLIBC 2.31-0kylin9.2k0.1)



> 因为Ubuntu系统为18.04，所以不支持，建议后续使用更新系统版本。
