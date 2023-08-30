#Ansible
<pre>
ansible代理: agentLess(无代理)
Ansible工作原理：
被管理端：主机(linux,windows),网络设备
Ansible引擎：Inventory,API,Modules,Plugins
user,ansible playbook,public/privateCloud,CMDB控制ansible
PlayBooks:任务剧本（任务集）
主控端：python2.6及以上
被控端：python2.4及以上，小于python2.4需要安装python-simplejson
被控端如果开启SElinxu则需要安装libselinux-python
windows不能做为主控端

ansible三大组件：模块、playbook、角色


--ansible安装
方式：源码，yum,pip，git

Operation:
[root@master ~]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 
[root@node1 ~]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 
[root@node2 ~]# cat /etc/redhat-release 
CentOS Linux release 7.6.1810 (Core) 

安装：
[root@master ~]# yum install -y ansible
[root@master ~]# rpm -ql ansible  | less
配置文件：
/etc/ansible/ansible.cfg   --主配置文件
/etc/ansible/hosts   --主机清单
/etc/ansible/roles  --默认存放角色的目录，可以更改，playbook的集合
程序：
/usr/bin/ansible 主程序，临时命令执行工具
/usr/bin/ansible-doc 查看配置文档，模块功能查看工具
/usb/bin/ansible-galaxy 下载/上传优秀代码或Roles模块的官网平台
/usr/bin/ansible-playbook 定制自动化任务，编排剧本工具/usr/bin/ansible-pull 远程执行命令的工具
/usr/bin/ansible-vault 文件加密工具
/usr/bin/ansible-console 基于Console界面与用户交互的执行工具

主机清单：
Inventory主机清单：ansible的主要功用在于批量主机操作，为了便捷地使用其中的部分主机，可以在inventory file中将其分组命名
默认的inventory file为/etc/ansible/hosts
inventory file可以有多个，且也可以通过Dynamic Inventory来动态生成

[root@master ~]# ansible --version
ansible 2.9.17
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Oct 30 2018, 23:45:53) [GCC 4.8.5 20150623 (Red Hat 4.8.5-36)]
[root@master ~]# ansible 192.168.13.201  -m ping 
[WARNING]: provided hosts list is empty, only localhost is available. Note that the implicit
localhost does not match 'all'
[WARNING]: Could not match supplied host pattern, ignoring: 192.168.13.201
注：表示清单是空的，只能控制自己127.0.0.1
[root@master ~]# ansible 127.0.0.1 -m ping 
127.0.0.1 | SUCCESS => {
    "changed": false, 
    "ping": "pong"
}
[root@master ~]# cp /etc/ansible/hosts{,.bak}
[root@master ~]# grep -Ev '#|^$' /etc/ansible/hosts
[root@master ~]# cat >> /etc/ansible/hosts << EOF
> 192.168.15.199 ansible_ssh_user=root ansible_ssh_port=2022
> 192.168.15.201
> 192.168.15.202
> EOF
[root@master ~]# grep -Ev '#|^$' /etc/ansible/hosts
192.168.15.199
192.168.15.201
192.168.15.202
[root@master ~]# ansible 192.168.15.201 -m ping -k  ---m表示模块名称，-k表示使用密码连接
SSH password: 
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"   --正常的响应就是pong
} 
[root@master ~]# ansible 192.168.15.201,192.168.15.202 -m ping -k  --多台主机，只让你输入一次密码，这种方法只针对密码一样的主机，如果不是一样密码则使用公私钥来认证
SSH password: 
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.202 | UNREACHABLE! => {
    "changed": false, 
    "msg": "Invalid/incorrect password: Permission denied, please try again.", 
    "unreachable": true   --密码不一样，所以这里失败
}
[root@master ~]# ansible all -m ping -k   --all表示所有主机
SSH password: 
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.199 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

--主机分组
[root@master ~]# vim /etc/ansible/hosts
[root@master ~]# grep -Ev '#|^$' /etc/ansible/hosts
[master]
192.168.15.199
[node]
192.168.15.20[1:2]
[db]
mysql[a:c].hs.com:2223
注：也可以写主机名称
[root@master ~]# ansible node -m ping -k   --管理的是node这个组内的主机
SSH password: 
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[root@master ~]# cp /etc/ansible/ansible.cfg{,.bak}
[root@master ~]# grep -Ev '#|^$' /etc/ansible/ansible.cfg 
[defaults]
[inventory]
[privilege_escalation]
[paramiko_connection]
[ssh_connection]
[persistent_connection]
[accelerate]
[selinux]
[colors]
[diff]

[defaults]
#inventory      = /etc/ansible/hosts   --指定清单文件路径
#library        = /usr/share/my_modules/   --指定ansible库
#module_utils   = /usr/share/my_module_utils/  --指定ansible模块工具包
#remote_tmp     = ~/.ansible/tmp   --远端主机临时目录，控制端会从本地复制运行脚本到这个目录下
#local_tmp      = ~/.ansible/tmp   --控制端临时目录，会把ping.py模块解析成脚本放在这个目录，然后复制到远端执行
#plugin_filters_cfg = /etc/ansible/plugin_filters.yml  --插件过滤配置文件
#forks          = 5    --同时运行多少个主机，并发运行主机
#poll_interval  = 15   --多长时间去控制端拉数据
#sudo_user      = root   --sudo到的用户身份是root
#ask_sudo_pass = True   --是否需要sudo命令时的口令
#ask_pass      = True   --是否需要口令
#transport      = smart  --传输模式
#remote_port    = 22   --默认远程端口
#module_lang    = C   --模块语言
#module_set_locale = False   
#host_key_checking = False  --主机key是否检验
#log_path = /var/log/ansible.log  --是否记录ansible操作日志

[root@master ~]# ansible 192.168.15.201 -m ping -k  --配置host_key_checking = False时，不会检查key
SSH password: 
[root@master ~]# ansible 192.168.15.201 -m ping -k --配置log_path = /var/log/ansible.log开启日志，将会记录日志
SSH password: 
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

[root@master ~]# cat /var/log/ansible.log
2021-03-06 17:44:56,946 p=19055 u=root n=ansible | 192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

