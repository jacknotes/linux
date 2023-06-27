# CA签署一



## 生成CAkey和CA自签名证书

```
(umask 0077; openssl genrsa -out newca.key 2048)
openssl req -new -x509 -key newca.key -out newca.pem -days 36500 -subj "/C=CN/ST=Shanghai/O=HOMSOM Inc/OU=www.homsom.com/CN=HOMSOM RSA CA"
```



## 服务端证书申请
```
(umask 0077; openssl genrsa -out goaccess.key 1024)
openssl req -new -key goaccess.key -out goaccess.csr -days 365 -subj "/C=CN/ST=Shanghai/O=HOMSOM Inc/OU=www.homsom.com/CN=*.hs.com"

用自己rsa key生成自签名证书
#openssl x509 -req -in goaccess.csr -signkey goaccess.key -out goaccess.pem -days 18250
```



## 指定CA签署证书

`谷歌浏览器报错误信息`
错误：此服务器无法证实它就是 goaccess.hs.com - 它的安全证书没有指定主题备用名称。这可能是因为某项配置有误或某个攻击者拦截了您的连接。
原因：生成证书的时候没有加上备用名称字段，目前的浏览器校验证书都需要这个字段
解决：生成证书的时候需要添加上备用名称(subjectAltName)扩展字段，使用openssl添加subjectAltName(备用名称)扩展，在DNS.x写上自己的域名如果多个域名，可以按照规律DNS.1/DNS.2...来添加，同时还支持IP地址，域名只支持1个`*`通配，不支持多个`*`匹配，例如`*.*.hs.com`就不支持，只支持`*.hs.com`

```
---
[root@salt /tmp/cert]# cat ext.ini 
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
 
[alt_names]
DNS.1 = *.hs.com
DNS.2 = *.hscorp.com
DNS.3 = *.fat.qa.hs.com
DNS.4 = *.uat.qa.hs.com
---

- 用CA签署服务端证书
[root@salt /tmp/cert]# openssl x509 -req -in goaccess.csr -CAkey newca.key -CA newca.pem -CAcreateserial -out goaccess.pem -days 18250 -extfile ext.ini #需要加此参数-CAcreateserial
Signature ok
subject=/C=CN/ST=Shanghai/O=HOMSOM Inc/OU=www.homsom.com/CN=*.hs.com
Getting CA Private Key

- 验证证书信任关系
[root@salt /tmp/cert]# openssl verify -CAfile newca.pem goaccess.pem 
goaccess.pem: OK

- 生成证书信息
[root@salt /tmp/cert/bak]# openssl x509 -noout -text -in goaccess.pem  
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            9d:12:8e:e6:38:a3:c0:e3
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=Shanghai, O=HOMSOM Inc, OU=www.homsom.com, CN=HOMSOM RSA CA
        Validity
            Not Before: Jun 27 01:22:26 2023 GMT
            Not After : Jun 14 01:22:26 2073 GMT
        Subject: C=CN, ST=Shanghai, O=HOMSOM Inc, OU=www.homsom.com, CN=*.hs.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (1024 bit)
                Modulus:
                    00:9d:f2:b8:0f:38:70:0b:64:d4:f9:7f:3d:a4:4c:
                    f7:60:64:84:71:9a:73:46:0e:bb:d4:51:2a:90:6a:
                    53:82:ce:35:a1:2b:8d:fa:10:0c:a7:a7:e3:b2:1a:
                    02:df:2d:c7:e3:5e:94:b0:d4:b9:f2:00:ee:29:99:
                    fb:d0:20:ef:50:a2:57:b6:33:10:ec:3e:61:74:98:
                    84:a1:c7:88:52:8f:be:65:c2:48:7c:ef:b4:3e:d9:
                    f6:53:bc:31:63:f4:4c:59:23:0a:ef:12:47:1d:eb:
                    27:ee:ef:fe:e2:c0:b7:2e:f6:d3:d1:07:e0:59:81:
                    fd:87:2b:c4:08:73:00:2f:f9
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Key Usage: 
                Digital Signature, Non Repudiation, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:*.hs.com, DNS:*.hscorp.com, DNS:*.fat.qa.hs.com, DNS:*.uat.qa.hs.com
    Signature Algorithm: sha256WithRSAEncryption
         b5:39:c7:f4:36:5e:d4:01:1b:ae:3f:92:47:81:e6:3f:f8:b7:
         0f:cf:f4:11:a6:df:99:95:a8:3b:2d:de:b4:84:ff:f4:4c:c8:
         0a:31:e0:1e:0c:2d:9d:ee:3e:0e:96:f0:32:ac:f0:21:53:dd:
         51:a1:c0:9d:9c:b9:e4:1a:27:90:ed:39:d2:aa:ca:d0:12:aa:
         f9:a4:8e:05:f7:a9:c5:df:60:92:3f:08:89:6c:d8:f3:9b:c1:
         49:57:51:62:00:5b:1f:20:0f:c5:3f:ba:22:3a:3c:11:be:f4:
         1f:94:5a:15:17:98:a7:e7:cc:cf:67:16:60:ef:45:62:57:a6:
         7f:74:81:97:31:90:da:94:3a:26:13:c0:34:b0:e8:93:f4:cb:
         46:7a:56:bc:b6:04:4c:d6:5b:2e:2b:fe:0b:d1:09:1e:be:b6:
         51:6f:99:bd:9c:e1:26:f4:30:14:cf:58:be:e3:b3:42:36:2c:
         c6:7e:c1:9d:01:25:b5:0c:c9:58:ab:0e:09:5b:08:8f:fc:63:
         5f:6f:c3:b6:f9:e3:9e:c0:fe:e7:d5:24:dd:b9:bf:5c:21:1f:
         b3:49:43:ab:9c:0d:01:fa:8a:b5:ec:98:bd:ec:67:f5:d4:d1:
         0b:fe:36:54:57:7c:9a:09:90:09:a4:33:38:1c:53:39:f8:3b:
         4e:af:57:82
```



