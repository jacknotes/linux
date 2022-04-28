#prometheus
<pre>
#学习1
#时间序列数据：
按照时间顺序记录系统、设备状态变化的数据被称为时序数据。
应用场景：
	1. 无人驾驶
	2. 车辆行驶轨迹数据
	3. 证券行业实时交易数据
	4. 实时运维监控数据等
#优点：
1. 性能好
2. 存储成本低，存储占用空间小
#特征：
1. 多维度数据模型（cpu,内存，存储，网络）
2. 灵活的查询语言（promQL）
3. 不依赖分布式存储，单个服务器节点是自主的
4. 以HTTP方式，通过pull模型去拉时间序列数据
5. 也可以通过中间网关支持push模型
6. 通过服务发现或者静态配置，来发现目标服务对象
7. 支持多种多样的图表和界面展示（需要跟grafana结合）
#prometheus架构原理
1. 通过自动发现K8s容器进行收集存储数据到prometheus Server.通过配置pull数据拉取到prometheus Server收集存储。
2. 如果触发阀值则会发送告警，通过prometheus Server的报警模块进行报警。
3. 结合grafana可视化软件在前端展示图形。

#实验环境
192.168.15.202(node3): prometheus(收集存储),grafana(可视化)
192.168.15.201(node2): by monitor machine(web,mysql..)
#软件下载
refresh: https://prometheus.io/download/
prometheus: https://github.com/prometheus/prometheus/releases/download/v2.17.2/prometheus-2.17.2.linux-amd64.tar.gz
grafana: https://dl.grafana.com/oss/release/grafana-7.0.3-1.x86_64.rpm
node_exporter: https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz #用于监控节点，如果监控mysql则需要mysql_exporter
#node3安装prometuehs
[root@node3 /download]# ls
grafana-7.0.3-1.x86_64.rpm  node_exporter-0.18.1.linux-amd64.tar.gz  prometheus-2.17.2.linux-amd64.tar.gz
[root@node3 /download]# tar xf prometheus-2.17.2.linux-amd64.tar.gz -C /usr/local/
[root@node3 /usr/local/prometheus]# groupadd -g 9090 prometheus
[root@node3 /usr/local/prometheus]# useradd -M -s /sbin/nologin -g 9090 -u 9090 prometheus
[root@node3 /usr/local/prometheus]# chown -R prometheus:prometheus /usr/local/prometheus-2.17.2.linux-amd64/
[root@node3 /download]# ln -vs /usr/local/prometheus-2.17.2.linux-amd64 /usr/local/prometheus
‘/usr/local/prometheus’ -> ‘/usr/local/prometheus-2.17.2.linux-amd64’
[root@node3 /download]# cd /usr/local/prometheus
[root@node3 /usr/local/prometheus]# ll
total 142908
drwxr-xr-x 2 prometheus prometheus       38 Apr 20 18:28 console_libraries
drwxr-xr-x 2 prometheus prometheus      173 Apr 20 18:28 consoles
-rw-r--r-- 1 prometheus prometheus    11357 Apr 20 18:28 LICENSE
-rw-r--r-- 1 prometheus prometheus     3184 Apr 20 18:28 NOTICE
-rwxr-xr-x 1 prometheus prometheus 84342838 Apr 20 16:29 prometheus
-rw-r--r-- 1 prometheus prometheus      926 Apr 20 18:28 prometheus.yml
-rwxr-xr-x 1 prometheus prometheus 48231919 Apr 20 16:30 promtool
-rwxr-xr-x 1 prometheus prometheus 13736212 Apr 20 16:31 tsdb
[root@node3 /usr/local/prometheus]# mkdir /var/lib/prometheus  #数据存储目录
[root@node3 /usr/local/prometheus]# chown -R prometheus:prometheus /var/lib/prometheus
[root@node3 /usr/local/prometheus]# grep -v '#\|^$' prometheus.yml 
global:
  scrape_interval:     15s # 抓取采样数据的时间间隔，默认是15秒去被监控机上采样一次，值应当是=>5s
  evaluation_interval: 15s # 监控的数据规则的评估频率，例如我们设置当内存使用量>70%时发出报警这么一条规则，那么prometheus会默认15秒来执行这个规则检查。
alerting:  #alertmanager配置段，在结合grafana4.0以上时不用这个了，使用grafana的报警了
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
scrape_configs:  #抓取数据的配置
  - job_name: 'prometheus'  #任务名称
    static_configs:  		#静态配置
    - targets: ['localhost:9090']  #要监控的客户端
  - job_name: 'node'
    static_configs:
    - targets: ['192.168.15.201:9100','192.168.15.202:9100']
  - job_name: 'mariadb'
    static_configs:
    - targets: ['192.168.15.201:9104']
[root@node3 /usr/local/prometheus]# vim /usr/lib/systemd/system/prometheus.service
-------旧版-------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.local.retention 168h0m0s \
--storage.local.max-chunks-to-persist 3024288 \
--storage.local.memory-chunks=50502740 \
--storage.local.num-fingerprint-mutexes=300960 \
--web.enable-lifecycle
Restart=on-failure

[Install]
WantedBy=multi-user.target
---------新版----------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=15d \
--web.external-url=http://192.168.13.236:9090 \
--web.enable-admin-api \
--web.enable-lifecycle
Restart=on-failure

[Install]
WantedBy=multi-user.target
--------------
注：prometheus其它参数：
--storage.local.retention
用来配置采用数据存储的时间，168h0m0s即为24*7小时，即1周
--storage.local.memory-chunks
设定prometheus内存中保留的chunks的最大个数，默认为1048576，即为1G大小
--storage.local.series-file-shrink-ratio
用来控制序列文件rewrite的时机，默认是在10%的chunks被移除的时候进行rewrite，如果磁盘空间够大，不想频繁rewrite，可以提升该值，比如0.3，即30%的chunks被移除的时候才触发rewrite
--storage.local.max-chunks-to-persist
该参数控制等待写入磁盘的chunks的最大个数，如果超过这个数，Prometheus会限制采样的速率，直到这个数降到指定阈值的95%。建议这个值设定为storage.local.memory-chunks的50%。Prometheus会尽力加速存储速度，以避免限流这种情况的发送。
--storage.local.num-fingerprint-mutexes
当prometheus server端在进行checkpoint操作或者处理开销较大的查询的时候，采集指标的操作会有短暂的停顿，这是因为prometheus给时间序列分配的mutexes可能不够用，可以通过这个指标来增大预分配的mutexes，有时候可以设置到上万个
--storage.local.series-sync-strategy
控制写入数据之后，何时同步到磁盘，有'never', 'always', 'adaptive'. 同步操作可以降低因为操作系统崩溃带来数据丢失，但是会降低写入数据的性能。 默认为adaptive的策略，即不会写完数据就立刻同步磁盘，会利用操作系统的page cache来批量同步。
--storage.local.checkpoint-interval
进行checkpoint的时间间隔，即对尚未写入到磁盘的内存chunks执行checkpoint操作。
--web.enable-lifecycle
开启此参数可对prometheus进行配置热加载和状态检查等。

[root@node3 /usr/local/prometheus]# systemctl daemon-reload
[root@node3 /usr/local/prometheus]# systemctl start prometheus
[root@node3 /usr/local/prometheus]# systemctl status prometheus
[root@node3 /usr/local/prometheus]# netstat -tnlp | grep 9090
tcp6       0      0 :::9090                 :::*                    LISTEN      12857/prometheus
注：prometheus已经成功启动了。可以登录http://192.168.15.202:9090进行访问了，http://192.168.15.202:9090/metrics可以查看采集prometheus server的数据。
#node2安装node_exporter监控主机
[root@node2 /download]# tar xf /download/node_exporter-0.18.1.linux-amd64.tar.gz -C /usr/local/
[root@node2 /download]# groupadd -g 9090 prometheus
[root@node2 /download]# useradd -M -s /sbin/nologin -g 9090 -u 9090 prometheus
[root@node2 /download]# chown -R prometheus:prometheus /usr/local/node_exporter-0.18.1.linux-amd64/
[root@node2 /download]# ln -sv /usr/local/node_exporter-0.18.1.linux-amd64/ /usr/local/node_exporter
‘/usr/local/node_exporter’ -> ‘/usr/local/node_exporter-0.18.1.linux-amd64/’
[root@node2 /usr/local/node_exporter]# vim /usr/lib/systemd/system/node_exporter.service
--------------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
--------------
[root@node2 /usr/local/node_exporter]# systemctl start node_exporter.service 
[root@node2 /usr/local/node_exporter]# systemctl status node_exporter.service 
[root@node2 /usr/local/node_exporter]# ss -tnlp | grep 9100
LISTEN     0      128         :::9100                    :::*                   users:(("node_exporter",pid=13333,fd=3))
注：http://192.168.15.201:9100/metrics可查看采集信息
#在prometheus server中添加node_exporter，添加后即可以在prometheus server拉取数据
[root@node3 /usr/local/prometheus]# vim prometheus.yml #编辑配置文件
scrape_configs:
  - job_name: 'node2'  #添加这三行
    static_configs:
    - targets: ['192.168.15.201:9100']
[root@node3 /usr/local/prometheus]# systemctl restart prometheus.service #重新启动服务
#注：在http://192.168.15.201:9090/targets可以查看添加node2的状态了。
#监控mysql服务,node2安装mysqld_exporter
[root@node2 /download]# axel -n 30 https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz
[root@node2 /etc/yum.repos.d]# yum install -y mariadb-server mariadb #安装mysql
[root@node2 /etc/yum.repos.d]# systemctl start mariadb.service
MariaDB [(none)]> grant select,replication client,process on *.* to prometheus_mysql@'localhost' identified by 'prometheus';
Query OK, 0 rows affected (0.00 sec)

MariaDB [(none)]> flush privileges;
Query OK, 0 rows affected (0.00 sec)
[root@node2 /download]# tar xf /download/mysqld_exporter-0.12.1.linux-amd64.tar.gz -C /usr/local/
[root@node2 /download]# groupadd -g 9090 prometheus
[root@node2 /download]# useradd -M -s /sbin/nologin -g 9090 -u 9090 prometheus
[root@node2 /download]# chown -R prometheus:prometheus /usr/local/mysqld_exporter-0.12.1.linux-amd64/
[root@node2 /download]# ln -sv /usr/local/mysqld_exporter-0.12.1.linux-amd64/ /usr/local/mysqld_exporter
[root@node2 /usr/local/mysqld_exporter]# vim /usr/lib/systemd/system/mysqld_exporter.service
--------------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/usr/local/mysqld_exporter/.my.cnf
Restart=on-failure

[Install]
WantedBy=multi-user.target
--------------
[root@node2 /usr/local/mysqld_exporter]# vim .my.cnf
[client]
user=prometheus_mysql@'localhost'
password=prometheus
[root@node2 /usr/local/mysqld_exporter]# systemctl start mysqld_exporter.service 
[root@node2 /usr/local/mysqld_exporter]# systemctl status mysqld_exporter.service 
#在prometheus server中添加mysqld_exporter，添加后即可以在prometheus server拉取数据
[root@node3 /usr/local/prometheus]# vim prometheus.yml #编辑配置文件
scrape_configs:
  - job_name: 'mariadb'  #添加这三行
    static_configs:
    - targets: ['192.168.15.201:9104']
[root@node3 /usr/local/prometheus]# systemctl restart prometheus.service #重新启动服务
#注：在http://192.168.15.201:9090/targets可以查看添加mariadb的状态了。

#----docker运行mysqld_exporter
[root@hohong-node2 /tmp]# cat mysqld-exporter.yaml 
version: '3'
services:
  mysql:
    image: mysql:5.7
    ports:
      - "3306:3306"
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=database
  mysqlexporter:
    image: prom/mysqld-exporter
    ports:
      - "9104:9104"
    environment:
      - DATA_SOURCE_NAME=root:password@(mysql:3306)/database
[root@hohong-node2 /tmp]# docker-compose -f mysqld-exporter.yaml up -d

#-----安装cAdvisor监控容器
--二进制运行：
[root@node3 /download]# wget https://github.com/google/cadvisor/releases/latest
[root@node3 /download]# cp cadvisor /usr/local/bin/
[root@node3 /download]# chmod +x /usr/local/bin/cadvisor
[root@node3 /download]# chown root.root /usr/local/bin/cadvisor
[root@node3 /download]# cat /usr/lib/systemd/system/cadvisor.service 
---------------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=root
Group=root
Type=simple
ExecStart=/usr/local/bin/cadvisor -port=8080 &>>/var/log/cadvisor.log
Restart=on-failure

[Install]
WantedBy=multi-user.target
---------------
[root@node3 /download]# netstat -tnlp | grep 8080
tcp6       0      0 :::8080                 :::*                    LISTEN      25771/cadvisor 

--docker运行
docker run -d \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=7070:8080 \
  --detach=true \
  --name=cadvisor \
  --restart=always \
  google/cadvisor:latest
[root@node3 /download]# netstat -tnlp | grep 7070
tcp6       0      0 :::7070                 :::*                    LISTEN      25771/cadvisor 	

#--redis_exporter监控redis主从集群
wget https://github.com/oliver006/redis_exporter/releases/download/v1.11.1/redis_exporter-v1.11.1.linux-amd64.tar.gz
tar -xf redis_exporter-v1.11.1.linux-amd64.tar.gz -C /usr/local
chmod -R prometheus.prometheus /usr/local//usr/local/redis_exporter-v1.11.1.linux-amd64/
ln -sv /usr/local//usr/local/redis_exporter-v1.11.1.linux-amd64/ /usr/local/redis_exporter
[root@prometheus redis_exporter]# cat /usr/lib/systemd/system/redis_exporter.service 
------------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/redis_exporter/redis_exporter -redis.addr 192.168.13.160:6369 -redis.password hmIpAjs/BunNqw==
Restart=on-failure

[Install]
WantedBy=multi-user.target
------------
--注：运行redis_exporter程序时必须指定一个集群节点，这样redis_exporter才能找到其他节点，有认证必须使用密码,集群密码必须统一,然后在prometheus.yml配置文件中添加redis_exporter和redis节点两个job，如果只添加redis_exporter则只会监控上述的192.168.13.160:6369节点，需要监控其它节点需要在再添加一个redis节点的job，并重写标签让这些节点的__address__变量值为redis_exporter的地址，这样才能使节点从127.0.0.1:9121的metric指标中promQL查询出值来。
systemctl daemon-reload
systemctl enable redis_exporter
systemctl start redis_exporter
[root@prometheus prometheus]# less prometheus.yml
-------------
  - job_name: 'redis_exporter_target'
    static_configs:
      - targets:
        - 192.168.13.160:6369
        - 192.168.13.161:6369
        - 192.168.13.162:6369
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 192.168.13.236:9121
  - job_name: 'redis_exporter'
    static_configs:
    - targets: 
      - '192.168.13.236:9121'
------------
[root@prometheus prometheus]# curl -X POST http://localhost:9090/-/reload
注：grafana添加redis cluster模板显示,模板ID:763