--帮助命令
ansible-doc
[root@master ~]# ansible-doc -l | wc -l  --模块数量
3387
[root@master ~]# ansible-doc -l  --列出所有模块
[root@master ~]# ansible-doc -l
fortios_router_community_list                                 Configure community lists in Fortinet's FortiOS and FortiGate                  
azure_rm_devtestlab_info                                      Get Azure DevTest Lab facts                                                    
ecs_taskdefinition                                            register a task definition in ecs                                              
avi_alertscriptconfig                                         Module for setup of AlertScriptConfig Avi RESTful Object                       
tower_receive                                                 Receive assets from Ansible Tower                                              
netapp_e_iscsi_target                                         NetApp E-Series manage iSCSI target configuration   
[root@master ~]# ansible-doc -l | grep win | wc -l  --管理windows命令
109
[root@master ~]# ansible-doc -l | grep zabbix   --管理windows命令
zabbix_group_info                                             Gather information about Zabbix ho...
zabbix_template                                               Create/update/delete/dump Zabbix t...
zabbix_mediatype                                              Create/Update/Delete Zabbix media ...
zabbix_hostmacro                                              Create/update/delete Zabbix host m...
zabbix_screen                                                 Create/update/delete Zabbix screen...
zabbix_maintenance                                            Create Zabbix maintenance windows 
zabbix_proxy                                                  Create/delete/get/update Zabbix pr...
zabbix_map                                                    Create/update/delete Zabbix maps  
zabbix_host                                                   Create/update/delete Zabbix hosts 
zabbix_host_info                                              Gather information about Zabbix ho...
zabbix_group                                                  Create/delete Zabbix host groups  
zabbix_action      
--查看模块详细帮助
[root@master ~]# ansible-doc ping  --详细输出
[root@master ~]# ansible-doc -s ping  --简要输出
- name: Try to connect to host, verify a usable python and return `pong' on success
  ping:
      data:                  # Data to return for the `ping' return value. If this parameter is set
                               to `crash', the module will cause an
                               exception.
--ansible命令帮助
ansible <host-pattern> [-m module_name] [-a args] 
	--version 显示版本
	-m module 指定模块，默认为command
	-v 详细过程 -vv -vvv更详细
	-k --ask-pass 提示输入ssh连接密码，默认Key验证
	-K --ask-become-pass 提示输入sudo时的口令
	-C --check 检查，并不执行
	-T --timout=TIMEOUT 执行命令的超时时间，默认10s
	-u --user=REMOTE_USER 执行远程执行的用户
	-b --become代替旧版的sudo切换
[root@master ~]# ansible all --list-hosts -v
Using /etc/ansible/ansible.cfg as config file
  hosts (3):
    192.168.15.201
    192.168.15.202
    192.168.15.199
[root@master ~]# ansible no* --list-hosts
  hosts (2):
    192.168.15.201
    192.168.15.202
[root@master ~]# ansible 192.168.15.202 -u jack -k -m command -a 'ls /tmp'
SSH password: 
192.168.15.202 | CHANGED | rc=0 >>
ansible_command_payload_Djh0VJ
ks-script-gsC4Hr
ks-script-oTUILi
systemd-private-427bb2d480b94a8090971d094643924f-chronyd.service-AjVcKG
vmware-root_5889-1983851818
yum.log
[root@master ~]# ansible 192.168.15.202 -u jack -k -a 'ls /tmp' --默认模块是-m command，-a额外选项必需添加
SSH password: 
192.168.15.202 | CHANGED | rc=0 >>
ansible_command_payload_VLDK3G
ks-script-gsC4Hr
ks-script-oTUILi
systemd-private-427bb2d480b94a8090971d094643924f-chronyd.service-AjVcKG
vmware-root_5889-1983851818
yum.log
[root@master ~]# ansible 192.168.15.202 -u jack -k -m command -a 'ls /root' -b -K --选项-b表示使用sudo root权限,-K表示要输出sudo root密码
SSH password:    --输入jack密码
BECOME password[defaults to SSH password]: --输入sudo到root的密码
192.168.15.202 | FAILED | rc=-1 >>  --报错，因为jack用户没有sudo权限
Incorrect sudo password
[root@node2 ~]# id jack 
uid=1001(jack) gid=1001(jack) groups=1001(jack)
[root@node2 ~]# usermod -aG wheel jack   --加入sudo权限组wheel
[root@node2 ~]# id jack
uid=1001(jack) gid=1001(jack) groups=1001(jack),10(wheel)
[root@node2 ~]# echo 'export EDITOR=vim' > /etc/profile.d/env.sh && source /etc/profile.d/env.sh
[root@node2 ~]# visudo   --此时就有高亮了
[root@master ~]# ansible 192.168.15.202 -u jack -k -b -K -m command -a 'ls /root'
SSH password:    --输入jack密码 
BECOME password[defaults to SSH password]:  --输入sudo密码
192.168.15.202 | CHANGED | rc=0 >>
anaconda-ks.cfg
ks-pre.log
original-ks.cfg
[root@master ~]# ansible 192.168.15.202 -u jack -k -m command -a 'ls /root' -b
SSH password:   --192.168.15.202将wheel配置NOPASSWD: ALL时，可不用输入sudo密码
192.168.15.202 | CHANGED | rc=0 >>
anaconda-ks.cfg
ks-pre.log
original-ks.cfg

--配置expect免密码复制公钥到authenrized_keys中
[root@master ~]# yum install -y expect
[root@master ~]# cat expect_ssh-copy-id.sh
---
#!/usr/bin/expect  
set timeout 30

set ip [lindex $argv 0]
set username root
set password p@ssw0rd
spawn ssh-copy-id $username@$ip
expect {
        "(yes/no)" {send "yes\r"; exp_continue}
        "password:" {send "$password\r"}
}
interact
---
[root@master ~]# for i in 201 202;do /root/expect_ssh.sh 192.168.15.$i;done
[root@master ~]# ansible all -m ping  --不用输入-k进行密码登录了
 192.168.15.199 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[root@master ~]# grep -Ev '#|^$' /etc/ansible/hosts
[master]
192.168.15.199
[node]
192.168.15.20[1:2]
[root@master ~]# ansible node:master:aa -m ping   --逻辑或(:),表示主机在node或者在master组中，结果会将这两个组中的主机全部ping一下
[WARNING]: Could not match supplied host pattern, ignoring: aa
192.168.15.199 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[root@master ~]# ansible 'node:&master' -m ping  --逻辑与(:&),表示主机既在node组中也在master组中的主机，结果没有，因为这两个组中没有主机重合
[WARNING]: No hosts matched, nothing to do
[root@master ~]# ansible 'node:!master' -m ping  --逻辑非(:!)，表示主机在node组中，但不在master组中的主机
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
[root@master ~]# !grep
grep -Ev '#|^$' /etc/ansible/hosts 
[master]
192.168.15.199
[node]
192.168.15.199
192.168.15.20[1:2]
[root@master ~]# ansible 'master:node:&master:!node' -m ping  --逻辑或、逻辑与、逻辑非组合
[WARNING]: No hosts matched, nothing to do
[root@master ~]# ansible 'master:node:&master' -m ping  --逻辑或、逻辑与组合
192.168.15.199 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
--正则表达式匹配
[root@master ~]# ansible '~(node|master)*' -m ping 
192.168.15.199 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "ping": "pong"
}

--ansible命令执行过程
1. 加载自己的配置文件，默认在/etc/ansible/ansible.cfg
2. 加载自己对应的模块文件，如command
3. 通过ansible将模块或命令生成对应的临时py文件，并将该文件传输至远程服务器的对应执行用户$HOMS/.ansible/tmp/ansible-tmp-数字/XXX.py文件
4. 结文件+x执行
5. 执行并返回结果 
6. 删除临时py文件，sleep 0退出
--执行状态
绿色：执行成功并且不需要做改变的操作
黄色：执行成功并且对目标主机做变更的操作
红色：执行失败
注：执行状态颜色在/etc/ansible/ansible.cfg中[colors]更改

#ansible常见模块 
#---command，默认模块，可省略-m command
[root@master ~]# ansible all -a 'creates=/tmp ls -l /etc/fstab' --creates，表示如果不存在这个文件或目录则会执行后面的命令，否则存在将不会执行后面的命令，就是creates是否执行成功，决定后面的命令是否成功
192.168.15.199 | SUCCESS | rc=0 >>
skipped, since /tmp exists
192.168.15.201 | SUCCESS | rc=0 >>
skipped, since /tmp exists
192.168.15.202 | SUCCESS | rc=0 >>
skipped, since /tmp exists
[root@master ~]# ansible all -a 'removes=/etc/jackli123 ls -l /etc/fstab'  --表示如果removes命令执行成功将会执行后面的命令，否则不会执行，跟creates正反，但是不是真正的删除这个文件/etc/jackli123
192.168.15.202 | SUCCESS | rc=0 >>
skipped, since /etc/jackli123 does not exist
192.168.15.199 | SUCCESS | rc=0 >>
skipped, since /etc/jackli123 does not exist
192.168.15.201 | SUCCESS | rc=0 >>
skipped, since /etc/jackli123 does not exist
[root@master ~]# ansible all -a 'touch /tmp/jackli123'   --新件文件测试
[root@master ~]# ansible all -a 'removes=/tmp/jackli123 ls /etc/fstab'  --表示新建文件存在，则会执行后面命令
192.168.15.202 | CHANGED | rc=0 >>
/etc/fstab
192.168.15.199 | CHANGED | rc=0 >>
/etc/fstab
192.168.15.201 | CHANGED | rc=0 >>
/etc/fstab
[root@master ~]# ansible all -a 'ls /tmp/jackli123'  --这个文件还存在，表示前面的操作不会删除
192.168.15.199 | CHANGED | rc=0 >>
/tmp/jackli123
192.168.15.202 | CHANGED | rc=0 >>
/tmp/jackli123
192.168.15.201 | CHANGED | rc=0 >>
/tmp/jackli123
注：commoad模块不支持$VARIABLE,|,>等特殊符号变量，更换shell模块使用

#---shell模块  --比command功能强大，可以支持$VARIABLE,|,>等特殊符号变量
[root@master ~]# ansible all -a 'echo $HOSTNAME'
192.168.15.199 | CHANGED | rc=0 >>
$HOSTNAME
192.168.15.202 | CHANGED | rc=0 >>
$HOSTNAME
192.168.15.201 | CHANGED | rc=0 >>
$HOSTNAME
[root@master ~]# ansible all -m shell -a 'echo $HOSTNAME'
192.168.15.199 | CHANGED | rc=0 >>
master
192.168.15.201 | CHANGED | rc=0 >>
node1
192.168.15.202 | CHANGED | rc=0 >>
node2

#---script模块 ---复制控制端脚本到被控端并运行
[root@master ~/ansible]# cat host.sh 
---
#!/bin/sh

hostname
---
[root@master ~/ansible]# ansible all -m script -a '/root/ansible/host.sh'  --目录不存在自己会新建
192.168.15.199 | CHANGED => {
    "changed": true, 
    "rc": 0, 
    "stderr": "Shared connection to 192.168.15.199 closed.\r\n", 
    "stderr_lines": [
        "Shared connection to 192.168.15.199 closed."
    ], 
    "stdout": "master\r\n", 
    "stdout_lines": [
        "master"
    ]
}
192.168.15.201 | CHANGED => {
    "changed": true, 
    "rc": 0, 
    "stderr": "Shared connection to 192.168.15.201 closed.\r\n", 
    "stderr_lines": [
        "Shared connection to 192.168.15.201 closed."
    ], 
    "stdout": "node1\r\n", 
    "stdout_lines": [
        "node1"
    ]
}
192.168.15.202 | CHANGED => {
    "changed": true, 
    "rc": 0, 
    "stderr": "Shared connection to 192.168.15.202 closed.\r\n", 
    "stderr_lines": [
        "Shared connection to 192.168.15.202 closed."
    ], 
    "stdout": "node2\r\n", 
    "stdout_lines": [
        "node2"
    ]
}
注：脚本后面可接脚本参数

#---copy模块 --从服务器复制文件到客户端，fetch模块则相反
[root@master ~/ansible]# ansible-doc -s copy   --帮助信息
[root@master ~/ansible]# ansible all -m copy -a 'src=/root/ansible/selinux dest=/etc/selinux/config mode=644 owner=root group=root backup=yes'
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "backup_file": "/etc/selinux/config.51180.2021-03-07@14:37:50~", 
    "changed": true, 
    "checksum": "975be6f654c612f31d3bd7a9d9a994c6713480f6", 
    "dest": "/etc/selinux/config", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "412d1bddeae6e4cf1ab31b3e7dee0719", 
    "mode": "0644", 
    "owner": "root", 
    "size": 547, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099069.09-51031-95593537386457/source", 
    "state": "file", 
    "uid": 0
}
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "backup_file": "/etc/selinux/config.60199.2021-03-07@14:37:50~", 
    "changed": true, 
    "checksum": "975be6f654c612f31d3bd7a9d9a994c6713480f6", 
    "dest": "/etc/selinux/config", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "412d1bddeae6e4cf1ab31b3e7dee0719", 
    "mode": "0644", 
    "owner": "root", 
    "size": 547, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099069.1-51035-134301818810806/source", 
    "state": "file", 
    "uid": 0
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "backup_file": "/etc/selinux/config.58788.2021-03-07@14:37:50~", 
    "changed": true, 
    "checksum": "975be6f654c612f31d3bd7a9d9a994c6713480f6", 
    "dest": "/etc/selinux/config", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "412d1bddeae6e4cf1ab31b3e7dee0719", 
    "mode": "0644", 
    "owner": "root", 
    "size": 547, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099069.09-51033-225563717819246/source", 
    "state": "file", 
    "uid": 0
}
注：如果没有备份文件，说明源文件和目标文件md5值相同
[root@master ~/ansible]# ansible all -m copy -a 'src=/root/ansible/selinux dest=/etc/selinux/config mode=644 owner=root group=root backup=yes'
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "backup_file": "/etc/selinux/config.51180.2021-03-07@14:37:50~", 
    "changed": true, 
    "checksum": "975be6f654c612f31d3bd7a9d9a994c6713480f6", 
    "dest": "/etc/selinux/config", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "412d1bddeae6e4cf1ab31b3e7dee0719", 
    "mode": "0644", 
    "owner": "root", 
    "size": 547, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099069.09-51031-95593537386457/source", 
    "state": "file", 
    "uid": 0
}
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "backup_file": "/etc/selinux/config.60199.2021-03-07@14:37:50~", 
    "changed": true, 
    "checksum": "975be6f654c612f31d3bd7a9d9a994c6713480f6", 
    "dest": "/etc/selinux/config", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "412d1bddeae6e4cf1ab31b3e7dee0719", 
    "mode": "0644", 
    "owner": "root", 
    "size": 547, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099069.1-51035-134301818810806/source", 
    "state": "file", 
    "uid": 0
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "backup_file": "/etc/selinux/config.58788.2021-03-07@14:37:50~", 
    "changed": true, 
    "checksum": "975be6f654c612f31d3bd7a9d9a994c6713480f6", 
    "dest": "/etc/selinux/config", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "412d1bddeae6e4cf1ab31b3e7dee0719", 
    "mode": "0644", 
    "owner": "root", 
    "size": 547, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099069.09-51033-225563717819246/source", 
    "state": "file", 
    "uid": 0
}
[root@master ~/ansible]# 
[root@master ~/ansible]# 
[root@master ~/ansible]# ansible master -m copy -a 'content=hello\nworld!\n dest=/tmp/helloWorld.txt'
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "checksum": "1202b045005e5d7445c5bb7dd010cdf7f1ca575f", 
    "dest": "/tmp/helloWorld.txt", 
    "gid": 0, 
    "group": "root", 
    "md5sum": "7eb1416759e95347e506edb8c45ff4f6", 
    "mode": "0644", 
    "owner": "root", 
    "size": 12, 
    "src": "/root/.ansible/tmp/ansible-tmp-1615099477.42-51648-261832060472552/source", 
    "state": "file", 
    "uid": 0
}
[root@master ~/ansible]# ansible all -m shell -a 'cat /tmp/helloWorld.txt'
192.168.15.199 | CHANGED | rc=0 >>
hello
world!

#---fetch  --从客户端抓取单个文件到控制端服务器上
[root@master /ansible-data]# ansible all -m fetch -a 'src=/var/log/messages dest=/ansible-data/'
192.168.15.199 | SUCCESS => {
    "changed": false, 
    "checksum": "e095c787a52b427bf0c8d910cb69e3f5bea12584", 
    "dest": "/ansible-data/192.168.15.199/var/log/messages", 
    "file": "/var/log/messages", 
    "md5sum": "5572561bcd812710a177fefed953e1fa"
}
192.168.15.201 | SUCCESS => {
    "changed": false, 
    "checksum": "fda6538dc4e88ae2a5699c478900f27ba4ed8597", 
    "dest": "/ansible-data/192.168.15.201/var/log/messages", 
    "file": "/var/log/messages", 
    "md5sum": "2d32ace91672c0b47b7cce680abcc13c"
}
192.168.15.202 | SUCCESS => {
    "changed": false, 
    "checksum": "c5260556d6f4867ee64503190517bba7e246c28c", 
    "dest": "/ansible-data/192.168.15.202/var/log/messages", 
    "file": "/var/log/messages", 
    "md5sum": "97fee7ca097bfab13728881e6861b8a4"
}
[root@master /ansible-data]# ansible all -m shell -a 'tar czf /tmp/log.tar.gz /var/log/*.log'  --先在客户端先打包
[WARNING]: Consider using the unarchive module rather than running 'tar'.  If you need to use
command because unarchive is insufficient you can add 'warn: false' to this command task or set
'command_warnings=False' in ansible.cfg to get rid of this message.
192.168.15.199 | CHANGED | rc=0 >>
tar: Removing leading `/' from member names
192.168.15.202 | CHANGED | rc=0 >>
tar: Removing leading `/' from member names
192.168.15.201 | CHANGED | rc=0 >>
tar: Removing leading `/' from member names
[root@master /ansible-data]# ansible all -m fetch -a 'src=/tmp/log.tar.gz dest=/ansible-data' 
192.168.15.199 | CHANGED => {
    "changed": true, 
    "checksum": "31f66214c57a881fa54d4a7d9b2be7be01f8f9ae", 
    "dest": "/ansible-data/192.168.15.199/tmp/log.tar.gz", 
    "md5sum": "585432335abff88052283380b212ba9c", 
    "remote_checksum": "31f66214c57a881fa54d4a7d9b2be7be01f8f9ae", 
    "remote_md5sum": null
}
192.168.15.201 | CHANGED => {
    "changed": true, 
    "checksum": "2f479c7778ecaad7cc760739e2779db3e9a7b87c", 
    "dest": "/ansible-data/192.168.15.201/tmp/log.tar.gz", 
    "md5sum": "e80704bea6fed63e000db9c6bfdb9566", 
    "remote_checksum": "2f479c7778ecaad7cc760739e2779db3e9a7b87c", 
    "remote_md5sum": null
}
192.168.15.202 | CHANGED => {
    "changed": true, 
    "checksum": "44c09d1e7657c151c976357ae6111239d6c9c09c", 
    "dest": "/ansible-data/192.168.15.202/tmp/log.tar.gz", 
    "md5sum": "0a40bdb6b215cb736793f86a3356b9e8", 
    "remote_checksum": "44c09d1e7657c151c976357ae6111239d6c9c09c", 
    "remote_md5sum": null
}
[root@master /ansible-data]# tree 
.
├── 192.168.15.199
│   ├── tmp
│   │   └── log.tar.gz
│   └── var
│       └── log
│           └── messages
├── 192.168.15.201
│   ├── tmp
│   │   └── log.tar.gz
│   └── var
│       └── log
│           └── messages
└── 192.168.15.202
    ├── tmp
    │   └── log.tar.gz
    └── var
        └── log
            └── messages