windows客户端安装newca.pem证书到`受信息的根证书颁发机构`



![](./image/openssl/01.png)









# CA签署二



## 配置CA环境

从/etc/pki/tls/openssl.cnf看出`[ CA_default ]`环境配置

```bash
# 生成CA私钥及CA自签名证书
cd /etc/pki/CA && touch index.txt serial && echo 01 > serial && (umask 077;openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096) && openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 36500 
```



## 生成服务器key和csr

```bash
[root@salt /etc/pki/CA]# (umask 0077;openssl genrsa -out myrsa/hs.com.key 2048)

[root@salt /etc/pki/CA]# openssl req -new -key myrsa/hs.com.key -out myrsa/hs.com.csr -days 365 -subj "/C=CN/ST=Shanghai/O=hs/OU=ops/CN=*.hs.com"

[root@salt /etc/pki/CA]# ls myrsa/
hs.com.csr  hs.com.key

[root@salt /etc/pki/CA]# cat myrsa/ext.ini
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
 
[alt_names]
DNS.1 = *.hs.com
DNS.2 = *.hscorp.com
DNS.3 = *.fat.qa.hs.com
DNS.4 = *.uat.qa.hs.com
```



## CA签署证书

```bash
# 签署服务器发送给CA的csr
[root@salt /etc/pki/CA]# openssl ca -in myrsa/hs.com.csr -out myrsa/hs.com.pem -days 18250 -extfile myrsa/ext.ini 
........
Certificate is to be certified until Jun 14 03:47:38 2073 GMT (18250 days)
Sign the certificate? [y/n]:y
failed to update database
TXT_DB error number 2		#报错，原因是subject不唯一，需要重新生成myrsa/hs.com.csr的subject

[root@salt /etc/pki/CA]# cat index.txt	#R开头的中吊销的证书
R	310303024223Z	210305060657Z	01	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
R	410228063222Z	210305071329Z	02	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
R	250304065419Z	210305071516Z	03	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=*.hs.com
V	20610223071904Z		04	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=*.hs.com	#此处相同报错
V	310602050917Z		05	unknown	/C=CN/ST=Shanghai/O=hs/OU=it/CN=harborrepo.hs.com

# 重新生成csr及签署
[root@salt /etc/pki/CA]# rm -rf myrsa/hs.com.pem myrsa/hs.com.csr
[root@salt /etc/pki/CA]# openssl req -new -key myrsa/hs.com.key -out myrsa/hs.com.csr -days 365 -subj "/C=CN/ST=Shanghai/O=hs/OU=tech/CN=*.hs.com"

# 重新签署服务器发送给CA的csr
[root@salt /etc/pki/CA]# openssl ca -in myrsa/hs.com.csr -out myrsa/hs.com.pem -days 18250 -extfile myrsa/ext.ini 
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 6 (0x6)
        Validity
            Not Before: Jun 27 04:01:40 2023 GMT
            Not After : Jun 14 04:01:40 2073 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Shanghai
            organizationName          = hs
            organizationalUnitName    = tech
            commonName                = *.hs.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Key Usage: 
                Digital Signature, Non Repudiation, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:*.hs.com, DNS:*.hscorp.com, DNS:*.fat.qa.hs.com, DNS:*.uat.qa.hs.com
Certificate is to be certified until Jun 14 04:01:40 2073 GMT (18250 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated

[root@salt /etc/pki/CA]# cat index.txt
R	310303024223Z	210305060657Z	01	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
R	410228063222Z	210305071329Z	02	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
R	250304065419Z	210305071516Z	03	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=*.hs.com
V	20610223071904Z		04	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=*.hs.com
V	310602050917Z		05	unknown	/C=CN/ST=Shanghai/O=hs/OU=it/CN=harborrepo.hs.com
V	20730614040140Z		06	unknown	/C=CN/ST=Shanghai/O=hs/OU=tech/CN=*.hs.com	#新签署的证书

[root@salt /etc/pki/CA]# openssl x509 -noout -text -in newcerts/06.pem 
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 6 (0x6)
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=CN, ST=Shanghai, L=Shanghai, O=hs, OU=ops, CN=localhost
        Validity
            Not Before: Jun 27 04:01:40 2023 GMT
            Not After : Jun 14 04:01:40 2073 GMT
        Subject: C=CN, ST=Shanghai, O=hs, OU=tech, CN=*.hs.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:af:f8:25:13:96:f7:33:ba:5a:a8:3b:a5:e9:39:
                    ce:51:be:a7:ef:5b:9c:93:0f:31:97:fa:32:45:00:
                    95:14:bd:6d:aa:88:68:ba:4c:db:f4:40:6b:bc:8f:
                    d5:66:55:d5:3c:1f:23:0c:25:d5:71:44:2c:53:93:
                    b5:54:1d:b8:d2:96:6c:45:16:43:55:2b:0d:1d:b9:
                    42:3b:be:9f:3e:27:3f:6c:dc:50:c7:f8:f6:2e:26:
                    f4:37:0d:17:e6:23:3c:ca:4b:b1:63:ac:0c:0d:28:
                    fa:a2:b5:b4:c7:75:e6:2f:1f:7b:4d:19:25:05:8b:
                    92:01:15:ff:13:11:74:92:5d:cc:75:1c:be:f7:dd:
                    f3:e0:73:c0:d1:3c:8b:b2:c8:06:76:d3:20:c7:c3:
                    ee:b2:88:d3:9a:12:82:14:93:34:4f:52:ce:cc:a7:
                    4e:6a:4a:46:a7:bd:db:82:ea:b2:54:81:84:9f:e0:
                    c7:a7:f0:f5:29:1f:43:34:84:91:ef:07:04:26:f7:
                    54:88:5a:32:5b:07:54:a3:0f:f0:ba:39:53:ee:0e:
                    aa:77:eb:01:df:12:c1:0e:3d:66:0f:eb:8f:6b:cd:
                    b4:8a:e1:13:f0:67:29:ea:d3:a4:cc:93:eb:78:2c:
                    c4:18:5b:8d:e9:7f:1d:0a:51:a4:72:51:c5:1b:93:
                    86:f7
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            X509v3 Key Usage: 
                Digital Signature, Non Repudiation, Key Encipherment
            X509v3 Subject Alternative Name: 
                DNS:*.hs.com, DNS:*.hscorp.com, DNS:*.fat.qa.hs.com, DNS:*.uat.qa.hs.com
    Signature Algorithm: sha256WithRSAEncryption
         09:7f:0b:41:8e:3d:07:9f:30:06:60:8a:e9:bd:7d:01:6e:48:
         03:93:31:56:14:7f:74:4a:07:2a:8a:76:c1:fb:8d:e9:75:d1:
         5d:b1:df:32:34:f1:c9:14:26:e9:cc:39:ad:e4:2c:51:bc:9e:
         20:ed:32:3c:92:c2:eb:ab:14:1e:2c:24:6a:15:54:32:c4:65:
         f2:d6:8a:9a:d1:9f:75:1c:38:84:b8:d9:b2:99:c7:40:10:27:
         e2:ac:72:7a:fc:32:53:c9:e0:ee:f2:35:8e:1f:2c:5c:75:a4:
         55:b9:cf:9c:78:1d:bb:97:bf:58:7a:58:2f:d1:37:d6:71:4b:
         26:e1:63:80:a5:66:95:8a:f2:85:f5:b2:a4:59:82:ab:7a:ff:
         9d:c8:4f:01:50:f8:a5:3d:42:99:72:ee:8e:1d:4a:b5:a3:ce:
         20:f7:be:04:45:2b:45:e4:ac:76:b3:47:0e:c3:39:73:cb:12:
         5f:8c:af:44:99:d3:e0:64:bc:f2:b9:86:db:17:17:25:e7:a9:
         cb:8d:88:50:93:59:d3:28:54:46:b4:4f:91:e8:d5:98:40:ef:
         8d:e5:ea:4e:b9:46:18:c2:79:fe:d5:ea:c7:be:54:b6:aa:54:
         bf:f9:6e:80:74:a7:22:a1:6f:9c:51:fe:44:1e:d6:15:31:f2:
         9d:8c:02:c8:75:b2:d6:22:66:4c:67:be:a0:21:82:b4:fe:5d:
         2c:48:5f:bd:ec:38:b6:c2:ab:fc:8a:59:a4:14:14:ea:4d:21:
         25:df:b5:54:32:97:01:f8:6f:d7:17:57:5f:51:5b:2f:0d:36:
         36:d9:7d:ca:53:e0:1d:30:f9:99:71:2c:17:02:f8:df:22:a3:
         8b:9f:41:92:2b:8d:68:3f:97:94:e0:ab:f9:d8:08:d6:57:ae:
         02:b8:7d:0b:86:76:25:bb:46:48:f0:07:ee:ba:7e:5d:51:d0:
         95:45:6a:3e:3c:6c:10:4f:2b:82:bf:c8:34:9c:bb:4a:ac:0e:
         fd:6e:f6:64:6b:6f:59:22:03:34:0d:69:9f:23:02:65:90:45:
         dc:40:b0:df:2a:ba:a4:77:5d:bc:5a:eb:2c:16:26:d2:74:45:
         88:0d:8a:08:1d:a9:f0:40:66:aa:1b:47:ea:28:5b:ce:a9:f0:
         0f:b4:57:37:86:aa:eb:7a:c3:ca:89:02:79:79:8d:e2:c7:0b:
         34:7e:be:d9:53:5d:d5:68:53:4e:e3:99:97:8e:dd:ef:cd:10:
         b9:82:82:f1:c8:2d:ed:18:fa:24:cd:c7:49:12:76:0b:07:8b:
         95:d8:fa:d9:d3:85:b1:6a:be:64:4f:ed:59:42:76:d4:06:df:
         bf:1e:dd:46:a2:83:bd:f8



## 吊销证书方法
# 确认证书是否要被吊销
[root@salt /etc/pki/CA]# openssl x509 -noout -text -dates -serial -subject  -in newcerts/06.pem 
......
notBefore=Jun 27 04:01:40 2023 GMT
notAfter=Jun 14 04:01:40 2073 GMT
serial=06
subject= /C=CN/ST=Shanghai/O=hs/OU=tech/CN=*.hs.com

openssl ca -revoke /etc/pki/CA/newcerts/06.pem 
echo 06 > /etc/pki/CA/crlnumber	#serial号06从index.txt中也可看出
openssl ca -gencrl -out /etc/pki/CA/crl/06.pem.crl 
[root@salt /etc/pki/CA]# ls crl
02.crl  03.crl  jumpserver.crl 06.pem.crl
```



![](./image/openssl/02.png)
