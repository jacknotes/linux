#varnish详解并无实操
<pre>
#varnish与memcached区别：
#缓存服务器也可以根据缓存数据内容分类：
1.数据缓存；data cache（memcached）
2.页面缓存；page cache（varnish）
数据存在访问热区，指被经常访问的数据。
#缓存服务器代理方式分类：
memcached是旁挂式缓存服务器
varnish是代理式缓存服务器
#memcached缓存服务器：
属于旁挂式缓存服务器，也属于数据缓存；
memcached存储形式：
1.将所有数据采用键值对儿的形式存储于内存当中；
2.无持久存储功能；
3.通常用于缓存小文件，小数据，单项缓存数据内容上限是1MB；
可以构建分布式缓存系统，各服务器之间互不通信的分布式集群系统
缓存空间耗尽：根据LRU（最近最少使用算法）完成清理过期数据；
缓存项过期：惰性清理机制---用来尽可能减少内存碎片
#VARNISH缓存服务器：
varnish缓存服务器是属于页面缓存服务器的一种，用来为客户端请求提供查询结果，也属于代理式缓存服务器。
varnish缓存服务器可以实现的功能：反向代理 + 缓存服务器
varnish缓存服务器默认在内存中占用128M内存空间去进行缓存服务
缓存服务器的实现：
开源解决方案：
squid：上世纪90年代中期出现；使用率较低
varnish：反向代理式缓存：使用率较高的缓存服务器实现方案；

#缓存类型：
公共缓存:缓存服务器，不能缓存cooking的
私有缓存：客户端缓存
把经常变动的cooking信息都会去掉的，来提高命中率的。
一般只能缓存GET操作，而且不能缓存GET操作中带有帐户和密码的信息。PUT,POST是不能缓存的
#CDN:内容颁发网络，结合智能DNS来判定客户端的来源，从而返回离用户最近的缓存服务器。 当子缓存服务器没有缓存结果则去父缓存服务器查找，无则去找原始服务器
公共智能DNS服务器：dnspod

Expire:绝对时间计时法
max-age:相对时间计时法
Cache-control:用于定义所有的缓存机制都必须遵循的缓存指示，这些指示是一些特定的指令，包括public,private,no-cache(表示可以缓存，每一次去询问服务端缓存是否有效)no-store,max-age,s-maxage,must-revalidate等，[当定义了Expire时，而又定义了Cache-Control：max-age时，则Cache-Control会覆盖Expire]
Etag:验证tag随机数是否发生变化的，有变化跟本地tag对比不一样则说明更新过，一样则说明未更新过，可以避免时间上的粗糙。
###著名的缓存服务器varnish
Squid:varnish好比httpd:nginx，前者宝刀未老，后者新贵，但受人追捧
一般使用Nginx+varnish 或者 Nginx+Squid
配置文件是编译后（通过VCL[varnish control language]）的二进制文件，被各子进程读取的
</pre>

#Tomcat
<pre>
servlet:类似php的cgi协议，这个是java使用的servlet框架，可以使得java开发web项目了
JSP：Jave Server Page,可以使得java像php一样在html中嵌入java语言。
SSH框架：Structs,Spring,Hebernate.java著名的开发框架
JSP脚本---通过Jasper---转换成Servlet，然后Servlet通过java编译器编译成类
#JSP性能比PHP好得多，而且java比php流行。大型站点都使用JSP。facebook网站是php写的，但是它把所有php程序转换面C++代码，最后才运行。
applet,servlet：都是特殊的类，applet运行在客户端的，servlet运行在服务端的。

JSP：
	.jsp（通过jasper转换成.java）-->.java（通过servlet转换为.class[有javac编译器]）-->.class(JVM运行)
Servlet Container:Servlet容器（包括了jdk和其他的程序），用来编译.java文件成.class文件并运行
Web Container:Web容器=jasper+Servlet容器
#hadoop和tomcat一样是java写的
线程私有内存区：
	1. 程序计数器
	2. java虚拟机栈：存放本地变量的
线程共享内存区：	
	1. 方法区
	2. 堆：存储对象的，jvm启动时就启动
#JAVA可以自动完成内存的回收，GC（Garbage collector）来完成垃圾批量回收的
垃圾回收算法：
	1. 标记-清除
	2. 复制
		1. 只有二分之一可用，避免内存碎片，但浪费空间
		2. 划分比例来复制清除
	3. 标记-整理：也可避免内存碎片
垃圾回收器：
	1. Serial
	2. ParNew
	3. Parallel Scavenge
	4. Serial Old
	5. Parallel Old
	6. CMS:并行标记清除器，由Parallel Scavenge和arallel Old整合而来
			CMS优点：并发收集、低停顿
			CMS缺点：无法浮动垃圾、由于基于标记-清除算法可能会产生内存碎片
	7. G1

SUN:
	JRE,JDK
Open:
	OpenJDK
#安装JDK方法：
	1. rpm
	2. 通用二进制格式，.bin格式
	3. 源码安装（通过OpenJDK编译）
#rpm包安装javaJDK:
[root@mysql-slave bin]# wget http://download.oracle.com/otn/java/jdk/6u45-b06/jdk-6u45-linux-x64-rpm.bin 
配置java环境变量:
vim /etc/profile.d/java.sh
export JAVA_HOME=/usr/local/jdk1.6.0_21
export PATH=$PATH:$JAVA_HOME/bin
$java -version  #有信息说明java环境配好了
source /etc/profile.d/java.sh

#JAVA配置参数：
	-XX:+<PTION>:开启此参数指定的功能
	-XX:-<option>:关闭功能
	-XX:<option>=<value>:给option指定的选项赋值

java -XX:+PrintFlagsFinal #查看最终参数的配置
-D<name>=<value>: set a system property

Sun JDK监控和故障处理工具：
	jps: JVM Process status Tool:显示指定系统内所有的HotSpot虚拟机进程
	jstat: JVM Statistics Monitoring Tool:收集并显示HotSpot虚拟机各大方面的运行数据 
	jinfo: 显示正在运行的某HotSpot虚拟机配置信息
	jmap: 生成某HotSpot虚拟机的内存转储快照
可视化工具：
	jconsole:java的监控与管理控制平台
	jvisualvm:
