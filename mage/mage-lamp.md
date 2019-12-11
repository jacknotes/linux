#LAMP
<pre>
###一、WEB服务及http协议

#常见请求方法：
1	GET	请求指定的页面信息，并返回实体主体。
2	HEAD	类似于 GET 请求，只不过返回的响应中没有具体的内容，用于获取报头
3	POST	向指定资源提交数据进行处理请求（例如提交表单或者上传文件）。数据被包含在请求体中。POST 请求可能会导致新的资源的建立和/或已有资源的修改。
4	PUT	    从客户端向服务器传送的数据取代指定的文档的内容。
5	DELETE	请求服务器删除指定的页面。
6	CONNECT	HTTP/1.1 协议中预留给能够将连接改为管道方式的代理服务器。
7	OPTIONS	允许客户端查看服务器的性能。
8	TRACE	回显服务器收到的请求，主要用于测试或诊断。
9	PATCH	是对 PUT 方法的补充，用来对已知资源进行局部更新 。

SMTP:多用途互联网邮件扩展，使用的就是MIME协议
HTTP:使用Base64协议（引入MIME协议）

##什么是动态网页？
动态网页是由客户端请求生成的，是非HTML格式的文件，是编程语言开发的脚本，脚本接收客户端参数后在服务器运行一次，并相对应的生成一个HTML文件发送给请求的客户端。
web服务器处理客户端的动态网页请求时，不是web服务器生成html文件，而web服务器通过协议去调用相对应的脚本解释器去，解释器执行并生成html文件，并返回给web服务器发送给客户端。
动态网页：包含静态内容（图片等，不需要运行解释器）和动态内容（只有动态内容才需要运行解释器生成html）
阻塞：一直等待
非阻塞：就是轮循
无论是阻塞还是非阻塞都会接收客户端的请求，我们称阻塞或非阻塞在等待客户端请求时为监听
#数据包
IP协议：源IP,目标IP
TCP协议：源端口，目标端口
HTTP首部：GET /2.html(什么方法，URL),Host: www.magedu.com(虚拟主机)
HTTP报文：请求报文，响应报文
请求报文语法：
-------------------------------
<method><request_URL><version>
<headers>
			
<entity-body> 
-------------------------------
<method>：请求的方法
<request_URL>:请求URL
<version>：http版本，http/1.0
<headers>：什么格式，什么类型的web对象
<entity-body>：报文主体
响应报文：
-------------------------------
<version><status><reason-phrase>
<headers>
			
<entity-body> 
-------------------------------
<version>：http版本，http/1.0
<status>:状态代码：1xx(纯信息)，2xx(成功类的信息，200),3xx(重定向类的信息，301，302，304),4xx(客户端错误类信息，404),5xx(服务器端错误类信息，501)
<reason-phrase>：进一步解释status的意义的
<headers>：什么格式，什么类型的web对象
<entity-body>：报文主体
请求报文例子：
GET / HTTP/1.1  #GET方式，默认主页
Host: www.magedu.com  #首部，名称及其值
Connection: keep-alive   #首部，名称及其值
响应报文例子：
HTTP/1.1 200 OK
X-Powered-By: PHP/5.2.17
Vary: Accept-Encoding,Cookie,User-Agent
Cache-Control: max-age=3,must-revalidata
Cotent-Encoding: gzip
Content-Length: 6931

#原生态的web服务器主要操作（不会操作动态内容的）：
1.建立连接——接受或拒绝客户端连接请求
2.接收请求——通过网络读取HTTP请求报文
3.处理请求——解析请求报文并做出相应的动作
4.访问资源——访问请求报文中相关的资源
5.构建响应——使用正确的首部生成HTTP响应报文
6.发送响应——向客户端发送生成的响应报文
7.记录日志——当已经完成的http事务记录进日志文件
#进程计算：
一个页面：10image,3css,5html,总共有18个资源
一个页面18个资源18个请求
http每个请求都是tcp协议的，三次握手，四次分手（说明了服务器压力很大，所以缓存是很有用的）

http/1.1：
增强了缓存的功能
长连接（减少三次握手的机会）:空闲超时，连接次数

四种模型：
1.单进程 2.多进程 3.单进程多请求 4.多进程多请求（最先进）
#httpd的MPM模型:prefork(@2),worker(@3),event(@4)，mpm_winnt(windows专用)
Client:IE,Firefox,Chrome,Opera,Safari
Server:Apache-httpd,IIS,nginx,lighttpd,thttpd
应用程序服务器（是web服务器也是解释器）：IIS,Tomcat(支持JSP,开源),apache（httpd,开源）,Websphere(IBM,解析JSP，不开源)，Weblogic(Oracle,解析JSP，不开源),JBoss(RedHat,实际是Tomcat,只是包装了)
全球web服务器统计（每半年统计一次）：https://www.netcraft.com/ 

###httpd：
NCSA,httpd——解散研发人员——研发人员不想httpd默落——通过互联网进行httpd的补丁和更新并发布新的版本——就被称为A Pactchy Server(充满补丁的服务，简称Apache)
开源界两个著名的基金会：
FSF:GNU,GPL
ASF:Apache Software Foundation
httpd特性：
1.事先创建空闲进程
2.按需维持适当的进程
3.模块设计，核心比较小，各种功能通过模块添加（包括php），支持运行时配置，支持单独编译模块
4.支持多种方式虚拟主机配置
HTTP/1.1比HTTP/1.0增加了缓存功能和长连接功能
支持https协议（mod_ssl）
支持用户认证
支持基于IP或主机名的ACL
支持每个目录的访问控制（默认站点可以不用认证访问，其他特定目录需要认证访问）
支持URL重写：/image/a.jpg转到/jack/image.abc.jpg。只是服务端重写，客户端无感知。

httpd:
/usr/sbin/httpd(MPM:prefork)#默认工作的模式
/etc/httpd #工作目录
/etc/httpd/conf #配置文件目录，主配置文件/etc/httpd/conf/httpd.conf
/etc/httpd/conf.d/*.conf  #主配置文件include进来的
/etc/httpd/modules #模块目录，是一个链接目录
/etc/httpd/logs --> /var/log/httpd #日志目录，有访问日志和错误日志两种
/var/www/html #静态网页目录
/var/www/cgi-bin #动态网页目录

perl #脚本语言，通过插件也可以写动态网页了。
python #脚本语言，通过插件现在也可以写动态网页了，
java #通过servlet插件也可以制作动态网页，而且直接嵌入到html中，不用手动编译，servlet直接帮我们编译运行了，现在比较流行
php #天生就是为动态网页而生的

假如同时有500个用户访问，每个用户访问10个动态资源，总共有多少进程？
500个web访问进程+500*10=5000个动态进程==5500个进程

一台web服务器有一个master process和多个work process进程，work进程是处理客户端web请求进程的，当有动态请求时，work进程把动态请求发送给应用程序服务器（解释器）运行[通过fastcgi协议通信，web服务器和应用程序服务器通过端口或套接字来联系的，这时应用程序服务器work process接收到后进程处理并返还html文件给web工作进程，web进程在发送响应给客户端。注：应用程序服务器的master process是管理自己的子进程work process的


#二、http安装及属性配置:
yum install -y httpd
cd /etc/httpd/conf ; grep "Section" httpd.conf
httpd有三个主配置段：1.全部环境，2.主服务配置，3.虚拟主机
vim httpd.conf;配置文件中有#号的都为注释,#号后面没有空格的都为指令，指令后面对应的为值
指令不区别大小写，value区分大小写
具体指令说明可以访问官网：httpd.apache.org查看帮助手册。也可以在系统中安装手册:yum install -y httpd-manual;重启httpd服务即可访问http://localhost/manual
属性配置：
ServerToken OS #在错误页显示错误信息，生产环境应当是关闭的
ServerSignature Off #关闭服务器显示信息
ServerRoot "/etc/httpd" #httpd服务的根目录
pidfile run/httpd.pid #pid目录
timeout 120 #tcp超时时间
KeepAlive off #是否打开长连接
maxkeepaliverequests 100 #长连接数最大请求数，无限制可设为0
keepalivetimeout 15 #长连接超时时长，比较繁忙的服务器，可以设低点，比如5秒钟，使用ab命令去测试时间，或者使用loadRunner(HP公司的),loadRunner接近于真实环境来测试
<IfModule prefork.c> #prefork模型
StartServers       8  #prefork模型下刚开始启动的进程数
MinSpareServers    5 #prefork最小空闲进程数
MaxSpareServers   20 #prefork最大空闲进程数
ServerLimit      256  #限制客户端最大连接数据，如果更改必须重启httpd服务（清理所有进程重新连接）
MaxClients       256 #客户端最大连接数，要想改大，先要改ServerLimit项后才能改
MaxRequestsPerChild  4000  #每一个进程最多响应4000个请求，超过kill掉重新生成
</IfModule>
<IfModule worker.c> #worker模型
StartServers         4  #worker模型下开始启动的进程数
MaxClients         300  #最大客户端连接数
MinSpareThreads     25 #最小空闲线程，以所有线程为基数的
MaxSpareThreads     75 #最大空闲线程
ThreadsPerChild     25 #每一个进程生成25个子线程
MaxRequestsPerChild  0 #每一个进程最大响应多少请求，由于worker模式是线程响应的，所以这里为0，不做响应
</IfModule>
Listen 80 #监听本地主机所有端口，可以监听多个端口，多加几次Listen 8080参数即可
LoadModule foo_module modules/mod_foo.so #装载模块：模块名称：模块路径（相对路径，以ServerRoot为根的）
Include conf.d/*.conf  #包含目录下的*.conf文件
User apache  #work进程需要以普通用户运行，在这设置
Group apache
ServerAdmin root@localhost #站点管理员邮件地址，用来给管理员发邮件时用的地址
#ServerName www.example.com:80 #虚拟主机名，如果没有设置则会用本地主机IP反解的域名来使用主机名，一般localhost
DocumentRoot "/var/www/html" #网站根目录，
<Directory "/var/www/html"> #对网站根目录进行权限设置
 Options Indexes FollowSymLinks #Options定义对应目录下文件的访问属性的。Indexes把文件列出来，只有在当文件下载时用的，其他时候不要开启。Indexex(允许索引目录，不安全的),None（不任何支持选项），Includes(允许执行服务端包含（SSI），不安全的),FollowFSynLinks(允许使用符号链接,影响性能)，execCGI(允许运行CGI脚本)，All(支持所有选项)
 AllowOverride None #设定.htaccess文件中允许的指令类型的，为None则不使用.htaccess，所以能使用allow和deny。.htaccess文件（由指定者AccessFileName）是用来设置相关目录的详细权限的。
Order allow,deny #order意为顺序，设置先允许后拒绝的。只要没有被明确允许的都会被拒绝访问
Allow from all #允许从所有地方访问
地址的表示方式：1.ip 2.network/netmask 3.hostname 4.domainname 5.partial IP:172.16
 AllowOverride AuthConfig  #设置认证后的用户才能访问，第一次用htpasswd -c -m /etc/httpd/conf/htpasswd hadoop命令来创建hadoop用户的，-c意为第一次新建，如果第二次建用户，则不需要加-c,例：htpasswd -m /etc/httpd/conf/htpasswd tom 。-m意为md5加密,-D为删除用户
 AuthType Basic #认证类型为basic，有其他认证类型digest
 AuthName "Restrocted Sote...." #显示认证时的提示信息
 AuthUserFile "/etc/httpd/conf/htpasswd" #用户认证的帐号和密码文件路径
AuthGroupFile "/etc/httpd/conf/htgruop" #用户组的文件路径，组文件格式是：myusers: hadoop tom
 Require Valid-user #设置请求的户为所有有效的用户，也可以指定某个用户或某个组
 Require user hadoop #只允许hadoop用户访问
 Requier group myusers #只允许myusers这个组能访问
 </Directory>
<IfModule mod_userdir.c>
UserDir disabled #是否允许用户在自己的家目录下创建网页（个人页面），例：http://192.168.1.233/~hadoop/访问时
 UserDir public_html #只允许用户家目录下特定的public_html目录能创建网页，这个用户为linux用户，例如/home/hadoop/public_html/index.html && chmod o+x /home/www && http://192.168.1.233/~hadoop即可访问个人站点。须先重启服务
<Directory /home/*/public_html> #定义用户家目录下特定目录的权限
    AllowOverride FileInfo AuthConfig Limit
    Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
    <Limit GET POST OPTIONS> #只限定GET POST OPTIONS三种方法
        Order allow,deny 
        Allow from all  #允许所有
    </Limit>
    <LimitExcept GET POST OPTIONS> #只限定除开GET POST OPTIONS外的方法
        Order deny,allow
        Deny from all  #拒绝所有
    </LimitExcept>
</Directory>
</IfModule>
DirectoryIndex index.html index.html.var #目录索引，就是主页文件，自左向右匹配，如果有权限访问而站点下没有这些主页，就会把索引目录列给这个有权限用户
AccessFileName .htaccess  #.htaccess是在站点下每个目录下的访问控制文件，从而达到每个目录权限控制，这个东西让apache的运行效率极低。生产环境是是禁用的
<Files ~ "^\.ht"> #模式匹配，以.ht开头的
  Order allow,deny  
  Deny from all #拒绝所有人访问 
  Satisfy All #针对所有人，除开特定的目的地址
</Files>
TypesConfig /etc/mime.types #让http协议支持多媒体非二进制类型的文件，里面记录了支持的类型
DefaultType text/plain #默认类型是文本下的纯文本信息
<IfModule mod_mime_magic.c> #如果mod_mime_magic.c模块存在
 # MIMEMagicFile /usr/share/magic.mime
  MIMEMagicFile conf/magic  #就使用conf/magic信息
