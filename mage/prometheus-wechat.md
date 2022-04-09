#prometheus-wechat告警

----#dingtalk告警
DownloadURL: https://github.com/timonwong/prometheus-webhook-dingtalk/releases/download/v1.4.0/prometheus-webhook-dingtalk-1.4.0.linux-amd64.tar.gz
１. 安装 
root@prometheus01:/usr/local/src# tar xf prometheus-webhook-dingtalk-1.4.0.linux-amd64.tar.gz -C /usr/local/
root@prometheus01:/usr/local# ln -sv prometheus-webhook-dingtalk-1.4.0.linux-amd64/ prometheus-webhook-dingtalk
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# cat config.yml

2. 服务配置文件
--配置prometheus-webhook-dingtalk服务
./prometheus-webhook-dingtalk --web.listen-address="0.0.0.0:8060" --ding.profile="dingding=https://oapi.dingtalk.com/robot/send?access_token=8e182e1791d67431a8ff1a421b4e2de2dfcb34eb07d5ab3b522cfa10"
#注：profile=dingding，所以alertmanager调用的时候也需要写profile名称dingding，例如'http://172.168.2.27:8060/dingtalk/dingding/send'

----或者
targets:
  dingding:
    url: https://oapi.dingtalk.com/robot/send?access_token=8e182e1791d67431a8ff1a421b4e2de2dfcb34eb07d5ab3b521e0
---
# /lib/systemd/system/prometheus-webhook-dingtalk.service
[Unit]
Description=https://github.com/timonwong/prometheus-webhook-dingtalk
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/prometheus-webhook-dingtalk/prometheus-webhook-dingtalk \
--config.file /usr/local/prometheus-webhook-dingtalk/config.yml \
--web.enable-lifecycle \
--web.listen-address "0.0.0.0:8060"
Restart=on-failure

[Install]
WantedBy=multi-user.target
---

3. 启动服务
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl daemon-reload
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl restart prometheus-webhook-dingtalk.service
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl enable prometheus-webhook-dingtalk.service
root@prometheus01:/usr/local/prometheus-webhook-dingtalk# systemctl status prometheus-webhook-dingtalk.service | grep Active
   Active: active (running) since Fri 2022-04-08 14:36:33 CST; 7s ago
#root@prometheus01:/usr/local/prometheus-webhook-dingtalk# curl -XPOST http://localhost:8060/-/reload	#后面可使用此方法重载，因为服务配置加入web.enable-lifecycle

----配置alertmanager
root@prometheus01:/usr/local/alertmanager# cat alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.qiye.163.com:465'
  smtp_hello: '@163.com'
  smtp_from: 'prometheus@domaim.com'
  smtp_auth_username: 'prometheus@domain.com'
  smtp_auth_password: 'password'
templates:
  - '/usr/local/alertmanager/email.tmpl'
route:
  receiver: 'dingding'		#配置告警通知时，最好将告警方式配置在这里，这里表示没有匹配到的告警将由此方式发出
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 1s
  repeat_interval: 4h
  routes:
  - receiver: 'dingding'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
  - receiver: 'email'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
receivers:
- name: 'email'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "email.html" . }}'
    send_resolved: true
- name: 'dingding'
  webhook_configs:
  - url: 'http://172.168.2.27:8060/dingtalk/dingding/send'
    send_resolved: true
inhibit_rules:
  - source_match:
      alertname: linuxNodeDown
    target_match:
      job: blackboxProbeFailure
    equal:
      - ops
