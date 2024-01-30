

# gitlab



## RPM包方式部署



**RPM包方式部署**



```bash
# 配置源：

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
alertmanager  bootstrapped  git-data   gitlab-exporter  gitlab-shell      grafana    nginx          postgres-exporter  test              redis
backups       gitaly        gitlab-ci  gitlab-rails     gitlab-workhorse  logrotate  node-exporter  postgresql         public_attributes.json  trusted-certs-directory-hash
```



### 备份和恢复



**gitlab配置**

```bash
root@git:/# cat /etc/gitlab/gitlab.rb
###### email
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qiye.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "test@test.com"
gitlab_rails['smtp_password'] = "pass"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_tls'] = true
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'test@test.com'
gitlab_rails['gitlab_email_reply_to'] = 'test@test.com'
gitlab_rails['smtp_pool'] = true
gitlab_rails['time_zone'] = 'Asia/Shanghai'
######


###### base config
external_url 'http://192.168.13.211:80'
gitlab_rails['gitlab_shell_ssh_port'] = 22


###### backup config
gitlab_rails['manage_backup_path'] = true
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_archive_permissions'] = 0644
gitlab_rails['backup_keep_time']= 2592000



###### use external test
test['enable'] = false
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '192.168.13.0/24']
gitlab_rails['test_address'] = '192.168.13.236:9090'

# Workhorse
gitlab_workhorse['test_listen_addr'] = "0.0.0.0:9229"

# Rails nodes
gitlab_exporter['listen_address'] = '0.0.0.0'
gitlab_exporter['listen_port'] = '9168'

# Sidekiq nodes
sidekiq['listen_address'] = '0.0.0.0'

# Redis nodes
redis_exporter['listen_address'] = '0.0.0.0:9121'

# PostgreSQL nodes
postgres_exporter['listen_address'] = '0.0.0.0:9187'

# Gitaly nodes
gitaly['test_listen_addr'] = "0.0.0.0:9236"

# Nginx
nginx['status']['options'] = {
      "server_tokens" => "off",
      "access_log" => "off",
      "allow" => "192.168.13.236",
      "deny" => "all",
}
######
```







您只能将备份还原到与创建它的 GitLab完全相同的版本和类型 (CE/EE)。将存储库从一台服务器迁移到另一台服务器的最佳方法是通过备份还原。

警告：GitLab 不会备份未存储在文件系统中的项目



#### 备份

GitLab 12.2 或更高版本：sudo gitlab-backup create

GitLab 12.1 及更早版本：sudo gitlab-rake gitlab:backup:create



**备份位置：**

备份存档保存在文件中backup_path指定的目录下：

vim /etc/gitlab/gitlab.rb

gitlab_rails['manage_backup_path'] = true

gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"

警告：GitLab 不备份任何配置文件、SSL 证书或系统文件



**存储配置文件**

GitLab 提供的备份 Rake 任务不会存储您的配置文件。这样做的主要原因是您的数据库包含的项目包括用于两因素身份验证的加密信息和 CI/CD安全变量。将加密信息存储在与其密钥相同的位置首先违背了使用加密的目的。

警告：secrets 文件对于保存您的数据库加密密钥至关重要。你必须备份:

/etc/gitlab/gitlab-secrets.json

/etc/gitlab/gitlab.rb



**备份策略选项**

当tar读取数据时数据发生变化，file changed as we read it可能会发生错误，并导致备份过程失败。为了解决这个问题，8.17 引入了一种名为copy. 该策略在调用tar和之前将数据文件复制到一个临时位置gzip，以避免错误。

sudo gitlab-backup create STRATEGY=copy

GitLab 12.1 及更早版本的用户应改用该命令gitlab-rake gitlab:backup:create。



**备份文件名**

默认情况下，备份文件是根据上一个备份时间戳部分中的规范创建的。但是，您可以通过设置BACKUP环境变量来覆盖文件名[TIMESTAMP]的一部分。例如：
sudo gitlab-backup create BACKUP=dump

生成的文件名为dump_gitlab_backup.tar. 这对于使用 rsync 和增量备份的系统很有用，并且可以显着提高传输速度。



**确认档案可以转移**

为确保生成的存档可通过 rsync 传输，您可以设置该GZIP_RSYNCABLE=yes选项。这会将--rsyncable选项设置为gzip，这仅在与设置备份文件名选项结合使用时才有用。

sudo gitlab-backup create BACKUP=dump GZIP_RSYNCABLE=yes



**在还原期间禁用提示**

在从备份还原期间，还原脚本可能会在继续之前要求确认。如果您希望禁用这些提示，您可以将GITLAB_ASSUME_YES环境变量设置为1

sudo GITLAB_ASSUME_YES=1 gitlab-backup restore



**同时备份 Git 存储库**

使用多个存储库存储时，可以同时备份存储库以帮助充分利用 CPU 时间

GITLAB_BACKUP_MAX_CONCURRENCY：同时备份的最大项目数。默认为1

GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY：每个存储上同时备份的最大项目数。这允许存储库备份跨存储分布。默认为1

sudo gitlab-backup create GITLAB_BACKUP_MAX_CONCURRENCY=4 GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY=1

```bash
root@git:/# gitlab-backup create GITLAB_BACKUP_MAX_CONCURRENCY=4 GITLAB_BACKUP_MAX_STORAGE_CONCURRENCY=1

root@git:/# ls -lh /var/opt/gitlab/backups/
total 5.9G
-rw-r--r-- 1 git git 5.9G Jan 25 07:23 1706167370_2024_01_25_15.11.13_gitlab_backup.tar

```



#### 恢复

您只能将备份还原到您在其上创建它的 GitLab的完全相同版本和类型 (CE/EE)

如果您的备份与当前安装的版本不同，则必须在恢复备份之前降级 GitLab 安装。



**Omnibus GitLab 恢复**

您已经安装了与创建备份完全相同的 GitLab Omnibus版本和类型 (CE/EE)。你sudo gitlab-ctl reconfigure至少跑过一次，GitLab 正在运行。如果没有，请使用

sudo gitlab-ctl start

首先确保您的备份 tar 文件位于gitlab.rb配置中描述的备份目录中gitlab_rails['backup_path']。默认为/var/opt/gitlab/backups。它需要归git用户所有。

sudo cp 1706167370_2024_01_25_15.11.13_gitlab_backup.tar /var/opt/gitlab/backups/

sudo chown git.git /var/opt/gitlab/backups/1706167370_2024_01_25_15.11.13_gitlab_backup.tar