#--mysqld_exporter监控mysql集群
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.12.1/mysqld_exporter-0.12.1.linux-amd64.tar.gz
[root@prometheus download]# tar xf mysqld_exporter-0.12.1.linux-amd64.tar.gz -C /usr/local/
[root@prometheus download]# chown -R prometheus.prometheus /usr/local/mysqld_exporter-0.12.1.linux-amd64/
[root@prometheus download]# ln -sv /usr/local/mysqld_exporter-0.12.1.linux-amd64/ /usr/local/mysqld_exporter
--配置mysqld访问帐户
mysql> CREATE USER 'exporter'@'192.168.13.%' IDENTIFIED BY 'mysqld_exporter' WITH MAX_USER_CONNECTIONS 3;
mysql> GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'192.168.13.%';
[root@prometheus mysqld_exporter]# yum install -y mysql
[root@prometheus mysqld_exporter]# cat .my_160.cnf 
[client]
host=192.168.13.160
port=3306
user=exporter
password='mysqld_exporter'
------------
[root@prometheus mysqld_exporter]# cat .my_116.cnf 
[client]
host=192.168.13.116
port=3306
user=exporter
password='mysqld_exporter'
------------
[root@prometheus mysqld_exporter]# cat /usr/lib/systemd/system/mysqld_exporter_160.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/usr/local/mysqld_exporter/.my_160.cnf \
--web.listen-address=0.0.0.0:9104 \
--collect.auto_increment.columns \
--collect.info_schema.processlist
Restart=on-failure

[Install]
WantedBy=multi-user.target
------------
[root@prometheus mysqld_exporter]# cat /usr/lib/systemd/system/mysqld_exporter_116.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/usr/local/mysqld_exporter/.my_116.cnf \
--web.listen-address=0.0.0.0:9105 \
--collect.auto_increment.columns \
--collect.info_schema.processlist
Restart=on-failure

[Install]
WantedBy=multi-user.target
------------
[root@prometheus download]# systemctl daemon-reload 
[root@prometheus download]# systemctl start mysqld_exporter_160.service
[root@prometheus download]# systemctl start mysqld_exporter_116.service
[root@prometheus download]# systemctl enable mysqld_exporter_160.service 
[root@prometheus download]# systemctl enable mysqld_exporter_116.service 
[root@prometheus prometheus]# less prometheus.yml
-----------------
  - job_name: 'mysqld_exporter'
    static_configs:
    - labels:
        instance: 192.168.13.160:3306
        mysql_host: 192.168.13.160:9100
      targets: 
      - '192.168.13.236:9104'
    - labels:
        instance: 192.168.13.116:3306
        mysql_host: 192.168.13.116:9100
      targets: 
      - '192.168.13.236:9105'
    relabel_configs:
      - source_labels: [__address__]
        regex: (.*)
        target_label: __address__
        replacement: $1
-----------------
[root@prometheus prometheus]# curl -XPOST http://localhost:9090/-/reload
注：去grafana添加模板，模板ID：7362

#--windows_exporter
注：windows_exporter客户端使用版本为windows_exporter-0.13.0-amd64.msi，此版本不能采集windows server 2003系统。
C:\software>msiexec /i windows_exporter-0.17.1-amd64.msi ENABLED_COLLECTORS="[defaults],tcp,iis,cpu_info" TEXTFILE_DIR="C:\custom_metrics\" /quiet
C:\software>msiexec /x windows_exporter-0.17.1-amd64.msi /quiet
注：开启iis，tcp,cpu_info等信息收集，但是收集这些东西耗性能，有时候会收集不到，并且导致收集其它信息异常，建议关闭，使用默认功能即可。

msiexec /i windows_exporter-0.13.0-amd64.msi ENABLED_COLLECTORS="[defaults],tcp,iis,cpu_info" TEXTFILE_DIR="C:\custom_metrics\" /quiet

#--wmi_exporter
注：wmi_exporter客户端使用版本为wmi_exporter-0.8.3-386.msi,此版本可以采集windows server 2003系统。

-----------------
#snmp_exporter
[root@prometheus download]# tar xf snmp_exporter-0.19.0.linux-amd64.tar.gz -C /usr/local/
[root@prometheus download]# chown -R prometheus.prometheus /usr/local/snmp_exporter-0.19.0.linux-amd64/
[root@prometheus download]# ln -sv /usr/local/snmp_exporter-0.19.0.linux-amd64/ /usr/local/snmp_exporter
----
[root@prometheus download]# cat /usr/lib/systemd/system/snmp_exporter.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/snmp_exporter/snmp_exporter \
--config.file=/usr/local/snmp_exporter/snmp.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
----
[root@prometheus snmp_exporter]# systemctl daemon-reload
[root@prometheus snmp_exporter]# systemctl start snmp_exporter
[root@prometheus snmp_exporter]# systemctl enable snmp_exporter
[root@prometheus snmp_exporter]# netstat -tnlp | grep 9116
tcp6       0      0 :::9116                 :::*                    LISTEN      19832/snmp_exporter 

#MIB
https://github.com/librenms/librenms/tree/master/mibs
idracURL: https://github.com/librenms/librenms/blob/master/mibs/dell/DELL-RAC-MIB
[root@prometheus generator]# cd /usr/local/generator/
[root@prometheus generator]# tree .
.
└── mib
    └── DELL-RAC-MIB
[root@prometheus generator]# snmptranslate -Tz -m ~/.snmp/mibs/DELL-RAC-MIB | grep batteryState
"batteryState"			"1.3.6.1.4.1.674.10892.2.6.1.20.130.15.1.4"
[root@prometheus generator]# cat generator.yml
---
modules:  
# we need to generate hwCpuDevTable metrics.
# and the module name in the `snmp.yml` will be `dell`.
  dell:
    walk: 
      - batteryState
    version: 2 
    timeout: 30s 
    auth:
      community: "public"
---
[root@prometheus mib]# docker run -it -v "${PWD}:/opt/" prom/snmp-generator:master generate
注：自己通过generator生成器生成snmp.yml文件总是失败。可以借助第三方生成好的文件进行运行

#第三方snmp.yml文件下载
https://raw.githubusercontent.com/zorrzoor/grafana-idrac-dashboard/main/snmp.yml
修改团体名称：  vim snmp.yml
auth:
    community: public
#dashboard
idrac snmp dashboard for granfana: 14395
#多开一个snmp_exporter服务
[root@prometheus snmp_exporter]# cat /usr/lib/systemd/system/snmp_exporter-two.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/snmp_exporter-two/snmp_exporter \
--config.file=/usr/local/snmp_exporter-two/snmp.yml \
--web.listen-address=192.168.13.236:9117
Restart=on-failure

[Install]
WantedBy=multi-user.target


-----------------

#SQL_EXPORTER(SQLSERVER)
-----------------
[root@prometheus download]# tar xf sql_exporter-0.5.linux-amd64.tar.gz -C /usr/local/
[root@prometheus download]# chown -R prometheus.prometheus /usr/local/sql_exporter-0.5.linux-amd64
[root@prometheus download]# ln -sv /usr/local/sql_exporter-0.5.linux-amd64 /usr/local/sql_exporter
[root@prometheus sql_exporter]# cat sql_exporter.yml  | grep -vE '#|^$'
global:
  scrape_timeout_offset: 500ms
  min_interval: 0s
  max_connections: 10
  max_idle_connections: 3
target:
  data_source_name: sqlserver://prom:password@172.168.2.219:1433?encrypt=disable
  collectors: [mssql_standard]
collector_files: 
  - "*.collector.yml"
[root@prometheus sql_exporter]# cat /usr/lib/systemd/system/sql_exporter.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/sql_exporter/sql_exporter \
-config.file=/usr/local/sql_exporter/sql_exporter.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
[root@prometheus prometheus]# systemctl daemon-reload 
[root@prometheus prometheus]# systemctl start sql_exporter
[root@prometheus prometheus]# systemctl enable sql_exporter
-----------------

#node3安装grafana
[root@node3 /download]# wget https://dl.grafana.com/oss/release/grafana-7.0.3-1.x86_64.rpm
[root@node3 /download]# sudo yum install grafana-7.0.3-1.x86_64.rpm -y
[root@node3 /download]# systemctl start grafana-server.service 
[root@node3 /download]# systemctl enable grafana-server.service 
[root@node3 /download]# systemctl status grafana-server.service
注：安装好即可进行访问grafana:http://192.168.15.202:3000/
#在grafana添加数据源prometheus
Configure--DataSource--Select prometheus Type--(设置名称，URL,access类型，scraper interval[获取数据间隔],query timeout[查询超时]，HTTP method[获取方法]等)
#针对prometheus数据源添加图形展示node信息
Create--Dashboard--new--Select Edit--在查询菜单下和第一个查询(A)中设置metrics的监控项值。例如node_load1--在添加一个查询node_load5--在添加一个查询node_load15--save要保存。
扩展：如果你想针对某一个实例或者某一个job来展示需要的图形，可在metrics的监控项值后面加大括号{}，例：node_load1{job="node2"}，表示只展示job_name是node2的主机实例。
#针对prometheus数据源添加图形展示mysql信息
percona模板连接：https://github.com/percona/grafana-dashboards #percon专门做数据库的，里面模板有mysql和mongodb
下载MySQL_Overview.json,并在grafana中导入模板文件。导入后显示数据源出错，因为默认模板是找Prometheus这个数据源，所以得去把数据源名称改成Prometheus，改后就有数据了。但最改好有些模板报错，显示“Panel plugin not found: pmm-singlestat-panel”，此时需要安装插件：grafana-piechart-panel如：
[root@node3 /usr/share/grafana/conf]# grafana-cli plugins install grafana-piechart-panel
[root@node3 /usr/share/grafana/conf]# systemctl restart grafana-server

#第三方模板
#常用的grafana模板,数据来源均为prometheus
第一部分
监控容器
推荐ID
3146
8685
10000
8588
315
11277
11558
第二部分
监控物理机/虚拟机(linux)
推荐ID
8919
9276
ok:1860
ok:10242
监控物理机/虚拟机(windows)
推荐ID
10467
10171
2129
第三部分
监控协议http/icmp/tcp/dns/
http监控某个网站
icmp监控某台机器
tcp监控某个端口
dns监控dns
推荐ID
9965
实操模板：
mysqld-exporter: 7362
docker cadvisor: 8321
cadvisor: 11277

#grafana+onealert报警
在睿象云（onealert）上注册帐号，可以使用webhook勾子.
在grafana的alert模块增加notify channel中添加webhook类型的通道。
在需要报警的图表中编辑alert子菜单，进行名称、触发条件、发送内容等设置。

#学习2
###prometheus特点
#优点
1. 监控精度高，可以精确到1~5秒的采集精度
2. 集群部署的速度、监控脚本的制作（在熟练后）非常快捷
3. 周边插件很丰富（exporter、pushgateway）大多数不需要自己开发了
4. 本身基于数据计算模型，大量的实证函数，可以实现很复杂规则的业务逻辑监控（例如QPS的曲线 弯曲 凸起 下跌的 比例等等）
5. 可以嵌入到很多开源工具的内部进行监控，数据更准时，更可信（其他监控很难做到这一点）
6. 本身是开源的，更新速度快，bug修复快，支持N多种语言做本身和插件的二次开发
7. 图形高大上，很美观，老板很喜欢看这种业务图（主要是指结合grafana）
#缺点
1. 目前不支持集群，只能自己workaround
2. 学习成本太大，尤其是其独有的数学命令行（非常强大的同时，又极其难学），中文资料极少，本身的各种数学模型的概念很复杂。
3. 对磁盘资源也是耗费的较大，这个具体要看监控的集群量和监控项的多少和时间的长短决定。
4. 本身的使用，需要使用者的数学不能太差，要有一定的数学头脑。

#组件
prometheus本身是一个以进程方式启动，之后（有exporters等插件加入）以多进程和多线程实现监控数据收集 计算 查询 更新 存储 的这样一个C/S模型运行模式。
存储： prometheus数据先保存在内存中，定期写入硬盘，硬盘中的数据先变成块，然后由块变成trunk文件，trunk文件是最小基本单元。每一秒的K/V数据是一个metric，index是将metric和label生成索引跟trunk一起存储。metadata也是跟trunk一起存储的。
pull: 各种exporter插件以后台守护进行方式运行，prometheus通过http get请求去访问exporter端口获取数据，这种就是pull模式。
push: pushgateway软件部署在客户端或者服务端，端口为9091，运维自行开发各种脚本把监控数据组织成K/V的形式通过http POST方法发送给pushgateway,pushgateway会定期将数据push到prometheus server上。
报警：prometheus自带了altermanager报警插件，但是这个插件有问题一般不用。一般用grafana自带的监控来实现报警。可以通过grafana结合pagerduty,email等进行报警。
metrics: 是一种对采样数据的总称。（metrics并不代表某一种具体的数据格式，是一种对于度量计算单位的抽象）
metrics几种主要的类型：
	1. Gauges：最简单的度量指标，只有一个简单的返回值，或者叫瞬时状态。这种变化没有规律，当前是多少采集回来就是多少。
	2. Counters: 是计数器，从数据0开始累积计算，在理想状态下只能是永远的增长，决对不会降低（一些特殊情况除外，例如Counter被清0了）
	3. Histograms: 统计数据的分布情况，近似百分比估算数值。比如最小值、最大值、中间值，还有中位数、75百分位、90百分位、95百分位等。比如：在全部用户的响应时间中。0~0.0.5秒量有多少，=0.0.5秒的量有多少，>2秒的量有多少,>10秒的量有多少
注：前两种metrics类型是最重新的metrics类型，占到百分之六七十。
时间序列数据：K/V的数据形式，以空格分隔
#exporter的类型
1. prometheus
2. alertmanager
3. blackbox_exporter(针对一个ip地址是否拼得通，服务是否是up状态，端口是否通的)
4. consul_exporter
5. graphite_exporter
6. haproxy_exporter
7. memcached_exporter
8. mysqld_exporter
9. node_exporter
10. statsd_exporter
#prometheus.yml配置文件讲解
[root@node3 /usr/local/prometheus]# grep -v '^#' prometheus.yml 
global:
  scrape_interval:     15s # 抓取采样数据的时间间隔，默认是15秒去被监控机上采样一次，值应当是=>5s
  evaluation_interval: 15s # 监控的数据规则的评估频率，例如我们设置当内存使用量>70%时发出报警这么一条规则，那么prometheus会默认15秒来执行这个规则检查。
alerting:  #alertmanager配置段，在结合grafana4.0以上时不用这个了，使用grafana的报警了
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
scrape_configs:  #抓取数据的配置
  - job_name: 'prometheus'  #任务名称
    static_configs:  		#静态配置
    - targets: ['localhost:9090']  #要监控的客户端
  - job_name: 'node'
    static_configs:
    - targets: ['192.168.15.201:9100','192.168.15.202:9100']
  - job_name: 'mariadb'
    static_configs:
    - targets: ['192.168.15.201:9104']

#promQL查询命令行，数学理论
prometheus cpu时间：从系统开机到现在的时间累加。
cpu使用率=所有cpu非空间时间总和/所有cpu时间总和
例如：
12:00开机后一直到12:30截止，这30分钟过程中的情况（当前我们先暂时忽略是几核CPU，就当作1核来说）
CPU被使用在用户态的时间一共是8分钟
CPU被使用在内核态的时间一共是1.5分钟
CPU被使用在IO等待的时间一共是0.5分钟
CPU被使用在idle(空闲状态)的时间一共是20分钟
CPU被使用在其他几个状态的时间是0
#函数
increase(): 是用来针对Counter这种类型持续增长的数值，截取其中一段时间的增量
例如：increase(node_cpu[1m])  #这样就获取了CPU总使用时间在1分钟内的增量，但是核数太多，看图太杂乱
sum(): 起到加合的作用,多核cpu相加的平均值
例如：sum(increase(node_cpu[1m])) #外面套用了一个sum即可把所有核数值加合平均显示，不会看到杂乱了
by(instance): 这个函数可以把sum加合到一起的数值按照指定的一个方式进行一层的拆分，instance代表的是机器名，这样就不会显示所有节点的信息的，而是指定某一个节点的信息
例如：sum(increase(node_cpu[1m])) by(instance)
命令行讲解：
第一步：选择key: node_cpu是我们需要使用的key name
第二步：把idle的空闲cpu时间和全部cpu时间都给过滤出来，key使用{}做过滤，例如node_cpu{mode="idle"}表示空闲cpu时间，node_cpu表示所有cpu时间
第三步：使用increase函数包起来
increase(node_cpu{mode="idle"}[1m])  #1分钟内cpu是空闲时间的增量
increase(node_cpu[1m])   #1分钟内cpu所有时间的增量
第四步：使用sum()函数加合，不然cpu核数太多会看到密密麻麻的线
sum(increase(node_cpu{mode="idle"}[1m]))  #1分钟内集群内所有cpu是空闲时间的增量，包括了多个节点
sum(increase(node_cpu[1m]))   #1分钟内集群内所有cpu所有时间的增量，包括了多个节点
第五步：使用by()函数
sum(increase(node_cpu{mode="idle"}[1m])) by(instance)
sum(increase(node_cpu[1m])) by(instance)
第六步：相除
sum(increase(node_cpu{mode="idle"}[1m])) by(instance) /sum(increase(node_cpu[1m])) by(instance)
第七步：用1去减空闲时间，然后乘于100
(1 - ((sum(increase(node_cpu{mode="idle"}[1m])) by(instance)) /(sum(increase(node_cpu[1m])) by(instance)))) * 100

