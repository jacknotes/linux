
# nexus私服



## 介绍

Nexus是一个强大的Maven仓库管理器，它极大地简化了自己内部仓库的维护和外部仓库的访问。 利用Nexus你可以只在一个地方就能够完全控制访问和部署在你所维护仓库中的每个Artifact。 Nexus是一套“开箱即用”的系统不需要数据库，它使用文件系统加Lucene来组织数据。



**这里有很多仓库，简单介绍下**
central: 中央仓库，默认从https://repo1.maven.org/maven2/拉取jar。类型：proxy
releases: 自定义的jar存储的仓库。类型：hosted
snapshots: 私库快照（调试版本）jar。类型：hosted
public: 仓库分组，把上面三个仓库组合在一起对外提供服务，在本地maven基础配置settings.xml中使用。类型：group



**类型**
Nexus的仓库分为这么几类：
hosted 宿主仓库：主要用于部署无法从公共仓库获取的构件（如 oracle 的 JDBC 驱动）以及自己或第三方的项目构件；
proxy 代理仓库：代理公共的远程仓库；
virtual 虚拟仓库：用于适配 Maven 1；
group 仓库组：Nexus 通过仓库组的概念统一管理多个仓库，这样我们在项目中直接请求仓库组即可请求到仓库组管理的多个仓库。



## 安装 
docker run -d -p 8010:8081 --name nexus-dotnet -v /data/nexus3:/nexus-data sonatype/nexus3:3.32.0



## 备份恢复



### 备份

只需要备份nexus-data目录即可。



### 恢复

```bash
#chmod -R 770 /data/nexus-data && chown -R root.200 /data/nexus-data
chmod -R 777 /data/nexus-data
docker run -d -p 8010:8081 --name nexus-dotnet -v /data/nexus-data:/nexus-data sonatype/nexus3:3.32.0
```





# maven



## 安装

```bash
wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar xf apache-maven-3.3.9-bin.tar.gz -C /usr/local
ln -sv /usr/localapache-maven-3.3.9 /usr/local/maven

cat /etc/profile.d/maven.sh
	export PATH=$PATH:/usr/local/maven/bin/
source /etc/profile
```



## 配置maven仓库

现在默认是从中央仓库拉取jar，我们把他改为aliyun的，增加一个maven仓库：maven-proxy，URL指向阿里云地址：http://maven.aliyun.com/nexus/content/groups/public



**调整maven仓库优先级**

1. 点击maven-public 往下拉--把新建的maven-proxy仓库添加到maven-public中,并把maven-public移到最上，越上面优先级越高，当资源包被第一个仓库匹配到好就不会再去找第二个仓库了。
2. 我们当前仓库有三个：maven-proxy,maven-releases,maven-snapshots,将这三个仓库加入到maven-public组中即可。



**添加用户组**

在Nexus 中创建一个javaRole的角色,拥有的权利为【nx-repository-view-maven2-*-edit】和【nx-repository-view-maven2-*-add】权利，如果该角色将来可能还有nuget,npm相关上传权利，则将其权利改为【nx-repository-view-*-*-edit】和【nx-repository-view-*-*-add】权利。



**添加用户**
创建用户java，java用户拥有的角色为【nx-anonymous】和刚创建的【javaRole】角色。其中nx-anonymous角色是nexus默认自带的角色



**maven settings配置文件**

```xml
<!-- 配置本地仓库目录 -->
 	<localRepository>/data/mavenrepo</localRepository>
<!-- 配置nexus指定仓库ID访问帐号和密码，用于命令行上传jar包，也可以使用nexus界面进行上传 -->
    <server>
      <id>maven-releases</id>
      <username>java</username>
      <password>homsom</password>
    </server>

    <server>
      <id>maven-snapshots</id>
      <username>java</username>
      <password>homsom</password>
    </server>
<!-- 配置镜像仓库，为自己部署的私服 -->
    <mirror>
      <id>mirrorHomsom</id>
      <mirrorOf>*</mirrorOf>
      <name>NexusHomsom</name>
      <url>http://nexus.hs.com/repository/maven-public/</url>
    </mirror>
<!-- 添加私服，包括仓库信息、插件仓库信息 -->
    <profile>
      <id>mirrorHomsom</id>
      <repositories>
        <repository>
          	<id>mirrorHomsom</id>
          	<name>mirrorHomsom</name>
         	<url>http://nexus.hs.com/repository/maven-public/</url>
	 	<releases>
	  		<enabled>true</enabled>
	  	</releases>
	 	<snapshots>
			<enabled>true</enabled>
          	</snapshots>
          	<layout>default</layout>
          	<snapshotPolicy>always</snapshotPolicy>
        </repository>
      </repositories>

	  <pluginRepositories>
		<pluginRepository>
		<id>mirrorHomsom</id>
		<name>mirrorHomsom</name>
		<url>http://nexus.hs.com/repository/maven-public/</url>
		<releases>
			<enabled>true</enabled>
		</releases>
		<snapshots>
			<enabled>true</enabled>
		</snapshots>
		</pluginRepository>
	  </pluginRepositories>
    </profile>
<!-- 开启私服，为上面的mirrorHomsom -->
  <activeProfiles>
    <activeProfile>mirrorHomsom</activeProfile>
  </activeProfiles>
```



