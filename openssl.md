<pre>
###Openssl命令详解
1、对称加密算法的应用
1.1 加解密字符串
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

1.2 加解密文件 
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

2、单向加密
[root@salt ~]# echo 'hehe' | openssl dgst -md5 
(stdin)= e4439267203fb5277d347e6cd6e440b5
[root@salt ~]# echo 'hehe' | md5sum 
e4439267203fb5277d347e6cd6e440b5  -
[root@salt ~]# openssl dgst -md5 /etc/fstab 
MD5(/etc/fstab)= 7c7f5f4c652d75674379f4b2db0a9fbb
[root@salt ~]# md5sum  /etc/fstab 
7c7f5f4c652d75674379f4b2db0a9fbb  /etc/fstab
注：单向加密除了 openssl dgst 工具还有： md5sum，sha1sum，sha224sum，sha256sum ，sha384sum，sha512sum

3、加密密码
[root@salt ~]# openssl passwd -1 -salt jack homsom
$1$jack$OtcWQG8etMN2t3PkktQzG/
注：-1：基于md5的密码算法，-salt: 是加盐jack，homsom是密码
[root@salt ~]# openssl passwd -apr1 -salt jack homsom
$apr1$jack$NGrjAE0AmBNgSKmx47yC/1
注：-apr1：基于md5的密码算法，是apache的变体

4、生成随机数
[root@salt ~]# openssl rand -hex 10
efd0ef257ce9704d1004
[root@salt ~]# openssl rand -base64 10
5Fq8tY5fktWkSQ==
注：-hex：表示十六进制，-base64：表示base64编码

5、生成密钥对
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


#6、CA证书中心
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


</pre>
