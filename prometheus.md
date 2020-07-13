#prometheus
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
--------------
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
-storage.local.retention 168h0m0s \
-storage.local.max-chunks-to-persist 3024288 \
-storage.local.memory-chunks=50502740 \
-storage.local.num-fingerprint-mutexes=300960
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
第二部分
监控物理机/虚拟机(linux)
推荐ID
8919
9276
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
increase(): 是用来针对Counter这种类型持续增长的数值，截取其中一段时间的总增量
例如：increase(node_network_receive_bytes_total[1m])  #这样就获取了网络总使用时间在1分钟内的总增量
注：什么时候用rate函数，什么时候用increase函数。increase一般采集不是详细的数据，比较粗糙。rate一般用于比较细的数据，瞬息万变的，例如：cpu，内存，硬盘，Io网络流量
sum(): 起到加合的作用,多核cpu相加的平均值，没有特定数据类型
例如：sum(rate(node_network_receive_bytes_total[1m])) by(instance) #外面套用了一个sum即可把所有网络接收流量接口的值加合平均显示，不会看到杂乱了。by()中的instance是表示对每个机器进行拆分。by(cluster_name)是对每个集群进行抓分，cluster_name需要我们自定义标签，node_exporter是没有办法提供的
by(instance): 这个函数可以把sum加合到一起的数值按照指定的一个方式进行一层的拆分，没有特定数据类型，通常结合sum函数一起使用
topk(): Gauge类型数据和Counter类型数据使用
例：topk(1,rate(node_network_receive_bytes_total[1m])) #topk因为对于每一个时间点都只取前几高的数值，那么必然会造成单个机器的采集数据不连贯。实际使用的时候，一般用topk()进行瞬时报警，而不是为了观察曲线图。
count(): 把数值符合条件的，输出数目进行加合。一般使用它进行模糊的监控判断，例如，当cpu(或连接数)高于80%的机器大于30台就报警
例如：count(count_netstat_wait_connections > 200) #找出当前（或历史）当TCP等待数大于200的机器数量
predict_linear(): 可以起到对曲线变化速率的计算，以及在一段时间加速度的预测。用得不是很多

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
1. 其实只 服务器不宕机，那么基本上pushgateway运行还是很稳定的。就算有太多的脚本同时都发送给一个pushgateway，其实也只是接收的速度会慢，丢数据没有遇到过。
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