</IfModule>
HostnameLookups Off #是否让日志记录主机名而不是记录ip，设成主机名容易浪费主机资源
ErrorLog logs/error_log #定义错误日志路径
LogLevel warn #日志级别为warn
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined #定义日志格式，并给日志模式起个名字，combined为混合模式[%h远程主机、%l远端主机登录名称（一般为-）、%u 登录网站用户（没登录为-）、%t收到请求的时间、（\反斜号转义）%r第一行请求（为方法，URL，版本号）、%>s最后一个请求的状态码、%b响应报文的大小、%{Referer}i表示你从哪个页面来的、%{User-Agent}i记录用户浏览器]
 LogFormat "%h %l %u %t \"%r\" %>s %b" common #通用模式
LogFormat "%{Referer}i -> %U" referer #记录访问地址来源
LogFormat "%{User-agent}i" agent #只记录浏览器类型
CustomLog logs/access_log combined #定义日志类型为combined，通过访问日志来判断页面访问量（PV（page view）,pv按每天统计，按照每个页面来统计不能按照一个资源来访问），判断客户访问量（UV（user view），uv按独立IP访问量）
Alias /icons/ "/www/icons/" #别名，在站点下创建一个别名/icons，访问时实际内容指向/www/icons/下

[root@a019736cb441 /]#grep 'Section' /etc/httpd/conf/httpd.conf
### Section 1: Global Environment  #全局环境
### Section 2: 'Main' server configuration  #主Server段，只有一个web服务器不提供虚拟主机
### Section 3: Virtual Hosts #虚拟主机，禁用中心主机，有多台主机
httpd -t #测试配置文件语法
elinks http://192.168.1.233 #-dump参数代表不使用交换式，登录后就退出。-source显示html格式源码并退出
-----多处理模块(MPM)：
mpm_winnt（windows专用的）
worker（一个请求用一个线程响应，服务器启动多个进程，每个进程生成多个线程）
prefork(一个请求用一个进程响应)（httpd2.2默认）
event（一个进程处理多个请求，httpd2.4默认）,最强大的机制模型，nginx就是这种机制模型
切换httpd MPM程序：可以切换工作模式
注：如果在安装httpd时MPM模块编译了就有，没有就不支持
[root@salt-server /git/job]# httpd -l #查看编译的模块
Compiled in modules:
  core.c
  mod_so.c
  http_core.c
[root@a019736cb441 conf]#httpd -M  #httpd所有装载的模块
httpd: Could not reliably determine the server's fully qualified domain name, using 172.17.0.3 for ServerName
Loaded Modules:
 core_module (static)
 mpm_prefork_module (static)
 http_module (static)
 so_module (static)
 auth_basic_module (shared)

rpm -ql httpd | grep bin #可查看httpd的执行命令
[root@salt-server /git/job]# vim /etc/sysconfig/httpd 
"HTTPD"=/usr/sbin/httpd.worker #这里可以选择MPM模型，然后启动脚本会从这里读取从而启动不同进程，默认是prefork进程

##三、httpd虚拟主机：
apache服务主机：
中心主机：不使用虚拟主机的主机
虚拟主机：服务于多个不同的站点
虚拟主机和中心主机不能同时使用。
虚拟主机：
   基于IP: ip1:80,ip2:80
   基于端口：ip:80,ip:8080
   基于域名：ip:80，ip和端口相同，主机名不同（常用）。
apache2.2用NameVirtualHost启用，2.4则不需要这条命令启用
apache2.4想用什么类型虚拟主机就用哪种方式定义即可
虚拟主机之间不同配置处：
-------------
DocumentRoot /www/a.org/
ServerName
ServerAlias  #虚拟主机别名，可以多个
<Directory "/www/a.org/"> #基于目录的访问权限
	Options
	AllowOverride
</Directory>
Alias #别名不同
ErrorLog   #错误日志路径及格式
CustomLog  #访问日志路径及格式
<Location "/images"> #定义URL的使用权限，比如只允许使用GET方法等等

</Location>
ScriptAlias #脚本别名，允许执行CGI的目录（CGI通用网关接口协议）
-------------
虚拟主机的定义：（使用虚拟主机的时候必须先取消中心主机，注释DocumentRoot即可）
<VirtualHost www.jack.com>

</VirtualHost>
vim /etc/httpd/conf.d/virtual.conf
#基于IP主机定义：
先注释httpd.conf文件中DocumentRoot中心主机
<VirtualHost 172.17.0.3:80 >
        ServerName www.jack.com
        DocumentRoot "/www/magedu.com"
</VirtualHost>
<VirtualHost 172.17.0.2:80 >
        ServerName www.jack2.com
        DocumentRoot "/www/magedu2.com"
</VirtualHost>
用httpd -t 检查语法 

#基于端口主机定义：
<VirtualHost 172.17.0.2:80 >
        ServerName www.jack2.com
        DocumentRoot "/www/magedu2.com"
</VirtualHost>
<VirtualHost 172.17.0.2:8080 >
        ServerName port.jack.com
        DocumentRoot "/www/magedu2.com"
</VirtualHost>
vim /etc/httpd/conf/httpd.conf添加listen8080端口。多监听端口

#基于域名主机定义：
[root@a019736cb441 conf.d]#cat virtual.conf 
NameVirtualHost 172.17.0.2:80
<VirtualHost 172.17.0.2:80>
        ServerName sec.jack.com
        DocumentRoot "/www/magedu2.com/"
        CustomLog /var/www/httpd/sec.jack.com/access_log combined  #设置虚拟主机各自目录
       <Directory "/www/magedu2.com"> #设置这个主机目录不允许172.168.0.3访问
				Options none
				AllowOverride none
				Order deny,allow
				Deny from 172.168.0.3
       </Directory>
</VirtualHost>
<VirtualHost 172.17.0.2:80>
        ServerName domain.jack.com
        DocumentRoot "/www/magedu3.com/"
        CustomLog /var/www/httpd/domain.jack.com/access_log combined
        <Directory "/www/magedu3.com">
                Options none
                AllowOverride authconfig
                AuthType Basic
                AuthName "Restrocted Sote..."
                AuthUserFile "/etc/httpd/config/htpasswd"
                Require Valid-user #允许有效的用户登录
        </Directory>
</VirtualHost>

<VirtualHost 172.17.0.2:80>  
        ServerName _default_  #默认虚拟主机，必须写在虚拟主机的第一个
        DocumentRoot "/www/default/"
</VirtualHost>

客户端动态：从服务器把脚本复制到客户端本地运行，不安全（例如黑客写个格式化硬盘脚本），适用性不强
服务端动态：基于CGI协议技术调用解释器运行脚本返回给apache（解释器：bash,c,php,python,java等）
MVC:一种软件设计典范，用一种业务逻辑、数据、界面显示分离的方法组织代码
directory定义的是本地目录的权限，location定义的是url权限
<Location /server-status>#URL是http://localhost/server-status
    SetHandler server-status #执行一个动作，调用某些文件的时候可以执行一些动作
    Order allow,deny
    Allow from all
</Location>

----------
#四、基于openssl的https服务配置
客户端和服务端tcp三次握手之后就可以建立ssl会话了
客户端和服务端协商单项加密算法9(hash)对称加密算法(des)、公钥加密算法(非对称加密算法)，选择大家都支持的算法，每种算法都可以用得到，这些算法都要进行选择的，一旦选择完成了，双方才可以建立ssl会话，server端用协商的单项加密算法加密证书（公钥）生成特征码和证书一起发送给客户端，客户端用单项加密算法解密证书验证特征码并验证证书是否为信任证书，验证完成后没有问题，就用服务端的公钥加密一个对称密钥发送给服务端，服务端用私钥解密获取对称密钥，服务端就有了和客户端配对的对称密钥，然后客户端将请求页面发送给服务端，服务端就用对称密钥加密内容给客户端。
#证书：
服务端要找一个第三方证书机构颁发证书，客户端上要把第三方机构证书放到信任路径后才能信任服务器证书。我们这里没办法找第三方机构，我们现在自建一个证书机构CA，颁发的证书也叫自签名证书。
服务器和客户端使用证书流程：
服务器生成一对密钥--服务器把公钥发送给CA--CA给服务器发来的公钥签名并颁发证书--服务器拿到证书后配置服务器使用证书--并且在客户端发送请求的时候发送证书给客户端--客户端用保存在自己机器上的CA机构证书验证服务器发来的证书是否有效。
##ssl会话仅能支持ip地址不支持主机名，如果主机只有一个ip地址的话，有多个虚拟主机情况下，那么只能有一个虚拟主机能拿来使用ssl，其他虚拟主机不能使用ssl
如果apache要想使用https功能，那么apache要安装ssl模块，使用httpd -Ms来查看是否已经安装需要的模块
yum install mod_ssl -y  #基于rpm包安装mod_ssl
[root@a019736cb441 conf.d]#rpm -ql mod_ssl
/etc/httpd/conf.d/ssl.conf  #涉及新的端口（套接字），必须重启服务
/usr/lib64/httpd/modules/mod_ssl.so #安装的模块
/var/cache/mod_ssl #ssl的缓存目录
/var/cache/mod_ssl/scache.dir
/var/cache/mod_ssl/scache.pag
/var/cache/mod_ssl/scache.sem

制作CA，先生成私钥：（apache服务和CA在一台服务器）
cd /etc/pki/CA/ 
[root@a019736cb441 CA]#(umask 077;openssl genrsa -out private/cakey.pem 2048) #用openssl生成rsa类型的CA私钥，输出保存在/etc/pki/CA/private/cakey.pem，长度为2048，权限只允许root有，所以umask为077
[root@a019736cb441 CA]#ls private/ -l
total 4
-rw------- 1 root root 1679 Mar 21 10:30 cakey.pem
vim /etc/pki/tls/openssl.cnf #先把生成证书默认信息改成自己需的信息
-------------
[ req_distinguished_name ]
countryName                     = Country Name (2 letter code)
countryName_default             = CN #国家：中国
countryName_min                 = 2
countryName_max                 = 2

stateOrProvinceName             = State or Province Name (full name)
stateOrProvinceName_default     = Shanghai #省：上海

localityName                    = Locality Name (eg, city)
localityName_default            = Shanghai #位置：上海
0.organizationName              = Organization Name (eg, company)
0.organizationName_default      = Magedu #组织：Magedu

# we can do this but it is not needed normally :-)
#1.organizationName             = Second Organization Name (eg, company)
#1.organizationName_default     = World Wide Web Pty Ltd