[root@master /ansible-data/192.168.15.202/tmp]# tar -tvf log.tar.gz 
-rw------- root/root         0 2021-03-07 13:24 var/log/boot.log
-rw-r--r-- root/root       678 2020-06-24 12:29 var/log/vmware-network.1.log
-rw-r--r-- root/root      5895 2021-03-06 16:53 var/log/vmware-network.log
-rw-r--r-- root/root      2025 2021-03-07 13:01 var/log/vmware-vmsvc.log
-rw------- root/root      2459 2020-06-24 12:34 var/log/yum.log

#---file模块
path: alias dest,name
[root@master ~]# ansible all -m file -a 'path=/tmp/test01.txt state=touch'
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/test01.txt", 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "owner": "root", 
    "size": 0, 
    "state": "file", 
    "uid": 0
}
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/test01.txt", 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "owner": "root", 
    "size": 0, 
    "state": "file", 
    "uid": 0
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/test01.txt", 
    "gid": 0, 
    "group": "root", 
    "mode": "0644", 
    "owner": "root", 
    "size": 0, 
    "state": "file", 
    "uid": 0
}
[root@master ~]# ansible all -m shell -a 'ls -l /tmp/test01.txt'
192.168.15.199 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 0 Mar  7 15:18 /tmp/test01.txt
192.168.15.202 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 0 Mar  7 15:18 /tmp/test01.txt
192.168.15.201 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 0 Mar  7 15:18 /tmp/test01.txt
[root@master ~]# ansible all -m file -a 'dest=/tmp/test01.txt state=absent' --absent表示删除一个文件
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/test01.txt", 
    "state": "absent"
}
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/test01.txt", 
    "state": "absent"
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/test01.txt", 
    "state": "absent"
}
[root@master ~]# ansible all -m shell -a 'ls -l /tmp/test01.txt'
192.168.15.199 | FAILED | rc=2 >>
ls: cannot access /tmp/test01.txt: No such file or directorynon-zero return code
192.168.15.201 | FAILED | rc=2 >>
ls: cannot access /tmp/test01.txt: No such file or directorynon-zero return code
192.168.15.202 | FAILED | rc=2 >>
ls: cannot access /tmp/test01.txt: No such file or directorynon-zero return code
[root@master /tmp]# ansible all -m file -a 'dest=/tmp/test01dir state=directory' --新建目录
[root@master /tmp]# ansible all -m file -a 'dest=/tmp/test01dir state=absent' --删除目录
[root@master /tmp]# ansible all -m file -a 'src=/var/log/messages dest=/tmp/mes.link state=link'
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/mes.link", 
    "gid": 0, 
    "group": "root", 
    "mode": "0777", 
    "owner": "root", 
    "size": 17, 
    "src": "/var/log/messages", 
    "state": "link", 
    "uid": 0
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/mes.link", 
    "gid": 0, 
    "group": "root", 
    "mode": "0777", 
    "owner": "root", 
    "size": 17, 
    "src": "/var/log/messages", 
    "state": "link", 
    "uid": 0
}
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "dest": "/tmp/mes.link", 
    "gid": 0, 
    "group": "root", 
    "mode": "0777", 
    "owner": "root", 
    "size": 17, 
    "src": "/var/log/messages", 
    "state": "link", 
    "uid": 0
}