**下载缓存基础包**

mvn help:system



**命令行上传包命令**

在maven工程项目nexus-upload中的pom文件中加入

```xml
<project>
 <repository>
     <!--这里的id需要和settings.xml中的server的id一致-->
     <id>maven-releases</id>
     <name>Nexus release Repository</name>
     <!--releases仓库-->
     <url>http://nexus.hs.com/repository/maven-releases/</url>
 </repository>
 <snapshotRepository>
     <id>maven-snapshots</id>
     <name>Nexus snapshots Repository</name>
     <!--snapshots仓库-->
     <url>http://nexus.hs.com/repository/maven-snapshots/</url>
 </snapshotRepository>
</distributionManagement>

</project>
```



**上传maven包到nexus私服**

```bash
mvn deploy:deploy-file \
-DgroupId=com.homsom \
-DartifactId=user-approve \
-Dversion=0.0.1 \
-Dpackaging=jar \
-Dfile=user-approve-0.0.1-SNAPSHOT.jar \
-Durl=http://nexus.hs.com/repository/maven-releases \
-DrepositoryId=maven-releases

注：
groupId：目录
artifactId：文件
version：版本
packaging：包类型
repositoryId：为之前server节点中的属性id的值,--settings指定maven的setting文件
url：nexus仓库的地址
例如：http://nexus.hs.com/repository/maven-public/com/zzuhai/approve/0.0.1/approve-0.0.1.jar
```



# nuget



## nuget推送包到nexus

```cmd
E:\tmp\nuget>nuget.exe push *.nupkg -source http://nugetv3.hs.com/repository/nuget-hosted/
警告: No API Key was provided and no API Key could be found for 'http://nugetv3.hs.com/repository/nuget-hosted/'. To save an API Key for a source use the 'setApiKey' command.
Pushing polly.7.1.1.nupkg to 'http://nugetv3.hs.com/repository/nuget-hosted/'...
  PUT http://nugetv3.hs.com/repository/nuget-hosted/
请提供以下人员的凭据: http://nugetv3.hs.com/repository/nuget-hosted/
用户名: 0799
密码: **********
  Created http://nugetv3.hs.com/repository/nuget-hosted/ 7706ms
Your package was pushed.
Pushing polly.7.2.0.nupkg to 'http://nugetv3.hs.com/repository/nuget-hosted/'...
  PUT http://nugetv3.hs.com/repository/nuget-hosted/
  Created http://nugetv3.hs.com/repository/nuget-hosted/ 256ms
Your package was pushed.
```



## npm配置

```bash
npm config list
npm config ls -l   --查看详细设置

[root@tengine /tmp/node/Homsom.Tool.RegionalSource.Client]# npm config get registry
https://registry.npmjs.org/
[root@tengine /tmp/node/Homsom.Tool.RegionalSource.Client]# npm config set registry https://registry.npm.taobao.org
[root@tengine /tmp/node/Homsom.Tool.RegionalSource.Client]# npm config get registry
https://registry.npm.taobao.org/

npm config set proxy="http://192.168.111.111:1111"   --设置网络代理用于快速连接国外网站
npm config delete proxy
npm config delete registry 
npm config set registry http://nugetv3.hs.com/repository/npm-proxy/    --设置nuget代理
npm update   --用新源更新一波package
vim /root/.npmrc   --可手工删除配置的信息
```



## npm编译安装

```bash
# npm编译安装
npm install
npm run build

# npm重新编译 
rm -rf node_modules/ package-lock.json
npm cache clean -f			# 清除/root/.npm
npm install
npm run build

# npm缓存验证
npm cache verify			# 查看缓存大小
```



# confluence备份

1. 进行站点管理后台 -> 找到每日备份管理，配置保存路径、保存名称前缀 -> 保存
2. 找到预定作业 -> 找到备份系统 -> 编辑配置备份运行时间（如每隔3天运行一次，运行时间为凌晨2点） -> 0 0 18 1/3 * ? (秒分时日月周年)
3. 在备份系统中点运行进行测试即可。



