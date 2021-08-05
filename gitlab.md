#gitlab

<pre>
#Centos7部署配置Gitlab 基于RPM包方式
配置源：
[root@newgitlab yum.repos.d]# curl -OL http://mirrors.aliyun.com/repo/Centos-7.repo
[root@newgitlab yum.repos.d]# curl -OL http://mirrors.aliyun.com/repo/epel-7.repo
[root@newgitlab yum.repos.d]# cat /etc/yum.repos.d/gitlab.repo 
[gitlab-ce]
name=gitlab-ce
baseurl=http://mirrors.tuna.tsinghua.edu.cn/gitlab-ce/yum/el7
gpgcheck=0
enabled=1

一、安装依赖软件
[root@newgitlab yum.repos.d]# rpm -qa | grep -E '(policycoreutils|openssh-server|openssh-clients|postfix)'
policycoreutils-2.5-29.el7.x86_64
openssh-server-7.4p1-16.el7.x86_64
openssh-clients-7.4p1-16.el7.x86_64
postfix-2.10.1-7.el7.x86_64
未有请安装：yum -y install policycoreutils openssh-server openssh-clients postfix

二、开启postfix
postfix支持gitlab发信功能，设置postfix开机自启
[root@newgitlab yum.repos.d]# systemctl enable postfix && systemctl start postfix

三、安装Gitlab
[root@newgitlab download]# yum install gitlab-ce-13.12.9 -y --show-duplicates 

四、设置服务器IP和端口
[root@newgitlab download]# grep -Ev '#|^$' /etc/gitlab/gitlab.rb
external_url 'http://192.168.13.75:8070'

五、重置并启动GitLab
[root@newgitlab download]# gitlab-ctl reconfigure
[root@newgitlab download]# gitlab-ctl restart
#--设置开机自启
[root@newgitlab download]# systemctl enable gitlab-runsvdir.service

六、浏览器访问GitLab
访问时显示502，可能的原因：
1. 防火墙被挡
2. 权限问题
[root@newgitlab ~]# chmod -R 755 /var/log/gitlab
3. 端口冲突，需要设成不一样
4. 内存不足，最少需要4G，建议8G

#gitlab HOME Directory
[root@newgitlab gitlab]# ls /var/opt/gitlab/
alertmanager  bootstrapped  git-data   gitlab-exporter  gitlab-shell      grafana    nginx          postgres-exporter  prometheus              redis
backups       gitaly        gitlab-ci  gitlab-rails     gitlab-workhorse  logrotate  node-exporter  postgresql         public_attributes.json  trusted-certs-directory-hash



#备份和恢复 GitLab
您只能将备份还原到与创建它的 GitLab完全相同的版本和类型 (CE/EE)。将存储库从一台服务器迁移到另一台服务器的最佳方法是通过备份还原。
警告：GitLab 不会备份未存储在文件系统中的项目
#--备份位置：
备份存档保存在文件中backup_path指定的目录下：
vim /etc/gitlab/gitlab.rb
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
警告：GitLab 不备份任何配置文件、SSL 证书或系统文件

#----备份：
GitLab 12.2 或更高版本：
sudo gitlab-backup create
GitLab 12.1 及更早版本：
sudo gitlab-rake gitlab:backup:create
#----存储配置文件
GitLab 提供的备份 Rake 任务不会存储您的配置文件。这样做的主要原因是您的数据库包含的项目包括用于两因素身份验证的加密信息和 CI/CD安全变量。将加密信息存储在与其密钥相同的位置首先违背了使用加密的目的。
警告：secrets 文件对于保存您的数据库加密密钥至关重要。
你必须备份:
/etc/gitlab/gitlab-secrets.json
/etc/gitlab/gitlab.rb
#----备份策略选项
当tar读取数据时数据发生变化，file changed as we read it可能会发生错误，并导致备份过程失败。为了解决这个问题，8.17 引入了一种名为copy. 该策略在调用tar和之前将数据文件复制到一个临时位置gzip，以避免错误。
sudo gitlab-backup create STRATEGY=copy
GitLab 12.1 及更早版本的用户应改用该命令gitlab-rake gitlab:backup:create。
#----备份文件名
默认情况下，备份文件是根据上一个备份时间戳部分中的规范创建的。但是，您可以通过设置BACKUP环境变量来覆盖文件名[TIMESTAMP]的一部分。例如：
sudo gitlab-backup create BACKUP=dump
生成的文件名为dump_gitlab_backup.tar. 这对于使用 rsync 和增量备份的系统很有用，并且可以显着提高传输速度。
#----确认档案可以转移
为确保生成的存档可通过 rsync 传输，您可以设置该GZIP_RSYNCABLE=yes选项。这会将--rsyncable选项设置为gzip，这仅在与设置备份文件名选项结合使用时才有用。
sudo gitlab-backup create BACKUP=dump GZIP_RSYNCABLE=yes