###Tomcat的实例
#tomcat的访问由外到里：
Server(每一个实例)，顶级组件
	service（将一个或多个连接器关联到一个引擎去的，一个service只有一个引擎）
		Engine(Serverlet Container)[一个引擎有多个虚拟主机，还有多个context，context类似httpd的别名URI路径，主机和context都可以运行一个实例的]
			JVM
server-->service-->Connector-->engine|Servlet Container-->Host,context--JVM

容器组件：Engine,host,context
顶级组件：server,service
Realm（领域）:用户帐号数据库，对用户进行认证的
Valve（阀门）:基于ip认证，过滤访问日志类型，需要logger进行记录日志
logger: 日志记录器，定义日志位置
#如果想让整个引擎上定义Realm，则在引擎上定义即可，如果想定义在host或context，则在相应位置定义即可。

###tomcat的配置文件
server.xml：tomcat的核心配置文件
<Server>
	<Service>
		<Connector />
		<Engine>
			<Host>
				<Context>  </Context>
			</Host>
		</Engine>
	</Service>
</Server>
#注：tomcat依赖的是jdk而不是jre，因为需要的不光是jvm，而且需要库编译

#安装tomcat方式：
	1. rpm包
	2. 通用二进制包
	3. 源码包

##通用二进制安装：
1. 先安装jdk:
#bin包安装javaJDK:
[root@mysql-slave download]# ./jdk-6u45-linux-x64.bin 
[root@mysql-slave download]# mv jdk1.6.0_45/ /usr/local/
[root@mysql-slave download]# ln -sv /usr/local/jdk1.6.0_45/ /usr/local/jdk
‘/usr/local/jdk’ -> ‘/usr/local/jdk1.6.0_45
配置java环境变量:
[root@mysql-slave download]# vim /etc/profile.d/java.sh
export JAVA_HOME=/usr/local/jdk
export PATH=$PATH:$JAVA_HOME/bin
[root@mysql-slave download]# . /etc/profile.d/java.sh 
[root@mysql-slave download]# java -version
java version "1.6.0_45"  #说明已经安装好
Java(TM) SE Runtime Environment (build 1.6.0_45-b06)
Java HotSpot(TM) 64-Bit Server VM (build 20.45-b01, mixed mode)
#安装tomcat:
[root@mysql-slave download]# wget http://mirrors.tuna.tsinghua.edu.cn/apache/tomcat/tomcat-7/v7.0.94/bin/apache-tomcat-7.0.94.tar.gz
[root@mysql-slave download]# tar xf apache-tomcat-7.0.94.tar.gz -C /usr/local/
[root@mysql-slave local]# ln -sv /usr/local/apache-tomcat-7.0.94/ /usr/local/tomcat
‘/usr/local/tomcat’ -> ‘/usr/local/apache-tomcat-7.0.9
[root@mysql-slave tomcat]# ll
total 132
drwxr-xr-x 2 root root  4096 Jul 10 21:21 bin
-rw-r--r-- 1 root root 18099 Apr 11 00:57 BUILDING.txt
drwxr-xr-x 2 root root   158 Apr 11 00:57 conf
-rw-r--r-- 1 root root  6090 Apr 11 00:57 CONTRIBUTING.md
drwxr-xr-x 2 root root  4096 Jul 10 21:21 lib
-rw-r--r-- 1 root root 56846 Apr 11 00:57 LICENSE
drwxr-xr-x 2 root root     6 Apr 11 00:56 logs
-rw-r--r-- 1 root root  1241 Apr 11 00:57 NOTICE
-rw-r--r-- 1 root root  3255 Apr 11 00:57 README.md
-rw-r--r-- 1 root root  9365 Apr 11 00:57 RELEASE-NOTES
-rw-r--r-- 1 root root 16978 Apr 11 00:57 RUNNING.txt
drwxr-xr-x 2 root root    30 Jul 10 21:21 temp
drwxr-xr-x 7 root root    81 Apr 11 00:57 webapps
drwxr-xr-x 2 root root     6 Apr 11 00:56 work
[root@mysql-slave tomcat]# ls bin/  #catalina.sh是核心脚本，其他.sh脚本可以当做参数传给catalina.sh调用的
bootstrap.jar                 daemon.sh         startup.sh
catalina.bat                  digest.bat        tomcat-juli.jar
catalina.sh                   digest.sh         tomcat-native.tar.gz
catalina-tasks.xml            setclasspath.bat  tool-wrapper.bat
commons-daemon.jar            setclasspath.sh   tool-wrapper.sh
commons-daemon-native.tar.gz  shutdown.bat      version.bat
configtest.bat                shutdown.sh       version.sh
configtest.sh                 startup.bat
[root@mysql-slave tomcat]# ll conf/
total 212
-rw------- 1 root root  13342 Apr 11 00:57 catalina.policy #定义tomcat的安全策略
-rw------- 1 root root   6776 Apr 11 00:57 catalina.properties #应用程序属性的
-rw------- 1 root root   1394 Apr 11 00:57 context.xml #上下文文件
-rw------- 1 root root   3562 Apr 11 00:57 logging.properties  #日志属性的
-rw------- 1 root root   6613 Apr 11 00:57 server.xml #核心配置文件
-rw------- 1 root root   1950 Apr 11 00:57 tomcat-users.xml #用户帐户认证文件
-rw------- 1 root root 170604 Apr 11 00:57 web.xml #默认的部署描述符
部署描述符：将一个web应用程序所依赖到的类装载进JVM
#运行tomcat
export CATALINA_HOME=/usr/local/tomcat #定义变量CATALINA_HOME或者CATALINA_BASE来定义tomcat的目录的，一个物理机上可以运行多个tomcat,但端口不能冲突
[root@mysql-slave tomcat]# vim /etc/profile.d/tomcat.sh #为永久有效写入文件
export CATALINA_HOME=/usr/local/tomcat
export PATH=$PATH:$CATALINA_HOME/bin
[root@mysql-slave tomcat]# . /etc/profile.d/tomcat.sh 
[root@mysql-slave tomcat]# catalina.sh version #其实是version.sh脚本，但是建议这样用
Using CATALINA_BASE:   /usr/local/tomcat
Using CATALINA_HOME:   /usr/local/tomcat
Using CATALINA_TMPDIR: /usr/local/tomcat/temp
Using JRE_HOME:        /usr/local/jdk
Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
Server version: Apache Tomcat/7.0.94
Server built:   Apr 10 2019 16:56:40 UTC
Server number:  7.0.94.0
OS Name:        Linux
OS Version:     3.10.0-957.el7.x86_64
Architecture:   amd64
JVM Version:    1.6.0_45-b06
JVM Vendor:     Sun Microsystems Inc
[root@mysql-slave tomcat]# catalina.sh start #启动tomcat
Using CATALINA_BASE:   /usr/local/tomcat
Using CATALINA_HOME:   /usr/local/tomcat
Using CATALINA_TMPDIR: /usr/local/tomcat/temp
Using JRE_HOME:        /usr/local/jdk
Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
Tomcat started.
[root@mysql-slave tomcat]# netstat -tunlp | grep 80 #验证已经启动成功
tcp6       0      0 :::8009                 :::*                    LISTEN      27199/java          
tcp6       0      0 :::8080                 :::*                    LISTEN      27199/java          
tcp6       0      0 127.0.0.1:8005          :::*                    LISTEN      27199/java          
[root@mysql-slave logs]# ll /usr/local/tomcat/logs/
total 20
-rw-r--r-- 1 root root 6237 Jul 10 21:43 catalina.2019-07-10.log #tomcat启动时记录的日志
-rw-r--r-- 1 root root 6237 Jul 10 21:43 catalina.out #当前正在使用的文件
-rw-r--r-- 1 root root    0 Jul 10 21:43 host-manager.2019-07-10.log #host-manager的日志文件
-rw-r--r-- 1 root root  601 Jul 10 21:43 localhost.2019-07-10.log #定义的主机日志文件，包括错误日志文件等信息
-rw-r--r-- 1 root root    0 Jul 10 21:43 localhost_access_log.2019-07-10.txt #定义的主机访问日志文件
-rw-r--r-- 1 root root    0 Jul 10 21:43 manager.2019-07-10.log #manager的日志文件
#日志对应的URI，从catalina.2019-07-10.log可以看出
/usr/local/apache-tomcat-7.0.94/webapps/host-manager #host-manager日志记录的对应位置
 /usr/local/apache-tomcat-7.0.94/webapps/manager #manager日志记录的对应位置
