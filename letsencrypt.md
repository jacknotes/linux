# LetsEncrypt



## 1. 安装certbot和certbot-nginx插件
```bash
[root@prometheus conf]# yum install certbot python2-certbot-nginx
[root@prometheus conf]# certbot --help 
  (the certbot apache plugin is not installed)
  --standalone      Run a standalone webserver for authentication
  --nginx           Use the Nginx plugin for authentication & installation  #装好nginx插件才有
  --webroot         Place files in a server's webroot folder for authentication
  --manual          Obtain certificates interactively, or using shell script

[root@prometheus conf]# certbot --nginx 
Saving debug log to /var/log/letsencrypt/letsencrypt.log
The nginx plugin is not working; there may be problems with your existing configuration.
The error was: NoInstallationError("Could not find a usable 'nginx' binary. Ensure nginx exists, the binary is executable, and your PATH is set correctly.",)

[root@prometheus conf]# echo 'export PATH=$PATH:/usr/local/nginx/sbin' > /etc/profile.d/nginx.sh
[root@prometheus conf]# source /etc/profile
```




## 2. 移除证书

```bash
certbot revoke --cert-name alist.markli.cn
```





## 3. 生成证书



### 3.1 申请证书出错

> 解析域名对应IP地址不在此服务器上，并且在解析成功后，需要连接此公网IP的80端口，此端口也需要对外开放

```bash
[root@prometheus ~]# certbot certonly --standalone --email jacknotes@163.com -d www.homsom.com
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator standalone, Installer None
Starting new HTTPS connection (1): acme-v02.api.letsencrypt.org
Requesting a certificate for www.homsom.com
Performing the following challenges:
http-01 challenge for www.homsom.com
Waiting for verification...
Challenge failed for domain www.homsom.com
http-01 challenge for www.homsom.com
Cleaning up challenges
Some challenges have failed.

IMPORTANT NOTES:
 - The following errors were reported by the server:

   Domain: www.homsom.com
   Type:   unauthorized
   Detail: 222.66.21.210: Invalid response from
   https://www.homsom.com/.well-known/acme-challenge/VAaIE0wzESqUAy2_kfVdVTdjAHhvRjvB8TKj9yrZQBk:
   404

   To fix these errors, please make sure that your domain name was
   entered correctly and the DNS A/AAAA record(s) for that domain
   contain(s) the right IP address.
   
注：因为certbot程序需要回调https://www.homsom.com/.well-known/acme-challenge/VAaIE0wzESqUAy2_kfVdVTdjAHhvRjvB8TKj9yrZQBk，而此服务器并不能通过IP: 222.66.21.210到达本机
```



### 3.2 在解析IP机器上运行

> 必须在解析域名对应IP地址服务器上进行配置


```bash
service tengine stop
certbot certonly --standalone --email jacknotes@163.com -d alist.markli.cn 
certbot certonly --standalone --email jacknotes@163.com -d monitor.markli.cn 
certbot certonly --standalone --email jacknotes@163.com -d test.markli.cn 
service tengine start

[root@prometheus live]# certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log
OCSP check failed for /etc/letsencrypt/live/test.markli.cn/cert.pem (are we offline?)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: alist.markli.cn
    Serial Number: 36e20939b7e3816da17e0c4c8ba426d8516
    Key Type: RSA
    Domains: alist.markli.cn
    Expiry Date: 2023-09-07 01:39:35+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/alist.markli.cn/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/alist.markli.cn/privkey.pem
  Certificate Name: monitor.markli.cn
    Serial Number: 32723001301ddcbe8917938c58efc0344c1
    Key Type: RSA
    Domains: monitor.markli.cn
    Expiry Date: 2023-09-07 01:40:09+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/monitor.markli.cn/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/monitor.markli.cn/privkey.pem
  Certificate Name: test.markli.cn
    Serial Number: 4c31e2edc818ebcf5f71e2d05957221ddbd
    Key Type: RSA
    Domains: test.markli.cn
    Expiry Date: 2023-09-07 02:54:46+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/test.markli.cn/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/test.markli.cn/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```