#----在还原期间禁用提示
在从备份还原期间，还原脚本可能会在继续之前要求确认。如果您希望禁用这些提示，您可以将GITLAB_ASSUME_YES环境变量设置为1
sudo GITLAB_ASSUME_YES=1 gitlab-backup restore
#----同时备份 Git 存储库
使用多个存储库存储时，可以同时备份存储库以帮助充分利用 CPU 时间,GITLAB_BACKUP_MAX_CONCURRENCY：同时备份的最大项目数。默认为1.GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY：每个存储上同时备份的最大项目数。这允许存储库备份跨存储分布。默认为1.
sudo gitlab-backup create GITLAB_BACKUP_MAX_CONCURRENCY=4 GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY=1

#----恢复：
您只能将备份还原到您在其上创建它的 GitLab的完全相同版本和类型 (CE/EE)
如果您的备份与当前安装的版本不同，则必须在恢复备份之前降级 GitLab 安装。
#-------Omnibus GitLab 安装的恢复
您已经安装了与创建备份完全相同的 GitLab Omnibus版本和类型 (CE/EE)。
你sudo gitlab-ctl reconfigure至少跑过一次。
GitLab 正在运行。如果没有，请使用sudo gitlab-ctl start.
首先确保您的备份 tar 文件位于gitlab.rb配置中描述的备份目录中gitlab_rails['backup_path']。默认为/var/opt/gitlab/backups。它需要归git用户所有。
sudo cp 11493107454_2018_04_25_10.6.4-ce_gitlab_backup.tar /var/opt/gitlab/backups/
sudo chown git.git /var/opt/gitlab/backups/11493107454_2018_04_25_10.6.4-ce_gitlab_backup.tar
停止连接到数据库的进程。让 GitLab 的其余部分保持运行：
sudo gitlab-ctl stop unicorn
sudo gitlab-ctl stop puma
sudo gitlab-ctl stop sidekiq
# Verify
sudo gitlab-ctl status
接下来，恢复备份，指定要恢复的备份的时间戳：
sudo gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce
接下来，/etc/gitlab/gitlab-secrets.json如有必要，恢复
重新配置、重启并检查 GitLab：
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart
sudo gitlab-rake gitlab:check SANITIZE=true
在 GitLab 13.1 及更高版本中，检查数据库值可以被解密，尤其是/etc/gitlab/gitlab-secrets.json在恢复时:
sudo gitlab-rake gitlab:doctor:secrets

#import导入裸存储库
[root@newgitlab git-data]# pwd
/var/opt/gitlab/git-data
[root@newgitlab git-data]# sudo -u git mkdir -p `pwd`/repository-import-20210804 
[root@gitlab Homsom.Java]# scp -r UserApprove.git/ root@192.168.13.75:/var/opt/gitlab/git-data/repository-import-20210804/G1/G2/
[root@newgitlab git-data]# chown -R git.git repository-import-20210804/
#--import
[root@newgitlab git-data]# sudo gitlab-rake gitlab:import:repos['/var/opt/gitlab/git-data/repository-import-20210804']
Processing /var/opt/gitlab/git-data/repository-import-20210804/G1/G2/UserApprove.git
 * Using namespace: G1/G2
 * Created UserApprove (G1/G2/UserApprove)

#邮件配置：
1. 找到 中的incoming_email部分/etc/gitlab/gitlab.rb，启用该功能并填写您的特定 IMAP 服务器和电子邮件帐户的详细信息:
[root@newgitlab ~]# grep -Ev '#|^$' /etc/gitlab/gitlab.rb | grep email
external_url 'http://192.168.13.75:8070'
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qiye.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "test@homsom.com"
gitlab_rails['smtp_password'] = "testtest"
gitlab_rails['smtp_domain'] = "smtp.qiye.163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_tls'] = true
gitlab_rails['smtp_pool'] = false
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'test@homsom.com'
2. 重新配置 GitLab 以使更改生效：
[root@newgitlab ~]# sudo gitlab-ctl reconfigure
3. 验证一切配置是否正确：
[root@newgitlab gitlab-workhorse]# gitlab-rails console
Notify.test_email('jack.li@homsom.com', 'title', 'content').deliver_now
4. 重启服务
[root@newgitlab ~]# sudo gitlab-ctl restart