organizationalUnitName          = Organizational Unit Name (eg, section)
#organizationalUnitName_default =
organizationalUnitName_default  = Tech #组织单元名称：Tech
-------------
生成自签名证书：
[root@a019736cb441 CA]#openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 3655 #给自己生成自签名证书，用做客户端用
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CN]: #下面五条是刚刚设置的信息
State or Province Name (full name) [Shanghai]:
Locality Name (eg, city) [Shanghai]:
Organization Name (eg, company) [Magedu]:
Organizational Unit Name (eg, section) [Tech]:
Common Name (eg, your name or your server's hostname) []:ca.magedu.com #主机名设置
Email Address []:admin@magedu.com #邮箱
[root@a019736cb441 CA]#ls
cacert.pem  certs  crl  newcerts  private
要把自己扮成私有CA，还需要改/etc/pki/tls/openssl.cnf的配置信息：
[root@a019736cb441 CA]#vim /etc/pki/tls/openssl.cnf
---------------
[ CA_default ]   #CA各个目录的默认工作路径

dir             = /etc/pki/CA           # CA的工作目录
certs           = $dir/certs            # 生成的证书目录
crl_dir         = $dir/crl              # 吊销的证书目录
database        = $dir/index.txt        # 签的有哪些证书
new_certs_dir   = $dir/newcerts         # 新签的证书目录
certificate     = $dir/cacert.pem       # CA的自签名证书
serial          = $dir/serial           # 签到第几个，序列号
crlnumber       = $dir/crlnumber        # 
crl             = $dir/crl.pem          # 
private_key     = $dir/private/cakey.pem# 私钥
RANDFILE        = $dir/private/.rand    # 

x509_extensions = usr_cert              # 
---------------
[root@a019736cb441 CA]#touch index.txt #新建目录及文件使匹配CA设置
[root@a019736cb441 CA]#echo 01 > serial
[root@a019736cb441 CA]#ls
cacert.pem  certs  crl  index.txt  newcerts  private  serial
CA证书机构已经制作完成了，之后只需要服务器生成密钥，把自己的公钥通过申请发送给CA，CA颁发就可以完成证书的颁发了。
#回到服务器：
[root@a019736cb441 ssl]#pwd
/etc/httpd/ssl #创建ssl目录，放置密钥对
[root@a019736cb441 ssl]#(umask 077;openssl genrsa 1024 > httpd.key) #生成私钥，与可用-out来导出证书
Generating RSA private key, 1024 bit long modulus
.................................................++++++
....................++++++
e is 65537 (0x10001)
[root@a019736cb441 ssl]#openssl req -new -key httpd.key -out httpd.csr #生成证书服务请求文件，里面的地址组织信息一定要跟CA的地址组织信息一致，因为证书机构一般是你的所在地证书机构
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CN]: #信息必须跟证书机构信息一致
State or Province Name (full name) [Shanghai]:
Locality Name (eg, city) [Shanghai]:
Organization Name (eg, company) [Magedu]:
Organizational Unit Name (eg, section) [Tech]:
Common Name (eg, your name or your server's hostname) []:hallo.magedu.com  #你要申请证书的域名
Email Address []:hallo@magedu.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:  #密码可以不填
An optional company name []:
然后把服务器的证书申请请求文件发送给CA，可以通过scp来发送。
CA签署服务器的证书申请请求：
---------------
[root@a019736cb441 ssl]#openssl ca -in /etc/httpd/ssl/httpd.csr -out /etc/httpd/ssl/httpd.crt -days 3650 #ca签署证书申请请求
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Mar 21 15:25:09 2019 GMT
            Not After : Mar 18 15:25:09 2029 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Shanghai
            organizationName          = Magedu
            organizationalUnitName    = Tech
            commonName                = hallo.magedu.com
            emailAddress              = hallo@magedu.com
        X509v3 extensions:
            X509v3 Basic Constraints:
                CA:FALSE
            Netscape Comment:
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier:
                A4:90:2F:0C:FB:1E:A5:6E:4D:CE:5F:22:91:16:74:CE:EA:C6:20:F3
            X509v3 Authority Key Identifier:
                keyid:69:FF:35:51:CD:92:AD:B8:82:DD:60:C8:4F:80:60:76:C2:18:11:C7

Certificate is to be certified until Mar 18 15:25:09 2029 GMT (3650 days)
Sign the certificate? [y/n]:y #同意签署


1 out of 1 certificate requests certified, commit? [y/n]y ##再次同意签署
Write out database with 1 new entries
Data Base Updated

[root@a019736cb441 ssl]#cat /etc/pki/CA/index.txt #在CA中查看可看到已经签署的证书
V       290318152509Z           01      unknown /C=CN/ST=Shanghai/O=Magedu/OU=Tech/CN=hallo.magedu.com/emailAddress=hallo@magedu.com
[root@a019736cb441 ssl]#cat /etc/pki/CA/serial
02 #之前为01，现在为02，增加了一个证书
注：其他无关的证书一定要清理掉。
配置服务器使用证书：
[root@a019736cb441 conf.d]#vim ssl.conf
LoadModule ssl_module modules/mod_ssl.so #装载了模块
Listen 443 #监听443端口
AddType application/x-x509-ca-cert      .crt  #添加了支持独特的证书类型
AddType application/x-pkcs7-crl            .crl #添加了支持独特的证书吊销列表类型
SSLPassPhraseDialog  builtin #密钥生成阶段会话机制是由内建的
SSLSessionCache         shmcb:/var/cache/mod_ssl/scache(512000) #缓存路径
SSLSessionCacheTimeout  300 #缓存清空时间
<VirtualHost 172.17.0.2:443> #指定特定的虚拟主机
ServerName hallo.magedu.com  #虚拟主机名
DocumentRoot "/www/magedu2.com/" #虚拟主机站点目录
ErrorLog logs/ssl_error_log  #错误日志目录
TransferLog logs/ssl_access_log #访问日志目录，ssl访问日志是transfer，而不是customlog了
LogLevel warn  #日志等级为warn
SSLEngine on  #关键，是不是启用ssl，
SSLProtocol all -SSLv2 #使用ssl的协议，支持所有ssl协议除开SSLv2版本,就是支持SSLv3和TLSv1的
SSLCipherSuite DEFAULT:!EXP:!SSLv2:!DES:!IDEA:!SEED:+3DES #加密套件
SSLCertificateFile /etc/httpd/ssl/httpd.crt #ssl的公钥证书文件路径
SSLCertificateKeyFile /etc/httpd/ssl/httpd.key #ssl的私钥文件路径
[root@a019736cb441 CA]#scp cacert.pem 192.168.1.19:/Share/Info/3CDaemon #把CA的自签名证书传给客户端，客户端再把cacert.pem改成cacert.crt，windows才能安装此证书，安装明把证书安装在受信息的根证书分发机构即可。

#五、PHP相关概念及配置：
浏览器仅通解码html的文档。其他音乐及视频用插件或者调用本地客户端的软件运行。
CGI协议：调用不同的解释器来编译对应的脚本，WEBapp(解释器或者WEB应用程序)
编程语言：
静态语言：编译型语言(强类型的，需要编译才能运行)
C，C++（系统，数据库，驱动等开发用C，性能好）,java,
优点：性能好。缺点：每一次改动都需要编译，开发周期长，维护成本大
动态语言：解释型语言（弱类型的，不需要手动编译，变量在使用时拿来用，不用事先声明变量，运行的时候拿解释器解释运行即可）
shell,perl,python,jsp,php
优点：便于维护，众多共享模块，开发周期短，维护成本小。缺点：性能差点，
折中方法：将动态语言转换为静态语言。php-->Hiphop小程序-->转换为C++-->编译成HTML
使用动态语言编写Web网站：bash,perl,python(Diango框架),java的jsp(ssh)，ruby(rails),php(天生为动态网站还生)和asp(丑陋的语言)
编程学习流程：1基本语法，2算法、数据结构，3编译原理
php(Php is Hypertext preprocessor):叫超文本预处理器
解释器：词法分析，语法分析，编译生成，执行路径
php source code --> 编译成二进制（php解释器自动编译的，二进制文件叫opcode）--》执行二进制格式在zend引擎上运行
zend引擎：编译的结果叫opcode（操作码，接进二进制，只能在zend引擎上运行），可以理解把zend引擎当成opcode或者php的虚拟机（类似java的编译文件运行在JVM上，MSL运行在.NET上）
1.词法扫描，2，语法分析，3，编译，4，执行（顺次执行opcode）
#php加速器（也叫opcode缓存器）。XCache缓存器是最常用的
opcode放置位置：放置在内存中，每一个动态进程生成的opcode都会放到各自内存空间上，为了加速执行效率就把内存分割成一块php缓存器，opcode都放置在php缓存器中，这样可以利用相同请求的opcode了，不再再次php编译，使opcode运行起来更加有速率。
php缓存器：XCache、Zend Optimizer(解密)和Zend Guard Loader(加密)、Nusphere PhpExpress

php官网：http://www.php.net/
php源码目录结构：
1、build--顾名思义，这里主要放置一些跟源码编译相关的文件，比如开始构建之前的buildconf脚本及一些检查环境的脚本等。
2、ext--官方的扩展目录，包括了绝大多数PHP函数的定义和实现，如array系统，pdo系统，spl系列等函数的实现。
3、main--这里存放的就是PHP最为核心的文件了，是实现PHP的基础设施，这里和Zend引擎不一样，Zend引擎主要实现语言最核心的语言运行环境。
4、Zend引擎的实现目录，比如脚本的词法语言解析，opcode的执行以及扩展机制的实现等等。
5、pear--PHP扩展与应用仓库，包含PEAR的核心文件。
6、sapi--包含了各种服务器抽象层的代码，例如apache的mod_php，cgi，fastcgi以及fpm等等接口。
7、TSRM--PHP的线程安全是构建在TSRM库之上的，PHP实现中常见的*G宏通常是对TSRM的封装，TSRM(Thread Safe Resurce Manager)线程安全资源管理器。
8、tests--PHP的测试脚本集合，包含PHP各项功能的测试文件。
9、win32--这个目录主要包括windows平台相关的一些实现，比如socket的实现在windows下和*Nix平台就不太一样，同时也包括了windows下编译PHP相关的脚本。

CGI（Common Gateway Interface）：让web服务器与后端程序相结合的，调用后端程序执行动态脚本的一种接口
apache--php--php编译成opcode--在zend引擎运行--生成数据流--发送给apache--apache不保存直接发送给客户端
MVC(module viewer controller):模块视图控制，嵌入式web开发语言
---------------
<html>
	<head></head>
<php
     这个位置放置php脚本，当web进程调用php解释器时，只会把php脚本内容执行，其他html格式不会执行。这个就是嵌入式web开发
php>
</html>
---------------
cat /etc/httpd/conf/httpd.conf
LoadModule cgi_module modules/mod_cgi.so  #说明apache是支持cgi的
ScriptAlias /cgi-bin/ "/var/www/cgi-bin/" #cgi执行路径
Web服务器到底如何跟php进行交换？
1、CGI 2、Module（php_mod，只需要加载到apahe中即可） 3、Fastcgi(fpm，需要编译php才能支持)
FastCGI:Fast Common Gateway Interface 
1、apache+Module（使用apache与php进行交换使用php_mod，当然apache+fpm相结合也是可以的，只是没有nginx+fpm处理静态和动态效率高）
2、Nginx+fpm(nginx与php进行交换使用fpm)
安装php:
[root@a019736cb441 conf.d]#yum install php.x86_64 php-mbstring.x86_64 #mbstring是支持多字节多国际语言的插件
[root@a019736cb441 conf.d]#rpm -ql php
/etc/httpd/conf.d/php.conf #增加了php配置文件
/usr/lib64/httpd/modules/libphp5.so #增加了php模块
/var/lib/php/session
/var/www/icons/php.gif
[root@a019736cb441 conf.d]#vim /etc/httpd/conf.d/php.conf
<IfModule prefork.c> 
  LoadModule php5_module modules/libphp5.so #如果apache为prefork模型则加载libphp5.so
</IfModule>
<IfModule worker.c>
  LoadModule php5_module modules/libphp5-zts.so #如果apache为work模型则加载libphp5-zts.so
</IfModule>
AddHandler php5-script .php #添加处理器的，如果是.php文件的话就用php5-script工具来处理
AddType text/html .php #添加MIME类型，把.php文件仍然当做纯文件执行
DirectoryIndex index.php  #添加php默认主页
[root@a019736cb441 magedu2.com]#cat index.php
<?php   #编写phpinfo函数可以查看php信息，也可做为检查是否成功安装php
phpinfo()
?>
/etc/php.ini  #此目录是php的配置目录，ini格式跟windows系统的ini文件一样，mysql的配置文件也是这种格式的

#六、数据及mysql:
程序：由指令和数据组成。
哪些数据库：
世界三大数据库巨头：Oracle,Sybase(SQLServer,前期Sybase研发的),Infomix(IBM收购了)
Mysql:MariaDB-->Percona
postgreSQL:pgsql,企业版EnterpriseDB
NoSQL(反关系模型):
MongoDB:文件数据库
Redis:缓存数据库
HBase:在自我内部实现的键值对数据库中，在hadoop中会用到。

Mysql的安装配置：
官网网址：www.mysql.com
mysql分社区版和企业版。
社区版提供三种软件包格式：1.特有安装方式，使用rpm包，使用exe格式。2.通用二进制格式。3.源程序
yum -y install mysql-server mysql #安装mysql软件
分析：
安装完mysql后，mysql有个系统数据库，存放了所以用户的数据库名，表名，表的字段等等信息，这个库就叫mysql库，数据是存放在文件系统的源数据区（inode）中的，最终由源数据区（inode）指向数据区的。
mysql库刚开始是不存在的，需要初始化后才能生成。service mysqld start 初始化mysql
mysql命令：
-u USERNAME  #mysql用户名是两部分组成的。user@host[host是客户端的登录主机名]
-p PASSWORD  #服务端用户访问密码
-h HOSTNAME #服务端主机名
mysql是基于什么连接的？TCP协议连接的，但linux在本机上连接是基于套接字(socket)的，比tcp快得多的多(因为基于进程间连接的)。而windows在本机是基于共享内存(memeory)连接的。
例如：mysql -u root -p -h 127.0.0.1#因为是本地，所以是基于套接字连接的，如果写的是本机ip，那么是基于tcp连接的。
mysql客户端：1.交互式模式。2.批处理模式
交换式模式中的命令类别：1.客户端命令，类如\h。2.服务器命令：都必须使用语句结束符，默认为分号;
SQL接口：
Oracle：PL/SQL(在sql标准下的扩展)
SQL Server：T-SQL(在sql标准下的扩展)
Mysql：也有扩展，没有名字，扩展是在自己平台用。
mysql数据库初始化启动后默认有三个库：1.mysql（mysql系统库）。2.information_schama（执行的信息保存在这，并提供接口查询，存放在内存当中，类似/proc目录）。3.test（测试库，默认为空）
mysql数据库默认在/var/lib/mysql/下，在此目录下mkdir可创建一个数据库。
mysql数据库大小写：区分大小写取决于你的文件系统，linux区分，windows不区分。
关系数据库对象：
1.表。2.索引。3.视图。4.约束。5.存储过程。6.存储函数。7.触发器(做主动数据库的)。8.游标。9.用户。10.权限。11.事务。12.库
表：行和列。可以没有行，但不可以没列。
表：一个表是一个实体。
行：row,实体集
列：field,column
定义一个表先写交字段名称：数据类型，类型修饰(约束)
字符：
1.CHAR(n)[固定的字符个数，最多256个字符]。
2.VARCHAR(n)[可变的字符，占用空间为n+1，最多65536个字符]{CHAR不支持大小写字符}
3.BINARY(n)[可以支持大小写字符]。
4.VARBINARY(n)[可变长的binary，可以支持大小写]。
5.TEXT(n)[明确我们要存储多大的文本]。
6.BLOB(n)[二进制大对象]
数值:
1.int(整形)。
2.DECIMAL(十进制)。
3.FLOAT(单精度浮点)。
4.DOUBLE(双精度浮点)
日期：DATE,TIME,DATETIME,STAMP（时间戳）
布尔：0和1表示
约束：NOT NULL,UNSIGNED（不能为负数）
MYSQL的常用命令(不区分大小写，大小应统一)：
DDL(定义数据对象)：CREATE,ALTER,DROP
DML(操纵语言)：INSERT,DELETE,UPDATE,SELECT
DCL(控制语言):GRANT,REVOKE,

DDL:
创建数据库：
CREATE DATABASE testdb; #创建数据库
 CREATE DATABASE IF NOT EXISTS testdb; #如果不存在则创建数据库
删除数据库：DROP DATABASE testdb; #mysql没有回收站，删除时警慎。
创建表：
USE mydb; #设定默认数据库，这是客户端的设置
SELECT DATABASE(); #查看目前所在的数据库
 CREATE TABLE students(Name CHAR(20) NOT NULL,Age TINYINT UNSIGNED,Gender CHAR(1) NOT NULL);新建表，也可使用mydb.students来创建表。
 SHOW TABLES FROM mydb; #查看指定数据库有哪些表
 SHOW TABLES; #查看默认数据库有哪些表
 DESC students; #查看表结构
 DROP TABLE IF EXISTS tb_name #如果存在删除表，不可逆
修改表：
MODIFY:修改字段属性，不修改字段名称
CHANGE:字段名称会改变的
ADD:添加一个字段
DROP:删除一个字段
获取帮助：help CREATE TABLE;  help ALTER TABLE;
 ALTER TABLE students ADD Course VARCHAR(100); #增加一个字段
ALTER TABLE students CHANGE course Course VARCHAR(110) AFTER Name; #修改字段course为Course
ALTER TABLE students DROP col_name #直接删除字段名

DML:
MariaDB [mydb]> DESC students;
+--------+---------------------+------+-----+---------+-------+
| Field  | Type                | Null | Key | Default | Extra |
+--------+---------------------+------+-----+---------+-------+
| Name   | char(20)            | NO   |     | NULL    |       |
| Course | varchar(110)        | YES  |     | NULL    |       |
| Age    | tinyint(3) unsigned | YES  |     | NULL    |       |
| Gender | char(1)             | NO   |     | NULL    |       |
+--------+---------------------+------+-----+---------+-------+
INSERT INTO students (Name,Gender) VALUE ('Linghuchong',"M"),("Xiaolongnv",'F'); #插入条目到表中，可多个插入。
MariaDB [mydb]> SELECT * FROM students;
+-------------+--------+------+--------+
| Name        | Course | Age  | Gender |
+-------------+--------+------+--------+
| Linghuchong | NULL   | NULL | M      |
| Xiaolongnv  | NULL   | NULL | F      |
+-------------+--------+------+--------+
INSERT INTO students VALUE ('Linghuchong','dugujiujian',43,"M"); #插入条目到表中，可以不指定字段，表示全部插入。
update students set Course='hamagong' where Name='linghuchong'; #更新表
选择：只选择哪几行;
投影：只选择显示哪几列;
delete from students where Name='linghuchong'; #删除表内容
select * from tb_name; #查询表
DCL:
CREATE USER 'USERNAME@HOST' IDENTIFIED BY 'PASSWORD'; #新建一个用户，只能连到mysql来做简单的查询，不能更改数据库
DROP USER 'USERNAME@HOST'; #删除用户
HOST：1.IP,2.HOSTNAME,3.NETWORK.
通配符：_:匹配任意单个字符。  %:匹配任意字符。注：使用通配符的时候一定要用'%'引号括起来。
GRANT PRI1,PRI2... ON DB_NAME.TB_NAME TO 'USERNAME'@'HOST' [IDENTIFIED BY 'PASSWORD'];#给用户授权。如果没有创建用户，这里授权的时候可以一起新建用户，而且还可以授权。
REVOKE PRI1,PRI2... ON DB_NAME.TB_NAME FROM 'USERNAME'@'HOST'; #移除用户权限。
例：
MariaDB [mydb]> CREATE USER 'jack'@'%' IDENTIFIED BY 'jack';
MariaDB [mydb]> SHOW GRANTS FOR 'jack'@'%'; #查看用户的授权
 GRANT USAGE ON *.* TO 'jack'@'%' IDENTIFIED BY PASSWORD '*9BCDC990E611B8D852EFAF1E3919AB6AC8C8A9F0' |
 #USAGE权限只能登录并且有限查看
权限类别：ALL(所有权限)，USAGE(只有登录查看的权限)
MariaDB [mydb]> GRANT ALL PRIVILEGES ON mydb.* TO  'jack'@'%'; #授权所有权限给jack
MariaDB [mydb]> REVOKE ALL PRIVILEGES ON mydb.* from 'jack'@'%'; #移除所有权限

#七、建立LAMP平台
1. MariaDB [mysql]> set password for 'root'@'localhost'=password('123456'); #设置root密码
MariaDB [mysql]> flush privileges; #由于mysql认证信息在驻留在内存当中的，所以你得重新加载表到内存当中，使用fulsh来刷新即可
2. [root@Linux-node6-slave-mysql mysql]# mysqladmin -uroot -h127.0.0.1 -p password '666666' #第二种更改密码方式，-h指定的是server地址，不是客户端地址。
3.update mysql.user set password=password('redhat') where user='root' and where host='localhost';
flush privileges;
图形客户端：1.phpMyAdmin 2.Workbench 3.Mysql Front 4.navicat for mysql 5.toad
装php-mysql的连接器(驱动)：[root@a019736cb441 conf.d]#yum install php-mysql
yum install yum-utils -y
[root@lamp 7]# repoquery -ql php-mysql
/etc/php.d/mysql.ini
/etc/php.d/mysqli.ini
/etc/php.d/pdo_mysql.ini
/usr/lib64/php/modules/mysql.so
/usr/lib64/php/modules/mysqli.so
/usr/lib64/php/modules/pdo_mysql.so
[root@a019736cb441 conf.d]#cat /www/magedu2.com/index.php
-----------------------
<?php
        $conn=mysql_connect('192.168.1.239','root','redhat123');
        if ($conn)
                echo "success...";
        else
                echo "faild...";
?> #可查看连接数据库是否成功
------------------------
【1】下载phpMyAdmin测试：
wget https://files.phpmyadmin.net/phpMyAdmin/3.4.3.2/phpMyAdmin-3.4.3.2-all-languages.tar.gz  #下载后解压到网站根目录下即可，php是不用重新启动的
phpmyadmin：修改libraries/config.default.php 文件，指定mysql服务器地址
1，查找$cfg['PmaAbsoluteUri']，将其值设置为你本地的phpmyadmin路径
2，查找$cfg['Servers'][$i]['host']，将其值设置为你mysql数据库地址，例如127.0.0.1
3，查找$cfg['Servers'][$i]['user']，将其值设置为你mysql数据库用户名，例如admin
4，查找$cfg['Servers'][$i]['password']，将其值设置为你mysql数据库密码，例如admin
【2】论坛：下载论坛进行测试，例如discuz,phpwind,phpbb
这里下载discuz:
【3】CMS：内容管理系统。drupal,joomla
【4】个人博客系统：wordpress
</pre>


#LAMP平台源码安装
####源码包各版本
<pre>
动态内容静态化：用户第一次的php请求由httpd发送给php解释器去执行，php的zend引擎去mysql拿数据并编译php生成opcode,最后zend引擎执行生成结果返回给httpd，由httpd保存在本地存储池并发送一份给客户端，当第二个用户访问相当的内容时，httpd直接去存储池拿返回给用户，这样的话访问速度快得多得多，这个就是动态内容静态化。
#编译安装LAMP
Linux,Apache,Mysql,PHP(Python,perl)
httpd:2.4.2、php5.4.13、mysql5.5（mysql通用二进制安装）
#编译安装顺序：httpd-->Mysql-->php-->XCache
#apr:Apache Portable Runtime(httpd底层是apr，可移植环境，安装后可使windows的httpd在linux上运行，反之亦然)
#编译安装httpd
先安装apr-util（apr工具）和apr，再安装httpd
1.确保 Development tools和Development Libraries都已安装
yum groupinstall -y "Development tools"
yum groupinstall -y "Development Libraries"
2.下载源码包：
apr:wget http://us.mirrors.quenda.co/apache//apr/apr-1.6.5.tar.gz
apr-util:wget http://us.mirrors.quenda.co/apache//apr/apr-util-1.6.1.tar.gz
httpd: wget http://apache.mirrors.lucidnetworks.net//httpd/httpd-2.4.38.tar.bz2
[root@Linux-node5-master-mysql download]# ls
apr-1.6.5.tar.gz  apr-util-1.6.1.tar.gz  httpd-2.4.38.tar.bz2
源码包安装次序：apr-->apr-util-->httpd
#3.源码安装apr:
 ./configure --help |less  #可以查看帮助。
 ./configure --prefix=/usr/local/apr  #由于apr默认功能足够我们用了，我们默认安装只需要指定安全路径即可
make && make install #安装。
注意：由于apr只有httpd用，所以在编译安装httpd的时候指定apr的位置即可了。
#4.源码安装apr-util:
 ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr #指定apr路径及安装路径
make && make install #安装
注意：make的时候报错：xml/apr_xml.c:35:19: fatal error: expat.h: No such file or directory
此时需要安装expat-devel,因为缺少expat.h文件。:yum install expat-devel
#5.源码安装httpd:
--enable-ssl   #启用ssl加密功能，使支持https
--enable-so   #是否支持动态共享模块（默认的），如果不启用则php无法以模块化方式跟httpd结合工作了
--sysconfdir=DIR  #选择配置目录
--enable-modules=MODULE-LIST  #启用什么模块，most为大多数的
--enable-mods-shared=MODULE-LIST  #是否以共享模式启用模块
--enable-mods-static=MODULE-LIST  #是否以静态模式启用模块
--enable-authn  #启用访问认证功能，默认是开启的，--disable-authn-file 为关闭此功能
--enable-authn-dbm    #启用认证功能dbm
--enable-authn-anon   #启用认证功能anon  
--enable-authn-dbd    #启用认证功能dbd  
--enable-authn-socache   #启用认证功能socache
--disable-authn-core   #禁用认证功能core
--enable-deflate   #启用使httpd压缩传输
--enable-expires #过期首部控制
--enable-proxy-fcgi  #开启httpd的fastCGI协议，将支持与php使用fastCGI
模块化方式使用MPM，可以单独把prefork,worker,event编译成三个不同的模块，在需要的时候直接调用即可，但是，在php和prefork相结合的时候php不受影响，可以正常使用，当php与worker或者php与event相结合使用时，php必须编译成zts格式
注意：httpd2.2版本默认是prefork格式，2.4以后默认是event模式了
--enable-mpms-shared=MPM-LIST #启用prefork或worker或event或all（所有模式）
--with-mpm=MPM  #明确指定哪个模式为默认的，如果不指则event为默认模式
--enable-rewrite  #是否支持URL重写
--enable-cgi  #开启CGI给prefork使用的
--enable-cgid   #开启CGI给线程使用的，worker或event MPM使用
#编译安装httpd:
yum install -y pcre-devel  #安装httpd-2.4.38.tar.bz2时需要解决依赖关系
#collect2: error: ld returned 1 exit status #报这个错
yum install -y libxml2-devel #安装httpd-2.4.10.tar.gz时出错需要这个依赖
#注意：缺少了xml相关的库，需要安装libxml2-devel包。直接安装并不能解决问题，因为httpd调用的apr-util已经安装好了，但是apr-util并没有libxml2-devel包支持。

[root@Linux-node5-master-mysql httpd-2.4.38]# ./configure --prefix=/usr/local/httpd-2.4.38 --sysconfdir=/etc/httpd --enable-so --enable-rewrite --enable-ssl --enable-cgi --enable-cgid --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --with-mpm=event --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
make && make install #安装



注：默认web服务器是受SElinux控制的。检查SElinux是否关掉。--enable-modules=most开启能够实现绝大多数编译的模块
cd /usr/local/ &&  ln -s httpd-2.4.38/ apache
bin/apachectl start #启动httpd
tree -d
.
├── bin  #二进制程序都在这
├── build  #编译时候的目录
├── cgi-bin  #执行cgi程序的存放位置
├── error  #错误信息
│?? └── include
├── htdocs  #手动编译安装时，网页文件位置在这
├── icons  #图标
│?? └── small
├── include  #头文件
├── logs  #日志文件
├── man  #帮助文件
│?? ├── man1
│?? └── man8
├── manual  #官方手册
│?? ├── developer
│?? ├── faq
│?? ├── howto
│?? ├── images
│?? ├── misc
│?? ├── mod
│?? ├── platform
│?? ├── programs
│?? ├── rewrite
│?? ├── ssl
│?? ├── style
│?? │?? ├── css
│?? │?? ├── lang
│?? │?? ├── latex
│?? │?? ├── scripts
│?? │?? └── xsl
│?? │??     └── util
│?? └── vhosts
└── modules  #模块目录
[root@Linux-node5-master-mysql apache]# vim /etc/httpd/httpd.conf #如果编译时不指定配置目录，现在在/usr/local/httpd-2.4.38/目录下有conf目录的，指定了则移动到指定位置了
[root@Linux-node5-master-mysql apache]# ls logs/
access_log  error_log  httpd.pid  #由于httpd.pid文件在logs目录下不标准，下面更改下
[root@Linux-node5-master-mysql apache]# bin/apachectl stop #先停止apache服务再改配置
[root@Linux-node5-master-mysql apache]# vim /etc/httpd/httpd.conf
PidFile "/var/run/httpd.pid" #加一行，更改pid目录
[root@Linux-node5-master-mysql apache]# bin/apachectl start
[root@Linux-node5-master-mysql apache]# ls logs/ 
access_log  error_log   #此时已经更改成功
[root@Linux-node5-master-mysql apache]# ls /var/run/httpd.pid 
/var/run/httpd.pid  #更改的位置
httpd服务脚本：
[root@Linux-node5-master-mysql init.d]# cat /etc/init.d/httpd #适合于redhat 5.8
-----------------
#!/bin/bash

. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/httpd ];then
        . /etc/sysconfig/httpd
