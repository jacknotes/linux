# 部署预生产环境

服务器：
* DNS服务器			1台			IP: 192.168.13.199
* nginx				1台			IP: 192.168.13.208
* webserver集群		3台			IP: 192.168.13.203,192.168.13.227,192.168.13.231
* k8s集群			3台			IP: 192.168.13.90,192.168.13.91,192.168.13.92



## 安装部署DNS

### 安装DNS服务
1. 安装Windows Server 2008R2系统，并安装DNS角色。
2. 配置DNS服务器网络信息，DNS地址指向本机：127.0.0.1

### 备份DNS配置
```powershell
<#
前提：
  1.该脚本需要模块DnsServer
  2.执行脚本的主机与DNS服务器保持网络连接
  3.执行脚本的用户需要在远程DNS服务器上有相应权限
使用方式：
  利用任务计划程序来调用脚本，参数：-File <脚本文件路径> -ComputerName <远程DNS服务器FQDN> -ErrorAction SilentlyContinue
结果：
  1.脚本执行后，会在远程DNS服务器上的DNS目录（默认为：c:\windows\system32\dns）生成DNS区域的备份文件（AD类型）
  2.每天每个区域只能有一个文件，之后的同名文件会创建失败
恢复DNS区域：
  1.将备份文件复制到DNS服务器上的DNS目录（默认为：c:\windows\system32\dns）
  2.执行命令：dnscmd <远程DNS服务器FQDN> /ZoneAdd <ZoneName> /Primary /file <备份的区域文件名> /load
  3.打开DNS服务器管理器，将相应区域的类型更改为：Active Directory 集成区域，动态类型更改为：安全
  4.如果是非域环境，第3步可不做
#>

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True,Position=1)]
    [string]$ComputerName
)

$Prefix = "Dns - " + (Get-Date -Format "yyyyMMdd") + " - " 
$Suffix = ".bak"
#$Zones = Get-DnsServerZone -ComputerName $ComputerName
$Zones = (Get-WmiObject -Namespace root\MicrosoftDNS -Class MicrosoftDNS_Zone -ComputerName $ComputerName).Name

foreach($zone in $Zones){
    #$zonename = $zone.ZoneName
    $zonename = $zone
    if ($zonename -eq "TrustAnchors"){
        #$zonename = "_msdcs.hs.com"
    }
    $filename = $Prefix + $zonename + $Suffix
    #Export-DnsServerZone -FileName $filename -Name $zonename -ComputerName $ComputerName
    dnscmd $ComputerName /ZoneExport $zonename $filename
}
```


### 恢复DNS配置
1. 复制备份的DNS到本机存放
2. 更改需要恢复的DNS配置文件，使用notepad++软件打开，批量替换192.168.13.207为192.168.13.208
3. 使用Powershell进行恢复到本机DNS

```Powershell
# ad域对象需要使用_msdcs.hs.com下的dc/domains/gc/pdc下面的域解析，否则指向新的DNS无法登录域
dnscmd srv-pre-dns /zoneadd _msdcs.hs.com /primary /file "Dns - 20230515 - _msdcs.hs.com.bak" /load
  
# 恢复步骤：可以用notepad++打开"Dns - 20230515 - hs.com.bak"，把192.168.13.207批量替换为192.168.13.208
dnscmd srv-pre-dns /zoneadd hs.com /primary /file "Dns - 20230515 - hs.com.bak" /load
```

### 测试DNS服务器
1. 使用ping命令进行测试解析
2. 部署新的win10操作系统，DNS指向DNS地址：192.168.13.199，进行加域测试、域名解析测试。




## 安装部署nginx
1. 初始化Centos7系统环境，/etc/resolv.conf中DNS地址为预生产环境DNS: 192.168.13.199
2. 安装tengine，跟生产环境nginx配置一样
3. 复制生产环境nginx.conf以及其它*.conf配置文件到此nginx配置目录下，并将upstream server中的webserver集群地址替换为IP: 192.168.13.203,192.168.13.227,192.168.13.231、k8s集群地址替换为192.168.13.90,192.168.13.91,192.168.13.92
4. 重载nginx服务



## 安装部署WebServer集群

### 192.168.13.203 WebServer部署
1. 备份192.168.13.204Webserver IIS配置
2. 安装 192.168.13.203操作系统，为Windows Server 2008R2 Enterprise
3. 安装IIS角色
4. 安装.NetFramwork 4.6.1 
5. 恢复IIS配置
6. 复制192.168.13.204站点目录数据到192.168.13.203
7. 配置站点目录权限等其它权限
8. 测试IIS服务是否跟192.168.13.204一样，一定要保持一致
9. 此服务器不可以克隆，经过测试会有问题
注：备份恢复步骤详见githbu.com/jacknotes/windows/notebook/IISBackupRestore.md


### 192.168.13.227 WebServer部署

方法1：
1. 克隆192.168.13.228
2. 执行以下命令更新UUID
C:\Windows\System32\Sysprep 
Sysprep /generalize /oobe /shutdown
3. 测试IIS服务是否跟192.168.13.228一样，一定要保持一致
4. 此服务器可以克隆，经过测试无问题

方法2：
1. 备份192.168.13.228 Webserver IIS配置
2. 安装 192.168.13.227操作系统，为Windows Server 2012R2 Datacenter
3. 安装IIS角色
4. 安装IIS URL重写模块
5. 恢复IIS配置
6. 复制192.168.13.228站点目录数据到192.168.13.227
7. 配置站点目录权限等其它权限
8. 测试IIS服务是否跟192.168.13.228一样，一定要保持一致
注：备份恢复步骤详见githbu.com/jacknotes/windows/notebook/IISBackupRestore.md


### 192.168.13.231 WebServer部署

方法1：
1. 克隆192.168.13.232
2. 执行以下命令更新UUID
C:\Windows\System32\Sysprep 
Sysprep /generalize /oobe /shutdown
3. 测试IIS服务是否跟192.168.13.232一样，一定要保持一致
4. 此服务器可以克隆，经过测试无问题

方法2：
1. 备份192.168.13.232Webserver IIS配置
2. 安装 192.168.13.231操作系统，为Windows Server 2008R2 Enterprise
3. 安装IIS角色
4. 安装.NetFramwork 4.6.1 
5. 恢复IIS配置
6. 复制192.168.13.232站点目录数据到192.168.13.231
7. 配置站点目录权限等其它权限
8. 测试IIS服务是否跟192.168.13.232一样，一定要保持一致
注：备份恢复步骤详见githbu.com/jacknotes/windows/notebook/IISBackupRestore.md



## 安装部署k8s集群

### 安装操作系统
1. master和node节点的操作系统为18.04.5
2. 配置网络信息和主机名等信息
3. 被ansible管理
4. 使用ansible初始化系统配置
5. 更新ubuntu操作系统
6. 将网卡名称由"ens开头"更改为"eth开头"格式


### 安装部署pre-pro-k8s-master01