[root@master /tmp]# ansible all -m shell -a 'ls -l /tmp/mes.link'
192.168.15.201 | CHANGED | rc=0 >>
lrwxrwxrwx 1 root root 17 Mar  7 15:26 /tmp/mes.link -> /var/log/messages
192.168.15.199 | CHANGED | rc=0 >>
lrwxrwxrwx 1 root root 17 Mar  7 15:26 /tmp/mes.link -> /var/log/messages
192.168.15.202 | CHANGED | rc=0 >>
lrwxrwxrwx 1 root root 17 Mar  7 15:26 /tmp/mes.link -> /var/log/messages

[root@master /tmp]# ansible all -m file -a 'dest=/tmp/mes.link state=absent'
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/mes.link", 
    "state": "absent"
}
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/mes.link", 
    "state": "absent"
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "path": "/tmp/mes.link", 
    "state": "absent"
}

#---hostname模块,生效并永久保存
[root@master /tmp]# ansible 192.168.15.202 -m hostname -a 'name=node02.magedu.com'
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "ansible_domain": "magedu.com", 
        "ansible_fqdn": "node02.magedu.com", 
        "ansible_hostname": "node02", 
        "ansible_nodename": "node02.magedu.com", 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "name": "node02.magedu.com"
}

#---cron模块,计划任务模块 
minute,hour,day,month,weekday,job,name
-----生成crontab
[root@master /tmp]# ansible all -m cron -a 'weekday=1,3,7 job="/usr/bin/wall FBI warnning" name=warnningFBI'
192.168.15.199 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "envs": [], 
    "jobs": [
        "warnningFBI"
    ]
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "envs": [], 
    "jobs": [
        "warnningFBI"
    ]
}
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false, 
    "envs": [], 
    "jobs": [
        "warnningFBI"
    ]
}
[root@node1 ~]# crontab -l
# Lines below here are managed by Salt, do not edit
# SALT_CRON_IDENTIFIER:ntpdate time1.aliyun.com
*/5 * * * * ntpdate time1.aliyun.com
#Ansible: warnningFBI
* * * * 1,3,7 /usr/bin/wall FBI warnning
----取消crontab
[root@master /tmp]# ansible all -m cron -a 'disabled=true job="/usr/bin/wall FBI warnning" name=warnningFBI'   
192.168.15.199 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "envs": [], 
    "jobs": [
        "warnningFBI", 
        "warningFBI"
    ]
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "envs": [], 
    "jobs": [
        "warnningFBI", 
        "warningFBI"
    ]
}
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "envs": [], 
    "jobs": [
        "warnningFBI", 
        "warningFBI"
    ]
}
---启用crontab
[root@master /tmp]# ansible all -m cron -a 'disabled=false job="/usr/bin/wall FBI warnning" name=warnningFB'
---删除crontab
[root@master /tmp]# ansible all -m cron -a 'state=absent job="/usr/bin/wall FBI warnning" name=warningFBI'

#---yum模块，软件管理模块
install: present,installed,latest
remove: absent，removed
list: installed,updates
disable_gpg_check=yes  --关闭gpg检查
update_cache=yes  --更新yum缓存
[root@master /tmp]# ansible all -m yum -a 'name=vsftpd state=present'  --安装vsftpd
[root@master /tmp]# ansible all -m yum -a 'state=absent name=vsftp'  --删除vsftpd
[root@master /tmp]# ansible all -m yum -a 'name=/data/vsftpd.rpm state=present'  --安装本地rpm包
[root@master /tmp]# ansible all -m yum -a 'name=vsftpd,git state=present'  --安装多个包
[root@master /tmp]# ansible all -m yum -a 'list=installed'  --列出已经安装的包