```bash
# 停止连接到数据库的进程
root@git:/# gitlab-ctl stop unicorn
root@git:/# gitlab-ctl stop puma
ok: down: puma: 0s, normally up
root@git:/# gitlab-ctl stop sidekiq
ok: down: sidekiq: 0s, normally up
root@git:/# gitlab-ctl status
run: alertmanager: (pid 15141) 1107s; run: log: (pid 877) 88354s
run: gitaly: (pid 15157) 1106s; run: log: (pid 323) 88408s
run: gitlab-exporter: (pid 15182) 1106s; run: log: (pid 592) 88366s
run: gitlab-kas: (pid 15434) 1095s; run: log: (pid 465) 88396s
run: gitlab-workhorse: (pid 15450) 1095s; run: log: (pid 548) 88376s
run: logrotate: (pid 15469) 1095s; run: log: (pid 271) 88418s
run: nginx: (pid 15519) 1094s; run: log: (pid 574) 88372s
run: postgres-exporter: (pid 15588) 1094s; run: log: (pid 897) 88346s
run: postgresql: (pid 15734) 1094s; run: log: (pid 447) 88401s
down: puma: 13s, normally up; run: log: (pid 478) 88388s
run: redis: (pid 15816) 1092s; run: log: (pid 284) 88414s
run: redis-exporter: (pid 15823) 1092s; run: log: (pid 608) 88358s
down: sidekiq: 3s, normally up; run: log: (pid 497) 88384s
run: sshd: (pid 15838) 1089s; run: log: (pid 30) 88432s

# 查看备份文件，及目录权限
root@git:/# ls -l /var/opt/gitlab/backups/
total 6098312
-rw-r--r-- 1 git git 6244669440 Jan 25 07:23 1706167370_2024_01_25_15.11.13_gitlab_backup.tar
# 恢复
root@git:/# gitlab-backup restore BACKUP=1706167370_2024_01_25_15.11.13
# BACKUP=备份归档文件时间戳 ： 使用指定的备份归档文件进行恢复。
# force=yes ：在恢复过程中不再进行交互式询问，类似使用HereDocument缺省输入yes

# 恢复配置文件
root@git:/# cp gitlab-secrets.json gitlab.rb /etc/gitlab/
root@git:/# gitlab-ctl reconfigure
root@git:/# gitlab-ctl restart
ok: run: alertmanager: (pid 1226) 1s
ok: run: gitaly: (pid 1240) 1s
ok: run: gitlab-exporter: (pid 1269) 0s
ok: run: gitlab-kas: (pid 1273) 0s
ok: run: gitlab-workhorse: (pid 1287) 1s
ok: run: logrotate: (pid 1303) 0s
ok: run: nginx: (pid 1309) 0s
ok: run: postgres-exporter: (pid 1329) 1s
ok: run: postgresql: (pid 1338) 0s
ok: run: puma: (pid 1347) 1s
ok: run: redis: (pid 1352) 0s
ok: run: redis-exporter: (pid 1359) 1s
ok: run: sidekiq: (pid 1366) 0s
ok: run: sshd: (pid 1372) 0s
# 检查服务
root@git:/# gitlab-rake gitlab:check SANITIZE=true

# 在 GitLab 13.1 及更高版本中，检查数据库值是否可以被解密，尤其是/etc/gitlab/gitlab-secrets.json在恢复时:
root@git:/# gitlab-rake gitlab:doctor:secrets
I, [2024-01-25T07:48:47.499444 #1762]  INFO -- : Checking encrypted values in the database
I, [2024-01-25T07:48:52.997455 #1762]  INFO -- : - Ci::InstanceVariable failures: 0
I, [2024-01-25T07:48:53.002758 #1762]  INFO -- : - Ci::PipelineVariable failures: 0
I, [2024-01-25T07:48:53.008051 #1762]  INFO -- : - Ci::PipelineScheduleVariable failures: 0
I, [2024-01-25T07:48:53.013345 #1762]  INFO -- : - Ci::Variable failures: 0
I, [2024-01-25T07:48:53.018754 #1762]  INFO -- : - Ci::GroupVariable failures: 0
I, [2024-01-25T07:48:53.022551 #1762]  INFO -- : - Ci::JobVariable failures: 0
I, [2024-01-25T07:48:53.026318 #1762]  INFO -- : - Ci::Trigger failures: 0
I, [2024-01-25T07:48:53.027837 #1762]  INFO -- : - Gitlab::BackgroundMigration::EncryptCiTriggerToken::CiTrigger failures: 0
I, [2024-01-25T07:48:53.044861 #1762]  INFO -- : - ApplicationSetting failures: 0
I, [2024-01-25T07:48:53.577136 #1762]  INFO -- : - User failures: 0
I, [2024-01-25T07:48:53.582713 #1762]  INFO -- : - Clusters::Platforms::Kubernetes failures: 0
I, [2024-01-25T07:48:53.601500 #1762]  INFO -- : - Snippet failures: 0
I, [2024-01-25T07:48:53.603147 #1762]  INFO -- : - PersonalSnippet failures: 0
I, [2024-01-25T07:48:53.604670 #1762]  INFO -- : - ProjectSnippet failures: 0
I, [2024-01-25T07:48:53.622879 #1762]  INFO -- : - Integration failures: 0
I, [2024-01-25T07:48:53.625064 #1762]  INFO -- : - Integrations::AppleAppStore failures: 0
I, [2024-01-25T07:48:53.626958 #1762]  INFO -- : - Integrations::Asana failures: 0
I, [2024-01-25T07:48:53.628833 #1762]  INFO -- : - Integrations::Assembla failures: 0
I, [2024-01-25T07:48:53.630903 #1762]  INFO -- : - Integrations::BaseCi failures: 0
I, [2024-01-25T07:48:53.632830 #1762]  INFO -- : - Integrations::Bamboo failures: 0
I, [2024-01-25T07:48:53.634680 #1762]  INFO -- : - Integrations::Buildkite failures: 0
I, [2024-01-25T07:48:53.636523 #1762]  INFO -- : - Integrations::DroneCi failures: 0
I, [2024-01-25T07:48:53.638419 #1762]  INFO -- : - Integrations::Jenkins failures: 0
I, [2024-01-25T07:48:53.640282 #1762]  INFO -- : - Integrations::Teamcity failures: 0
I, [2024-01-25T07:48:53.642119 #1762]  INFO -- : - Integrations::MockCi failures: 0
I, [2024-01-25T07:48:53.644201 #1762]  INFO -- : - Integrations::BaseIssueTracker failures: 0
I, [2024-01-25T07:48:53.646046 #1762]  INFO -- : - Integrations::Bugzilla failures: 0
I, [2024-01-25T07:48:53.647924 #1762]  INFO -- : - Integrations::CustomIssueTracker failures: 0
I, [2024-01-25T07:48:53.649791 #1762]  INFO -- : - Integrations::Ewm failures: 0
I, [2024-01-25T07:48:53.651649 #1762]  INFO -- : - Integrations::Jira failures: 0
I, [2024-01-25T07:48:53.653522 #1762]  INFO -- : - Integrations::Redmine failures: 0
I, [2024-01-25T07:48:53.655370 #1762]  INFO -- : - Integrations::Youtrack failures: 0
I, [2024-01-25T07:48:53.657194 #1762]  INFO -- : - Integrations::Zentao failures: 0
I, [2024-01-25T07:48:53.659089 #1762]  INFO -- : - Integrations::Campfire failures: 0
I, [2024-01-25T07:48:53.661012 #1762]  INFO -- : - Integrations::BaseThirdPartyWiki failures: 0
I, [2024-01-25T07:48:53.662891 #1762]  INFO -- : - Integrations::Confluence failures: 0
I, [2024-01-25T07:48:53.664754 #1762]  INFO -- : - Integrations::Shimo failures: 0
I, [2024-01-25T07:48:53.666623 #1762]  INFO -- : - Integrations::Datadog failures: 0
I, [2024-01-25T07:48:53.668770 #1762]  INFO -- : - Integrations::BaseChatNotification failures: 0
I, [2024-01-25T07:48:53.670668 #1762]  INFO -- : - Integrations::Discord failures: 0
I, [2024-01-25T07:48:53.672522 #1762]  INFO -- : - Integrations::HangoutsChat failures: 0
I, [2024-01-25T07:48:53.674543 #1762]  INFO -- : - Integrations::Mattermost failures: 0
I, [2024-01-25T07:48:53.676399 #1762]  INFO -- : - Integrations::MicrosoftTeams failures: 0
I, [2024-01-25T07:48:53.678336 #1762]  INFO -- : - Integrations::BaseSlackNotification failures: 0
I, [2024-01-25T07:48:53.680170 #1762]  INFO -- : - Integrations::Slack failures: 0
I, [2024-01-25T07:48:53.682056 #1762]  INFO -- : - Integrations::Pumble failures: 0
I, [2024-01-25T07:48:53.684124 #1762]  INFO -- : - Integrations::UnifyCircuit failures: 0
I, [2024-01-25T07:48:53.685996 #1762]  INFO -- : - Integrations::WebexTeams failures: 0
I, [2024-01-25T07:48:53.687872 #1762]  INFO -- : - Integrations::EmailsOnPush failures: 0
I, [2024-01-25T07:48:53.689963 #1762]  INFO -- : - Integrations::ExternalWiki failures: 0
I, [2024-01-25T07:48:53.691814 #1762]  INFO -- : - Integrations::GooglePlay failures: 0
I, [2024-01-25T07:48:53.693685 #1762]  INFO -- : - Integrations::Harbor failures: 0
I, [2024-01-25T07:48:53.695534 #1762]  INFO -- : - Integrations::Irker failures: 0
I, [2024-01-25T07:48:53.697506 #1762]  INFO -- : - Integrations::BaseSlashCommands failures: 0
I, [2024-01-25T07:48:53.699413 #1762]  INFO -- : - Integrations::MattermostSlashCommands failures: 0
I, [2024-01-25T07:48:53.701268 #1762]  INFO -- : - Integrations::SlackSlashCommands failures: 0
I, [2024-01-25T07:48:53.703120 #1762]  INFO -- : - Integrations::Packagist failures: 0
I, [2024-01-25T07:48:53.705000 #1762]  INFO -- : - Integrations::PipelinesEmail failures: 0
I, [2024-01-25T07:48:53.706876 #1762]  INFO -- : - Integrations::Pivotaltracker failures: 0
I, [2024-01-25T07:48:53.708795 #1762]  INFO -- : - Integrations::BaseMonitoring failures: 0
I, [2024-01-25T07:48:53.710644 #1762]  INFO -- : - Integrations::Prometheus failures: 0
I, [2024-01-25T07:48:53.712504 #1762]  INFO -- : - Integrations::MockMonitoring failures: 0
I, [2024-01-25T07:48:53.714354 #1762]  INFO -- : - Integrations::Pushover failures: 0
I, [2024-01-25T07:48:53.716220 #1762]  INFO -- : - Integrations::SquashTm failures: 0
I, [2024-01-25T07:48:53.721844 #1762]  INFO -- : - AlertManagement::HttpIntegration failures: 0
I, [2024-01-25T07:48:53.726941 #1762]  INFO -- : - GrafanaIntegration failures: 0
I, [2024-01-25T07:48:53.731754 #1762]  INFO -- : - JiraConnectInstallation failures: 0
I, [2024-01-25T07:48:53.749176 #1762]  INFO -- : - PagesDomain failures: 0
I, [2024-01-25T07:48:53.752769 #1762]  INFO -- : - PagesDomainAcmeOrder failures: 0
I, [2024-01-25T07:48:53.756171 #1762]  INFO -- : - ProjectImportData failures: 0
I, [2024-01-25T07:48:53.759471 #1762]  INFO -- : - RemoteMirror failures: 0
I, [2024-01-25T07:48:53.762965 #1762]  INFO -- : - Alerting::ProjectAlertingSetting failures: 0
I, [2024-01-25T07:48:53.766545 #1762]  INFO -- : - Atlassian::Identity failures: 0
I, [2024-01-25T07:48:53.770015 #1762]  INFO -- : - BulkImports::Configuration failures: 0
I, [2024-01-25T07:48:53.786730 #1762]  INFO -- : - Clusters::KubernetesNamespace failures: 0
I, [2024-01-25T07:48:53.790208 #1762]  INFO -- : - ErrorTracking::ProjectErrorTrackingSetting failures: 0
I, [2024-01-25T07:48:53.793817 #1762]  INFO -- : - IncidentManagement::ProjectIncidentManagementSetting failures: 0
I, [2024-01-25T07:48:53.797297 #1762]  INFO -- : - Integrations::IssueTrackerData failures: 0
I, [2024-01-25T07:48:53.806228 #1762]  INFO -- : - Integrations::JiraTrackerData failures: 0
I, [2024-01-25T07:48:53.809799 #1762]  INFO -- : - Integrations::ZentaoTrackerData failures: 0
I, [2024-01-25T07:48:53.813326 #1762]  INFO -- : - ServiceDesk::CustomEmailCredential failures: 0
I, [2024-01-25T07:48:53.817025 #1762]  INFO -- : - ServiceDesk::CustomEmailVerification failures: 0
I, [2024-01-25T07:48:53.818387 #1762]  INFO -- : - Clusters::Integrations::Prometheus failures: 0
I, [2024-01-25T07:48:53.822853 #1762]  INFO -- : - Clusters::Providers::Aws failures: 0
I, [2024-01-25T07:48:53.826541 #1762]  INFO -- : - Clusters::Providers::Gcp failures: 0
I, [2024-01-25T07:48:53.830101 #1762]  INFO -- : - Packages::Debian::GroupDistributionKey failures: 0
I, [2024-01-25T07:48:53.833574 #1762]  INFO -- : - Packages::Debian::ProjectDistributionKey failures: 0
I, [2024-01-25T07:48:53.851121 #1762]  INFO -- : - WebHook failures: 0
I, [2024-01-25T07:48:53.853027 #1762]  INFO -- : - ProjectHook failures: 0
I, [2024-01-25T07:48:53.855016 #1762]  INFO -- : - ServiceHook failures: 0
I, [2024-01-25T07:48:53.856902 #1762]  INFO -- : - SystemHook failures: 0
I, [2024-01-25T07:48:53.858964 #1762]  INFO -- : - Gitlab::BackgroundMigration::BackfillIntegrationsEnableSslVerification::Integration failures: 0
I, [2024-01-25T07:48:53.878127 #1762]  INFO -- : - Ci::Runner failures: 0
I, [2024-01-25T07:48:54.040539 #1762]  INFO -- : - Ci::Build failures: 0
I, [2024-01-25T07:48:54.383647 #1762]  INFO -- : - Group failures: 0
I, [2024-01-25T07:48:54.389693 #1762]  INFO -- : - DeployToken failures: 0
I, [2024-01-25T07:48:54.675575 #1762]  INFO -- : - Project failures: 0
I, [2024-01-25T07:48:54.682077 #1762]  INFO -- : - Clusters::AgentToken failures: 0
I, [2024-01-25T07:48:54.686922 #1762]  INFO -- : - Operations::FeatureFlagsClient failures: 0
I, [2024-01-25T07:48:54.686964 #1762]  INFO -- : Total: 0 row(s) affected
I, [2024-01-25T07:48:54.686976 #1762]  INFO -- : Done!
```