#gitlab源码部署安装8.9.11
官方部署指导URL: https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/install/centos

支持的 Unix 发行版：
Ubuntu
Debian
CentOS
Red Hat Enterprise Linux（请使用 CentOS 软件包和说明）
Scientific Linux（请使用 CentOS 软件包和说明）
Oracle Linux（请使用 CentOS 软件包和说明）

Ruby 版本:
GitLab 需要 Ruby (MRI) 2.1.x，目前不适用于 2.2 或 2.3 版本。
您将不得不使用 Ruby 的标准 MRI 实现。我们喜欢JRuby和Rubinius，但 GitLab 需要几个具有本机扩展的 Gems。

硬件要求:
硬盘：您应该拥有至少与所有存储库组合占用的空间一样多的可用空间。
CPU:
1 个核心工作最多支持 100 个用户，但由于所有工作人员和后台作业都在同一核心上运行，因此应用程序可能会慢一点
2 核是推荐的核数，最多支持 500 个用户
4 核最多支持 2,000 个用户
8 核最多支持 5,000 个用户
16 核最多支持 10,000 个用户
32 个内核最多支持 20,000 个用户
64 核最多支持 40,000 个用户
内存：你至少需要 2GB 的可寻址内存（RAM + swap）来安装和使用 GitLab！操作系统和任何其他正在运行的应用程序也将使用内存，因此请记住，在运行 GitLab 之前至少需要 2GB 可用空间。使用较少的内存 GitLab 在重新配置运行期间会出现奇怪的错误，在使用过程中会出现 500 个错误
512MB RAM + 1.5GB 交换空间是绝对最小值，但我们强烈建议不要使用这种内存量。有关更多建议，请参阅下面的独角兽工人部分。
1GB RAM + 1GB swap 最多支持 100 个用户，但速度会很慢
2GB RAM是所有安装的推荐内存大小，最多支持 100 个用户
4GB RAM 最多支持 1,000 个用户
8GB RAM 最多支持 2,000 个用户
16GB RAM 最多支持 4,000 个用户
32GB RAM 最多支持 8,000 个用户
64GB RAM 最多支持 16,000 个用户
128GB RAM 最多支持 32,000 个用户

Gitlab Runner:
我们强烈建议不要在您计划安装 GitLab 的同一台机器上安装 GitLab Runner。根据您决定如何配置 GitLab Runner 以及在 CI 环境中使用哪些工具来练习应用程序，GitLab Runner 可能会消耗大量可用内存。如果您决定在同一台机器上运行 GitLab Runner 和 GitLab Rails 应用程序，上面提供的内存消耗计算将无效。
由于安全原因，将所有东西都安装在一台机器上也不安全——尤其是当你计划将 shell 执行器与 GitLab Runner 一起使用时。如果您打算使用 CI 功能，我们建议为每个 GitLab Runner 使用单独的机器。

建议配置要求：
Distribution      : CentOS 6.8 Minimal
GitLab version    : 8.9
Web Server        : Apache, Nginx
Init system       : sysvinit
Database          : MySQL, PostgreSQL
Contributors      : @nielsbasjes, @axilleas, @mairin, @ponsjuh, @yorn, @psftw, @etcet, @mdirkse, @nszceta, @herkalurk, @mjmaenpaa
Additional Notes  : In order to get a proper Ruby & Git setup we build them from source

GitLab 安装包括设置以下组件：
Install the base operating system (CentOS 6.8 Minimal) and Packages / Dependencies
Ruby
Go
System Users
Database
Redis
GitLab
Web server
Firewall