#---service模块
state: started，stopped，restarted
enabled: yes/no,true/false
[root@master /tmp]# ansible node -m service -a 'name=vsftpd state=started enabled=yes'
[root@master /tmp]# ansible node -m service -a 'name=vsftpd state=restarted'
[root@master /tmp]# ansible node -m shell -a 'systemctl is-enabled vsftpd'
192.168.15.202 | CHANGED | rc=0 >>
enabled
192.168.15.201 | CHANGED | rc=0 >>
enabled

#---group模块 
name：组名称
gid: gid
system: 是否为系统用户,true/false,yes/no
[root@master /tmp]# ansible node -m group -a 'name=nginx gid=2000 system=yes' --增加组
[root@master /tmp]# ansible node -m shell -a 'getent group nginx'
192.168.15.202 | CHANGED | rc=0 >>
nginx:x:2000:
192.168.15.201 | CHANGED | rc=0 >>
nginx:x:2000:
[root@master /tmp]# ansible node -m group -a 'name=nginx state=absent' --删除用户


#---user模块
name：用户名称 
shell：用户shell
uid: 用户uid
system: 是否为系统用户,true/false,yes/no
home: 用户家目录
groups: 抚助组
comment: 用户描述信息
state: 运作是新建用户还是删除用户，present/absent
[root@master /tmp]# ansible node -m user -a 'name=nginx shell=/sbin/nologin uid=2000 system=true home=/var/nginx groups=root,bin comment="nginx service user"'
192.168.15.202 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "nginx service user", 
    "create_home": true, 
    "group": 992, 
    "groups": "root,bin", 
    "home": "/var/nginx", 
    "name": "nginx", 
    "shell": "/sbin/nologin", 
    "state": "present", 
    "system": true, 
    "uid": 2000
}
192.168.15.201 | CHANGED => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": true, 
    "comment": "nginx service user", 
    "create_home": true, 
    "group": 992, 
    "groups": "root,bin", 
    "home": "/var/nginx", 
    "name": "nginx", 
    "shell": "/sbin/nologin", 
    "state": "present", 
    "system": true, 
    "uid": 2000
}
[root@master /tmp]# ansible node -m user -a 'name=nginx state=absent remove=yes' --删除用户并删除用户家目录

#ansible-galaxy命令
[root@master ~]# ansible-galaxy list  --列出所有已安装的galaxy
# /usr/share/ansible/roles
# /etc/ansible/roles
[WARNING]: - the configured path /root/.ansible/roles does not exist.
[root@master ~]# ansible-galaxy install geerlingguy.nginx  --安装角色
- downloading role 'nginx', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-nginx/archive/2.8.0.tar.gz
- extracting geerlingguy.nginx to /root/.ansible/roles/geerlingguy.nginx
- geerlingguy.nginx (2.8.0) was installed successfully
[root@master ~]# ansible-galaxy remove geerlingguy.nginx  --删除角色
[root@master ~/.ansible/roles/geerlingguy.nginx/tasks]# ansible-galaxy list
# /root/.ansible/roles
- geerlingguy.nginx, 2.8.0
# /usr/share/ansible/roles
# /etc/ansible/roles

#ansible-pull命令  --推送命令至远程，效率无限提升，对运维要求较高
#ansible-vault命令 --针对剧本进行加解密
[root@master ~/ansible]# ansible-vault encrypt hello.yml  --加密
New Vault password: 
Confirm New Vault password: 
Encryption successful
[root@master ~/ansible]# cat hello.yml 
$ANSIBLE_VAULT;1.1;AES256
32313164303936313066616435326432393632636163323365303832616233313666623366366431
3230633134666433393562633737663433383862326236650a643931663730316335393166376237
66306437343063373663326531646161656663663764633139366263393736376435656632643936
6631333763363364340a383836386562326561326235376239633336383834376630636332633062
31633664666636306663343166313430366437363130326435353032373063613062356239323238
37396537666462633137336631633039326162646537356438316364613862333135363566323536
31333032316532383161653964326331393731616163393631616635313639346366323362363434
35636332303762333234306264353862336566623763623662363965623163393466343436386332
3431
[root@master ~/ansible]# ansible-vault view hello.yml   --查看
Vault password: 
---
- hosts: node
  remote_user: root

  tasks:
    - name: hello
      command: hostname 
[root@master ~/ansible]# ansible-vault edit hello.yml  --编辑
[root@master ~/ansible]# ansible-vault rekey hello.yml  --更改密钥
Vault password: 
New Vault password: 
Confirm New Vault password: 
[root@master ~/ansible]# ansible-vault create hello2.yml  --新建加加密文件
New Vault password: 
Confirm New Vault password: 
[root@master ~/ansible]# ansible-vault decrypt hello.yml  --解密
Vault password: 
Decryption successful
[root@master ~/ansible]# cat hello.yml 
---
- hosts: node
  remote_user: root

  tasks:
    - name: hello
      command: hostname 

#ansible-console命令
[root@master ~/ansible]# ansible-console
Welcome to the ansible console.
Type help or ? to list commands.

root@all (3)[f:5]$    --root：表示以root用户运行，all:表示在所有主机组中，(3):表示all主机组中有3个主机，[f:5]：表示并发有5个主机
root@node (2)[f:5]$ command hostname  --模块 命令
192.168.15.201 | CHANGED | rc=0 >>
node1
192.168.15.202 | CHANGED | rc=0 >>
node02



#ansible-playbook  --剧本
playbook初体验：
[root@master ~/ansible]# vim hello.yml 
---
- host: node   --主机组
  remote_user: root   --在客户端用什么身份执行
  tasks:    --任务模块
    - name: hello   --任务名称
      command: hostname   --模块名称，后面是模块的命令

[root@master ~/ansible]# cat hello.yml 
---
- hosts: node
  remote_user: root

  tasks:
    - name: hello
      command: hostname 
[root@master ~/ansible]# ansible-playbook hello.yml 

PLAY [node] *****************************************************************************************

TASK [Gathering Facts] ******************************************************************************
ok: [192.168.15.201]
ok: [192.168.15.202]

TASK [hello] ****************************************************************************************
changed: [192.168.15.202]
changed: [192.168.15.201]

PLAY RECAP ******************************************************************************************
192.168.15.201             : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.15.202             : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  

yaml语法简介：
一个yaml文件至少需要一个name和task
--task中格式抒写：
tasks:
(1)action: module arguments
(2)module： arguments  --建议使用这种格式

--如果命令或脚本的退出码不为零，如果还要继续执行则可以使用如下方法：
tasks:
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand || /bin/true
或
  - name: run this command and ignore the result
    shell: /usr/bin/somecommand
    ignore_error:True


#ansible-playbook
[root@master ~/ansible]# cat file.yml 
---
- hosts: node
  remote_user: root   --远端执行的用户名称

  tasks:
    - name: create new file
      file: name=/data/newfile state=touch
    - name: create new user
      user: name=httpd system=true shell=/sbin/nologin 
    - name: install packages
      yum: name=httpd state=present
    - name: copy html
      copy: src=/var/www/html/index.html dest=/var/www/html/
    - name: start service
      service: name=httpd state=started enabled=yes
[root@master ~/ansible]# ansible-playbook -C file.yml  --测试配置文件
[root@master ~/ansible]# ansible-playbook file.yml --执行playbook
[root@master ~/ansible]# ansible all -m shell -a 'curl -s 127.0.0.1'
192.168.15.199 | CHANGED | rc=0 >>
hello ansible!
192.168.15.202 | CHANGED | rc=0 >>
hello ansible!
192.168.15.201 | CHANGED | rc=0 >>
hello ansible!
[root@master ~/ansible]# ansible-playbook --list-hosts file.yml  --从剧本中查看应用的主机名称列表
playbook: file.yml
  play #1 (node): node	TAGS: []
    pattern: [u'node']
    hosts (2):
      192.168.15.201
      192.168.15.202
[root@master ~/ansible]# ansible-playbook file.yml --limit 192.168.15.202 --只在指定主机上运行，不加则在整个node组中运行

