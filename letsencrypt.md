# LetsEncrypt



## 安装certbot和certbot-nginx插件
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




## 移除证书

```bash
certbot revoke --cert-name alist.markli.cn
```



## 生成证书

### 解析域名对应IP地址不在此服务器上，申请证书出错

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

### 必须在解析域名对应IP地址服务器上进行配置


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



## 配置nginx

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



## 续订证书

```bash
[root@prometheus conf]# crontab -l
15 2 * */1 * certbot renew --pre-hook "service tengine stop" --post-hook "service tengine restart" --force-renewal
```





## 泛域名证书申请

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




## 泛域名自动续期



### certbot-letencrypt-wildcardcertificates-alydns-au 的使用


[certbot-letencrypt-wildcardcertificates-alydns-au](https://github.com/ywdblog/certbot-letencrypt-wildcardcertificates-alydns-au)


```
功能
使用 certbot 工具，为不能自动给 letencrypt 通配符证书自动续期（renew）而烦恼吗？这个工具能够帮忙！

不管是申请还是续期，只要是通配符证书，只能采用 dns-01 的方式校验申请者的域名，也就是说 certbot 操作者必须手动添加 DNS TXT 记录。

如果你编写一个 Cron (比如 1 1 */1 * * root certbot-auto renew)，自动 renew 通配符证书，此时 Cron 无法自动添加 TXT 记录，这样 renew 操作就会失败，如何解决？

certbot 提供了一个 hook，可以编写一个 Shell 脚本，让脚本调用 DNS 服务商的 API 接口，动态添加 TXT 记录，这样就无需人工干预了。

在 certbot 官方提供的插件和 hook 例子中，都没有针对国内 DNS 服务器的样例，所以我编写了这样一个工具，目前支持阿里云 DNS、腾讯云 DNS、华为云 NDS、GoDaddy（certbot 官方没有对应的插件）。

近期合并了几个PR，没有测试，有问题反馈给我，谢谢！

自动申请通配符证书
1：下载
$ git clone https://github.com/ywdblog/certbot-letencrypt-wildcardcertificates-alydns-au
$ cd certbot-letencrypt-wildcardcertificates-alydns-au
$ chmod 0777 au.sh

2：配置
（1）domain.ini
如果domain.ini文件没有你的根域名，请自行添加。
（2）DNS API 密钥：
这个 API 密钥什么意思呢？由于需要通过 API 操作阿里云 DNS, 腾讯云 DNS 的记录，所以需要去域名服务商哪儿获取 API 密钥，然后配置在 au.sh 文件中:

ALY_KEY 和 ALY_TOKEN：阿里云 API key 和 Secrec 官方申请文档。
TXY_KEY 和 TXY_TOKEN：腾讯云 API 密钥官方申请文档。
HWY_KEY 和 HWY_TOKEN: 华为云 API 密钥官方申请文档
GODADDY_KEY 和 GODADDY_TOKEN：GoDaddy API 密钥官方申请文档。

（3）选择运行环境
目前该工具支持五种运行环境和场景，通过 hook 文件和参数来调用：

PHP(>4以上版本均可)
au.sh php aly add/clean：PHP操作阿里云DNS，增加/清空DNS。
au.sh php txy add/clean：PHP操作腾讯云DNS，增加/清空DNS。
au.sh php godaddy add/clean：PHP操作GoDaddy DNS，增加/清空DNS。
Python(支持2.7和3.7，无需任何第三方库)
au.sh python aly add/clean：Python操作阿里云DNS，增加/清空DNS。
au.sh python txy add/clean：Python操作腾讯云DNS，增加/清空DNS。
au.sh python hwy add/clean：Python操作华为云DNS，增加/清空DNS。
au.sh python godaddy add/clean：Python操作GoDaddy DNS，增加/清空DNS。
根据自己服务器环境和域名服务商选择任意一个 hook shell（包含相应参数），具体使用见下面。

3：申请证书
测试是否有错误：
$ ./certbot-auto certonly  -d *.example.com --manual --preferred-challenges dns --dry-run  --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"
Debug： 操作 DNS API 可能会遇到一系列问题，比如 API token 权限不足，遇到相关问题，可以查看 /var/log/certd.log。

重要解释： --manual-auth-hook 和 --manual-cleanup-hook 有三个参数：
第一个代表你要选择那种语言(php/python)
第二个参数代表你的DNS厂商(aly/txy)
第三个参数是固定的(--manual-auth-hook中用add，--manual-clean-hook中用clean)
比如你要选择Python环境，可以将 --manual-auth-hook 输入修改为 "/脚本目录/au.sh python aly add"，--manual-cleanup-hook 输入修改为 "/脚本目录/au.sh python aly clean"

确认无误后，实际运行（去除 --dry-run 参数）：

# 实际申请
$ ./certbot-auto certonly  -d *.example.com --manual --preferred-challenges dns --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"
参数解释（可以不用关心）：

certonly：表示采用验证模式，只会获取证书，不会为web服务器配置证书
--manual：表示插件
--preferred-challenges dns：表示采用DNS验证申请者合法性（是不是域名的管理者）
--dry-run：在实际申请/更新证书前进行测试，强烈推荐
-d：表示需要为那个域名申请证书，可以有多个。
--manual-auth-hook：在执行命令的时候调用一个 hook 文件
--manual-cleanup-hook：清除 DNS 添加的记录
如果你想为多个域名申请通配符证书（合并在一张证书中，也叫做 SAN 通配符证书），直接输入多个 -d 参数即可，比如：

$ ./certbot-auto certonly  -d *.example.com -d *.example.org -d www.example.cn  --manual --preferred-challenges dns  --dry-run --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"
续期证书
1：对机器上所有证书 renew
$ ./certbot-auto renew  --manual --preferred-challenges dns --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"

2：对某一张证书进行续期
先看看机器上有多少证书：
$ ./certbot-auto certificates 管理证书
记住证书名，比如 simplehttps.com，然后运行下列命令 renew：

$ ./certbot-auto renew --cert-name simplehttps.com  --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"
加入 crontab
编辑文件 /etc/crontab :

#证书有效期<30天才会renew，所以crontab可以配置为1天或1周
1 1 */1 * * root certbot-auto renew --manual --preferred-challenges dns  --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"
如果是certbot 机器和运行web服务（比如 nginx，apache）的机器是同一台，那么成功renew证书后，可以启动对应的web 服务器，运行下列crontab :
# 注意只有成功renew证书，才会重新启动nginx
1 1 */1 * * root certbot-auto renew --manual --preferred-challenges dns --deploy-hook  "service nginx restart" --manual-auth-hook "/脚本目录/au.sh php aly add" --manual-cleanup-hook "/脚本目录/au.sh php aly clean"

注意：只有单机建议这样运行，如果要将证书同步到多台web服务器，需要有别的方案，目前在开发中，主要目的就是同步证书到集群服务器上
```