安装步骤：
1. 更新和添加基本软件和服务
[root@ha2 yum.repos.d]# cat base.repo 
[base]
name=centos6 base repos
baseurl=https://vault.centos.org/6.8/os/x86_64
gpgcheck=0
1.1 添加 EPEL 存储库
EPEL是 Fedora 项目基于志愿者的社区努力，旨在创建一个高质量的附加软件包存储库，以补充基于 Fedora 的 Red Hat Enterprise Linux (RHEL) 及其兼容的衍生产品，例如 CentOS 和 Scientific Linux。
作为 Fedora 打包社区的一部分，EPEL 包是 100% 免费/自由的开源软件 (FLOSS)。
root@gitlab yum.repos.d]# yum localinstall -y https://fedora-archive.ip-connect.vn.ua/epel/6/x86_64/epel-release-6-8.noarch.rpm
[root@gitlab yum.repos.d]# rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
[root@gitlab yum.repos.d]# rpm -qa gpg*
gpg-pubkey-0608b895-4bd22942
1.2 添加 Remi 的 RPM 存储库
Remi 的 RPM Repository是 Centos/RHEL 的非官方存储库，提供一些软件的最新版本。我们利用 Remi 的 RPM 存储库来获取 Redis 的最新版本。
[root@gitlab yum.repos.d]# wget -O /etc/pki/rpm-gpg/RPM-GPG-KEY-remi http://rpms.famillecollet.com/RPM-GPG-KEY-remi
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
[root@gitlab yum.repos.d]# rpm -qa gpg*
gpg-pubkey-00f97f56-467e318a
[root@gitlab yum.repos.d]# rpm -q --info gpg-pubkey-00f97f56-467e318a
现在安装该remi-release-6软件包，它将在您的系统上启用 remi-safe 存储库：
[root@gitlab yum.repos.d]# rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm
[root@gitlab yum.repos.d]# yum repolist
repo id                  repo name                                                                  status
base                     centos6.8 repos                                                             6,696
epel                     Extra Packages for Enterprise Linux 6 - x86_64                             12,581
remi-safe                Safe Remi's RPM repository for Enterprise Linux 6 - x86_64                  2,973
repolist: 22,250

2. 安装 GitLab 所需的工具
[root@gitlab yum.repos.d]# yum -y groupinstall 'Development Tools'
[root@gitlab yum.repos.d]# yum -y install readline readline-devel ncurses-devel gdbm-devel glibc-devel tcl-devel openssl-devel curl-devel expat-devel db4-devel byacc sqlite-devel libyaml libyaml-devel libffi libffi-devel libxml2 libxml2-devel libxslt libxslt-devel libicu libicu-devel system-config-firewall-tui redis sudo wget crontabs logwatch logrotate perl-Time-HiRes git cmake libcom_err-devel.i686 libcom_err-devel.x86_64 nodejs python-docutils

3. 安装邮件服务器
为了接收邮件通知，请确保安装邮件服务器。推荐的一个是 postfix，默认已经安装，未安装时请安装它:
[root@gitlab yum.repos.d]# yum -y install postfix

4. 安装vim并配置默认编辑器
[root@gitlab ~]# yum install -y vim-enhanced
[root@gitlab ~]# ln -s /usr/bin/vim /usr/bin/editor

5. 从源代码安装新版本Git
5.1 安装 Git 编译的必备文件：
[root@gitlab ~]# yum install -y zlib-devel perl-CPAN gettext curl-devel expat-devel gettext-devel openssl-devel
5.2 克隆 Gitaly 存储库以编译和安装 Git：
如果要安装 GitLab 13.6，请使用分支名称13-6-stable
[root@gitlab ~]# git clone https://gitlab.com/gitlab-org/git.git -b v2.32.0 /tmp/git
[root@gitlab ~]# cd /tmp/git
[root@gitlab git]# make prefix=/usr/local all
[root@gitlab git]# make prefix=/usr/local install
[root@gitlab git]# /usr/local/bin/git version 
git version 2.32.0

6. Ruby安装
6.1 在生产中使用 ruby​​ 版本管理器，如RVM、rbenv或chruby与 GitLab 经常导致难以诊断的问题。不支持版本管理器，我们强烈建议大家按照以下说明使用系统 ruby​​。
如果存在，请删除旧的 Ruby 1.8 包。GitLab 仅支持 Ruby 2.1 发布系列：
[root@gitlab git]# yum remove -y ruby
删除任何其他 Ruby 版本（如果它仍然存在）：
cd <your-ruby-source-path>
make uninstall
6.2 下载 Ruby 并编译它：
[root@gitlab ~]# mkdir /tmp/ruby && cd /tmp/ruby
[root@gitlab ruby]# curl --progress-bar https://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.9.tar.gz | tar xz
[root@gitlab ruby]# cd ruby-2.1.9
[root@gitlab ruby-2.1.9]# ./configure --disable-install-rdoc
[root@gitlab ruby-2.1.9]# make
[root@gitlab ruby-2.1.9]# make prefix=/usr/local install
[root@gitlab ruby-2.1.9]# ruby --version 
ruby 2.1.9p490 (2016-03-30 revision 54437) [x86_64-linux]
6.3 使用Gem安装Bundler ：
[root@gitlab gitlab]# gem source --add https://rubygems.org/
[root@gitlab gitlab]# gem source list
[root@gitlab gitlab]# gem install bundler -v 1.17.3 --no-doc 
[root@gitlab ruby-2.1.9]# gem list | grep bundler
bundler (1.17.3)