[root@mysql-slave tomcat]# ls webapps/ROOT/ #每一个webapps目录下的WEB-INF、META-INF表示私有信息，绝不允许用户URI访问，也访问不到的。
asf-logo-wide.svg  bg-middle.png    bg-nav.png    favicon.ico  RELEASE-NOTES.txt  tomcat.gif  tomcat-power.gif  WEB-INF
bg-button.png      bg-nav-item.png  bg-upper.png  index.jsp    tomcat.css         tomcat.png  tomcat.svg
[root@mysql-slave tomcat]# ls work/  #tomcat的工作目录
Catalina
[root@mysql-slave tomcat]# ls work/Catalina/ #表示Catalina这个引擎
localhost
[root@mysql-slave tomcat]# ls work/Catalina/localhost/ #表示引擎下的主机localhost
_  docs  examples  host-manager  manager  #这些都是主机下的实例，context
[root@mysql-slave tomcat]# ls work/Catalina/localhost/_/ #下面无任何信息，需要访问才可编译生成
注：访问http://192.168.1.37:8080/
[root@mysql-slave tomcat]# ls work/Catalina/localhost/_/
org  #现在生成了编译的文件
[root@mysql-slave tomcat]# tree  work/Catalina/localhost/_/
work/Catalina/localhost/_/
└── org
    └── apache
        └── jsp
            ├── index_jsp.class  #这个就是编译的文件
            └── index_jsp.java
[root@mysql-slave tomcat]# jps
27369 Jps
27199 Bootstrap  #已经运行了
###tomcat脚本
[root@mysql-slave tomcat]# vim /etc/init.d/tomcatd
[root@mysql-slave ~]# cat /etc/init.d/tomcatd 
#!/bin/sh
# Tomcat init script for Linux.
# chkconfig: 2345 96 04
# description: The Apache Tomcat servlet/JSP container.
export JAVA_HOME=/usr/local/jdk
export CATALINA_HOME=/usr/local/tomcat
#export CATALINA_OPTS="-Xms128m -Xmx256m"
case $1 in
        restart)
                $CATALINA_HOME/bin/catalina.sh stop
                sleep 2
                $CATALINA_HOME/bin/catalina.sh start
                ;;
        *)
                $CATALINA_HOME/bin/catalina.sh $*
                ;;
esac
[root@mysql-slave tomcat]# chmod +x /etc/init.d/tomcatd
[root@mysql-slave tomcat]# chkconfig --add tomcatd
[root@mysql-slave tomcat]# chkconfig --list tomcatd
tomcatd         0:off   1:off   2:on    3:on    4:on    5:on    6:off
[root@mysql-slave tomcat]# service tomcatd stop
[root@mysql-slave tomcat]# service tomcatd start

#tomcat配置文件解析：
1. <Server port=”8005” shutdown=”SHUTDOWN”>
#tomcat启动一个server实例（即一个JVM），它监听在8005端口以接收shutdown命令。各Server的定义不能使用同一个端口，这意味着如果在同一个物理机上启动了多个Server实例，必须配置它们使用不同的端口。
部分参数意义：
className: 用于实现此Server容器的完全限定类的名称，默认为org.apache.catalina.core.StandardServer；
port: 接收shutdown指令的端口，默认仅允许通过本机访问，默认为8005；
shutdown：发往此Server用于实现关闭tomcat实例的命令字符串，默认为SHUTDOWN；
2. <Service name=”Catalina”>
#这定义了一个名为Catalina的Service，此名字也会在产生相关的日志信息时记录在日志文件当中。
部分参数意义：
className：用于实现service的类名，一般都是org.apache.catalina.core.StandardService
name：此服务的名称，默认为Catalina；
3. <Connector port="8080" protocol="HTTP/1.1"
maxThreads="150" connectionTimeout="20000"
redirectPort="8443"/>和<Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
#进入Tomcat的请求可以根据Tomcat的工作模式分为如下两类：
	1. Tomcat作为应用程序服务器：请求来自于前端的web服务器，这可能是Apache, IIS, Nginx等
	2. Tomcat作为独立服务器：请求来自于web浏览器；
#Tomcat应该考虑工作情形并为相应情形下的请求分别定义好需要的连接器才能正确接收来自于客户端的请求。一个引擎可以有一个或多个连接器，以适应多种请求方式。
#定义连接器可以使用多种属性，有些属性也只适用于某特定的连接器类型。一般说来，常见于server.xml中的连接器类型通常有4种：
	1. HTTP连接器
	2. SSL连接器
	3. AJP 1.3连接器
	4. proxy连接器
