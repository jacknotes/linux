#salt simple
###第一部分：salt的简单使用
<pre>
#安装master和minion
master启动服务
minion在配置文件中设定master地址，并启动服务 
master同意minion连接，用命令salt-key
master随后即可执行salt命令了
#master配置文件/etc/salt/master
#定义grains文件根配置：   在File Server settings 
file_roots:
  base:
    - /srv/salt
[root@saltsrv salt]# mkdir /srv/salt/web -pv
mkdir: created directory ‘/srv/salt’  #这个就是我们设置的base环境的根
mkdir: created directory ‘/srv/salt/web’
[root@saltsrv salt]# cat /srv/salt/web/apache.sls  #编辑salt配置文件执行配置安装
apache-install:
  pkg.installed:
    - names:   #如果执行不成功认证检查下配置文件
      - httpd
      - httpd-devel
apache-service:
  service.running:
    - name: httpd
    - enable: True
[root@saltsrv salt]# salt mysql-slave.jack.com cmd.run 'yum install -y epel-release' #针对特定主机先安装epel源
[root@saltsrv salt]# salt mysql-slave.jack.com state.sls web.apache #针对特定主机执行文件根下的web.apache的sls配置文件
[root@mysql-slave ~]# cat /var/cache/salt/minion/files/base/web/apache.sls  #运行成功后在minion端这个路径可查看到跟master端一样的sls文件
top.file文件：默认是在file_roots的base环境下的
[root@saltsrv salt]# cat /srv/salt/top.sls  #top.sls位置在base环境下
base:  #指定环境
  'mysql-slave.jack.com':
    - web.apache
  'srvsalt.jack.com':
    - web.apache
[root@saltsrv salt]# salt '*' state.highstate test=True #测试高级状态是否成功

#####salt-ssh
[root@saltsrv salt]# yum install salt-ssh -y  #安装salt-ssh工具
[root@saltsrv salt]# egrep -v '#|^$' /etc/salt/roster  #编辑salt-ssh文件配置主机
lnmp.jack.com:
  host: 192.168.1.233
  port: 22
  user: root
[root@saltsrv salt]# salt-ssh '*' test.ping -i  #连接远程主机使用交互模式,当你输入密码时，salt-ssh会把自己的公钥拷贝到目标机器的~/.ssh/authorized_keys文件中，当下次salt-ssh链接目标机器时，就会用自己的私钥去解密目标主机自己存放的公钥，就不会再要输入密码了
注：salt-ssh的公私钥路径：/etc/salt/pki/master/ssh/目录下
salt-ssh '*' -r 'ifconfig'  #远程执行命令
[root@saltsrv salt]# salt-ssh '*' -r 'yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest-2.el7.noarch.rpm' #salt-ssh安装salt源
注：如果是centos6则安装：yum install https://repo.saltstack.com/yum/redhat/salt-repo-latest.el6.noarch.rpm
[root@saltsrv salt]# salt-ssh '*' -r 'yum install -y salt-minion' #远程安装minion,
[root@saltsrv salt]# salt-ssh '*' -r "echo 'master: 192.168.1.235' >> /etc/salt/minion"
[root@saltsrv salt]# salt-ssh '*' -r 'echo "cobbler.jack.com" > /etc/salt/minion_id'
[root@saltsrv salt]# salt-ssh '*' -r "systemctl start salt-minion"  #salt-ssh的任务也已经完成
[root@saltsrv salt]# salt '*' grains.ls  #列出grains的所有key
[root@saltsrv salt]# salt '*' grains.items #列出grains的所有key和值
[root@saltsrv salt]# salt '*' grains.item os #只列出grains的某个item
[root@saltsrv salt]# salt -G 'ipv4:192.168.1.233' test.ping  #用于目标选择，选择grains的ipv4:192.168.1.233的目标进行ping测试，看是否有
##自定义item值：
方式一：
[root@saltsrv salt]# vim /etc/salt/minion
grains:
  roles: apache	
[root@saltsrv salt]# systemctl restart salt-minion #也可用salt '*' saltutil.sync_grains命令同步
[root@saltsrv salt]#  salt '*' grains.item roles
srvsalt.jack.com:
    ----------
    roles:
        apache