7. Go安装
从 GitLab 8.0 开始，Git HTTP 请求由 gitlab-workhorse（以前称为 gitlab-git-http-server）处理。这是一个用 Go 编写的小守护进程。要安装 gitlab-workhorse，我们需要一个 Go 编译器。
[root@gitlab ~]# yum install -y golang golang-bin golang-src

8. 创建gitlab系统用户
8.1 为 Gitlab创建一个用户git：
[root@gitlab ~]# useradd --system --shell /bin/bash --comment 'GitLab' --create-home --home-dir /home/git/ git
8.2 配置git执行命令权限 
重要提示：为了包含/usr/local/bin到 git 用户的 PATH，一种方法是编辑 sudoers 文件。作为 root 运行：
然后搜索这一行：Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin
增加为执行路径为：Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin

9. 数据库
支持PostgreSQL（推荐）和MySQL，由于各种问题，我们不建议使用 MySQL。由于熟悉Mysql，这里使用mysql
9.1 安装mysql并启用mysqld服务以在启动时启动：
[root@gitlab ~]# yum install -y mysql-server mysql-devel
[root@gitlab ~]# chkconfig mysqld on
[root@gitlab ~]# service mysqld start
确保您拥有 MySQL 5.5.14 或更高版本：
mysql> select version();
+-----------+
| version() |
+-----------+
| 5.1.73    |
+-----------+
安全安装：
mysql_secure_installation
9.2 为 GitLab 创建一个用户（将下面命令中的 $password 更改为您选择的真实密码）
mysql> CREATE USER 'git'@'localhost' IDENTIFIED BY 'gitlab@homsom';
mysql> CREATE USER 'git'@'%' IDENTIFIED BY 'gitlab@homsom';
设置配置存储引擎：
mysql> SET storage_engine=INNODB;
mysql> show engines;
InnoDB     | DEFAULT
9.3 创建 GitLab 生产数据库：
mysql> CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
授予 GitLab 用户必要的表权限：
mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES ON `gitlabhq_production`.* TO 'git'@'localhost';
mysql> GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER, LOCK TABLES, REFERENCES ON `gitlabhq_production`.* TO 'git'@'%';
尝试使用新用户连接到新数据库：
[root@gitlab ~]# sudo -u git -H mysql -u git -p -D gitlabhq_production
注：-H 表示切换到git家目录

10. 安装Redis
10.1 GitLab 至少需要 Redis 2.8
[root@gitlab ~]# redis-server --version
Redis server v=3.2.12 sha=00000000:0 malloc=jemalloc-3.6.0 bits=64 build=b2d74fe5fff7657d
[root@gitlab ~]# chkconfig redis on 
10.2 配置 redis 以使用套接字：
[root@gitlab ~]# cp /etc/redis.conf /etc/redis.conf.orig
通过将“端口”设置为 0 来禁用 Redis 侦听 TCP：
[root@gitlab ~]# sed 's/^port .*/port 0/' /etc/redis.conf.orig | sudo tee /etc/redis.conf
为默认 CentOS 路径启用 Redis 套接字：
[root@gitlab ~]# echo 'unixsocket /var/run/redis/redis.sock' | sudo tee -a /etc/redis.conf
[root@gitlab ~]# echo -e 'unixsocketperm 0770' | sudo tee -a /etc/redis.conf
创建包含套接字的目录:
[root@gitlab ~]# mkdir -p /var/run/redis
[root@gitlab ~]# chown redis:redis /var/run/redis
[root@gitlab ~]# chmod 755 /var/run/redis
启动redis:
[root@gitlab ~]# service redis restart
[root@gitlab ~]# ls -l /var/run/redis/redis.sock 
srwxrwx---. 1 redis redis 0 Jul 28 22:25 /var/run/redis/redis.sock
将 git 添加到 redis 组：
[root@gitlab ~]# usermod -aG redis git
[root@gitlab ~]# id git 
uid=497(git) gid=497(git) groups=497(git),499(redis)