#handlers和notify结合使用触发条件
handlers: 是task列表，这些task与前述的task并没有本质上的不同，用于当关注的资源发生变化时，才会采取一定的操作
notify：此action可用于在每个play的最后被触发，这样可避免多次有改变发生时每次都执行指定的操作，仅在所有的变化发生完成后一次性地执行指定操作。在notify中列出的操作称为handler，也即notify中调用handler中定义的操作。
--例子：
[root@master ~/ansible]# cat httpd.yml 
---
- hosts: node
  remote_user: root

  tasks:
    - name: install httpd packages
      yum: name=httpd state=present
    - name: copy config file
      copy: src=files/httpd.conf dest=/etc/httpd/conf/ backup=yes
      notify: restart service  --通知给handler，notify value是list,可以写多个handler
    - name: start service
      service: name=httpd state=started enabled=yes

  handlers:
    - name: restart service
      service: name=httpd state=restarted 
        
[root@master ~/ansible]# ansible node -m shell -a 'ss -tnl | grep :9527'
192.168.15.201 | CHANGED | rc=0 >>
LISTEN     0      128         :::9527                    :::*                  
192.168.15.202 | CHANGED | rc=0 >>
LISTEN     0      128         :::9527                    :::*           

---playbook中的tags
tags: 多个action可以使用同一个名称标签
[root@master ~/ansible]# ansible node -m service -a 'name=httpd state=stopped'
[root@master ~/ansible]# ansible node -m shell -a 'ss -tnl | grep :9527'
192.168.15.202 | FAILED | rc=1 >>
non-zero return code
192.168.15.201 | FAILED | rc=1 >>
non-zero return code
[root@master ~/ansible]# cat httpd.yml 
---
- hosts: node
  remote_user: root

  tasks:
    - name: install httpd packages
      yum: name=httpd state=present
      tags: inshttpd
    - name: copy config file
      copy: src=files/httpd.conf dest=/etc/httpd/conf/ backup=yes
      notify: restart service
    - name: start service
      service: name=httpd state=started enabled=yes
      tags: rshttpd

  handlers:
    - name: restart service
      service: name=httpd state=restarted 
[root@master ~/ansible]# ansible-playbook -t rshttpd httpd.yml  --挑选标签tag运
行
[root@master ~/ansible]# ansible node -m shell -a 'ss -tnl | grep :9527'
192.168.15.202 | CHANGED | rc=0 >>
LISTEN     0      128         :::9527                    :::*                  
192.168.15.201 | CHANGED | rc=0 >>
LISTEN     0      128         :::9527                    :::*   
[root@master ~/ansible]# ansible-playbook -t inshttpd,rshttpd httpd.yml  --挑选多个标签运行
[root@master ~/ansible]# ansible-playbook httpd.yml --list-tags
playbook: httpd.yml
  play #1 (node): node	TAGS: []
      TASK TAGS: [inshttpd, rshttpd]

#---setup模块，可查看ansible收集的变量
[root@master ~/ansible]# ansible node -m setup -a 'filter=ansible_fqdn'
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "ansible_fqdn": "node02", 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "ansible_fqdn": "node1", 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}
[root@master ~/ansible]# ansible node -m setup -a 'filter=*fqdn*'
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "ansible_fqdn": "node1", 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "ansible_fqdn": "node02", 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}
[root@master ~/ansible]# ansible node -m setup -a 'filter=*addres*'
192.168.15.201 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.15.201", 
            "172.17.0.1"
        ], 
        "ansible_all_ipv6_addresses": [
            "fe80::250:56ff:fe3a:d302"
        ], 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}
192.168.15.202 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "192.168.15.202", 
            "172.17.0.1"
        ], 
        "ansible_all_ipv6_addresses": [
            "fe80::250:56ff:fe3a:d303"
        ], 
        "discovered_interpreter_python": "/usr/bin/python"
    }, 
    "changed": false
}

---变量
[root@master ~/ansible]# cat app.yml
---
- hosts: node
  remote_user: root

  tasks:
    - name: install packages
      yum: name={{ pkname }} state=present
    - name: start service
      service: name={{ pkname }} state=started enabled=yes
[root@master ~/ansible]# ansible-playbook -e 'pkname=vsftpd' app.yml --1.命令行传入变量，可以多个变量，如：'pkname=vsftpd pkname=redis'
[root@master ~/ansible]# ansible node -m shell -a 'ss -tnl | grep :21'
192.168.15.201 | CHANGED | rc=0 >>
LISTEN     0      32          :::21                      :::*                  
192.168.15.202 | CHANGED | rc=0 >>
LISTEN     0      32          :::21                      :::*      
[root@master ~/ansible]# cat app.yml  --2.在playbook中定义变量
---
- hosts: node
  remote_user: root
  vars:
    - pkname: httpd

  tasks:
    - name: install packages
      yum: name={{ pkname }} state=present
    - name: start service
      service: name={{ pkname }} state=started enabled=yes
[root@master ~/ansible]# ansible-playbook app.yml --limit 192.168.15.201
[root@master ~/ansible]# grep -Ev '#|^$' /etc/ansible/hosts  --3.在主机清单中定义主机级别变量
[master]
192.168.15.199
[node]
192.168.15.201 http_port=81
192.168.15.202 http_port=82
[root@master ~/ansible]# ansible-playbook hostname.yml --limit 192.168.15.201
[root@master ~/ansible]# ansible node -m shell -a 'hostname' --limit 192.168.15.201
192.168.15.201 | CHANGED | rc=0 >>
www81.magedu.com

[root@master ~/ansible]# grep -Ev '#|^$' /etc/ansible/hosts
[master]
192.168.15.199
[node]
192.168.15.201 http_port=81
192.168.15.202 http_port=82
[node:vars]     --4.在主机清单中定义主机组级别变量
nodename=www
domainname=magedu.com
[root@master ~/ansible]# cat hostname.yml 
---
- hosts: node
  remote_user: root

  tasks:
    - name: set hostname
      hostname: name={{nodename}}{{ http_port }}.{{domainname}}
[root@master ~/ansible]# ansible-playbook hostname.yml 
[root@master ~/ansible]# ansible node -m shell -a 'hostname' 
#变量优先级： 命令行变量 > playbook变量 > /etc/ansible/hosts主机变量 > /etc/ansible/hosts主机组变量


#jinja2模板和变量文件
路径：/root/ansible/templates
[root@salt ~/ansible]# grep -Ev '#|^$' /etc/ansible/hosts 
[master]
172.168.2.222 role=master
[node]
172.168.2.223 role=node
[node:vars]
service=jenkins
[root@salt ~/ansible]# cat var.env
nginx_port: 8080
httpd_port: 8081
[root@salt ~/ansible]# cat jinja2.yml 
---
- hosts: node
  remote_user: root
  vars_files:
    - /root/ansible/var.env

  tasks: 
    - name: copy config
      #jinja2 default template is /root/ansible/templates
      template: src=httpd.conf.j2 dest=/usr/local/src/httpd.conf
[root@salt ~/ansible]# cat templates/httpd.conf.j2 
listen {{ httpd_port }}
listen {{ nginx_port }}
[root@salt ~/ansible]# ansible-playbook -C jinja2.yml 
[root@salt ~/ansible]# ansible-playbook jinja2.yml 
[root@salt ~/ansible]# ansible node -m shell -a 'cat /usr/local/src/httpd.conf'
172.168.2.223 | CHANGED | rc=0 >>
listen 8081
listen 8080

#when
[root@salt ~/ansible]# cat when.yml 
---
- hosts: all
  remote_user: root

  tasks:
    - name: copy conf
      template: src=/etc/fstab dest=/usr/local/src/fstab
      when: ansible_fqdn == "salt"
[root@salt ~/ansible]# ansible-playbook when.yml 

PLAY [all] ***********************************************************************************************

TASK [Gathering Facts] ***********************************************************************************
ok: [172.168.2.222]
ok: [172.168.2.223]

TASK [copy conf] *****************************************************************************************
skipping: [172.168.2.223]
changed: [172.168.2.222]

PLAY RECAP ***********************************************************************************************
172.168.2.222              : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
172.168.2.223              : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   