fi

HTTPD_LANG=${HTTPD_LANG-"C"}

INITLOG_ARGS=""

apachectl=/usr/local/apache/bin/apachectl
httpd=${HTTPD-/usr/local/apache/bin/httpd}
prog=httpd
pidfile=${PIDFILE-/var/run/httpd.pid}
lockfile=${LOCKFILE-/var/lock/subsys/httpd}
RETVAL=0

start(){
        echo -n $"Starting $prog:"
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $httpd $OPTIONS
        RETVAL=$?
        echo
        { $RETVAL = 0 } && touch ${lockfile}
        return $RETVAL
}

stop(){
        echo -n $"Stopping $prog:"
        killproc -p ${pidfile} -d 10 $httpd
        RETVAL=$?
        echo
        { $RETVAL = 0 } && rm -f ${lockfile} ${pidfile}
}

reload(){
        echo -n $"Reloading $prog:"
        if ! LANG=$HTTPD_LANG $httpd $OPTIONS -t >&/dev/null; then
                RETVAL=$?
                echo $"not reloading due to configuration syntax error"
                failure $"not reloading $httpd due to configuration syntax error"
        else
                killproc -p ${pidfile} $httpd -HUP
                RETVAL=$?
        fi
        echo
}

# See how we were called.
case "$1" in
        start)
                start
                ;;
        stop)
                stop
                ;;
        status)
                status -p ${pidfile} $httpd
                RETVAL=$?
                ;;
        restart)
                stop
                start
                ;;
        condrestart)
                if [ -f ${pidfile} ];then
                        stop
                        start
                fi
                ;;
        reload)
                reload
                ;;
        graceful|help|configtest|fullstatus)
                $apachectl $@
                RETVAL=$?
                ;;
        *)
                echo $"Usage: $prog {start|stop|restart|condrestart|reload|status|fullstatus|granceful|help|configtest}"
                exit 1
                ;;