#定义连接器时可以配置的属性非常多，但通常定义HTTP连接器时必须定义的属性只有“port”，定义AJP连接器时必须定义的属性只有"protocol"，因为默认的协议为HTTP。以下为常用属性的说明：
address：指定连接器监听的地址，默认为所有地址，即0.0.0.0；
maxThreads：支持的最大并发连接数，默认为200；
port：监听的端口，默认为0；
protocol：连接器使用的协议，默认为HTTP/1.1，定义AJP协议时通常为AJP/1.3；
redirectPort：如果某连接器支持的协议是HTTP，当接收客户端发来的HTTPS请求时，则转发至此属性定义的端口；
connectionTimeout：等待客户端发送请求的超时时间，单位为毫秒，默认为60000，即1分钟；
enableLookups：是否通过request.getRemoteHost()进行DNS查询以获取客户端的主机名；默认为true；
acceptCount：设置等待队列的最大长度；通常在tomcat所有处理线程均处于繁忙状态时，新发来的请求将被放置于等待队列中；
4. <Engine name="Catalina" defaultHost="localhost">
#Engine是Servlet处理器的一个实例，即servlet引擎，默认为定义在server.xml中的Catalina。Engine需要defaultHost属性来为其定义一个接收所有发往非明确定义虚拟主机的请求的host组件。
部分参数意义：
defaultHost：Tomcat支持基于FQDN的虚拟主机，这些虚拟主机可以通过在Engine容器中定义多个不同的Host组件来实现；但如果此引擎的连接器收到一个发往非明确定义虚拟主机的请求时则需要将此请求发往一个默认的虚拟主机进行处理，因此，在Engine中定义的多个虚拟主机的主机名称中至少要有一个跟defaultHost定义的主机名称同名；
name：Engine组件的名称，用于日志和错误信息记录时区别不同的引擎；
5. <Host name="localhost" appBase="webapps"
unpackWARs="true" autoDeploy="true"
xmlValidation="false" xmlNamespaceAware="false">
</Host>
#位于Engine容器中用于接收请求并进行相应处理的主机或虚拟主机
常用属性说明：
appBase：此Host的webapps目录，即存放非归档的web应用程序的目录或归档后的WAR文件的目录路径；可以使用基于$CATALINA_HOME的相对路径；
autoDeploy：在Tomcat处于运行状态时放置于appBase目录中的应用程序文件是否自动进行deploy；默认为true；
unpackWars：在启用此webapps时是否对WAR格式的归档文件先进行展开；默认为true；
###虚拟主机示例：
<Engine name="Catalina" defaultHost="localhost">
<Host name="localhost" appBase="webapps">
<Context path="" docBase="ROOT"/>
<Context path="/bbs" docBase="/web/bss"
reloadable="true" crossContext="true"/>
</Host>

<Host name="mail.tiantian.com" appBase="/web/mail">
<Context path="" docBase="ROOT"/>
</Host>
</Engine>
6. <Host name="www.tiantian.com" appBase="webapps" unpackWARs="true">
<Alias>tiantian.com</Alias>
</Host>
#主机别名定义
7. <Context path="" docBase="/web/webapps"/>
<Context path="/bbs" docBase="/web/threads/bbs" reloadable="true">
<Context path="/chat" docBase="/web/chat"/>
<Context path="/darian" docBase="darian"/>
#一个Context定义用于标识tomcat实例中的一个Web应用程序
#每一个context定义也可以使用一个单独的XML文件进行，其文件的目录为$CATALINA_HOME/conf/<engine name>/<host name>
部分参数解释：
	1. docBase：相应的Web应用程序的存放位置；也可以使用相对路径，起始路径为此Context所属Host中appBase定义的路径；切记，docBase的路径名不能与相应的Host中appBase中定义的路径名有包含关系，比如，如果appBase为deploy，而docBase绝不能为deploy-bbs类的名字；
	2. path：相对于Web服务器根路径而言的URI；如果为空“”，则表示为此webapp的根路径；如果context定义在一个单独的xml文件中，此属性不需要定义；
	3. reloadable：是否允许重新加载此context相关的Web应用程序的类；默认为false；
8. 一个Realm表示一个安全上下文，它是一个授权访问某个给定Context的用户列表和某用户所允许切换的角色相关定义的列表。因此，Realm就像是一个用户和组相关的数据库。定义Realm时惟一必须要提供的属性是classname，它是Realm的多个不同实现，用于表示此Realm认证的用户及角色等认证信息的存放位置。
JAASRealm：基于Java Authintication and Authorization Service实现用户认证；
JDBCRealm：通过JDBC访问某关系型数据库表实现用户认证；
JNDIRealm：基于JNDI使用目录服务实现认证信息的获取；
MemoryRealm：查找tomcat-user.xml文件实现用户信息的获取；
UserDatabaseRealm：基于UserDatabase文件(通常是tomcat-user.xml)实现用户认证，它实现是一个完全可更新和持久有效的MemoryRealm，因此能够跟标准的MemoryRealm兼容；它通过JNDI实现；
#下面是一个常见的使用UserDatabase的配置：
<Realm className=”org.apache.catalina.realm.UserDatabaseRealm”
resourceName=”UserDatabase”/>
#下面是一个使用JDBC方式获取用户认证信息的配置：
<Realm className="org.apache.catalina.realm.JDBCRealm" debug="99"
driverName="org.gjt.mm.mysql.Driver"
connectionURL="jdbc:mysql://localhost/authority"
connectionName="test" connectionPassword="test"
userTable="users" userNameCol="user_name"
userCredCol="user_pass"
userRoleTable="user_roles" roleNameCol="role_name" /></pre>
9. Valve类似于过滤器，它可以工作于Engine和Host/Context之间、Host和Context之间以及Context和Web应用程序的某资源之间。一个容器内可以建立多个Valve，而且Valve定义的次序也决定了它们生效的次序。
#下面介绍常见的两种Valve。一个是RemoteHostValve，一个是RemoteAddrValve:
RemoteHostValve:基于主机名称的访问控制,,控制本身可以通过allow或deny来进行定义
RemoteAddrValve:基于IP地址的访问控,,控制本身可以通过allow或deny来进行定义
 <Context path="/probe" docBase="probe">
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
allow="127.0.0.1"/>
</Context>
#相关参数解释：
className：相关的java实现的类名，相应于分别应该为org.apache.catalina.valves.RemoteHostValve或org.apache.catalina.valves.RemoteAddrValve；
allow：以逗号分开的允许访问的IP地址列表，支持正则表达式，因此，点号“.”用于IP地址时需要转义；仅定义allow项时，非明确allow的地址均被deny；
deny: 以逗号分开的禁止访问的IP地址列表，支持正则表达式；使用方式同allow