[root@salt ~/ansible]# ansible all -m shell -a 'ls -l /usr/local/src/fstab'
172.168.2.222 | CHANGED | rc=0 >>
-rw-r--r-- 1 root root 436 Mar  9 16:01 /usr/local/src/fstab
172.168.2.223 | FAILED | rc=2 >>
ls: cannot access /usr/local/src/fstab: No such file or directorynon-zero return code

#item迭代
[root@salt ~/ansible]# cat item.yml 
---
- hosts: node
  remote_user: root

  tasks:
    - name: create user
      user: name={{ item.user }} state=present groups={{ item.group }} system=true shell=/sbin/nologin
      with_items:
        - { user: "test01", group: "bin" }
        - { user: "test02", group: "bin" }
        - { user: "test03", group: "bin" }
[root@salt ~/ansible]# ansible-playbook -C item.yml 
[root@salt ~/ansible]# ansible-playbook item.yml
[root@salt ~/ansible]# ansible node -m shell -a 'tail /etc/passwd'
172.168.2.223 | CHANGED | rc=0 >>
www:x:1000:1000:www:/home/www:/sbin/bash
zabbix:x:997:993:Zabbix Monitoring System:/var/lib/zabbix:/sbin/nologin
jenkins:x:996:992:Jenkins Automation Server:/var/lib/jenkins:/bin/false
mysql:x:3306:3306:mysql:/home/mysql:/sbin/nologin
tinyproxy:x:995:991:tinyproxy user:/var/run/tinyproxy:/bin/false
prometheus:x:3307:9090::/home/prometheus:/sbin/nologin
grafana:x:994:990:grafana user:/usr/share/grafana:/sbin/nologin
test01:x:993:989::/home/test01:/sbin/nologin
test02:x:992:988::/home/test02:/sbin/nologin
test03:x:991:987::/home/test03:/sbin/nologin
[root@salt ~/ansible]# ansible node -m shell -a 'id test01 '
172.168.2.223 | CHANGED | rc=0 >>
uid=993(test01) gid=989(test01) groups=989(test01),1(bin)


#for循环
[root@salt ~/ansible/templates]# cat ../for.yml 
---
- hosts: node
  remote_user: root
  vars:
    ports:
      - listen_port: 81
      - listen_port: 82
      - listen_port: 83

  tasks:
    - name: copy conf
      template: src=for.conf.j2 dest=/usr/local/src/nginx.conf
[root@salt ~/ansible/templates]# cat for.conf.j2 
{% for port in ports %}
server{
	listen {{ port.listen_port }}
}
{% endfor %}
[root@salt ~/ansible/templates]# ansible-playbook ../for.yml 

PLAY [node] **********************************************************************************************

TASK [Gathering Facts] ***********************************************************************************
ok: [172.168.2.223]

TASK [copy conf] *****************************************************************************************
changed: [172.168.2.223]

PLAY RECAP ***********************************************************************************************
172.168.2.223              : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[root@salt ~/ansible/templates]# ansible node -m shell -a 'cat /usr/local/src/nginx.conf'
172.168.2.223 | CHANGED | rc=0 >>
server{
	listen 81
}
server{
	listen 82
}
server{
	listen 83
}



--for example 2
[root@salt ~/ansible/templates]# cat for2.conf.j2
{% for p in ports %}
server{
	listen {{ p.port }}
	hostname {{ p.name }}
	root {{ p.rootdir }}
}
{% endfor %}
[root@salt ~/ansible]# cat for2.yml 
---
- hosts: node
  remote_user: root
  vars:
    ports:
      - web1:
        port: 81
        name: web1.magedu.com
        rootdir: /data/website1
      - web2:
        port: 82
        name: web2.magedu.com
        rootdir: /data/website2
      - web3:
        port: 83
        name: web3.magedu.com
        rootdir: /data/website3

  tasks:
    - name: copy conf
      template: src=for2.conf.j2 dest=/usr/local/src/nginx2.conf
[root@salt ~/ansible]# ansible-playbook -C for2.yml
[root@salt ~/ansible]# ansible-playbook for2.yml

PLAY [node] **********************************************************************************************

TASK [Gathering Facts] ***********************************************************************************
ok: [172.168.2.223]

TASK [copy conf] *****************************************************************************************
changed: [172.168.2.223]

PLAY RECAP ***********************************************************************************************
172.168.2.223              : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

[root@salt ~/ansible]# ansible node -m shell -a 'cat /usr/local/src/nginx2.conf'
172.168.2.223 | CHANGED | rc=0 >>
server{
	listen 81
	hostname web1.magedu.com
	root /data/website1
}
server{
	listen 82
	hostname web2.magedu.com
	root /data/website2
}
server{
	listen 83
	hostname web3.magedu.com
	root /data/website3
}

#if statement
[root@salt ~/ansible/templates]# cat ../if.yml 
---
- hosts: node
  remote_user: root
  vars:
    ports:
      - web1:
        port: 81
        #name: web1.magedu.com
        rootdir: /data/website1
      - web2:
        port: 82
        name: web2.magedu.com
        rootdir: /data/website2
      - web3:
        port: 83
        #name: web3.magedu.com
        rootdir: /data/website3

  tasks:
    - name: copy conf
      template: src=if.conf.j2 dest=/usr/local/src/nginx3.conf
[root@salt ~/ansible/templates]# cat if.conf.j2 
{% for p in ports %}
server{
	listen {{ p.port }}
{% if p.name is defined %}
	hostname {{ p.name }}
{% endif %}
	root {{ p.rootdir }}
}
{% endfor %}
[root@salt ~/ansible]# ansible-playbook -C if.yml 
[root@salt ~/ansible]# ansible-playbook if.yml 
[root@salt ~/ansible]# ansible node -m shell -a 'cat /usr/local/src/nginx3.conf'
172.168.2.223 | CHANGED | rc=0 >>
server{
	listen 81
	root /data/website1
}
server{
	listen 82
	hostname web2.magedu.com
	root /data/website2
}
server{
	listen 83
	root /data/website3
}

#roles角色
[root@salt /etc/ansible]# tree roles/
roles/
├── httpd
├── memcached
├── mysql
└── nginx
    ├── tasks
    │   ├── group.yml
    │   ├── main.yml
    │   ├── restart.yml
    │   ├── start.yml
    │   ├── templ.yml
    │   ├── user.yml
    │   └── yum.yml
    └── templates
        └── nginx.conf.j2
[root@salt /etc/ansible]# cat nginx-playbook.yml 
---
- hosts: node
  remote_user: root

  roles:
    - role: nginx
[root@salt /etc/ansible/roles/nginx]# for i in `ls`;do for j in `ls $i`;do echo "--> $i/$j";cat $i/$j ;done ;done
--> tasks/group.yml
- name: create nginx group
  group: name=nginx system=yes gid=8080
--> tasks/main.yml
- include: group.yml
- include: user.yml
- include: yum.yml
- include: templ.yml
- include: start.yml
--> tasks/restart.yml
- name: restart nginx service
  service: name=nginx state=restarted
--> tasks/start.yml
- name: start nginx service
  service: name=nginx state=started enabled=yes
--> tasks/templ.yml
- name: copy template nginx.conf to remote client
  template: src=nginx.conf.j2 dest=/etc/nginx/nginx.conf
--> tasks/user.yml
- name: create nginx user
  user: name=nginx uid=8080 group=nginx system=yes shell=/sbin/nologin
--> tasks/yum.yml
- name: yum install nginx packages
  yum: name=nginx state=present
--> templates/nginx.conf.j2
#user  nobody;
worker_processes  {{ ansible_processor_vcpus }};
[root@salt /etc/ansible]# ansible-playbook -C nginx-playbook.yml
[root@salt /etc/ansible]# ansible-playbook nginx-playbook.yml
[root@salt /etc/ansible]# ansible node -m shell -a 'ss -tnol'
172.168.2.223 | CHANGED | rc=0 >>
State      Recv-Q Send-Q Local Address:Port               Peer Address:Port              
LISTEN     0      128          *:80                       *:*                  
LISTEN     0      128          *:22                       *:*                  
LISTEN     0      128       [::]:9090                  [::]:*                  
LISTEN     0      128       [::]:9100                  [::]:*                  
LISTEN     0      50        [::]:18477                 [::]:*                  
LISTEN     0      50        [::]:8080                  [::]:*                  
LISTEN     0      128       [::]:22                    [::]:*                  
LISTEN     0      128       [::]:3000                  [::]:* 