11. 安装GitLab
11.1 克隆gitlab源：
[root@gitlab ~]# cd /home/git
[root@gitlab git]# sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-ce.git -b 8-9-stable gitlab
注：项目“gitlab-org/gitlab-ce”已被移至“gitlab-org/gitlab-foss”
11.2 配置gitlab
[root@gitlab git]# cd /home/git/gitlab
[root@gitlab gitlab]# sudo -u git -H cp config/gitlab.yml.example config/gitlab.yml
[root@gitlab gitlab]# sudo -u git -H editor config/gitlab.yml
---
32     host: localhost
33     port: 80
475     bin_path: /usr/local/bin/git
---
11.3 复制secrets file
[root@gitlab gitlab]# sudo -u git -H cp config/secrets.yml.example config/secrets.yml
[root@gitlab gitlab]# sudo -u git -H chmod 0600 config/secrets.yml
11.4 确保GitLab可以写入log/和tmp/目录
[root@gitlab gitlab]# sudo chown -R git log/
[root@gitlab gitlab]# sudo chown -R git tmp/
[root@gitlab gitlab]# sudo chmod -R u+rwX,go-w log/
[root@gitlab gitlab]# sudo chmod -R u+rwX tmp/
11.5 确保GitLab可以写入tmp/pid /和tmp/sockets/目录
[root@gitlab gitlab]# sudo chmod -R u+rwX tmp/pids/
[root@gitlab gitlab]# sudo chmod -R u+rwX tmp/sockets/
11.6 创建public/upload /目录
[root@gitlab gitlab]# sudo -u git -H mkdir public/uploads/
11.7 确保只有GitLab用户可以访问public/upload /目录,现在public/upload中的文件由gitlab-workhorse提供
[root@gitlab gitlab]# sudo chmod 0700 public/uploads
11.8 创建和配置/home/git/repositories
[root@gitlab gitlab]# sudo -u git -H mkdir -p /home/git/repositories/
[root@gitlab gitlab]# sudo chmod ug+rwX,o-rwx /home/git/repositories/
[root@gitlab gitlab]# ls -l /home/git/
total 8
drwxr-xr-x. 22 git git 4096 Jul 28 22:35 gitlab
drwxrwx---.  2 git git 4096 Jul 28 22:48 repositories
11.9 更改存储CI构建跟踪的目录的权限
[root@gitlab gitlab]# sudo chmod -R u+rwX builds/
11.10 更改存储CI工件的目录的权限
[root@gitlab gitlab]# sudo chmod -R u+rwX shared/artifacts/
11.11 复制config/unicorn.rb.example配置
[root@gitlab gitlab]# sudo -u git -H cp config/unicorn.rb.example config/unicorn.rb
查看CPU核心数
[root@gitlab gitlab]# nproc
4
将worker的数量设置为至少内核数
[root@gitlab gitlab]# sudo -u git -H editor config/unicorn.rb
worker_processes 3
11.12 复制config/initializers/rack_attack.rb.example配置示例
[root@gitlab gitlab]# sudo -u git -H cp config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb
11.13 为Git user配置Git全局设置
[root@gitlab gitlab]# sudo -u git -H git config --global core.autocrlf input
11.14 禁用'git gc——auto'，因为GitLab已经在需要的时候运行'git gc'了
[root@gitlab gitlab]# sudo -u git -H git config --global gc.auto 0
11.15 配置Redis连接设置
[root@gitlab gitlab]# sudo -u git -H cp config/resque.yml.example config/resque.yml
[root@gitlab gitlab]# sudo -u git -H editor config/resque.yml
development: redis://localhost:6379
test: redis://localhost:6379
production: unix:/var/run/redis/redis.sock

12 配置 GitLab 数据库设置
[root@gitlab gitlab]# sudo -u git cp config/database.yml.mysql config/database.yml
--您只需要调整生产设置(第一部分)。
[root@gitlab gitlab]# sudo -u git -H editor config/database.yml
---
production:
  adapter: mysql2
  encoding: utf8
  collation: utf8_general_ci
  reconnect: false
  database: gitlabhq_production
  pool: 10
  username: git
  password: "gitlab@homsom"
  # host: localhost
  socket: /var/lib/mysql/mysql.sock
---
[root@gitlab gitlab]# sudo -u git -H chmod o-rwx config/database.yml

13 安装 Gems  ----这一步是关键，我在安装时不能安装成功，因为有些包ruby源不提供了，所以下载不下来，导致后面的步骤都失败，后面的步骤是按照部署指导URL复制出来的。
从 bundler 1.5.2 开始，您可以调用bundle install -jN（N您的处理器核心数）并享受并行 gems 安装，完成时间的差异可测量（约快 60%）。使用 来检查您的核心数nproc。
[root@gitlab gitlab]# cd /home/git/gitlab
[root@gitlab gitlab]# sudo -u git -H bundle install -j4 --deployment --without development test postgres aws kerberos
注意：如果要使用 Kerberos 进行用户身份验证，请省略上面--without的kerberos选项。