-------------------tomcat配置文件示例--------------------
规划： 
网站网页目录：/web/www      域名：www.test1.com 
论坛网页目录：/web/bbs     URL：bbs.test1.com/bbs 
网站管理程序：$CATALINA_HOME/wabapps   URL：manager.test.com    允许访问地址：172.23.136.* 
 
conf/server.xml 
<Server port="8005" shutdown="SHUTDOWN"> 
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" /> 
  <Listener className="org.apache.catalina.core.JasperListener" /> 
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" /> 
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" /> 
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" /> 
  <GlobalNamingResources> 
  <!-- 全局命名资源，来定义一些外部访问资源，其作用是为所有引擎应用程序所引用的外部资源的定义 --!> 
    <Resource name="UserDatabase" auth="Container" 
              type="org.apache.catalina.UserDatabase" 
              description="User database that can be updated and saved" 
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory" 
              pathname="conf/tomcat-users.xml" /> 
  </GlobalNamingResources> 
  <!-- 定义的一个名叫“UserDatabase”的认证资源，将conf/tomcat-users.xml加载至内存中，在需要认证的时候到内存中进行认证 --> 
  <Service name="Catalina"> 
  <!-- # 定义Service组件，同来关联Connector和Engine，一个Engine可以对应多个Connector，每个Service中只能一个Engine --!> 
    <Connector port="80" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" /> 
    <!-- 修改HTTP/1.1的Connector监听端口为80.客户端通过浏览器访问的请求，只能通过HTTP传递给tomcat。  --> 
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" /> 
    <Engine name="Catalina" defaultHost="test.com"> 
    <!-- 修改当前Engine，默认主机是，www.test.com  --> 
    <Realm className="org.apache.catalina.realm.LockOutRealm"> 
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm" 
               resourceName="UserDatabase"/> 
    </Realm> 
    # Realm组件，定义对当前容器内的应用程序访问的认证，通过外部资源UserDatabase进行认证 
      <Host name="test.com"  appBase="/web" unpackWARs="true" autoDeploy="true"> 
      <!--  定义一个主机，域名为：test.com，应用程序的目录是/web，设置自动部署，自动解压    --> 
        <Alias>www.test.com</Alias> 
        <!--    定义一个别名www.test.com，类似apache的ServerAlias --> 
        <Context path="" docBase="www/" reloadable="true" /> 
        <!--    定义该应用程序，访问路径""，即访问www.test.com即可访问，网页目录为：相对于appBase下的www/，即/web/www，并且当该应用程序下web.xml或者类等有相关变化时，自动重载当前配置，即不用重启tomcat使部署的新应用程序生效  --> 
        <Context path="/bbs" docBase="/web/bbs" reloadable="true" /> 
        <!--  定义另外一个独立的应用程序，访问路径为：www.test.com/bbs，该应用程序网页目录为/web/bbs   --> 
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="/web/www/logs" 
               prefix="www_access." suffix=".log" 
               pattern="%h %l %u %t &quot;%r&quot; %s %b" /> 
        <!--   定义一个Valve组件，用来记录tomcat的访问日志，日志存放目录为：/web/www/logs如果定义为相对路径则是相当于$CATALINA_HOME，并非相对于appBase，这个要注意。定义日志文件前缀为www_access.并以.log结尾，pattern定义日志内容格式，具体字段表示可以查看tomcat官方文档   --> 
      </Host> 
      <Host name="manager.test.com" appBase="webapps" unpackWARs="true" autoDeploy="true"> 
      <!--   定义一个主机名为man.test.com，应用程序目录是$CATALINA_HOME/webapps,自动解压，自动部署   --> 
        <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="172.23.136.*" /> 
        <!--   定义远程地址访问策略，仅允许172.23.136.*网段访问该主机，其他的将被拒绝访问  --> 
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="/web/bbs/logs" 
               prefix="bbs_access." suffix=".log" 
               pattern="%h %l %u %t &quot;%r&quot; %s %b" /> 
        <!--   定义该主机的访问日志      --> 
      </Host> 
    </Engine> 
  </Service> 
</Server> 
 
conf/tomcat-users.xml 
<?xml version='1.0' encoding='utf-8'?> 
<tomcat-users> 
  <role rolename="manager-gui" /> 
  <!--  定义一种角色名为：manager-gui    --> 
  <user username="cz" password="manager$!!110" roles="manager-gui" /> 
  <!--  定义一个用户的用户名以及密码，并赋予manager-gui的角色    --> 
</tomcat-users>
-------------------


#会话保持的几种方式：
             1、session sticky      注： 会话粘性
                      source ip     注:  基于ip地址的会话保持
                      cookie        注: 基于cookie绑定
             2、session cluster     注：session集群，不同节点之间可以通过session复制的方式来同步session，tomcat的集群Delta管理器实现    
             3、session server      注:  session服务器，专门建立一个服务器来保存session，session server上装一个memcache或者redis，它们是用key-value技术实现的

########tomcat的负载均衡实现方式，
  1、 nginx做反向代理   nginx+tomcat
  2、 apache做方向代理  apache+tomcat
#apache实现反向代3种方式需要的模块
    1、apache: 
                mod_proxy
                mod_proxy_http
                mod_proxy_balancer
              tomcat:
                http connector

    2 、apache: 
                 mod_proxy
                 mod_proxy_ajp
                 mod_proxy_balancer                
            tomcat:
                ajp connector

    3、 apache:
                mod_jk
             tomcat:
                ajp connector

#tomcat的index.jsp测试页面源码：
[root@lamp-zabbix ROOT]# cat index.jsp
----------
 <%@ page language="java" %>
 <html>
   <head><title>TomcatB</title></head>
   <body>
     <h1><font color="blue">TomcatB.magedu.com</font></h1>
     <table align="centre" border="1">
       <tr>
         <td>Session ID</td>
     <% session.setAttribute("magedu.com","magedu.com"); %>
         <td><%= session.getId() %></td>
       </tr>
       <tr>
         <td>Created on</td>
         <td><%= session.getCreationTime() %></td>
      </tr>
     </table>
   </body>
 </html>