## 源码部署



**源码部署安装gitlab 8.9.11**

官方部署指导URL: https://gitlab.com/gitlab-org/gitlab-recipes/tree/master/install/centos

部署URL分支：63-gitlab-omnibus-ssl-apache24-conf-proxypass-vs-rewriterule

支持的 Unix 发行版：Ubuntu、Debian、CentOS

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

````bash
更新和添加基本软件和服务
[root@ha2 yum.repos.d]# cat base.repo 
[base]
name=centos6 base repos
#baseurl=https://vault.centos.org/6.8/os/x86_64
baseurl=http://archive.kernel.org/centos-vault/6.8/os/x86_64/
gpgcheck=0

```
cat > /etc/yum.repos.d/base.repo << EOF
[base]
name=CentOS-6.10 - Base - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/6.10/os/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
#released updates 
[updates]
name=CentOS-6.10 - Updates - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/6.10/updates/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
#additional packages that may be useful
[extras]
name=CentOS-6.10 - Extras - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/6.10/extras/$basearch/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
#additional packages that extend functionality of existing packages
[centosplus]
name=CentOS-6.10 - Plus - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/6.10/centosplus/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
#contrib - packages by Centos Users
[contrib]
name=CentOS-6.10 - Contrib - mirrors.aliyun.com
failovermethod=priority
baseurl=http://mirrors.aliyun.com/centos-vault/6.10/contrib/$basearch/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6

EOF
```

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
   [root@gitlab ~]# yum install -y zlib-devel perl-CPAN gettext curl-devel expat-devel gettext-devel openssl-devel numactl