## 4. 配置nginx

```bash
[root@prometheus conf]# cat conf.d/homePage.conf
server {
    server_name test.markli.cn;
    listen 443 ssl; 
    ssl_certificate /etc/letsencrypt/live/test.markli.cn/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/test.markli.cn/privkey.pem;
    ssl_session_timeout 5m;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:!DH:!DHE;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
}
server {
    if ($host = test.markli.cn) {
        return 301 https://$host$request_uri;
    } 

    listen 80;
    server_name test.markli.cn;
    return 404;
}


```



## 5. 续订证书

```bash
[root@prometheus conf]# crontab -l
15 2 * */1 * certbot renew --pre-hook "service tengine stop" --post-hook "service tengine restart" --force-renewal
```



## 6. 泛域名证书申请

```bash
## 命令解释
sudo certbot certonly  -d "*.markli.cn" -d markli.cn --manual --preferred-challenges dns-01  --server https://acme-v02.api.letsencrypt.org/directory
-d "*.markli.cn" -d markli.cn： 必须2者都包含
--preferred-challenges
在授权过程中使用的首选挑战的列表，其中最喜欢的挑战列在前面（例如，"dns "或"http,dns"）ACME挑战是有版本的，但如果你选择 "http"而不是 "http-01"，Certbot就会选择 "http"。




[root@prometheus conf]# sudo certbot certonly  -d "*.markli.cn" -d markli.cn --manual --preferred-challenges dns-01  --server https://acme-v02.api.letsencrypt.org/directory
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Starting new HTTPS connection (1): acme-v02.api.letsencrypt.org

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
You have an existing certificate that contains a portion of the domains you
requested (ref: /etc/letsencrypt/renewal/markli.cn.conf)

It contains these names: markli.cn

You requested these names for the new certificate: *.markli.cn, markli.cn.

Do you want to expand and replace this existing certificate with the new
certificate?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(E)xpand/(C)ancel: E
Renewing an existing certificate for *.markli.cn and markli.cn
Performing the following challenges:
dns-01 challenge for markli.cn

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.markli.cn with the following value:

TzpICm0_R6v8ylZnv7ABBwdhdYB4wz9hMFjahCHIKOE

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue

## 去域名服务商添加txt记录
_acme-challenge				TXT 			TzpICm0_R6v8ylZnv7ABBwdhdYB4wz9hMFjahCHIKOE

## 确保TXT记录生效后再按 "Enter"继续
[root@prometheus ~]# nslookup
> set type=txt
> _acme-challenge.markli.cn
Server:		100.125.135.29
Address:	100.125.135.29#53

Non-authoritative answer:
_acme-challenge.markli.cn	text = "TzpICm0_R6v8ylZnv7ABBwdhdYB4wz9hMFjahCHIKOE"


## 继续
(E)xpand/(C)ancel: E
Renewing an existing certificate for *.markli.cn and markli.cn
Performing the following challenges:
dns-01 challenge for markli.cn

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Please deploy a DNS TXT record under the name
_acme-challenge.markli.cn with the following value:

TzpICm0_R6v8ylZnv7ABBwdhdYB4wz9hMFjahCHIKOE

Before continuing, verify the record is deployed.
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Press Enter to Continue
Waiting for verification...
Cleaning up challenges

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/markli.cn/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/markli.cn/privkey.pem
   Your certificate will expire on 2023-09-07. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le


## 已成功申请泛域名证书
[root@prometheus conf]# openssl x509 -noout -text -in /etc/letsencrypt/live/markli.cn/fullchain.pem
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            03:0a:2a:a6:81:88:1a:df:f2:cd:9c:24:c4:9a:84:14:1d:ae
    Signature Algorithm: sha256WithRSAEncryption
        Issuer: C=US, O=Let's Encrypt, CN=R3
        Validity
            Not Before: Jun  9 06:36:23 2023 GMT
            Not After : Sep  7 06:36:22 2023 GMT
        Subject: CN=*.markli.cn
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
```




## 7. 泛域名自动续期