#prometheus命令行格式 
例如：count_netstat_wait_connections (TCP wait_connect数，自行编写的)
cpu: 类型 counter(需要使用函数去修饰)
自行编写的：类型gauge（很少使用函数去修饰）
1. 标签的过滤
count_netstat_wait_connections{exported_instance="log",exporterd_job="pushgateway1",instance="localhost:9092",job="pushgateway"} #{}内的部分属于标签，标签：也是来自于采集数据，可以自定义也可以直接使用默认的exporter提供的标签项，这个{}中最重要的标签是exported_instance，指明了是哪台被监控服务器，"log"是一台日志服务器的机器名。注：命令行的查询，在原始输入的基础上先使用{}进行第一步过滤。
count_netstat_wait_connections{exported_instance=~"web.*"} #只显示web开头的机器
注：.*属于正则表达式  =~模糊匹配  !~模糊不匹配（模糊匹配后取反）
2. 数值的过滤
count_netstat_wait_connections{exported_instance=~"web.*"}>400 #只显示web开头的机器，并且条件是大于400的显示出来（会在图形上显示不规则的点图示）

#函数的使用
函数链接：https://prometheus.io/docs/prometheus/latest/querying/functions/
rate(): 是专门搭配counter类型数据使用的函数，它的的功能是按照设置一个时间段，取counter在这个时间段中的"平均每秒"的增量,prometheus最重要的函数之一
例如：rate(node_network_receive_bytes_total[1m])  #在一分钟内平均每秒的增量
注意：我们以后在使用任何counter数据类型的时候，永远记得别的先不做，先给它加上一个rate()或者increase()函数。
increase(): 是用来针对Counter这种类型持续增长的数值，截取其中一段时间的总增量，last值-first值，自动调整单调性，与delta()不同之处在于delta是求差值，而increase返回最后一个减第一个值,可为正为负。
例如：increase(node_network_receive_bytes_total[1m])  #这样就获取了网络总使用时间在1分钟内的总增量
注：什么时候用rate函数，什么时候用increase函数。increase一般采集不是详细的数据，比较粗糙。rate一般用于比较细的数据，瞬息万变的，例如：cpu，内存，硬盘，Io网络流量
delta（）
计算一个范围向量v的第一个元素和最后一个元素之间的差值，只能为正。delta函数返回值类型只能是gauges
sum(): 对多个结果进行加和，可以使用by()或者without()关键字进一步筛选，没有特定数据类型
例如：sum(rate(node_network_receive_bytes_total[1m])) by(instance) #外面套用了一个sum即可把所有网络接收流量接口的值加合平均显示，不会看到杂乱了。by()中的instance是表示对每个机器进行拆分。by(cluster_name)是对每个集群进行抓分，cluster_name需要我们自定义标签，node_exporter是没有办法提供的
by(instance): 这个函数可以把sum加合到一起的数值按照指定的一个方式进行一层的拆分，没有特定数据类型，通常结合sum函数一起使用
topk(): Gauge类型数据和Counter类型数据使用
例：topk(1,rate(node_network_receive_bytes_total[1m])) #topk因为对于每一个时间点都只取前几高的数值，那么必然会造成单个机器的采集数据不连贯。实际使用的时候，一般用topk()进行瞬时报警，而不是为了观察曲线图。
count(): 把数值符合条件的，输出数目进行加合。一般使用它进行模糊的监控判断，例如，当cpu(或连接数)高于80%的机器大于30台就报警
例如：count(count_netstat_wait_connections > 200) #找出当前（或历史）当TCP等待数大于200的机器数量
predict_linear(): ----例如预测内存4小时后的剩余情况
predict_linear(node_filesystem_free_bytes{job="nodes"}[1h], 4 * 3600) / 1024 /1024
irate()
(last值-last前一个值)/时间戳差值

##企业级监控数据采集方法
prometheus后台运行方式：
1. nohup &
2. screen
3. 写/usr/lib/systemd/system/prometheus.service配置文件，这个稳定，前面有。
4. daemonize 方式放入后台，更加正规更稳定
daemonize的使用：
git clone git@github.com:bmc/daemonize.git
sh configure && make && make install
daemonize -c /usr/local/prometheus /usr/local/prometheus/up.sh #-c表示脚本路径，后面是脚本路径名称
注：up.sh内容： /usr/local/prometheus/prometheus --web-listen-address="0.0.0.0:9090" --web.read-timeout=5m --web.max-connections=512 --storage-tsdb.retention=15d --storage.tsdb.path="/var/lib/prometheus" --query.max-concurrency=20 --query.timeout=2m
--web-listen-address="0.0.0.0:9090" #监听地址端口
--web.read-timeout=5m #请求链接的最大等待时间，当达到这个值是prometheus会进行回收，防止大多的空闲链接占用资源
--web.max-connections=512  #最大链接数
--storage-tsdb.retention=15d #prometheus开始采集监控数据后，会存在内存和硬盘中，这里可以设置数据保留时间天数
--storage.tsdb.path="/var/lib/prometheus" #存储数据的目录，不指是当前运行的程序路径下存储。必需指定
--query.max-concurrency=20  #最大的并发查询连接数
--query.timeout=2m #例如当慢查询过长时，设置这个值prometheus会结束这个慢查询，防止单个用户执行过大的查询而不一直退出。
注：prometheus的所有节点都必须时间同步，否则数据会有不一致情况发生。
#prometheus数据
[root@node3 /var/lib/prometheus]# ls /var/lib/prometheus/
01EA6S8F5PS9X5QDC4GWQ2DJQY  01EA8XXPSHK0RS6TQX63HZTG3V  01EA94SE172YEYYXTPQC17VRFX  queries.active
01EA8SBPQG8M25DN9HGXP490AH  01EA8XXQ1061FPC00TMT7KJF1S  lock                        wal
注：长串字母目录是prometheus历史保留数据，而近期的数据实际上保留在内存中，并且按照一定间隔存放在wal/（冷备份）目录中，防止突然断电或者重启，以用来恢复内存中的数据。
#配置文件
[root@node3 /usr/local/prometheus]# grep -v '^#' prometheus.yml 
global:
  scrape_interval:     15s # 抓取采样数据的时间间隔，默认是15秒去被监控机上采样一次，值应当是=>5s
  evaluation_interval: 15s # 监控的数据规则的评估频率，例如我们设置当内存使用量>70%时发出报警这么一条规则，那么prometheus会默认15秒来执行这个规则检查。
alerting:  #alertmanager配置段，在结合grafana4.0以上时不用这个了，使用grafana的报警了
  alertmanagers:
  - static_configs:
    - targets:
      # - alertmanager:9093
rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"
scrape_configs:  #抓取数据的配置
  - job_name: 'prometheus'  #任务名称
    static_configs:  		#静态配置
    - targets: ['localhost:9090']  #要监控的客户端
  - job_name: 'node'
    static_configs:
    - targets: ['192.168.15.201:9100','192.168.15.202:9100']
  - job_name: 'mariadb'
    static_configs:
    - targets: ['192.168.15.201:9104']
#node_export安装运行中prometheus方式一样运行，工作在9100端口。
node_export有默认常用的监控项，有些没有开启的监控项，可以使用帮助命令查看开启：./node_exporter --help  #./node_exporter --buddyinfo
#必须掌握的key类别
1. node_memory
2. node_cpu
3. node_disk

#企业级监控数据采集脚本开发
#pushgateway的安装
[root@node3 /download]# axel -n 30 https://github.com/prometheus/pushgateway/releases/download/v1.0.1/pushgateway-1.0.1.linux-amd64.tar.gz
[root@node3 /download]# tar xf pushgateway-1.0.1.linux-amd64.tar.gz -C /usr/local/
[root@node3 /usr/local/pushgateway]# chown -R prometheus:prometheus /usr/local/pushgateway-1.0.1.linux-amd64/
[root@node3 /usr/local/pushgateway-1.0.1.linux-amd64]# ln -sv /usr/local/pushgateway-1.0.1.linux-amd64/ /usr/local/pushgateway
[root@node3 ~]# cat /usr/lib/systemd/system/pushgateway.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/pushgateway/pushgateway --web.listen-address=0.0.0.0:9091
Restart=on-failure

[Install]
WantedBy=multi-user.target
[root@node3 ~]# systemctl start pushgateway.service 
[root@node3 ~]# systemctl status pushgateway.service | grep -i active
   Active: active (running) since Mon 2020-06-08 14:17:38 CST; 35s ago
[root@node3 ~]# vim /usr/local/prometheus/prometheus.yml #添加pushgaetway配置
- job_name: 'pushgateway'
    static_configs:
    - targets: ['localhost:9091']
[root@node3 ~]# systemctl restart prometheus.service  #重启prometheus服务
[root@node3 ~]# systemctl status prometheus.service | grep -i active
   Active: active (running) since Mon 2020-06-08 14:20:40 CST; 9s ago
#编辑pushgateway的脚本：
[root@node3 ~]# cat /root/pushgateway-netstat.sh
--------------
#!/bin/bash
#description: will localhost tcp and udp LISTEN status count to pushgateway
#author: jackli
#date: 2020-06-08
#email: jacknotes@163.com

instance_name=$(hostname -f | cut -d '.' -f 1)
if [ ${instance_name} == "localhost" ];then
	echo "hostanem Must FQDN"
	exit 1
fi
PushgatewayServer="192.168.15.201:9091"

netstat_listen_label="netstat_listen_count" 
netstat_listen_value=`netstat -natu | grep -ic listen`
echo "${netstat_listen_label} ${netstat_listen_value}"
netstat_established_label="netstat_established_connections" 
netstat_established_value=`netstat -natu | grep -ic established`
echo "${netstat_established_label} ${netstat_established_value}"
netstat_wait_label="netstat_wait_connections" 
netstat_wait_value=`netstat -na | grep -ic wait`
echo "${netstat_wait_label} ${netstat_wait_value}"

#"--data-binary" default is POST method,"@-" is from file and stdin input,"http://${PushgatewayServer}/metrics/job/pushgateway" is pushgateway address and job_name,"instance/${instance_name}" is set K/V,K=instance,V=${instance_name}
cat << EOF | curl --data-binary @- http://${PushgatewayServer}/metrics/job/pushgateway/instance/${instance_name}
# TYPE ${netstat_listen_label} gauge
${netstat_listen_label} ${netstat_listen_value}
# TYPE ${netstat_established_label} gauge
${netstat_established_label} ${netstat_established_value}
# TYPE ${netstat_wait_label} gauge
${netstat_wait_label} ${netstat_wait_value}
EOF
--------------
注："--data-binary"默认是POST方法，"@-"表示是从文件和标准输入输入，"http://192.168.15.202:9091/metrics/job/pushgateway"表示pushgateway的地址及job K/V，"instance/${instance_name}"是为当前推送的数据设定一个实例和值。
[root@node1 ~]# crontab -l
# Lines below here are managed by Salt, do not edit
# SALT_CRON_IDENTIFIER:ntpdate time1.aliyun.com
*/5 * * * * ntpdate time1.aliyun.com

*/1 * * * * /root/netstat-status.sh
*/1 * * * * sleep 15; /root/netstat-status.sh
*/1 * * * * sleep 30; /root/netstat-status.sh
*/1 * * * * sleep 45; /root/netstat-status.sh

*/1 * * * * /root/ping.sh
*/1 * * * * sleep 15; /root/ping.sh 
*/1 * * * * sleep 30; /root/ping.sh
*/1 * * * * sleep 45; /root/ping.sh

#pushgateway的优缺点
优点：灵活，自定义编写脚本，中小型企业中一般只使用node_exporter和mysqld_exporter
缺点：
1. pushgateway会形成一个单点瓶颈，假如好多个脚本同时发送给一个pushgateway的进程，如果这个进程挂了，那么监控数据也就没了。
2. pushgateway并不能对发送过来的脚本采集数据进行更智能的判断，假如脚本中间采集出问题了，那么有问题的数据pushgateway一样照单全收发送给prometheus.
针对缺点优化：
1. 其实只要服务器不宕机，那么基本上pushgateway运行还是很稳定的。就算有太多的脚本同时都发送给一个pushgateway，其实也只是接收的速度会慢，丢数据没有遇到过。
2. 其实只要我们在写脚本的时候，细心一些，别出错就行。写的时候用自己熟悉的脚本写就好。
#采集网络丢包率，延迟，抖动数据
[root@node3 ~]# cat ./pushgateway-ping.sh
---------------
#!/bin/bash
#description: will localhost tcp and udp LISTEN status count to pushgateway
#author: jackli
#date: 2020-06-08
#email: jacknotes@163.com

instance_name=$(hostname -f | cut -d '.' -f 1)
if [ ${instance_name} == "localhost" ];then
	echo "hostanem Must FQDN"
	exit 1
fi

PingServer="192.168.15.201"
PushgatewayServer="192.168.15.201:9091"
ping_result=`ping -q -A -s 500 -W 1000 -c 100 ${PingServer}` 
if [ $? != 0 ];then 
	echo "hostname not result,ping failure"
	exit 1
fi
ping_value=`ping -q -A -s 500 -W 1000 -c 100 ${PingServer} | grep rtt | awk -F '=' '{print $2}' | awk -F '/' '{sub(/\ /,"");print $1,$2,$3}'`

#get min,avg,max delay value
ping_delay_min=`echo $ping_value | awk '{print $1}'`
ping_delay_avg=`echo $ping_value | awk '{print $2}'`
ping_delay_max=`echo $ping_value | awk '{print $3}'`

#ping loss rate
ping_loss_lable="ping_loss" 
ping_loss_value=`ping -q -A -s 500 -W 1000 -c 100 ${PingServer} | grep loss | awk -F ',' '{print $3}' | awk '{sub(/%/,"");print $1}'`
echo "${ping_loss_lable} ${ping_loss_value}"

#ping delay value,unit is ms
ping_delay_lable="ping_delay" 
ping_delay_value=${ping_delay_avg}
echo "${ping_delay_lable} ${ping_delay_value}"

#ping zheng and fu shake value,unit is ms
ping_shake_zheng_lable="ping_shake_zheng" 
ping_shake_zheng_value=`echo "scale=3; $ping_delay_max-$ping_delay_avg" | bc`
ping_shake_fu_lable="ping_shake_fu" 
#ping_shake_fu_value=`echo "scale=3; $ping_delay_min-$ping_delay_avg" | bc | awk '{sub(/\-/,"");print $NF}'`
ping_shake_fu_value=`echo "scale=3; $ping_delay_min-$ping_delay_avg" | bc`
echo "${ping_shake_zheng_lable} ${ping_shake_zheng_value}"
echo "${ping_shake_fu_lable} ${ping_shake_fu_value}"