5.2 克隆 Gitaly 存储库以编译和安装 Git：
mkdir /tmp/git && cd /tmp/git
curl --progress https://www.kernel.org/pub/software/scm/git/git-2.10.5.tar.gz | tar xz
cd git-2.10.5
./configure
make
make prefix=/usr/local install
[root@gitlab git-2.10.5]# /usr/local/bin/git version 
git version 2.10.5

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
   mysql> CREATE USER 'git'@'localhost' IDENTIFIED BY 'gitlab@test';
   mysql> CREATE USER 'git'@'%' IDENTIFIED BY 'gitlab@test';
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
  password: "gitlab@test"

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
````



### 备份和恢复



#### 备份

```bash
# 参数链接：https://blog.51cto.com/u_15127626/3294565

# 初始化
[root@localhost git]# mkdir -p /data/backup
[root@localhost git]# mkdir -p /windows/gitlab

[root@localhost git]# mount -t cifs -o username=linuxuser,password=linuxuser,dir_mode=0777,file_mode=0777 //192.168.13.182/testAuto /windows
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

# 备份
[root@localhost backup]# cd /home/git/gitlab
sudo -u git -H bundle exec rake gitlab:backup:create RAILS_ENV=production



# 自动备份脚本
[root@localhost ~]# cat backupGitlab.sh
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
```



#### 恢复

```bash
# 恢复
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
[root@gitlab gitlab]# pwd
/home/git/gitlab
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
```





**解决gitlab8.9.11源码编译环境，用户访问gitlab报forbidden 错误**

1. 如果一个ip被错误地拦截，导致不能访问，如何快速恢复：
```bash
[root@gitlab gitlab]# redis-cli -s /var/run/redis/redis.sock
redis /var/run/redis/redis.sock> keys *rack::attack*
1) "cache:gitlab:rack::attack:allow2ban:ban:172.168.2.205"
redis /var/run/redis/redis.sock> del cache:gitlab:rack::attack:allow2ban:ban:172.168.2.205
(integer) 1
redis /var/run/redis/redis.sock> keys *rack::attack*
(empty list or set)
```

2. 我们使用的是从源码安装的gitlab，rack-attack机制默认是启用的，如果想禁用掉这个机制，将enabled更改为false，然后取消注释，重启服务即可。ip_whitelist为启用rack-attack机制下的白名单配置

```bash
[root@gitlab gitlab]# vim config/gitlab.yml
  rack_attack:
    git_basic_auth:
      # Rack Attack IP banning enabled
      enabled: false
      #
      # Whitelist requests from 127.0.0.1 for web proxies (NGINX/Apache) with incorrect headers
      # ip_whitelist: ["127.0.0.1"]
      #
      # Limit the number of Git HTTP authentication attempts per IP
      # maxretry: 10
      #
      # Reset the auth attempt counter per IP after 60 seconds
      # findtime: 60
      #
      # Ban an IP for one hour (3600s) after too many auth attempts
      # bantime: 3600
```









## docker部署



**docker-compose部署gitlab15.11.13**



**配置文件**

```bash
[root@gitlab /data/gitlab]# cat config/gitlab.rb 
###### email
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.qiye.163.com"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "test@test.com"
gitlab_rails['smtp_password'] = "test"
gitlab_rails['smtp_domain'] = "163.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_tls'] = true
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'
gitlab_rails['gitlab_email_enabled'] = true
gitlab_rails['gitlab_email_from'] = 'test@test.com'
gitlab_rails['gitlab_email_reply_to'] = 'jack.li@test.com'
#gitlab_rails['smtp_ca_file'] = '/path/to/your/cacert.pem'
gitlab_rails['smtp_pool'] = true
gitlab_rails['time_zone'] = 'Asia/Shanghai'
######


###### use external test
test['enable'] = false
gitlab_rails['monitoring_whitelist'] = ['127.0.0.0/8', '192.168.13.0/24']
gitlab_rails['test_address'] = '192.168.13.236:9090'

# Workhorse
gitlab_workhorse['test_listen_addr'] = "0.0.0.0:9229"

# Rails nodes
gitlab_exporter['listen_address'] = '0.0.0.0'
gitlab_exporter['listen_port'] = '9168'

# Sidekiq nodes
sidekiq['listen_address'] = '0.0.0.0'

# Redis nodes
redis_exporter['listen_address'] = '0.0.0.0:9121'

# PostgreSQL nodes
postgres_exporter['listen_address'] = '0.0.0.0:9187'

# Gitaly nodes
gitaly['test_listen_addr'] = "0.0.0.0:9236"

# Nginx
nginx['status']['options'] = {
      "server_tokens" => "off",
      "access_log" => "off",
      "allow" => "192.168.13.236",
      "deny" => "all",
}
######
```



**deploy method 01**

```bash
# 网络模式为host
version: '3.6'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:15.11.13-ce.0'
    restart: always
    hostname: 'git.hs.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://git.hs.com:80'
        gitlab_rails['gitlab_shell_ssh_port'] = 22
    volumes:
      - '/data/gitlab/config:/etc/gitlab'
      - '/data/gitlab/logs:/var/log/gitlab'
      - '/data/gitlab/data:/var/opt/gitlab'
    shm_size: '256m'
    network_mode: host
```



**deploy method 02**

```bash
# 网络模式为bridge
version: '3.6'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:15.11.13-ce.0'
    restart: always
    hostname: 'gitlab.hs.com'
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://gitlab.hs.com:80'
        gitlab_rails['gitlab_shell_ssh_port'] = 22
    ports:
      - '80:80'
      - '443:443'
      - '22:22'
    volumes:
      - '/data/gitlab/config:/etc/gitlab'
      - '/data/gitlab/logs:/var/log/gitlab'
      - '/data/gitlab/data:/var/opt/gitlab'
    shm_size: '256m'
```



**启动**