# nexus配置python PYPI代理



## 增加pypi(proxy)仓库

```
1. 配置仓库名称，例如pypi-proxy-aliyun
2. 配置远程仓库：https://mirrors.aliyun.com/pypi 
3. 得到代理倒库地址http://192.168.222.4/repository/pypi-aliyun/

# django==为未指定版本，此命令会输出django所有版本, -i为指定索引地址、这里要加simple子路径，上面第2步不能加simple子路径
4. 测试代理地址：pip3 install -i http://192.168.222.4/repository/pypi-aliyun/simple django== 
WARNING: Running pip install with root privileges is generally not a good idea. Try `pip3 install --user` instead.
Collecting django==
  Could not find a version that satisfies the requirement django== (from versions: 1.1.3, 1.1.4, 1.2, 1.2.1, 1.2.2, 1.2.3, 1.2.4, 1.2.5, 1.2.6, 1.2
.7, 1.3, 1.3.1, 1.3.2, 1.3.3, 1.3.4, 1.3.5, 1.3.6, 1.3.7, 1.4, 1.4.1, 1.4.2, 1.4.3, 1.4.4, 1.4.5, 1.4.6, 1.4.7, 1.4.8, 1.4.9, 1.4.10, 1.4.11, 1.4.1
2, 1.4.13, 1.4.14, 1.4.15, 1.4.16, 1.4.17, 1.4.18, 1.4.19, 1.4.20, 1.4.21, 1.4.22, 1.5, 1.5.1, 1.5.2, 1.5.3, 1.5.4, 1.5.5, 1.5.6, 1.5.7, 1.5.8, 1.5
.9, 1.5.10, 1.5.11, 1.5.12, 1.6, 1.6.1, 1.6.2, 1.6.3, 1.6.4, 1.6.5, 1.6.6, 1.6.7, 1.6.8, 1.6.9, 1.6.10, 1.6.11, 1.7, 1.7.1, 1.7.2, 1.7.3, 1.7.4, 1.
7.5, 1.7.6, 1.7.7, 1.7.8, 1.7.9, 1.7.10, 1.7.11, 1.8a1, 1.8b1, 1.8b2, 1.8rc1, 1.8, 1.8.1, 1.8.2, 1.8.3, 1.8.4, 1.8.5, 1.8.6, 1.8.7, 1.8.8, 1.8.9, 1
.8.10, 1.8.11, 1.8.12, 1.8.13, 1.8.14, 1.8.15, 1.8.16, 1.8.17, 1.8.18, 1.8.19, 1.9a1, 1.9b1, 1.9rc1, 1.9rc2, 1.9, 1.9.1, 1.9.2, 1.9.3, 1.9.4, 1.9.5
, 1.9.6, 1.9.7, 1.9.8, 1.9.9, 1.9.10, 1.9.11, 1.9.12, 1.9.13, 1.10a1, 1.10b1, 1.10rc1, 1.10, 1.10.1, 1.10.2, 1.10.3, 1.10.4, 1.10.5, 1.10.6, 1.10.7
, 1.10.8, 1.11a1, 1.11b1, 1.11rc1, 1.11, 1.11.1, 1.11.2, 1.11.3, 1.11.4, 1.11.5, 1.11.6, 1.11.7, 1.11.8, 1.11.9, 1.11.10, 1.11.11, 1.11.12, 1.11.13
, 1.11.14, 1.11.15, 1.11.16, 1.11.17, 1.11.18, 1.11.20, 1.11.21, 1.11.22, 1.11.23, 1.11.24, 1.11.25, 1.11.26, 1.11.27, 1.11.28, 1.11.29, 2.0a1, 2.0
b1, 2.0rc1, 2.0, 2.0.1, 2.0.2, 2.0.3, 2.0.4, 2.0.5, 2.0.6, 2.0.7, 2.0.8, 2.0.9, 2.0.10, 2.0.12, 2.0.13, 2.1a1, 2.1b1, 2.1rc1, 2.1, 2.1.1, 2.1.2, 2.
1.3, 2.1.4, 2.1.5, 2.1.7, 2.1.8, 2.1.9, 2.1.10, 2.1.11, 2.1.12, 2.1.13, 2.1.14, 2.1.15, 2.2a1, 2.2b1, 2.2rc1, 2.2, 2.2.1, 2.2.2, 2.2.3, 2.2.4, 2.2.
5, 2.2.6, 2.2.7, 2.2.8, 2.2.9, 2.2.10, 2.2.11, 2.2.12, 2.2.13, 2.2.14, 2.2.15, 2.2.16, 2.2.17, 2.2.18, 2.2.19, 2.2.20, 2.2.21, 2.2.22, 2.2.23, 2.2.
24, 2.2.25, 2.2.26, 2.2.27, 2.2.28, 3.0a1, 3.0b1, 3.0rc1, 3.0, 3.0.1, 3.0.2, 3.0.3, 3.0.4, 3.0.5, 3.0.6, 3.0.7, 3.0.8, 3.0.9, 3.0.10, 3.0.11, 3.0.1
2, 3.0.13, 3.0.14, 3.1a1, 3.1b1, 3.1rc1, 3.1, 3.1.1, 3.1.2, 3.1.3, 3.1.4, 3.1.5, 3.1.6, 3.1.7, 3.1.8, 3.1.9, 3.1.10, 3.1.11, 3.1.12, 3.1.13, 3.1.14
, 3.2a1, 3.2b1, 3.2rc1, 3.2, 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.5, 3.2.6, 3.2.7, 3.2.8, 3.2.9, 3.2.10, 3.2.11, 3.2.12, 3.2.13, 3.2.14, 3.2.15, 3.2.16,
 3.2.17, 3.2.18)
No matching distribution found for django==

5. 配置源为全局默认配置
[root@controller ~]# cat .pip/pip.conf 
[global]
timeout = 60000
index-url = http://192.168.222.4/repository/pypi-aliyun/simple/
trusted-host = 192.168.222.4

6. 安装指定django版本包，这里只是在处理问题过程中的测试，**不能以此种方式来使python2.7支持Django**
[root@controller ~]# pip2 install django==1.8.18
```





