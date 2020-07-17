#JumpServer

<pre>
REFERENCE: https://docs.jumpserver.org/zh/master/install/docker_install/

介绍：
JumpServer 是全球首款完全开源的堡垒机, 使用 GNU GPL v2.0 开源协议, 是符合 4A 的专业运维审计系统。
JumpServer 使用 Python / Django 进行开发, 遵循 Web 2.0 规范, 配备了业界领先的 Web Terminal 解决方案, 交互界面美观、用户体验好。
JumpServer 采纳分布式架构, 支持多机房跨区域部署, 中心节点提供 API, 各机房部署登录节点, 可横向扩展、无并发访问限制。
JumpServer 现已支持管理 SSH、 Telnet、 RDP、 VNC 协议资产。
改变世界, 从一点点开始。

特色优势：
开源: 零门槛，线上快速获取和安装；
分布式: 轻松支持大规模并发访问；
无插件: 仅需浏览器，极致的 Web Terminal 使用体验；
多云支持: 一套系统，同时管理不同云上面的资产；
云端存储: 审计录像云端存储，永不丢失；
多租户: 一套系统，多个子公司和部门同时使用。

环境要求：
硬件配置: 2个CPU核心, 4G 内存, 50G 硬盘（最低）
操作系统: Linux 发行版 x86_64
Python = 3.6.x
Mysql Server ≥ 5.6
Mariadb Server ≥ 5.5.56
Redis


#容器部署jumpserver
JumpServer 封装了一个 All in one Docker, 可以快速启动。该镜像集成了所需要的组件, "支持使用外置 Database 和 Redis"
注：环境迁移和更新升级请检查 SECRET_KEY 是否与之前设置一致, 不能随机生成, 否则数据库所有加密的字段均无法解密
----容器部署jumpserver_all容器
1. Linux 生成随机加密秘钥，使用 root 身份输入：
if [ ! "$SECRET_KEY" ]; then
  SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`;
  echo "SECRET_KEY=$SECRET_KEY" >> ~/.bashrc;
  echo $SECRET_KEY;
else
  echo $SECRET_KEY;
fi  
if [ ! "$BOOTSTRAP_TOKEN" ]; then
  BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`;
  echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc;
  echo $BOOTSTRAP_TOKEN;
else
  echo $BOOTSTRAP_TOKEN;
fi
2. 部署jumpserver_all容器：
docker run --name jms_all -d \
  -p 80:80 -p 2222:2222 \
  -e SECRET_KEY=$SECRET_KEY \
  -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN \
  jumpserver/jms_all:latest
-----------额外变量说明------------
SECRET_KEY = ******
BOOTSTRAP_TOKEN = ******
DB_HOST = mysql_host
DB_PORT = 3306
DB_USER = jumpserver
DB_PASSWORD = weakPassword
DB_NAME = jumpserver
REDIS_HOST = redis_host
REDIS_PORT = 6379
REDIS_PASSWORD = weakPassword
VOLUME /opt/jumpserver/data/media
VOLUME /var/lib/mysql
----------------------------------
3. 访问：
浏览器访问: http://<容器所在服务器IP>
SSH 访问: ssh -p 2222 <容器所在服务器IP>
XShell 等工具请添加 connection 连接, 默认 ssh 端口 2222
默认管理员账户 admin 密码 admin

堡垒机操作流程：
1. 建立用户组
2. 建立用户，将用户加入用户组，并设定用户密码，以后是这里的用户连接jumpserver的ssh端口进行管理设备等操作的。
3. 进入资产管理中，增加管理用户，此用户是root或具有NOPASSWD权限的sudo用户。jumpserver将用此用户进行管理设备，一个设备对应一个管理用户。
4. 进入资产管理中，增加系统用户，设定用户名称，用户名，密码，登录模式为自动登录(连接时不用手动输入用户名 和密码)，协议为ssh，开启自动推送(如果机器中无此用户，则会自动增加用户和设定我们给定的密码)，也可以设定'命令过滤器'来允许或阻止用户命令(只要用户命令匹配到设定的正则命令则会允许或阻止)，设定sudo(开启普通用户可以使用的命令)，设定用户默认shell.
5. 进入资产列表添加资产，在左侧资产树中增加树节点(可以看做一个环境是一个节点，例如:pro)，然后选择树节点新建主机设备，设定：主机名，IP,指定系统平台，公网IP(无则跟IP字段一样即可),指定管理用户连接此主机设备的协议及端口(ssh:22)，选定之前建立的管理用户，选择节点属于哪个树节点。
6. 进入权限管理中，进行资产授权，创建一个授权：设定名称(例如：Ops-jack),并关联选定用户和用户组(此用户就是来登录堡垒机的)，选择资产(服务器等设备)，选择节点(树节点，例如pro)，选择系统用户(实际操作机器的帐记)，动作设定为全部，选择激活，最后确定即可。
7. 以上操作完成可即可连接堡垒机ssh端口进行管理设备，h是帮助，p是打印机器。可以在堡垒机web上进行实时监控的操作，查看用户执行的命令，用户的登录记录等信息。还可导出相关信息用于审计。


#外置数据库要求：
mysql 版本需要大于等于 5.6
mariadb 版本需要大于等于 5.5.6
数据库编码要求 uft8

1. 创建数据库
create database jumpserver default charset 'utf8' collate 'utf8_bin';
grant all on jumpserver.* to 'jumpserver'@'%' identified by 'weakPassword';
2. 安装redis数据库，并设定访问redis库密码
3. 运行jumpserver容器
[root@hohong-node2 ~]# docker run --name jms_all -d -v /opt/jumpserver:/opt/jumpserver/data/media  -p 80:80 -p 2222:2222 -e SECRET_KEY=$SECRET_KEY -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN -e DB_HOST=192.168.230.80 -e DB_PORT=3306 -e DB_USER=jumpserver -e DB_PASSWORD=weakPassword -e DB_NAME=jumpserver -e REDIS_HOST=192.168.230.80 -e REDIS_PORT=6379 -e REDIS_PASSWORD=weakPassword jumpserver/jms_all:latest



</pre>