----------
[root@lnmp ROOT]# mkdir -pv ./{classes,lib,WEB-INF,META-INF}  #创建所需目录
mkdir: created directory ‘./classes’
mkdir: created directory ‘./lib’
mkdir: created directory ‘./WEB-INF’
mkdir: created directory ‘./META-INF

#nginx+tomcat部署：
实验部署：
1、三个节点，第一个几点的ip地址为172.16.0.131，后两个几点分别为172.16.0.134和172.16.0.135
2、后两个节点分别准备jdk和tomcat的安装包
3、第一个节点安装nginx
#tomcat-node1:
<Host name="localhost"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log." suffix=".txt"
               pattern="%{X-Real-IP}i %l %u %t &quot;%r&quot; %s %b" />
      </Host>
#tomcat-node2:
<Host name="tomcat.jack.com"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
<Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log." suffix=".txt"
               pattern="%{X-Real-IP}i %l %u %t &quot;%r&quot; %s %b" />
      </Host>
#nginx配置：[root@lnmp nginx]# cat /etc/nginx/nginx.conf 
worker_processes  1;
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    gzip  on;
    upstream tomcatserver {
        server 192.168.1.233:8080 weight=2;
        server 192.168.1.239:8080 weight=2;
    }
    server {
        listen       80;
        server_name  lnmp.jack.com;
        location / {
                index index.jsp;
                root html;
        }

        location /nginx_status {
             stub_status on;
             access_log off;
        }
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
        location ~* \.(jsp|do)$ {
                proxy_redirect  off;
                proxy_set_header        Host    $host;
                proxy_set_header        X-Real-IP       $remote_addr;
                proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header        X-Forwarded-Proto       $scheme;
                proxy_pass      http://tomcatserver;

#       location ~ \.php$ {
#            root           html;
#            fastcgi_pass   127.0.0.1:9000;
#            fastcgi_index  index.php;
#            fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
#            include        fastcgi_params;
        }
    }
}

##apache+tomcat
apache使用ajp协议（比http协议快）代理到后端的tomcat上
apache代理模块：
	1. mod_proxy(用得比mod_jk多，下级模块：mod_proxy_http,mod_proxy_ajp,mod_proxy_balancer)
	2. mod_jk
连接器：
	1. AJP
	2. HTTP
	3. https
	4. proxy
	注：需要java类来实现

###基于apache反向代理到tomcat,(使用ajp协议)
#配置tomcat：
#node1
[root@lnmp conf]# vim server.xml 
 <Engine name="Catalina" defaultHost="tomcat.jack.com" jvmRoute=tomcatA> #设置默认虚拟主机，并且设置jvmRouteID
<Host name="tomcat.jack.com"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
    <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="localhost_access_log." suffix=".txt"
               pattern="%{X-Real-IP}i %l %u %t &quot;%r&quot; %s %b" />
      </Host>
service tomcat start #启动服务 
#node2
<Engine name="Catalina" defaultHost="my.jack.com" jvmRoute="tomcatB">
<Host name="my.jack.com"  appBase="webapps"
            unpackWARs="true" autoDeploy="true">
 <Valve className="org.apache.catalina.valves.AccessLogValve" directory=
"logs"
               prefix="localhost_access_log." suffix=".txt"
               pattern="%{X-Real-IP}i %l %u %t &quot;%r&quot; %s %b" />
      </Host>

#前端apache配置：
./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-ssl --enable-cgi --enable-rewrite --with-zlib --with-pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-mpms-shared=all --with-mpm=event --enable-proxy --enable-proxy-http --enable-proxy-ajp --enable-proxy-balancer --enable-lbmethod-heartbeat --enable-heartbeat --enable-slotmem-shm --enable-slotmem-plain --enable-watchdog  #后面是开启proxy反向代理和hearbeat健康检查的。 
#配置apache通过mod_proxy模块与tomcat连接
需要apache已经装载mod_proxy,mod_proy_http，mod_proxy_ajp和proxy_balancer_module(实现tomcat集群时用到)，slotmem_shm_module，lbmethod_byrequests_module等模块
[root@saltsrv httpd-2.4.38]# httpd -D DUMP_MODULES | grep proxy #来查找proxy模块装载了哪些
 proxy_module (shared)
 proxy_http_module (shared)
 proxy_ajp_module (shared)
 proxy_balancer_module (shared)
#在httpd.conf的全局配置段或虚拟主机段加入如下内容(全局配置段是可以生效的，虚拟主机未试)：
##此段是基于ajp协议反向代理到tomcat的
ProxyVia Off #用于控制在httpd首部是否使用Via,主要用于在多级代理中控制代理请求的流向
ProxyRequests Off  #关闭正向代理功能
ProxyPreserveHost Off #如果启用此功能，代理会将用户请求报文中的Host:行发送给后端的服务器，而不再使用ProxyPass指定的服务器地址，如果想在反向代理中支持虚拟主机，则需要开启此项，否则就无需打开此功能。
<Proxy *>
	Require all granted
</Proxy>
	ProxyPass / ajp://172.16.100.1:8009/
	ProxyPassReverse / ajp://172.16.100.1:8009/ #用于让apache调整HTTP重写向响应报文中的Location,Content-Location及URI标签所对应的URL,在反向代理环境中必须使用此指令避免重写向报文绕过proxy服务器。
<Location />
	Require all granted
</Location>
------------------
ProxyVia Off
ProxyRequests Off
ProxyPreserveHost Off
<Proxy *>
        Require all granted
</Proxy>
        ProxyPass / ajp://192.168.1.233:8009/
        ProxyPassReverse / ajp://192.168.1.233:8009/
<Location />
        Require all granted
</Location>
------------------
##此段是基于http反向代理是tomcat的
------------------
ProxyVia Off
ProxyRequests Off
ProxyPreserveHost Off
<Proxy *>
        Require all granted
</Proxy>
        ProxyPass / http://172.16.100.1:8080/  #代理的URI必须和后端的URI保持一致
        ProxyPassReverse / http://172.16.100.1:8080/
<Location />
        Require all granted