```bash
[root@gitlab gitlab]# docker-compose up -d
[root@gitlab gitlab]# docker exec -it gitlab /bin/bash
root@gitlab:/etc/gitlab# gitlab-ctl reconfigure 
root@gitlab:/etc/gitlab# gitlab-ctl restart 
root@gitlab:/etc/gitlab# gitlab-ctl status 
root@gitlab:/etc/gitlab# gitlab-rake gitlab:check
```



**常用命令**

```bash
# 启动所有 gitlab 组件：
gitlab-ctl start
# 停止所有 gitlab 组件：
gitlab-ctl stop
# 停止 postgresql 组件：
gitlab-ctl stop postgresql
# 停止相关数据连接服务
gitlab-ctl stop unicorn
gitlab-ctl stop sidekiq
# 重启所有 gitlab 组件：
gitlab-ctl restart
# 重启 gitlab-workhorse 组件：
gitlab-ctl restart gitlab-workhorse
# 查看服务状态
gitlab-ctl status
# 查看运行时配置
gitlab-ctl show-config
# 如果更改了主配置文件 [：/etc/gitlab/gitlab.rb 文件],需要用这个命令，使配置文件生效 但是会初始化除了gitlab.rb 之外的所有文件
gitlab-ctl reconfigure
# 查看服务列表名称
gitlab-ctl service-list
# 执行完上面那个命令 重启所有 gitlab 组件
gitlab-ctl restart
# 针对某个服务重启 例如重启nginx
gitlab-ctl restart nginx
# 针对某个服务启动 例如启动nginx
gitlab-ctl start nginx
# 针对某个服务关闭 例如关闭nginx
gitlab-ctl stop nginx
# 查看日志 （查看gitlab整个所有的日志）
gitlab-ctl tail
# 检查 redis 的日志
gitlab-ctl tail redis
# 恢复到数据库的先前版本
gitlab-ctl revert-pg-upgrade
# 设置数据库复制密码
gitlab-ctl set-replication-password
# 与 Gitaly 集群交互
gitlab-ctl praefect
# 运行容器注册表垃圾回收
gitlab-ctl registry-garbage-collect

# 备份配置，会备份/etc/gitlab整个目录下的文件
root@git:/# gitlab-ctl backup-etc -p /tmp/
WARNING: /tmp may be read by non-root users
Running configuration backup
Creating configuration backup archive: gitlab_config_1704367847_2024_01_04.tar
/etc/gitlab/
/etc/gitlab/ssh_host_rsa_key
/etc/gitlab/ssh_host_rsa_key.pub
/etc/gitlab/ssh_host_ecdsa_key
/etc/gitlab/ssh_host_ecdsa_key.pub
/etc/gitlab/ssh_host_ed25519_key
/etc/gitlab/ssh_host_ed25519_key.pub
/etc/gitlab/gitlab-secrets.json
/etc/gitlab/trusted-certs/
/etc/gitlab/git.txt
/etc/gitlab/git2.log
/etc/gitlab/gitlab.rb
Configuration backup archive complete: /tmp/gitlab_config_1704367847_2024_01_04.tar
Keeping all older configuration backups

# 更新现有 Let's Encrypt 证书
gitlab-ctl renew-le-certs 
# 以 PostgreSQL 格式生成用户密码的 MD5 哈希值
root@git:/# gitlab-ctl pg-password-md5 test
Enter password: 			# abc
Confirm password: 			# abc
f7dc2e1937940bb8486274edc88cc3c5

#  将 PostgreSQL 数据库升级到最新支持版本
gitlab-ctl pg-upgrade 
Checking for an omnibus managed postgresql: OK
Checking if postgresql['version'] is set: OK
Checking if we already upgraded: OK
The latest version 13.11 is already running, nothing to do
```







## gitlab迁移



**命令**

```bash
# 裸克隆和裸推送01
git clone -v --bare -- git@gitlab-test01.hs.com:k8s-deploy/frontend-hotelnew-hs-com.git tmp/repos/k8s-deploy/frontend-hotelnew-hs-com
git push --porcelain --all -- git@192.168.13.211:k8s-deploy/frontend-hotelnew-hs-com.git

# 裸克隆和裸推送02
git clone -v --bare git@gitlab-test01.hs.com:k8s-deploy/frontend-hotelnew-hs-com.git test02
git push --porcelain --all git@192.168.13.211:k8s-deploy/frontend-hotelnew-hs-com.git
```





### python脚本迁移

此脚本用于从gitlab版本迁移到新版本，如gitlab 8.9.11  --->  gitlab 15.11.13

因为gitlab 8.9.11采用源码编译安装，目前使用源码编译安装时有些环境无法安装成功，帮只能将项目、用户、组迁移到新版本gitlab



#### config.py

```python
# -*- coding: utf-8 -*-

SOURCE = {
	'address': 'gitlab-test01.hs.com',
	'access_token': 'Bh6TQ123RCyk'
}

TARGET = {
	'test': {
		'address': 'gitlabtest.hs.com',
		'access_token': '2zg912312b-po7Fxw'
	},
	'prepro': {
		'address': '192.168.130.1',
		'access_token': 'glpat-4123123_kzQ7GxDtg4'
	}
}

```



#### main.py

```python
# -*- coding: utf-8 -*-

import os, sys, config, base
from users import Users
from groups import Groups
from groups_members import GroupsMembers
from projects import Projects
from repositories import Repositories

def execute(cfg):
	users = Users(cfg).run()
	base.storage('users', users)

	groups = Groups(cfg).run()
	base.storage('groups', groups)

	members = GroupsMembers(cfg, users, groups).run()
	base.storage('groups-members', members)

	projects = Projects(cfg, users['target'], groups['target']).run()
	base.storage('projects', projects)

	# 用于测试时使用
	# projects = base.read_from_storage('projects')

	Repositories(cfg, projects['source']).run()

if __name__ == '__main__':
	env = sys.argv[1:]
	if env:
		env = env[0]
	else:
		env = 'test'

	tmppath = 'tmp'
	if not os.path.exists(tmppath):
		os.makedirs(tmppath)

	cfg = {
		'source': config.SOURCE,
		'target': config.TARGET.get(env, config.TARGET['test'])
	}

	print('[INFO] Migrator configuration:')
	for key in cfg:
		cfg[key]['headers'] = { 'PRIVATE-TOKEN': cfg[key]['access_token'] }
		print('[INFO] %s:' % key)
		print(cfg[key])
	cfg['per_page'] = 100
	
	execute(cfg)

```



#### base.py

```python
# -*- coding: utf-8 -*-

import json

def storage(name, data):
	with open('tmp/%s.json' % name, 'w', encoding = 'UTF-8') as f:
		json.dump(data, f, sort_keys = False, indent = 2, ensure_ascii = False)

# 用于测试从文件读取Json数据到对象，可以快速测试，不用从头再落数据
def read_from_storage(name):
	with open('tmp/%s.json' % name, 'r', encoding = 'UTF-8') as f:
		return json.load(f)

```



#### users.py

