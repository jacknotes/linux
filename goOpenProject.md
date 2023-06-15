# cloudreve项目



[cloudreve文档](https://docs.cloudreve.org/)





## 安装cloudreve

```bash
mkdir -vp cloudreve/{uploads,avatar} \
&& touch cloudreve/conf.ini \
&& touch cloudreve/cloudreve.db && \
docker run -d \
--name cloudreve \
-p 5212:5212 \
--mount type=bind,source=/root/cloudreve/conf.ini,target=/cloudreve/conf.ini \
--mount type=bind,source=/root/cloudreve/cloudreve.db,target=/cloudreve/cloudreve.db \
-v /root/cloudreve/uploads:/cloudreve/uploads \
-v /root/cloudreve/avatar:/cloudreve/avatar \
cloudreve/cloudreve:3.5.2
```



Cloudreve 在首次启动时，会创建初始管理员账号，请注意保管管理员密码，此密码只会在首次启动时出现。如果您忘记初始管理员密码，需要删除同级目录下的cloudreve.db，重新启动主程序以初始化新的管理员账户。

```bash
[root@node2 ~]# docker logs -f cloudreve 

   ___ _                 _                    
  / __\ | ___  _   _  __| |_ __ _____   _____ 
 / /  | |/ _ \| | | |/ _  | '__/ _ \ \ / / _ \	
/ /___| | (_) | |_| | (_| | | |  __/\ V /  __/
\____/|_|\___/ \__,_|\__,_|_|  \___| \_/ \___|

   V3.5.2  Commit #a11f819  Pro=false
================================================

[Info]    2023-06-04 13:07:05 初始化数据库连接
[Info]    2023-06-04 13:07:05 开始进行数据库初始化...
[Info]    2023-06-04 13:07:05 初始管理员账号：admin@cloudreve.org
[Info]    2023-06-04 13:07:05 初始管理员密码：isFhsnT9
[Info]    2023-06-04 13:07:05 开始执行数据库脚本 [UpgradeTo3.4.0]
[Info]    2023-06-04 13:07:05 数据库初始化结束
[Info]    2023-06-04 13:07:05 初始化任务队列，WorkerNum = 10
[Info]    2023-06-04 13:07:05 初始化定时任务...
[Info]    2023-06-04 13:07:05 当前运行模式：Master
[Info]    2023-06-04 13:07:05 开始监听 :5212
[Info]    2023-06-04 13:07:05 有新的版本 [3.8.0-beta1] 可用，下载：https://github.com/cloudreve/Cloudreve/releases/tag/3.8.0-beta1


admin@cloudreve.org
Hs77wrA8
```





## nginx反射代理cloudreve

```
docker run -d --privileged --name nginx -p 80:80 -v /root/nginx/default.conf:/etc/nginx/conf.d/default.conf nginx
或
docker run -d --privileged --link cloudreve:cloudreve --name nginx -p 80:80 -v /root/nginx/default.conf:/etc/nginx/conf.d/default.conf nginx

[root@node2 ~/nginx]# cat default.conf 
server {
    listen       80;
    server_name  cloudreve.markli.cn;
    location / {
        proxy_redirect off;
        proxy_set_header Host $http_host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Real-Port $remote_port;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://192.168.15.202:5212;
        #proxy_pass http://cloudreve:5212;
    }
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}

[root@node2 ~/nginx]# docker exec nginx nginx -s reload
```

![cloudreve](./image/go-open-project/cloudreve/01.png)













# dozzle项目



[dozzle文档](https://github.com/amir20/dozzle)





## 查看主机docker输出日志

docker run --name dozzle -d --volume=/var/run/docker.sock:/var/run/docker.sock -p 8888:8080 amir20/dozzle:latest

![dozzle](./image/go-open-project/dozzle/01.png)














# alist项目



[alist文档](https://alist.nn.ci/zh/guide/)





## docker running

```bash
docker run -d --restart=always -v /etc/alist:/opt/alist/data -p 5244:5244 -e PUID=0 -e PGID=0 -e UMASK=022 --name="alist" xhofe/alist:latest
[root@prometheus ~]# docker logs alist
INFO[2023-06-05 07:10:22] reading config file: data/config.json        
INFO[2023-06-05 07:10:22] config file not exists, creating default config file 
INFO[2023-06-05 07:10:22] load config from env with prefix:            
INFO[2023-06-05 07:10:22] init logrus...                               
INFO[2023-06-05 07:10:22] Successfully created the admin user and the initial password is: oblPN87u 
INFO[2023-06-05 07:10:22] start server @ 0.0.0.0:5244                  
INFO[2023-06-05 07:10:22] qbittorrent not ready.                       
INFO[2023-06-05 07:10:22] Aria2 not ready.           
```



## binnary running

```bash
[root@prometheus download]# curl -OL https://github.com/axel-download-accelerator/axel/releases/download/v2.17.11/axel-2.17.11.tar.gz
[root@prometheus download]# axel -n 30 https://github.com/alist-org/alist/releases/download/v3.18.0/alist-linux-musl-amd64.tar.gz
[root@prometheus download]# tar xf alist-linux-musl-amd64.tar.gz
[root@prometheus download]# mv alist /usr/local/alist/bin/
[root@prometheus data]# cat /etc/profile.d/alist.sh 
export PATH=$PATH:/usr/local/alist/bin
[root@prometheus data]# source /etc/profile
[root@prometheus data]# systemctl cat alist.service 
# /usr/lib/systemd/system/alist.service
[Unit]
Description=alist
After=network.target
 
[Service]
Type=simple
WorkingDirectory=/usr/local/alist
ExecStart=/usr/local/alist/bin/alist server
Restart=on-failure
 
[Install]
WantedBy=multi-user.target
[root@prometheus data]# systemctl enable alist.service 
[root@prometheus data]# systemctl start alist.service 
[root@prometheus data]# journalctl -u alist
-- Logs begin at Sat 2023-06-03 11:00:17 CST, end at Mon 2023-06-05 16:41:15 CST. --
Jun 05 16:34:49 prometheus systemd[1]: Started alist.
Jun 05 16:34:49 prometheus alist[29881]: A file list program that supports multiple storage,
Jun 05 16:34:49 prometheus alist[29881]: built with love by Xhofe and friends in Go/Solid.js.
Jun 05 16:34:49 prometheus alist[29881]: Complete documentation is available at https://alist.nn.ci/
Jun 05 16:34:49 prometheus alist[29881]: Usage:
Jun 05 16:34:49 prometheus alist[29881]: alist [command]
Jun 05 16:34:49 prometheus alist[29881]: Available Commands:
Jun 05 16:34:49 prometheus alist[29881]: admin       Show admin user's info
Jun 05 16:34:49 prometheus alist[29881]: cancel2fa   Delete 2FA of admin user
Jun 05 16:34:49 prometheus alist[29881]: completion  Generate the autocompletion script for the specified shell
Jun 05 16:34:49 prometheus alist[29881]: help        Help about any command
Jun 05 16:34:49 prometheus alist[29881]: lang        Generate language json file
Jun 05 16:34:49 prometheus alist[29881]: restart     Restart alist server by daemon/pid file
Jun 05 16:34:49 prometheus alist[29881]: server      Start the server at the specified address
Jun 05 16:34:49 prometheus alist[29881]: start       Silent start alist server with `--force-bin-dir`
Jun 05 16:34:49 prometheus alist[29881]: stop        Stop alist server by daemon/pid file
Jun 05 16:34:49 prometheus alist[29881]: storage     Manage storage
Jun 05 16:34:49 prometheus alist[29881]: version     Show current version of AList
Jun 05 16:34:49 prometheus alist[29881]: Flags:
Jun 05 16:34:49 prometheus alist[29881]: --data string     config file (default "data")
Jun 05 16:34:49 prometheus alist[29881]: --debug           start with debug mode
Jun 05 16:34:49 prometheus alist[29881]: --dev             start with dev mode
Jun 05 16:34:49 prometheus alist[29881]: --force-bin-dir   Force to use the directory where the binary file is located as data directory
Jun 05 16:34:49 prometheus alist[29881]: -h, --help            help for alist
Jun 05 16:34:49 prometheus alist[29881]: --log-std         Force to log to std
Jun 05 16:34:49 prometheus alist[29881]: --no-prefix       disable env prefix
Jun 05 16:34:49 prometheus alist[29881]: Use "alist [command] --help" for more information about a command.
Jun 05 16:38:18 prometheus systemd[1]: Started alist.
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] reading config file: data/config.json
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] config file not exists, creating default config file
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] load config from env with prefix: ALIST_
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] init logrus...
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] Successfully created the admin user and the initial password is: teyOpaG2
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] start server @ 0.0.0.0:5244
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] Aria2 not ready.
Jun 05 16:38:18 prometheus alist[30144]: INFO[2023-06-05 16:38:18] qbittorrent not ready.
# user: admin  		password: teyOpaG2
```



## 配置nginx

```bash
[root@prometheus data]# cat /usr/local/nginx/conf/nginx.conf
	server {
        listen       80;
        server_name  alist.markli.cn;

        location / {
		proxy_pass http://127.0.0.1:5244;
		proxy_set_header    Host            $proxy_host;
                proxy_set_header    X-Real-IP       $remote_addr;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_hide_header   X-Powered-By;
			#auth_basic_user_file /usr/local/nginx/conf/passwdfile;
			#auth_basic	"alist authentication";
        }
    }

```



![alist](./image/go-open-project/alist/01.png)

![alist](./image/go-open-project/alist/02.png)

![alist](./image/go-open-project/alist/03.png)















# kubeshark项目



[kubeshark文档](https://docs.kubeshark.co/en/introduction)



https://github.com/kubeshark/kubeshark/releases/download/40.5/kubeshark_40.5_windows_amd64.tar.gz



![](./image/go-open-project/kubeshark/01.png)

 

![](./image/go-open-project/kubeshark/02.png)



![](./image/go-open-project/kubeshark/03.png)



![](./image/go-open-project/kubeshark/04.png)








# hack-browser-data项目



[hack-browser-data文档](https://github.com/moonD4rk/HackBrowserData)



![](./image/go-open-project/hack-browser-data/01.png)



![](./image/go-open-project/hack-browser-data/02.png)








# hugo项目



## hugo简介

世界上最快的网站构建框架

Hugo是最受欢迎的开源静态站点生成器之一。凭借其惊人的速度和灵活性，Hugo 让构建网站再次变得有趣。



## 1. 安装hugo

```
[root@prometheus download]# axel -n 30 https://github.com/gohugoio/hugo/releases/download/v0.113.0/hugo_0.113.0_linux-amd64.tar.gz
[root@prometheus download]# tar xf hugo_0.113.0_linux-amd64.tar.gz -C /usr/local/bin/
```



## 2. 安装git

```
[root@prometheus download]# yum install -y git 
```



## 3. 配置hugo

```
[root@prometheus download]# mkdir /opt/hugo
[root@prometheus download]# cd /opt/hugo
[root@prometheus hugo]# hugo new site blog
[root@prometheus hugo]# cd blog/
[root@prometheus blog]# git init 
Initialized empty Git repository in /opt/hugo/blog/.git/
# 此步可能需要科学上网
[root@prometheus blog]# git clone https://github.com/adityatelange/hugo-PaperMod themes/PaperMod

############
# 配置代理，方可进行下面clone
[root@docker /usr/local/hugo/quickstart]# export HTTP_PROXY="http://172.168.2.219:10809"
[root@docker /usr/local/hugo/quickstart]# export HTTPS_PROXY="http://172.168.2.219:10809"
[root@docker /usr/local/hugo/quickstart]# curl -I https://www.google.com
HTTP/1.1 200 Connection established
############



[root@prometheus blog]# cat hugo.yml 
baseURL: "http://blog.markli.cn/"
languageCode: "zh-CN"
title: "JackBlog"
theme: "PaperMod"
paginate: 5

enableRobotsTXT: true
buildDrafts: false
buildFuture: false
buildExpired: false

googleAnalytics: UA-123-45

minify:
  disableXML: true
  minifyOutput: true

params:
  #env: opengraph # to enable google analytics, opengraph, twitter-cards and schema.
  env: production # to enable google analytics, opengraph, twitter-cards and schema.
  title: ExampleSite
  description: "ExampleSite description"
  keywords: [Blog, Portfolio, PaperMod]
  author: Me
  # author: ["Me", "You"] # multiple authors
  images: ["<link or path of image for opengraph, twitter-cards>"]
  DateFormat: "January 2, 2006"
  defaultTheme: auto # dark, light
  disableThemeToggle: false

  ShowReadingTime: true
  ShowShareButtons: true
  ShowPostNavLinks: true
  ShowBreadCrumbs: true
  ShowCodeCopyButtons: false
  ShowWordCount: true
  ShowRssButtonInSectionTermList: true
  UseHugoToc: true
  disableSpecial1stPost: false
  disableScrollToTop: false
  comments: false
  hidemeta: false
  hideSummary: false
  showtoc: false
  tocopen: false

  assets:
    # disableHLJS: true # to disable highlight.js
    # disableFingerprinting: true
    favicon: "<link / abs url>"
    favicon16x16: "<link / abs url>"
    favicon32x32: "<link / abs url>"
    apple_touch_icon: "<link / abs url>"
    safari_pinned_tab: "<link / abs url>"

  label:
    text: "Home"
    icon: /apple-touch-icon.png
    iconHeight: 35

  # profile-mode
  profileMode:
    enabled: false # needs to be explicitly set
    title: ExampleSite
    subtitle: "This is subtitle"
    imageUrl: "<img location>"
    imageWidth: 120
    imageHeight: 120
    imageTitle: my image
    buttons:
      - name: Posts
        url: posts
      - name: Tags
        url: tags

  # home-info mode
  homeInfoParams:
    Title: "Hi there \U0001F44B"
    Content: Welcome to my blog

  socialIcons:
    - name: grafana
      url: "https://monitor.markli.cn/grafana"
    - name: github
      url: "https://github.com/jacknotes"

  analytics:
    google:
      SiteVerificationTag: "XYZabc"
    bing:
      SiteVerificationTag: "XYZabc"
    yandex:
      SiteVerificationTag: "XYZabc"

  cover:
    hidden: true # hide everywhere but not in structured data
    hiddenInList: true # hide on list pages and home
    hiddenInSingle: true # hide on single page

#  editPost:
#    #URL: "https://github.com/<path_to_repo>/content"
#    URL: "http://192.168.75.100:1313/content"
#    Text: "Suggest Changes" # edit text
#    appendFilePath: true # to append file path to Edit link

  # for search
  # https://fusejs.io/api/options.html
  fuseOpts:
    isCaseSensitive: false
    shouldSort: true
    location: 0
    distance: 1000
    threshold: 0.4
    minMatchCharLength: 0
    keys: ["title", "permalink", "summary", "content"]
menu:
  main:
    - identifier: categories
      name: categories
      url: /categories/
      weight: 10
    - identifier: tags
      name: tags
      url: /tags/
      weight: 20
# Read: https://github.com/adityatelange/hugo-PaperMod/wiki/FAQs#using-hugos-syntax-highlighter-chroma
pygmentsUseClasses: true
markup:
  highlight:
    noClasses: false
    # anchorLineNos: true
    # codeFences: true
    # guessSyntax: true
    # lineNos: true
    # style: monokai
	

[root@prometheus content]# mkdir -p /opt/hugo/blog/content/posts
[root@prometheus blog]# ls content/posts/
cloudnative  frp.md
```



## 以systemd服务启动

```
[root@prometheus blog]# systemctl cat hugo.service 
# /usr/lib/systemd/system/hugo.service
[Unit]
Description=https://gohugo.io/documentation/
After=network-online.target

[Service]
User=root
Group=root
Type=simple
WorkingDirectory=/opt/hugo/blog
ExecStart=/usr/local/bin/hugo server --config=/opt/hugo/blog/hugo.yml --buildDrafts --baseURL=http://blog.markli.cn/ --appendPort=false --theme=/opt/hugo/blog/themes/PaperMod/
Restart=on-failure

[Install]
WantedBy=multi-user.target
```





## 通过nginx反向代理

```
    server {
        listen       80;
        server_name  blog.markli.cn;
	rewrite ^(.*)$ https://${server_name}$1 permanent;
    }
    server {
        listen       443;
        server_name  blog.markli.cn;
	ssl_certificate /etc/letsencrypt/live/blog.markli.cn/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/blog.markli.cn/privkey.pem;
        ssl_session_timeout 5m;
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4:!DH:!DHE;
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;

        location / {
		proxy_pass http://127.0.0.1:1313;
		proxy_set_header    Host            $proxy_host;
                proxy_set_header    X-Real-IP       $remote_addr;
                proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_hide_header   X-Powered-By;
        }
    }
```





## hugo主题更换

```
# 官方主题市场
https://themes.gohugo.io/
# 本地主题目录
[root@docker /usr/local/hugo/quickstart]# ls themes/
ananke
# 下载第三方主题到主题目录，必须带特定目录，否则主题不可用
[root@docker /usr/local/hugo/quickstart]# git clone https://github.com/adityatelange/hugo-PaperMod themes/PaperMod
[root@docker /usr/local/hugo/quickstart]# ls themes/PaperMod/
assets  go.mod  i18n  images  layouts  LICENSE  README.md  theme.toml
# 切换指定主题
[root@docker /usr/local/hugo/quickstart]# vim hugo.toml
theme = 'PaperMod'
```



![](./image/go-open-project/hugo/1.png)
