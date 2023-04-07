#maven
<pre>
安装：
wget http://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz
tar xf apache-maven-3.3.9-bin.tar.gz -C /usr/local
ln -sv /usr/localapache-maven-3.3.9 /usr/local/maven
[root@BuildImage ~]# cat /etc/profile.d/maven.sh
export PATH=$PATH:/usr/local/maven/bin/
source /etc/profile

#nexus私服介绍
这里有很多仓库，简单介绍下
central--中央仓库，默认从https://repo1.maven.org/maven2/拉取jar。类型：proxy
releases --自定义的jar存储的仓库。类型：hosted
snapshots-- 私库快照（调试版本）jar。类型：hosted
public：仓库分组，把上面三个仓库组合在一起对外提供服务，在本地maven基础配置settings.xml中使用。类型：group
--类型
Nexus的仓库分为这么几类：
hosted 宿主仓库：主要用于部署无法从公共仓库获取的构件（如 oracle 的 JDBC 驱动）以及自己或第三方的项目构件；
proxy 代理仓库：代理公共的远程仓库；
virtual 虚拟仓库：用于适配 Maven 1；
group 仓库组：Nexus 通过仓库组的概念统一管理多个仓库，这样我们在项目中直接请求仓库组即可请求到仓库组管理的多个仓库。

#nexus安装 
docker run -d -p 8010:8081 --name nexus-dotnet -v /data/nexus3:/nexus-data sonatype/nexus3:3.32.0

#neuxs备份恢复
--备份
只需要备份nexus-data目录即可。
--恢复
chmod -R 777 /data/nexus-data
docker run -d -p 8010:8081 --name nexus-dotnet -v /data/nexus-data:/nexus-data sonatype/nexus3:3.32.0


#增加maven仓库
现在默认是从中央仓库拉取jar,我们把他改为aliyun的，岂不是更快。
增加一个maven仓库：maven-proxy,URL指向阿里云地址：http://maven.aliyun.com/nexus/content/groups/public
#调整maven仓库优先级
点击maven-public 往下拉--把新建的maven-proxy仓库添加到maven-public中,并把maven-public移到最上，越上面优先级越高，当资源包被第一个仓库匹配到好就不会再去找第二个仓库了。
我们当前仓库有三个：maven-proxy,maven-releases,maven-snapshots,将这三个仓库加入到maven-public组中即可。
#添加用户组
在Nexus 中创建一个javaRole的角色,拥有的权利为【nx-repository-view-maven2-*-edit】和【nx-repository-view-maven2-*-add】权利，如果该角色将来可能还有nuget,npm相关上传权利，则将其权利改为【nx-repository-view-*-*-edit】和【nx-repository-view-*-*-add】权利。
#添加用户
创建用户java，java用户拥有的角色为【nx-anonymous】和刚创建的【javaRole】角色。其中nx-anonymous角色是nexus默认自带的角色


#maven settings配置文件更改：
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

#下载缓存基础包
[root@BuildImage ~]# mvn help:system

#命令行上传包命令
在maven工程项目nexus-upload中的pom文件中加入
----------------
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
----------------


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


</pre>

<pre>
#nuget推送包到nexus
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



#npm配置:
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
#npm编译安装
npm install
npm run build
#npm重新编译
rm -rf node_modules/
npm cache clean -f
npm install
npm run build
#npm缓存验证
npm cache verify



##confluence备份
1. 进行站点管理后台 -> 找到每日备份管理，配置保存路径、保存名称前缀 -> 保存
2. 找到预定作业 -> 找到备份系统 -> 编辑配置备份运行时间（如每隔3天运行一次，运行时间为凌晨2点） -> 0 0 18 1/3 * ? (秒分时日月周年)
3. 在备份系统中点运行进行测试即可。

</pre>