```python
# -*- coding: utf-8 -*-

import requests

class Users(object):
	def __init__(self, cfg):
		super(Users, self).__init__()
		self.source_api = 'http://%s/api/v3/users'
		self.target_api = 'http://%s/api/v4/users'
		self.source = cfg['source']
		self.target = cfg['target']
		self.params = { 'per_page': cfg['per_page'], 'sort': 'asc' }

	def run(self):
		source = self.get()
		target = self.inserts(source)

		return { 'source': source, 'target': target }

	def get(self):
		resp = requests.get(self.source_api % self.source['address'], 
			headers = self.source['headers'], params = self.params)
		
		users = sorted(resp.json(), key = lambda x:x['id'], reverse = False)
		print('[INFO] Total accounts: %d' % len(users))

		return users

	def inserts(self, users):
		new_users = []
		for user in users:
			uname = user['username']
			if uname == 'ghost':
				continue

			if uname == 'root':
				resp = requests.get(
					'%s/1' % (self.target_api % self.target['address'], ), 
					headers = self.target['headers'], params = self.params)
				new_users.append(resp.json())
			else:
				data = {
					'email': user.get('email'),
					'password': 'wVHEfDW7DemFTZrx',
					'username': user.get('username'),
					'name': user.get('name'),
					'skype': user.get('skype'),
					'linkedin ': user.get('linkedin '),
					'twitter': user.get('twitter'),
					'website_url': user.get('website_url'),
					'organization': user.get('organization'),
					'bio': user.get('bio'),
					'location': user.get('location'),
					'admin': user.get('is_admin'),
					'skip_confirmation': True
				}
				resp = requests.post(self.target_api % self.target['address'], 
					headers = self.target['headers'], data = data)
				new_users.append(resp.json())

		size = len(new_users)
		print('[INFO] Create new user: %d' % (size - 1))
		print('[INFO] Total new user: %d' % size)

		return new_users

```



#### groups.py

```python
# -*- coding: utf-8 -*-

import requests

class Groups(object):
	def __init__(self, cfg):
		super(Groups, self).__init__()
		self.source_api = 'http://%s/api/v3/groups'
		self.target_api = 'http://%s/api/v4/groups'
		self.source = cfg['source']
		self.target = cfg['target']

	def run(self):
		source = self.get()
		target = self.inserts(source)
		
		return { 'source': source, 'target': target }

	def get(self):
		resp = requests.get(
			self.source_api % self.source['address'], 
			headers = self.source['headers'])

		groups = sorted(resp.json(), key = lambda x:x['id'], reverse = False)

		print('[INFO] Total groups: %d' % len(groups))
		return groups

	def inserts(self, groups):
		new_groups = []
		for group in groups:
			if group['name'] == 'Public':
				data = {
				"name": "PublicNew",
				"path": "PublicNew",
				"description": group['description'],
				"visibility_level": group['visibility_level'],
				"lfs_enabled": 0
			}
			else:
				data = {
					"name": group['name'],
					"path": group['path'],
					"description": group['description'],
					"visibility_level": group['visibility_level'],
					"lfs_enabled": 0
				}
			resp = requests.post(
				self.target_api % self.target['address'], 
				headers = { 'PRIVATE-TOKEN': self.target['access_token'] }, 
				data = data)
			new_groups.append(resp.json())

		print('[INFO] Create new group: %d' % len(new_groups))

		return new_groups

```



#### groups_members.py

```python
# -*- coding: utf-8 -*-

import requests

class GroupsMembers(object):
	def __init__(self, cfg, users, groups):
		super(GroupsMembers, self).__init__()
		self.source_api = 'http://%s/api/v3/groups/%s/members'
		self.target_api = 'http://%s/api/v4/groups/%s/members'
		self.source = cfg['source']
		self.target = cfg['target']
		self.users = users
		self.groups = groups

	def run(self):
		members = self.index()
		self.add(members)

		return members

	def index(self):
		target_groups = self.groups['target']
		target_users = self.users['target']
		source_groups = self.groups['source']

		target_members = []
		for group in source_groups:
			if group['name'] == 'Public':
				tgroup = next(x for x in target_groups if x['name'] == "PublicNew")
				resp = requests.get(
					self.source_api % (self.source['address'], group['id']),
					headers = self.source['headers'])
				source_members = resp.json()
			else:
				tgroup = next(x for x in target_groups if x['name'] == group['name'])
				resp = requests.get(
					self.source_api % (self.source['address'], group['id']),
					headers = self.source['headers'])
				source_members = resp.json()

			for m in source_members:
				tm = next(x for x in target_users if x['username'] == m['username'])
				m['target_id'] = tm['id']
				m['target_username'] = tm['username']
			target_members.append({
				'id': group['id'],
				'name': group['name'],
				'target_id': tgroup['id'],
				'target_name': tgroup['name'],
				'members': source_members
			})

		return target_members

	def add(self, members):
		for gm in members:
			gid = gm['target_id']
			for m in gm['members']:
				data = {
					'id': gid,
					'user_id': m['target_id'],
					'access_level': m['access_level']
				}
				requests.post(
					self.target_api % (self.target['address'], gid),
					headers = self.target['headers'], 
					data = data)

```



#### projects.py

```python
# -*- coding: utf-8 -*-

import requests

class Projects(object):
	def __init__(self, cfg, target_users, target_groups):
		super(Projects, self).__init__()
		self.source_api = 'http://%s/api/v3/projects/all'
		self.target_api = 'http://%s/api/v4/projects'
		self.source = cfg['source']
		self.target = cfg['target']
		self.per_page = cfg['per_page']
		self.target_users = target_users
		self.target_groups = target_groups

	def run(self):
		source = self.get()
		target = self.inserts(source)
		
		return { 'source': source, 'target': target }

	def get(self):
		projects = requests.get(
			self.source_api % self.source['address'], 
			headers = self.source['headers'],
			params = { 'order_by': 'updated_at', 'per_page': self.per_page, 'page': 1})

		X_Next_Page = projects.headers.get('X-Next-Page')		
		project_list = []
		for project in projects.json():
				project_list.append(project)

		# 老版本gitlab最大支持每页展示100个对象，故有大于100的项目无法获取，所以这里加了一些代码，从而获取所有的项目列表
		while X_Next_Page != '' or X_Next_Page is None:
			projects = requests.get(
				self.source_api % self.source['address'], 
				headers = self.source['headers'],
				params = { 'order_by': 'updated_at', 'per_page': self.per_page, 'page': X_Next_Page})

			for project in projects.json():
				project_list.append(project)
			
			X_Next_Page = projects.headers.get('X-Next-Page')		
		
		print('[INFO] Total projects:', len(project_list))	
		return project_list

	def inserts(self, projects):
		new_projects = []
		for project in projects:
			npn = project['namespace']['name']
			try:
				# 因为老版本gitlab有Public的群组，而新版本gitlab不支持创建名为Public的群组，所以做了 'Public' + 'New'特殊处理
				if npn == 'Public':
					np = next(x for x in self.target_groups if x['path'] == npn + 'New')

					data = {
						"name": project['name'],
						"path": project['path'],
						"namespace_id": np['id'],
						"description": project['description'],
						"visibility_level": project['visibility_level'],
						"lfs_enabled": 0
					}
					resp = requests.post(
						self.target_api % self.target['address'], 
						headers = self.target['headers'], 
						data = data)
					new_projects.append(resp.json())
				else:
					np = next(x for x in self.target_groups if x['path'] == npn)

					data = {
						"name": project['name'],
						"path": project['path'],
						"namespace_id": np['id'],
						"description": project['description'],
						"visibility_level": project['visibility_level'],
						"lfs_enabled": 0
					}
					resp = requests.post(
						self.target_api % self.target['address'], 
						headers = self.target['headers'], 
						data = data)
					new_projects.append(resp.json())
			except Exception as e:
				# 因为老版本gitlab有Public的群组，而新版本gitlab不支持创建名为Public的群组，所以做了 'Public' + 'New'特殊处理
				if npn == 'Public':
					np = next(x for x in self.target_groups if x['path'] == npn + 'New')
					
					data = {
						"name": project['name'],
						"path": project['path'],
						"user_id": np['id'],
						"description": project['description'],
						"visibility_level": project['visibility_level'],
						"lfs_enabled": 0
					}
					resp = requests.post(
						'%s/user/%s' % (self.target_api % self.target['address'], np['id']), 
						headers = self.target['headers'], 
						data = data)
					new_projects.append(resp.json())
				else:
					np = next(x for x in self.target_users if x['username'] == npn)

					data = {
						"name": project['name'],
						"path": project['path'],
						"user_id": np['id'],
						"description": project['description'],
						"visibility_level": project['visibility_level'],
						"lfs_enabled": 0
					}
					resp = requests.post(
						'%s/user/%s' % (self.target_api % self.target['address'], np['id']), 
						headers = self.target['headers'], 
						data = data)
					new_projects.append(resp.json())

		print('[INFO] Create new project: %d' % len(new_projects))

		return new_projects

```



