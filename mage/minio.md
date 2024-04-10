# MinIO



## 一、概述


MinIO 是一个开源的对象存储服务器，用于存储和管理大规模的非结构化数据，例如图像、视频、日志文件、备份和容器镜像。MinIO 旨在提供高性能、高可用性、可扩展性和易用性的对象存储解决方案，适用于私有云、公共云和混合云环境。

以下是 MinIO 的主要特点和介绍：
* 开源和自由：MinIO 是一个开源项目，根据 Apache License 2.0 许可证发布，这意味着您可以免费使用、修改和分发它。
* 对象存储：MinIO 是一种对象存储系统，它使用存储桶（buckets）来组织数据，每个存储桶包含多个对象。对象可以是各种文件、文档、媒体和其他非结构化数据。
* 高性能：MinIO 具有出色的性能，能够以高速处理大规模数据。它采用了分布式、并行和多线程处理技术，以支持高吞吐量和低延迟。
* 高可用性：MinIO 具有内置的冗余和故障转移功能，支持数据备份和多副本存储，以确保数据的持久性和高可用性。它还支持数据版本控制。
* 容器化：MinIO 可以轻松部署在容器化环境中，如Docker和Kubernetes。这使得它适用于云原生应用和容器化工作负载。
* 分布式扩展：MinIO 支持分布式架构，可以轻松扩展以适应不断增长的数据需求。您可以添加更多的MinIO实例以构建多节点集群。
* S3 兼容：MinIO 提供了S3（Simple Storage Service） API 兼容性，这意味着它可以与现有的S3客户端和应用程序集成，无需进行大规模修改。
* 安全性：MinIO 提供数据加密、身份验证和访问控制功能，以确保数据的保密性和完整性。它还支持SSL/TLS加密。
* 易用性：MinIO 的配置和管理非常简单，具有用户友好的命令行界面和Web管理控制台。它还有丰富的文档和活跃的社区支持。
MinIO 是一个功能强大且易于使用的对象存储解决方案，适用于各种应用，从数据备份和存档到大规模媒体存储和分析。它为云原生环境提供了一个强大的存储选项，并且由于其开源性质，广受开发者和组织的欢迎。
[官方文档](https://min.io/docs/minio/linux/index.html)

![MinIO Arch](../image/minio/01.png)



![MinIO Arch](../image/minio/02.png)








## 二、Minio分布式集群部署



分布式 Minio 可以让你将多块硬盘或者多台服务器组成一个对象存储服务。由于硬盘分布在不同的节点上，分布式 Minio 避免了单点故障。MinioMinio分布式模式可以帮助你搭建一个高可用的对象存储服务，你可以使用这些存储设备，而不用考虑其真实物理位置。




### 1. Minio分布式部署的优势



#### 1.1 数据保护
* 分布式 Minio 采用纠删码来防范多个节点宕机和位衰减。
* 分布式 Minio 至少需要 4 个节点（4台服务器），使用分布式 Minio 就 自动引入了纠删码功能。
* 纠删码是一种恢复丢失和损坏数据的数学算法， Minio 采用 Reed-Solomon code 将对象拆分成 N/2 数据和 N/2 奇偶校验块。 这就意味着如果是 12 块盘，一个对象会被分成 6 个数据块、6 个奇偶校验块，你可以丢失任意 6 块盘（不管其是存放的数据块还是奇偶校验块），你仍可以从剩下的盘中的数据进行恢复。
* 纠删码的工作原理和 RAID 或者复制不同，像 RAID6 可以在损失两块盘的情况下不丢数据，而 Minio 纠删码可以在丢失一半的盘的情况下，仍可以保证数据安全。 而且 Minio 纠删码是作用在对象级别，可以一次恢复一个对象，而RAID 是作用在卷级别，数据恢复时间很长。 Minio 对每个对象单独编码，存储服务一经部署，通常情况下是不需要更换硬盘或者修复。Minio 纠删码的设计目标是为了性能和尽可能的使用硬件加速。
* 位衰减又被称为数据腐化 Data Rot、无声数据损坏 Silent Data Corruption ，是目前硬盘数据的一种严重数据丢失问题。硬盘上的数据可能会神不知鬼不觉就损坏了，也没有什么错误日志。正所谓明枪易躲，暗箭难防，这种背地里犯的错比硬盘直接故障还危险。 所以 Minio 纠删码采用了高速 HighwayHash 基于哈希的校验和来防范位衰减。


#### 1.2 高可用
* 单机 Minio 服务存在单点故障，相反，如果是一个 N 节点的分布式 Minio ,只要有 N/2 节点在线，你的数据就是安全的。不过你需要至少有 N/2+1 个节点来创建新的对象。
* 例如，一个 8 节点的 Minio 集群，每个节点一块盘，就算 4 个节点宕机，这个集群仍然是可读的，不过你需要 5 个节点才能写数据。


#### 1.3 限制
* 分布式 Minio 单租户存在最少 4 个盘最多 16 个盘的限制（受限于纠删码）。这种限制确保了 Minio 的简洁，同时仍拥有伸缩性。如果你需要搭建一个多租户环境，你可以轻松的使用编排工具（Kubernetes）来管理多个Minio实例。
* 注意，只要遵守分布式 Minio 的限制，你可以组合不同的节点和每个节点几块盘。比如，你可以使用 2 个节点，每个节点 4 块盘，也可以使用 4 个节点，每个节点两块盘，诸如此类。


#### 1.4 一致性
* Minio 在分布式和单机模式下，所有读写操作都严格遵守 read-after-write 一致性模型。



### 2. Minio分布式集群部署



#### 2.1 环境准备

部署规划：一共5台服务器。MinIO集群部署在4台服务器上，每个服务器2块磁盘；剩余一台服务器用于部署Nginx负载均衡。

| 系统               | 节点         | 目录                     | 角色      |
| ------------------ | ------------ | ------------------------ | --------- |
| Ubuntu 18.04.5 LTS | 172.168.2.27 | /data/disk1，/data/disk2 | minio节点 |
| Ubuntu 18.04.5 LTS | 172.168.2.28 | /data/disk1，/data/disk2 | minio节点 |
| Ubuntu 18.04.5 LTS | 172.168.2.29 | /data/disk1，/data/disk2 | minio节点 |
| Ubuntu 18.04.5 LTS | 172.168.2.30 | /data/disk1，/data/disk2 | minio节点 |
| Ubuntu 18.04.5 LTS | 172.168.2.12 |                          | 负载均衡  |





#### 2.2 部署步骤



##### 2.2.1 时间同步

```bash
root@ansible:~# ansible minio -m ping
root@ansible:~# ansible minio -m shell -a 'hostname'
172.168.2.30 | SUCCESS | rc=0 >>
minio-04

172.168.2.27 | SUCCESS | rc=0 >>
minio-01

172.168.2.28 | SUCCESS | rc=0 >>
minio-02

172.168.2.29 | SUCCESS | rc=0 >>
minio-03

root@ansible:~# ansible minio -m shell -a 'apt update'
root@ansible:~# ansible minio -m shell -a 'apt install -y ntpdate'
root@ansible:~# ansible minio -m shell -a "echo '*/5 * * * * ntpdate time1.aliyun.com' >> /var/spool/cron/crontabs/root"
root@ansible:~# ansible minio -m shell -a "crontab -l"
172.168.2.27 | SUCCESS | rc=0 >>
*/5 * * * * ntpdate time1.aliyun.com

172.168.2.29 | SUCCESS | rc=0 >>
*/5 * * * * ntpdate time1.aliyun.com

172.168.2.30 | SUCCESS | rc=0 >>
*/5 * * * * ntpdate time1.aliyun.com

172.168.2.28 | SUCCESS | rc=0 >>
*/5 * * * * ntpdate time1.aliyun.com
root@ansible:~# ansible minio -m shell -a "ntpdate time1.aliyun.com"
root@ansible:~# ansible minio -m shell -a "date"
172.168.2.27 | SUCCESS | rc=0 >>
Tue Apr  2 11:00:52 CST 2024

172.168.2.28 | SUCCESS | rc=0 >>
Tue Apr  2 11:00:52 CST 2024

172.168.2.30 | SUCCESS | rc=0 >>
Tue Apr  2 11:00:52 CST 2024

172.168.2.29 | SUCCESS | rc=0 >>
Tue Apr  2 11:00:52 CST 2024
```



##### 2.2.2 磁盘配置

**报错：**

Unable to use the drive http://172.168.2.27:9000/data/minio: drive is part of root drive, will not be used

**原因：**

文件系统挂载是`根`文件系统的一部分，将不会被使用，需要使用独立的硬盘分区

```bash
root@ansible:~# ansible minio -m shell -a 'mkfs.xfs /dev/sdb -L DISK1 && mkfs.xfs /dev/sdc -L DISK2'
root@ansible:~# ansible minio -m shell -a 'mkdir -p /data/disk1 /data/disk2'
# 配置开机自启
root@ansible:~# ansible minio -m shell -a "echo 'LABEL=DISK1      /data/disk1         xfs     defaults,noatime  0       2' >> /etc/fstab && echo 'LABEL=DISK2      /data/disk2         xfs     defaults,noatime  0       2' >> /etc/fstab"
root@ansible:~# ansible minio -m shell -a 'mount -a'
root@ansible:~# ansible minio -m shell -a 'df -TH | grep /data'
172.168.2.28 | SUCCESS | rc=0 >>
/dev/sdb                             xfs       5.4G   40M  5.4G   1% /data/disk1
/dev/sdc                             xfs       5.4G   40M  5.4G   1% /data/disk2

172.168.2.29 | SUCCESS | rc=0 >>
/dev/sdb                             xfs       5.4G   40M  5.4G   1% /data/disk1
/dev/sdc                             xfs       5.4G   40M  5.4G   1% /data/disk2

172.168.2.27 | SUCCESS | rc=0 >>
/dev/sdb                             xfs       5.4G   40M  5.4G   1% /data/disk1
/dev/sdc                             xfs       5.4G   40M  5.4G   1% /data/disk2

172.168.2.30 | SUCCESS | rc=0 >>
/dev/sdb                             xfs       5.4G   40M  5.4G   1% /data/disk1
/dev/sdc                             xfs       5.4G   40M  5.4G   1% /data/disk2
```



##### 2.2.3 安装minio

```bash
root@ansible:/download# wget https://dl.min.io/server/minio/release/linux-amd64/minio
root@ansible:/download# ansible minio -m copy -a 'src=./minio dest=/usr/local/bin/minio mode=755'
root@ansible:~# ansible minio -m shell -a 'minio --version'
172.168.2.30 | SUCCESS | rc=0 >>
minio version RELEASE.2024-03-30T09-41-56Z (commit-id=cb577835d945dbe47f873be96d25caa5a8a858f8)
Runtime: go1.21.8 linux/amd64
License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
Copyright: 2015-2024 MinIO, Inc.

172.168.2.29 | SUCCESS | rc=0 >>
minio version RELEASE.2024-03-30T09-41-56Z (commit-id=cb577835d945dbe47f873be96d25caa5a8a858f8)
Runtime: go1.21.8 linux/amd64
License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
Copyright: 2015-2024 MinIO, Inc.

172.168.2.27 | SUCCESS | rc=0 >>
minio version RELEASE.2024-03-30T09-41-56Z (commit-id=cb577835d945dbe47f873be96d25caa5a8a858f8)
Runtime: go1.21.8 linux/amd64
License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>
Copyright: 2015-2024 MinIO, Inc.

172.168.2.28 | SUCCESS | rc=0 >>
minio version RELEASE.2024-03-30T09-41-56Z (commit-id=cb577835d945dbe47f873be96d25caa5a8a858f8)
Runtime: go1.21.8 linux/amd64
License: GNU AGPLv3 <https://www.gnu.org/licenses/agpl-3.0.html>

# 配置目录权限 
root@ansible:/tmp/minio# ansible minio -m shell -a 'groupadd -r minio-user && useradd -r -M -g minio-user minio-user'
root@ansible:/tmp/minio# ansible minio -m shell -a 'chown minio-user:minio-user /data/disk*'
root@ansible:/tmp/minio# ansible minio -m shell -a 'ls -ld /data/disk*'
172.168.2.28 | SUCCESS | rc=0 >>
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk1
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk2

172.168.2.27 | SUCCESS | rc=0 >>
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk1
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk2

172.168.2.29 | SUCCESS | rc=0 >>
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk1
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk2

172.168.2.30 | SUCCESS | rc=0 >>
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk1
drwxr-xr-x 2 minio-user minio-user 6 Apr  2 15:33 /data/disk2

```



##### 2.2.4 配置minio

**报错：**

如果`MINIO_SERVER_URL`使用了`IP地址`，那么分布式集群部署完成后，通过任意节点或者nginx的console `9001端口`访问时，会提示密码不正确而无法访问，应该是Minio签名问题导致。

**解决：**

* `MINIO_SERVER_URL`必需使用FQDN完全合格域名才行，这样Minio签字才不会出错。最终部署完成后通过Nginx反向代理访问成功

* 如果没有反向代理，可以将`MINIO_SERVER_URL`的值临时设定为任意节点的IP地址，但所以节点必须一样配置，如：`MINIO_SERVER_URL="http://172.168.2.27:9000"`

**测试：**

可以使用`mc alias set local http://172.168.2.27:9000 test aaa@1234`进行测试，看是否能成功连接

```bash
# MINIO_SERVER_URL：指定MinIO控制台必须使用以连接到MinIO服务器的完全合格域名（FQDN）。控制台还使用此值设置生成预签名URL时的根主机名。
# MINIO_BROWSER_REDIRECT_URL: 指定MinIO控制台监听传入连接的完全合格域名（FQDN）

# 配置主机名，因为MINIO_SERVER_URL和MINIO_BROWSER_REDIRECT_URL必需使用FQDN域名，IP不能使用
root@ansible:/download/minio-dir# cat hosts
127.0.0.1       localhost
172.168.2.12    minio.hs.com minio-console.hs.com
root@ansible:/download/minio-dir# ansible minio -m copy -a 'src=./hosts dest=/etc/hosts backup=yes mode=644'

# 配置环境变量
root@ansible:/download/minio-dir# cat minio
MINIO_VOLUMES="http://172.168.2.{27...30}:9000/data/disk{1...2}"
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_ROOT_USER=test
MINIO_ROOT_PASSWORD=aaa@1234
MINIO_SERVER_URL="http://minio.hs.com"
MINIO_BROWSER_REDIRECT_URL="http://minio-console.hs.com"
root@ansible:/download/minio-dir# ansible minio -m copy -a 'src=./minio dest=/etc/default/minio mode=644'

# 配置minio.service服务
root@ansible:/download/minio-dir# cat minio.service
[Unit]
Description=MinIO
Documentation=https://min.io/docs/minio/linux/index.html
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/usr/local/bin/minio

[Service]
Type=simple
User=minio-user
Group=minio-user
ProtectProc=invisible
EnvironmentFile=-/etc/default/minio
ExecStartPre=/bin/bash -c "if [ -z \"${MINIO_VOLUMES}\" ]; then echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\"; exit 1; fi"
ExecStart=/usr/local/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
Restart=always
LimitNOFILE=655360
TasksMax=infinity
TimeoutStopSec=infinity
SendSIGKILL=no

[Install]
WantedBy=multi-user.target
root@ansible:/download/minio-dir# ansible minio -m copy -a 'src=./minio.service dest=/lib/systemd/system/minio.service mode=644'

root@ansible:/download/minio-dir# ansible minio -m shell -a 'systemctl daemon-reload'
```



##### 2.2.5 配置Nginx

`nginx.conf`

```nginx
        upstream minio_console {
            least_conn;
            server 172.168.2.27:9001 max_fails=3 fail_timeout=5s;
            server 172.168.2.28:9001 max_fails=3 fail_timeout=5s;
            server 172.168.2.29:9001 max_fails=3 fail_timeout=5s;
            server 172.168.2.30:9001 max_fails=3 fail_timeout=5s;
        }
        upstream minio_api {
            least_conn;
            server 172.168.2.27:9000 max_fails=3 fail_timeout=5s;
            server 172.168.2.28:9000 max_fails=3 fail_timeout=5s;
            server 172.168.2.29:9000 max_fails=3 fail_timeout=5s;
            server 172.168.2.30:9000 max_fails=3 fail_timeout=5s;
        }

        server {
                listen 80;
                server_name minio-console.hs.com;
                ignore_invalid_headers off;
                client_max_body_size 0;
                proxy_buffering off;
                proxy_request_buffering off;

                location / {
                        proxy_next_upstream  error timeout http_502 http_503 http_504;
                        proxy_redirect off;
                        proxy_set_header Host $host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Real-Port $remote_port;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_http_version 1.1;
                        proxy_set_header X-Forwarded-Proto $scheme;
                        proxy_connect_timeout 300;
                        proxy_set_header Connection "";
                        chunked_transfer_encoding off;
                        proxy_pass http://minio_console;
                }
        }

        server {
                listen 80;
                server_name minio.hs.com;
                ignore_invalid_headers off;
                client_max_body_size 0;
                proxy_buffering off;
                proxy_request_buffering off;

                location / {
                        proxy_next_upstream  error timeout http_502 http_503 http_504;
                        proxy_redirect off;
                        proxy_set_header Host $host;
                        proxy_set_header X-Real-IP $remote_addr;
                        proxy_set_header X-Real-Port $remote_port;
                        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                        proxy_http_version 1.1;
                        proxy_set_header X-Forwarded-Proto $scheme;
                        proxy_connect_timeout 300;
                        proxy_set_header Connection "";
                        chunked_transfer_encoding off;
                        proxy_pass http://minio_api;
                }
        }
```





##### 2.2.6 启动服务

```bash
# 启动服务
root@ansible:/tmp/minio# ansible minio -m shell -a 'systemctl start minio.service'
root@ansible:/tmp/minio# ansible minio -m shell -a 'systemctl is-active minio.service'
root@ansible:/tmp/minio# ansible minio -m shell -a 'systemctl status minio.service'
root@ansible:/tmp/minio# ansible minio -m shell -a 'systemctl enable minio.service'

# 查看运行状态
root@ansible:/tmp/minio# ansible minio -m shell -a 'netstat -antlp'
172.168.2.29 | SUCCESS | rc=0 >>
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      1720/minio
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      472/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      639/sshd
tcp        0      0 172.168.2.29:57688      172.168.2.30:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:4932       172.168.2.28:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:4934       172.168.2.28:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:57666      172.168.2.30:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:59062      172.168.2.27:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:4924       172.168.2.28:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:57662      172.168.2.30:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:57668      172.168.2.30:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:59084      172.168.2.27:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:15428      35.201.125.20:443       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:59082      172.168.2.27:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:22         172.168.2.12:42196      ESTABLISHED 1585/sshd: root@pts
tcp        0      0 172.168.2.29:57678      172.168.2.30:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:4926       172.168.2.28:9000       ESTABLISHED 1720/minio
tcp        0      0 172.168.2.29:59068      172.168.2.27:9000       ESTABLISHED 1720/minio
tcp6       0      0 :::9000                 :::*                    LISTEN      1720/minio
tcp6       0      0 :::9001                 :::*                    LISTEN      1720/minio
tcp6       0      0 :::22                   :::*                    LISTEN      639/sshd
tcp6       0      0 172.168.2.29:9000       172.168.2.28:31192      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.28:31168      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.30:44420      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.30:44430      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.27:31442      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.28:31190      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.28:31180      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.30:44432      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.27:31444      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.28:31172      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.27:31428      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.27:31418      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.27:31430      ESTABLISHED 1720/minio
tcp6       0      0 172.168.2.29:9000       172.168.2.30:44412      ESTABLISHED 1720/minio

172.168.2.28 | SUCCESS | rc=0 >>
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      1771/minio
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      520/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      645/sshd
tcp        0      0 172.168.2.28:40406      172.168.2.30:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:40404      172.168.2.30:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:31172      172.168.2.29:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:40388      172.168.2.30:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:22         172.168.2.12:64658      ESTABLISHED 1094/sshd: root@pts
tcp        0      0 172.168.2.28:31190      172.168.2.29:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:31180      172.168.2.29:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:28150      35.201.125.20:443       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:31168      172.168.2.29:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:52430      172.168.2.27:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:52420      172.168.2.27:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:31192      172.168.2.29:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:40396      172.168.2.30:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:52412      172.168.2.27:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:52428      172.168.2.27:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:40398      172.168.2.30:9000       ESTABLISHED 1771/minio
tcp        0      0 172.168.2.28:22         172.168.2.12:64686      ESTABLISHED 1641/sshd: root@pts
tcp6       0      0 :::9000                 :::*                    LISTEN      1771/minio
tcp6       0      0 :::9001                 :::*                    LISTEN      1771/minio
tcp6       0      0 :::22                   :::*                    LISTEN      645/sshd
tcp6       0      0 172.168.2.28:9000       172.168.2.27:13294      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.27:13318      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.30:60544      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.29:4934       ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.29:4932       ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.30:60562      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.30:60542      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.29:4926       ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.29:4924       ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.30:60556      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.27:13316      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.27:13300      ESTABLISHED 1771/minio
tcp6       0      0 172.168.2.28:9000       172.168.2.27:13304      ESTABLISHED 1771/minio

172.168.2.27 | SUCCESS | rc=0 >>
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      504/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      652/sshd
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      1738/minio
tcp        0      0 172.168.2.27:31442      172.168.2.29:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:48130      35.201.125.20:443       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:22         172.168.2.12:5374       ESTABLISHED 1608/sshd: root@pts
tcp        0      0 172.168.2.27:13318      172.168.2.28:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:46324      172.168.2.30:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:46332      172.168.2.30:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:13304      172.168.2.28:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:22         172.168.2.12:5310       ESTABLISHED 712/sshd: root@pts/
tcp        0      0 172.168.2.27:46346      172.168.2.30:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:46348      172.168.2.30:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:46336      172.168.2.30:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:13300      172.168.2.28:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:31430      172.168.2.29:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:31444      172.168.2.29:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:31418      172.168.2.29:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:13294      172.168.2.28:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:13316      172.168.2.28:9000       ESTABLISHED 1738/minio
tcp        0      0 172.168.2.27:31428      172.168.2.29:9000       ESTABLISHED 1738/minio
tcp6       0      0 :::22                   :::*                    LISTEN      652/sshd
tcp6       0      0 :::9000                 :::*                    LISTEN      1738/minio
tcp6       0      0 :::9001                 :::*                    LISTEN      1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.28:52420      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.30:61386      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.29:59068      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.30:61402      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.28:52428      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.29:59084      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.29:59062      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.28:52412      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.28:52430      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.30:61394      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.29:59082      ESTABLISHED 1738/minio
tcp6       0      0 172.168.2.27:9000       172.168.2.30:61400      ESTABLISHED 1738/minio

172.168.2.30 | SUCCESS | rc=0 >>
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 127.0.0.53:53           0.0.0.0:*               LISTEN      551/systemd-resolve
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      649/sshd
tcp        0      0 127.0.0.1:9000          0.0.0.0:*               LISTEN      1731/minio
tcp        0      0 172.168.2.30:61400      172.168.2.27:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:22         172.168.2.12:4020       ESTABLISHED 1598/sshd: root@pts
tcp        0      0 172.168.2.30:60542      172.168.2.28:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:60562      172.168.2.28:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:60556      172.168.2.28:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:44432      172.168.2.29:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:61402      172.168.2.27:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:44420      172.168.2.29:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:44430      172.168.2.29:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:61386      172.168.2.27:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:61394      172.168.2.27:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:44412      172.168.2.29:9000       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:26882      35.201.125.20:443       ESTABLISHED 1731/minio
tcp        0      0 172.168.2.30:60544      172.168.2.28:9000       ESTABLISHED 1731/minio
tcp6       0      0 :::22                   :::*                    LISTEN      649/sshd
tcp6       0      0 :::9000                 :::*                    LISTEN      1731/minio
tcp6       0      0 :::9001                 :::*                    LISTEN      1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.29:57688      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.29:57666      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.27:46336      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.27:46332      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.28:40398      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.28:40404      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.29:57662      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.27:46348      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.28:40396      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.29:57668      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.29:57678      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.27:46324      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.27:46346      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.28:40406      ESTABLISHED 1731/minio
tcp6       0      0 172.168.2.30:9000       172.168.2.28:40388      ESTABLISHED 1731/minio


```

> 注意：如果只启动了1个节点，那么可能发现9001端口没有启动，继续等到4个节点都启动后再检查9001,会发现就启动成功了。



**使用用户和密码进行访问**

![MinIO Arch](../image/minio/03.png)







#### 2.3 客户端工具mc

```bash
root@ansible:/tmp/minio# curl -OL https://dl.min.io/client/mc/release/linux-amd64/mc
root@ansible:/tmp/minio# chmod +x mc
root@ansible:/tmp/minio# mv mc /usr/local/bin/
```



**使用**

```bash
root@ansible:/download/minio-dir# mc alias set local http://172.168.2.27:9000 test aaa@1234
Added `local` successfully.
# 可以使用Nginx反向代理的地址minio.hs.com进行访问
root@ansible:/download/minio-dir# mc alias set local http://minio.hs.com test aaa@1234
Added `local` successfully.
root@ansible:/download/minio-dir# mc alias list local
local
  URL       : http://minio.hs.com
  AccessKey : test
  SecretKey : aaa@1234
  API       : s3v4
  Path      : auto

root@ansible:/download/minio-dir# mc mb local/test
Bucket created successfully `local/test`.
root@ansible:/download/minio-dir# mc ls local
[2024-04-03 14:32:00 CST]     0B test/
```



**minio磁盘目录**

```bash
root@minio-01:~# ls -al /data/disk*
/data/disk1:
total 0
drwxr-xr-x 4 minio-user minio-user  36 Apr  2 17:53 .
drwxr-xr-x 4 root       root        32 Apr  2 16:36 ..
drwxr-xr-x 8 minio-user minio-user 113 Apr  2 17:50 .minio.sys
drwxr-xr-x 2 minio-user minio-user   6 Apr  2 17:53 test

/data/disk2:
total 0
drwxr-xr-x 4 minio-user minio-user  36 Apr  2 17:53 .
drwxr-xr-x 4 root       root        32 Apr  2 16:36 ..
drwxr-xr-x 8 minio-user minio-user 113 Apr  2 17:50 .minio.sys
drwxr-xr-x 2 minio-user minio-user   6 Apr  2 17:53 test

```



**常用命令**

```
ls 列出文件和文件夹。
mb 创建一个存储桶或一个文件夹。
cat 显示文件和对象内容。
pipe 将一个STDIN重定向到一个对象或者文件或者STDOUT。
share 生成用于共享的URL。
cp 拷贝文件和对象。
mirror 给存储桶和文件夹做镜像。
find 基于参数查找文件。
diff 对两个文件夹或者存储桶比较差异。
rm 删除文件和对象。
events 管理对象通知。
watch 监听文件和对象的事件。
policy 管理访问策略。
session 为cp命令管理保存的会话。
config 管理mc配置文件。
update 检查软件更新。
version 输出版本信息。
```











#### 2.4 监控

使用Prometheus进行监控和报警



##### 2.4.1 生成抓取配置

```bash
# 监控Minio Server
root@ansible:/download/minio-dir# mc admin prometheus generate local
scrape_configs:
- job_name: minio-job
  bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjUxN30.3el30s5aPg-ZcJ1RyMDIaT1b2C5of4gT-nv5TTAETv_XGyhUpLu-jXGVlCmnTqJFwKDS6LXRiWgC6uBsn6VpSw
  metrics_path: /minio/v2/metrics/cluster
  scheme: http
  static_configs:
  - targets: [minio.hs.com]



# 监控Nodes
root@ansible:/download/minio-dir# mc admin prometheus generate local node
scrape_configs:
- job_name: minio-job-node
  bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjUyOH0.l5qJNAfLPW6FwwQhe3WvusFrysWql2PyXJoqt6Y2BAgnbpXPcmPh4tl-FYmA6LkHE0bjlJRZVEZbn_5Pk8Tj6g
  metrics_path: /minio/v2/metrics/node
  scheme: http
  static_configs:
  - targets: [minio.hs.com]



# 监控Buckets
root@ansible:/download/minio-dir# mc admin prometheus generate local bucket
scrape_configs:
- job_name: minio-job-bucket
  bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjUzOH0.lAr1gbvVAugAdVHa6hU362dcZZr-7EV1G8kusbsgVlAeqdbLi3p530sZUOYurI1h-qRMgZ6bvX0OWukdFFsL1A
  metrics_path: /minio/v2/metrics/bucket
  scheme: http
  static_configs:
  - targets: [minio.hs.com]


# 监控Resources
scrape_configs:
- job_name: minio-job-resource
  bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjU0N30.jyJxbsJslelG7nohP5_-KLZDET4EV73SDn61L9lTRHMxB6Eqbf_mbOsxuV-UMQLcoE_Xtk8r1XLT7QEATtiHDQ
  metrics_path: /minio/v2/metrics/resource
  scheme: http
  static_configs:
  - targets: [minio.hs.com]


```



##### 2.4.2 配置Prometheus

```bash
[root@prometheus prometheus]# tail -n 100 prometheus.yml
#######################

  - job_name: minio-job
    bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjUxN30.3el30s5aPg-ZcJ1RyMDIaT1b2C5of4gT-nv5TTAETv_XGyhUpLu-jXGVlCmnTqJFwKDS6LXRiWgC6uBsn6VpSw
    metrics_path: /minio/v2/metrics/cluster
    scheme: http
    static_configs:
    - targets: [minio.hs.com]
  - job_name: minio-job-node
    bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjUyOH0.l5qJNAfLPW6FwwQhe3WvusFrysWql2PyXJoqt6Y2BAgnbpXPcmPh4tl-FYmA6LkHE0bjlJRZVEZbn_5Pk8Tj6g
    metrics_path: /minio/v2/metrics/node
    scheme: http
    static_configs:
    - targets: [minio.hs.com]
  - job_name: minio-job-bucket
    bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjUzOH0.lAr1gbvVAugAdVHa6hU362dcZZr-7EV1G8kusbsgVlAeqdbLi3p530sZUOYurI1h-qRMgZ6bvX0OWukdFFsL1A
    metrics_path: /minio/v2/metrics/bucket
    scheme: http
    static_configs:
    - targets: [minio.hs.com]
  - job_name: minio-job-resource
    bearer_token: eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJwcm9tZXRoZXVzIiwic3ViIjoidGVzdCIsImV4cCI6NDg2NTcyNjU0N30.jyJxbsJslelG7nohP5_-KLZDET4EV73SDn61L9lTRHMxB6Eqbf_mbOsxuV-UMQLcoE_Xtk8r1XLT7QEATtiHDQ
    metrics_path: /minio/v2/metrics/resource
    scheme: http
    static_configs:
    - targets: [minio.hs.com]  

####################
# 重载prometheus服务生效
[root@prometheus prometheus]# postp
```

![MinIO Arch](../image/minio/04.png)



##### 2.4.3 配置告警

``` bash
groups:
- name: minio-alerts
  rules:
  - alert: NodesOffline
    expr: avg_over_time(minio_cluster_nodes_offline_total{job="minio-job"}[5m]) > 0
    for: 10m
    labels:
      severity: warn
    annotations:
      summary: "Node down in MinIO deployment"
      description: "Node(s) in cluster {{ $labels.instance }} offline for more than 5 minutes"

  - alert: DisksOffline
    expr: avg_over_time(minio_cluster_disk_offline_total{job="minio-job"}[5m]) > 0
    for: 10m
    labels:
      severity: warn
    annotations:
      summary: "Disks down in MinIO deployment"
      description: "Disks(s) in cluster {{ $labels.instance }} offline for more than 5 minutes"
```



##### 2.4.4 配置Grafana

https://grafana.com/grafana/dashboards/15305-minio-replication-dashboard/?tab=revisions

ID: 15305  Revesion: 1



##### 2.4.5 （可选）配置MinIO控制台以查询Prometheus

该控制台还支持通过查询配置为从MinIO部署中抓取数据的Prometheus 服务来显示时间序列和历史数据。

为了启用MinIO控制台中的历史数据可视化，请在MinIO部署的每个节点上设置以下环境变量：

- 设置 [`MINIO_PROMETHEUS_URL`](https://www.minio.org.cn/docs/minio/linux/reference/minio-server/settings/console.html#envvar.MINIO_PROMETHEUS_URL) 为 Prometheus 服务的URL。
- 设置 [`MINIO_PROMETHEUS_JOB_ID`](https://www.minio.org.cn/docs/minio/linux/reference/minio-server/settings/console.html#envvar.MINIO_PROMETHEUS_JOB_ID) 为收集到的指标分配的唯一作业ID。

重新启动MinIO部署并访问 [Monitoring](https://www.minio.org.cn/docs/minio/linux/administration/console/managing-deployment.html#minio-console-monitoring) 面板以查看历史数据视图。

```bash
root@ansible:/download/minio-dir# cat minio
MINIO_VOLUMES="http://172.168.2.{27...30}:9000/data/disk{1...2}"
MINIO_OPTS="--address :9000 --console-address :9001"
MINIO_ROOT_USER=test
MINIO_ROOT_PASSWORD=aaa@1234
MINIO_SERVER_URL="http://minio.hs.com"
MINIO_BROWSER_REDIRECT_URL="http://minio-console.hs.com"
MINIO_PROMETHEUS_URL="http://192.168.13.236:9090"
MINIO_PROMETHEUS_JOB_ID="minio-job"
root@ansible:/download/minio-dir# ansible minio -m copy -a 'src=./minio dest=/etc/default/minio mode=644'
root@ansible:/download/minio-dir# ansible minio -m shell -a 'systemctl restart minio '
```

**此时MinIO的图形化界面处可以看到`Usage``Traffic``Resource`的历史监控了**

![MinIO Arch](../image/minio/05.png)





## 三、Minio备份和恢复



### 3.1 备份



#### 3.1 配置alias服务

```bash
# 添加Minio服务
root@ansible:/download/minio-dir# mc alias set k8s http://192.168.13.63:30100 admin minio123
Added `k8s` successfully.
root@ansible:/download/minio-dir# mc alias set local http://minio.hs.com test aaa@1234
Added `local` successfully.

# 查看alias
root@ansible:/download/minio-dir# mc alias list
k8s
  URL       : http://192.168.13.63:30100
  AccessKey : admin
  SecretKey : minio123
  API       : s3v4
  Path      : auto

local
  URL       : http://minio.hs.com
  AccessKey : test
  SecretKey : aaa@1234
  API       : s3v4
  Path      : auto
```



#### 3.2 备份数据

备份alias为k8s的数据 

```bash
# 备份所有数据
root@ansible:/download/minio-dir# mc cp --recursive k8s /mnt/minio/backup-k8s
...-backup-001-20240329172357-results.gz: 267.23 MiB / 267.23 MiB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 10.28 MiB/s 25s

# 备份Bucket为k8s-test的数据
root@ansible:/download/minio-dir# mc cp --recursive k8s/k8s-test /mnt/minio/custom/backup-k8s/
...t/b/velero-v1.13.1-linux-amd64.tar.gz: 39.11 MiB / 39.11 MiB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 11.03 MiB/s 3s
root@ansible:/download/minio-dir# tree /mnt/minio/custom/backup-k8s/
/mnt/minio/custom/backup-k8s/
└── k8s-test
    ├── a
    │   ├── 15305_rev1.json
    │   └── 15305_rev4.json
    └── b
        └── velero-v1.13.1-linux-amd64.tar.gz
```



#### 3.3 恢复数据

恢复 alias为k8s的数据 -> 到alias为local中

```bash
# 在alias为local的服务中创建bucket
root@ansible:/download/minio-dir# mc mb local/k8s-test
Bucket created successfully `local/k8s-test`.
root@ansible:/download/minio-dir# mc mb local/velero
Bucket created successfully `local/velero`.

# 恢复 alias为k8s的数据 -> 到alias为local中
root@ansible:/download/minio-dir# mc cp --recursive /mnt/minio/backup-k8s/ local
...ops-backup-001-20240329172357-logs.gz: 267.23 MiB / 267.23 MiB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 22.73 MiB/s 11s

# 将某个桶（比如：k8s-test）的备份数据恢复到 local 的指定桶（比如：test）中,需提前创建好 test 这个桶
root@ansible:/download/minio-dir# mc cp --recursive /mnt/minio/custom/backup-k8s/k8s-test/ local/test/
...t/b/velero-v1.13.1-linux-amd64.tar.gz: 39.11 MiB / 39.11 MiB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 26.46 MiB/s 1s
```

> 注意：备份文件目录路径需以'/'结尾





#### 3.4 镜像数据

先决条件：`配置alias服务`

镜像alias为local的数据 -> 到alias为k8s的服务中

```bash
# 全量迁移，重名文件不覆盖，如bucket不存在，会自动创建
root@ansible:~# mc mirror local k8s

# 加上--overwrite参数，覆盖重名文件
root@ansible:~# mc mirror --overwrite local k8s
...-backup-001-20240329172357-results.gz: 267.23 MiB / 267.23 MiB ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 9.06 MiB/s 29s

# 只迁移某个bucket，以test为例，迁移的目标bucket需要提前创建，--overwrite覆盖重名文件
root@ansible:~# mc mirror --overwrite local/test k8s/test
```