</Location>
------------------
#使用基于mod_proxy，mod_balancer的ajp协议来反向代理负载均衡tomcat
[root@saltsrv extra]# httpd -D DUMP_MODULES | egrep 'proxy|shm|lbmethod' #首先要装载如下些模块
 proxy_module (shared)
 proxy_http_module (shared)
 proxy_ajp_module (shared)
 proxy_balancer_module (shared)
 slotmem_shm_module (shared)
#注：由于balancer需要slotmem_shm_module模块，所以需要开启来才可运行
[root@saltsrv extra]# vim /etc/httpd/httpd.conf #如下配置是基于ajp协议的
--------------
<IfModule proxy_balancer_module>
    <IfModule proxy_ajp_module>
        <Proxy balancer://mybalancer>
            BalancerMember ajp://192.168.1.233:8009/ loadfactor=80 route=tomcatA
            BalancerMember ajp://192.168.1.239:8009/ loadfactor=20 route=tomcatB
			ProxySet lbmethod=byrequests
        </Proxy>

        ProxyRequests off
        ProxyPass / balancer://mybalancer/ stickySession=JSESSIONID nofailover=Off
        ProxyPassReverse / balancer://mybalancer/
    </IfModule>
</IfModule>
-------------
<IfModule proxy_balancer_module>  #以下配置是基于http的，跟ajp写在一起或分开只写一个都可以
    <IfModule proxy_http_module>
        <Proxy balancer://mybalancer>
            BalancerMember http://192.168.1.233:8080/ loadfactor=80 route=tomcatA
            BalancerMember http://192.168.1.239:8080/ loadfactor=20 route=tomcatB
			ProxySet lbmethod=byrequests
        </Proxy>

        ProxyRequests off
        ProxyPass / balancer://mybalancer/   stickySession=JSESSIONID nofailover=Off
        ProxyPassReverse / balancer://mybalancer/
    </IfModule>
</IfModule>
--------------
#注：如果proxy指定是以banlancer://开头，即用于负载均衡集群时，其还可以接受一些特殊的参数,用ProxySet进行配置，如下所示：
1. stickySession：调度器的名称，跟所web程序语言不同其值也不同，一般为JSESSIONID或PHPSESSIONID，用于绑定用户session的。
2. Nofailover：为On时表示配置故障时用户的session将损坏，Off为不损坏，因为后端不支持session复制时应配置为On。
3. loadfactor=20表示权重值，
4. lbmethod：是实现负载均衡的调度方法，默认是byrequests,即基于权重将统计请求个数进行调度，bytraffic则执行基于权重的流量计数调度，bybusyness通过考量每个后端服务器的当前负载进行调度。
5. maxattempts:放弃请求之前，实现故障转移的次数，默认为1，其最大值不应该大于总的节点数。
6. ProxyPassReverse：用于让apache调整http重定向响应报文中的Location、Content-Location及URI标签所对应的URL，在反向代理环境中必须使用此指令避免重定向报文绕过proxy服务器。
7. route=tomcatB指定tomcat的routeID
8. min：连接池的最小容量，此值与实际连接个数无头，仅表示连接池最小要初始化的空间大小
9. max：连接的最大容量
10. retry:当apache将请求发送到后端服务器得到错误响应时等待多长时间以后再重试，单位是秒钟。
------------------
在httpd.conf的全局配置中配置banlancer:
ProxyRequests Off
<Proxy balancer://mybalancer>
      BalancerMember http://192.168.1.233:8080/ loadfactor=1 route=tomcatA
      BalancerMember http://192.168.1.239:8080/ loadfactor=1 route=tomcatB
	  ProxySet lbmethod=byrequests   #定义负载均衡方法
</Proxy>
在虚拟主机中配置proxyPass:(或在中心主机中配置proxyPass)
<VirtualHost *:80>
	ServerAdmin admin@magedu.com
	ServerName www.magedu.com
	ProxyPass / balancer://mybalancer/   stickySession=JSESSIONID nofailover=Off
	ProxyPassReverse / balancer://mybalancer/
<Location /balancer-manager>
	SetHandler balancer-manager
	ProxyPass !  #表示这个路径不向后代理，可在状态URI上查看节点住处
	Require all granted
</Location>
------------------
http://www.magedu.com/balancer-manager访问状态信息
#注：tomcat的session可以保存在文件或者jdbc连接的数据库当中