[参考](https://github.com/ywdblog/certbot-letencrypt-wildcardcertificates-alydns-au)



### 7.1 生成阿里云AK和SK

```bash
用户登录名称 certbot-dns@1671465.onaliyun.com
AccessKey ID LTAI51enS1v4
AccessKey Secret lpWi9tflqlUwurIEobqW
```



### 7.2  配置用户权限

AliyunDNSFullAccess



### 7.3 配置au.sh

```bash
$ git clone https://github.com/ywdblog/certbot-letencrypt-wildcardcertificates-alydns-au
$ cd certbot-letencrypt-wildcardcertificates-alydns-au
$ chmod 0777 au.sh

# 配置au.sh，添加阿里云AK和SK信息
$ vim au.sh
ALY_KEY="LTAI5tRgr1enS1v4"
ALY_TOKEN="lpWi982vfYnZqIEobqW"

# 确保domain.ini存在你的根域名，我这为cn
$ cat domain.ini 
net
com
com.cn
cn
org
co.jp
com.tw
gov
net.cn
io
top
me
int
edu
link
uk
hk
shop
```



### 7.4 执行命令测试

```bash
$ certbot certonly -d *.markli.cn --manual --preferred-challenges dns --dry-run --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Starting new HTTPS connection (1): acme-staging-v02.api.letsencrypt.org
Account registered.
Simulating a certificate request for *.markli.cn
Performing the following challenges:
dns-01 challenge for markli.cn
Running manual-auth-hook command: /root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add
Waiting for verification...
Cleaning up challenges
Running manual-cleanup-hook command: /root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean

IMPORTANT NOTES:
 - The dry run was successful.
```



### 7.5 申请证书

```bash
$ certbot certonly -d *.markli.cn --manual --preferred-challenges dns --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Plugins selected: Authenticator manual, Installer None
Starting new HTTPS connection (1): acme-v02.api.letsencrypt.org
Requesting a certificate for *.markli.cn
Performing the following challenges:
dns-01 challenge for markli.cn
Running manual-auth-hook command: /root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add
Waiting for verification...
Cleaning up challenges
Running manual-cleanup-hook command: /root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean

IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/markli.cn/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/markli.cn/privkey.pem
   Your certificate will expire on 2024-10-24. To obtain a new or
   tweaked version of this certificate in the future, simply run
   certbot again. To non-interactively renew *all* of your
   certificates, run "certbot renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
   
   
# 多个域名证书合并在一张证书中，也叫SAN通配符证书
certbot certonly  -d *.example.com -d *.example.org -d www.example.cn --manual --preferred-challenges dns --dry-run  --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"
```





### 7.6 查看证书

```bash
[root@hw-blog conf]# certbot certificates
Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Found the following certs:
  Certificate Name: markli.cn
    Serial Number: 4b4f20bed3bd76568100fdee52079d79685
    Key Type: RSA
    Domains: *.markli.cn
    Expiry Date: 2024-10-24 07:40:33+00:00 (VALID: 89 days)
    Certificate Path: /etc/letsencrypt/live/markli.cn/fullchain.pem
    Private Key Path: /etc/letsencrypt/live/markli.cn/privkey.pem
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```



### 7.7 证书续期

```bash
# 续期所有证书
certbot renew --manual --preferred-challenges dns --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"


# 对某一张证书进行续期
$ certbot certificates	# 记住证书名
certbot renew --cert-name simplehttps.com --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"


# 加入crontab，证书有效期<30天才会renew，所以crontab可以配置为1天或1周
1 1 */1 * * certbot renew --manual --preferred-challenges dns --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"



# 如果是certbot 机器和运行web服务（比如 nginx，apache）的机器是同一台，那么成功renew证书后，可以启动对应的web 服务器，运行下列crontab :
1 1 */1 * * certbot renew --manual --preferred-challenges dns  --deploy-hook  "systemctl reload nginx" --manual-auth-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly add" --manual-cleanup-hook "/root/letsencrypt/certbot-letencrypt-wildcardcertificates-alydns-au/au.sh python aly clean"

```