14 安装GitLab shell
GitLab Shell 是专门为 GitLab 开发的 SSH 访问和存储库管理软件。
[root@gitlab gitlab]# sudo -u git -H bundle exec rake gitlab:shell:install[v3.0.0] REDIS_URL=unix:/var/run/redis/redis.sock RAILS_ENV=production
[root@gitlab gitlab]# sudo -u git -H editor /home/git/gitlab-shell/config.yml

15. 安装 gitlab-workhorse
15.1 克隆gitlab-workhorse
[root@gitlab gitlab]# cd /home/git
[root@gitlab git]# sudo -u git -H git clone https://gitlab.com/gitlab-org/gitlab-workhorse.git
[root@gitlab git]# cd gitlab-workhorse
[root@gitlab gitlab-workhorse]# sudo -u git -H git checkout v0.7.5
[root@gitlab gitlab-workhorse]# sudo -u git -H make
15.2 初始化数据库并激活高级功能
[root@gitlab gitlab-workhorse]# cd /home/git/gitlab
[root@gitlab gitlab]# sudo -u git -H bundle exec rake gitlab:setup RAILS_ENV=production

16. 安装初始化脚本
16.1 下载初始化脚本（将是/etc/init.d/gitlab）
[root@gitlab gitlab]# cp lib/support/init.d/gitlab /etc/init.d/gitlab
[root@gitlab gitlab]# chkconfig gitlab on
[root@gitlab gitlab]# cp lib/support/logrotate/gitlab /etc/logrotate.d/gitlab
检查 GitLab 及其环境是否配置正确：
[root@gitlab gitlab]# sudo -u git -H bundle exec rake gitlab:env:info RAILS_ENV=production
编译资产:
[root@gitlab gitlab]# sudo -u git -H bundle exec rake assets:precompile RAILS_ENV=production
启动您的 GitLab 实例:
[root@gitlab gitlab]# service gitlab start

17. 配置网络服务器
httpd:
GitLab-Workhorse配置：
[root@gitlab gitlab]# cat /etc/default/gitlab
gitlab_workhorse_options="-listenUmask 0 -listenNetwork tcp -listenAddr 127.0.0.1:8181 -authBackend http://127.0.0.1:8080"
重启gitlab:
[root@gitlab gitlab]# service gitlab restart

http协议方式：
1. 我们将使用mod_proxy安装 apache 时默认加载的模块来配置apache：
yum -y install httpd
chkconfig httpd on
wget -O /etc/httpd/conf.d/gitlab.conf https://gitlab.com/gitlab-org/gitlab-recipes/raw/master/web-server/apache/gitlab-apache22.conf
sed -i 's/logs\///g' /etc/httpd/conf.d/gitlab.conf
2. 更改配置文件/etc/httpd/conf.d/gitlab.conf将YOUR_SERVER_FQDN更改为您的 FQDN

为确保您没有遗漏任何内容，请进行更彻底的检查：
cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:check RAILS_ENV=production


#源代码编译安装备份和恢复
[root@localhost git]# mkdir -p /data/backup
[root@localhost git]# mkdir -p /windows/gitlab
[root@localhost git]# mount -t cifs -o username=linuxuser,password=linuxuser,dir_mode=0777,file_mode=0777 //192.168.13.182/HomsomAuto /windows
---
[root@localhost gitlab]# vim /home/git/gitlab/config/gitlab.yml
  backup:
    path: "/data/backup"
    archive_permissions: 0644
---
[root@localhost gitlab]# vim /home/git/gitlab/config/gitlab.yml
  backup:
    path: "/data/backup"
    archive_permissions: 0644
    upload:
      connection:
        provider: Local
        local_root: /windows/gitlab
      remote_directory: 'gitlab_backups'
---

##备份：
[root@localhost backup]# cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production

##恢复：
注：由于gitlab版本较老，源码安装时有些依赖包不支持，所以不能部署一模一样的环境版本，所以将gitlab快照后导出恢复，从而复制出了一份一模一样的环境。
您只能将备份恢复到与您创建它的 GitLab 版本完全相同的版本，例如 8.9.11。
首先确保您的备份 tar 文件位于gitlab.rb配置中描述的备份目录中 gitlab_rails['backup_path']。默认值为 /homt/git/gitlab/tmp/backups
[root@localhost ~]# \cp /windows/gitlab/1627612057_gitlab_backup.tar /data/backup/
[root@localhost ~]# chown git.git /data/backup/1627612057_gitlab_backup.tar 
[root@localhost ~]# chmod 644 /data/backup/1627612057_gitlab_backup.tar
[root@localhost ~]# sudo service gitlab stop
Shutting down GitLab Unicorn
Shutting down GitLab Sidekiq
Shutting down GitLab Workhorse
[root@localhost gitlab]# sudo -u git -H bundle exec rake gitlab:backup:restore RAILS_ENV=production BACKUP=1627612057
Unpacking backup ... done
Before restoring the database we recommend removing all existing
tables to avoid future upgrade problems. Be aware that if you have
custom tables in the GitLab database these tables and all data will be
removed.