#### repositories.py

```python
# -*- coding: utf-8 -*-

from git import Repo
import os, shutil
import requests

class Repositories(object):
	def __init__(self, cfg, source_projects):
		super(Repositories, self).__init__()
		self.source_api = 'http://%s/api/v3/projects/%s/repository/tree'
		# self.api = 'http://%s/%s.git'
		self.api = 'git@%s:%s.git'
		self.source = cfg['source']
		self.target = cfg['target']
		self.source_projects = source_projects
		self.dirpath = 'tmp/repos/'

	def run(self):
		# self.clean()
		# for project in self.source_projects:
		for i,project in enumerate(self.source_projects):
			# 加了if语句，主要用于调试时使用
			if i+1 >= 0:
				print("[INFO] number %s" % str(i+1))

				request_status = requests.get(
					self.source_api % (self.source['address'], project['id']),
					headers = self.source['headers'])

				# 用于判断项目是否为空，如果为空则不对此项目进行克隆和上传动作，如果为空进行上传的动作时会报错
				if request_status.status_code == 404:
					print("[INFO] project %s content is Null" % project['path_with_namespace'])
					continue

				groupdir = '%s%s' % (self.dirpath, project['namespace']['path'])
				if not os.path.exists(groupdir):
					os.makedirs(groupdir)

				# 因为老版本gitlab有Public的群组，而新版本gitlab不支持创建名为Public的群组，所以做了 'Public' + 'New'特殊处理
				if project['namespace']['path'] == 'Public':
					self.push(project['namespace']['path'] + 'New' + '/' + project['path'], 
						'%s/%s' % (groupdir, project['path']))
				else:
					self.push(project['path_with_namespace'], 
						'%s/%s' % (groupdir, project['path']))

	def push(self, uri, to_path):
		# 因为老版本gitlab有Public的群组，而新版本gitlab不支持创建名为Public的群组，所以做了 'Public' + 'New'特殊处理
		source_url = self.api % ('%s' % self.source['address'], str(uri).replace('New',''))
		target_url = self.api % (self.target['address'], uri)
		print('[INFO] Clone:', source_url)
		repo = Repo.clone_from(url = source_url, to_path = to_path, bare = True)
		print('[INFO] Push:', target_url)
		gitlab = repo.create_remote('gitlab', target_url)
		print('[INFO] push all')
		# 在windows环境下运行此脚本，有些项目会报UnicodeDecodeError: 'gbk' codec can't decode byte 0xae in position 86: illegal multibyte sequence
		# 在Linux环境下运行此脚本无此问题
		gitlab.push(all = True)
		print('[INFO] push tags')
		gitlab.push(tags = True)

	def clean(self):
		if os.path.exists(self.dirpath):
			shutil.rmtree(self.dirpath, onerror = self.onerror)

	def onerror(self, func, path, exec_info):
		import stat
		if not os.access(path, os.W_OK):
			os.chmod(path, stat.S_IWUSR)
			func(path)
		else:
			raise

```



#### clean.py

```python
# -*- coding: utf-8 -*-

import requests, config

# 清除测试(test)目标的数据
cfg = config.TARGET["prepro"]
address = 'http://%s/api/v4' % cfg['address']
headers = { 'PRIVATE-TOKEN': cfg['access_token'] }
print("[INFO]",address, headers)

def removeGroups():
	url = '%s/groups' % address
	resp = requests.get(url, headers = headers)
	groups = resp.json()
	print('[INFO] Remove groups: %d' % len(groups))

	for g in groups:
		requests.delete('%s/%s' % (url, g['id']), headers = headers)

def removeUsers():
	url = '%s/users' % address
	resp = requests.get(url, headers = headers, 
		params = { 'per_page': 500 })
	users = resp.json()
	print('[INFO] Remove users: %d' % len(users))

	for u in users:
		if u['username'] != 'root':
			requests.delete('%s/%s' % (url, u['id']), 
				headers = headers, params = { 'hard_delete': True })

def removeProjects():
	url = '%s/projects' % address
	projects = requests.get(url, headers = headers,
		params = { 'order_by': 'updated_at', 'per_page': 100, 'page': 1})

	X_Next_Page = projects.headers.get('X-Next-Page')		
	project_list = []
	for project in projects.json():
		project_list.append(project)

	while X_Next_Page != '' or X_Next_Page is None:
		# 老版本gitlab最大支持每页展示100个对象，故这里写的是100
		projects = requests.get(url, headers = headers,
			params = { 'order_by': 'updated_at', 'per_page': 100, 'page': X_Next_Page})

		for project in projects.json():
			project_list.append(project)
		
		X_Next_Page = projects.headers.get('X-Next-Page')	

	print('[INFO] Remove projects: %d' % len(project_list))
	for p in project_list:
		requests.delete('%s/%s' % (url, p['id']), headers = headers)

class Clean(object):
	def __init__(self):
		super(Clean, self).__init__()
		removeGroups()
		removeUsers()
		removeProjects()

if __name__ == '__main__':
	Clean()
```



#### README.md

````
# GitLab Community Edition数据迁移

使用`gitlab-ce` API进行私有仓库数据迁移，从`8.9.11`迁至`15.11.13`。因版本不同，无法使用`gitlab-rake`工具进行`backup`/`restore`。

## 配置

`src/config.py`:

- `SOURCE`: 老版本GitLab地址(端口`80`)与访问令牌

- `TARGET`: 新版本GitLab(`test`/`prod`)地址与访问令牌

## 迁移数据列表

- [X] Users
- [X] Groups
- [X] Group members
- [X] Projects
- [X] Repositories
- [ ] Issues
- [ ] Merge requests

## 用法

- 安装依赖
```sh
pip3 install GitPython
```

- 迁移
``` sh
$ python3 src/main.py [test | prod]
```

- 清除测试目标库中的数据
``` sh
$ python3 src/clean.py
```
````





### webhook批量添加



#### bash命令