方式二：
[root@saltsrv salt]#vim /etc/salt/grains  #新增这个文件进行增加roles
cloud: openstack
[root@saltsrv salt]# systemctl restart salt-minion #也可用salt '*' saltutil.sync_grains命令同步
[root@saltsrv salt]#  salt '*' grains.item cloud
srvsalt.jack.com:
    ----------
    cloud:
        openstack	

#####在配置文件中使用grains:
[root@saltsrv salt]# cat /srv/salt/top.sls 
base:
  'mysql-slave.jack.com':
    - web.apache
  'roles:apache':     #匹配的角色名
    - match: grain   #先用于指定是grain
    - web.apache
[root@saltsrv salt]# salt '*' state.highstate test=true

###自定义grains:
[root@saltsrv salt]# mkdir -pv /srv/salt/_grains #在files_root下新建下划线grains文件夹
mkdir: created directory ‘/srv/salt/_grains
[root@saltsrv _grains]# vim /srv/salt/_grains/my_grains.py 
#!/usr/bin/env python
#-*- coding: utf-8 -*-
def my_grains():
        grains = {}
        grains['iaass'] = 'openstack'
        grains['edu'] = 'oldboyedu'
        return grains
[root@saltsrv _grains]# salt '*' saltutil.sync_grains #同步grains参数
[root@saltsrv minion]# tree /var/cache/salt/minion/
├── files
│?? └── base
│??     ├── _grains
│??     │?? └── my_grains.py
##自定义grains同步到minion的路径：/var/cache/salt/minion/extmods/grains/my_grains.py
[root@saltsrv minion]# salt '*' grains.item iaass #用这个为自己定义的grains
#注：自定义item是对某台主机进行定义，可在/etc/salt/minion或/etc/salt/grains下定义。自定义grains是在/srv/salt/_grains下定义的，是对所有主机生效的。

###grains优先级：
	1. 系统自带
	2. grains文件写的  /etc/salt/grains
	3. minion配置文件写的  /etc/salt/minion
	4. 自己写的   /srv/salt/_grains/

######pillar
开启pillar的item键值：vim /etc/salt/master
pillar_opts True   #开启salt的pillar键值参数
##编写pillar sls描述文件
vim /etc/salt/master
pillar_roots:  #设置pillar的根路径
  base:
    - /srv/pillar
[root@saltsrv ~]# mkdir -pv /srv/pillar/web  #注：pillar里面可以嵌套grains
[root@saltsrv web]# cat apache.sls  #注：pillar不写top file文件是不能执行的，而grains不写top file也可以执行
{% if grains['os'] == 'CentOS' %}
apache: httpd
{% elif grains['os'] == 'Debian' %}
apache: apache2
{% endif %}
[root@saltsrv pillar]# cat /srv/pillar/top.sls  #这个是pillar根路径下的top file文件
base:
  'mysql-slave.jack.com': 
    - web.apache
[root@saltsrv pillar]# salt '*' saltutil.refresh_pillar  #刷新pillar
[root@saltsrv pillar]#  salt '*' pillar.items apache #可以查看对应主机的pillar值
mysql-slave.jack.com:
    ----------
    apache:
        httpd
####pillar使用场景，主要用于目标选择上，使用参数-I来选择，grains用-G来选择
[root@saltsrv web]# salt -I "apache:httpd" test.ping
mysql-slave.jack.com:
    True

######Grains和Pillar对比：
Grains:
类型：静态（需要重启minion服务或在master端使用saltutil.snyc_grains同步grains）
数据采集方式：minion启动时采集或master自定义
应用场景：数据查询，目标选择，配置管理
定义位置：minion端和master端
Pillar:
类型：动态（不需要重启,需要使用saltutil.refresh_pillar同步pillar）
数据采集方式：master自定义
应用场景：目标选择，配置管理，机密数据
定义位置：master端
假如有100台机器：如果定义grains，那么需要在每台minion去设置或在master上的/srv/salt/_grains目录下设置即可，如果定义pillar,只需要在master一台机器上设置就可以了
##使用通配符进行目标选择：?,*,[12]
[root@saltsrv web]# salt -L 'lnmp.jack.com,srvsalt.jack.com' test.ping #-L进行列表选择
[root@saltsrv web]# salt -E 'mysql-[slave|master]*' test.ping #进行正则表达式匹配
[root@saltsrv salt]# salt -S 192.168.0.0/16 test.ping #用子网来匹配ip地址
#编写状态模块
[root@saltsrv salt]# mkdir /srv/salt/_modules #建议模块位置
[root@saltsrv _modules]# vim my_disk.py #文件名就是模块名
def list():
  cmd = 'df -h'
  ret = __salt__['cmd.run'](cmd)
  return ret