#"--data-binary" default is POST mode,"@-" is from file and stdin input,"http://${PushgatewayServer}/metrics/job/pushgateway" is pushgateway address and job_name,"instance/${instance_name}" is set K/V,K=instance,V=${instance_name}
cat << EOF | curl --data-binary @- http://${PushgatewayServer}/metrics/job/pushgateway/instance/${instance_name}
# TYPE ${ping_loss_lable} gauge
# HELP ${ping_loss_lable} loss package rate
${ping_loss_lable} ${ping_loss_value}
# TYPE ${ping_delay_lable} gauge
# HELP ${ping_delay_lable} delay avg time,unit is ms
${ping_delay_lable} ${ping_delay_value}
# TYPE ${ping_shake_zheng_lable} gauge
# HELP ${ping_shake_zheng_lable} shake zheng time,unit is ms
${ping_shake_zheng_lable} ${ping_shake_zheng_value}
# TYPE ${ping_shake_fu_lable} gauge
# HELP ${ping_shake_fu_lable} shake fu time,unit is ms
${ping_shake_fu_lable} ${ping_shake_fu_value}
EOF
---------------

#grafana
1. 安装并启动grafana
2. 添加prometheus数据源
3. 添加dashboard，添加图形
4. 在图形中设置metrics的值，legend可以优化图例中显示的值：{{exported_instance}}表示只显示exported_instance，不显示其他参数
5. grafana dashboard可以另存为一个新的dashboard,可以把dashboard json数据复制出来保存，以备不时之需，windows下记事本保存必须是UTF-8保存，否则恢复是会有乱码
6. grafana报警：进入alerting--Notification channels--new channel添加一个报警通道--Email类型--include image--填写收件地址并保存，include image：需要安装插件：[root@node1 /etc/grafana]# grafana-cli plugins install grafana-image-renderer。
7. 进入需要报警的dashboard中的图形中，进入Alert，设置规则名称、报警条件{WHEN avr()|max()|min().. OF query(A|B,1m,now) IS ABOVE 2000}，并设置每1m钟评估一次，持续3m钟后才发送报警，期间状态是pending。然后选择Notifications的报警通道，报警消息。
#邮箱发件端需要在/etc/grafana/grafana.ini中设置，如下：
#################################### SMTP / Emailing ##########################
[smtp]
enabled = true
host = smtp.126.com:25
user = jack@126.com
password = TEZV12
skip_verify = true
from_address = jack@126.com
from_name = Grafana
ehlo_identity =            #这里不能写，否则会被网易识别为垃圾邮件发送不成功。为空使用默认消息
###############

#企业中CPU监控
#cpu
CPU的使用率：
(1 - ((sum(increase(node_cpu_seconds_total{mode="idle"}[1m])) by(instance)) / (sum(increase(node_cpu_seconds_total[1m])) by (instance)))) * 100
或
(1- (sum(rate(node_cpu_seconds_total{mode="idle"}[1m])) by(instance)) / ((sum (rate(node_cpu_seconds_total[1m])) by(instance))) ) * 100
针对IOWAIT类型的CPU等待时间：
(sum(increase(node_cpu_seconds_total{mode="iowait"}[1m])) by(instance) / sum(increase(node_cpu_seconds_total[1m])) by (instance)) * 100
#内存
CentOS5.x和CentOS6.x真实可用内存=free memory+buffer+cached
CentOS7.x真实可用内存=available(也可使用free memory+buffer+cached)
内存使用率：单位Ms
(1 - ((node_memory_Buffers_bytes + node_memory_Cached_bytes + node_memory_MemFree_bytes) /node_memory_MemTotal_bytes)) * 100
#硬盘
硬盘空闲比例：
(sum(node_filesystem_free_bytes{device=~"/dev/sda.*"}) by(instance) / sum(node_filesystem_size_bytes{device=~"/dev/sda.*"}) by(instance)) * 100
硬盘IO使用率：是(read+written) /1024 /1024  
((rate(node_disk_read_bytes_total[1m]) + rate(node_disk_written_bytes_total[1m])) /1024 /1024) > 0
#网络
网络流量情况：，单位Ms
rate(node_network_transmit_bytes_total[1m]) /1024 /1024
#针对close wait 和time wait的监控key
netstat_wait_connections
#针对文件描述符监控：linux系统每个默认打开最大文件描述符限制是1024，默认都有0，1，2三个文件描述符
(node_filefd_allocated / node_filefd_maximum) * 100 #打开的文件描述符/最大的文件描述符 * 100
#网络丢包率监控
使用上面自己写的脚本，把他做成grafana图形

#pagerduty报警平台
pagedury默认只有14天试用期，购买一个月几百元。
1. 注册新账号
2. 创建新的service
3. 用户接收帐户设置以及报警信息的设置

</pre>