```bash
## 列出名称空间k8s-deploy下所有项目的webhook
gitlab-rake gitlab:web_hook:list RAILS_ENV=production NAMESPACE=k8s-deploy

## 删除名称空间k8s-deploy下所有项目的webhook
gitlab-rake gitlab:web_hook:rm URL="https://argocd.test.k8s.hs.com/api/webhook" NAMESPACE=k8s-deploy

## 添加名称空间k8s-deploy下所有项目的webhook，只能添加URL，不能添加token及其它自定义参数，放弃此方法
gitlab-rake gitlab:web_hook:add RAILS_ENV=production NAMESPACE=k8s-deploy URL="https://argocd.k8s.hs.com/api/webhook"

```



#### python脚本



**webhook.py**

```py
# -*- coding: utf-8 -*-

import requests

class Webhook(object):
	def __init__(self, cfg, target_groups):
		super(Webhook, self).__init__()
		self.target_group_projects_api = 'http://%s/api/v4/groups/%s/projects'
		self.target_api = 'http://%s/%s/-/hooks'
		self.target = cfg['target']
		self.per_page = cfg['per_page']
		self.target_groups = target_groups

	def run(self):
		target_group_projects = self.get(self.target_groups)
		self.inserts(target_group_projects)

		return { 'target_group_projects': target_group_projects }

	def get(self, target_groups):
		project_list = []
		for group in target_groups:
			if group['path'] == 'k8s-deploy':
				projects = requests.get(
					self.target_group_projects_api % (self.target['address'], group['id']), 
					headers = self.target['headers'], 
					params = { 'order_by': 'updated_at', 'per_page': self.per_page, 'page': 1})

				X_Next_Page = projects.headers.get('X-Next-Page')		
				for project in projects.json():
						project_list.append(project)

				# gitlab最大支持每页展示100个对象，故有大于100的项目无法获取，所以这里加了一些代码，从而获取所有的项目列表
				while X_Next_Page != '' or X_Next_Page is None:
					projects = requests.get(
						self.target_group_projects_api % (self.target['address'], group['id']), 
						headers = self.target['headers'], 
						params = { 'order_by': 'updated_at', 'per_page': self.per_page, 'page': X_Next_Page})

					for project in projects.json():
						project_list.append(project)

					X_Next_Page = projects.headers.get('X-Next-Page')		
		
		print('[INFO] Total projects:', len(project_list))	
		target_group_projects = sorted(project_list, key = lambda x:x['id'], reverse = False)
		return target_group_projects

	def inserts(self, target_group_projects):
		target_response_project_info = []
		# 手动添加Cookie 和 authenticity_token 值
		self.target['headers']['Cookie']="visitor_id=7150fcea-28a3-4152-a1fc-e16953de244d; sidebar_collapsed=false; preferred_language=zh_CN; hide_auto_devops_implicitly_enabled_banner_204=false; hide_auto_devops_implicitly_enabled_banner_306=false; hide_auto_devops_implicitly_enabled_banner_3216=false; known_sign_in=T1c0RnUrcWlSNFJBTnMwUXY1dDR5QTZ5V0tMN25BUjdydTVWdWMwcThORi9pY2ExalgrVHdMZjBMVW43ZWlDcUxadUZFRy9DM3ZFc1c3LzZ2dVBCdlczeWNUQU1kcnZKMUQrcDE1NEFjZndkOGtibHdVSUlNbko4aVo0UTNCbk4tLWtxdklZK2JkaVpnc2VZOUsvTnFNc2c9PQ%3D%3D--10271fb60010acc2659daf93dfb222b5ec969330; _gitlab_session=80b58eec69dd52d83b0b6c24a68ac767; event_filter=team"
		params = {
			'authenticity_token': 'K0tEIKFYJnJJqh7jOfvgXRnOnf3l3aglTZAzRonUqDXvnsZZNTpBI9-wHIjOhwyVv4zsUsd1HLhEfnPuBzrrEA',
			'hook[url]': 'https://argocd.test.k8s.hs.com/api/webhook',
			'__BVID__8': 'false',
			'hook[token]': 'uv6uHEyPI6Xbvh7I4b5tDfdNs1bBBtOL',
			'hook[push_events]': 'true',
			'hook[branch_filter_strategy]': 'all_branches',
			'hook[enable_ssl_verification]': 0
		}
		for project in target_group_projects:
			resp = requests.post(
				self.target_api % (self.target['address'], project['path_with_namespace']),
				headers = self.target['headers'], 
				params = params)
			target_response_project_info.append(resp)

		print('[INFO] Create webhook project: %d' % len(target_response_project_info))

```



**base.py**

```python
# -*- coding: utf-8 -*-

import json

def storage(name, data):
	with open('tmp/%s.json' % name, 'w', encoding = 'UTF-8') as f:
		json.dump(data, f, sort_keys = False, indent = 2, ensure_ascii = False)

def storage_txt(name, data):
	with open('tmp/%s.txt' % name, 'a+', encoding = 'UTF-8') as f:
		f.write(data)

# 用于测试从文件读取Json数据到对象，可以快速测试，不用从头再落数据
def read_from_storage(name):
	with open('tmp/%s.json' % name, 'r', encoding = 'UTF-8') as f:
		return json.load(f)

```



**main.py**

```pytho
# -*- coding: utf-8 -*-

import os, sys, config, base
from users import Users
from groups import Groups
from groups_members import GroupsMembers
from projects import Projects
from webhook import Webhook
from repositories import Repositories

def execute(cfg):
	# users = Users(cfg).run()
	# base.storage('users', users)

	# groups = Groups(cfg).run()
	# base.storage('groups', groups)

	# members = GroupsMembers(cfg, users, groups).run()
	# base.storage('groups-members', members)

	# projects = Projects(cfg, users['target'], groups['target']).run()
	# base.storage('projects', projects)

	# 用于测试时使用
	# projects = base.read_from_storage('projects')

	# Repositories(cfg, projects['source']).run()

	# 用于独立使用，插入webhook
	target_groups = Groups(cfg).get_target()
	base.storage('target_groups', target_groups)
	webhook = Webhook(cfg, target_groups).run()
	base.storage('webhook', webhook)



if __name__ == '__main__':
	env = sys.argv[1:]
	if env:
		env = env[0]
	else:
		env = 'test'

	tmppath = 'tmp'
	if not os.path.exists(tmppath):
		os.makedirs(tmppath)

	cfg = {
		'source': config.SOURCE,
		'target': config.TARGET.get(env, config.TARGET['test'])
	}

	print('[INFO] Migrator configuration:')
	for key in cfg:
		cfg[key]['headers'] = { 'PRIVATE-TOKEN': cfg[key]['access_token'] }
		print('[INFO] %s:' % key)
		print(cfg[key])
	cfg['per_page'] = 100
	
	execute(cfg)

```



### 添加后效果

```bash
root@git:/# gitlab-rake gitlab:web_hook:list 
0 webhooks found.

root@git:/# gitlab-rake gitlab:web_hook:list 
java-invoiceapply... -> https://argocd.test.k8s.hs.com/api/webhook
java-interhotelpo... -> https://argocd.test.k8s.hs.com/api/webhook
java-integratetra... -> https://argocd.test.k8s.hs.com/api/webhook
............
frontend-nginx-bg... -> https://argocd.test.k8s.hs.com/api/webhook
frontend-nginx-hs... -> https://argocd.test.k8s.hs.com/api/webhook
java-test-emailto... -> https://argocd.test.k8s.hs.com/api/webhook

191 webhooks found.
```