Do you want to continue (yes/no)? yes    --提示在恢复数据库之前，我们建议删除所有现有的数据库表，以避免将来的升级问题。要注意，如果你有自定义表，那么所有数据将会删除。
This will rebuild an authorized_keys file.
You will lose any data stored in authorized_keys file.
Do you want to continue (yes/no)? yes   --这将重新生成authorized_keys文件。您将丢失存储在authorized_keys文件中的所有数据。
[root@localhost gitlab]# sudo service gitlab start  --开启服务



#自动备份脚本
[root@localhost ~]# cat backupGitlab.sh
-------------
#!/bin/sh
#description: auto backup gitlab to local and remote directory
#versionForGitlab: 8.9.11,source code compile installed. 
#date: 20210729
#author: JackLi

gitlabHome='/home/git/gitlab'
localBackupDirectory='/data/backup'
remoteBackupDirectory='/windows/gitlab'
logFile=${localBackupDirectory}/gitlabBackup.log
dateFormat="date +'%Y-%m-%d %H:%M:%S'"
backupFileSubfix='gitlab_backup.tar'

# mkdir local backup directory.
mkdir -p ${localBackupDirectory} && (chown -R root.git ${localBackupDirectory} && chmod -R 775 ${localBackupDirectory} ) || (echo "`eval ${dateFormat}`: create directory ${localBackupDirectory} and config prvileges failure." | tee -a ${logFile}; exit 10)

#test remote directory
df -h | grep /windows >& /dev/null || (echo "`eval ${dateFormat}`: ${remoteBackupDirectory} directory not exists." >> ${logFile}; exit 10)

#backup gitlab
echo "`eval ${dateFormat}`: start bakcup gitlab to local ${localBackupDirectory}......." >> ${logFile}
cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production
if [ $? == 0 ];then
	echo "`eval ${dateFormat}`: bakcup gitlab to local ${localBackupDirectory} success." >> ${logFile}
	echo "`eval ${dateFormat}`: start bakcup gitlab to remote ${remoteBackupDirectory}......." >> ${logFile}
	backupFileName=`ls ${localBackupDirectory} | grep ${backupFileSubfix} | sort -r | head -n 1`
	\cp -a ${localBackupDirectory}/${backupFileName} ${remoteBackupDirectory}
	if [ $? == 0 ];then
		echo "`eval ${dateFormat}`: bakcup gitlab to remote ${remoteBackupDirectory} success." >> ${logFile}
		for i in `ls ${localBackupDirectory} | grep ${backupFileSubfix} | grep -v ${backupFileName}`;do
			sudo rm -rf ${localBackupDirectory}/${i} 
			[ $? == 0 ] && echo "`eval ${dateFormat}`: delete local ${localBackupDirectory}/${i} success." >> ${logFile} || echo "`eval ${dateFormat}`: delete local ${localBackupDirectory}/${i} failure." >> ${logFile}
		done
	else
		echo "`eval ${dateFormat}`: bakcup gitlab to remote ${remoteBackupDirectory} failure." >> ${logFile}
		exit 10
	fi
else
	echo "`eval ${dateFormat}`: bakcup gitlab to local ${localBackupDirectory} failure." >> ${logFile}
	exit 10
fi

#backup secret file
if ! [ -e "${remoteBackupDirectory}/.secret" ];then
	echo "`eval ${dateFormat}`: bakcup gitlab secret file to remote ${remoteBackupDirectory} ......." >> ${logFile}
	sudo \cp -a ${gitlabHome}/.secret ${remoteBackupDirectory}
	[ $? == 0 ] && echo "`eval ${dateFormat}`: bakcup gitlab secret file to remote ${remoteBackupDirectory} success." >> ${logFile} || echo "`eval ${dateFormat}`: bakcup gitlab secret file to remote ${remoteBackupDirectory} failure." >> ${logFile}
else
	echo "`eval ${dateFormat}`: gitlab secret file already exists in remote ${remoteBackupDirectory}!" >> ${logFile}
fi

echo '' >> ${logFile}
-------------


</pre>