###配置tomcatl连接器mod_jk，需要单独下载tomcat-connector
wget http://mirror.bit.edu.cn/apache/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.46-src.tar.gz
tar xf tomcat-connectors-1.2.46-src.tar.gz
cd tomcat-connectors-1.2.46-src/nativel
./configure --with-apxs=/usr/local/apache/bin/apxs #把tomcat-connector连接器编译成模块，php_mod也是这样编译成模块的，只要可以编译成为apache的模块就是用这种方式编译的
make && make install #安装后模块就在apache的模块目录下
#vim /etc/httpd/extra/httpd-jk.conf #编辑jk配置文件
LoadModule jk_module modules/mod_jk.so #装载模块
JKWorkersFile /etc/httpd/extra/workers.properties #指定jk工作文件
JKLogFile logs/mod_jd.log
JKLogLevel debug  #为了测试才打开debug
JKMount /* TomcatA  #把哪下个URI路径送到后端的哪一个tomcat的routeID中
JKMount /status/ stat1  #stat1这个实例是在/etc/httpd/extra/workers.properties文件当中，文件中定义了什么实例，这里就使用什么名称
-------------
[root@saltsrv extra]# cat httpd-jk.conf 
LoadModule jk_module modules/mod_jk.so
JKWorkersFile /etc/httpd/extra/workers.properties 
JKLogFile logs/mod_jd.log
JKLogLevel debug 
JKMount /* tomcatA
JKMount /status/ stat1
-------------
#vim /etc/httpd/extra/workers.properties
worker.list=TomcatA,stat1 #stat是jk模块自带内嵌的实例，我们取了个名是stat1
worker.TomcatA.port=8009
worker.TomcatA.host=192.168.10.8 #TomcatA的ip和端口
worker.TomcatA.type=ajp13  #使用ajp的协议版本为1.3
worker.TomcatA.lbfactor=1  #负载均衡权重
worker.stat1.type=status  #指定stat1输出状态信息的
-----------
[root@saltsrv extra]# cat workers.properties 
worker.list=tomcatA,stat1 
worker.tomcatA.port=8009
worker.tomcatA.host=192.168.1.233
worker.tomcatA.type=ajp13
worker.tomcatA.lbfactor=1
worker.stat1.type=status 
-----------
#[root@saltsrv httpd]# echo 'Include /etc/httpd/extra/httpd-jk.conf' >> /etc/httpd/httpd.conf      
#重启httpd服务即可访问后端的tomcat，使用的是ajp协议的mod_jk模块

##基于httpd的ajp协议反向代理负载均衡实现配置：
[root@saltsrv ~]# cat /etc/httpd/extra/httpd-jk.conf 
LoadModule jk_module modules/mod_jk.so
JKWorkersFile /etc/httpd/extra/workers.properties 
JKLogFile logs/mod_jd.log
JKLogLevel debug 
JKMount /* tomcatGroup  #反向代理至tomcat组
JKMount /status/ statA   #可使用/status/URI进行访问状态信息
[root@saltsrv ~]# cat /etc/httpd/extra/workers.properties    
worker.list=tomcatGroup,statA  #设定tomcatGroup集群组，statA为这个集群组的状态名
worker.tomcatA.port=8009
worker.tomcatA.host=192.168.1.233
worker.tomcatA.type=ajp13
worker.tomcatA.lbfactor=1
worker.tomcatB.port=8009
worker.tomcatB.host=192.168.1.239
worker.tomcatB.type=ajp13
worker.tomcatB.lbfactor=1
worker.statA.type=status  #定义statA为状态
worker.tomcatGroup.type=lb  #设定这个集群组的类型为lb
worker.tomcatGroup.balance_workers=tomcatA,tomcatB  #定义负载均衡工作的主机为tomcatA,tomcatB
worker.tomcatGroup.sticky_session=0 #这是为不启用会话保持功能sticky_session
#在负载均衡模式中，专用的属性还有：
◇balance_workers：用于负载均衡模式中的各worker的名称列表，需要注意的是，出现在此处的worker名称一定不能在任何worker.list属性列表中定义过，并且worker.list属性中定义的worker名字必须包含负载均衡worker。具体示例请参见后文中的定义。
◇ method：可以设定为R、T或B；默认为R，即根据请求的个数进行调度；T表示根据已经发送给worker的实际流量大小进行调度；B表示根据实际负载情况进行调度。
◇sticky_session：在将某请求调度至某worker后，源于此址的所有后续请求都将直接调度至此worker，实现将用户session与某worker绑定。默认为值为1，即启用此功能。如果后端的各worker之间支持session复制，则可以将此属性值设为0。

#基于tomcat自带的会话共享（实操不生效）
#一定要在web站点目录上的WEB-INF/web.xml中添加<distributable/>才可以实现session共享的

<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                   channelSendOptions="8">
     <Manager className="org.apache.catalina.ha.session.DeltaManager"
                    expireSessionsOnShutdown="false"
                    notifyListenersOnReplication="true"/>
       <Channel className="org.apache.catalina.tribes.group.GroupChannel">
          <Membership className="org.apache.catalina.tribes.membership.McastService"
                   address="228.50.10.1"   bind="172.16.100.1"   port="45564"
                   frequency="500"  dropTime="3000"/>
             <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                                address="172.16.100.1"   port="4000"  autoBind="100"
                                selectorTimeout="5000"   maxThreads="6"/>
             <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
                <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
             </Sender>
       <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
       <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
     </Channel>
     <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                        filter=".*\.gif;.*\.js;.*\.jpg;.*\.htm;.*\.html;.*\.txt;"/>
     <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>
     <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                     tempDir="/tmp/war-temp/" deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"  watchEnabled="false"/>
      <ClusterListener className="org.apache.catalina.ha.session.JvmRouteSessionIDBinderListener"/>
      <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
</Cluster>
#注：以上内容定义在Engine容器中，则表示对所有主机均启动用集群功能。如果定义在某Host中，则表示仅对此主机启用集群功能。

[root@lamp-zabbix WEB-INF]# vim /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml 
<distributable/> #在<web-app>标签中添加这行
[root@lnmp WEB-INF]#  vim /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml 
<distributable/> #在<web-app>标签中添加这行
注：所有启用集群功能的web应用程序，其web.xml中都须添加<distributable/>才能实现集群功能。如果某web应用程序没有自己的web.xml，也可以通过复制默认的web.xml至其WEB-INF目录中实现。
#对tomcat NODE1进行集群配置，设定组播地址，绑定的本地节点地址，和接收组播信息的本地信息地址
#224.0.2.0～238.255.255.255为用户可用的组播地址（临时组地址），全网范围内有效；
[root@lnmp tomcat]# vim /usr/local/tomcat/conf/server.xml 
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="6">

          <Manager className="org.apache.catalina.ha.session.BackupManager"
                   expireSessionsOnShutdown="false"
                   notifyListenersOnReplication="true"
                   mapSendOptions="6"/>


          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="228.0.0.4"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="192.168.1.233"
                      port="5000"
                      selectorTimeout="100"
                      maxThreads="6"/>

            <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
              <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
            </Sender>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.ThroughputInterceptor"/>
          </Channel>

          <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                 filter=".*\.gif;.*\.js;.*\.jpg;.*\.png;.*\.htm;.*\.html;.*\.css;.*\.txt;"/>

          <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                    tempDir="/tmp/war-temp/"
                    deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"
                    watchEnabled="false"/>

          <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
        </Cluster>
-------------------
[root@lamp-zabbix conf]# vim /usr/local/tomcat/conf/server.xml
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="6">

          <Manager className="org.apache.catalina.ha.session.BackupManager"
                   expireSessionsOnShutdown="false"
                   notifyListenersOnReplication="true"
                   mapSendOptions="6"/>


          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="228.0.0.4"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="192.168.1.239"
                      port="5000"
                      selectorTimeout="100"
                      maxThreads="6"/>

            <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
              <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
            </Sender>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatch15Interceptor"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.ThroughputInterceptor"/>
          </Channel>

          <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                 filter=".*\.gif;.*\.js;.*\.jpg;.*\.png;.*\.htm;.*\.html;.*\.css;.*\.txt;"/>

          <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                    tempDir="/tmp/war-temp/"
                    deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"
                    watchEnabled="false"/>

          <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
        </Cluster>

###注：当部署某些网站时可能启动服务报异常，试用参数JAVA_OPTS='-Xms512m -Xmx1024m -XX:MaxPermSize=512m'在catalina.sh中定义变量，应该会好点。




</pre>