[root@saltsrv _modules]# salt '*' saltutil.sync_modules #同步模块到所有minion
[root@saltsrv _modules]# salt '*' my_disk.list #/srv/salt/_modules这个目录是默认自定义模块目录，执行自定义模块时是文件名加函数名
#注：/srv/salt/_grains，/srv/salt/_modules，这些路径为自定义的路径

#slat常用命令：
test.ping
cmd.run
state.sls  #状态文件
state.highstate  #高级状态文件
grains.ls
grains.items #列出grains所有的键值
grains.item os  #进行指定item列出
-G 'ipv4:192.168.1.233'  #进行grains目标选择
-I 'apache:httpd'  #进行pillar目标选择
-L 'lnmp.jack.com,srvsalt.jack.com' #进行列表选择
-E 'mysql-[slave|master]*' #进行正则匹配选择
-S 192.168.0.0/16  #进行ip子网选择
-b 10  #用百分比来执行
pillar.items  #列出pillar所有的键值
saltutil.sync_grains   #同步master端的grains到minion端
saltutil.refresh_pillar  #刷新master端的pillar到minion端 
saltutil.sync_modules  #同步模块到minion
#salt常用模块
salt '*' network.arp  #查看minion的arp信息
salt '*' service.status salt-minion #查看服务状态
salt-cp '*' /etc/hosts /tmp #从master复制东西到minion
salt '*' state.show_top #查看目标minion在topfile文件中需要做什么事情
salt lnmp.jack.com state.single pkg.installed name=tree #执行单状态包安装动作，包名叫tree,实际是通过yum或者apt进行安装