# nexus docker私有仓库



## 1. 运行

```bash
#!/bin/bash

# root@repo:/data# ll | grep nexus
# drwxrwx---  15 root        200  254 Jun 11 11:39 nexus-repo/
# drwxrwx---   4 root        200  209 Jun 11 11:33 nexus-repo-data/

docker run --name=nexus-repo --volume=/data/nexus-repo:/nexus-data --volume=/data/nexus-repo-data:/nexus-repo-data -p 8081-8088:8081-8088 --restart=always --log-opt max-file=3 --log-opt max-size=500m --detach=true sonatype/nexus3:3.60.0

root@repo:/data# docker ps -a 
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                              NAMES
1f8824241dc6   sonatype/nexus3:3.60.0   "/opt/sonatype/nexus…"   3 minutes ago   Up 3 minutes   0.0.0.0:8081-8088->8081-8088/tcp   nexus-repo

# 8081为nexus的Web访问端口
root@repo:/data# ss -tnl | grep 808
LISTEN   0         128                 0.0.0.0:8081             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8082             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8083             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8084             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8085             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8086             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8087             0.0.0.0:*       
LISTEN   0         128                 0.0.0.0:8088             0.0.0.0:*       
```



## 2. 配置docker代理仓库

- 创建自定义blog存储
- 创建repositories -> docker(proxy) 
- 创建repositories -> docker(hosted) ，并暴露http端口，这里为8083，忽略url的地址
- 创建repositories -> docker(group) ，并暴露http端口，这里为8082，忽略url的地址，并加入docker(proxy) 、docker(hosted) 
- 配置权限，Realms -> ”Docker Bearer Token Realm“ -> 激活





## 3. 客户端配置

用户配置docker镜像仓库为http://192.168.13.202:8082，并在insecure-registries里面配置这个地址

```bash
# 配置"insecure-registries"，"registry-mirrors"
root@ansible:~# cat /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=cgroupfs"],
  "registry-mirrors": [
    "http://192.168.13.202:8082"
  ],
  "insecure-registries": ["127.0.0.1/8","192.168.13.235:8000","192.168.13.197:8000","harbor.hs.com","harborrepo.hs.com","192.168.13.202:8082"],
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
    },
  "data-root": "/var/lib/docker"
}

root@ansible:~# docker info | grep -A 10 'Insecure Registries'
WARNING: No swap limit support
 Insecure Registries:
  192.168.13.235:8000
  harbor.hs.com
  harborrepo.hs.com
  192.168.13.197:8000
  192.168.13.202:8082
  127.0.0.0/8
 Registry Mirrors:
  http://192.168.13.202:8082/
 Live Restore Enabled: false
 Product License: Community Engine


root@ansible:~# docker login http://192.168.13.202:8082 -u ops
Password:
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

```