---
--配置prometheus告警规则
root@prometheus01:/usr/local/prometheus/rules# cat /usr/local/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - '172.168.2.27:9093'
rule_files:
  - rules/*.rule

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
      - '{job="prometheus"}'
      - '{__name__=~"job:.*"}'
      - '{__name__=~"node.*"}'
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
root@prometheus01:/usr/local/prometheus/rules# cat test.rule
groups:
- name: linuxHostStatusAlert
  rules:
  - alert: linuxHostCPUUsageAlert
    expr: avg(rate(node_cpu_seconds_total{mode="system"}[5m])) by (instance) *100 >7
    for: 30s
    labels:
      severity: warnning
    annotations:
      summary: "Host CPU[5m] usage High"
      description: "instance: {{ $labels.instance }} CPU Usage above 85%/5m (current value: {{ $value }})"
---
root@prometheus01:/usr/local/prometheus/rules# curl -X POST http://localhost:9090/-/reload

4. 测试钉钉是否成功收取到消息


----#企业微信告警
----注册企业微信，可以取一个企业名称，主要是手机号绑定，不用实名也可以的，但不能违法，然后在应用管理——应用——创建一个机器人，获取AgentId和Secret，企业ID——在我的企业中获取，信息如下：
企业ID: ww51a66e1695615e
AgentId: 100002
Secret: G-mb4SP5Xn-Id75f99NrFGMjHrfbYzIkDLcbi

root@prometheus01:/usr/local/alertmanager# cat wechat-new.tmpl		#微信模板
{{ define "wechat.default.message" }}
{{ range $i, $alert :=.Alerts }}
===alertmanager 监控报警===
告警状态：{{ .Status }}
告警主题: {{ $alert.Annotations.summary }}
告警级别：{{ $alert.Labels.severity }}
告警类型：{{ $alert.Labels.alertname }}
故障主机: {{ $alert.Labels.instance }}
告警详情: {{ $alert.Annotations.description }}
触发时间: {{ $alert.StartsAt.Format "2006-01-02 15:04:05" }}
===========end============
{{ end }}
{{ end }}
-----
root@prometheus01:/usr/local/alertmanager# cat email.tmpl			#邮件模板
{{ define "email.to" }}jack@domain.com{{ end }}
{{ define "email.html" }}
{{ range .Alerts }}
 <pre>
状态：{{   .Status }}
实例: {{ .Labels.instance }}
信息: {{ .Annotations.summary }}
详情: {{ .Annotations.description }}
时间: {{ (.StartsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}
 </pre>
{{ end }}
{{ end }}
---

--alertmanagre增加配置即可
root@prometheus01:/usr/local/alertmanager# cat alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_require_tls: false
  smtp_smarthost: 'smtp.qiye.163.com:465'
  smtp_hello: '@163.com'
  smtp_from: 'prometheus@domaim.com'
  smtp_auth_username: 'prometheus@domain.com'
  smtp_auth_password: 'password'
templates:
  - '/usr/local/alertmanager/email.tmpl'
  - '/usr/local/alertmanager/wechat-new.tmpl'
route:
  receiver: 'webhook'
  group_by: ['alertname']
  group_wait: 5s
  group_interval: 1s
  repeat_interval: 4h
  routes:
  - receiver: 'dingding'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
  - receiver: 'wechat'
    group_wait: 5s
    continue: true
    match_re:
      alertname: .*[a-z].*
receivers:
- name: 'email'
  email_configs:
  - to: '{{ template "email.to" . }}'
    html: '{{ template "email.html" . }}'
    send_resolved: true
- name: 'dingding'
  webhook_configs:
  - url: 'http://172.168.2.27:8060/dingtalk/dingding/send'
    send_resolved: true
- name: 'wechat'
  wechat_configs:
  - corp_id: ww51a66e1695615e
    to_user: '@all'
    agent_id: 100002
    api_secret: G-mb4SP5Xn-Id75MjHrfbYzIkDLcbiLkunX0
    send_resolved: true
inhibit_rules:
  - source_match:
      alertname: linuxNodeDown
    target_match:
      job: blackboxProbeFailure
    equal:
      - ops
-----

--最后测试企业微信是否收到测试消息即可


#alertmanager高可用
第一种：prometheus-server01	------------|		   | alertmanager01	---------|	
										lvs--------							dingding,wechat,email
		prometheus-server02	------------|		   | alertmanager02 ---------|
注：后面装两个alertmanager，因为基于Alertmanager的告警分组机制即使不同的Prometheus Sever分别发送相同的告警给Alertmanager，Alertmanager也可以自动将这些告警合并为一个通知向receiver发送。会自动去重，所以为会发送重复的告警到后端告警媒介，lvs需要有健康检查功能。需要使用源地址哈希功能，sh算法

第二种：prometheus-server01	------------|		   | alertmanager01	---------|	
										|----------| alertmanager02	---------|dingding,wechat,email
		prometheus-server02	------------|		   | alertmanager03 ---------|
注：alertmanagr集群运行gossip协议，会自动去重


----#部署alertmanager集群
为了能够让Alertmanager节点之间进行通讯，需要在Alertmanager启动时设置相应的参数。其中主要的参数包括：
--cluster.listen-address string: 当前实例集群服务监听地址
--cluster.peer value: 初始化时关联的其它实例的集群服务地址

--3个节点部署alertmanager
root@prometheus:/usr/local/src# tar xf alertmanager-0.23.0.linux-amd64.tar.gz -C /usr/local/
root@prometheus:/usr/local/src# chown -R prometheus.prometheus /usr/local/alertmanager-0.23.0.linux-amd64/
root@prometheus:/usr/local/src# ln -sv /usr/local/alertmanager-0.23.0.linux-amd64/ /usr/local/alertmanager

--alertmanager01
/usr/local/alertmanager/alertmanager  --web.listen-address=":9093" --cluster.listen-address="172.168.2.27:8001" --config.file=/usr/local/alertmanager/alertmanager.yml  --storage.path=/usr/local/alertmanager/data/

--alertmanager02
/usr/local/alertmanager/alertmanager  --web.listen-address=":9093" --cluster.listen-address="172.168.2.28:8001" --cluster.peer=172.168.2.27:8001 --config.file=/usr/local/alertmanager/alertmanager.yml  --storage.path=/usr/local/alertmanager/data/

--alertmanager03
/usr/local/alertmanager/alertmanager  --web.listen-address=":9093" --cluster.listen-address="172.168.2.29:8001"  --cluster.peer=172.168.2.27:8001 --config.file=/usr/local/alertmanager/alertmanager.yml  --storage.path=/usr/local/alertmanager/data/
#去其中一台alertmanager查看集群状态


---服务方式启动
root@prometheus01:/usr/local/alertmanager# cat /lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://172.168.2.27:9093 \
--web.listen-address="0.0.0.0:9093" --cluster.listen-address="172.168.2.27:8001"
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
root@prometheus02:/usr/local/alertmanager# cat /lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://172.168.2.28:9093 \
--web.listen-address="0.0.0.0:9093" --cluster.listen-address="172.168.2.28:8001" --cluster.peer=172.168.2.27:8001
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
root@prometheus03:/usr/local/alertmanager# cat /lib/systemd/system/alertmanager.service
[Unit]
Description=https://prometheus.io
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/alertmanager/alertmanager --config.file=/usr/local/alertmanager/alertmanager.yml \
--storage.path=/usr/local/alertmanager/data/ --web.external-url=http://172.168.2.29:9093 \
--web.listen-address="0.0.0.0:9093" --cluster.listen-address="172.168.2.29:8001" --cluster.peer=172.168.2.28:8001
Restart=on-failure

[Install]
WantedBy=multi-user.target
---
root@prometheus:/usr/local/alertmanager# systemctl daemon-reload
root@prometheus:/usr/local/alertmanager# systemctl restart alertmanager.service



--配置prometheus增加alertmanager地址
root@prometheus01:/usr/local/alertmanager# cat /usr/local/prometheus/prometheus.yml
alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - '172.168.2.27:9093'
          - '172.168.2.28:9093'
          - '172.168.2.29:9093'
	
	
	

####promtheus远端存储----victoriametrics
DownloadURL: https://github.com/VictoriaMetrics/VictoriaMetrics
单机版下载：https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.76.0/victoria-metrics-amd64-v1.76.0.tar.gz
集群版下载：https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.76.0/victoria-metrics-amd64-v1.76.0-cluster.tar.gz

####单机部署
参数：
-httpListenAddr=0.0.0.0:8428 #监听地址及端口
-storageDataPath #VictoriaMetrics 将所有数据存储在此目录中，默认为执行启动 victoria 的当前目录下
的 victoria-metrics-data 目录中。
-retentionPeriod #存储数据的保留，较旧的数据会自动删除，默认保留期为 1 个月，默认单位为 m(月)，
支持的单位有 h (hour), d (day), w (week), y (year)。

1. 安装运行
root@prometheus01:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0.tar.gz
root@prometheus01:/usr/local/src# chown -R prometheus.prometheus /usr/local/src/victoria-data/
root@prometheus01:/usr/local/src# chmod -R 775 /usr/local/src/victoria-data/	
root@prometheus01:/usr/local/src# ./victoria-metrics-prod -httpListenAddr=0.0.0.0:8428 -storageDataPath=/usr/local/src/victoria-data -retentionPeriod=3

2. 配置prometheus
root@prometheus01:~# cd /usr/local/prometheus
root@prometheus01:/usr/local/prometheus# vim prometheus.yml
remote_write:
- url: http://172.168.2.27:8428/api/v1/write
root@prometheus01:/usr/local/prometheus# systemctl restart prometheus
注：prometheus虽然往远端存储上写入数据，但是tsdb配置不能删除，否则会在/data/目录下生成tsdb目录

3. 测试数据是否在维多利亚存储成功
访问维多利亚：http://172.168.2.27:8428/
在UI查看数据是否存储成功：http://172.168.2.27:8428/vmui






####集群部署
组件介绍：
vminsert	#写入组件(写)，vminsert 负责接收数据写入并根据对度量名称及其所有标签的一致 hash 结果将数据分散写入不同的后端 vmstorage 节点之间 vmstorage，vminsert 默认端口 8480
vmstorage 	#存储原始数据并返回给定时间范围内给定标签过滤器的查询数据，默认端口 8482
vmselect 	#查询组件(读)，连接 vmstorage ，默认端口 8481
注：远端存储只部署以上3个组件即可

其它可选组件：
vmagent	#是一个很小但功能强大的代理，它可以从 node_exporter 各种来源收集度量数据，并将它们存 储 在 VictoriaMetrics 或 任 何 其 他 支 持 远 程 写 入 协 议 的 与 prometheus 兼 容 的 存 储 系 统 中 ， 有 替 代prometheus server 的意向。
vmalert： 替换 prometheus server，以 VictoriaMetrics 为数据源，基于兼容 prometheus 的告警规则，判断数据是否异常，并将产生的通知发送给 alertermanager
Vmgateway： 读写 VictoriaMetrics 数据的代理网关，可实现限速和访问控制等功能，目前为企业版组件
vmctl： VictoriaMetrics 的命令行工具，目前主要用于将 prometheus、opentsdb 等数据源的数据迁移到VictoriaMetrics。

vmstorage-prod主要参数：
-httpListenAddr string
Address to listen for http connections (default ":8482")
-vminsertAddr string
TCP address to accept connections from vminsert services (default ":8400")
-vmselectAddr string
TCP address to accept connections from vmselect services (default ":8401")



1. 安装部署vmstorage-prod:
----node01:
root@prometheus01:/usr/local/src# tar -tvf victoria-metrics-amd64-v1.76.0-cluster.tar.gz
-rwxr-xr-x valyala/valyala 11454200 2022-04-07 20:51 vminsert-prod
-rwxr-xr-x valyala/valyala 12511560 2022-04-07 20:52 vmselect-prod
-rwxr-xr-x valyala/valyala 11784736 2022-04-07 20:52 vmstorage-prod
root@prometheus01:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0-cluster.tar.gz -C /usr/local/bin/
root@prometheus01:/usr/local/src# cat /lib/systemd/system/vmstorage.service
[Unit]
Description=Vmstorage Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmstorage-prod -loggerTimezone Asia/Shanghai -storageDataPath /data/vmstorage-data -httpListenAddr :8482 -vminsertAddr :8400 -vmselectAddr :8401

[Install]
WantedBy=multi-user.target
---
root@prometheus01:/usr/local/src# systemctl daemon-reload && systemctl enable vmstorage.service && systemctl start vmstorage.service
root@prometheus01:/usr/local/src# ss -tnl | grep :84
LISTEN   0         128                 0.0.0.0:8482             0.0.0.0:*		#vmstorage端口
LISTEN   0         128                 0.0.0.0:8400             0.0.0.0:*		#提供vminsert写入端口
LISTEN   0         128                 0.0.0.0:8401             0.0.0.0:*		#提供vmselect读取端口

----node02:
root@prometheus02:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0-cluster.tar.gz -C /usr/local/bin/
root@prometheus02:/usr/local/src# cat /lib/systemd/system/vmstorage.service
[Unit]
Description=Vmstorage Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmstorage-prod -loggerTimezone Asia/Shanghai -storageDataPath /data/vmstorage-data -httpListenAddr :8482 -vminsertAddr :8400 -vmselectAddr :8401

[Install]
WantedBy=multi-user.target
---
root@prometheus02:/usr/local/src# systemctl daemon-reload && systemctl enable vmstorage.service && systemctl start vmstorage.service
root@prometheus02:/usr/local/src# ss -tnl | grep :84
LISTEN   0         128                 0.0.0.0:8482             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8400             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8401             0.0.0.0:*

----node03:
root@prometheus03:/usr/local/src# tar xf victoria-metrics-amd64-v1.76.0-cluster.tar.gz -C /usr/local/bin/
root@prometheus03:/usr/local/src# cat /lib/systemd/system/vmstorage.service
[Unit]
Description=Vmstorage Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmstorage-prod -loggerTimezone Asia/Shanghai -storageDataPath /data/vmstorage-data -httpListenAddr :8482 -vminsertAddr :8400 -vmselectAddr :8401

[Install]
WantedBy=multi-user.target
---
root@prometheus03:/usr/local/src# systemctl daemon-reload && systemctl enable vmstorage.service && systemctl start vmstorage.service
root@prometheus03:/usr/local/src# ss -tnl | grep :84
LISTEN   0         128                 0.0.0.0:8400             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8401             0.0.0.0:*
LISTEN   0         128                 0.0.0.0:8482             0.0.0.0:*


2. 安装部署vminsert-prod:
----node01
root@prometheus01:/usr/local/src# cat /lib/systemd/system/vminsert.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -storageNode=172.168.2.27:8400,172.168.2.28:8400,172.168.2.29:8400

[Install]
WantedBy=multi-user.target
---
root@prometheus01:/usr/local/src# systemctl daemon-reload && systemctl enable vminsert.service && systemctl start vminsert.service
root@prometheus01:/usr/local/src# ss -tnl | grep :8480
LISTEN   0         128                 0.0.0.0:8480             0.0.0.0:*

----node02
root@prometheus02:/usr/local/src# cat /lib/systemd/system/vminsert.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -storageNode=172.168.2.27:8400,172.168.2.28:8400,172.168.2.29:8400

[Install]
WantedBy=multi-user.target
root@prometheus02:/usr/local/src# systemctl daemon-reload && systemctl enable vminsert.service && systemctl start vminsert.service
root@prometheus02:/usr/local/src# ss -tnl | grep :8480
LISTEN   0         128                 0.0.0.0:8480             0.0.0.0:*

----node03
root@prometheus03:/usr/local/src# cat /lib/systemd/system/vminsert.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vminsert-prod -httpListenAddr :8480 -storageNode=172.168.2.27:8400,172.168.2.28:8400,172.168.2.29:8400

[Install]
WantedBy=multi-user.target
root@prometheus03:/usr/local/src# systemctl daemon-reload && systemctl enable vminsert.service && systemctl start vminsert.service
root@prometheus03:/usr/local/src# ss -tnl | grep :8480
LISTEN   0         128                 0.0.0.0:8480             0.0.0.0:*


3. 安装部署vmselect-prod:
----node01
root@prometheus01:/usr/local/src# cat /lib/systemd/system/vmselect.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmselect-prod -httpListenAddr :8481 -storageNode=172.168.2.27:8401,172.168.2.28:8401,172.168.2.29:8401

[Install]
WantedBy=multi-user.target
---
root@prometheus01:/usr/local/src# systemctl daemon-reload && systemctl enable vmselect.service && systemctl start vmselect.service
root@prometheus01:/usr/local/src# ss -tnl | grep :8481
LISTEN   0         128                 0.0.0.0:8481             0.0.0.0:*

----node02
root@prometheus02:/usr/local/src# cat /lib/systemd/system/vmselect.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmselect-prod -httpListenAddr :8481 -storageNode=172.168.2.27:8401,172.168.2.28:8401,172.168.2.29:8401

[Install]
WantedBy=multi-user.target
---
root@prometheus02:/usr/local/src# systemctl daemon-reload && systemctl enable vmselect.service && systemctl start vmselect.service
root@prometheus02:/usr/local/src# ss -tnl | grep :8481
LISTEN   0         128                 0.0.0.0:8481             0.0.0.0:*

----node03
root@prometheus03:/usr/local/src# cat /lib/systemd/system/vmselect.service
[Unit]
Description=Vminsert Server
After=network.target

[Service]
Restart=on-failure
WorkingDirectory=/tmp
ExecStart=/usr/local/bin/vmselect-prod -httpListenAddr :8481 -storageNode=172.168.2.27:8401,172.168.2.28:8401,172.168.2.29:8401

[Install]
WantedBy=multi-user.target
---
root@prometheus03:/usr/local/src# systemctl daemon-reload && systemctl enable vmselect.service && systemctl start vmselect.service
root@prometheus03:/usr/local/src# ss -tnl | grep :8481
LISTEN   0         128                 0.0.0.0:8481             0.0.0.0:*

4. 验证服务端口
root@prometheus01:/usr/local/src# curl http://172.168.2.27:8480/metrics
root@prometheus01:/usr/local/src# curl http://172.168.2.27:8481/metrics
root@prometheus01:/usr/local/src# curl http://172.168.2.27:8482/metrics


5. 配置prometheus写入到vmstorage
root@prometheus01:/usr/local/prometheus# cat prometheus.yml
remote_write:
- url: http://172.168.2.27:8480/insert/1/prometheus				
- url: http://172.168.2.28:8480/insert/1/prometheus
- url: http://172.168.2.29:8480/insert/1/prometheus
注：#http://172.168.2.27:8480/insert此为固定地址，1/prometheus此为自定义地址，查询时应对此自定义地址，查询地址路径应为：http://172.168.2.27:8481/select/1/prometheus，是无状态的，在前面可加LB，默认情况下，数据被 vminsert 的组件基于 hash 算法分别将数据持久化到不同的vmstorage节点，一个数据会被拆分成N分在vmstorage节点，提高读写性能
root@prometheus01:/usr/local/prometheus# systemctl stop prometheus
root@prometheus01:/usr/local/prometheus# systemctl start prometheus

6. 在grafana配置prometheus数据源为vmselect，从vmselect读取数据，无状态，前面应有LB
添加一个新的prometheus源，名称为：Prometheus-victoriametrics-cluster，地址为：http://172.168.2.27:8481/select/1/prometheus
新添加模板选定数据源为新添加的Prometheus-victoriametrics-cluster，再看是否有数据


7. 开启数据复制（可选）
默认情况下，数据被 vminsert 的组件基于 hash 算法分别将数据持久化到不同的vmstorage 节点，一个数据被拆分成多份。可以启用 vminsert 组件支持的-replicationFactor=N 复制功能，将数据分别在各节点保存一份完整的副本以实现数据的高可用。


	