#小结：
1.minion启动时收集本地信息成为grains的键值对
2.使用grains可用于目标选择，配置管理，信息查询。
3.grains不用top文件亦可执行，例：( salt -G 'os:Centos' state.sls web.apache ),但pillar却不行，pillar只有top文件才能执行
4.grains目标选择也可以写入/srv/salt/top.sls文件中使用。
5.grains自定义优先组：1.系统自带，2.minion端/etc/salt/grains自定义，需要重启minion服务，3.minion端/etc/salt/minion自定义，需要重启minion服务，4.master端/srv/salt/_grains/*.py自定义,需要使用（salt '*' saltutil.sync_grains）命令来同步。
6.pillar常用于机密信息处理，grains常用于普通信息处理。
7.pillar的描述文件在/srv/pillar/*.sls，pillor的top文件在/srv/pillar/top.sls，pillar的描述文件编写完成后必需刷新才能生效，命令：(salt '*' saltutil.refresh_pillar)
8.自定义模块可满足自己的需要，在/srv/salt/_modules/目录下编写*.py文件
9.Pillar是动态的。给特定的Minion指定特定的数据（top file也是这样的）。只有指定的minion自己能看到自己的数据，比较安全。而grains却是所有的minion都能看到，不安全。所以在普通的信息时使用grains,而在涉及帐号密码时使用pillar。
</pre>

###第二部分：salt的高级使用
<pre>
####YAML语法：
简介：YAML语法写成sls描述文件，sls全称：Salt State
例子：
apache-install:
  pkg.installed:
    - names:
      - httpd
      - httpd-devel
apache-service:
  service.running:
    - name: httpd
    - enable: True
1. apache-service为名称(ID)声明,不写names,则默认name就是名称声明的名称。ID声明在高级状态下必须唯一
2. service.running为状态声明，模块声明
3. - name: httpd为名称选项声明

#实际应用例子：LAMP架构
1. 安装软件包		pkg
2. 修改配置文件	file
3. 启动服务 		service
pkg.installed	安装
pkg.latest	确保最新版本软件
pkg.remove	卸载
pkg.purge	卸载并删除配置文件
1.同时安装多个包：
common_packages:
  pkg.installed:
    - pkgs:
      - httpd
      - php
      - mysql
      - mariadb-server
      - php-mysql
      - php-cli
      - php-mbstring
2.配置管理
apache-config:
  file.managed:#一个ID声明中只能是不同的状态模块，因为会冲突
    - name: /etc/httpd/conf/httpd.conf #要被配置的目标文件
    - source: salt://files/httpd.conf #源文件在哪位置，根是file_roots路径
    - user: root  #文件所有者用户
    - group: root  #文件所有者组
    - mode: 644  #文件权限
3.服务管理
apache-service:
  service.running:  #在salt.states.service模块下
    - name: httpd
    - enable: True
    - reload: True #httpd已经运行时是否重载配置配置文件
#生产配置：
#vim /srv/salt/lamp/lamp.sls
lamp-pkg:
  pkg.installed:
    - pkgs:
      - httpd
      - php
      - mariadb
      - mariadb-server
      - php-mysql
      - php-cli
      - php-mbstring

apache-config:
  file.managed:
    - name: /etc/httpd/conf/httpd.conf
    - source: salt://lamp/files/httpd.conf
    - user: root
    - group: root
    - mode: 644

php-config:
  file.managed:
    - name: /etc/php.ini
    - source: salt://lamp/files/php.ini
    - user: root
    - group: root
    - mode: 644

mysql-config:
   file.managed:
    - name: /etc/my.cnf
    - source: salt://lamp/files/my.cnf
    - user: root
    - group: root
    - mode: 644

apache-service:
  service.running:
    - name: httpd
    - enable: True
    - reload: True

mysql-service:
  service.running:
    - name: mariadb
    - enable: True
    - reload: True
salt 'linux*' state.sls lamp.lamp
注：配置和服务可以写在一个声明id上

#状态间关系：
1. 我依赖谁    require: 
	require: #我依赖下面两个模块的id，为True我才能成功执行
      - pkg: lamp-pkg  #pkg是模块名，后面是相关的ID
      - file: apache-config
2. 我被谁依赖   require_in
    require_in: mysql-service #我被其他模块依赖，我必须先成功执行，其他依赖我的模块才能成功执行，mysql-service为声明id
3. 我监控谁  watch，监控salt://lamp/files/httpd.conf配置文件是否被更改，如果被更改，则在执行top file时重载配置文件到各个minion
  - reload: True#写了就是重载配置文件，不写这个就是重启服务 
  - watch:
      - file: apache-config #watch包括require,也就是apache-config首先存在，然后apache-config被更改了才用reload进行重载
4. 我被谁监控 watch_in
5. 我引用谁  include
include: 
  - lamp.mysql
  - lamp.apache
6. 我扩展谁
#编写SLS技巧：
1. 按状态分类，如果单独使用，很清晰
2. 按服务分类，可以被其他的SLS include。例如LNMP的sls include mysql的sls
例：
lamp-pkg:
  pkg.installed:
    - pkgs:
      - httpd
      - php
      - mariadb
      - mariadb-server
      - php-mysql
      - php-cli
      - php-mbstring
apache-config:
  file.managed:
    - name: /etc/httpd/conf/httpd.conf
    - source: salt://lamp/files/httpd.conf
    - user: root
    - group: root
    - mode: 644 
apache-service:
  service.running:
    - name: httpd
    - enable: True
    - reload: True
    - require:   #依赖关系 
      - pkg: lamp-pkg  
    - watch:
      - file: apache-config
mysql-config:
   file.managed:
    - name: /etc/my.cnf
    - source: salt://lamp/files/my.cnf
    - user: root
    - group: root
    - mode: 644
    - require_in: mysql-service
mysql-service:
  service.running:
    - name: mariadb
    - enable: True
    - reload: True

###Jinja模板(python的模板语言)
两种分隔符:
1. {%……%}条件语句
2. {{……}}变量
使用一个模板需要3步走：
1. 告诉File模块，使用Jinja模板，这样jinja格式就可以生效了
- template: jinja
2. 你要列出参数列表
- defaults:
  PORT: 88  #指定PORT变量值为88
3. 模板引用
{{ PORT }} #在source文件中添加jinja格式的变量
例:
apache-config:
  file.managed:
    - name: /etc/httpd/conf/httpd.conf
    - source: salt://lamp/files/httpd.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - defaults:
      PORT: 99
注：jinja模板可以使用：salt grains pillar 赋值
注：grains目标选择fqdn_ip4这个item是跟minion的主机名绑定的，是唯一的，vim /etc/hosts 后，使用 `salt '*' saltutil.sync_grains` 直接同步即可

一、写在模板文件中
编辑源文件，使用grains进行赋值：
Listen {{grains['fqdn_ip4'][0]}}:{{ PORT }}
二、写在SLS文件里面的Defaults变量列表中
- defaults:
    IPADDR: {{ grains['fqdn_ip4'][0] }}
    PORT: 88

####salt实战
#规划：
1. 系统初始化
2. 功能模板：设置单独的目录,nginx,php,mysql,memcached,尽可能的全、独立
3. 业务模块：根据业务类型划分，例如web服务。论坛bbs，然后用include包括进来
4. base基础环境
环境初始化（在salt基础上）：1.dns配置，2.history记录时间3.记录命令操作4.内核参数优化5.安装yum仓库6.安装zabbix-agent
注：salt环境配置：开发、测试（功能测试、性能测试）、预生产、生产
#步骤：
1. vim /etc/salt/master
file_roots:
  base:
    - /srv/salt/base
  prod:
    - /srv/salt/prod
pillar_roots:
  base:
    - /srv/pillar/base
  prod:
    - /srv/pillar/prod
[root@SaltstackServer /srv/salt]# mkdir base 
[root@SaltstackServer /srv/salt]# mkdir prod
[root@SaltstackServer /srv/pillar]# mkdir base
[root@SaltstackServer /srv/pillar]# mkdir prod
[root@SaltstackServer /srv/pillar]# systemctl restart salt-master.service 
#dns.sls----dns配置
[root@SaltstackServer /srv/salt/base/init]# cat dns.sls
/etc/resolve.conf:  #由于未写明name参数，所以声明id为目标路径
  file.managed:
    - source: salt://init/files/resolv.conf
    - user: root
    - group: root
    - mode: 644
#history.sls----history记录时间
[root@SaltstackServer /srv/salt/base/init]# cat history.sls 
/etc/profile:
  file.append:
    - text:
      - export HISTTIMEFORMAT="%F %T `whoami`"
#audit.sls----记录命令到日志操作
[root@SaltstackServer /srv/salt/base/init]# cat audit.sls 
/etc/bashrc:
  file.append:
    - text:
      - export PROMPT_COMMAND='{ msg=$(history 1 | { read x y; echo $y; });logger "[euid=$(whoami)]":$(who am i):[`pwd`]"$msg"; }'
#sysctl.sls----内核参数优化
[root@SaltstackServer /srv/salt/base/init]# cat sysctl.sls 
net.ipv4.ip_local_port_range:    #客户端打口随机端口范围
  sysctl.present:
    - value: 10000 65000
fs.file-max:
  sysctl.present:
    - value: 2000000
net.ipv4.ip_forward:     #打开ipv4转发
  sysctl.present:
    - value: 1
vm.swappiness:   #swap为0,尽量不要使用swap内存
  sysctl.present:
    - value: 0
#epel.sls----安装yum仓库
[root@SaltstackServer /srv/salt/base/init]# cat repo.sls 
yum_repo_release:
  pkg.installed:
    - sources:  #这里是指定包位置，从这个位置安装
      - zabbix: https://mirrors.aliyun.com/zabbix/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
      - epel-release: https://mirrors.aliyun.com/epel/epel-release-latest-7.noarch.rpm
#zabbix-agent.sls----安装zabbix-agent
[root@SaltstackServer /srv/salt/base/init]# cat zabbix-agent.sls 
zabbix-agent:
  pkg.installed:
    - name: zabbix-agent
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://init/files/zabbix_agentd.conf
    - template: jinja
    - defaults:
        Zabbix_Server: {{ pillar['Zabbix_Server'] }}
    - require:
      - pkg: zabbix-agent
  service.running:
    - enable: True
    - watch:
      - pkg: zabbix-agent
      - file: zabbix-agent
zabbix_agentd.conf.d:
  file.directory:
    - name: /etc/zabbix/zabbix_agentd.d
    - watch_in: 
      - service: zabbix-agent
    - require:
      - pkg: zabbix-agent
#[root@SaltstackServer /srv/pillar/base]# vim /srv/salt/base/init/files/zabbix_agentd.conf
Server={{ Zabbix_Server }}
[root@saltsrv init]# vim /srv/pillar/zabbix/zabbixserver.sls
Zabbix_Server: 192.168.1.239
[root@saltsrv init]# salt '*' saltutil.refresh_pillar #同步生效pillar到所有minion，会去找pillar的top file文件执行
[root@saltsrv init]# salt '*' pillar.item Zabbix_Server #检验pillar的设置是否正确
#创建init.sls描述文件
[root@SaltstackServer /srv/salt/base/init]# cat init.sls 
include:
  - init.dns
  - init.history
  - init.audit
  - init.sysctl
  - init.epel
  - init.zabbix-agent
#top.sls #编写topfile，把初始化的设置运行
[root@SaltstackServer /srv/salt/base]# cat top.sls 
base:
  '*':
    - init.init
[root@saltsrv init]# salt '*' state.show_top
[root@saltsrv init]# salt tomcat.jack.com state.highstate test=true #先测试一下
[root@saltsrv init]# salt tomcat.jack.com state.highstate #执行安装
[root@saltsrv salt]# tree
.
├── _grains
│?? └── my_grains.py
├── init
│?? ├── audit.sls
│?? ├── dns.sls
│?? ├── files
│?? │?? ├── resolv.conf
│?? │?? └── zabbix_agentd.conf
│?? ├── history.sls
│?? ├── init.sls
│?? ├── repo.sls
│?? ├── sysctl.sls
│?? └── zabbix-agent.sls
├── _modules
│?? └── my_disk.py
├── prod
└── top.sls

#注：unless解释：
 cmd.run:
    - name: chkconfig --add haproxy
    - unless: chkconfig --list | grep haproxy #unless表示命令执行完后不成功则执行name后面的命令，否则不会执行name命令
#salt-run命令：
salt '*' saltutil.runnig  #查看正在运行的job_id
salt '*' saltutil.kill_job job_id  #结束job_id的工作
注：当你ctrl+c时，salt还在运行，所以你要用salt '*' saltutil.kill_job job_id来结束不需要的salt工作，用sal-run jobs.lookup_id 2016...  查看详细的job_id工作

####使master端用job_cache写入到mysql
[root@saltsrv init]# yum install -y MySQL-python mariadb-server
-------------
CREATE DATABASE  `salt`
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;
USE `salt`;

DROP TABLE IF EXISTS `jids`;
CREATE TABLE `jids` (
  `jid` varchar(255) NOT NULL,
  `load` mediumtext NOT NULL,
  UNIQUE KEY `jid` (`jid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE INDEX jid_id ON jids(jid) USING BTREE;

DROP TABLE IF EXISTS `salt_returns`;
CREATE TABLE `salt_returns` (
  `fun` varchar(50) NOT NULL,
  `jid` varchar(255) NOT NULL,
  `return` mediumtext NOT NULL,
  `id` varchar(255) NOT NULL,
  `success` varchar(10) NOT NULL,
  `full_ret` mediumtext NOT NULL,
  `alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY `id` (`id`),
  KEY `jid` (`jid`),
  KEY `fun` (`fun`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `salt_events`;
CREATE TABLE `salt_events` (
`id` BIGINT NOT NULL AUTO_INCREMENT,
`tag` varchar(255) NOT NULL,
`data` mediumtext NOT NULL,
`alter_time` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
`master_id` varchar(255) NOT NULL,
PRIMARY KEY (`id`),
KEY `tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-------------
master端的job_cache路径：/var/cache/salt/master/jobs/下
minion端正在运行的salt程序id路径：/var/cache/salt/minion/proc下
第一步：修改master的配置文件/etc/salt/master
添加：
master_job_cache: mysql
mysql.user: salt
mysql.pass: salt
mysql.host: localhost 
mysql.port: 3306
mysql.db: salt
第二步：重启master
[root@salt-server ~]# systemctl restart salt-master.service 
结果：以后每次执行的结果就都会从master的job_cache写入到mysql上了，从job_cache写入到mysql上的这种方法都用在生产环境中。

###salt-run
salt-run这个命令是在master上执行的，并非在minion上执行的，而salt这个命令是master分发工作给minion执行的
列出正在运行的jid：salt-run jobs.list_jobs
显示指定的jid执行情况：salt-run jobs.lookup_jid jid
在master端执行看minion的状态：
- salt-run manage.status
- salt-run manage.up
- salt-run manage.down
在master端执行看minion的版本：salt-run manage.versions

###salt-call
就是只一台机器minion，它想运行salt，就可以使用salt-call命令。
第零步：关闭master-minion进程，因为本地运行，不用跟master建立连接，所以进程也没必要开启
第一步：vim /etc/salt/minion，把状态文件客户端从远端改成本地：
#file_client: remote
file_client: local
第二步：设置salt和pillar环境：
file_roots:
  base: /srv/salt/base
pillar_roots:
  base: /srv/pillar/base
第三步：本地编写sls文件
第四步：salt-call --local state.highstate

###syndic
[root@saltsrv ~]# yum install salt-syndic -y
salt syndic必须运行在master上，
syndic没有配置文件，通过master配置来更改。
vim /etc/salt/master编辑配置文件:
syndic_master: 192.168.56.12 --设置高级master的ip
systemctl restart salt-master  --重启服务
systemctl restart salt-syndic   --重启服务,sydnc就可以去找高级master了
这个时候192.168.56.12变成syndic了
vim /etc/salt/master：
order_masters: True  --开启高级Master 
systemctl restart salt-master
[root@saltsrv ~]# vim /etc/salt/master #每个syndic配置路径要一样
file_roots:
  base:
    - /srv/salt
  prod:
    - /srv/salt/prod
pillar_roots:
  base:
    - /srv/pillar
  prod:
    - /srv/pillar/prod
##top master和syndic的工作流程：
发：top master-->syndic-->master-->minion1,minion2
收：minion1,minion2-->syndic,master-->top master
syndic的file_roots和pillar_roots必须和top master高度一致(用共享或git来保持)
缺点：top master不知道自己到底有多少minion

#salt-api
#用salt API进行salt的管理
python框架：
http://docs.saltstack.cn/ref/netapi/all/salt.netapi.rest_cherrypy.html
1.https证书
2.配置文件
3.验证。使用PAM验证
4.启动salt-api
#实例：
第二步：配置：
[root@salt-server ~]# yum install salt-api -y
[root@salt-server ~]# vim /etc/salt/master
default_include: master.d/*.conf
[root@salt-server ~]# systemctl restart salt-master
[root@salt-server ~]# cd /etc/salt/master.d
[root@salt-server /etc/salt/master.d]# cat api.conf
rest_cherrypy:
  host: 192.168.1.235
  port: 8000
  ssl_crt: /etc/pki/tls/certs/localhost.crt
  ssl_key: /etc/pki/tls/private/salt_nopass.key
第三步：验证：使用PAM验证
[root@salt-server /etc/salt/master.d]# cat eauth.conf
external_auth:
  pam:
    saltapi:
      - .*   #能够执行所有模块
      - '@wheel'  #salt-key用的
      - '@runner'  #让它看机器是否存活
[root@salt-server /etc/salt/master.d]# systemctl start salt-api
[root@salt-server /etc/salt/master.d]# netstat -tunlp
tcp        0      0 192.168.1.235:8000      0.0.0.0:*               LISTEN
#注意执行步骤，否则salt-api有可能无法正常启动：
1. 先安装pip,然后安装CherryPy==3.2.6 
2. 再修master配置文件，打开/etc/salt/master.d/*.conf配置
3. 重启master服务，并配置api.conf和eauth.conf配置
4. 重启salt-api服务
#####获取token
[root@salt-server /etc/salt/master.d]# curl -k https://192.168.1.235:8000/login \
> -H 'Accept: application/x-yaml' \
> -d username='saltapi' \
> -d password='saltapi' \
> -d eauth='pam'
return:
- eauth: pam
  expire: 1546972037.344875
  perms:
  - .*
  - '@wheel'
  - '@runner'
  start: 1546928837.344873
  token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4
  user: saltapi
###查询Minion(Linux-node3-salt)的信息
[root@salt-server ~]# curl  -k https://192.168.1.235:8000/minions/Linux-node3-salt \
> -H "Accept: application/x-yaml" \
> -H "X-Auth-Token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4"
return:
- Linux-node3-salt:
    SSDs: []
    biosreleasedate: 09/30/2014
    biosversion: '6.00'
    cpu_flags:
    - fpu
    - vme
    - de
    - pse
    - tsc
    - msr
    - pae
    - .........

###job管理
获取缓存的jobs列表
[root@salt-server ~]# curl  -k https://192.168.1.235:8000/jobs/ \
>  -H "Accept: application/x-yaml" \
> -H "X-Auth-Token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4"

return:
- '20190107220235665576':
    Arguments: []
    Function: runner.manage.versions
    StartTime: 2019, Jan 07 22:02:35.665576
    Target: salt-server_master
    Target-type: list
    User: root
  '20190107220236473477':
    Arguments: []
    Function: test.version
    StartTime: 2019, Jan 07 22:02:36.473477
    Target: '*'
    Target-type: glob
    User: root
    ............

###查询指定的job
[root@salt-server ~]# curl -k https://192.168.1.235:8000/jobs/20190108144904235175 \
> -H "Aaccept: application/x-yaml" \
> -H "X-Auth-Token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4"
{"info": [{"Function": "grains.items", "jid": "20190108144904235175", "Target": "Linux-node3-salt", "Target-type": "glob", "Result": {"Linux-node3-salt": {"fun_args": [], "jid": "20190108144904235175", "return": {"biosversion": "6.00", "kernel": "Linux", "domain": "", "uid": 0, "zmqversion": "4.1.4", "kernelrelease": "3.10.0-862.el7.x86_64", "selinux": {"enforced": "Disabled", "enabled": false}, "serialnumber": "VMware-42 2d 74 25 4d b4 e5 b4-e2 ee 35 15 66 73 cf 17", "pid": 1599, "ip_interfaces": {"lo": ["127.0.0.1", "::1"], "eth0": ["192.168.1.232", "192.168.1.236", "fe80::250:56ff:fead:4c16"]}..........

###远程执行模块
#client="local"  #类似本地salt
[root@salt-server ~]# curl  -k https://192.168.1.235:8000/ \
> -H "Aaccept: application/x-yaml" \
> -H "X-Auth-Token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4" \
> -d client="local" \
> -d tgt="*" \
> -d fun="test.ping" 
{"return": [{"Linux-node6-slave-mysql": true, "Linux-node3-salt": true, "Linux-node1-salt": true, "Linux-node5-master-mysql": true, "salt-server": true, "Linux-node4-salt": true}]}

###运行runner,(salt-run)
[root@salt-server ~]# curl  -k https://192.168.1.235:8000/ \
> -H "Aaccept: application/x-yaml" \
> -H "X-Auth-Token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4" \
> -d client="runner" \
> -d tgt="manage.status" 
return:
- down: []
  up:
  - Linux-node1-salt
  - Linux-node3-salt
  - Linux-node4-salt
  - Linux-node5-master-mysql
  - Linux-node6-slave-mysql
  - salt-server

###运行wheel
#类似获取salt-key一样
[root@salt-server ~]# curl -k https://192.168.1.235:8000/ \
> -H "Accept: application/x-yaml" \
> -H "X-Auth-Token: 7453b2facb592ffa7be3b1c1de4e2a51d796acf4" \
> -d client="wheel" \
> -d fun='key.list_all'
return:
- data:
    _stamp: '2019-01-08T07:07:51.835321'
    fun: wheel.key.list_all
    jid: '20190108150750623661'
    return:
      local:
      - master.pem
      - master.pub
      minions:
      - Linux-node1-salt
      - Linux-node3-salt
      - Linux-node4-salt
      - Linux-node5-master-mysql
      - Linux-node6-slave-mysql
      - salt-server
      minions_denied: []
      minions_pre:
      - cobbler-server
      - zabbix-proxy
      - zabbix-server
      minions_rejected: []
    success: true
    tag: salt/wheel/20190108150750623661
    user: saltapi
  tag: salt/wheel/20190108150750623661

##资料：
www.github.com/binbin91/oms
oms系统:
git clone --depth 1 https://www.github.com/binbin91/oms
saltshaker系统:
https://github.com/yueyongyue/saltshaker

</pre>