esac

exit $RETVAL
-----------------
注:添加后可使用service httpd start|stop|status|restart来启动服务，也可使chkconfig来管理服务
[root@Linux-node5-master-mysql bin]# vim /etc/profile.d/httpd.sh
export PATH=$PATH:/usr/local/apache/bin #加一行变量
[root@Linux-node5-master-mysql bin]# . /etc/profile.d/httpd.sh #使变量生效
也可使用apachectl自带的脚本，一步轻松搞定：
[root@Linux-node5-master-mysql init.d]# ln -s /usr/local/apache/bin/apachectl httpd
注:软链接后可使用service httpd start|stop|status|restart来启动服务
[root@Linux-node5-master-mysql init.d]# chkconfig --add httpd #这里是centos7.5，使用的httpd是从/usr/local/apache/bin/下的httpd复制过去的，所以会报错
service httpd does not support chkconfig
--------------
在vi /etc/rc.d/init.d/httpd 添加(#!/bin/sh下面)
#chkconfig: 2345 10 90
#description: Activates/Deactivates Apache Web Server
--------------

[root@Linux-node5-master-mysql bin]# vim /etc/httpd/httpd.conf #修改为prefork模式，重启服务生效
#LoadModule mpm_event_module modules/mod_mpm_event.so
 LoadModule mpm_event_module modules/mod_mpm_prefork.so #修改当前行

#httpd2.4新特性
1. MPM可于运行时加载：--enable-mpms-shared=all --with-mpm=event。前者是开启多模块，后者指定运行的模块
2. 支持Event MPM
3. 异步读写：可以大大的提升httpd的性能
4. 在每模块及每目录上可以指定日志级别
5. 可以实现每请求配置：<if><elseif><esle>比如你请求的文件，我可以对某个文件进行授权
6. 增加的表达式分析器
7. 支持毫秒级的KeepAlive Timeout:以前只支持秒，现在到毫秒级
8. 基于域名的虚拟主机不再需要NameVirtualHost指令
9. 降低了内存占用
10. 支持在配置文件中使用自定义变量
11. 
对于基于IP的访问控制：
以前2.2版本httpd:
Order allow,deny
allow from all
现在2.4版本不再支持2.2版本写法，使用Require:
Require ip IPADDR  #172.168.0.0/255.255.255.0 = 172.168.0.0/16 = 172.16
Require host HOSTNAME  #www.magedu.com   .magedu.com
Require user USERNAME
Require group GROUPNAME
Require all granted  #授权所有主机访问
Require all deny  #拒绝所有主机访问
注：如果拒绝主机或用户访问等，在Require后面加not取反即可，例：Require not ip IPADDR,配置规则是自上而下和最佳配置来完成的。

2.4新增加的模块：
mod_proxy_fcgi  #--enable--modules=most 这个是开启fastCGI的
mod_proxy_acgi
mod_proxy_express
mod_remoteip
mod_session
mod_ratelimit
mod_request
等等：
注：2.2版本的httpd有mod_proxy，像mod_proxy_fcgi是没有的，在2.2版本上要使用需要额外安装第三方模块。在2.4版本支持编译安装了。mod_proxy_*等是对mod_proxy的补充



##Mysql编译安装
#mysql-5.5的编译安装
[root@Linux-node5-master-mysql download]# wget https://dev.mysql.com/get/Downloads/MySQL-5.5/mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz #下载mysql-5.5通用二进制
[root@Linux-node5-master-mysql download]# wget https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz  #下载mysql-5.6通用二进制
[root@Linux-node5-master-mysql download]# tar -xf mysql-5.5.62-linux-glibc2.12-x86_64.tar.gz -C /usr/local #通用二进制格式解压就能用，官方要求解压的包必须在/usr/local下,并且目录名称为mysql才行
[root@Linux-node5-master-mysql local]# ln -s mysql-5.5.62-linux-glibc2.12-x86_64/ mysql
[root@Linux-node5-master-mysql mysql]# pwd
/usr/local/mysql
[root@Linux-node5-master-mysql mysql]# ll -h
total 44K
drwxr-xr-x  2 root root  4.0K Mar 26 11:27 bin
-rw-r--r--  1 7161 31415  18K Aug 29  2018 COPYING
drwxr-xr-x  3 root root    18 Mar 26 11:27 data
drwxr-xr-x  2 root root    55 Mar 26 11:27 docs
drwxr-xr-x  3 root root  4.0K Mar 26 11:27 include
-rw-r--r--  1 7161 31415  301 Aug 29  2018 INSTALL-BINARY
drwxr-xr-x  3 root root   316 Mar 26 11:27 lib
drwxr-xr-x  4 root root    30 Mar 26 11:27 man
drwxr-xr-x 10 root root   291 Mar 26 11:27 mysql-test
-rw-r--r--  1 7161 31415 2.5K Aug 29  2018 README
drwxr-xr-x  2 root root    30 Mar 26 11:27 scripts
drwxr-xr-x 27 root root  4.0K Mar 26 11:27 share
drwxr-xr-x  4 root root  4.0K Mar 26 11:27 sql-bench
drwxr-xr-x  2 root root   325 Mar 26 11:27 support-files
创建mysql用户及mysql组：
[root@Linux-node5-master-mysql mysql]# groupadd -r -g 306 mysql #-r为系统用户，-g为指定gid
[root@Linux-node5-master-mysql mysql]# useradd -g 306 -r -u 306 mysql #-r为系统用户，-u为uid,-g为gid
[root@Linux-node5-master-mysql mysql]# id mysql
uid=306(mysql) gid=306(mysql) groups=306(mysql)
[root@Linux-node5-master-mysql mysql]# grep mysql /etc/passwd
mysql:x:306:306::/home/mysql:/bin/bash #shell为/bin/bash，mysql为系统用户，所有是没有用户目录的
[root@Linux-node5-master-mysql mysql]# less INSTALL-BINARY #查看二进制的安装手册，
[root@Linux-node5-master-mysql mysql]# chown -R mysql:mysql ./* #改变mysql属主和属组
[root@Linux-node5-master-mysql mysql]# scripts/mysql_install_db --help  #mysql_install_db这个脚本是初始化mysql的，初始化完才能使用mysql服务，yum安装时只需要服务启动就是初始化了
--user=user_name  #初始化时使用的用户
--datadir=path    #初始化时指定数据库路径，推荐使用LVM逻辑卷存储
[root@Linux-node5-master-mysql mysql]# mkdir /mydata/data -p #这里用系统卷测试
[root@Linux-node5-master-mysql mydata]# chmod o-rx data/ #设置其他用户无读和执行权限
[root@Linux-node5-master-mysql mydata]# ll
total 0
drwxr-x--- 2 mysql mysql 6 Mar 26 13:40 data
[root@Linux-node5-master-mysql mysql]# scripts/mysql_install_db --user=mysql --datadir=/mydata/data #初始化mysql
[root@Linux-node5-master-mysql mysql]# chown -R root /usr/local/mysql/* #未避免mysql用户被攻破，所以这里把属主还改成root
[root@Linux-node5-master-mysql mysql]# ll
total 44
drwxr-xr-x  2 root mysql  4096 Mar 26 11:27 bin
-rw-r--r--  1 root mysql 17987 Aug 29  2018 COPYING
drwxr-xr-x  3 root mysql    18 Mar 26 11:27 data
drwxr-xr-x  2 root mysql    55 Mar 26 11:27 docs
drwxr-xr-x  3 root mysql  4096 Mar 26 11:27 include
-rw-r--r--  1 root mysql   301 Aug 29  2018 INSTALL-BINARY
drwxr-xr-x  3 root mysql   316 Mar 26 11:27 lib
drwxr-xr-x  4 root mysql    30 Mar 26 11:27 man
drwxr-xr-x 10 root mysql   291 Mar 26 11:27 mysql-test
-rw-r--r--  1 root mysql  2496 Aug 29  2018 README
drwxr-xr-x  2 root mysql    30 Mar 26 11:27 scripts
drwxr-xr-x 27 root mysql  4096 Mar 26 11:27 share
drwxr-xr-x  4 root mysql  4096 Mar 26 11:27 sql-bench
drwxr-xr-x  2 root mysql   325 Mar 26 11:27 support-files
[root@Linux-node5-master-mysql support-files]# cp mysql.server /etc/init.d/mysqld #将mysql提供的启动脚本复制到/etc/init.d/目录下，叫mysqld
[root@Linux-node5-master-mysql support-files]# ls /etc/init.d/mysqld -l
-rwxr-xr-x 1 root root 10565 Mar 26 13:47 /etc/init.d/mysqld
[root@Linux-node5-master-mysql support-files]# chkconfig --add mysqld #将mysqld加入chkconfig下，因为mysql.service默认添加了#chkconfig 2345这个选项
[root@Linux-node5-master-mysql support-files]# chkconfig --list mysqld #默认2345启动
mysqld          0:off   1:off   2:on    3:on    4:on    5:on    6:off
#mysql的配置文件：/etc/my.cnf
mysql为集中式配置文件，为多个程序提供配置：
[mysql] #为mysql客户端设置配置文件
[mysqld] #为服务端设置配置文件
[client] #为所有客户端程序设置的，例如mysql,mysqladmin等
注：mysql找配置文件次序：1./etc/my.cnf。2./etc/mysql/my.cnf（mysql进程目录）。3.$BASEDIR/my.cnf。4.~/.my.cnf（mysql没有家目录，没有就忽略）。----越后面的配置文件会覆盖前面的配置文件，以最后一个为准，如果没有配置文件mysql也可以跑起来，因为它有默认定义的。
[root@Linux-node5-master-mysql support-files]# ls #mysql默认提供了5种配置文件
binary-configure   my-huge.cnf             mysqld_multi.server
config.huge.ini    my-innodb-heavy-4G.cnf  mysql-log-rotate
config.medium.ini  my-large.cnf            mysql.server
config.small.ini   my-medium.cnf           ndb-config-2-node.ini
magic              my-small.cnf
[root@Linux-node5-master-mysql support-files]# cp my-huge.cnf /etc/my.cnf #选择适合自己服务器配置的配置文件到/etc下改名为my.cnf
[root@Linux-node5-master-mysql support-files]# vim /etc/my.cnf
socket          = /tmp/mysql.sock  #mysql的锁文件
thread_concurrency = 4 #线程并发数，等于cpu个数X2
datadir = /mydata/data #因为你改过数据库目录，所以这里要写明数据库目录
[root@Linux-node5-master-mysql support-files]# service mysqld start  #正式启动mysqld服务
Starting MySQL.Logging to '/mydata/data/Linux-node5-master-mysql.err'.
. SUCCESS! 
[root@Linux-node5-master-mysql support-files]# netstat -tnlp  #查看是否启动正常
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 0.0.0.0:10050           0.0.0.0:*               LISTEN      10106/zabbix_agentd 
tcp        0      0 0.0.0.0:3306            0.0.0.0:*               LISTEN      1605/mysqld         
tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      560/rpcbind         
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      10893/sshd          
tcp6       0      0 :::10050                :::*                    LISTEN      10106/zabbix_agentd 
tcp6       0      0 :::111                  :::*                    LISTEN      560/rpcbind         
tcp6       0      0 :::22                   :::*                    LISTEN      10893/sshd          
[root@Linux-node5-master-mysql support-files]# mysql #用mysql连接mysqld服务端。通用二进制mysql装的时候mysql客户端也一起装的
MySQL [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |  #nformation_schema就像是MySQL实例的一个百科全书，记录了数据库当中大部分我们需要了结的信息
| mysql              |
| performance_schema |  #这是一个系统状态信息收集库，比如哪些用户连接进来过，哪个用户连接进来后服务端发送了多少流量出去
| test               |
+--------------------+

#mysql服务器维持了两类变量：
#1.服务器变量：定义mysql服务器运行特性，改变服务器运行状态的。
SHOW GLOBAL VARIABLES
MySQL [(none)]> SHOW GLOBAL VARIABLES LIKE 'basedir';
MySQL [(none)]> SHOW GLOBAL VARIABLES LIKE 'data%';
#2.状态变量：保存了mysql服务器运行的统计数据
SHOW GLOBAL STATUS
MySQL [(none)]> show global status;
 Bytes_received                           | 422         |  #显示mysql服务启动到现在接收了多少字数
| Bytes_sent                               | 19551       | #显示mysql服务启动到现在发送了多少字节
MySQL [(none)]> select version();  #查看mysql版本
+------------+
| version()  |
+------------+
| 5.5.62-log |
+------------+
MySQL [mysql]> select database(); #查看默认数据库
+------------+
| database() |
+------------+
| mysql      |
+------------+
MySQL [mysql]> SELECT USER(); #查看当前用户
+----------------+
| USER()         |
+----------------+
| root@localhost |
+----------------+
MySQL [(none)]> SHOW GLOBAL STATUS LIKE '%select%';
+------------------------+-------+
| Variable_name          | Value |
+------------------------+-------+
| Com_insert_select      | 0     |
| Com_replace_select     | 0     |
| Com_select             | 8     |  #服务启动到现在执行了8个select语句
| Select_full_join       | 0     |
| Select_full_range_join | 0     |
| Select_range           | 0     |
| Select_range_check     | 0     |
| Select_scan            | 11    |
+------------------------+-------+
注：以后调优mysql主要集中在服务器变量和状态变量上，调优mysql需要调节服务器变量，测试状态变量性能是否提升
#导出帮助文件路径
vim /etc/man.config #编辑man的配置文件
MANPATH /usr/local/mysql/man  #添加mysql的帮助手册 
#导出库文件
[root@Linux-node5-master-mysql mysql]# vim /etc/ld.so.conf.d/mysql.conf
/usr/local/mysql/lib  #添加mysql的库文件路径即可
[root@Linux-node5-master-mysql mysql]# ldconfig -v #同步库文件
#内核到哪去找库文件：开机自动找到库文件然后缓存到/etc/ld.so.cache中，刚才新建的没有缓存，ldconfig让操作系统重新建立库文件缓存的。
#导出头文件
[root@Linux-node5-master-mysql mysql]# ln -sv /usr/local/mysql/include /usr/include/mysql #把include头文件软链接到/usr/include/下
注意：导出帮助文件，导出库文件，导出头文件不是必须的，只是不这样做某些功能实现不了

#PHP编译安装：
#php3种功能模式：CGI,php_mod,fastCGI  #对于apache而言，最简单的还是php_mod
php5.6.12下载:wget https://www.php.net/distributions/php-5.6.12.tar.bz2
#怎么把php安装成为httpd的模块？
------------
./configure \
--prefix=/usr/local/php \   #安装目录
--with-mysql=/usr/local/mysql \  #告诉mysql在哪个位置
--with-openssl \   #开启openssl功能
--with-mysqli=/usr/local/mysql/bin/mysql_config \ #mysql另外一种接口，让php和mysql交互的接口，接口程序是/usr/local/mysql/bin/mysql_config
--enable-mbstring \ #多字节string,支持中文或非一个字节能表示字符的语言的
--with-freetype-dir \  #加载freetype的头文件，支持freetype的功能，让你能引用特定字体的。
--with-jpeg-dir \ #支持jpeg图片
--with-png-dir \  #支持png图片
--with-zlib \  #互联网常用的通用的压缩库，让文件先压缩再传送，节约带宽
--with-libxml-dir=/usr \  #告诉xml的库在什么地方
--enable-xml \  #开启xml功能（扩展标记语言），实现系统数据交换的
--enable-sockets \  #让php支持基于套接字通信
--with-apxs2=/usr/local/apache/bin/apxs \  #基于apxs的勾子能够实现让php编译成httpd的模块
--with-mcrypt \  #支持加密功能的，额外的加密库
--with-config-file-path=/etc \  #php的主配置文件php.ini目录
--with-config-file-scan-dir=/etc/php.d \  #php的配置文件目录，在主文件中include /etc/php.d进来的
--with-bz2 \  #压缩库
--enable-maintainer-zts  #要不要用取决于httpd是什么类型的，如果httpd以进程工作(prefork)则不需要，如果以线程(worker或event)才需要用他
--------------
[root@Linux-node5-master-mysql php-5.4.13]# httpd -M
Loaded Modules:
 core_module (static)
 so_module (static)
 http_module (static)
 mpm_event_module (shared)  #说明现在httpd现在是event模式
 authn_file_module (shared)
 authn_core_module (shared)
 authz_host_module (shared)
 authz_groupfile_module (shared)
 authz_user_module (shared)
 authz_core_module (shared)
 access_compat_module (shared)
 auth_basic_module (shared)
 reqtimeout_module (shared)
 filter_module (shared)
 mime_module (shared)
 log_config_module (shared)
 env_module (shared)
 headers_module (shared)
 setenvif_module (shared)
 version_module (shared)
 unixd_module (shared)
 status_module (shared)
 autoindex_module (shared)
 dir_module (shared)
 alias_module (shared)

编译php成模块模式:
[root@Linux-node5-master-mysql php-5.4.13]# ./configure --prefix=/usr/local/php-5.4.13 --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-sockets --with-apxs2=/usr/local/apache/bin/apxs --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 --enable-maintainer-zts

#报错：configure: error: xml2-config not found. Please check your libxml2 installation.----提示检查libxml2安装包
注意：这个时候可以去google搜索，也可以去http://rpmfind.net/这里找
[root@Linux-node5-master-mysql php-5.4.13]# rpm -qa | grep libxml2
libxml2-2.9.1-6.el7_2.3.x86_64
libxml2-python-2.9.1-6.el7_2.3.x86_64
[root@Linux-node5-master-mysql php-5.4.13]# yum list all | grep libxml2
Trying other mirror.
libxml2.x86_64                          2.9.1-6.el7_2.3          @anaconda      
libxml2-python.x86_64                   2.9.1-6.el7_2.3          @anaconda      
libxml2.i686                            2.9.1-6.el7_2.3          base           
libxml2-devel.i686                      2.9.1-6.el7_2.3          base     #是这个包没有安装       
libxml2-devel.x86_64                    2.9.1-6.el7_2.3          base           
libxml2-static.i686                     2.9.1-6.el7_2.3          base           
libxml2-static.x86_64                   2.9.1-6.el7_2.3          base        
#安装依赖包：[root@Linux-node5-master-mysql php-5.4.13]# yum install -y libxml2-devel.x86_64 
#报错：configure: error: Please reinstall the BZip2 distribution
安装依赖包：[root@Linux-node5-master-mysql php-5.4.13]# yum install -y bzip2-devel.x86_64
#报错：configure: error: mcrypt.h not found. Please reinstall libmcrypt.
[root@lamp php-5.6.12]# yum install epel-release
安装依赖包：[root@Linux-node5-master-mysql php-5.4.13]# yum install -y libmcrypt libmcrypt-devel
[root@Linux-node5-master-mysql php-5.4.13]# echo $?  #最后编译完成成功
0
[root@Linux-node5-master-mysql php-5.4.13]# make && make install #安装

/etc/php.ini
/etc/php.d.ini
#需不需要启动php服务？
如果做成了模块就不需要，如果做成了fastCGI则需要启动服务。
#如何做成fastCGI模式？
把php编译成fastCGI模式：
[root@Linux-node5-master-mysql php-5.4.13]# ./configure --prefix=/usr/local/php-5.4.13 --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-sockets --enable-fpm --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 --enable-maintainer-zts
注：把--with-apxs2=/usr/local/apache/bin/apxs这项去掉，换成--enable-fpm，只能开启一个模式

————————————————
#查看nginx编译参数：/usr/local/nginx/sbin/nginx -V 查看apache编译参数：cat /usr/local/apache2/build/config.nice 查看mysql编译参数：cat /usr/local/mysql/bin/mysqlbug | grep CONFIGURE_LINE 查看php编译参数：/usr/local/php/bin/php -i | grep configure
————————————————

[root@lamp ~]# cat /usr/local/httpd-2.4.38/build/config.nice  #build目录下可查看编译时的参数
#! /bin/sh
#
# Created by configure

"./configure" \
"--prefix=/usr/local/httpd-2.4.38" \
"--sysconfdir=/etc/httpd" \
"--enable-so" \
"--enable-rewrite" \
"--enable-ssl" \
"--enable-cgi" \
"--enable-cgid" \
"--enable-modules=most" \
"--enable-mods-shared=most" \
"--enable-mpms-shared=all" \
"--with-mpm=event" \
"--with-apr=/usr/local/apr" \
"--with-apr-util=/usr/local/apr-util" \
"$@"

[root@Linux-node5-master-mysql php]# ls bin/ #php-config和phpize是php命令行工具
pear  peardev  pecl  phar  phar.phar  php  php-cgi  php-config  phpize
[root@Linux-node5-master-mysql php]# ls etc/ #为php其他子项目提供的配置文件存放路径
pear.conf
[root@Linux-node5-master-mysql php]# ls include/ #php头文件
php
[root@Linux-node5-master-mysql php]# ls lib/ #php库文件
php
[root@Linux-node5-master-mysql php]# ls php/ #php手册
man
[root@Linux-node5-master-mysql php]# ll /usr/local/apache/modules/libphp5.so  #libphp5.so为安装的php模块,权限为755，默认没有被httpd加载
-rwxr-xr-x 1 root root 31580192 Mar 26 17:52 /usr/local/apache/modules/libphp5.so
[root@Linux-node5-master-mysql php-5.4.13]# cp php.ini-production /etc/php.ini #从源码包下复制生产环境的配置文件到/etc目录下，名称叫php.ini。因为php编译的时候参数指定配置文件目录为/etc
#如何让httpd跟php相结合工作？
首先要让php能够处理以php页面结尾的文件，所以这里先编辑httpd配置文件，添加php类型。
[root@Linux-node5-master-mysql htdocs]# vim /etc/httpd/httpd.conf
AddType application/x-httpd-php .php  #添加php文件
AddType application/x-httpd-php-source .phps #添加php源码文件
<IfModule dir_module>
    DirectoryIndex  index.php index.html  #添加index.php索引
</IfModule>

Include /etc/httpd/extra/httpd-ssl.conf #这是启用ssl的，还要装载ssl模块

[root@Linux-node5-master-mysql htdocs]# cat index.php #添加php函数到索引测试php
<html><body><h1>It works!</h1></body></html>
<?php
phpinfo();
?>

[root@Linux-node5-master-mysql htdocs]# cat index.php #编辑index.php,添加测试mysql数据库配置到网页测试
<html><body><h1>It works!</h1></body></html>
<?php
        $conn=mysql_connect('localhost','root','');
        if ($conn)
                echo "Success...";
        else
                echo "Faild.....";
?>

#配置XCache:
XCache资源网站：https://xcache.lighttpd.net/
下载XCache:wget https://xcache.lighttpd.net/pub/Releases/3.1.2/xcache-3.1.2.tar.gz
[root@Linux-node5-master-mysql download]# tar  xf xcache-3.1.2.tar.gz
[root@Linux-node5-master-mysql download]# cd xcache-3.1.2/
[root@Linux-node5-master-mysql xcache-3.1.2]# ls /usr/local/php/php/man/man1/
php.1  php-config.1  phpize.1 
[root@Linux-node5-master-mysql xcache-3.1.2]# man -M /usr/local/php/php/man phpize #查看帮助手册
[root@Linux-node5-master-mysql xcache-3.1.2]# pwd  #必须在此路径下，然后使用phpize命令
/download/xcache-3.1.2
#[root@Linux-node5-master-mysql xcache-3.1.2]# /usr/local/php/bin/phpize #所有php扩展，编译前必须使用phpize命令，让扩展识别php
Configuring for:
PHP Api Version:         20100412
Zend Module Api No:      20100525
Zend Extension Api No:   220100525
  ##Cannot find autoconf. Please check your autoconf installation and the $PHP_AUTOCONF environment vari  #如何错错安装yum install autoconf
#编译xcache:
[root@Linux-node5-master-mysql xcache-3.1.2]# ./configure --enable-xcache --with-php-config=/usr/local/php/bin/php-config
注：
--prefix #这项是不写的，xcache默认会安装在php的扩展路径下的
--enable-xcache  #为开启xcache
--with-php-config=/usr/local/php/bin/php-config  #通过指定--with-php-config路径来获取php在编译时开启了哪些功能。因为php安装的配置信息等不在默认路径下，所以告诉xcache,不然xcache找不到的。
[root@Linux-node5-master-mysql xcache-3.1.2]# make && make install
Installing shared extensions:     /usr/local/php-5.4.13/lib/php/extensions/no-debug-zts-20100525/  #安装扩展的路径
[root@Linux-node5-master-mysql xcache-3.1.2]# ls /download/xcache-3.1.2
 xcache.ini  #xcache提供的样例性配置文件
[root@Linux-node5-master-mysql xcache-3.1.2]# mkdir /etc/php.d #新建php.d目录，目录下配置文件会被php.ini主配置加载
[root@Linux-node5-master-mysql xcache-3.1.2]# cp xcache.ini /etc/php.d/ #复制xcache.ini配置文件到/etc/php.d/目录下
vim /etc/php.d/xcache.ini 
[xcache-common]
;; non-Windows example:
#extension = xcache.so
extension = /usr/local/php-5.4.13/lib/php/extensions/no-debug-zts-20100525/xcache.so #把上面的行改成xcache的扩展目录，上面xcache安装成功后有返回的
[xcache.admin]
xcache.admin.enable_auth = On #是否开启管理员认证
; use http://xcache.lighttpd.net/demo/cacher/mkpassword.php to generate your encrypted password
xcache.admin.user = "mOo" #管理员姓名
xcache.admin.pass = "md5 encrypted password" #管理员密码
[xcache]
; ini only settings, all the values here is default unless explained
; select low level shm implemenation
xcache.shm_scheme =        "mmap"  #使用哪种方式共享内存，使用mmap方式
; to disable: xcache.size=0
; to enable : xcache.size=64M etc (any size > 0) and your system mmap allows
xcache.size  =               60M  #opcode存储器大小
; set to cpu count (cat /proc/cpuinfo |grep -c processor)
xcache.count =                 1  #cpu个数
; just a hash hints, you can always store count(items) > slots
xcache.slots =                8K  #存储器缓存槽位，有多少个缓存来缓存opcode,槽位大小为8K
; ttl of the cache item, 0=forever
xcache.ttl   =                 0  #过期时间，0表示永远不过期，由xcache自我管理
; interval of gc scanning expired items, 0=no scan, other values is in seconds
xcache.gc_interval =           0  #垃圾回收器多久工作一次，0表示不做任何扫描的。
; same as aboves but for variable cache
xcache.var_size  =            4M  #变量缓存多大
xcache.var_count =             1  #变量缓存多少个
xcache.var_slots =            8K  #变量缓槽位大小
; default value for $ttl parameter of xcache_*() functions
xcache.var_ttl   =             0
; hard limit ttl that cannot be exceed by xcache_*() functions. 0=unlimited
xcache.var_maxttl   =          0
xcache.var_gc_interval =     300
; mode:0, const string specified by xcache.var_namespace
; mode:1, $_SERVER[xcache.var_namespace]
; mode:2, uid or gid (specified by xcache.var_namespace)
xcache.var_namespace_mode =    0
xcache.var_namespace =        ""
; N/A for /dev/zero
xcache.readonly_protection = Off
; for *nix, xcache.mmap_path is a file path, not directory. (auto create/overwrite)
; Use something like "/tmp/xcache" instead of "/dev/*" if you want to turn on ReadonlyProtection
; different process group of php won't share the same /tmp/xcache
; for win32, xcache.mmap_path=anonymous map name, not file path
xcache.mmap_path =    "/dev/zero"
; Useful when XCache crash. leave it blank(disabled) or "/tmp/phpcore/" (writable by php)
xcache.coredump_directory =   ""
; Windows only. leave it as 0 (default) until you're told by XCache dev
xcache.coredump_type =         0
; disable cache after crash
xcache.disable_on_crash =    Off
; enable experimental documented features for each release if available
xcache.experimental =        Off
; per request settings. can ini_set, .htaccess etc
xcache.cacher =               On  #xcache缓存功能是否启用
xcache.stat   =               On  
xcache.optimizer =           Off  #xcache自身优化器是否启用，不用启用
[xcache.coverager]
; enabling this feature will impact performance
; enabled only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; per request settings. can ini_set, .htaccess etc
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager =           Off
xcache.coverager_autostart =  On
; set in php ini file only
; make sure it's readable (open_basedir is checked) by coverage viewer script
xcache.coveragedump_directory = ""
                               
注：xcache配置标注的要改和留意，其他未改的为默认
[root@Linux-node5-master-mysql xcache-3.1.2]# service httpd restart  #要想使xcache生效，必须重启web服务器。
[root@Linux-node5-master-mysql xcache-3.1.2]# cat /usr/local/apache/htdocs/index.php
<html><body><h1>It works!</h1></body></html>
<?php
        $conn=mysql_connect('localhost','root','');
        if ($conn)
                echo "Success...";
        else
                echo "Faild.....";
phpinfo();   #加入此行，要看xcache是否开启，然后打开网页测试
?>
http://192.168.1.238   #查看opcode cache是否开启，如下则为开启了xcaches
Opcode Cache 	enabled, 62,914,560 bytes, 1 split(s), with 8192 slots each 

#虚拟主机：
[root@Linux-node5-master-mysql ~]# vim /etc/httpd/httpd.conf
#DocumentRoot "/usr/local/httpd-2.4.38/htdocs" #注释中心主机
Include /etc/httpd/extra/httpd-vhosts.conf  #把虚拟主机配置开启
[root@Linux-node5-master-mysql ~]# vim /etc/httpd/extra/httpd-vhosts.conf  #编辑虚拟主机文件
# Required modules: mod_log_config  #虚拟主机配置文件中有注释需要mod_log_config这个模块，因为我们要去httpd.conf开启这个模块
[root@Linux-node5-master-mysql ~]# vim /etc/httpd/httpd.conf
LoadModule log_config_module modules/mod_log_config.so  #默认是开启的，最好启用
[root@Linux-node5-master-mysql ~]# vim /etc/httpd/extra/httpd-vhosts.conf  #编辑虚拟主机文件
<VirtualHost *:80>
    ServerName www.a.org
    DocumentRoot "/www/a.org"
    ErrorLog "/var/log/httpd/a.org-error_log"
    CustomLog "/var/log/httpd/a.org-access_log" combined
</VirtualHost>

<VirtualHost *:80>
    ServerName www.b.net
    DocumentRoot "/usr/local/httpd-2.4.38/docs/dummy-host2.example.com"
    ErrorLog "/var/log/httpd/b.net-error_log"
    CustomLog "/var/log/httpd/b.net-access_log" common
</VirtualHost>
#注：打开www.a.org和www.b.net访问是被拒绝，可以到httpd中心主机去查看是什么没有设置，一看是这个中心主机设置了目录访问权限而虚拟主机没有设置目录访问权限。说明2.4版本默认不设置则拒绝所有访问
<Directory "/usr/local/httpd-2.4.38/htdocs">
Options Indexes FollowSymLinks #中心主机打开索引
AllowOverride None   #不开启.htaccess文件权限,而指定Require选项的
Require all granted  #授权所有者访问
[root@Linux-node5-master-mysql a.org]# cat /etc/httpd/extra/httpd-vhosts.conf
-----------------------
<VirtualHost *:80>
    ServerName www.a.org
    DocumentRoot "/www/a.org"
    ErrorLog "/var/log/httpd/a.org-error_log"
    CustomLog "/var/log/httpd/a.org-access_log" combined
    <Directory "/www/a.org">
        Options none
        AllowOverride none
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    ServerName www.b.net
    DocumentRoot "/www/b.net"
    <Directory "/www/b.net">
        Options none
        AllowOverride none
        Require all granted
    </Directory>
    ErrorLog "/var/log/httpd/b.net-error_log"
    CustomLog "/var/log/httpd/b.net-access_log" common
</VirtualHost>
-----------------------
性能压力评估测试工具：ab - Apache HTTP server benchmarking tool
-c  #concurrency并发数
-n  #一共多少个请求
[root@Linux-node5-master-mysql bin]# /usr/local/httpd-2.4.38/bin/ab -c 10 -n 100 http://www.a.org/index.html  #10个并发，100个请求
Benchmarking www.a.org (be patient).....done
Server Software:        Apache/2.4.38 #服务端软件及版本
Server Hostname:        www.a.org #服务端主机名
Server Port:            80  #服务端端口
Document Path:          /index.html #服务端URL
Document Length:        19 bytes  #请求文档大小
Concurrency Level:      10   #并发数为10
Time taken for tests:   0.054 seconds #从发的第一个请求到收到的最后一个回应共花了0.054秒
Complete requests:      100  #完成100个请求
Failed requests:        0 #失败请求为0
Total transferred:      27400 bytes  #服务器全部转发到客户端流量的大小，除于总请求次数的大小得到的是单个请求的大小，这个大小包括数据包以及tcp、ip、帧的大小
HTML transferred:       1900 bytes  #单个请求的数据包大小
Requests per second:    1859.22 [#/sec] (mean)  #每秒的请求数
Time per request:       5.379 [ms] (mean) #指定的是每一批并发数所花的平均时间
Time per request:       0.538 [ms] (mean, across all concurrent requests) #指的是每个请求平均所花的时间
Transfer rate:          497.49 [Kbytes/sec] received #传输速率，每秒传输了多少字节

Connection Times (ms) #连接时间

              min  mean[+/-sd] median   max
Connect:        0    0   0.1      0       0   #建立连接的时间
Processing:     0    5   5.6      3      24   #处理过程花费时间
Waiting:        0    5   5.6      2      24   #客户端等待的时间
Total:          0    5   5.6      3      24
Percentage of the requests served within a certain time (ms)
  50%      3
  66%      6
  75%      8
  80%      9
  90%     14
  95%     19
  98%     22
  99%     24
 100%     24 (longest request)
[root@Linux-node5-master-mysql bin]# /usr/local/httpd-2.4.38/bin/ab -c 2000 -n 10000 http://www.a.org/index.html
This is ApacheBench, Version 2.3 <$Revision: 1843412 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.a.org (be patient)
socket: Too many open files (24) #提示打开的文件太多，因为linux默认设置每个进程最多打开1000个文件，这里打开了2000个文件
[root@Linux-node5-master-mysql bin]# ulimit -n 10000 #修改每个进程最多打开10000个
[root@Linux-node5-master-mysql bin]# netstat -an #可以查看现在有多少套接字文件是打开的
[root@Linux-node5-master-mysql a.org]# /usr/local/httpd-2.4.38/bin/ab -c 2000 -n 10000 http://www.a.org/test.html
Transfer rate:          186.21 [Kbytes/sec] received #这个是每秒传输的流量大小，为186.21KB，186*8=1488Kb约等于1.5Mb带宽
#注意：用请求峰值来衡量网站标准

#用动态网站做测试，phpMyAdmin
参考链接：https://www.phpmyadmin.net/files/
[root@lamp down]# wget https://files.phpmyadmin.net/phpMyAdmin/4.4.12/phpMyAdmin-4.4.12-english.tar.gz
[root@Linux-node5-master-mysql download]# tar -xf phpMyAdmin-3.4.3.2-all-languages.tar.gz -C /www/b.net
[root@Linux-node5-master-mysql b.net]# mv phpMyAdmin-3.4.3.2-all-languages pma
[root@Linux-node5-master-mysql pma]# cp config.sample.inc.php config.inc.php
[root@Linux-node5-master-mysql pma]# whatis rand  #可以查找相关rand的帮助手册
rand (3)             - pseudo-random number generator
sslrand (1ssl)       - generate pseudo-random bytes
sslrand (3ssl)       - pseudo-random number generator
rand (3p)            - pseudo-random number generator
[root@Linux-node5-master-mysql pma]# openssl rand -base64 10  #生成随机数，类型-base64。为10位
LH5GRCI8T12gag==
[root@Linux-node5-master-mysql pma]# vim config.inc.php  #编辑phpMyAdmin配置文件
$cfg['blowfish_secret'] = 'LH5GRCI8T12gag==';  #设置随机数，越随机越好
$cfg['Servers'][$i]['host'] = 'localhost';  #其他几项，由于mysql在本机，所以不用配置
$cfg['Servers'][$i]['connect_type'] = 'tcp';
$cfg['Servers'][$i]['compress'] = false;
$cfg['Servers'][$i]['extension'] = 'mysql';
$cfg['Servers'][$i]['AllowNoPassword'] = false;
[root@Linux-node5-master-mysql pma]# mysqladmin -uroot password 'redhat' #修改mysql数据库密码，因为phpMyAdmin不允许空密码登录
[root@Linux-node5-master-mysql pma]# mysqladmin -uroot -p flush-privileges #刷新内存中mysql的配置
#注意：用ab进行压力测试的时候，用浏览器进行再次打开其他网页，判断其他网页是否正常。
##压力测试工具：ab（httpd自带）,http_load(手动编译安装可使用),siege,webbench
[root@Linux-node5-master-mysql ~]# vmstat 1 #测试系统的上下文速度
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0 198516    176 1765484    0    0     0     0    2    1  0  0 100  0  0 #cs为1
 0  0      0 198516    176 1765484    0    0     0     0  177  144  0  0 100  0  0
31  0      0 185480    176 1768956    0    0     0     0 1439 1040 38  6 57  0  0
30  0      0 234144    176 1722960    0    0     0  7433 2951 2769 75 20  5  0  0
43  0      0 243840    176 1701852    0    0     0   425 2434 1698 81 19  0  0  0
28  0      0 237924    176 1703392    0    0     0   360 2568 1847 84 16  0  0  0 #cs为1847,,磁盘读为360，运行队列长度为28，说明上下文切换快，机器cpu很繁忙
32  0      0 235556    176 1705720    0    0     0   503 2471 1854 84 17  0  0  0
15  0      0 239388    176 1708076    0    0     0   427 2528 1721 84 16  0  0  0
69  0      0 238648    176 1709932    0    0     0   502 2492 1458 83 17  0  0  0
36  0      0 236904    176 1712252    0    0     0  2377 2417 1472 84 16  0  0  0
130  1      0 228800    176 1714664    0    0     0   247 2240 1269 82 18  0  0  0
33  0      0 212148    176 1716636    0    0     0   535 2704 3249 83 17  0  0  0
27  0      0 231648    176 1718824    0    0     0   563 2439 1593 85 15  0  0  0
121  0      0 228000    176 1721528    0    0     0   441 2431 1358 83 17  0  0  0
 0  0      0 251352    176 1722284    0    0     0 13852 2657 2619 57 16 27  0  0
 0  0      0 251544    176 1721996    0    0     0     0  181  155  0  0 100  0  0#cs为155,磁盘读为0，运行队列为0，说明上下文切换回归正常，
 0  0      0 251612    176 1721976    0    0     0     0  166  140  0  0 100  0  0

##如何让httpd启用https加密功能
[root@Linux-node5-master-mysql pma]# vim /etc/httpd/httpd.conf #开启ssl功能
LoadModule ssl_module modules/mod_ssl.so  #装载ssl模块
Include /etc/httpd/extra/httpd-ssl.conf  #加入ssl配置文件
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so  #ssl需要的模块
#httpd-ssl.conf文件配置信息
[root@Linux-node5-master-mysql extra]# grep -Ev '#|^$' /etc/httpd/extra/httpd-ssl.conf
-------------------- 
Listen 443
SSLCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
SSLProxyCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
SSLHonorCipherOrder on 
SSLProtocol all -SSLv3
SSLProxyProtocol all -SSLv3
SSLPassPhraseDialog  builtin
SSLSessionCache        "shmcb:/usr/local/httpd-2.4.38/logs/ssl_scache(512000)"
SSLSessionCacheTimeout  300
<VirtualHost 192.168.1.238:443>
DocumentRoot "/www/a.org"
ServerName www.a.org
ServerAdmin admin@a.org
ErrorLog "/var/log/httpd/ssl-error_log"
TransferLog "/var/log/httpd/ssl-access_log"
SSLEngine on
SSLCertificateFile "/etc/httpd/ssl/httpd.crt"
SSLCertificateKeyFile "/etc/httpd/ssl/httpd.key"
<FilesMatch "\.(cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
</FilesMatch>
<Directory "/usr/local/httpd-2.4.38/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>
BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
CustomLog "/usr/local/httpd-2.4.38/logs/ssl_request_log" \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
<Directory "/www/a.org">
        Options none
        AllowOverride none
        Require all granted
</Directory>
</VirtualHost>                               
--------------------
#httpd-mpm模块文件
[root@Linux-node5-master-mysql pma]# ls /etc/httpd/extra/
httpd-mpm.conf    #这个文件是定义每种不同mpm的工作方式的
[root@Linux-node5-master-mysql pma]# vim /etc/httpd/httpd.conf
Include /etc/httpd/extra/httpd-mpm.conf  #开启mpm多模式配置文件，使用哪种配置时就会加载哪个模式的配置
例如event文件：
<IfModule mpm_event_module>
    StartServers             3  #启动3个进程
    MinSpareThreads         75  #最小空闲线程
    MaxSpareThreads        250  #最大空闲线程
    ThreadsPerChild         25  #每一个进程刚开始生成25个线程
    MaxRequestWorkers      400  #每一个线程最大请求数
    MaxConnectionsPerChild   0  #每一个进程最大请求数，event工作模式是线程，所以这里为0不使用
</IfModule>

---------------------
#http.conf文件配置信息
[root@Linux-node5-master-mysql extra]# grep -Ev '#|^$' /etc/httpd/extra/httpd-ssl.conf 
Listen 443
SSLCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
SSLProxyCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
SSLHonorCipherOrder on 
SSLProtocol all -SSLv3
SSLProxyProtocol all -SSLv3
SSLPassPhraseDialog  builtin
SSLSessionCache        "shmcb:/usr/local/httpd-2.4.38/logs/ssl_scache(512000)"
SSLSessionCacheTimeout  300
<VirtualHost 192.168.1.238:443>
DocumentRoot "/www/a.org"
ServerName www.a.org
ServerAdmin admin@a.org
ErrorLog "/var/log/httpd/ssl-error_log"
TransferLog "/var/log/httpd/ssl-access_log"
SSLEngine on
SSLCertificateFile "/etc/httpd/ssl/httpd.crt"
SSLCertificateKeyFile "/etc/httpd/ssl/httpd.key"
<FilesMatch "\.(cgi|shtml|phtml|php)$">
    SSLOptions +StdEnvVars
</FilesMatch>
<Directory "/usr/local/httpd-2.4.38/cgi-bin">
    SSLOptions +StdEnvVars
</Directory>
BrowserMatch "MSIE [2-5]" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
CustomLog "/usr/local/httpd-2.4.38/logs/ssl_request_log" \
          "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
<Directory "/www/a.org">
        Options none
        AllowOverride none
        Require all granted
</Directory>
</VirtualHost>                                  
[root@Linux-node5-master-mysql extra]# grep -Ev '#|^$' /etc/httpd/httpd.conf
ServerRoot "/usr/local/httpd-2.4.38"
PidFile "/var/run/httpd.pid"
Listen 80
LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule authn_file_module modules/mod_authn_file.so
LoadModule authn_core_module modules/mod_authn_core.so
LoadModule authz_host_module modules/mod_authz_host.so
LoadModule authz_groupfile_module modules/mod_authz_groupfile.so
LoadModule authz_user_module modules/mod_authz_user.so
LoadModule authz_core_module modules/mod_authz_core.so
LoadModule access_compat_module modules/mod_access_compat.so
LoadModule auth_basic_module modules/mod_auth_basic.so
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
LoadModule reqtimeout_module modules/mod_reqtimeout.so
LoadModule filter_module modules/mod_filter.so
LoadModule mime_module modules/mod_mime.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule env_module modules/mod_env.so
LoadModule headers_module modules/mod_headers.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule version_module modules/mod_version.so
LoadModule ssl_module modules/mod_ssl.so
LoadModule unixd_module modules/mod_unixd.so
LoadModule status_module modules/mod_status.so
LoadModule autoindex_module modules/mod_autoindex.so
<IfModule !mpm_prefork_module>
</IfModule>
<IfModule mpm_prefork_module>
</IfModule>
LoadModule dir_module modules/mod_dir.so
LoadModule alias_module modules/mod_alias.so
LoadModule php5_module        modules/libphp5.so
<IfModule unixd_module>
User daemon
Group daemon
</IfModule>
ServerAdmin you@example.com
ServerName www.a.org:80
<Directory />
    AllowOverride none
    Require all denied
</Directory>
<Directory "/usr/local/httpd-2.4.38/htdocs">
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
</Directory>
<IfModule dir_module>
    DirectoryIndex  index.php index.html
</IfModule>
<Files ".ht*">
    Require all denied
</Files>
ErrorLog "logs/error_log"
LogLevel warn
<IfModule log_config_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
    LogFormat "%h %l %u %t \"%r\" %>s %b" common
    <IfModule logio_module>
      LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
    </IfModule>
    CustomLog "logs/access_log" common
</IfModule>
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/usr/local/httpd-2.4.38/cgi-bin/"
</IfModule>
<IfModule cgid_module>
</IfModule>
<Directory "/usr/local/httpd-2.4.38/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
<IfModule headers_module>
    RequestHeader unset Proxy early
</IfModule>
<IfModule mime_module>
    TypesConfig /etc/httpd/mime.types
    AddType application/x-compress .Z
    AddType application/x-gzip .gz .tgz
    AddType application/x-httpd-php .php
    AddType application/x-httpd-php-source .phps
    AddType application/x-x509-ca-cert .crt
    AddType application/x-pkcs7-crl .crl
</IfModule>
Include /etc/httpd/extra/httpd-mpm.conf
Include /etc/httpd/extra/httpd-vhosts.conf
<IfModule proxy_html_module>
Include /etc/httpd/extra/proxy-html.conf
</IfModule>
Include /etc/httpd/extra/httpd-ssl.conf
<IfModule ssl_module>
SSLRandomSeed startup builtin
SSLRandomSeed connect builtin
</IfModule>
---------------------
[root@Linux-node5-master-mysql metadata]# apxs -c -i -a mod_mime_magic.c  #使用apxs来向httpd添加模块，-c为编译，-i为安装，-a为添加到httpd.conf文件中，mod_mime_magic.c这个源模块文件在apache的源码包中：cd modules/metadata/





###httpd以fastCGI方式与php整合
httpd必须提供fastCGI模块，叫做fcgi
--enable--modules=most  #能够实现编译绝大多数的模块
#把mysql和php都卸载了，只保留了apache2.4，重新安装mysql和php

php5.4-xcache3.0
php5.5-xcache3.1


#安装mysql
解压mysql:
[root@lamp download]# tar xf mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz  -C /usr/local/mysql
groupadd -r -g 306 mysql
useradd -r -g 306 -u 306 mysql
chown -R mysql.mysql /usr/local/mysql/*
mkdir /mydata/data && chown -R mysql.mysql /mydata
[root@lamp mysql]# /usr/local/mysql/scripts/mysql_install_db --user=mysql --data-dir=/mydata/data #初始化数据库
[root@lamp mysql]# cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld #复制mysql启动脚本
[root@lamp mysql]# chkconfig --add mysqld 
[root@lamp mysql]# chkconfig --level 2345 on
[root@lamp mysql]# touch /mydata/mysql-error.log #注意，mysql编译的日志及pid等目录权限必须要有可写读写权限，否则不会启动成功
[root@lamp mydata]# chown -R root.mysql var
[root@lamp mydata]# chown -R root.mysql /var
[root@lamp mydata]# chmod 775 -R /var
[root@lamp mydata]# cat /etc/profile.d/mysqld.sh 
export PATH=$PATH:/usr/local/mysql/bin  #加入mysql指令变量
[root@lamp mydata]# . /etc/profile.d/mysqld.sh 


----------------------
[root@lamp mysql]# cat /etc/my.cnf
[mysqld]
datadir=/mydata/data
socket=/mydata/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

[mysqld_safe]
log-error=/mydata/mysql-error.log
pid-file=/mydata/mysqld.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d
---------------------

#安装php的fastCGI
#php下载地址：https://www.php.net/releases/
#安装php-5.4.24版本：
./configure --prefix=/usr/local/php-5.4.24 --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-sockets --enable-fpm --with-mcrypt --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2 #--enable-fpm 这个是开启fastCGI模型，--with-apxs2=/usr/local/apache/bin/apxs必须关掉,只能选其一，--enable-maintainer-zts这项开启线程的也关掉，fastCGI不使用线程，
#checking for BZip2 in default path... not found configure: error: Please reinstall the BZip2 distribution #报这个错
yum -y install bzip2-devel #安装bzip2-devel包解决依赖
#configure: error: mcrypt.h not found. Please reinstall libmcrypt#报错
[root@lamp php-5.4.24]# yum install libmcrypt-devel -y #安装libmcrypt-devel解决依赖
make && make install 
#为php-fpm提供init脚本
cp sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm
chmod +x /etc/rc.d/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
#为php-fpm提供配置文件
[root@lamp php-5.4.24]#cp php.ini-production /etc/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
#编辑php-fpm的配置文件
#php-5.4.13的/usr/local/php/etc/php-fpm.conf配置：
#vim /usr/local/php/etc/php-fpm.conf
pm.max_children = 50 #最多几个子进程
pm.start_servers = 5
pm.min_spare_servers = 2
pm.max_spare_servers = 8
pid = /usr/local/php/var/run/php-fpm.pid
#php-5.4.24的/usr/local/php/etc/php-fpm.conf配置：
#[root@lamp php-fpm.d]# vim /usr/local/php/etc/php-fpm.conf
pid = run/php-fpm.pid  #pid路径开启
[root@lamp php-fpm.d]# vim /usr/local/php/etc/php-fpm.d/www.conf.default  #这个文件被include到php-fpm.conf中
pm.max_children = 5 #最大几个子进程
pm.start_servers = 2 #开始2个进程
pm.min_spare_servers = 1 #最小空闲进程
pm.max_spare_servers = 3 #最大空闲进程
listen = 127.0.0.1:9000   #fastCGI默认监听127.0.0.1:9000端口
[root@lamp php-fpm.d]# mv /usr/local/php/etc/php-fpm.d/www.conf.default www.conf #改名为*.conf
service php-fpm start  #启动php-fpm
[root@lamp php-fpm.d]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name    
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      11269/php-fpm: mast 


#配置httpd
1. 开启mod_proxy_fcgi.so和mod_proxy.so两个模块
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so
2. 配置虚拟主机支持使用fcgi
在相应的虚拟主机中添加类似如下两行： 
 ProxyRequests Off
 ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/PATH/TO/DOCUMENT_ROOT/$1
例如：
ProxyRequests Off  #关闭正向代理功能
ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/www/megedu.com/$1 #只要匹配到以/开头，以.php结尾的文件就转发到fcgi://127.0.0.1:9000/www/megedu.com/$1路径，$1表示的是()里面的文件
#虚拟主机配置：
------------------------
<VirtualHost 192.168.1.239:80>
    DocumentRoot "/www/a.org/"
    ServerName www.a.org
    ErrorLog "/var/log/httpd/a.org-error_log"
    CustomLog "/var/log/httpd/a.org-access_log" common
    ProxyRequests Off
    ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/www/a.org/$1
    <Directory "/www/a.org/">
        Options none
        AllowOverride none
        Require all granted
    </Directory>
</VirtualHost>
------------------------
#添加php类型：
[root@lamp php-fpm.d]# vim /etc/httpd/httpd.conf 
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .phps
#DocumentRoot "/usr/local/httpd-2.4.10/htdocs" #注释取消中心主机
<IfModule dir_module>
    DirectoryIndex index.php index.html  #添加index.php主页
</IfModule>
Include /etc/httpd/extra/httpd-mpm.conf #开启mpm配置文件
Include /etc/httpd/extra/httpd-vhosts.conf  #开启虚拟主机配置文件


#配置xcache见之前的xcache配置
[root@lamp xcache-3.1.2]# pwd
/download/xcache-3.1.2
[root@lamp xcache-3.1.2]# /usr/local/php/bin/phpize
Configuring for:
PHP Api Version:         20160303
Zend Module Api No:      20160303
Zend Extension Api No:   320160303

[root@lamp xcache-3.1.2]# ./configure --enable-xcache --with-php-config=/usr/local/php/bin/php-config
Installing shared extensions:     /usr/local/php-7.1.26/lib/php/extensions/no-debug-non-zts-20160303/ #记住这个xcache路径，xcache配置文件要用，non-zts这个说明不支持zts 
报错：undefined symbol: core_globals_id in Unknown on line 0
#注意：xcache高版本不支持，所以这里配置是用不了，最后是报错的。php7使用了opcache，为php自带





</pre>