#prometheus-book
<pre>
#-----查询操作
#查询时间序列
http_requests_total
等同于：
http_requests_total{}
#范围查询：
http_request_total{}[1d]
除了使用m表示分钟以外，PromQL的时间范围选择器支持其它时间单位：
s - 秒
m - 分钟
h - 小时
d - 天
w - 周
y - 年
#时间位移操作：
如果我们想查询，5分钟前的瞬时样本数据，或昨天一天的区间内的样本数据呢? 这个时候我们就可以使用位移操作，位移操作的关键字为offset：
http_request_total{} offset 5m
http_request_total{}[1d] offset 1d
#使用聚合操作
-查询系统所有http请求的总量
sum(http_request_total)
-按照mode计算主机CPU的平均使用时间
avg(node_cpu) by (mode)
-按照主机查询各个主机的CPU使用率
sum(sum(irate(node_cpu{mode!='idle'}[5m]))  / sum(irate(node_cpu[5m]))) by (instance)
#标量和字符串
--除了使用瞬时向量表达式和区间向量表达式以外，PromQL还直接支持用户使用标量(Scalar)和字符串(String)。
-标量（Scalar）：一个浮点型的数字值
直接使用浮点型的数字值，作为PromQL表达式，则会直接返回浮点型的数字值，没有时序。
-字符串（String）：一个简单的字符串值
直接使用字符串，作为PromQL表达式，则会直接返回字符串。
#合法的PromQL表达式
http_request_total # 合法
http_request_total{} # 合法
{method="get"} # 合法
{__name__=~"node_cpu_seconds_total"}
#-----PromQL操作符
#用> <对结果进行一次过滤，满足条件则保留，不满足则丢弃
((node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes ) * 100 > 70
#用bool修饰符使结果返回0还是1
((node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes ) * 100 > bool 70
#集合运算符
and (并且,交集)
or (或者，并集)
unless (排除，差集)
--and,只返回两个向量相同的结果
node_filesystem_free_bytes{device=~"/dev/sda1"} and node_filesystem_free_bytes{device=~"/dev/sda[12]"} 
--or,返回两个向量去重后的结果
node_memory_MemTotal_bytes or node_memory_MemFree_bytes
--unless,用前面多的标签 - 右边少的标签，得到的结果
node_filesystem_free_bytes{device=~"/dev/sda[12]"} unless node_filesystem_free_bytes{device=~"/dev/sda1"}
#操作符优先级顺序(加用()来优先运算)
^
*, /, %
+, -
==, !=, <=, <, >=, >
and, unless
or
#匹配模式(匹配标签)
向量与向量之间进行运算操作时会基于默认的匹配规则：依次找到与左边向量元素匹配（标签完全一致）的右边向量元素进行运算，如果没找到匹配元素，则直接丢弃。PromQL中有两种典型的匹配模式：一对一（one-to-one）,多对一（many-to-one）或一对多（one-to-many）
	例如当存储样本：
		method_code:http_errors:rate5m{method="get", code="500"}  24
		method_code:http_errors:rate5m{method="get", code="404"}  30
		method_code:http_errors:rate5m{method="put", code="501"}  3
		method_code:http_errors:rate5m{method="post", code="500"} 6
		method_code:http_errors:rate5m{method="post", code="404"} 21
		method:http_requests:rate5m{method="get"}  600
		method:http_requests:rate5m{method="del"}  34
		method:http_requests:rate5m{method="post"} 120
	一对一匹配：
		一对一匹配模式会从操作符两边表达式获取的瞬时向量依次比较并找到唯一匹配(标签完全一致)的样本值。默认情况下，使用表达式。在操作符两边表达式标签不一致的情况下，可以使用on(label list)或者ignoring(label list）来修改便签的匹配行为。使用ignoreing可以在匹配时忽略某些便签。而on则用于将匹配行为限定在某些便签之内
		例：method_code:http_errors:rate5m{code="500"} / ignoring(code) method:http_requests:rate5m 
		结果：	{method="get"}  0.04            //  24 / 600
				{method="post"} 0.05            //   6 / 120
		注解：当右边标签不能匹配左边标签时，则需要使用on()或者ignoring()来确定标签或忽略标签。结果：左边向量只有两个结果24和6，右边有三个结果是600、120和34，这里是在右边向量前使用ignoring()注明本向量没有code标签，请忽略，则左边向量去除右边向量时则会忽略code标签，即最后左边向量是{method="get"}，{method="post"}两个标签，右边需要满足左边标签则也是{method="get"}，{method="post"}
	多对一和一对多：
		多对一和一对多两种匹配模式指的是“一”侧的每一个向量元素可以与"多"侧的多个元素匹配的情况。在这种情况下，必须使用group修饰符：group_left或者group_right来确定哪一个向量具有更高的基数（充当“多”的角色）
		例：method_code:http_errors:rate5m / ignoring(code) group_left method:http_requests:rate5m
		{method="get", code="500"}  0.04            //  24 / 600
		{method="get", code="404"}  0.05            //  30 / 600
		{method="post", code="500"} 0.05            //   6 / 120
		{method="post", code="404"} 0.175           //  21 / 120
		注解：该表达式中，左向量method_code:http_errors:rate5m包含两个标签method和code。而右向量method:http_requests:rate5m中只包含一个标签method，因此匹配时需要使用ignoring限定匹配的标签为code。 在限定匹配标签后，右向量中的元素可能匹配到多个左向量中的元素 因此该表达式的匹配模式为多对一，需要使用group修饰符group_left指定左向量具有更好的基数。

#----PromQL聚合函数
sum (求和)
min (最小值)
max (最大值)
avg (平均值)
stddev (标准差)
stdvar (标准方差)
count (计数)
count_values (对value进行计数)
bottomk (后n条时序)
topk (前n条时序)
quantile (分位数)
其中只有count_values, quantile, topk, bottomk支持参数(parameter)。
without用于从计算结果中移除列举的标签，而保留其它标签。by则正好相反，结果向量中只保留列出的标签，其余标签则移除。通过without和by可以按照样本的问题对数据进行聚合。
sum(http_requests_total) without (instance)
等价于
sum(http_requests_total) by (code,handler,job,method)
count_values: count_values("tag",node_cpu_seconds_total{mode="nice"})  #将向量表达式结果值代入给标签tag，形成新的标签，值为标签出现的次数

#----PromQL内置函数
#计算Counter指标增长率
--increase计算出最近两分钟的增长量，最后除以时间120秒得到node_cpu样本在最近两分钟的平均增长率
increase(node_cpu[2m]) / 120
--rate函数可以直接计算区间向量在时间窗口内平均增长速率。因此，通过以下表达式可以得到与increase函数相同的结果：
rate(node_cpu[2m])
--irate函数是通过区间向量中最后两个样本数据来计算区间向量的增长速率。这种方式可以避免在时间窗口范围内的“长尾问题”(rate函数无法避免长尾问题)，并且体现出更好的灵敏度，经常用于突发性指标中。
注：irate函数相比于rate函数提供了更高的灵敏度，不过当需要分析长期趋势或者在告警规则中，irate的这种灵敏度反而容易造成干扰。因此在长期趋势分析或者告警中更推荐使用rate函数。
#预测Gauge指标变化趋势
--在一般情况下，系统管理员为了确保业务的持续可用运行，会针对服务器的资源设置相应的告警阈值。例如，当磁盘空间只剩512MB时向相关人员发送告警通知。 这种基于阈值的告警模式对于当资源用量是平滑增长的情况下是能够有效的工作的。 但是如果资源不是平滑变化的呢？ 比如有些某些业务增长，存储空间的增长速率提升了高几倍。这时，如果基于原有阈值去触发告警，当系统管理员接收到告警以后可能还没来得及去处理问题，系统就已经不可用了。 因此阈值通常来说不是固定的，需要定期进行调整才能保证该告警阈值能够发挥去作用。此时PromQL中内置的predict_linear(v range-vector, t scalar) 函数可以帮助系统管理员更好的处理此类情况，predict_linear函数可以预测时间序列v在t秒后的值。它基于简单线性回归的方式，对时间窗口内的样本数据进行统计，从而可以对时间序列的变化趋势做出预测。例如，基于2小时的样本数据，来预测主机可用磁盘空间的是否在4个小时候被占满，可以使用如下表达式：
predict_linear(node_filesystem_free_bytes{job="nodes"}[1h], 4 * 3600)  <  0
#动态标签替换
表达式：up
up{instance="192.168.230.8:9104",job="mysqld"}
表达式：label_replace(up,'host','$1','instance',"(.*):(.*)")
up{host="192.168.230.8",instance="192.168.230.8:9104",job="mysqld"}
表达式：label_join(up,'host','----','instance','job')
up{host="192.168.230.8:9104----mysqld",instance="192.168.230.8:9104",job="mysqld"}

#使用httpAPI
"resultType": "matrix" | "vector" | "scalar" | "string"有四种数据类型，分别是：区间向量，瞬时向量，标量，字符串
--------数据查询
[root@node1 /usr/local/prometheus]# {"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"up","instance":"192.168.230.8:9104","job":"mysqld"},"value":[1595469514.863,"0"]},{"metric":{"__name__":"up","instance":"192.168.230.8:9100","job":"nodes"},"value":[1595469514.863,"0"]},{"metric":{"__name__":"up","instance":"192.168.230.8:8080","job":"cadvisor"},"value":[1595469514.863,"0"]},{"metric":{"__name__":"up","instance":"127.0.0.1:9090","job":"prometheus"},"value":[1595469514.863,"1"]},{"metric":{"__name__":"up","instance":"127.0.0.1:9104","job":"mysqld"},"value":[1595469514.863,"1"]},{"metric":{"__name__":"up","instance":"127.0.0.1:9091","job":"pushgateway"},"value":[1595469514.863,"1"]},{"metric":{"__name__":"up","instance":"127.0.0.1:9100","job":"nodes"},"value":[1595469514.863,"1"]}]}}
--------区间数据查询--curl的url分号一定要
[root@node1 /usr/local/prometheus]# curl 'http://localhost:9090/api/v1/query_range?query=up&start=2020-07-23T10:03:30.781Z&end=2020-07-23T10:04:00.781Z&step=15s'
{"status":"success","data":{"resultType":"matrix","result":[]}}

###AlertManager
在告警规则文件中，我们可以将一组相关的规则设置定义在一个group下。在每一个group中我们可以定义多个告警规则(rule)。一条告警规则主要由以下几部分组成：
alert：告警规则的名称。
expr：基于PromQL表达式告警触发条件，用于计算是否有时间序列满足该条件。
for：评估等待时间，可选参数。用于表示只有当触发条件持续一段时间后才发送告警。在等待期间新产生告警的状态为pending。
labels：自定义标签，允许用户指定要附加到告警上的一组附加标签。
annotations：用于指定一组附加信息，比如用于描述告警详细信息的文字等，annotations的内容在告警产生时会一同作为参数发送到Alertmanager。
--模块化
一般来说，在告警规则文件的annotations中使用summary描述告警的概要信息，description用于描述告警的详细信息。同时Alertmanager的UI也会根据这两个标签值，显示告警信息。为了让告警信息具有更好的可读性，Prometheus支持模板化label和annotations的中标签的值。
通过$labels.<labelname>变量可以访问当前告警实例中指定标签的值。$value则可以获取当前PromQL表达式计算的样本值。
--查看告警状态
用户可以通过Prometheus WEB界面中的Alerts菜单查看当前Prometheus下的所有告警规则，以及其当前所处的活动状态。
同时对于已经pending或者firing的告警，Prometheus也会将它们存储到时间序列ALERTS{}中。
可以通过表达式，查询告警实例：
ALERTS{alertname="<alert name>", alertstate="pending|firing", <additional alert labels>}
#定义告警规则
[root@node1 /usr/local/prometheus]# cat /usr/local/prometheus/rules/alert.yaml 
groups:
- name: hostStatesAlert
  rules:
  - alert: hostCpuUsageAlert
    #判断条件为true则匹配到
    expr: sum(avg without (cpu)(irate(node_cpu_seconds_total{mode!='idle'}[5m]))) by(instance) > 0.85
    #匹配并持续多久时间
    for: 1m
    #增加的标签和值，可以引用模板
    labels:
      severity: page
    #注解，可以引用模板
    annotations:
      summary: "Instance {{ $labels.instance }} CPU usage High"
      description: "{{ $labels.instance }} CPU Usage above 85% (current value: {{ $value }})"
  - alert: hostMemUsageAlert
    expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes > 0.85
    for: 1m 
    labels:
      severity: page
    annotations:
      summary: "Instance {{ $labels.instance }} Memory usage High"
      description: "{{ $labels.instance }} Memory Usage above 85% (current value: {{ $value }})"
----prometheus添加规则文件
[root@node1 /usr/local/prometheus]# grep rule /usr/local/prometheus/prometheus.yml 
rule_files:
  - /usr/local/prometheus/rules/*.yaml
#安装alertmanager
[root@node3 /download]# tar xf alertmanager-0.20.0.linux-amd64.tar.gz -C /usr/local/
[root@node3 /download]# ln -sv /usr/local/alertmanager-0.20.0.linux-amd64 /usr/local/alertmanager
----默认的存储路径为data/。因此，在启动Alertmanager之前需要创建相应的目录
[root@node3 /usr/local/alertmanager]# mkdir -p /usr/local/alertmanager/data
[root@node3 /usr/local/alertmanager]# chown -R prometheus.prometheus /usr/local/alertmanager-0.20.0.linux-amd64/
[root@node3 /usr/local/alertmanager]# cp /usr/lib/systemd/system/node_exporter.service /usr/lib/systemd/system/alertmanager.service
[root@node3 /usr/local/alertmanager]# cat /usr/lib/systemd/system/alertmanager.service
----------------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://192.168.13.236:9093
Restart=on-failure

[Install]
WantedBy=multi-user.target
----------------
--访问alertmanager WEB界面：http://192.168.15.203:9093/
----关联prometheus
[root@node1 /usr/local/prometheus]# tail /usr/local/prometheus/prometheus.yml
alerting:
  alertmanagers:
    - static_configs:
        - targets: ['localhost:9093']
[root@node1 /usr/local/prometheus]# curl -XPOST http://localhost:9090/-/reload

#alertmanager配置文件：
--alertmanager参数
resolve_timeout:该参数定义了当Alertmanager持续多长时间未接收到告警后标记告警状态为resolved（已解决）。该参数的定义可能会影响到告警恢复通知的接收时间，读者可根据自己的实际场景进行定义，其默认值为5分钟
group_by:使用group_by来定义分组规则,基于告警中包含的标签，如果满足group_by中定义标签名称，那么这些告警将会合并为一个通知发送给接收器
group_wait:新分组默认等待30s批量发送
repeat_interval:发送成功的告警等待3h后重复发送，如果设置太小则会导致收到重复的垃圾邮件
group_interval:存在分组有新告警加入等待5m批量发送
告警的匹配有两种方式可以选择:
match_re:通过设置match_re验证当前告警标签的值是否满足正则表达式的内容。
match:通过设置match规则判断当前告警中是否存在标签labelname并且其值等于labelvalue
每一个告警都会从配置文件中顶级的route进入路由树，需要注意的是顶级的route必须匹配所有告警(即不能有任何的匹配设置match和match_re)，每一个路由都可以定义自己的接受人以及匹配规则。默认情况下，告警进入到顶级route后会遍历所有的子节点，直到找到最深的匹配route，并将告警发送到该route定义的receiver中。但如果route中设置continue的值为false，那么告警在匹配到第一个子节点之后就直接停止。如果continue为true，报警则会继续进行后续子节点的匹配。如果当前告警匹配不到任何的子节点，那该告警将会基于当前路由节点的接收器配置方式进行处理。
#----alertmanager与SMTP邮件集成
[root@node3 /usr/local/alertmanager]# cat alertmanager.yml 
-------------- 
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.126.com:25'
  smtp_from: 'jacknotes@126.com'
  smtp_auth_username: 'jacknotes@126.com'
  smtp_auth_password: 'EHHQVBC'
templates:
  - '/usr/local/alertmanager/wechat.tmpl'
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'default-receiver'
receivers:
- name: 'default-receiver'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "wechat.html" . }}'
    send_resolved: true
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
--------------
[root@node3 /usr/local/alertmanager]# cat wechat.tmpl 
{{ define "email.from" }}jacknotes@126.com{{ end }}
{{ define "email.to" }}jacknotes@163.com, jacknotes@126.com{{ end }}
{{ define "wechat.html" }}
{{- if gt (len .Alerts.Firing) 0 -}}{{ range .Alerts }}
@警报<br>
=========start==========<br>
实例: {{ .Labels.instance }}<br>
信息: {{ .Annotations.summary }}<br>
详情: {{ .Annotations.description }}<br>
时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }}<br>
=========end==========<br>
{{ end }}{{ end -}}
{{- if gt (len .Alerts.Resolved) 0 -}}{{ range .Alerts }}
@恢复<br>
=========start==========<br>
实例: {{ .Labels.instance }}<br>
信息: {{ .Annotations.summary }}<br>
时间: {{ .StartsAt.Format "2006-01-02 15:04:05" }}<br>
恢复: {{ .EndsAt.Format "2006-01-02 15:04:05" }}<br>
=========end==========<br>
{{ end }}{{ end -}}
{{- end }}
----重载alertmanager配置
[root@node3 /usr/local/alertmanager]# curl -XPOST http://localhost:9093/-/reload
#与钉钉集成webhook
--docker安装钉钉报警插件，启用一个名为：webhook1的钉钉机器人：
[root@node3 /download]# docker run -d --name dingtalk --restart always -p 8060:8060 timonwong/prometheus-webhook-dingtalk:master --ding.profile="webhook1=https://oapi.dingtalk.com/robot/send?access_token=dcdb94119d8f6d349bb1311c60fa749ab701b55a5d5a6b9f41ae9548bf1ea8a01"
[root@node3 /download]# netstat -tnlp | grep 8060
tcp6       0      0 :::8060                 :::*                    LISTEN      16946/docker-proxy  
--增加webhook配置
[root@node3 /usr/local/alertmanager]# cat alertmanager.yml 
-----------------
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.126.com:25'
  smtp_from: 'jacknotes@126.com'
  smtp_auth_username: 'jacknotes@126.com'
  smtp_auth_password: 'EHHQVBC'
templates:
  - '/usr/local/alertmanager/wechat.tmpl'
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'webhook'
receivers:
- name: 'default-receiver'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "wechat.html" . }}'
    send_resolved: true
- name: 'webhook'
  webhook_configs:
  - url: 'http://127.0.0.1:8060/dingtalk/webhook1/send'
    send_resolved: true
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
-----------------
[root@node3 /usr/local/alertmanager]# curl -XPOST http://localhost:9093/-/reload
--测试cpu
[root@node3 /download]# cat /dev/zero > /dev/null 
----此时钉钉收到信息
[FIRING:1] hostCpuUsagelert
Alerts Firing
[PAGE] Instance localhost:9100 CPU Usage hight
Description: localhost:9100 CPU Usage above 85% (current value: 0.28501900126675117)
Graph: 
Details:
alertname: hostCpuUsagelert
instance: localhost:9100


#20210830--使用amtool进行命令行邮件告警
例如：需要在"2021-08-30 11:28:01"进行邮件告警，则可以设置如下
[root@prometheus alertmanager]# ./amtool --alertmanager.url=http://localhost:9093 alert add alertname=test team=ops instance='http://192.168.13.236:9093' --annotation=summary='summary of the alert' --annotation=description='description of the alert' --start="2021-08-30T03:28:01+08:00"
[root@prometheus alertmanager]# ./amtool --alertmanager.url=http://localhost:9093 alert query
Alertname  Starts At                Summary               
test       2021-08-30 03:28:01 CST  summary of the alert  
例如：需要对"2021-08-30 11:28:01"进行邮件恢复，则可以设置如下,结束时间不能大于当前时间，为了保险起见建议将恢复时间跟发送时间设成一样，在邮件中有resolved告知是恢复即可。
[root@prometheus alertmanager]# ./amtool --alertmanager.url=http://localhost:9093 alert add alertname=test team=ops instance='http://192.168.13.236:9093' --annotation=summary='summary of the alert' --annotation=description='description of the alert' --end="2021-08-30T03:28:01+08:00"
[root@prometheus alertmanager]# ./amtool --alertmanager.url=http://localhost:9093 alert query
Alertname  Starts At  Summary  
--查看接收告警方式
[root@prometheus alertmanager]# ./amtool --alertmanager.url=http://localhost:9093 config routes 
Routing tree:
.
└── default-route  receiver: email
    ├── {job=~"^(?:.*[a-z].*)$"}  continue: true  receiver: email
    └── {job=~"^(?:.*[a-z].*)$"}  continue: true  receiver: webhook
--测试正则匹配走向哪个路由接收
[root@prometheus alertmanager]# ./amtool --alertmanager.url=http://localhost:9093 config routes test job=service
email,webhook




#屏蔽告警通知
Alertmanager提供了方式可以帮助用户控制告警通知的行为，包括预先定义的抑制机制和临时定义的静默规则。
#----抑制机制
Alertmanager的抑制机制可以避免当某种问题告警产生之后用户接收到大量由此问题导致的一系列的其它告警通知。例如当集群不可用时，用户可能只希望接收到一条告警，告诉他这时候集群出现了问题，而不是大量的如集群中的应用异常、中间件服务异常的告警通知。
例如当集群中的某一个主机节点宕机(NodeDown告警)被触发，由于该主机上部署有其它服务如：中间件等会不可用并触发报警。根据抑制规则的定义:当此主机的所有告警发来时，alertmanager会筛选source_match_re的告警，如果匹配到source_match_re告警条目，则再去找另外的告警标签为job=.*blackbox.*的，如果有多个匹配到，则还要比较其它标签是否有ops值一样相等，如果相等，则相等标签的警告将会被抑制不会被发送告警。否则告警将不会被抑制而正常发送。另外：抑制规则是对黑盒测试用的，白盒监控和黑盒监控(source和target)匹配之间，他们之间的for时间跨度不能太大，否则告警不会被抑制。其实告警在pending状态时alertmanager就在匹配抑制规则了。最好白盒监控和黑盒监控时间一样，这里是都为15s。
inhibit_rules:
  - source_match_re:
      alertname: .*Down.*
    target_match_re:
      job: .*blackbox.*
    equal: 
      - ops

[root@node3 /usr/local/alertmanager]# cat alertmanager.yml 
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.126.com:25'
  smtp_from: 'jacknotes@126.com'
  smtp_auth_username: 'jacknotes@126.com'
  smtp_auth_password: 'EHHQOCOQA'
templates:
  - '/usr/local/alertmanager/wechat.tmpl'
route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 10s
  receiver: 'default-receiver'
receivers:
- name: 'default-receiver'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "wechat.html" . }}'
    send_resolved: true
- name: 'webhook'
  webhook_configs:
  - url: 'http://127.0.0.1:8060/dingtalk/webhook1/send'
    send_resolved: true
inhibit_rules:
  - source_match:
      alertname: hostCpuUsagelert
      severity: page
    target_match:
      severity: page
      #jack: jack
注：表示当一个报警名称为hostCpuUsagelert的告警生效时，并且这个告警中有标签和值为：severity: page的告警，当有一个新的告警中携带标签值为severity: page时，则这个新的报警将被抑制，否则不会被抑制。当多个标签时表示为‘与’的关系
#----临时静默
除了基于抑制机制可以控制告警通知的行为以外，用户或者管理员还可以直接通过Alertmanager的UI临时屏蔽特定的告警通知。通过定义标签的匹配规则(字符串或者正则表达式)，如果新的告警通知满足静默规则的设置，则停止向receiver发送通知。进入Alertmanager UI，点击"New Silence"，用户可以通过该UI定义新的静默规则的开始时间以及持续时间，通过Matchers部分可以设置多条匹配规则(字符串匹配或者正则匹配)。填写当前静默规则的创建者以及创建原因后，点击"Create"按钮即可。通过"Preview Alerts"可以查看预览当前匹配规则匹配到的告警信息。静默规则创建成功后，Alertmanager会开始加载该规则并且设置状态为Pending,当规则生效后则进行到Active状态。


#exporter
exporter download links: https://github.com/prometheus
---------------------------
范围	常用Exporter
数据库	MySQL Exporter, Redis Exporter, MongoDB Exporter, MSSQL Exporter等
硬件	Apcupsd Exporter，IoT Edison Exporter， IPMI Exporter, Node Exporter等
消息队列	Beanstalkd Exporter, Kafka Exporter, NSQ Exporter, RabbitMQ Exporter等
存储	Ceph Exporter, Gluster Exporter, HDFS Exporter, ScaleIO Exporter等
HTTP服务	Apache Exporter, HAProxy Exporter, Nginx Exporter等
API服务	AWS ECS Exporter， Docker Cloud Exporter, Docker Hub Exporter, GitHub Exporter等
日志	Fluentd Exporter, Grok Exporter等
监控系统	Collectd Exporter, Graphite Exporter, InfluxDB Exporter, Nagios Exporter, SNMP Exporter等
其它	Blockbox Exporter, JIRA Exporter, Jenkins Exporter， Confluence Exporter等
---------------------------

1. mysqld-exporter
[root@node1 /usr/local/blackbox_exporter]# cat /usr/lib/systemd/system/mysqld_exporter.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Environment=DATA_SOURCE_NAME=exporter:exporter@(localhost:3306)/
Type=simple
ExecStart=/usr/local/mysqld_exporter/mysqld_exporter --config.my-cnf=/usr/local/mysqld_exporter/.my.cnf --web.listen-address=0.0.0.0:9104
Restart=on-failure

[Install]
WantedBy=multi-user.target

2. blackbox_exporter
----黑盒监控即以用户的身份测试服务的外部可见性，常见的黑盒监控包括HTTP探针、TCP探针等用于检测站点或者服务的可访问性，以及访问效率等。
[root@node3 /download]# tar xf blackbox_exporter-0.17.0.linux-amd64.tar.gz -C /usr/local/
[root@node3 /download]# chown -R prometheus.prometheus /usr/local/blackbox_exporter-0.17.0.linux-amd64/
[root@node3 /download]# ln -sv /usr/local/blackbox_exporter-0.17.0.linux-amd64/ /usr/local/blackbox_exporter
[root@salt /usr/local/blackbox_exporter]# cat blackbox.yml
modules:
  http_2xx:
    prober: http
    timeout: 5s
    http:
      method: GET
      preferred_ip_protocol: ip4
  https_2xx:
    prober: http
    timeout: 5s
    http:
      method: GET
      preferred_ip_protocol: ip4
      tls_config:
        ca_file: "/certs/my_cert.crt"
  http_custom_httpcode:
    prober: http
    timeout: 5s
    http:
      method: GET
      valid_http_versions: ["HTTP/1.1","HTTP/2"]
      valid_status_codes: [200,201,202,203,204,300,301,302]
      preferred_ip_protocol: ip4
  http_post_2xx:
    prober: http
    timeout: 5s
    http:
      method: POST
      preferred_ip_protocol: ip4
      headers:
        Content-Type: application/json
      body: '{}'
  http_post_2xx_basic_auth:
    prober: http
    timeout: 5s
    http:
      method: POST
      preferred_ip_protocol: ip4
      headers:
        Host: 'login.baidu.com'
      basic_auth:
        username: 'username'
        password: 'password'
  tcp_connect:
    prober: tcp
    timeout: 3s
    tcp:
      preferred_ip_protocol: ip4
  pop3s_banner:
    prober: tcp
    timeout: 3s
    tcp:
      query_response:
      - expect: "^+OK"
      tls: true
      tls_config:
        insecure_skip_verify: false
  ssh_banner:
    prober: tcp
    timeout: 3s
    tcp:
      query_response:
      - expect: "^SSH-2.0-"
  irc_banner:
    prober: tcp
    tcp:
      query_response:
      - send: "NICK prober"
      - send: "USER prober prober prober :prober"
      - expect: "PING :([^ ]+)"
        send: "PONG ${1}"
      - expect: "^:[^ ]+ 001"
  icmp:
    prober: icmp
    icmp:
      preferred_ip_protocol: ip4
  dns:
    prober: dns
    timeout: 3s
    dns:
      query_name: 'homsom.com'
      preferred_ip_protocol: 'ip4'
      source_ip_address: '127.0.0.1'
      transport_protocol: 'udp'
      query_type: 'ANY'
注：icmp这个功能需要调整linux内核参数，否则除root外的普通用户无法ping，应在/etc/sysctl.conf设为：net.ipv4.ping_group_range = 0 9090，表示0到9090的组ID范围，运行blackbox_exporter的用户组ID必须在这范围内才有效
[root@node3 /download]# cat /usr/lib/systemd/system/blackbox_exporter.service
--------
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/blackbox_exporter/blackbox_exporter --config.file=/usr/local/blackbox_exporter/blackbox.yml
Restart=on-failure

[Install]
WantedBy=multi-user.target
--------
[root@node3 /usr/local/blackbox_exporter]# systemctl start blackbox_exporter
[root@node3 /usr/local/blackbox_exporter]# netstat -tnlp | grep 9115
tcp6       0      0 :::9115                 :::*                    LISTEN      13601/blackbox_expo 
#Prometheus的Relabeling机制----在Prometheus所有的Target实例中，都包含一些默认的Metadata标签信息。可以通过Prometheus UI的Targets页面中查看这些实例的Metadata标签的内容：默认情况下，当Prometheus加载Target实例完成后，这些Target时候都会包含一些默认的标签：
__address__：当前Target实例的访问地址<host>:<port>  #例如:http://127.0.0.1:9115
__scheme__：采集目标服务访问地址的HTTP Scheme，HTTP或者HTTPS  #http或https协议
__metrics_path__：采集目标服务访问地址的访问路径  #例如/probe
__param_<name>：采集任务目标服务的中包含的请求参数  #例如http://127.0.0.1:9115/probe?module=http_2xx&target=http://baidu.com   ,则__param_target表示获取URL的参数:target=http://baidu.com
-----------------------
[root@prometheus prometheus]# cat prometheus.yml
global:
  scrape_interval:     15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - 'localhost:9093'

rule_files:
  - "/usr/local/prometheus/rules/*.rule"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['127.0.0.1:9090']
  - job_name: 'node_exporter'
    static_configs:
    - targets: ['127.0.0.1:9100']
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - http://baidu.com
        - https://prometheus.io
        - http://mi.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 172.168.2.222:9115
  - job_name: 'docker'
    static_configs:
    - targets: 
      - '192.168.13.21:7070'
      - '192.168.13.160:7070'
      - '192.168.13.161:7070'
      - '192.168.13.162:7070'
      - '192.168.13.223:7070'
      - '192.168.13.235:7070'
      - '192.168.13.237:7070'
      - '192.168.13.238:7070'
      - '192.168.13.239:7070'
-----------------------
relabel_configs注解：
1. source_labels: [__address__]:表示获取targets实例中的地址，例如http://baidu.com，https://prometheus.io，http://mi.com
2. target_label: __param_target:表示将获取到底的__address__值写入到新的标签target中，其值将被传入URL中当参数使用，例如target=http://baidu.com,target=https://prometheus.io,target=http://mi.com
3. source_labels: [__param_target]:表示获取__param_target的值,例如target=http://baidu.com,target=https://prometheus.io,target=http://mi.com
4. target_label: instance:表示将__param_target的值写入到instance标签中，写入为instance=http://baidu.com,instance=https://prometheus.io,instance=target=http://mi.com
5. target_label: __address__:表示将操作这个目标标签
6. replacement: 172.168.2.222:9115:表示替换__address__这个标签的值为172.168.2.222:9115
-----------------------

#20210830--promtool工作使用
--命令行查询表达式
[root@prometheus prometheus]# ./promtool query instant http://localhost:9090 '(1 - ((node_memory_Buffers_bytes{job=~".*node_exporter.*"} + node_memory_Cached_bytes{job=~".*node_exporter.*"} + node_memory_MemFree_bytes{job=~".*node_exporter.*"}) / node_memory_MemTotal_bytes{job=~".*node_exporter.*"})) * 100 > 85'
{app="mysql", env="test", instance="192.168.13.116:9100", job="consul-node_exporter", mysqld_exporter="192.168.13.116:9104", project="services", team="ops"} => 95.62319001386963 @[1630295649.293]
--命令行查询标签
[root@prometheus prometheus]# ./promtool query labels http://localhost:9090 team
dba
ops
tiger





#prometheus API
--管理API
错误：Only queries that return single series/table is supported
清除某个实例的信息，但数据还存在在磁盘中，prometheus在下一次压缩时会进行清理：
curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={instance="127.0.0.1:9100"}'
手动确定立即清理：
curl -X PUT http://localhost:9090/api/v1/admin/tsdb/clean_tombstones
注：当报警邮件收到时，明明一条报警信息，却邮件收到两条，只是实例名称不一样，例如：TCP:172.168.2.222:6379和172.168.2.222:9100，此时需要使用管理API进行清理，{instance="TCP:172.168.2.222:6379"}

#prometheus数据大小优化
--查看prometheus单个series最大多少，单个数量超过了200 万，就不要单实例了，做下集群分片
[root@prometheus prometheus]# /usr/local/prometheus/tsdb ls /var/lib/prometheus/
BLOCK ULID                  MIN TIME       MAX TIME       NUM SAMPLES  NUM CHUNKS  NUM SERIES
01FRZ1473AKBT9CYDK6J84P6C7  1641513600000  1641708000000  4321475895   35892450    354272
01FS4TGVFNAJSMRPWGT5R2MTSM  1641708000000  1641902400000  4319848463   35858035    354249

--查看tsdb状态，评估哪些metric 和 label占用较多，去掉没用的指标
[root@prometheus prometheus]# curl http://localhost:9090/api/v1/status/tsdb | jq .
{
  "status": "success",
  "data": {
    "seriesCountByMetricName": [
      {
        "name": "windows_service_status",
        "value": 61908
      },
      {
        "name": "windows_service_state",
        "value": 41272
      },
      {
        "name": "windows_service_start_mode",
        "value": 25795
      },
      {
        "name": "wmi_service_status",
        "value": 11520
      },
      {
        "name": "wmi_service_state",
        "value": 7680
      },
      {
        "name": "container_cpu_usage_seconds_total",
        "value": 6316
      },
      {
        "name": "container_tasks_state",
        "value": 6005
      },
      {
        "name": "windows_service_info",
        "value": 5269
      },
      {
        "name": "container_memory_failures_total",
        "value": 4804
      },
      {
        "name": "wmi_service_start_mode",
        "value": 4800
      }
    ],
}
--看到windows_service_status和windows_service_state很多，可以去prometheus查看此指标是否无用，无用则可以删除
[root@prometheus ~]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]=windows_service_status&start>2022-01-01&end<2022-01-18'
或者
[root@prometheus ~]# curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]=windows_service_status&match[]={instance="172.168.2.10:9182"}&start>2022-01-01&end<2022-01-18'
--手动立即清理，（跟--storage.tsdb.retention.size=100GB一起使用，效果更明显）
[root@prometheus ~]# curl -X PUT http://localhost:9090/api/v1/admin/tsdb/clean_tombstones

</pre>


<pre>
----consul
[root@prometheus prometheus]# docker run -d --restart=always --name consul -p 8500:8500 consul
[root@prometheus ~]# curl -I http://127.0.0.1:8500
HTTP/1.1 301 Moved Permanently

--consul注册服务
curl -X PUT -d '{"id": "node-exporter","name": "node-exporter-192.168.13.50","address": "192.168.13.50","port": 9100,"tags": ["test"],"checks": [{"http": "http://192.168.13.50:9100/metrics", "interval": "5s"}]}'  http://192.168.13.236:8500/v1/agent/service/register

--consul注销服务
curl -X PUT http://192.168.13.236:8500/v1/agent/service/deregister/node-exporter 

--添加consul配置，并设置过滤条件，只保留__meta_consul_tags标签值包含test的实例
- job_name: 'consul-prometheus'
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*test.*
        action: keep

--编写consul的注册服务信息文件
[root@prometheus work]# cat consul-0.json 
{
  "ID": "node-exporter",
  "Name": "node-exporter-192.168.13.235",
  "Tags": [
    "test"
  ],
  "Address": "192.168.13.235",
  "Port": 9100,
  "Meta": {
    "app": "rabbitmq",
    "team": "ops",
    "project": "jinyu"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.236:9100/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}

--向consul注册服务信息
curl -X PUT --data @consul-0.json http://192.168.13.236:8500/v1/agent/service/register?replace-existing-checks=1



--给每个服务标记不同的 Tag，然后通过 relabel_configs 来进行匹配区分
[root@prometheus work]# cat consul-0.json 
{
  "ID": "node-exporter",
  "Name": "node-exporter-192.168.13.50",
  "Tags": [
    "node-exporter"
  ],
  "Address": "192.168.13.50",
  "Port": 9100,
  "Meta": {
    "app": "rabbitmq",
    "team": "dev",
    "project": "jinyu"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.50:9100/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
[root@prometheus work]# cat consul-1.json 
{
  "ID": "cadvisor-exporter",
  "Name": "cadvisor-exporter-192.168.13.50",
  "Tags": [
    "cadvisor-exporter"
  ],
  "Address": "192.168.13.50",
  "Port": 7070,
  "Meta": {
    "app": "docker",
    "team": "ops",
    "project": "jinyu"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.50:7070/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
[root@prometheus work]# curl -XPUT --data @consul-0.json http://192.168.13.236:8500/v1/agent/service/register?replace-existing-checks=1
[root@prometheus work]# curl -XPUT --data @consul-1.json http://192.168.13.236:8500/v1/agent/service/register?replace-existing-checks=1
  - job_name: 'consul-node-exporter'
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*node.*
        action: keep
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap

  - job_name: 'consul-cadvisor-exporter'
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*cadvisor.*
        action: keep
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap
[root@prometheus prometheus]# curl -XPOST http://localhost:9090/-/reload



#rabbitmq_exporter
REFERENCE: https://github.com/kbudde/rabbitmq_exporter
---
[root@prometheus rabbitmq_exporter]# cat /usr/lib/systemd/system/rabbitmq_exporter.service 
[Unit]
Description=rabbitmq_exporter
Documentation=https://prometheus.io/
After=network.target

[Service]
Type=simple
User=prometheus
Group=prometheus
EnvironmentFile=/usr/local/rabbitmq_exporter/rabbitmq_exporter_env.conf
ExecStart=/usr/local/rabbitmq_exporter/rabbitmq_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
[root@prometheus rabbitmq_exporter]# cat rabbitmq_exporter_env.conf 
RABBIT_USER=rabbitmq_exporter
RABBIT_PASSWORD=rabbitmq@exporter
OUTPUT_FORMAT=JSON
PUBLISH_PORT=9419
RABBIT_URL=http://rabbitmq.hs.com
---
systemctl daemon-reload 
systemctl start rabbitmq_exporter
systemctl enable rabbitmq_exporter

--prometheus.yml文件增加rabbitmq_exporter配置
[root@prometheus rabbitmq_exporter]#vim /usr/local/prometheus/prometheus.yml
  - job_name: 'consul-rabbitmq_exporter'
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_tags]
        regex: .*rabbitmq.*
        action: keep
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap
---
--注册consul
[root@prometheus rabbitmq_exporter]# cat ~/work/consul/rabbitmq_exporter/consul-rabbitmq_exporter-rabbitmq.hs.com.json 
{
  "Name": "rabbitmq_exporter",
  "ID": "rabbitmq_exporter-rabbitmq.hs.com",
  "Tags": [
    "rabbitmq_exporter"
  ],
  "Address": "192.168.13.235",
  "Port": 9419,
  "Meta": {
    "app": "rabbitmq.hs.com",
    "env": "pro",
    "project": "services",
    "team": "ops",
    "cluster": "rabbitmq_cluster"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.235:9419/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
---
--alertmanager增加rabbitmq_exporter报警
[root@prometheus rules]# cat rabbitmq_exporter.rule 
groups:
- name: RabbitmqExporterAlert
  rules:
  - alert: RabbitmqClusterUpAlert
    expr: rabbitmq_up != 1
    for: 15s
    labels:
      severity: High
    annotations:
      summary: "rabbitmq cluster is down"
      description: "team: {{ $labels.team }}, env: {{ $labels.env }}, project: {{ $labels.project }}, job: {{ $labels.job }}, app: {{ $labels.app }}, instance: {{ $labels.instance }} rabbitmq cluster is down(current value: {{ $value }})"

  - alert: RabbitmqNodeRunningAlert
    expr: rabbitmq_running != 1
    for: 15s
    labels:
      severity: High
    annotations:
      summary: "rabbitmq node is down"
      description: "team: {{ $labels.team }}, env: {{ $labels.env }}, project: {{ $labels.project }}, job: {{ $labels.job }}, app: {{ $labels.app }}, instance: {{ $labels.instance }}, node: {{ $labels.node }} rabbitmq node is down(current value: {{ $value }})"
---
[root@prometheus rules]# curl -XPOST http://localhost:9090/-/reload

#202104301755
#prometheus for nginx-vts-exporter 

nginx-module-vts：Nginx virtual host traffic status module，
# Nginx的监控模块，能够提供JSON格式的数据产出。
nginx-vts-exporter：Simple server that scrapes Nginx vts stats and exports them via HTTP for Prometheus consumption。
# 主要用于收集Nginx的监控数据，并给Prometheus提供监控接口，默认端口号9913。
Prometheus：
# 监控Nginx-vts-exporter提供的Nginx数据，并存储在时序数据库中，可以使用PromQL对时序数据进行查询和聚合。

1. nginx 编译安装添加模块
nginx_vts_exporter依赖nginx-module-vts模块，安装此模块无需任何其他依赖。模块与Nginx的版本兼容性如下：
Nginx
1.19.x (last tested: 1.19.6)
1.18.x (last tested: 1.18.0)
1.16.x (last tested: 1.15.1)
1.15.x (last tested: 1.15.0)
1.14.x (last tested: 1.14.0)
1.13.x (last tested: 1.13.12)
1.12.x (last tested: 1.12.2)
1.11.x (last tested: 1.11.10)
1.10.x (last tested: 1.10.3)
1.8.x (last tested: 1.8.0)
1.6.x (last tested: 1.6.3)
1.4.x (last tested: 1.4.7)
[root@tengine /download]# /usr/local/tengine/sbin/nginx -V
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/tengine --sbin-path=/usr/local/tengine/sbin/nginx --conf-path=/usr/local/tengine/conf/nginx.conf --error-log-path=/usr/local/tengine/log/error.log --http-log-path=/usr/local/tengine/log/access.log --pid-path=/usr/local/tengine/tengine.pid --lock-path=/usr/local/tengine/lock/tengine.lock --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --with-http_sub_module

[root@tengine /download]# /usr/local/tengine/sbin/nginx -v
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3

[root@tengine /download]# curl -OL https://github.com/vozlt/nginx-module-vts/archive/refs/tags/v0.1.17.tar.gz
[root@tengine /download]# tar -xf nginx-module-vts-0.1.17.tar.gz 
[root@tengine /download]# cd tengine-2.3.2/
[root@tengine /download/tengine-2.3.2]# ./configure --prefix=/usr/local/tengine --sbin-path=/usr/local/tengine/sbin/nginx --conf-path=/usr/local/tengine/conf/nginx.conf --error-log-path=/usr/local/tengine/log/error.log --http-log-path=/usr/local/tengine/log/access.log --pid-path=/usr/local/tengine/tengine.pid --lock-path=/usr/local/tengine/lock/tengine.lock --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --add-module=/download/nginx-module-vts-0.1.17
[root@tengine /download/tengine-2.3.2]# mv /usr/local/tengine/sbin/nginx{,.old}
[root@tengine /download/tengine-2.3.2]# cp objs/nginx /usr/local/tengine/sbin/
[root@tengine /download/tengine-2.3.2]# ls /usr/local/tengine/sbin/
nginx  nginx.old
[root@tengine /download/tengine-2.3.2]# make upgrade
/usr/local/tengine/sbin/nginx -t
nginx: the configuration file /usr/local/tengine/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/tengine/conf/nginx.conf test is successful
kill -USR2 `cat /usr/local/tengine/tengine.pid`
\sleep 1
test -f /usr/local/tengine/tengine.pid.oldbin
kill -QUIT `cat /usr/local/tengine/tengine.pid.oldbin`
[root@tengine /download/tengine-2.3.2]# /usr/local/tengine/sbin/nginx -V
Tengine version: Tengine/2.3.2
nginx version: nginx/1.17.3
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-44) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017
TLS SNI support enabled
configure arguments: --prefix=/usr/local/tengine --sbin-path=/usr/local/tengine/sbin/nginx --conf-path=/usr/local/tengine/conf/nginx.conf --error-log-path=/usr/local/tengine/log/error.log --http-log-path=/usr/local/tengine/log/access.log --pid-path=/usr/local/tengine/tengine.pid --lock-path=/usr/local/tengine/lock/tengine.lock --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --add-module=modules/ngx_http_upstream_session_sticky_module --with-stream_ssl_module --add-module=modules/ngx_http_upstream_check_module --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --add-module=/download/nginx-module-vts-0.1.17
2. 配置nginx
http {
    vhost_traffic_status_zone shared:vhost_traffic_status:64m;		#增加共享内存，否则会nginx会异常报错，如下线服务器失败
    vhost_traffic_status_filter_by_host on;

server{
	listen 8089;
	server_name 192.168.13.50;
	#server_name 127.0.0.1;

	location /status {
		vhost_traffic_status_display;
        	vhost_traffic_status_display_format html;
    	}
}
}
注：后期生产nginx监控报错
2022/04/28 17:15:52 [crit] 20484#0: ngx_slab_alloc() failed: no memory in vhost_traffic_status_zone "ngx_http_vhost_traffic_status"
2022/04/28 17:15:52 [error] 20484#0: *7810808 shm_add_node::ngx_slab_alloc_locked() failed: used_size[886785], used_node[251] while logging request, client: 172.168.2.219, server: interhotelrm.hs.com, request: "POST /supplier/Getlist HTTP/1.1", upstream: "http://192.168.13.239:12890/supplier/Getlist", host: "interhotelrm.hs.com", referrer: "http://interhotelrm.hs.com/Supplier"
2022/04/28 17:15:52 [error] 20484#0: *7810808 shm_add_upstream::shm_add_node("UGinterhotelrm_loop192.168.13.239:12890") failed while logging request, client: 172.168.2.219, server: interhotelrm.hs.com, request: "POST /supplier/Getlist HTTP/1.1", upstream: "http://192.168.13.239:12890/supplier/Getlist", host: "interhotelrm.hs.com", referrer: "http://interhotelrm.hs.com/Supplier"
注：解决报错方法
        vhost_traffic_status_zone shared:vhost_traffic_status:64m;		#增加共享内存大小
        vhost_traffic_status_filter_by_host on;


[root@tengine /usr/local/tengine/conf]# service tengine reload
3. 配置nginx-vts-exporter
[root@tengine /download]# curl -OL https://github.com/hnlq715/nginx-vts-exporter/releases/download/v0.10.3/nginx-vts-exporter-0.10.3.linux-amd64.tar.gz
[root@tengine /download]# tar xf nginx-vts-exporter-0.10.3.linux-amd64.tar.gz -C /usr/local/
[root@tengine /download]# cd /usr/local/nginx-vts-exporter-0.10.3.linux-amd64/
[root@tengine /usr/local/nginx-vts-exporter-0.10.3.linux-amd64]# /usr/local/nginx-vts-exporter-0.10.3.linux-amd64/nginx-vts-exporter -nginx.scrape_timeout 10 -nginx.scrape_uri http://127.0.0.1:8089/status/format/json -telemetry.address 192.168.13.50:9913 -telemetry.endpoint '/metrics'
[root@tengine /usr/local/nginx-vts-exporter-0.10.3.linux-amd64]# cat /usr/lib/systemd/system/nginx_exporter.service
---
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/nginx-vts-exporter-0.10.3.linux-amd64/nginx-vts-exporter -nginx.scrape_timeout 10 -nginx.scrape_uri http://127.0.0.1:8089/status/format/json -telemetry.address 192.168.13.50:9913 -telemetry.endpoint '/metrics'
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
4. 配置consul和prometheus
consul:
[root@prometheus nginx_exporter]# vim consul-nginx_exporter-192.168.13.50.json
---
[root@prometheus nginx_exporter]# cat consul-nginx_exporter-192.168.13.50.json 
{
  "Name": "nginx_exporter",
  "ID": "nginx_exporter-192.168.13.50",
  "Tags": [
    "nginx_exporter"
  ],
  "Address": "192.168.13.50",
  "Port": 9913,
  "Meta": {
    "app": "ops nginx",
    "env": "pro",
    "project": "services",
    "team": "ops"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.50:9913/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
---
[root@prometheus nginx_exporter]# curl -X PUT --data @consul-nginx_exporter-192.168.13.50.json http://localhost:8500/v1/agent/service/register 
prometheus:
[root@prometheus prometheus]# vim prometheus.yml
---
  - job_name: 'consul-nginx_exporter'
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: []
    relabel_configs:
      - source_labels: [__meta_consul_service]
        regex: nginx.*
        action: keep
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap
---
[root@prometheus prometheus]# curl -X POST http://localhost:9090/-/reload
5. 最后在grafana上配置nginx_exporter，dashboard ID: 2949

#20220426--nginx生产编译参数
[root@reverse01 tengine-2.3.2]# ./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-pcre=/download/pcre-8.44 --with-http_ssl_module --with-http_flv_module --with-http_stub_status_module --with-http_gzip_static_module --with-http_sub_module --with-stream --with-http_realip_module  --with-stream_ssl_module  --with-http_auth_request_module --with-http_gzip_static_module --with-http_random_index_module --add-module=modules/ngx_http_upstream_session_sticky_module --add-module=modules/ngx_http_upstream_check_module --add-module=/download/ngx_http_substitutions_filter_module --add-module=/download/nginx-module-vts-0.1.17


[root@reverse01 /usr/local/nginx/conf]# cat /usr/lib/systemd/system/nginx_exporter.service
[Unit]
Description=https://github.com/hnlq715/nginx-vts-exporter
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/nginx-vts-exporter/nginx-vts-exporter -nginx.scrape_timeout 10 -nginx.scrape_uri http://127.0.0.1:8089/status/format/json -telemetry.address 192.168.13.215:9913 -telemetry.endpoint '/metrics'
Restart=on-failure

[Install]
WantedBy=multi-user.target
---



#grafana + zabbix 显示 
1. grafana-cli plugins install alexanderzobnin-zabbix-app    --安装grafana zabbix插件
2. vim /etc/grafana/grafana.ini    --添加允许未注册的插件装载
allow_loading_unsigned_plugins = alexanderzobnin-zabbix-datasource
3. systemctl restart grafana-server.service
4. 在zabbix中新建只读用户组grafana，并新建用户grafana加入grafana组中
5. 添加zabbix数据源，地址：http://zabbix.hs.com/api_jsonrpc.php 或 地址：http://zabbix.hs.com/zabbix/api_jsonrpc.php


#nginx反向代理prometheus+alertmanager+blackbox
nginx中配置prometheus和alertmanager时需要注意：
/prometheus 表示prometheus配置文件要设置子路径跟这代理一样，--web.external-url=prometheus 
/grafana 表示grafana配置文件要设置子路径跟这代理一样，root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana
------------------
[root@prometheus conf]# grep '^root_url' /etc/grafana/grafana.ini
root_url = %(protocol)s://%(domain)s:%(http_port)s/grafana

[root@prometheus conf]# cat /usr/lib/systemd/system/blackbox_exporter.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/blackbox_exporter/blackbox_exporter \
--config.file /usr/local/blackbox_exporter/blackbox.yml \
--web.external-url=blackbox
Restart=on-failure

[Install]
WantedBy=multi-user.target

[root@prometheus conf]# cat /usr/lib/systemd/system/alertmanager.service 
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager \
--config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data \
--web.route-prefix=alertmanager
Restart=on-failure

[Install]
WantedBy=multi-user.target

[root@prometheus ~]# systemctl cat prometheus.service
# /usr/lib/systemd/system/prometheus.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=30d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://192.168.13.236:9090 \
--web.enable-admin-api \
--web.enable-lifecycle
Restart=on-failure

[Install]
WantedBy=multi-user.target

------------------
--storage.tsdb.wal-compression: 启用预写日志 (WAL) 的压缩
--storage.tsdb.retention.time=30d：数据保留时间，或可用storage.tsdb.retention.time
--storage.tsdb.retention.size=100GB：数据达到此大小将清理数据，和storage.tsdb.retention.time一起使用时谁先达到条件将清理数据
--storage.tsdb.path：数据存储路径
--web.external-url：对外的URL
--web.enable-admin-api：开启管理API功能
--web.enable-lifecycle：开启使用API功能管理prometheus服务

[root@prometheus conf]# cat /usr/local/nginx/conf/nginx.conf | grep -Ev '#|^$' 
worker_processes  1;
events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    upstream grafana {
	server 127.0.0.1:3000;
    }
    upstream prometheus {
	server 127.0.0.1:9090;
    }
    upstream alertmanager {
	server 127.0.0.1:9093;
    }
    upstream blackbox {
	server 127.0.0.1:9115;
    }
    server {
        listen       8088;
        server_name  localhost;
        location / {
            root   html;
            index  index.html index.htm;
        }
	location ^~ /grafana/ {
	        proxy_set_header Host $proxy_host;
	        proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Real-Port $remote_port;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass       http://grafana/;
	}
	location ^~ /prometheus/ {
	        proxy_set_header Host $proxy_host;
	        proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Real-Port $remote_port;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass       http://prometheus/prometheus/;
		auth_basic_user_file /usr/local/nginx/conf/passwdfile;
		auth_basic	"Prometheus";
	}
	location ^~ /alertmanager/ {
	        proxy_set_header Host $proxy_host;
	        proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Real-Port $remote_port;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass       http://alertmanager/alertmanager/;
		auth_basic_user_file /usr/local/nginx/conf/passwdfile;
		auth_basic	"Alertmanager";
	}
	location ^~ /blackbox/ {
	        proxy_set_header Host $proxy_host;
	        proxy_set_header X-Real-IP $remote_addr;
		proxy_set_header X-Real-Port $remote_port;
	        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_pass       http://blackbox/blackbox/;
		auth_basic_user_file /usr/local/nginx/conf/passwdfile;
		auth_basic	"Blackbox";
	}
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}


#ipmi_exporter
axel -n 30 https://github.com/prometheus-community/ipmi_exporter/releases/download/v1.4.0/ipmi_exporter-1.4.0.linux-amd64.tar.gz
tar xf ipmi_exporter-1.4.0.linux-amd64.tar.gz -C /usr/local/ && ln -sv /usr/local/ipmi_exporter-1.4.0.linux-amd64 /usr/local/ipmi
cd /usr/local/ipmi && curl -OL https://raw.githubusercontent.com/prometheus-community/ipmi_exporter/master/ipmi_remote.yml
vim ipmi_remote.yml --更改default下的用户名密码，用来抓取ipmi信息，帐户和密码是idrac的账户和密码
                user: "root"
                pass: "calvin"
[root@prometheus ipmi_exporter]# cat /usr/lib/systemd/system/ipmi_exporter.service 
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/ipmi_exporter/ipmi_exporter \
--config.file=/usr/local/ipmi_exporter/ipmi_remote.yml \
--web.listen-address=192.168.13.236:9290
Restart=on-failure
[Install]
WantedBy=multi-user.target
systemctl start ipmi_exporter.service && systemctl enable ipmi_exporter.service


#vmware_esxi
--config.env
VSPHERE_USER=root
VSPHERE_PASSWORD="secure password"
VSPHERE_HOST=192.168.13.242
VSPHERE_IGNORE_SSL=TRUE
VSPHERE_SPECS_SIZE=2000
--docker run
docker run -d  -p 9272:9272 --env-file config.env --name vmware_exporter pryorda/vmware_exporter
--prometheus.yml
  - job_name: 'vmware_exporter'
    metrics_path: '/metrics'
    consul_sd_configs:
    - server: '192.168.13.236:8500'
      services: [vmware_exporter]
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - regex: __meta_consul_service_metadata_(.+)
        action: labelmap
      - target_label: __address__
        replacement: 192.168.13.236:9272
--consul-vmware_exporter-192.168.13.242.json
{
  "Name": "vmware_exporter",
  "ID": "vmware_exporter-192.168.13.242",
  "Tags": [
    "vmware_exporter"
  ],
  "Address": "192.168.13.236",
  "Port": 9272,
  "Meta": {
    "app": "esxi01.rack05.idc01.hs.com",
    "env": "pro",
    "project": "Machine",
    "team": "ops"
  },
  "EnableTagOverride": false,
  "Check": {
    "HTTP": "http://192.168.13.236:9272/metrics",
    "Interval": "10s"
  },
  "Weights": {
    "Passing": 10,
    "Warning": 1
  }
}
--vmware_exporter.rule
------------------------
groups:
- name: vmware_exporterServiceAlert
  rules:
  - alert: vmware_exporterHostDown
    expr: up{job="vmware_esxi"} < 1
    for: 30s
    labels:
      severity: High
    annotations:
      summary: "Host Down"
      description: "team: {{ $labels.team }}, project: {{ $labels.project }}, job: {{ $labels.job }}, app: {{ $labels.app }}, instance: {{ $labels.instance }} Host is Down (current value: {{ $value }})"

  - alert: vmware_exporterHostMemoryAlert
    expr: vmware_host_memory_usage / vmware_host_memory_max * 100 > 95
    for: 30s
    labels:
      severity: High
    annotations:
      summary: "Memory Usage High"
      description: "team: {{ $labels.team }}, project: {{ $labels.project }}, job: {{ $labels.job }}, app: {{ $labels.app }}, instance: {{ $labels.instance }} Host Memory Usage great than 95% (current value: {{ $value }})"

  - alert: vmware_exporterHostDiskAlert
    expr: vmware_datastore_freespace_size /1024 /1024 /1024 < 50
    for: 30s
    labels:
      severity: High
    annotations:
      summary: "Disk Capacity Low"
      description: "team: {{ $labels.team }}, project: {{ $labels.project }}, job: {{ $labels.job }}, app: {{ $labels.app }}, instance: {{ $labels.instance }} Host Disk Capacity less than 50G (current value: {{ $value }})"

  - alert: vmware_exporterHostCPUAlert
    expr: vmware_host_cpu_usage / vmware_host_cpu_max * 100 > 85
    for: 30s
    labels:
      severity: High
    annotations:
      summary: "CPU Usate High"
      description: "team: {{ $labels.team }}, project: {{ $labels.project }}, job: {{ $labels.job }}, app: {{ $labels.app }}, instance: {{ $labels.instance }} Host CPU Usage great than 85% (current value: {{ $value }})"
------------------------
curl -X PUT -d @consul-esxi-192.168.13.242.json http://localhost:8500/v1/agent/service/register?replace-existing-check=1
curl -X POST http://localhost:9090/-/reload


----#监控haproxy
--下载配置haproxy_exporter
https://github.com/prometheus/haproxy_exporter/releases/download/v0.13.0/haproxy_exporter-0.13.0.linux-amd64.tar.gz
--有两种方式配置haproxy_exporter监控haproxy
1. 通过socket	2. 通过haproxy状态页，haproxy_exporter再转换为prometheus能识别的格式

--安装配置haproxy，通过socket方式监控haproxy
root@ha:~# cat /etc/haproxy/haproxy.cfg
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
        #stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats socket /run/lib/haproxy/haproxy.sock mode 660 level admin		#此行就是socket
        stats timeout 30s
        user haproxy
        group haproxy
        daemon
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3
defaults
        log     global
        mode    http
        option  httplog
        #mode tcp
        option  dontlognull
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http

listen k8s-apiserver-6443
  bind 172.168.2.12:6443
  mode tcp
  server k8s-master01 172.168.2.21:6443 check inter 3s fall 3 rise 5
  server k8s-master02 172.168.2.22:6443 check inter 3s fall 3 rise 5
  server k8s-master03 172.168.2.23:6443 check inter 3s fall 3 rise 5

listen prometheus-server-80
  bind 172.168.2.12:80
  mode http
  server 172.168.2.27 172.168.2.27:9090 check inter 3s fall 3 rise 5
---
root@ha:~# systemctl restart haproxy

--方式1：启动haproxy_exporter
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# ./haproxy_exporter --haproxy.scrape-uri=unix:/run/lib/haproxy/haproxy.sock

--方式2：启动haproxy_exporter
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# cat /etc/haproxy/haproxy.cfg
listen stats
  bind :9009
  stats enable
  #stats hide-version
  stats uri /haproxy-status
  stats realm HAPorxy\ Stats\ Page
  stats auth haadmin:123456
  stats auth admin:123456
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# systemctl restart haproxy
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# ./haproxy_exporter --haproxy.scrape-uri="http://haadmin:123456@127.0.0.1:9009/haproxy-status;csv" &
root@ha:/apps/haproxy_exporter-0.13.0.linux-amd64# ss -tnl | grep 9009
LISTEN   0         128                 0.0.0.0:9009             0.0.0.0:*

--配置prometheus-server
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
  - job_name: 'kubernetes-haproxy-server-metrics'
    static_configs:
    - targets: ["172.168.2.12:9101"]
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus

--haproxy模板367/2428



#----监控tomcat
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# cat Dockerfile
#FROM tomcat:8.5.73-jdk11-corretto
FROM tomcat:8.5.73

ADD server.xml /usr/local/tomcat/conf/server.xml	#tomcat配置文件，指定了站点目录/data/tomcat/webapps
RUN mkdir /data/tomcat/webapps -p
ADD myapp /data/tomcat/webapps/myapp
ADD metrics.war /data/tomcat/webapps		#metrics.war包放到站点目录，会暴露/metrics URL，主要看内存异常，session信息
ADD simpleclient-0.8.0.jar  /usr/local/tomcat/lib/		#下面的所有jar包放到tomcat lib目录或者java的lib目录，metrics.war运行的时候需要加载，这些jar可以去gitlab上查找
ADD simpleclient_common-0.8.0.jar /usr/local/tomcat/lib/
ADD simpleclient_hotspot-0.8.0.jar /usr/local/tomcat/lib/
ADD simpleclient_servlet-0.8.0.jar /usr/local/tomcat/lib/
ADD tomcat_exporter_client-0.0.12.jar /usr/local/tomcat/lib/
EXPOSE 8080 8443 8009
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# cat run_tomcat.sh
#!/bin/bash
echo "1.1.1.1 www.a.com" >> /etc/hosts
su - magedu -c "/apps/tomcat/bin/catalina.sh start"
tail -f /etc/hosts
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# cat build-command.sh
#!/bin/bash
docker build -t 192.168.13.197:8000/magedu/tomcat-app1:v1 .
docker push 192.168.13.197:8000/magedu/tomcat-app1:v1
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/tomcat-image# ./build-command.sh		#构建镜像

--在k8s运行tomcat
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/yaml# cat tomcat-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tomcat-deployment
  namespace: default
spec:
  selector:
    matchLabels:
     app: tomcat
  replicas: 1 # tells deployment to run 2 pods matching the template
  template: # create pods using pod definition in this template
    metadata:
      labels:
        app: tomcat
      annotations:
        prometheus.io/scrape: 'true'
    spec:
      containers:
      - name: tomcat
        image: 192.168.13.197:8000/magedu/tomcat-app1:v1
        ports:
        - containerPort: 8080
        securityContext:
          privileged: true
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/yaml# cat tomcat-svc.yaml
kind: Service  #service 类型
apiVersion: v1
metadata:
#  annotations:
#    prometheus.io/scrape: 'true'
  name: tomcat-service
spec:
  selector:
    app: tomcat
  ports:
  - nodePort: 31080
    port: 80
    protocol: TCP
    targetPort: 8080
  type: NodePort
---
root@k8s-master01:~/k8s/yaml/prometheus-case/app-monitor-case/tomcat/yaml# kubectl apply -f .

--配置prometheus增加tomcat的监控
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
  - job_name: 'kubernetes-tomcat-metrics'
    static_configs:
    - targets: ["172.168.2.21:31080"]
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus
导入tomcat-模板














#联邦集群
主prometheus:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true			#不重写源 Prometheus 服务暴露的标签
    metrics_path: '/federate'
    params:
      'match[]':
       - '{job=~"aliyun-node_exporter|aliyun-docker"}'
    static_configs:
    - targets: ['10.10.10.230:9090']
      labels:
        prometheus: "aliyun"

子prometheus:
[ops0799@jumpserver /usr/local/prometheus]$ cat prometheus.yml
global:
  scrape_interval:     15s 
  evaluation_interval: 15s 
scrape_configs:  
  - job_name: 'aliyun-prometheus'  
    static_configs:               
    - targets: ['127.0.0.1:9090'] 
      labels:
        app: "aliyun-prometheus_server"

  - job_name: 'aliyun-node_exporter'
    static_configs:
    - targets:
      - '192.168.0.42:9100'
      labels:
        app: "aliyun-node_exporter"

  - job_name: 'aliyun-docker'
    static_configs:
    - targets:
      - '192.168.0.42:7070'
      labels:
        app: "aliyun-docker"


#prometheus2.19.3升级到prometheus2.33.4
tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
cd /usr/local/
cp -r prometheus/prometheus.yml prometheus-2.33.4.linux-amd64/
\cp -a prometheus/tsdb prometheus-2.33.4.linux-amd64/
\cp -a prometheus/rules /usr/local/prometheus/
chown -R prometheus.prometheus prometheus-2.33.4.linux-amd64/
systemctl stop prometheus
rm -rf /usr/local/prometheus
ln -sv prometheus-2.33.4.linux-amd64/ prometheus
systemctl start prometheus


----202204062300
----#prometheus联绑集群
环境：
172.168.2.27	prometheus-server
172.168.2.28	prometheus-federate01
172.168.2.29	prometheus-federate02
172.168.2.21 172.168.2.22 172.168.2.23	node-exporter for prometheus-federate01
172.168.2.24 172.168.2.25 172.168.2.26	192.168.13.63	node-exporter for prometheus-federate02

--------安装
----prometheus-server
root@prometheus01:/usr/local/src# tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
root@prometheus01:/usr/local/src# ln -sv /usr/local/prometheus-2.33.4.linux-amd64/ /usr/local/prometheus
root@prometheus01:/usr/local/src# groupadd -r prometheus
root@prometheus01:/usr/local/src# useradd  -r -g prometheus -s /sbin/nologin -M prometheus
root@prometheus01:/usr/local/src# mkdir -p /var/lib/prometheus
root@prometheus01:/usr/local/src# chown -R prometheus.prometheus /usr/local/prometheus-2.33.4.linux-amd64/ /var/lib/prometheus
root@prometheus01:/usr/local/src# cat >> /lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=90d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://172.169.2.27:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=HomsomMonitor
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
------
root@prometheus01:/usr/local/src# systemctl daemon-reload
sroot@prometheus01:/usr/local/src# systemctl restart prometheus.service
root@prometheus01:/usr/local/src# systemctl status prometheus.service | grep Active
   Active: active (running) since Wed 2022-04-06 22:10:55 CST; 19s ago

----prometheus-federate01
root@prometheus02:/usr/local/src# tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
root@prometheus02:/usr/local/src# ln -sv /usr/local/prometheus-2.33.4.linux-amd64/ /usr/local/prometheus
root@prometheus02:/usr/local/src# groupadd -r prometheus
root@prometheus02:/usr/local/src# useradd  -r -g prometheus -s /sbin/nologin -M prometheus
root@prometheus02:/usr/local/src# mkdir -p /var/lib/prometheus
root@prometheus02:/usr/local/src# chown -R prometheus.prometheus /usr/local/prometheus-2.33.4.linux-amd64/ /var/lib/prometheus
root@prometheus02:/usr/local/src# cat >> /lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=90d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://172.169.2.28:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=HomsomMonitor
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
------
root@prometheus02:/usr/local/src# systemctl daemon-reload
sroot@prometheus02:/usr/local/src# systemctl restart prometheus.service
root@prometheus02:/usr/local/src# systemctl status prometheus.service | grep Active
   Active: active (running) since Wed 2022-04-06 22:16:55 CST; 19s ago


----prometheus-federate02
root@prometheus03:/usr/local/src# tar xf prometheus-2.33.4.linux-amd64.tar.gz -C /usr/local/
root@prometheus03:/usr/local/src# ln -sv /usr/local/prometheus-2.33.4.linux-amd64/ /usr/local/prometheus
root@prometheus03:/usr/local/src# groupadd -r prometheus
root@prometheus03:/usr/local/src# useradd  -r -g prometheus -s /sbin/nologin -M prometheus
root@prometheus03:/usr/local/src# mkdir -p /var/lib/prometheus
root@prometheus03:/usr/local/src# chown -R prometheus.prometheus /usr/local/prometheus-2.33.4.linux-amd64/ /var/lib/prometheus
root@prometheus03:/usr/local/src# cat >> /lib/systemd/system/prometheus.service << EOF
[Unit]
Description=https://prometheus.io
After=network-online.target
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus/prometheus \
--config.file /usr/local/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--storage.tsdb.retention.time=90d \
--storage.tsdb.retention.size=100GB \
--storage.tsdb.wal-compression \
--web.external-url=http://172.169.2.29:9090 \
--web.enable-admin-api \
--web.enable-lifecycle \
--web.page-title=HomsomMonitor
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
root@prometheus03:/usr/local/src# systemctl daemon-reload
root@prometheus03:/usr/local/src# systemctl restart prometheus.service
root@prometheus03:/usr/local/src# systemctl status prometheus.service | grep Active
   Active: active (running) since Wed 2022-04-06 22:21:32 CST; 4s ago


-------配置
----prometheus-federate01
root@prometheus02:/usr/local/prometheus# cat prometheus.yml
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "kubernetes-master-metrics"
    file_sd_configs:
    - files:
      - /usr/local/prometheus/file_sd_configs/*.json
      refresh_interval: 10s
---
root@prometheus02:/usr/local/prometheus# mkdir -p /usr/local/prometheus/file_sd_configs
root@prometheus02:/usr/local/prometheus# cat /usr/local/prometheus/file_sd_configs/kubernetes-master.json
[
  {
    "targets": ["172.168.2.21:9100","172.168.2.22:9100"]
  }
]
root@prometheus02:/usr/local/prometheus# curl -X POST http://localhost:9090/-/reload

----prometheus-federate02
root@prometheus03:/usr/local/prometheus# cat prometheus.yml
global:
  scrape_interval: 15s 
  evaluation_interval: 15s 

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "kubernetes-node-metrics"
    file_sd_configs:
    - files:
      - /usr/local/prometheus/file_sd_configs/*.json
      refresh_interval: 10s
---
root@prometheus03:/usr/local/prometheus# mkdir -p /usr/local/prometheus/file_sd_configs
root@prometheus03:/usr/local/prometheus# cat /usr/local/prometheus/file_sd_configs/kubernetes-node.json
[
  {
    "targets": ["172.168.2.24:9100","172.168.2.25:9100"]
  }
]
root@prometheus03:/usr/local/prometheus# curl -X POST http://localhost:9090/-/reload

----prometheus-server
root@prometheus01:/usr/local/prometheus# cat prometheus.yml | head -n 40
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
rule_files:

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "prometheus-federate01-172.168.2.28"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      - '{job="prometheus"}'			#这个是匹配job="prometheus"的，本机有所以不会覆盖本机，没有才会抓取
      - '{__name__=~"job:.*"}'			这个是匹配指标是job:开头的
      - '{__name__=~"node.*"}'			#这个是匹配指标是node开头的
    static_configs:
    - targets: ["172.168.2.28:9090"]

  - job_name: "prometheus-federate02-172.168.2.29"
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
      - '{job="prometheus"}'
      - '{__name__=~"job:.*"}'
      - '{__name__=~"node.*"}'
    static_configs:
    - targets: ["172.168.2.29:9090"]
---
root@prometheus01:/usr/local/prometheus# curl -X POST http://localhost:9090/-/reload

----grafana导入模板11074(node-exporter for EN)/8919(node-exporter for CN)

----prometheus-federate01和prometheus-federate02增加主机，prometheus-server不用配置自动发现主机
root@prometheus02:/usr/local/prometheus/file_sd_configs# cat kubernetes-master.json
[
  {
    "targets": ["172.168.2.21:9100","172.168.2.22:9100","172.168.2.23:9100"]			#再增加一个master
  }
]
root@prometheus03:/usr/local/prometheus/file_sd_configs# cat kubernetes-node.json
[
  {
    "targets": ["172.168.2.24:9100","172.168.2.25:9100","172.168.2.26:9100","192.168.13.63:9100"]
  }
]
root@prometheus02:/usr/local/prometheus/file_sd_configs# curl -XPOST http://localhost:9090/-/reload  		 #此时联绑server(prometheus-server)最大等待10s+15s=25s时间就可以查看到增加的master节点





</pre>