#跨role角色调用
[root@salt /etc/ansible]# cat nginx-playbook.yml 
---
- hosts: node
  remote_user: root

  roles:
    - role: nginx
[root@salt /etc/ansible]# cat roles/nginx/tasks/main.yml
- include: group.yml
- include: user.yml
- include: yum.yml
- include: templ.yml
- include: start.yml
- include: roles/httpd/tasks/copyfile.yml
[root@salt /etc/ansible]# cat roles/httpd/tasks/copyfile.yml 
- name: copy apache config file
  copy: src=/etc/ansible/roles/httpd/files/httpd.conf dest=/tmp owner=apache

#role角色标签
[root@salt /etc/ansible]# cat httpd-playbook.yml
---
- hosts: node
  remote_user: root
  roles:
    - {role: httpd, tags: ['web','httpd'] }
    - {role: nginx, tags: ['web','nginx'] }
[root@salt /etc/ansible]# ansible-playbook -t nginx httpd-playbook.yml   --挑选剧本角色运行剧本
[root@salt /etc/ansible]# cat some-playbook.yml 
---
- hosts: all
  remote_user: root
  roles:
    - {role: httpd, tags: ['web','httpd'] }
    - {role: nginx, tags: ['web','nginx'], when: ansible_distribution_major_version == '7'}
注：在role中使用when语句
--较完整剧本目录结构
[root@salt /etc/ansible/roles/app]# tree .
.
├── files     --存放文件的地方，可用相对路径引用，不用加files文件夹
├── handlers  --触发器处理的子剧本文件，由notify通知触发，这里必需有main.yml文件
├── tasks     --日常处理的任务子剧本文件，必需有main.yml文件,里面有子剧本引用files和templates文件夹下的子剧本
├── templates --jinja2模板存放的地方，里面引用了变量配置的文件，由tasks里面子剧本引用
└── vars      --存放变量的文件，必需是main.yml，不需要在tasks引用
注：剧本目录结构流程：files,templates,vars,handlers<----tasks




#####其它模块问题解疑：
----本地操作功能-------local_action
Ansible默认只会对控制机器执行操作，但如果在这个过程中需要在Ansible本机执行操作呢？
可以使用delegate_to(任务委派)功能，不过除了任务委派之外，还可以使用local_action关键字
例如：
- name: add hostname resolv to /etc/hosts
  local_action: shell 'echo "192.168.1.1 test.xyz.com" >> /etc/hosts'
或者：
- name: add hostname resolv to /etc/hosts
  shell: 'echo "192.168.1.1 test.xyz.com" >> /etc/hosts'
  connection: local
注：这两个操作结果是一样的

----轮循方式检测服务状态
- name: 以轮询的方式等待服务同步完成
  shell: "systemctl status etcd.service|grep Active"
  register: etcd_status
  until: '"running" in etcd_status.stdout'
  retries: 8
  delay: 8
  tags: upgrade_etcd, restart_etcd
- name: 轮询等待node达到Ready状态
  shell: "{{ bin_dir }}/kubectl get node {{ inventory_hostname }}|awk 'NR>1{print $2}'"
  register: node_status
  until: node_status.stdout == "Ready" or node_status.stdout == "Ready,SchedulingDisabled"
  retries: 8
  delay: 8
  tags: upgrade_k8s, restart_node
  
----roles下文件夹defaults和vars都是定义当前role的变量
root@ansible:/etc/kubeasz# cat roles/etcd/defaults/main.yml
# etcd 集群间通信的IP和端口, 根据etcd组成员自动生成
TMP_NODES: "{% for h in groups['etcd'] %}etcd-{{ h }}=https://{{ h }}:2380,{% endfor %}"
ETCD_NODES: "{{ TMP_NODES.rstrip(',') }}"
# etcd 集群初始状态 new/existing
CLUSTER_STATE: "new"
root@ansible:/etc/kubeasz# cat roles/docker/vars/main.yml
# cgroup driver
CGROUP_DRIVER: "{%- if DOCKER_VER|float >= 20.10 -%} \
                     systemd \
                {%- else -%} \
                     cgroupfs \
                {%- endif -%}"

----只执行一次获取docker版本并注册到变量docker_ver中
# 18.09.x 版本二进制名字有变化，需要做判断
- name: 获取docker版本信息
  shell: "{{ base_dir }}/bin/dockerd --version|cut -d' ' -f3"
  register: docker_ver
  connection: local
  run_once: true
  tags: upgrade_docker, download_docker
- name: debug info		#debug输入变量等于"docker_ver"的信息
  debug: var="docker_ver"
  connection: local
  run_once: true
  tags: upgrade_docker, download_docker
  
----set_fact------设置fact变量，可以跨playbook调用，但是这个值在运行期间有用，运行完成后变量将会销毁，获取变量也都是针对同一台主机
- name: 转换docker版本信息为浮点数
  set_fact:
    DOCKER_VER: "{{ docker_ver.stdout.split('.')[0]|int + docker_ver.stdout.split('.')[1]|int/100 }}"
  connection: local
  run_once: true
  tags: upgrade_docker, download_docker

----block块，可以当when满足时，执行block中的多个task，否则不执行block中的多个task
- block:
    - name: 准备docker相关目录
      file: name={{ item }} state=directory
      with_items:
      - "{{ bin_dir }}"
      - "/etc/docker"
      - "/etc/bash_completion.d"

----通过inport_tasks导入task,使用include也行
#----------- 创建配置文件: /root/.kube/config
- import_tasks: create-kubectl-kubeconfig.yml
  tags: create_kctl_cfg

----注册变量，只运行一次，如果注册变量是notfound则会进行创建kubernetes-crb集群角色绑定
- name: 获取user:kubernetes是否已经绑定对应角色
  shell: "{{ bin_dir }}/kubectl get clusterrolebindings|grep kubernetes-crb || echo 'notfound'"
  register: crb_info
  run_once: true
- name: 创建user:kubernetes角色绑定
  command: "{{ bin_dir }}/kubectl create clusterrolebinding kubernetes-crb --clusterrole=cluster-admin --user=kubernetes"
  run_once: true
  when: "'notfound' in crb_info.stdout"

----设置变量到fact
- name: 注册变量 DNS_SVC_IP
  shell: echo {{ SERVICE_CIDR }}|cut -d/ -f1|awk -F. '{print $1"."$2"."$3"."$4+2}'
  register: DNS_SVC_IP
- name: 设置变量 CLUSTER_DNS_SVC_IP
  set_fact: CLUSTER_DNS_SVC_IP={{ DNS_SVC_IP.stdout }}


----playbook再次确认node不在master组时再部署
root@ansible:/etc/kubeasz# cat playbooks/05.kube-node.yml
# to set up 'kube_node' nodes
- hosts: kube_node
  roles:
  - { role: kube-lb, when: "inventory_hostname not in groups['kube_master']" }
  - { role: kube-node, when: "inventory_hostname not in groups['kube_master']" }


----calico ansible部分
    - name: 尝试推送离线docker 镜像（若执行失败，可忽略）
      copy: src={{ base_dir }}/down/{{ item }} dest=/opt/kube/images/{{ item }}
      when: 'item in download_info.stdout'
      with_items:
      - "pause.tar"
      - "{{ calico_offline }}"
      ignore_errors: true
# 等待网络插件部署成功，视下载镜像速度而定
- name: 轮询等待calico-node 运行，视下载镜像速度而定
  shell: "{{ bin_dir }}/kubectl get pod -n kube-system -o wide|grep 'calico-node'|grep ' {{ inventory_hostname }} '|awk '{print $3}'"
  register: pod_status
  until: pod_status.stdout == "Running"
  retries: 15
  delay: 15
  ignore_errors: true



### shell模块
[root@prometheus ~]# ansible '~192.168.13.23[789]' -m shell -a "docker ps -a | awk '{print \$2}'"  #遇到特殊符号需要加入\转义，这样子ansible才能正常运行
192.168.13.238 | CHANGED | rc=0 >>
ID
192.168.13.235:8000/pro/receiptclaim.service.hs.com:v20221108153418
192.168.13.235:8000/pro/flightrefund.hs.com:v20221107115009




</pre>
