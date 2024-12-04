# command 
<pre>
curl命令详解：
###curl参数值：
-x:指定代理
-T:通过ftp上传文件
-w:测试网页返回值 %{http_code}
-c:保存http的response里面的cookie信息
-D:保存http的response里面的header信息
-b:使用cookie
-A:可以让我们指定浏览器去访问网站
-e:以让我们设定referer（盗链）
-o:抓取文件并重命名
-O:下载文件以远程名字命名
-C:断点续传
-r:分段下载
-#:显示进度条
-s:静默，不显示进度条
-k:指定配置文件
-H:指定标头数据
-d:指定http数据
-i:输出时包括protocol头信息
curl示例：
1.抓取页面内容到一个文件中：
curl -o home.html http://192.168.1.31:9200
下载文件：
curl -O http://192.168.1.31/target.tar.gz
2.指定proxy服务器以及其端口：【当我们经常用curl去搞人家东西的时候，人家会把你的IP给屏蔽掉的,这个时候,我们可以用代理】
curl -x 10.10.90.83:80 -o home.html http://www.sina.com.cn
3.断点续传：
curl -C -O http://www.sina.com.cn
注：-C为启用断点续传
4.不显示下载进度信息 -s
curl -s -o aaa.jpg http://www.github.com
5.通过ftp下载文件
curl -u username:password -O ftp://192.168.1.19/store.tar.gz
curl -O ftp://username:password@192.168.1.19/store.tar.gz
6.通过ftp上传
curl -T ks-pre.log ftp://username:password@192.168.1.1
curl -T ks-pre.log -u username:password ftp://192.168.1.19
7.GET：
curl http://www.yahoo.com/login.cgi?user=nickname&password=12345
8.POST:
$curl -d "user=nickname&password=12345" http://www.yahoo.com/login.cgi
9.POST文件：
$curl -F upload= $localfile  -F $btn_name=$btn_value http://mydomain.net/~zzh/up_file.cgi
10.测试网页返回值：【在脚本中，这是很常见的测试网站是否正常的用法】
curl -o /dev/null -s -w %{http_code} 192.168.1/users/sign_in
11.保存http的response里面的header信息：
curl -D cookied.txt https://www.linux.com
12.保存http的response里面的cookie信息:
curl -c cookiec.txt https://www.linux.com
13.使用cookie：
curl -b cookiec.txt https://www.linux.com
注意：-c(小写)产生的cookie和-D里面的cookie是不一样的。
14.模仿浏览器:【有些网站需要使用特定的浏览器去访问他们，有些还需要使用某些特定的版本。curl内置option:-A可以让我们指定浏览器去访问网站】
curl -A "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.0)" https://www.linux.com
注：这样服务器端就会认为是使用IE8.0去访问的
15.伪造referer（盗链）：【比如：你是先访问首页，然后再访问首页中的邮箱页面，这里访问邮箱的referer地址就是访问首页成功后的页面地址，如果服务器发现对邮箱页面访问的referer地址不是首页的地址，就断定那是个盗连了】
curl -e "www.linux.com" http://mail.linux.com
注：-e可以让我们设定referer
16.循环下载：【有时候下载图片可能是前面的部分名称是一样的，就最后的尾椎名不一样】
curl -O http://www.linux.com/dodo[1-5].JPG
17.分块下载：【有时候下载的东西会比较大，这个时候我们可以分段下载，使用内置option：-r】
curl -r 0-100 -o dodo1_part1.JPG http://www.linux.com/dodo1.JPG
curl -r 100-200 -o dodo1_part2.JPG http://www.linux.com/dodo1.JPG
curl -r 200- -o dodo1_part3.JPG http://www.linux.com/dodo1.JPG
cat dodo1_part* > dodo1.JPG
这样就可以查看dodo1.JPG的内容了
18.显示下载进度条#：
curl -# -O http://www.linux.com/dodo1.JPG


gpg命令详解：
#生成key，注：最后要你设置一个私钥密码。这个解密的时候很重要
gpg --gen-key 
#列出key
[root@clusterFS-node4-salt ~]# gpg --list-keys
/root/.gnupg/pubring.gpg
------------------------
pub   2048R/36ED2B33 2019-02-28
uid                  jackli (jackli) <595872348@qq.com>
sub   2048R/F2D4CDE8 2019-02-28
#导出公钥
gpg -a -o ./tt.key --export jackli
#导入新建的公钥文件
gpg --import pub.key  
#以指定公钥加密文件，生成加密的文件是.asc结尾
gpg -a -r 36ED2B33 --encrypt  test.txt 
#解密文件需要输入私钥密码，将密码的文件输出到tmp.txt中
gpg --decrypt -a -o tmp.txt test.txt.asc  

###mysql
MySQL授权命令grant的使用方法
grant 普通 DBA 管理某个 MySQL 数据库的权限。
grant all privileges on testdb to dba@'localhost'
其中，关键字 “privileges” 可以省略。

grant 高级 DBA 管理 MySQL 中所有数据库的权限。
grant all on *.* to dba@'localhost'

grant 作用在表中的列上
grant select(id, se, rank) on testdb.apache_log to dba@localhost;

查看 MySQL 用户权限：
查看当前用户（自己）权限：
show grants;
查看其他 MySQL 用户权限：
show grants for dba@localhost;

撤销已经赋予给 MySQL 用户权限的权限：
revoke 跟 grant 的语法差不多，只需要把关键字 “to” 换成 “from” 即可：
grant all on *.* to dba@localhost;
revoke all on *.* from dba@localhost;

MySQL grant、revoke 用户权限注意事项：
1. grant, revoke 用户权限后，该用户只有重新连接 MySQL 数据库，权限才能生效。
2. 如果想让授权的用户也可以将这些权限 grant 给其他用户，需要选项 “grant option“
grant select on testdb.* to dba@localhost with grant option;
这个特性一般用不到。实际中，数据库权限最好由 DBA 来统一管理。

linux：
安装mysql yum 源最新到80版本：
rpm -Uvh mysql80-community-release-el6-n.noarch.rpm
禁用mysql80:
sudo yum-config-manager --disable mysql80-community
启用mysql57:
sudo yum-config-manager --enable mysql57-community

Linux下MySQL的数据文件存放位置：
 show variables like '%dir%';

#jobs:
jobs -l 
jobs -kill -9 %id
bg %1
fg %1

#nohup:
nohup curl -T ec_new.tar.gz ftp://jackli:jackli123@180.168.251.179:8021/ >tmp.log 2>&1 

#zip:
压缩：
zip -r zip.name target/*
解压：
unzip -o passwd.linux.zip -d ./passwd.linux.tmp #-d是输出到哪个目录


#rsync
-a 归档递归方式传输（相当于rtopgDl）
-v 显示详细模式
-z传输时进行压缩（如同传输图片时进行压缩大小提高传输速度）
-P显示传输进度信息
--exclude传输时排除指定的文件或目录
远程备份命令：
rsync -avzP -e "ssh -p 22" 192.168.1.37:/etc/hostname /tmp/hostname1
#Linux系统rsync实战操作:
备份服务器（master-nginx）：
-------------------
[root@master-nginx tmp]# egrep -v "#|^$" /etc/rsyncd.conf
 uid = rsync
 gid = rsync
 use chroot = no
 max connections = 200   #最大连接数（并发）
 timeout = 100        #超时时间默认S单位
 pid file = /var/run/rsyncd.pid
 lock file = /var/run/rsyncd.lock
 log file = /var/log/rsyncd.log
 [backup]     #模块名称可自定义任意名称
 path = /backup/   #备份数据的路径
 ignore errors   #忽略错误
 read only = false
 list = false
 hosts allow = 192.168.1.0/24
 hosts deny = 0.0.0.0/32
 auth users = rsync_backup    #虚拟的用户用于连接认证
 secrets file = /etc/rsync.password  #认证的密码配置文件路径
-------------------
[root@BK-S ~]#dos2unix /etc/rsync.conf   #格式化配置文件（系统自带不用格式化，自己新建格式化下）
#或者：vim filename;set ff=unix 或者 sed -i 's/\r//g' filename
#强制保存：	:w !sudo tee %
[root@master-nginx tmp]# useradd -M -s /sbin/nologin rsync  #添加用户
[root@master-nginx tmp]# mkdir /backup -p
[root@master-nginx tmp]# chown -R rsync:rsync /backup
[root@master-nginx /]# chmod -R 770 /backup/
[root@master-nginx /]# echo "rsync_backup:rsync.conf" > /etc/rsync.password
[root@master-nginx /]# cat /etc/rsync.password
rsync_backup:rsync.conf       #认证用户：认证密码
[root@master-nginx /]# ll -d /etc/rsync.password  #由于是明文密码，设置root可管理
[root@master-nginx /]#  rsync --daemon   #启动rsync daemon服务
[root@master-nginx /]# netstat -tunlp | grep rsync  #查看是否启动成功
tcp        0      0 0.0.0.0:873             0.0.0.0:*               LISTEN      16598/rsync
tcp6       0      0 :::873                  :::*                    LISTEN      16598/rsync
客户端（slave-nginx）：
[root@slave-nginx tmp]# echo "rsync.conf" > /etc/rsync.password
[root@slave-nginx tmp]# cat /etc/rsync.password
rsync.conf
[root@slave-nginx tmp]# chmod 600 /etc/rsync.password
[root@slave-nginx tmp]# ll /etc/rsync.password
-rw------- 1 root root 11 Mar  6 09:57 /etc/rsync.password
数据备份：
[root@slave-nginx src]# rsync -avzP ./pcre-8.43.tar.gz rsync_backup@192.168.1.31::backup --password-file=/et
c/rsync.password
sending incremental file list
pcre-8.43.tar.gz
      2,085,854 100%   24.47MB/s    0:00:00 (xfr#1, to-chk=0/1)
rsync: chgrp ".pcre-8.43.tar.gz.Cd7JBS" (in backup) failed: Operation not permitted (1)
sent 2,079,579 bytes  received 135 bytes  4,159,428.00 bytes/sec
total size is 2,085,854  speedup is 1.00
rsync error: some files/attrs were not transferred (see previous errors) (code 23) at main.c(1178) [sender=3.1.2]
上面在报错了，找了好久，是因为rsync --daemon中缺少一行配置fake super = yes。应加上，如：
------------------------------
uid = rsync
gid = rsync
use chroot = no
max connections = 200
timeout = 100
pid file = /var/run/rsyncd.pid
lock file = /var/run/rsyncd.lock
log file = /var/log/rsyncd.log
fake super = yes   #在版本6里面不需要，现在版本需要
[backup]
path = /backup/
ignore errors
read only = false
list = false
hosts allow = 192.168.1.0/24
hosts deny = 0.0.0.0/32
auth users = rsync_backup
secrets file = /etc/rsync.password
------------------------------
添加后重启rsync --daemon后即可。
[root@slave-nginx src]# rsync -avzP ./nginx-1.10.1.tar.gz rsync_backup@192.168.1.31::backup --password-file=/etc/rsync.password
sending incremental file list
nginx-1.10.1.tar.gz
        909,077 100%   21.99MB/s    0:00:00 (xfr#1, to-chk=0/1)
sent 908,676 bytes  received 43 bytes  1,817,438.00 bytes/sec
total size is 909,077  speedup is 1.00
#--delete参数
[root@slave-nginx tmp]# ls
123.txt  456.aaa
[root@master-nginx backup]# ls
123.txt  nginx-1.10.1.tar.gz
[root@slave-nginx tmp]# rsync -avzP /download/src/tmp/ --delete rsync_backup@192.168.1.31::backup --password-file=/etc/rsync.password
[root@master-nginx backup]# ls
123.txt  456.aaa
最终结果显示delete参数的作用就是：客户端有什么，远端服务器就有什么，客户备份目录下没有的，远端服务器目录下其它文件或目录就会被删除，此参数相当危险，实际生产环境中要小心使用


#Linux三剑客命令之Awk
awk命令作用:对文本和数据进行处理
详细说明:awk 是一种编程语言，用于在linux/unix下对文本和数据进行处理。数据可以来自标准输(stdin)、一个或多个文件，或其它命令的输出。它在命令行中使用，但更多是作为脚本来使用。awk有很多内建的功能，比如数组、函数等，这是它和C语言的相同之处，灵活性是awk最大的优势。
语法格式:awk [options] 'scripts' var=value filename
常用参数:
-F 指定分隔符（可以是字符串或正则表达式）
-f 从脚本文件中读取awk命令
-v var=value 赋值变量，将外部变量传递给awk
脚本基本结构:
awk 'BEGIN{ print "start" } pattern{ commands } END{ print "end" }' filename
一个awk脚本通常由BEGIN语句+模式匹配+END语句三部分组成,这三部分都是可选项
实例：
#不加print参数时默认只打印当前的行
[root@master-nginx backup]# echo "hello " | awk 'BEGIN{ print "welcome" } END{ print "2017-08-08" }'
welcome
2017-08-08
[root@master-nginx backup]# echo "hello " | awk 'BEGIN{ print "welcome" } {print} END{ print "2017-08-08" }'
welcome
hello
2017-08-08
#使用print以逗号分隔时，打印则是以空格分界
[root@master-nginx backup]# echo | awk '{a="hello";b="nihao";c="minggongge";print a,b,c;}'  
hello nihao minggongge
#内置变量
$0   #当前记录
$1~$n #当前记录的第N个字段
FS   #输入字段分隔符（-F相同作用）默认空格  Field Separator
RS   #输入记录分割符，默认换行符  Record Separator
NF   #字段个数,就是列  Number Field  
NR   #记录数，就是行号，默认从1开始  Number Row
OFS  #输出字段分隔符，默认空格  Output Field Separator
ORS  #输出记录分割符，默认换行符  Output Record Separator
#外部变量
[root@master-nginx backup]# a=5
[root@master-nginx backup]# b=5
[root@master-nginx backup]# echo | awk '{ print v1*v2 }' v1=$a v2=$b
25
#Awk运算与判断
+ -  加减
* / & 乘 除 求余
^ *  求幂
++ -- 增加或减少，作为前缀或后缀
[root@master-nginx backup]# awk 'BEGIN{a="b";print a,a++,a--,++a;}'
b 0 1 1   #a="b";print a时，a输出b;print a++时，由于a=b为英文参加运算，所以a等于0，所以输出为0,a再++等于1;print a--时，先输出a等于1，a再--等于0;print ++a时，上一个a为0，a先++等于1=a，输出为1
#和其它编程语言一样，所有用作算术运算符进行操作，操作数自动转为数值，所有非数值都变为0
[root@master-nginx backup]# awk 'BEGIN{a="0";print a,a++,a--,a--;}'
0 0 1 0
[root@master-nginx backup]# awk 'BEGIN{a="0";print a,a++,a--,--a;}'
0 0 1 -1
#注意：a++,a--是先输出a,最后再++和--给自身的。--a，++a是先--和++给自身的。最后再输出a的
#赋值运算符:
= += -= *= /= %= ^= **=
正则运算符
~ !~  匹配正则表达式/不匹配正则表达式
逻辑运算符	 
||  &&  逻辑或  逻辑与
关系运算符
< <= > >= != ==  
其它运算符
$   字段引用 
空格 字符串链接符
?:   三目运算符
ln   数组中是否存在某键值
#Awk正则:
^    行首定位符
$    行尾定位符
.    匹配任意单个字符
*    匹配0个或多个前导字符（包括回车）
+    匹配1个或多个前导字符
?    匹配0个或1个前导字符   
[]   匹配指定字符组内的任意一个字符/^[ab]
[^]  匹配不在指定字符组内的任意一个字符
()   子表达式
|    或者
\    转义符
~,!~ 匹配或不匹配的条件语句
x{m} x字符重复m次
x{m,} x字符至少重复m次
X{m,n} x字符至少重复m次但不起过n次（需指定参数-posix或--re-interval）

基本语法：awk [options] 'pattern{action}' file
实例：
在没有options和pattern的情况下，使用命令awk
类似cat：
[root@master-nginx backup]# echo hello > 123.txt
[root@master-nginx backup]# awk '{print}' 123.txt
hello

pattern包括两种特殊模式，分别是BEGIN和END：
1.BEGIN模式，是指命令在处理文本之前执行
2.END模式，是指命令在处理文本之后执行
3.BEGIN模式和END模式同时存在时，其中，BEGIN与END之间的{}相当于一个循环体，对文件中的每一行进行处理
[root@master-nginx backup]# cat 123.txt
haaaaaaaaai     idjfaids      ello
sdfasd      fasdfj     dfafds
[root@master-nginx backup]# awk -F ' ' '{print $1,$2}' 123.txt  #以空格分隔符运行
haaaaaaaaai idjfaids
sdfasd fasdfj
[root@master-nginx backup]# echo | awk -v v=10 '{print v}'  #echo 变量v
10
[root@master-nginx backup]# awk -v FS=' ' '{print $1,$2;}' 123.txt  #使用内置变量时要使用-v参数
haaaaaaaaai idjfaids
sdfasd fasdfj
[root@master-nginx backup]# awk -v FS=' ' -v OFS='$' '{print $1,$2;}' 123.txt  #使用内置变量，以空格为分隔符截取字段，以$为分隔符输出。
haaaaaaaaai$idjfaids
sdfasd$fasdfj 
[root@master-nginx backup]# cat 123.txt #编辑后的文本
hi hello haha
nihao hope happy
fdsfs:fdsfs
[root@master-nginx backup]# awk -v RS=' ' '{print NR,$1}' 123.txt   #以空格为记录分隔，使分隔的成为多行
1 hi
2 hello
3 haha
4 nihao
5 hope
6 happy 
[root@master-nginx backup]# awk -v FS=' ' '{print NR,$1}' 123.txt  #以空格为字段分隔，使分隔的为多列
1 hi
2 nihao
3 fdsfs:fdsfs
[root@master-nginx backup]# awk -v FS=' ' '{print NF,$1}' 123.txt  #以空格为字段分隔，输出每行的字段个数
3 hi
3 nihao
1 fdsfs:fdsfs
[root@master-nginx backup]# last -n 5| awk '{print $1"\trow:"NR"\tcolumn:"NF"\t" $3}'
root    row:1   column:10       192.168.2.27
root    row:2   column:10       192.168.2.27
root    row:3   column:10       192.168.2.27
root    row:4   column:10       192.168.2.27
root    row:5   column:10       192.168.2.27
        row:6   column:0
wtmp    row:7   column:7        Tue
[root@master-nginx backup]# cat /etc/passwd | \
> awk '{FS=":"} $3 < 100 && $3 >10 {print}'  #以':'号为分隔，$3小于100和$3小于10的全部打印
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:99:99:Nobody:/:/sbin/nologin
dbus:x:81:81:System message bus:/:/sbin/nologin
rpc:x:32:32:Rpcbind Daemon:/var/lib/rpcbind:/sbin/nologin
ntp:x:38:38::/etc/ntp:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
postfix:x:89:89::/var/spool/postfix:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin
[root@master-nginx backup]# cat /etc/passwd | awk '{FS=":"} {OFS="#"} $3 < 100 && $3 >10 {print $1,$3,$4}' #以#号为输出分隔符输出$1,$3,$4
operator#11#0
games#12#100
ftp#14#50
nobody#99#99
dbus#81#81
rpc#32#32
ntp#38#38
sshd#74#74
postfix#89#89
tcpdump#72#72
[root@master-nginx backup]# cat /etc/passwd | awk '{FS=":"} $3 < 10 {print $1 "\t"$3}'
root:x:0:0:root:/root:/bin/bash  #这里第一行默认还是以空格为分隔符的
bin     1
daemon  2
adm     3
lp      4
sync    5
shutdown        6
halt    7
mail    8
[root@master-nginx backup]# cat /etc/passwd | awk 'BEGIN {FS=":"} $3 < 10 {print $1 "\t"$3}'
root    0   #因为最之前使用了BEGIN，所以后面全部生效
bin     1
daemon  2
adm     3
lp      4
sync    5
shutdown        6
halt    7
mail    8
[root@master-nginx backup]# cat chenji | awk 'NR==1{printf"%10s %10s %10s %10s %10s\n",$1,$2,$3,$4,"Total"} NR>=2{total=$2+$3+$4;printf"%10s %10d %10d %10d %10.2f\n",$1,$2,$3,$4,total}' #awk的动作间隔用;或者在{}内敲Enter键
      Name        1st        2nd        3th      Total
    libiao         98         95         99     292.00
 yincanhua         87         98         90     275.00
zhanwangjun         80         87         75     242.00
  xuyuying         75         64         61     200.00
  xuyuying         75         64         61       0.00
[root@master-nginx backup]# cat chenji | awk '{if(NR==1) printf "%10s %10s %10s %10s %10s\n",$1,$2,$3,$4,"Tobal"} NR>=2{total=$2+$3+$4; printf "%10s %10d %10d %10d %10.2f\n",$1,$2,$3,$4,total}' #只能用一个if
      Name        1st        2nd        3th      Tobal
    libiao         98         95         99     292.00
 yincanhua         87         98         90     275.00
zhanwangjun         80         87         75     242.00
  xuyuying         75         64         61     200.00

[root@openssl openvpn]# awk '{count[$6]++}END{for (i in count){print i,count[i]}}' openvpn.log | grep jack | awk '{sum+=$2}END{print sum}'
6225
[root@autodep ~]# netstat -tan | awk '{count[$NF]++}END{for (i in count) {printf "%-20s%d\n",i,count[i]}}'
LISTEN              16
State               1
ESTABLISHED         5
established)        1
注：awk后面可接着-F ':'进行设定换行符，可接着-v sum=0设定变量,'/^tcp/{print $1}'单引号内大括号外是为匹配模式，可以支持正则表达式，模糊匹配~，大括号内是执行的动作，一般为print和printf操作，在执行动作内可使用if(1<s){...}else{...}fi或for(i=1,i<=3,i++){}或for(i in array){}或while(){}。执行动作前后可使用BEGIN和END来执行一次操作，注意，是BEGIN只能执行一次，END也只能执行一次。

#mage AWK
awk的输出：
一、print
print的使用格式：
	print item1, item2, ...
要点：
1、各项目之间使用逗号隔开，而输出时则以空白字符分隔；
2、输出的item可以为字符串或数值、当前记录的字段(如$1)、变量或awk的表达式；数值会先转换为字符串，而后再输出；
3、print命令后面的item可以省略，此时其功能相当于print $0, 因此，如果想输出空白行，则需要使用print ""；
例子：
# awk 'BEGIN { print "line one\nline two\nline three" }'
awk -F: '{ print $1, $3 }' /etc/passwd

二、awk变量
2.1 awk内置变量之记录变量：
FS: field separator，读取文件本时，所使用字段分隔符；
RS: Record separator，输入文本信息所使用的换行符；
OFS: Output Filed Separator: 
ORS：Output Row Separator：

awk -F:
OFS="#"
FS=":"

2.2 awk内置变量之数据变量：
NR: The number of input records，awk命令所处理的记录数；如果有多个文件，这个数目会把处理的多个文件中行统一计数；
NF：Number of Field，当前记录的field个数；
FNR: 与NR不同的是，FNR用于记录正处理的行是当前这一文件中被总共处理的行数；
ARGV: 数组，保存命令行本身这个字符串，如awk '{print $0}' a.txt b.txt这个命令中，ARGV[0]保存awk，ARGV[1]保存a.txt；
ARGC: awk命令的参数的个数；
FILENAME: awk命令所处理的文件的名称；
ENVIRON：当前shell环境变量及其值的关联数组；
如：awk 'BEGIN{print ENVIRON["PATH"]}'

2.3 用户自定义变量
gawk允许用户自定义自己的变量以便在程序代码中使用，变量名命名规则与大多数编程语言相同，只能使用字母、数字和下划线，且不能以数字开头。gawk变量名称区分字符大小写。

2.3.1 在脚本中赋值变量
在gawk中给变量赋值使用赋值语句进行，例如：
awk 'BEGIN{var="variable testing";print var}'

2.3.2 在命令行中使用赋值变量
gawk命令也可以在“脚本”外为变量赋值，并在脚本中进行引用。例如，上述的例子还可以改写为：
awk -v var="variable testing" 'BEGIN{print var}'

三、printf
printf命令的使用格式：
printf format, item1, item2, ...
要点：
1、其与print命令的最大不同是，printf需要指定format；
2、format用于指定后面的每个item的输出格式；
3、printf语句不会自动打印换行符；\n
format格式的指示符都以%开头，后跟一个字符；如下：
%c: 显示字符的ASCII码；
%d, %i：十进制整数；
%e, %E：科学计数法显示数值；
%f: 显示浮点数；
%g, %G: 以科学计数法的格式或浮点数的格式显示数值；
%s: 显示字符串；
%u: 无符号整数；
%%: 显示%自身；
修饰符：
N: 显示宽度；
-: 左对齐；
+：显示数值符号；
例子：
# awk -F: '{printf "%-15s %i\n",$1,$3}' /etc/passwd

四、输出重定向
print items > output-file
print items >> output-file
print items | command
特殊文件描述符：
/dev/stdin：标准输入
/dev/sdtout: 标准输出
/dev/stderr: 错误输出
/dev/fd/N: 某特定文件描述符，如/dev/stdin就相当于/dev/fd/0；
例子：
# awk -F: '{printf "%-15s %i\n",$1,$3 > "/dev/stderr" }' /etc/passwd

#exec
shell 中的 exec 两种用法：
1.exec 命令 ;命令代替shell程序，命令退出，shell 退出；比如 exec ls
2.exec 文件重定向，可以将文件的重定向就看为是shell程序的文件重定向 比如 exec 5</dev/null;exec 5<&-
example:
--新建一个文件描述符3，并连接172.168.2.222 22的端口信息返回给文件描述符3，再读取文件描述符3并标准输入到显示器，最后关闭新建的文件描述符。
注：新建文件描述符时前面是数字，紧挨着的是输入或输出或输入输出(3< 3> 3<>),
调用文件描述符时需要使用&符号进行调用，后面是文件描述符ID，调用是输入还是输出必需跟&符号紧挨着。
关闭文件描述符时跟新建文件描述符类型，都是3<开关，结束符是&-，必须紧挨着
exec 3</dev/tcp/172.168.2.222/22
timeout 1 cat <&3
exec 3<＆-

exec 4<> /dev/tcp/172.168.2.222/22
[root@salt ~]# ls -l /dev/fd/
总用量 0
lrwx------ 1 root root 64 9月  28 11:59 0 -> /dev/pts/0
lrwx------ 1 root root 64 9月  28 11:59 1 -> /dev/pts/0
lrwx------ 1 root root 64 9月  28 11:59 2 -> /dev/pts/0
lr-x------ 1 root root 64 9月  28 11:59 3 -> /proc/126348/fd
lrwx------ 1 root root 64 9月  28 11:59 4 -> socket:[3751876]
[root@salt ~]# timeout 1 cat <&4
SSH-2.0-OpenSSH_7.4
[root@salt ~]# echo hehe >&4
[root@salt ~]# timeout 1 cat <&4
Protocol mismatch.
[root@salt ~]# timeout 1 cat <&4
exec 4<&-  或者  exec 4>&-   关闭描述符 
ls -l /dev/fd/
lrwx------ 1 root root 64 9月  28 12:01 0 -> /dev/pts/0
lrwx------ 1 root root 64 9月  28 12:01 1 -> /dev/pts/0
lrwx------ 1 root root 64 9月  28 12:01 2 -> /dev/pts/0
lr-x------ 1 root root 64 9月  28 12:01 3 -> /proc/126652/fd



六、awk的操作符：
6.1 算术操作符：
-x: 负值
+x: 转换为数值；
x^y: 
x**y: 次方
x*y: 乘法
x/y：除法
x+y:
x-y:
x%y:
6.2 字符串操作符：
只有一个，而且不用写出来，用于实现字符串连接；
6.3 赋值操作符：
=
+=
-=
*=
/=
%=
^=
**=
++
--
需要注意的是，如果某模式为=号，此时使用/=/可能会有语法错误，应以/[=]/替代；

6.4 布尔值
awk中，任何非0值或非空字符串都为真，反之就为假；
6.5 比较操作符：
x < y	True if x is less than y. 
x <= y	True if x is less than or equal to y. 
x > y	True if x is greater than y. 
x >= y	True if x is greater than or equal to y. 
x == y	True if x is equal to y. 
x != y	True if x is not equal to y. 
x ~ y	True if the string x matches the regexp denoted by y. 
x !~ y	True if the string x does not match the regexp denoted by y. 
subscript in array	  True if the array array has an element with the subscript subscript.

6.7 表达式间的逻辑关系符：
&&
||
6.8 条件表达式：
selector?if-true-exp:if-false-exp
if selector; then
  if-true-exp
else
  if-false-exp
fi
a=3
b=4
a>b?a is max:b ia max
6.9 函数调用：
function_name (para1,para2)

七 awk的模式：
awk 'program' input-file1 input-file2 ...
其中的program为:
pattern { action }
pattern { action }
...
7.1 常见的模式类型：
1、Regexp: 正则表达式，格式为/regular expression/
2、expresssion： 表达式，其值非0或为非空字符时满足条件，如：$1 ~ /foo/ 或 $1 == "magedu"，用运算符~(匹配)和!~(不匹配)。
3、Ranges： 指定的匹配范围，格式为pat1,pat2
4、BEGIN/END：特殊模式，仅在awk命令执行前运行一次或结束前运行一次
5、Empty(空模式)：匹配任意输入行；对每一行进行处理

7.2 常见的Action
1、Expressions:
2、Control statements
3、Compound statements
4、Input statements
5、Output statements

/正则表达式/：使用通配符的扩展集。
关系表达式：可以用下面运算符表中的关系运算符进行操作，可以是字符串或数字的比较，如$2>%1选择第二个字段比第一个字段长的行。
模式匹配表达式：
模式，模式：指定一个行的范围。该语法不能包括BEGIN和END模式。
BEGIN：让用户指定在第一条输入记录被处理之前所发生的动作，通常可在这里设置全局变量。
END：让用户在最后一条输入记录被读取之后发生的动作。

八 控制语句：
8.1 if-else
语法：if (condition) {then-body} else {[ else-body ]}
例子：
awk -F: '{if ($1=="root") print $1, "Admin"; else print $1, "Common User"}' /etc/passwd
awk -F: '{if ($1=="root") printf "%-15s: %s\n", $1,"Admin"; else printf "%-15s: %s\n", $1, "Common User"}' /etc/passwd
awk -F: -v sum=0 '{if ($3>=500) sum++}END{print sum}' /etc/passwd

8.2 while
语法： while (condition){statement1; statment2; ...}
awk -F: '{i=1;while (i<=3) {print $i;i++}}' /etc/passwd
awk -F: '{i=1;while (i<=NF) { if (length($i)>=4) {print $i}; i++ }}' /etc/passwd

8.3 do-while  #先执行再判断条件，与while相反
语法： do {statement1, statement2, ...} while (condition)
awk -F: '{i=1;do {print $i;i++}while(i<=3)}' /etc/passwd

8.4 for
语法： for ( variable assignment; condition; iteration process) { statement1, statement2, ...}
awk -F: '{for(i=1;i<=3;i++) print $i}' /etc/passwd
awk -F: '{for(i=1;i<=NF;i++) { if (length($i)>=4) {print $i}}}' /etc/passwd
for循环还可以用来遍历数组元素：
语法： for (i in array) {statement1, statement2, ...}
awk -F: '$NF!~/^$/{BASH[$NF]++}END{for(A in BASH){printf "%15s:%i\n",A,BASH[A]}}' /etc/passwd

8.5 case
语法：switch (expression) { case VALUE or /REGEXP/: statement1, statement2,... default: statement1, ...}

8.6 break 和 continue
常用于循环或case语句中

8.7 next
提前结束对本行文本的处理，并接着处理下一行；例如，下面的命令将显示其ID号为奇数的用户：
# awk -F: '{if($3%2==0) next;print $1,$3}' /etc/passwd

九 awk中使用数组
9.1 数组
array[index-expression]
index-expression可以使用任意字符串；需要注意的是，如果某数据组元素事先不存在，那么在引用其时，awk会自动创建此元素并初始化为空串；因此，要判断某数据组中是否存在某元素，需要使用index in array的方式。

要遍历数组中的每一个元素，需要使用如下的特殊结构：
for (var in array) { statement1, ... }
其中，var用于引用数组下标，而不是元素值；
例子：
netstat -ant | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
每出现一被/^tcp/模式匹配到的行，数组S[$NF]就加1，NF为当前匹配到的行的最后一个字段，此处用其值做为数组S的元素索引；
awk '{counts[$1]++}; END {for(url in counts) print counts[url], url}' /var/log/httpd/access_log
用法与上一个例子相同，用于统计某日志文件中IP地的访问量
[root@lvs httpd]# awk '{count[$1]++};END{for (i in count) print i,count[i]}' access_log
192.168.1.101 39

9.2 删除数组变量
从关系数组中删除数组索引需要使用delete命令。使用格式为：
delete  array[index]

十、awk的内置函数
split(string, array [, fieldsep [, seps ] ])
功能：将string表示的字符串以fieldsep为分隔符进行分隔，并将分隔后的结果保存至array为名的数组中；数组下标为从0开始的序列；
netstat -ant | awk '/:80\>/{split($5,clients,":");IP[clients[1]]++}END{for(i in IP){print IP[i],i}}' | sort -rn | head -50
length([string])
功能：返回string字符串中字符的个数；

substr(string, start [, length])
功能：取string字符串中的子串，从start开始，取length个；start从1开始计数；

system(command)
功能：执行系统command并将结果返回至awk命令

systime()
功能：取系统当前时间

tolower(s)
功能：将s中的所有字母转为小写

toupper(s)
功能：将s中的所有字母转为大写

十一、用户自定义函数
自定义函数使用function关键字。格式如下：
function F_NAME([variable])
{
	statements
}
函数还可以使用return语句返回值，格式为“return value”。
#常用例子，以nginx日志和网络状态为例：
#nginx IP
[root@jack ~]# awk '{count[$1]++} END {for (i in count) {print i,count[i]}}' access-2019-12-26-02\:00\:01.log | sort -t ' ' -k 2
#nginx PV
[root@jack ~]# awk '{count[$7]++} END{ for (i in count) {print i,count[i]}}' access-2019-12-26-02\:00\:01.log | sort -t ' ' -k 2
#Network Status Statistic
[root@localhost ~]# netstat -tan | awk '/^tcp/{count[$NF]++} END {for (i in count) {print i,count[i]}}'  
TIME_WAIT 113
FIN_WAIT1 2
SYN_SENT 1
FIN_WAIT2 23
ESTABLISHED 649
LAST_ACK 1
LISTEN 6

#echo
echo -e "next\n" #意思是在引号内容中""引用回车键

#Linux三剑客命令之sed
[root@www ~]# sed [-nefr] [动作]
选项与参数：
-n ：使用安静(silent)模式。在一般 sed 的用法中，所有来自 STDIN 的数据一般都会被列出到终端上。但如果加上 -n 参数后，则只有经过sed 特殊处理的那一行(或者动作)才会被列出来。
-e ：直接在命令列模式上进行 sed 的动作编辑；
-f ：直接将 sed 的动作写在一个文件内， -f filename 则可以运行 filename 内的 sed 动作；
-r ：sed 的动作支持的是延伸型正规表示法的语法。(默认是基础正规表示法语法)
-i ：直接修改读取的文件内容，而不是输出到终端。

动作说明： [n1[,n2]]function
n1, n2 ：不见得会存在，一般代表『选择进行动作的行数』，举例来说，如果我的动作是需要在 10 到 20 行之间进行的，则『 10,20[动作行为] 』

function：
a ：新增， a 的后面可以接字串，而这些字串会在新的一行出现(目前的下一行)～
c ：取代， c 的后面可以接字串，这些字串可以取代 n1,n2 之间的行！
d ：删除，因为是删除啊，所以 d 后面通常不接任何咚咚；
i ：插入， i 的后面可以接字串，而这些字串会在新的一行出现(目前的上一行)；
p ：列印，亦即将某个选择的数据印出。通常 p 会与参数 sed -n 一起运行～
s ：取代，可以直接进行取代的工作哩！通常这个 s 的动作可以搭配正规表示法！例如 1,20s/old/new/g 就是啦！

[root@master-nginx backup]# sed -n '1,3p' passwd  #-n为安静模式，打开1到3行
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | sed  '1a jack'  #在第一行后加入jack
root:x:0:0:root:/root:/bin/bash
jack
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | sed  '1c jack'  #把第一行改成jack
jack
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | nl |sed '3d' #第3行被删除
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nologin
     4  adm:x:3:4:adm:/var/adm:/sbin/nologin
     5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | nl | sed 's/login/jack/g' #把全部源是login的换成目标jack
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nojack
     3  daemon:x:2:2:daemon:/sbin:/sbin/nojack
     4  adm:x:3:4:adm:/var/adm:/sbin/nojack
     5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nojack
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# cat test ; sed -i 's/login/jack/g' test ;cat test #使用i直接更改文件
jack:x:0:0:jack:/jack:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
jack:x:0:0:jack:/jack:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nojack
daemon:x:2:2:daemon:/sbin:/sbin/nojack
adm:x:3:4:adm:/var/adm:/sbin/nojack
lp:x:4:7:lp:/var/spool/lpd:/sbin/nojack
[root@master-nginx backup]# sed -i '$a add jack' test  #直接在最后一行添加信息add jack
[root@master-nginx backup]# cat test 
jack:x:0:0:jack:/jack:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nojack
daemon:x:2:2:daemon:/sbin:/sbin/nojack
adm:x:3:4:adm:/var/adm:/sbin/nojack
lp:x:4:7:lp:/var/spool/lpd:/sbin/nojack
add jack
#数据的搜寻并执行命令
找到匹配模式eastern的行后，搜索/etc/passwd,找到root对应的行，执行后面花括号中的一组命令，每个命令之间用分号分隔，这里把bash替换为blueshell，再输出这行：
 nl /etc/passwd | sed -n '/root/{s/bash/blueshell/;p}'
 1  root:x:0:0:root:/root:/bin/blueshell
如果只替换/etc/passwd的第一个bash关键字为blueshell，就退出:
nl /etc/passwd | sed -n '/bash/{s/bash/blueshell/;p;q}'    
1  root:x:0:0:root:/root:/bin/blueshell
最后的q是退出。
#多点编辑
一条sed命令，删除/etc/passwd第三行到末尾的数据，并把bash替换为blueshell
nl /etc/passwd | sed -e '3,$d' -e 's/bash/blueshell/'
1  root:x:0:0:root:/root:/bin/blueshell
2  daemon:x:1:1:daemon:/usr/sbin:/bin/sh
-e表示多点编辑，第一个编辑命令删除/etc/passwd第三行到末尾的数据，第二条命令搜索bash替换为blueshell。
#更改匹配行
sudo sed -i '/^TFTP_DIRECTORY/c TFTP_DIRECTORY="/var/lib/tftpboot"' /etc/default/tftpd-hpa
#examples
[root@ceph04 ~]# cat test.txt
hehe
test01
test02

ok
[root@ceph04 ~]# sed -i '1i\\helloworld!' test.txt  --在第1行前面增加第一行，内容为'helloworld!'
[root@ceph04 ~]# cat test.txt
helloworld!
hehe
test01
test02

ok
[root@ceph04 ~]# sed -i '2a\\xiaomi' test.txt  --在第2行后面增加第三行，内容为'xiaomi'
[root@ceph04 ~]# cat test.txt
helloworld!
hehe
xiaomi
test01
test02

ok
[root@ceph04 ~]# sed -i '2c replace' test.txt  --将第二行替换为'replace'
[root@ceph04 ~]# cat test.txt
helloworld!
replace
xiaomi
test01
test02

ok
[root@ceph04 ~]# sed -i 's/01/linux&/' test.txt  --在匹配02的前面增加'linux'
[root@ceph04 ~]# cat test.txt
helloworld!
replace
xiaomi
testlinux01
test02

ok
[root@ceph04 ~]# sed -i 's/02/&ubuntu/' test.txt  --在匹配02的后面增加'ubuntu'
[root@ceph04 ~]# cat test.txt
helloworld!
replace
xiaomi
testlinux01
test02ubuntu

ok
[root@ceph04 ~]# sed -i '/^$/d' test.txt   --删除空行
[root@ceph04 ~]# cat test.txt
helloworld!
replace
xiaomi
testlinux01
test02ubuntu
ok




#Linux三剑客命令之grep
.  代表一定有一个任意字符
*  代表0到无穷多次
[:alnum:] 代表大小写字母及数字
[:alpha:] 代表大小写字母
[:upper:] 代表大写字母
[:lower:] 代表小写字母
[:digit:] 代表数字
[root@master-nginx backup]# grep --color=auto root passwd  #--color=auto使查找到的突出颜色
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | grep -i ROOT #-i忽略大小写
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | grep -iv ROOT #-v取反
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | grep '^root'  #查找开头是root的信息
root:x:0:0:root:/root:/bin/bash
[root@master-nginx backup]# head -n 5 passwd | grep '^[^root]' #查找开头是非root的信息
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | grep '.*/var' #查找前面任意信息，包括/var的信息
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
[root@master-nginx backup]# head -n 5 passwd | grep 'bash$' #查找bash结尾的信息
root:x:0:0:root:/root:/bin/bash
[root@master-nginx backup]# head -n 10 passwd | grep '[78]' #查找包含7和8的信息
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
[root@master-nginx backup]# echo -e "123abc \n Root" | grep '^[^0-9]' #查找开关不是数字的信息
 Root
[root@master-nginx backup]# echo -e "123abc \n Root \n rooooot" | grep -i 'ro\{3,5\}t'
 rooooot #查找r开头，中间o有3到5个的，t结尾的信息
[root@master-nginx backup]# cat test | grep -E 'lp|daemon' #使用-E为延伸型正则表达式
daemon:x:2:2:daemon:/sbin:/sbin/nojack
lp:x:4:7:lp:/var/spool/lpd:/sbin/nojack
[root@master-nginx backup]# cat test  | egrep 'spo+l' #查找一个以上的o信息
lp:x:4:7:lp:/var/spool/lpd:/sbin/nojack
[root@master-nginx backup]# cat test  | egrep 'daemon|lp|add'  #或的意思
daemon:x:2:2:daemon:/sbin:/sbin/nojack
lp:x:4:7:lp:/var/spool/lpd:/sbin/nojack
add jack
[root@master-nginx backup]# echo -e "glale \n goole \n goooole" | egrep 'g(la|oo)le'
glale  #使用()和|来判断中间是la或oo的信息
 goole 
[root@master-nginx backup]# echo -e "gxyzc \n gxyzxyzc \n abcabc" | egrep 'g(xyz)+c' #查找中间是重复xyz的信息
gxyzc 
 gxyzxyzc 

## iptables防火墙

![iptables-chains](.\image\iptables\iptables-chains.png)

iptables表：
filter（过滤）,nat（地址软的）,mangle（对包拆开，封装，修改）,raw（只看不做任何修改）
规则链：
PREROUTING
POSTROUTING
INPUT
OUTPUT
FORWARD
iptables最大处理连接数：
注：本机路由转发的时候，才配置FORWARD转发链
[root@smb-server ~]# cat /proc/sys/net/nf_conntrack_max
65536  #这个是nf_conntrack的最大选择连接数
管理链：
-F（清空指定规则）,-P（设定链的默认策略）,-N（自定义一个空链）,-X（删除自定义的空链）,-Z（置零指定链中的计数器）,-E(重命名自定义的链)
filter表默认策略：
iptables -P INPUT DROP  
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
查看类：
-L(显示指定表中的规则)，-n（以数字显示主机地址和端口号）,-v(显示链及规则的详细信息)，-vv（更加详细），-x(显示计数器的精确值)，--line--numbers(显示规则号码)
动作：
ACCEPT（放行）,DROP（丢弃）,REJECT（拒绝）,LOG（日志）,DNAT（目标地址转换）,SNAT（源地址转换）,REDIRECT（端口重定向）,MASQUERADE（地址伪装）,LOG（日志）,MARK（打标记）
扩展模块：
-m state --state RELATED,ESTABLISHED,NEW,INVALID  #指定状态
-m multiport --source-ports 21,22,80 | -m multiport --destination-ports 8080,53 | -m multiport --ports 31,100,23 #指定多端口 
-m iprange --src-range 172.16.100.1-172.168.100.100  #ip范围指定
-m connlimit --connlimit-above 2  #连接数限定,一般使用ACCEPT时跟取反(!)一起使用
-m limit --limit 3/minute --limit-burst 5 -p icmp --icmp-type 8  #先保持5个连接，而后根据速率来限定每分钟响应连接的次数为3次，协议为INPUT的icmp
-m string --algo kmp --string "h7n9" #指定INPUT链中请求报文中有n7n9的，给予匹配，用的是kmp算法，也可用bm算法
-m state --state LOG --log-prefix "firewall all for icmp" -p icmp --icmp-type 8 #对icmp协议进行进行日志记录，并给日志加入前缀好让自己识别
iptables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH -j DROP #设置新的请求到22端口上时，启用recent模块并新建名叫SSH，达到简单防御dos攻击的功能
iptables -I INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 3 --name SSH -j DROP #更新recent，设置SSH的recent连接在300秒内达到3次时，让请求的用户冻结300秒，

filter表规则:
iptables -A INPUT -d 192.168.1.19 -p tcp --dport 22 -j ACCEPT #添加在INPUT链的末尾
iptables -I INPUT -d 192.168.1.19 -p tcp --dport 22 -j ACCEPT #默认插入在INPUT链第一条，可以在INPUT后面加要插入的位置
iptables -D INPUT 1 # 删除指定链中的第几条规则
iptables -R INPUT 1 -d 192.168.1.19 -p tcp --dport 22 -j ACCEPT #替换指定链中的第几条规则
iptables -I INPUT 9 -d 192.168.1.19 -p tcp --dport 21 -m connlimit ! --connlimit-above 2 -j ACCEPT #限定ftp最大连接数为2，超过则不予连接

nat表规则
SNAT:（源地址转换，用于局域网访问互联网）
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j SNAT --to-source 180.1.1.1  #用于固定外网ip的时候，内网用户可上网，仅限内网用户主动发起
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASQUERADE  #用于外网ip不是固定的时候，内网用户可上网，仅限内网用户主动发起
iptables -t nat -A FORWARD -s 192.168.0.0/24 -p icmp -j REJECT #拒绝转发icmp的所有协议，其他协议允许通过 
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT #开启转发ftp数据服务，RELATED就是打开数据服务的   #ip_nat_ftp 和ip_conntrack_ftp两个模块必须安装
iptables -A FORWARD -s 192.168.1.0/24 -p tcp --dport 21 -m state --state NEW -j ACCEPT #开启转发ftp命令服务
DNAT:（目标地址转换，用于互联网访问局域网服务器）
iptables -t nat -A PREROUTING -d 180.1.1.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1 #目标地址转换，用于互联网访问局域网的服务器的，外网地址为180.1.1.1:80，内网地址为192.168.1.1:80
iptables -t nat -R PREROUTING -d 180.1.1.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:8080  #目标地址转换，PAT,用于互联网访问局域网的服务器的，外网地址为180.1.1.1:80，内网地址为192.168.1.1:8080,
iptables -A FORWARD -m string --algo kmp --string "h7n9" -j DROP #丢弃带"h7n9"信息的请求
Example:
[root@nat ~]# cat /etc/sysconfig/iptables
# Generated by iptables-save v1.4.21 on Mon Aug 10 17:25:08 2020
*nat
:PREROUTING ACCEPT [81714:4922587]
:INPUT ACCEPT [1365:98906]
:OUTPUT ACCEPT [10:1168]
:POSTROUTING ACCEPT [167:10069]
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 8 -j DNAT --to-destination 192.168.3.8:8
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 5009 -j DNAT --to-destination 192.168.3.155:7901
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 5012 -j DNAT --to-destination 192.168.3.155:8389
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 8380 -j DNAT --to-destination 192.168.3.155:8380
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 5003 -j DNAT --to-destination 192.168.3.155:8093
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 5002 -j DNAT --to-destination 192.168.3.155:8781
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 5008 -j DNAT --to-destination 192.168.3.155:7904
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 5004 -j DNAT --to-destination 192.168.3.155:22
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 1799 -j DNAT --to-destination 192.168.3.155:7999
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 1521 -j DNAT --to-destination 192.168.3.26:1521
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 8180 -j DNAT --to-destination 192.168.3.90:8180
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 6986 -j DNAT --to-destination 192.168.3.90:22
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 18380 -j DNAT --to-destination 192.168.3.186:8380
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 6876 -j DNAT --to-destination 192.168.3.186:22
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 1117 -j DNAT --to-destination 192.168.3.117:22
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 28380 -j DNAT --to-destination 192.168.3.117:8380
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 1522 -j DNAT --to-destination 192.168.3.127:1521
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 1165 -j DNAT --to-destination 192.168.3.165:22
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 8280 -j DNAT --to-destination 192.168.3.165:8280
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 10000 -j DNAT --to-destination 192.168.3.200:22
-A PREROUTING -d 58.33.49.196/32 -p tcp -m tcp --dport 1524 -j DNAT --to-destination 192.168.3.130:1521
-A POSTROUTING -s 192.168.3.0/24 -j SNAT --to-source 58.33.49.196
COMMIT
# Completed on Mon Aug 10 17:25:08 2020
# Generated by iptables-save v1.4.21 on Mon Aug 10 17:25:08 2020
*filter
:INPUT DROP [1:52]
:FORWARD ACCEPT [391688:55247796]
:OUTPUT ACCEPT [318:31859]
-A INPUT -s 127.0.0.0/8 -j ACCEPT
-A INPUT -s 192.168.3.0/24 -j ACCEPT
-A INPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
COMMIT
# Completed on Mon Aug 10 17:25:08 2020

#filter链最小默认规则
:INPUT DROP [18:2143]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [86:9328]
-A INPUT -s 192.168.13.0/24 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT
-A INPUT -s 172.168.2.0/24 -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p icmp -j ACCEPT

#rsyslog
基本语法格式
类型.级别[;类型.级别]　　动作
news.=crit　　/var/log/news.crit
‘=’特殊符号，如果存在说明只有本Severity的消息才进行处理，如果不存在则处理本Severity及其以下级别的消息
‘;‘表示&&、’!‘表示取反、’*’表示所有
动作：表示信息发送的目的地
　　可以是日记文件(绝对路径)，如果文件名前面加上减号表示不将日志信息同步刷新到磁盘上(使用写入缓存)，这样可以提高日志写入性能，但是增加了系统崩溃后丢失日志的风险
　　可以是远程主机（@host，host可以是ip或域名,一个@表示UDP协议，两个@@表示TCP协议）
　　可以是指定用户（user1,user2），如果指定用户已登入，那么他们将收到消息
过滤指定内容日志：
:msg,contains,"iptables:" 				/var/log/iptables.log
systemctl restart rsyslog
注：如果不设置，则日志默认写入到/var/log/messages文件中

#规则链的先后顺序:
入站顺序:PREROUTING→INPUT
出站顺序:OUTPUT→POSTROUTING
转发顺序:PREROUTING→FORWARD→POSTROUTING

#iptables日志写入到文件
iptables -N SILENCE_INPUT_LOG
iptables -I INPUT 1 -j SILENCE_INPUT_LOG
iptables -A SILENCE_INPUT_LOG -p icmp -j LOG --log-prefix "iptables:"
iptables -A SILENCE_INPUT_LOG -j RETURN

#iptables添加黑白名单真实案例：
---1. 记录ssh日志信息到文件
[ops0799@iptables ~]$ sudo iptables -t nat -I PREROUTING 1 -d 47.100.73.110/32 -p tcp -m tcp --dport 8022 -j LOG --log-prefix "iptables-ssh-to-jumpserver:"
[ops0799@iptables ~]$ sudo grep iptables-ssh-to-jumpserver /var/log/messages
Jul 17 14:33:10 iptables kernel: iptables-ssh-to-jumpserver:IN=eth1 OUT= MAC=00:16:3e:1e:ac:3b:ee:ff:ff:ff:ff:ff:08:00 SRC=123.57.237.200 DST=47.100.73.110 LEN=60 TOS=0x14 PREC=0x00 TTL=56 ID=46677 DF PROTO=TCP SPT=57902 DPT=8022 WINDOW=29200 RES=0x00 SYN URGP=0 
Jul 17 14:33:24 iptables kernel: iptables-ssh-to-jumpserver:IN=eth1 OUT= MAC=00:16:3e:1e:ac:3b:ee:ff:ff:ff:ff:ff:08:00 SRC=123.57.237.200 DST=47.100.73.110 LEN=60 TOS=0x14 PREC=0x00 TTL=56 ID=6674 DF PROTO=TCP SPT=60026 DPT=8022 WINDOW=29200 RES=0x00 SYN URGP=0 
--从ssh日志中获取地址
[ops0799@iptables ipset]$ sudo grep iptables-ssh-to-jumpserver /var/log/messages | awk -F "SRC=" '{print $2}' | awk '{print $1}' | sort | uniq -c
    325 123.57.237.200
      1 222.66.21.210
----2. 设置ipset
[ops0799@iptables ~]$ sudo yum install ipset -y
[ops0799@iptables ~]$ sudo ipset create blacklist hash:ip maxelem 1000000
[ops0799@iptables ~]$ sudo ipset create whitelist hash:ip maxelem 1000000
[ops0799@iptables ~]$ sudo ipset add blacklist 123.57.237.200
[ops0799@iptables ~]$ sudo ipset add whitelist 222.66.21.210
[ops0799@iptables ~]$ sudo ipset list 
Name: blacklist
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 1000000
Size in memory: 168
References: 1
Number of entries: 1
Members:
123.57.237.200

Name: whitelist
Type: hash:ip
Revision: 4
Header: family inet hashsize 1024 maxelem 1000000
Size in memory: 168
References: 1
Number of entries: 1
Members:
222.66.21.210
--将ipset规则保存到文件，可选
sudo ipset save blacklist -f blacklist.txt
sudo ipset save whitelist -f whitelist.txt

---其它常用命令---
--删除ipset
sudo ipset destroy blacklist
sudo ipset destroy whitelist
--导入ipset规则
ipset restore -f blacklist.txt
ipset restore -f whitelist.txt
-------------

----3. iptables添加黑白名单操作----
--新建黑名单规则
sudo iptables -I FORWARD 1 -m set --match-set blacklist src  -d 10.10.10.230 -p tcp --dport 2222  -j DROP
--新建白名单规则
sudo iptables -I FORWARD 1 -m set --match-set whitelist src  -d 10.10.10.230 -p tcp --dport 2222  -j ACCEPT
------------------------------
[ops0799@iptables ipset]$ sudo iptables -vnL FORWARD
Chain FORWARD (policy ACCEPT 215K packets, 168M bytes)
 pkts bytes target     prot opt in     out     source               destination         
  945 62932 ACCEPT     tcp  --  *      *       0.0.0.0/0            10.10.10.230         match-set whitelist src tcp dpt:2222
   49  3452 DROP       tcp  --  *      *       0.0.0.0/0            10.10.10.230         match-set blacklist src tcp dpt:2222

----4. 定时自己添加IP到黑名单----
[ops0799@iptables ipset]$ cat deny-sship.sh 
#!/bin/sh
IPTABLE_LOG_PREFIX='iptables-ssh-to-jumpserver'
IPTABLES_LOG_FILE='/var/log/messages'
IPTABLES_FILTER_IP_FILE='./iptables-ssh.log'

#filter ip to file
sudo grep ${IPTABLE_LOG_PREFIX} ${IPTABLES_LOG_FILE} | awk -F "SRC=" '{print $2}' | awk '{print $1}' | sort | uniq -c > ${IPTABLES_FILTER_IP_FILE}
#add ip to blacklist
sudo grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' ${IPTABLES_FILTER_IP_FILE} | awk '{print "sudo ipset add -! blacklist",$0}' | sh
[ops0799@iptables ipset]$ sudo crontab -l
* */6 * * * sudo /home/ops0799/ipset/deny-sship.sh
----------------------------


-------iptables案例规则-------
[ops0799@iptables ipset]$ sudo cat /etc/sysconfig/iptables
# Generated by iptables-save v1.4.21 on Sat Jul 17 15:33:04 2021
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [100389:81915449]
:OUTPUT ACCEPT [11821:9607040]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m tcp --dport 1194 -j ACCEPT
-A INPUT -s 192.168.177.0/24 -p tcp -m tcp --dport 9100 -j ACCEPT
-A INPUT -s 192.168.177.0/24 -p tcp -m tcp --dport 9572 -j ACCEPT
-A INPUT -s 10.0.0.0/8 -p tcp -m tcp --dport 9572 -j ACCEPT
-A INPUT -s 222.66.21.210/32 -p tcp -m tcp --dport 9572 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9572 -j DROP
-A FORWARD -d 10.10.10.230/32 -p tcp -m set --match-set whitelist src -m tcp --dport 2222 -j ACCEPT
-A FORWARD -d 10.10.10.230/32 -p tcp -m set --match-set blacklist src -m tcp --dport 2222 -j DROP
COMMIT
# Completed on Sat Jul 17 15:33:04 2021
# Generated by iptables-save v1.4.21 on Sat Jul 17 15:33:04 2021
*nat
:PREROUTING ACCEPT [7065:528078]
:INPUT ACCEPT [394:24352]
:OUTPUT ACCEPT [556:38088]
:POSTROUTING ACCEPT [556:38088]
-A PREROUTING -d 47.100.73.115/32 -p tcp -m tcp --dport 8022 -j LOG --log-prefix "iptables-ssh-to-jumpserver:"
-A PREROUTING -d 47.100.73.115/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination 10.10.10.240:80
-A PREROUTING -d 47.100.73.115/32 -p tcp -m tcp --dport 443 -j DNAT --to-destination 10.10.10.240:443
-A PREROUTING -d 47.100.73.115/32 -p tcp -m tcp --dport 8022 -j DNAT --to-destination 10.10.10.230:2222
-A POSTROUTING -d 10.10.10.240/32 -p tcp -m tcp --dport 80 -j SNAT --to-source 10.10.10.250
-A POSTROUTING -d 10.10.10.240/32 -p tcp -m tcp --dport 443 -j SNAT --to-source 10.10.10.250
-A POSTROUTING -d 10.10.10.230/32 -p tcp -m tcp --dport 2222 -j SNAT --to-source 10.10.10.250
-A POSTROUTING -s 10.0.0.0/8 -o eth1 -j SNAT --to-source 47.100.73.115
-A POSTROUTING -s 192.168.177.0/24 -j MASQUERADE
COMMIT
# Completed on Sat Jul 17 15:33:04 2021





#docker run add iptables rules
[root@linux01 shell]# cat iptables_mysql_rule.sh 
-------
#!/bin/sh
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:
PORT='3306'

for i in ${PORT};do
	iptables -vnL INPUT | grep ${i} >& /dev/null
	if [ $? != 0 ];then
		iptables -I INPUT 1 -s 192.168.10.0/24 -p tcp --dport 3306 -j DROP >& /dev/null
	fi
done
-------

#"$@"与"$*"的区别：
------------
[root@lamp ~]# bash test.sh a 'b c d ' e
3
a b c d  e
1
a b c d  e
[root@lamp ~]# cat test.sh 
#!/bin/bash
#
fun(){
        echo $#
}

fun "$@"
echo "$@"
fun "$*"
echo "$*"
------------


##CA证书：
#cakey.pem建立：
[root@mysql-slave CA]# （umask 077;openssl genrsa -out private/cakey.pem 2048)
#cacert.pem自签名证书：
[root@mysql-slave CA]# openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:Tech
Organizational Unit Name (eg, section) []:magedu
Common Name (eg, your name or your server's hostname) []:ca.jack.com                       
Email Address []:
#建立CA需要的文件
[root@mysql-slave CA]# touch index.txt
[root@mysql-slave CA]# touch serial
[root@mysql-slave CA]# echo 01 > serial
#客户端生成key:
[root@mysql-slave data]# openssl genrsa -out ./mysql.key 1024
#客户端生成csr证书请求文件:
[root@mysql-slave data]# openssl req -new -key mysql.key -out mysql.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:Tech
Organizational Unit Name (eg, section) []:magedu
Common Name (eg, your name or your server's hostname) []:mysql.jack.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
#CA签署证书请求文件生成证书：
[root@mysql-slave data]# openssl ca -in mysql.csr -out mysql.crt -days 3650
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Jun 30 09:30:52 2019 GMT
            Not After : Jun 27 09:30:52 2029 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Shanghai
            organizationName          = Tech
            organizationalUnitName    = magedu
            commonName                = mysql.jack.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                D9:B5:05:EB:7B:0F:BF:4E:0C:12:C8:62:2C:9C:40:4E:CD:07:3D:40
            X509v3 Authority Key Identifier: 
                keyid:48:71:EC:91:50:71:2D:0A:F1:D6:20:97:92:58:82:A3:0C:5B:E0:4F

Certificate is to be certified until Jun 27 09:30:52 2029 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated


#Linux的文件系统控制(setfacl、getfacl)
[root@smb-server tmp]# mkdir test
[root@smb-server tmp]# ll -d test/
drwxr-xr-x 2 root root 4096 7月   4 20:30 test/
[root@smb-server tmp]# getfacl test/
# file: test/
# owner: root
# group: root
user::rwx   #未设置facl时，使用简单的acl权限
group::r-x
other::r-x
[root@smb-server tmp]# setfacl -m u:hq01u0402:rwx test/
[root@smb-server tmp]# getfacl test/
# file: test/
# owner: root
# group: root
user::rwx
user:hq01u0402:rwx  #设置用户hq01u0402的权限为rwx,mask也相应的随着改变为rwx，当mask为rw，而user:hq01u0402权限为rwx，则user:hq01u0402最后权限为rw，不能大于mask
group::r-x
mask::rwx
other::r-x
[root@smb-server tmp]# getfacl test/
# file: test/
# owner: root
# group: root
user::rwx
user:hq01u0402:rwx
user:hq01u0061:rw- #又加入一个用户
group::r-x
mask::rwx
other::r-x
[root@smb-server tmp]# setfacl -m mask::rw test/ #设置mask为rw
[root@smb-server tmp]# getfacl test/
# file: test/
# owner: root
# group: root
user::rwx
user:hq01u0402:rwx              #effective:rw-  #真实权限只有rw
user:hq01u0061:rw-
group::r-x                      #effective:r--  #真实权限只有r
mask::rw-
other::r-x
[root@smb-server tmp]# mkdir -pv test/jack
mkdir: 已创建目录 "test/jack"
[root@smb-server tmp]# getfacl -R test/ #递归查询目录下所有文件权限信息
# file: test/
# owner: root
# group: root
user::rwx
user:hq01u0402:rwx              #effective:rw-
user:hq01u0061:rw-
group::r-x                      #effective:r--
mask::rw-
other::r-x

# file: test//jack  #这个文件目录下的权限不受test目录权限影响
# owner: root
# group: root
user::rwx
group::r-x
other::r-x

[root@smb-server tmp]# setfacl -d -m mask::rwx test/  #设置默认的mask为rwx
[root@smb-server tmp]# getfacl -R test/
# file: test/
# owner: root
# group: root
user::rwx
user:hq01u0402:rwx              #effective:rw-
user:hq01u0061:rw-
group::r-x                      #effective:r--
mask::rw-
other::r-x
default:user::rwx
default:group::r-x
default:mask::rwx   #默认mask为rwx，表示这个目录下的所有新建立文件mask为rwx，本目录本身的rwx为自己设置的rw
default:other::r-x

# file: test//jack
# owner: root
# group: root
user::rwx
group::r-x
other::r-x
[root@smb-server tmp]# setfacl -R -d -m u:hq01u0402:rwx test/ #递归设置默认用户hq01u0402的权限为rwx,则以后在test/目录上新建的任何文件用户hq01u0402都具有rwx权限
[root@smb-server tmp]# getfacl -R test/
# file: test/
# owner: root
# group: root
user::rwx
user:hq01u0402:rwx              #effective:rw-
user:hq01u0061:rw-
group::r-x                      #effective:r--
mask::rw-
other::r-x
default:user::rwx
default:user:hq01u0402:rwx
default:group::r-x
default:mask::rwx
default:other::r-x

# file: test//jack
# owner: root
# group: root
user::rwx
group::r-x
other::r-x
default:user::rwx
default:user:hq01u0402:rwx
default:group::r-x
default:mask::rwx
default:other::r-x
[root@smb-server tmp]# getfacl /Share/Info/   #查看/share/Info的facl权限
getfacl: Removing leading '/' from absolute path names 
# file: Share/Info/
# owner: hq01u0402
# group: hq01u0402
# flags: -s-
user::rwx
group::r-x
group:Info:rwx
mask::rwx
other::r-x
default:user::rwx
default:group::r-x
default:group:Info:rwx
default:mask::rwx
default:other::r--
[root@smb-server tmp]# getfacl /Share/Info/ | setfacl -R --set-file=- /tmp/test/  #复制acl权限到另外一个目录，并且递归应用于每个文件
getfacl: Removing leading '/' from absolute path names
[root@smb-server tmp]# getfacl -R test/
# file: test/
# owner: root
# group: root
user::rwx
group::r-x
group:Info:rwx
mask::rwx
other::r-x
default:user::rwx
default:group::r-x
default:group:Info:rwx
default:mask::rwx
default:other::r--

# file: test//jack
# owner: root
# group: root
user::rwx
group::r-x
group:Info:rwx
mask::rwx
other::r-x
default:user::rwx
default:group::r-x
default:group:Info:rwx
default:mask::rwx
default:other::r--
[root@smb-server test]# getfacl jack/
# file: jack/
# owner: root
# group: root
user::rwx
group::r-x
group:Info:rwx
mask::rwx
other::r-x
default:user::rwx
default:group::r-x
default:group:Info:rwx
default:mask::rwx
default:other::r--
[root@smb-server test]# setfacl -x group:Info jack/  #删除用户或组权限时可不精确到权限
[root@smb-server test]# getfacl jack/
# file: jack/
# owner: root
# group: root
user::rwx
group::r-x
mask::r-x
other::r-x
default:user::rwx
default:group::r-x
default:group:Info:rwx
default:mask::rwx
default:other::r--
[root@smb-server test]# setfacl -b jack/ #清空所有facl权限
[root@smb-server test]# getfacl jack/
# file: jack/
# owner: root
# group: root
user::rwx
group::r-x
other::r-x
[root@smb-server test]# setfacl -k aa/  #删除默认acl
[root@smb-server test]# getfacl aa/
# file: aa/
# owner: root
# group: root
user::rwx
group::r-x
group:Info:rwx
mask::rwx

<<<<<<< Updated upstream
#find
find $(pwd) -type -f   #查找文件
find $(pwd) -ctime +3 -exec rm -rf {} \; #查找3天前的文件(以ctime时间来判断.当你编辑文件什么也不修改退出时，此时会改变atime(access time)时间，当你修改并保存退出时，此时会改变atime和mtime(modify time)时间。当你更改文件权限和移动复制时会改变ctime(change time)时间)，然后执行删除
find $(pwd) -cmin -60  #以change time时间(minute单位)来查找60分钟内的文件,还有mmin,amin
find $(pwd) -size +10k #查找大于10k的文件
find . -name \*.cfg -print  #查找.cfg结尾的文件并打印出来
find /sbin /usr/sbin -executable \! -readable -print  #搜索可执行但不可读的文件
find ./ -perm 664  #查找权限正好是664的所有文件
find ./ -perm -664 #查找权限最大是664的所有文件
find ./ -perm +644 #查找权限最小是664的所有文件

#nginx日志切割
cat /shell/nginx_cut.sh
#!/bin/bash
date=$(date +%Y-%m-%d-%H:%M:%S)   
logpath=/var/log/nginx
bkpath=$logpath/backup_logs
nginx_pid=/var/run/nginx/nginx.pid
mkdir -p $bkpath
mv $logpath/access.log $bkpath/access-$date.log 
mv $logpath/error.log $bkpath/error-$date.log
kill -USR1 $(cat $nginx_pid) 
#clean old logs
find $bkpath/ -ctime +90 -exec rm -f {} \;

tail /etc/crontab
0 2 * * * root /etc/init.d/nginx_cut.sh

####日志切割
#logrotate的执行是由crond服务来调用的，其脚本是/etc/cron.daily/logrotate
[root@elk bin]# cat /etc/cron.daily/logrotate 
#!/bin/sh
/usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
/usr/sbin/logrotate工具调用了/var/lib/logrotate/logrotate.status和/etc/logrotate.conf两个文件。然后将执行的结果（就是那个$?，成功为0，不成功为非0）进行判断，非0时执行/usr/bin/logger命令。最后退出。

#/etc/logrotate.conf是主配置文件
[root@xuexi ~]# grep -vE "^$|^#" /etc/logrotate.conf
weekly　　//每周一次rotate（翻译是旋转，其实就是切割）
rotate 4　　//保留4份切割文件，多余删除，不计算新建日志文件
create　　//结束后创建一个新的空白日志文件
dateext　　//用日期作为切切割文件的后缀
include /etc/logrotate.d　　//将/etc/logrotate.d目录下的文件都加载进来（全都执行）
/var/log/wtmp {　　//仅针对/var/log/wtmp文件
    monthly　　//每月执行一次
    create 0664 root utmp　　//结束后创建新的空白日志，权限0664，所有者root，所属组utmp
    minsize 1M　　//切割文件最少需要1M，否则不执行
    rotate 1　　//保留1份，多余删除，不计算新建日志文件
}
/var/log/btmp {　　//仅针对/var/log/btmp
    missingok　　//丢失不报错
    monthly　　//每月执行一次
    create 0600 root utmp　　//结束后创建新的空白日志，权限0600，所有者root，所属组utmp
    rotate 1　　//保留1份，多余删除，不计算新建日志文件
}
#其余主要参数
olddir directory                         转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统
copytruncate                              用于还在打开中的日志文件，把当前日志备份并截断；是先拷贝再清空的方式，拷贝和清空之间有一个时间差，可能会丢失部分日志数据。
sharedscripts                           运行postrotate脚本，作用是在所有日志都轮转后统一执行一次脚本。如果没有配置这个，那么每个日志轮转后都会执行一次脚本
prerotate                                 在logrotate转储之前需要执行的指令，例如修改文件的属性等动作；必须独立成行
postrotate                               在logrotate转储之后需要执行的指令，例如重新启动 (kill -HUP) 某个服务！必须独立成行

#/var/lib/logrotate/logrotate.status中默认记录logrotate上次切割日志文件的时间
[root@elk bin]# cat /var/lib/logrotate/logrotate.status 
logrotate state -- version 2
"/var/log/yum.log" 2019-8-8-1:0:0
"/var/log/boot.log" 2019-8-11-3:7:1
"/var/log/httpd/error_log" 2019-8-11-3:0:0
"/var/log/chrony/*.log" 2019-8-8-1:0:0
"/var/log/wtmp" 2019-8-8-1:0:0
"/var/log/spooler" 2019-8-11-3:7:1
"/var/log/btmp" 2019-8-8-1:0:0
"/var/log/maillog" 2019-8-11-3:7:1
"/var/log/iptraf-ng/*.log" 2019-8-8-1:0:0
"/var/log/wpa_supplicant.log" 2019-8-8-1:0:0
"/var/log/secure" 2019-8-11-3:7:1
"/var/log/messages" 2019-8-11-3:7:1
"/var/log/httpd/access_log" 2019-8-11-3:0:0
"/var/account/pacct" 2019-8-8-1:0:0
"/var/log/cron" 2019-8-11-3:7:1
[root@elk bin]# vim /etc/logrotate.d/sshd #因为/etc/logrotate.d被include到/etc/logrotate.conf中，又/etc/logrotate.conf被include到/etc/cron.daily/logrotate中，所以每天会执行一边新建的文件，不过每天检查到我们这也不会每天进行切割，因为我们这里明确定义了每周进行切割一次
/var/log/sshd-test.log{
        missingok
        weekly
        create 0600 root root
        dateext
        rotate 3
}
[root@elk bin]# logrotate -vf /etc/logrotate.d/sshd  #手动强制进行日志切割
logrotate命令格式：
logrotate [OPTION...] <configfile>
-d, --debug ：debug模式，测试配置文件是否有错误。
-f, --force ：强制转储文件。
-m, --mail=command ：压缩日志后，发送日志到指定邮箱。
-s, --state=statefile ：使用指定的状态文件。
-v, --verbose ：显示转储过程。

[root@elk bin]# ls /var/log/
     sshd-test.log
     sshd-test.log-20190811

切割nginx日志的配置	
[root@master-server ~]# vim /etc/logrotate.d/nginx
/usr/local/nginx/logs/*.log {
daily
rotate 7
missingok
notifempty
dateext
sharedscripts
postrotate
    if [ -f /usr/local/nginx/logs/nginx.pid ]; then
        kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
    fi
endscript
}
##日志分割脚本
[root@bastion-IDC ~# vim /usr/local/sbin/logrotate-nginx.sh
-------------
#!/bin/bash
#创建转储日志压缩存放目录
mkdir -p /data/nginx_logs/days
#手工对nginx日志进行切割转换
/usr/sbin/logrotate -vf /etc/logrotate.d/nginx
#当前时间
time=$(date -d "yesterday" +"%Y-%m-%d")
#进入转储日志存放目录
cd /data/nginx_logs/days
#对目录中的转储日志文件的文件名进行统一转换
for i in $(ls ./ | grep "^\(.*\)\.[[:digit:]]$")
do
mv ${i} ./$(echo ${i}|sed -n 's/^\(.*\)\.\([[:digit:]]\)$/\1/p')-$(echo $time)
done
#对转储的日志文件进行压缩存放，并删除原有转储的日志文件，只保存压缩后的日志文件。以节约存储空间
for i in $(ls ./ | grep "^\(.*\)\-\([[:digit:]-]\+\)$")
do
tar jcvf ${i}.bz2 ./${i}
rm -rf ./${i}
done
#只保留最近7天的压缩转储日志文件
find /data/nginx_logs/days/* -name "*.bz2" -mtime 7 -type f -exec rm -rf {} \;
-------------
##crontab定时执行
[root@bastion-IDC ~# crontab -e
#logrotate
0 0 * * * /bin/bash -x /usr/local/sbin/logrotate-nginx.sh > /dev/null 2>&1 


### mysql 日志切割
```
[root@devmysql /etc/logrotate.d]# cat mysql 
# grant reload on *.* to ops@'localhost' identified by 'homsom';
/data/mysql/mysql.err {
	create 640 mysql mysql
	dateext
	notifempty
	daily
	maxage 60
	rotate 30
	missingok
	compress
	olddir /data/logrotate
	postrotate
	    # just if mysqld is really running
	    if test -x /usr/local/mysql/bin/mysqladmin &&
	       /usr/local/mysql/bin/mysqladmin -uops -phomsom ping &>/dev/null
	    then
	       /usr/local/mysql/bin/mysqladmin -uops -phomsom flush-logs error
	    fi
	endscript
}

/data/mysql/mysql-slow.log {
	create 640 mysql mysql
	dateext
	notifempty
	daily
	maxage 60
	rotate 30
	missingok
	compress
	olddir /data/logrotate
	postrotate
	    # just if mysqld is really running
	    if test -x /usr/local/mysql/bin/mysqladmin &&
	       /usr/local/mysql/bin/mysqladmin -uops -phomsom ping &>/dev/null
	    then
	       /usr/local/mysql/bin/mysqladmin -uops -phomsom flush-logs slow
	    fi
	endscript
}

# logrotate -vf /etc/logrotate.d/mysql	#测试
```


##tcpdump
[root@autodep ~]# tcpdump -i eth0 ip host 192.168.1.254  #在eth0接口上，ip协议，抓取关于主机是192.168.1.254的包
[root@autodep ~]# tcpdump -i eth0 ip host 192.168.1.234 and tcp port 22  #在eth0接口上，ip协议，抓取关于主机是192.168.1.254并且端口是22的
[root@autodep ~]# tcpdump -i eth0 src 192.168.1.234 and dst 192.168.1.232
[root@autodep ~]# tcpdump -i eth0 src 192.168.1.234 and dst ! 192.168.1.232
[root@docker02 download]# tcpdump -vvvnnn -i eth0 ip src 192.168.13.218 and tcp dst port 9000



#tcpkill connection
--test grab package
tcpdump -i eth0 ip src 172.168.2.222 and src port 22 and dst 192.168.13.236 and dst port 43607
--install tcpkill
yum install dsniff -y
--tcpkill connection session,match for tcpdump <expression>
tcpkill -i eth0 ip src 172.168.2.222 and src port 22 and dst 192.168.13.236 and dst port 43607
tcpkill -i eth1 ip src 4.10.7.11 and src port 1194 and dst 22.6.2.20 and dst port 53647

####Linux下用curl命令对API的使用
测试get请求
$ curl http://www.linuxidc.com/login.cgi?user=test001&password=123456
测试post请求
$ curl -d "user=nickwolfe&password=12345" http://www.linuxidc.com/login.cgi

方式一：发送磁盘上面的JSON文件（推荐）
curl -X POST -H 'content-type: application/json'  -d @/apps/myjsonfile.txt http://192.168.129.xx/AntiRushServer/api/ActivityAntiRush
方式二：在命令行直接发送JSON结构数据
curl -H 'content-type: application/json' -X POST -d '{"accountType":"4","channel":"1","channelId":"YW_MMY","uid":"13154897541","phoneNumber":"13154897541","loginSource":"3","loginType":"1","userIp":"192.168.2.3","postTime":"14633fffffffffff81286","userAgent":"Windows NT","imei":"352600051025733","macAddress":"40:92:d4:cb:46:43","serialNumber":"123"}' http://192.168.129.xx/AntiRushServer/api/ActivityAntiRush

方式一：发送磁盘上面的xml文件（推荐）
curl -X POST -H 'content-type: application/xml'  -d @/apps/myxmlfile.txt http://172.19.219.xx:8081/csp/faq/actDiaUserInfo.action
方式二：在命令行直接发送xml结构数据
echo '<?xml version="1.0" encoding="UTF-8"?><userinfoReq><subsNumber>13814528620</subsNumber><type>3</type></userinfoReq>'|curl -X POST -H'Content-type:text/xm' -d @- http://172.19.xx.xx:8081/csp/faq/actDiaUserInfo.action

方式一：发送磁盘上面的请求报文文件（推荐）
 curl -H 'Content-Type: text/xml;charset=UTF-8;SOAPAction:""' -d @/apps/mysoapfile.xml http://172.18.173.xx:8085/csp-magent-client/madapterservices/madapter/lmCountAccessor
方式二：在命令行直接发送xml结构数据
curl -H 'content-type: application/xml' -d '<?xml version="1.0" encoding="utf-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ser="http://service.accessor.madapter.csp.huawei.com"><soapenv:Header /><soapenv:Body><ser:leaveMessageCount><ser:in0><![CDATA[20161011160516XdznbN]]></ser:in0><ser:in1><![CDATA[1600106496388382726]]></ser:in1><ser:in2><![CDATA[14]]></ser:in2><ser:in3><![CDATA[<extendParams><channelid>1600</channelid><servicetype></servicetype><appid></appid><usertype>10</usertype><userid>6496388382726</userid><msisdn>13814528620</msisdn><email></email><account></account><nickname></nickname><questionType></questionType></extendParams>]]></ser:in3></ser:leaveMessageCount></soapenv:Body></soapenv:Envelope>' http://172.18.173.xx:8085/csp-magent-client/madapterservices/madapter/lmCountAccessor

#ssh隧道
ssh -N -f -R 8888:127.0.0.1:1080 root@172.168.2.222
注：-N连接后不进入终端，-f在后台运行，-R表示前面先写远程端口，后面写本地ip加端口，这样远端的服务器就可以用8888端口连接本地的1080http_proxy，https_proxy代理端口上网了。
ssh -N -f -L 127.0.0.1:1080:172.168.2.222:8000 root@172.168.2.222
注：-N连接后不进入终端，-f在后台运行，-L表示前面先写本地ip加端口，后面写远端ip加端口，这样本地的服务器就可以用1080端口连接远端的8000端口了。
ssh -Nfg -L 192.168.13.236:10011:192.168.0.202:443 localhost
注：将192.168.0.202:443服务通过ssh隧道转发到192.168.13.236:10011端口


#linux设置http_proxy,https_proxy
[root@salt /git/linux]# export http_proxy='127.0.0.1:8888'
[root@salt /git/linux]# export https_proxy='127.0.0.1:8888'
#git设置代理
[root@master /download]# git config --global https.proxy https://127.0.0.1:10080
[root@master /download]# git config --global http.proxy http://127.0.0.1:10080
[root@master /download]# git config --global -l
https.proxy=https://127.0.0.1:10080
http.proxy=http://127.0.0.1:10080

#通过linux shell发送邮件：
1.安装mailx:
centos7自带有mailx软件包，有/usr/bin/mail命令，配置文件为/etc/mail.rc。如果没有软件包，可以安装：yum install -y mailx 
2.修改配置文件/etc/mail.rc,在后面添加：
----------
set from=jacknotes@126.com
set smtp=smtp.126.com
set smtp-auth=login
set smtp-auth-user=jack@126.com
set smtp-auth-password=TEZVGXVC
#下面是忽略认证
set ssl-verify=ignore
set nss-config-dir=/etc/maildbs/
----------
3.发送邮件：
mail -s 'test for linux' jack@163.com
hello jack
EOT  #按ctrl+D进行结束输入并发送
或者 
echo 'hello world!' | mail -s 'test' jack@163.com
#通过python3进行邮件报警
[root@node1 ~]# cat sendmail.py
#!/usr/bin/python3
import smtplib
from email.mime.text import MIMEText
#from email.mime.multipart import MIMEMultipart
from email.header import Header

mail_host='smtp.126.com'
mail_port=25
mail_user='jack@126.com'
mail_pass='TEZVGROG'
sender = 'jacknotes@126.com'
receivers = ['jack@163.com', 'jack@126.com'] 

# 三个参数：第一个为文本内容，第二个 plain 设置文本格式，第三个 utf-8 设置编码
#message = MIMEMultipart()
#message.attach(MIMEText('Python邮件', 'plain', 'utf-8'))
message = MIMEText('Python', 'plain', 'utf-8')
message['From'] = sender    
subject = 'alert'
message['Subject'] = Header(subject, 'utf-8')
for i in range(0,len(receivers)):
    message['To'] =  receivers[i]        
    try:
        smtpObj = smtplib.SMTP()
        smtpObj.connect(mail_host, mail_port)
        smtpObj.login(mail_user, mail_pass)
        smtpObj.sendmail(sender, receivers[i], message.as_string())
        print ("发送邮件" + receivers[i] +"成功")
    except smtplib.SMTPException:
        print ("Error: 发送邮件"+ receivers[i] +"失败")

#https建立连接原理
https总的会话建立步骤:
1.tcp连接
2.建立ssl会话
https协议建立会话过程：
1.服务器端先监听在某个套接字上，例如443
2.客户端主动建立连接（TCP三次握手）
3.客户端和服务端协商其中一项相同加密算法（单项加密算法，对称加密算法，公钥加密算法）
4.服务端发送CA颁发的证书给客户端
5.客户端用存储在本地的CA自签名证书验证服务端发送过来的证书是否合格
6.客户端生成随机对称密钥，并发送一个密钥给服务端
7.客户端请求url时通过对称密钥加密，服务端通过对称密钥解密，从而形成https会话
https注意事项:
1.ssl会话只能针对ip地址进行加密，也就是多个主机名使用同一个ip地址时，只能使用一个主机名建立建立会话
2.证书签署时fqdn名称必须和虚拟主机名称一样

#/etc/sudoers
test    ALL=(ALL)       NOPASSWD: ALL,/usr/bin/passwd [A-Za-z0-9]*,!/usr/bin/passwd root,!/usr/bin/passwd,!/bin/su - root,!/bin/su root,!/bin/su -,!/bin/su,!/usr/sbin/visudo,!/usr/bin/vim /etc/sudoers
注：指令遵从'从广到细',后面会覆盖前面的指令。

#yum命令
--未安装过包命令，不安装只下载包到指定目录
yum install -y openssh-server --downloadonly --downloaddir=/download
--已安装过包命令，不安装只下载包到指定目录
yum reinstall -y openssh-server --downloadonly --downloaddir=/download
yum update openssh-server -y
yum list all | grep openssh-server
yum deplist openssh-server
yum remove openssh-server
--更新系统所有软件，也会更新系统
yum update  

#dd命令
1.1 dd测试DirectIO 
注：count: 1M=1000k=1000*1000; bs=8k表示块大小
iops——写测试 dd if=/dev/zero of=./a.dat bs=8k count=1M oflag=direct 
iops——读测试 dd if=./a.dat of=/dev/null bs=8k count=1M iflag=direct
bw——写测试 dd if=/dev/zero of=./a.dat bs=1M count=8k oflag=direct 
bw——读测试 dd if=./a.dat of=/dev/null bs=1M count=8k iflag=direct

[root@test ~]# dd if=/dev/zero of=./a.dat bs=8k count=1k oflag=direct
1024+0 records in
1024+0 records out
8388608 bytes (8.4 MB) copied, 5.45422 s, 1.5 MB/s
[root@test ~]# dd if=./a.dat of=/dev/null bs=8k count=1k iflag=direct
1024+0 records in
1024+0 records out
8388608 bytes (8.4 MB) copied, 0.503745 s, 16.7 MB/s

1.2 dd测试BufferIO
BufferIO主要出现在一些大文件读写的场景，由于使用内存做Cache所以读写性能上和DirectIO相比，
通常会高很多，尤其是读，所以这个场景下我们仅关心bw即可。
用dd测试BufferIO的写时，需要增加一个conv=fdatasync，使用该参数，在完成所有读写后会调用
一个sync确保数据全部刷到磁盘上（期间操作系统也有可能会主动flush），否则就是主要在测内存读写了；
通常conv=fdatasync更符合大文件读写的场景，所以这里以其作为参数进行测试。
另外还有一个参数是oflag=dsync，使用该参数也是走的BufferIO，但却是会在每次IO操作后都执行一个sync。

#生成随机字符串
[root@clog ~]# cat /dev/urandom | tr -dc a-zA-Z0-9 | head -c 16
gJlKo0osrUEsUPAf
#生成随机数字
[root@clog ~]# cat /dev/urandom | tr -dc 0-9 | head -c 10
8546054403
echo $RANDOM
20288

#netstat
#state status
[root@homsom-nginx-dev conf]#  netstat -tan | awk '/^tcp/{count[$NF]++} END {for (i in count) {print i,count[i]}}'
TIME_WAIT 726
CLOSE_WAIT 1
ESTABLISHED 4132
SYN_RECV 10
LISTEN 8

#192.168.13.230
#server or client
[root@homsom-nginx-dev conf]# netstat -ano | grep ESTABLISHED | wc -l
1364
#server IP
[root@homsom-nginx-dev conf]# netstat -ano | grep ESTABLISHED  | awk '{print $4}' | awk -F ':' '{count[$1]++} END{for(i in count){if(count[i] > 10){printf "%-20s%d\r\n",i,count[i]}}}'
192.168.13.230      1597
#server PORT
[root@homsom-nginx-dev conf]# netstat -ano | grep ESTABLISHED  | awk '{print $4}' | awk -F ':' '{count[$2]++} END{for(i in count){if(count[i] > 10){printf "%-20s%d\r\n",i,count[i]}}}'
80                  1445
#server query which client
[root@homsom-nginx-dev conf]# netstat -ano | egrep 'ESTABLISHED' | awk '{print $5}' | awk -F ':' '{count[$1]++} END{for(i in count){if(count[i] > 1500){printf "%-20s%d\r\n",i,count[i]}}}'
192.168.13.223      1649

#192.168.13.230
#client port listen
[root@clog ~]# netstat -ano | grep ESTABLISHED  | awk '{print $4}' | awk -F ':' '{count[$2]++} END{for(i in count){if(count[i] > 10){printf "%-20s%d\r\n",i,count[i]}}}'
6002                22
9200                926
#client ip connection
[root@clog ~]# netstat -ano | grep ESTABLISHED  | awk '{print $5}' | awk -F ':' '{count[$1]++} END{for(i in count){if(count[i] > 10){printf "%-20s%d\r\n",i,count[i]}}}'
172.17.0.21         22
172.17.0.23         1290
172.20.0.2          1295
#new
#从nginx服务器获取各种状态连接数
[root@reverse02_pro conf]# while true;do sleep 5;date;sudo netstat -tan | awk '/^tcp/{count[$NF]++} END {for (i in count) {print i,count[i]}}';echo;done
Fri Oct 29 11:28:53 CST 2021
TIME_WAIT 1338
CLOSE_WAIT 14
FIN_WAIT1 3
SYN_SENT 496
FIN_WAIT2 43
ESTABLISHED 4399
LAST_ACK 6
LISTEN 5
#从nginx服务器获取对外服务的ip:port的总连接数
[root@reverse02_pro ~]# while true;do sleep 5;date;sudo netstat -ano  | grep ESTABLISHED  | awk '{print $4}' | awk -F ':' '{count[$1,":",$2]++} END{for(i in count){if(count[i] > 2){printf "%-40s%d\r\n",i,count[i]}}}';echo;done
Fri Oct 29 11:28:53 CST 2021
192.168.13.207:80                     1643
192.168.13.207:443                    1241
#从nginx服务器获取连接外部服务的ip:port的总连接数
[root@reverse02_pro ~]# while true;do sleep 5;date;sudo netstat -ano  | grep ESTABLISHED  | awk '{print $5}' | awk -F ':' '{count[$1,":",$2]++} END{for(i in count){if(count[i] > 2){printf "%-40s%d\r\n",i,count[i]}}}';echo;done
Fri Oct 29 11:28:57 CST 2021
192.168.13.238:9000                   14
192.168.13.239:12270                  581
192.168.13.239:9000                   510
192.168.13.238:12270                  579
#从nginx服务器获取跟外部服务主动建立的ip:port的总排队数
[root@reverse02_pro ~]# while true;do sleep 5;date;sudo netstat -ano  | grep SYN_SENT | awk '{print $5}' | awk -F ':' '{count[$1,":",$2]++} END{for(i in count){if(count[i] > 10){printf "%-40s%d\r\n",i,count[i]}}}';echo;done

#问题：在nginx服务器上看到目标地址是192.168.13.239:9000(容器宿主机)，为什么在192.168.13.239docker宿主机上看不到ESTABLISHED状态连接？
因为目标端口是通过iptables规则重定向到容器端口，所以ESTABLISHED状态连接应该建立在容器上，应该去容器上看，但大部分容器是精简版，所以无法查看，只能通过其它方式佐证，如tcpdump。
#目标服务器上抓包看是否有真实连接
[root@docker02 download]# tcpdump -vvvnnn -i eth0 ip src 192.168.13.218 and tcp dst port 9000
#使用名称空间程序进行查看
----
#! /bin/bash
echo $1
PID=$(docker inspect -f '{{.State.Pid}}' $1)
nsenter -t $PID -n netstat -ano |grep ESTABLISHED
-----
[ops0799@docker01 ~]$ sudo docker inspect -f '{{.State.Pid}}' pro-hotelresourcemeituan
10285
[ops0799@docker01 ~]$ sudo nsenter -t 10285  -n netstat -ano | grep ESTABLISHEDS
注：指令注解
nsenter：命令(namespace enter)
-t: 从目标进程获取名称空间
-n: 进入网络名称空间
netstat -ano | grep ESTABLISHEDS：表示执行的网络命令
#批量获取容器网络连接状态
for i in `docker ps -a | awk '{print $NF}' | grep -v NAMES`;do ./nsenter.sh $i ESTABLISHED >> ./nsenter-docker.log;done
#获取pid的容器名称
[root@fatserver ~]# for i in `docker ps -a | grep -v CONTAINER | awk '{print $NF}'`;do a=`docker inspect -f {{.State.Pid}} $i`; if [ $a == 16861 ];then echo $i;else continue;fi ;done



#docker格式化输出
#数据挂载信息
[root@test ~]# docker inspect 7042bac0e964 -f '数据挂载信息:{{println}}{{range .Mounts}}{{.Source}}:{{.Destination}}{{println}}{{end}}'
数据挂载信息:
/data/elk/nginx/default.conf:/etc/nginx/conf.d/default.conf
/data/elk/nginx/.login.txt:/etc/nginx/.login.txt
#IP信息
[root@clog ~]# docker inspect --format 'Hostname:{{ .Config.Hostname }}  Name:{{.Name}} IP:{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' $(docker ps -q)
Hostname:1e9276038de3  Name:/fat-hotelresourcemeituan IP:172.17.0.40 
Hostname:196f64418ba7  Name:/fat-travelreportservice IP:172.17.0.31 
Hostname:ac1f389b40e4  Name:/fat-hotelresourceyaduo IP:172.17.0.33 
Hostname:0fccc8b7c265  Name:/fat-hotelresource IP:172.17.0.18 
Hostname:148ac5a0544e  Name:/fat-dataconversionervice IP:172.17.0.38 
Hostname:26948c784e68  Name:/fat_integrateapi IP:172.17.0.25 
Hostname:6aa36fb42057  Name:/fat-hotelresourcehsziyou IP:172.17.0.35 
Hostname:429ed931332a  Name:/uat_integrateapi IP:172.17.0.39 
Hostname:fc7419447896  Name:/fat-hotelresourceyouyou IP:172.17.0.30 
Hostname:d5b111e12462  Name:/fat_protocol IP:172.17.0.32 
Hostname:fae784890f94  Name:/fat-hotelresourcemanager IP:172.17.0.36 
Hostname:39c136d94c7a  Name:/fat-identitysource IP:172.17.0.5 
Hostname:d8b4a4d8de6c  Name:/fat-hotelresourcetepai IP:172.17.0.34 
Hostname:b96362855b5f  Name:/fat-homsompayapi IP:172.17.0.4 
Hostname:7ed5bbd3924a  Name:/fat-bussinesslog IP:172.17.0.37 
Hostname:42fde26b934f  Name:/fat_carbusinessapi IP:172.17.0.14 
Hostname:ea3bfe17f21d  Name:/fat_carserviceapi IP:172.17.0.13 
Hostname:420efe622a11  Name:/fat_carresourceapi IP:172.17.0.6 
Hostname:a32f15a1199f  Name:/fat_domaineventserviceapi IP:172.17.0.24 
Hostname:6f2ebfb72d1b  Name:/fat-systemintergrationmvc IP:172.17.0.26 
Hostname:b187a406c68d  Name:/fat-systemintergration IP:172.17.0.8 
Hostname:d6d6da9abe76  Name:/uat_carserviceapi IP:172.17.0.29 
Hostname:91e5fe26a882  Name:/uat_carbusinessapi IP:172.17.0.28 
Hostname:c67b32ac520a  Name:/uat_carresourceapi IP:172.17.0.27 
Hostname:0463f78ec380  Name:/bill_api_13 IP:172.17.0.7 
Hostname:00a9f787b151  Name:/uat_bill_api_12 IP:172.17.0.9 
Hostname:fba471457747  Name:/uat-identitysource IP:172.17.0.10 
Hostname:694d61d7d43d  Name:/fat_toc_service_15 IP:172.17.0.11 
Hostname:05ca3772a667  Name:/fat_toc_api_15 IP:172.17.0.12 
Hostname:ddb9a03a820e  Name:/fat_toc_login_12_1 IP:172.17.0.15 
Hostname:c02428b8a187  Name:/cadvisor IP:172.17.0.16 
Hostname:f998f7cfea6f  Name:/uat_flightmanagerapi_1_1 IP:172.17.0.17 
Hostname:8ead940c014e  Name:/mysql IP:172.17.0.19 
Hostname:763b77c5dd39  Name:/clever_poincare IP:172.17.0.20 
Hostname:3adf239271c5  Name:/fat_rabbitmq IP:172.17.0.3 
Hostname:5c8f211ba91f  Name:/uat_rabbitmq IP:172.17.0.2 
Hostname:a2bd7e732bfc  Name:/fat-redis IP:172.17.0.21 172.18.0.2 
Hostname:de656e916c5b  Name:/uat-redis IP:172.17.0.22 172.18.0.3 
Hostname:b3ffa92cc37c  Name:/elk IP:172.17.0.23 172.20.0.3 

#端口信息
[root@clog ~]#  docker inspect --format '{{/*通过变量组合展示容器绑定端口列表*/}}已绑定端口列表：{{println}}{{range $p,$conf := .NetworkSettings.Ports}}{{$p}} -> {{range $conf}}{{.HostIP}}:{{.HostPort}}{{end}}{{println}}{{end}}' b3ffa92cc37c
\已绑定端口列表：
5044/tcp -> 0.0.0.0:5044
5601/tcp -> 0.0.0.0:80
9200/tcp -> 0.0.0.0:9200
9300/tcp -> 0.0.0.0:9300

#总信息
[root@clog ~]# docker inspect --format '{{/*ContainerName,HostName,ip,DataMountFiles,Port*/}}ContainerName:{{.Name}}    Hostname:{{ .Config.Hostname }}    IP:{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}{{println}}DataMountFiles:{{println}}{{range .Mounts}}{{.Source}}:{{.Destination}}{{println}}{{end}}{{println}}Port: {{println}}{{range $p,$conf := .NetworkSettings.Ports}}{{$p}} -> {{range $conf}}{{.HostIP}}:{{.HostPort}}{{end}}{{println}}{{end}}' `docker ps -aq`
ContainerName:/fat-hotelresourcemeituan    Hostname:1e9276038de3    IP:172.17.0.40
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12180

ContainerName:/fat-travelreportservice    Hostname:196f64418ba7    IP:172.17.0.31
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12150

ContainerName:/fat-hotelresourceyaduo    Hostname:ac1f389b40e4    IP:172.17.0.33
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12140

ContainerName:/fat-hotelresource    Hostname:0fccc8b7c265    IP:172.17.0.18
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12100

ContainerName:/fat-dataconversionervice    Hostname:148ac5a0544e    IP:172.17.0.38
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12160

ContainerName:/fat_integrateapi    Hostname:26948c784e68    IP:172.17.0.25
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12190

ContainerName:/fat-hotelresourcehsziyou    Hostname:6aa36fb42057    IP:172.17.0.35
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12200

ContainerName:/uat_integrateapi    Hostname:429ed931332a    IP:172.17.0.39
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12191

ContainerName:/fat-hotelresourceyouyou    Hostname:fc7419447896    IP:172.17.0.30
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12120

ContainerName:/fat_protocol    Hostname:d5b111e12462    IP:172.17.0.32
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12130

ContainerName:/fat-hotelresourcemanager    Hostname:fae784890f94    IP:172.17.0.36
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12110

ContainerName:/fat-identitysource    Hostname:39c136d94c7a    IP:172.17.0.5
DataMountFiles:

Port: 
8083/tcp -> 0.0.0.0:11990

ContainerName:/fat-hotelresourcetepai    Hostname:d8b4a4d8de6c    IP:172.17.0.34
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12170

ContainerName:/fat-homsompayapi    Hostname:b96362855b5f    IP:172.17.0.4
DataMountFiles:

Port: 
12000/tcp -> 0.0.0.0:12000

ContainerName:/fat-bussinesslog    Hostname:7ed5bbd3924a    IP:172.17.0.37
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:8091

ContainerName:/fat_carbusinessapi    Hostname:42fde26b934f    IP:172.17.0.14
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12060

ContainerName:/fat_carserviceapi    Hostname:ea3bfe17f21d    IP:172.17.0.13
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12050

ContainerName:/fat_carresourceapi    Hostname:420efe622a11    IP:172.17.0.6
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12070

ContainerName:/fat_domaineventserviceapi    Hostname:a32f15a1199f    IP:172.17.0.24
DataMountFiles:

Port: 
80/tcp -> 0.0.0.0:12090

ContainerName:/fat-systemintergrationmvc    Hostname:6f2ebfb72d1b    IP:172.17.0.26
DataMountFiles:

Port: 
8989/tcp -> 0.0.0.0:8989

ContainerName:/fat-systemintergration    Hostname:b187a406c68d    IP:172.17.0.8
DataMountFiles:

Port: 
80/tcp -> 
8999/tcp -> 0.0.0.0:8999

ContainerName:/uat_carserviceapi    Hostname:d6d6da9abe76    IP:172.17.0.29
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12051

ContainerName:/uat_carbusinessapi    Hostname:91e5fe26a882    IP:172.17.0.28
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12061

ContainerName:/uat_carresourceapi    Hostname:c67b32ac520a    IP:172.17.0.27
DataMountFiles:

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:12071

ContainerName:/bill_api_13    Hostname:0463f78ec380    IP:172.17.0.7
DataMountFiles:
/etc/localtime:/etc/localtime

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:11980

ContainerName:/uat_bill_api_12    Hostname:00a9f787b151    IP:172.17.0.9
DataMountFiles:
/etc/localtime:/etc/localtime

Port: 
443/tcp -> 
80/tcp -> 0.0.0.0:11981

ContainerName:/uat-identitysource    Hostname:fba471457747    IP:172.17.0.10
DataMountFiles:

Port: 
8083/tcp -> 0.0.0.0:11991

ContainerName:/fat_toc_service_15    Hostname:694d61d7d43d    IP:172.17.0.11
DataMountFiles:
/etc/localtime:/etc/localtime

Port: 
80/tcp -> 0.0.0.0:10880

ContainerName:/fat_toc_api_15    Hostname:05ca3772a667    IP:172.17.0.12
DataMountFiles:
/etc/localtime:/etc/localtime

Port: 
80/tcp -> 0.0.0.0:10890

ContainerName:/es_test01    Hostname:28cf2149b64a    IP:
DataMountFiles:
/home/docker/lib/volumes/497d03dba140237d49b43e0b28955053f218cc9524a00e5f72c5f7a493cf818b/_data:/var/lib/elasticsearch

Port: 

ContainerName:/es_test02    Hostname:95abf386d6c9    IP:
DataMountFiles:
/home/docker/lib/volumes/56e34dacab279356fdb4d9aedff406c9d966fbc15fd47be00a4b0536a5ccda49/_data:/var/lib/elasticsearch

Port: 

ContainerName:/fat_toc_login_12_1    Hostname:ddb9a03a820e    IP:172.17.0.15
DataMountFiles:
/etc/localtime:/etc/localtime

Port: 
80/tcp -> 0.0.0.0:10900

ContainerName:/cadvisor    Hostname:c02428b8a187    IP:172.17.0.16
DataMountFiles:
/dev/disk:/dev/disk
/:/rootfs
/sys:/sys
/var/lib/docker:/var/lib/docker
/var/run:/var/run

Port: 
8080/tcp -> 0.0.0.0:8080

ContainerName:/uat_flightmanagerapi_1_1    Hostname:f998f7cfea6f    IP:172.17.0.17
DataMountFiles:
/etc/localtime:/etc/localtime

Port: 
80/tcp -> 0.0.0.0:14334

ContainerName:/mysql    Hostname:8ead940c014e    IP:172.17.0.19
DataMountFiles:
/home/docker/data:/var/lib/mysql

Port: 
3306/tcp -> 0.0.0.0:3306
33060/tcp -> 

ContainerName:/fat-systemlog    Hostname:42568a9e78ba    IP:
DataMountFiles:
/config/systemlog/fat/appsettings.json:/app/appsettings.json

Port: 

ContainerName:/clever_poincare    Hostname:763b77c5dd39    IP:172.17.0.20
DataMountFiles:
/home/docker/lib/volumes/fe863cbfa51d0bb9e9b805704fab20d1d25b81faa56843886e2cf3b65e262726/_data:/data

Port: 
6379/tcp -> 0.0.0.0:6009

ContainerName:/fat_rabbitmq    Hostname:3adf239271c5    IP:172.17.0.3
DataMountFiles:
/usr/local/rabbitmq1:/var/lib/rabbitmq

Port: 
15671/tcp -> 
15672/tcp -> 0.0.0.0:8002
25672/tcp -> 0.0.0.0:25682
4369/tcp -> 0.0.0.0:4379
5671/tcp -> 
5672/tcp -> 0.0.0.0:5682

ContainerName:/uat_rabbitmq    Hostname:5c8f211ba91f    IP:172.17.0.2
DataMountFiles:
/usr/local/rabbitmq2:/var/lib/rabbitmq

Port: 
15671/tcp -> 
15672/tcp -> 0.0.0.0:8001
25672/tcp -> 0.0.0.0:25672
4369/tcp -> 0.0.0.0:4369
5671/tcp -> 
5672/tcp -> 0.0.0.0:5672

ContainerName:/fat-redis    Hostname:a2bd7e732bfc    IP:172.17.0.21172.18.0.2
DataMountFiles:
/home/redis/fat/conf:/etc/redis/redis.conf
/home/redis/fat/data:/data

Port: 
6379/tcp -> 0.0.0.0:6002

ContainerName:/uat-redis    Hostname:de656e916c5b    IP:172.17.0.22172.18.0.3
DataMountFiles:
/home/redis/uat/conf/uat/data:/data
/home/redis/uat/conf/uat/conf:/etc/redis/redis.conf

Port: 
6379/tcp -> 0.0.0.0:6001

ContainerName:/elk    Hostname:b3ffa92cc37c    IP:172.17.0.23172.20.0.3
DataMountFiles:
/home/docker_files:/home/docker_files
/home/docker/lib/volumes/5909409d0f4b665015cc677ba2935a6ec1995c2edcce9359741912030ccf1ac1/_data:/var/lib/elasticsearch

Port: 
5044/tcp -> 0.0.0.0:5044
5601/tcp -> 0.0.0.0:80
9200/tcp -> 0.0.0.0:9200
9300/tcp -> 0.0.0.0:9300


# 获取nginx访问远程地址连接数
[root@reverse01 ~]# while true;do sleep 5;date;sudo netstat -ano  | grep ESTABLISHED  | awk '{print $5}' | awk -F ':' '{count[$1,":",$2]++} END{for(i in count){if(count[i] > 2){printf "%-40s%d\r\n",i,count[i]}}}';echo;done
Mon Feb 13 15:50:12 CST 2023
192.168.13.238:9000                   357
192.168.13.233:80                     4
192.168.13.182:80                     3
192.168.13.239:9000                   457
192.168.13.239:12270                  401
192.168.13.31:6443                    3
192.168.13.229:80                     3
192.168.13.238:12270                  400
# 查看docker服务连接数
-- docker server, example 12270
[root@docker01 ~]# nsenter -t $(docker inspect `docker ps -a | grep :12270 | awk '{print $NF}'` | jq '.[0].State.Pid ') -n netstat -tan | awk '/^tcp/{count[$NF]++} END {for (i in count) {print i,count[i]}}' 
LISTEN 1
CLOSE_WAIT 2
ESTABLISHED 743
TIME_WAIT 5400

# 以端口查询全部docker服务连接数
CONTAINER_PORT=`sudo docker ps -a  | awk '{print $(NF-1)}' | awk -F':' '{print $2}' | awk -F'->' '{print $1}' | grep -v '^\s*$'`
for i in $CONTAINER_PORT;do echo "CONTAINER_PORT: ${i}";sudo nsenter -t $(sudo docker inspect `sudo docker ps -a | grep :${i} | awk '{print $NF}'` | jq '.[0].State.Pid ') -n netstat -tan | awk '/^tcp/{count[$NF]++} END {for (i in count) {print i,count[i]}}'; echo -e '\n';done

## 以端口查询全部docker服务连接数-格式化输出 
# 1
CONTAINER_PORT=`sudo docker ps -a  | awk '{print $(NF-1)}' | awk -F':' '{print $2}' | awk -F'->' '{print $1}' | grep -v '^\s*$'`
# 2
for i in $CONTAINER_PORT;do echo "CONTAINER_PORT: ${i}";sudo nsenter -t $(sudo docker inspect `sudo docker ps -a | grep :${i} | awk '{print $NF}'` | jq '.[0].State.Pid ') -n netstat -tan | awk '/^tcp/{count[$NF]++} END {for (i in count) {print i,count[i]}}'; echo -e '\n';done > /tmp/container_port.txt
# 3
sed -n '/^CONTAINER_PORT/{:a;N;/TIME_WAIT/!ba;s/\n/ /g;p}' /tmp/container_port.txt
```
1. 匹配CONTAINER_PORT开关的行
2. 执行{}里面的操作
3. :a; 定义标签a，用于跳转
4. N; 一直读取下一行文本，并将其追加到当前行的末尾
5. /TIME_WAIT/!ba; 直到匹配到TIME_WAIT行，则跳转到标签a
6. s/\n/ /g; 将换行符替换成空格符
7. p 打印结果
```









#容器运行状态
[root@uat-redis ~]# docker inspect --format '{{if ne 0 .State.ExitCode}}容器{{.Name}}是停止的{{else}}容器{{.Name}}是运行的{{end}}' `docker ps -qa`
容器/fat_hotelresourcehuazhu是运行的
容器/fat_abservice是运行的

[root@harbor ~]#  docker inspect --format '{{if eq .HostConfig.RestartPolicy.Name "no"}}容器{{.Name}}没有重启策略{{else}}容器{{.Name}}有重启策略{{end}}' `docker ps -qa`
容器/zabbix-web-nginx-mysql有重启策略
容器/zabbix-server-mysql有重启策略
容器/hsredis没有重启策略


#获取容器关键信息--20221208
[root@docker01 ~]# docker inspect -f 'HostName:{{.Config.Hostname}} Name:{{.Name}} RestartPolicy:{{.HostConfig.RestartPolicy.Name}}{{println}}ContainerIP:{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}{{println}}Ports:{{println}}{{range $k,$v := .NetworkSettings.Ports}}  {{$k}} -> {{range $v}}{{.HostIp}}:{{.HostPort}}{{end}}{{println}}{{end}}{{/*date mount*/}}DataMount:{{println}}{{range .Mounts}}  {{.Source}}:{{.Destination}}{{println}}{{end}}' `docker ps -qa`
HostName:8cd00684eb19 Name:/pro_hoteloperation RestartPolicy:no
ContainerIP:172.17.0.27
Ports:
  80/tcp -> 0.0.0.0:12460
DataMount:

HostName:3f99b6adf207 Name:/elk RestartPolicy:always
ContainerIP:172.17.0.8
Ports:
  5044/tcp -> 0.0.0.0:5044
  5601/tcp -> 0.0.0.0:80
  9200/tcp -> 0.0.0.0:9200
  9300/tcp -> 0.0.0.0:9300
DataMount:
  /home/docker_files:/home/docker_files
  /home/var/lib/docker/volumes/18917e959ccedd96cb7f3641ea229454bcd7cf0e0b104f49845856f2752e2dfe/_data:/var/lib/elasticsearch





#iperf3 ----测试客户端到服务端的网速
#例子：测试sslvpn之间的网速是多少
#工作在server模式
[root@nginx ~]# iperf3 -s  
#工作在client模式，连接服务器ip，间隔为1秒，持续时间为10秒
[root@prometheus ~]# iperf3 -c 10.10.10.240 -i 1 -t 10
Connecting to host 10.10.10.240, port 5201
[  4] local 192.168.177.178 port 31819 connected to 10.10.10.240 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  12.2 MBytes   102 Mbits/sec   26    161 KBytes       
[  4]   1.00-2.00   sec  17.1 MBytes   143 Mbits/sec   34    174 KBytes       
[  4]   2.00-3.00   sec  12.4 MBytes   104 Mbits/sec    0    220 KBytes       
[  4]   3.00-4.00   sec  12.8 MBytes   107 Mbits/sec    0    258 KBytes       
[  4]   4.00-5.00   sec  12.6 MBytes   106 Mbits/sec    0    291 KBytes       
[  4]   5.00-6.00   sec  12.7 MBytes   106 Mbits/sec    0    320 KBytes       
[  4]   6.00-7.00   sec  12.5 MBytes   105 Mbits/sec    0    348 KBytes       
[  4]   7.00-8.00   sec  12.4 MBytes   104 Mbits/sec    0    372 KBytes       
[  4]   8.00-9.00   sec  12.6 MBytes   106 Mbits/sec    0    396 KBytes       
[  4]   9.00-10.00  sec  12.6 MBytes   106 Mbits/sec    0    418 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec   130 MBytes   109 Mbits/sec   60             sender
[  4]   0.00-10.00  sec   129 MBytes   108 Mbits/sec                  receiver


#openssl--20210326
------------------------------------
###Openssl命令详解

ot@salt ~/custom_pki]# echo hehe > 123.log
[root@salt ~/custom_pki]# cat 123.log 
hehe
[root@salt ~/custom_pki]# openssl rsautl -encrypt -in 123.log -inkey jack.crt -pubin -out 123.en
[root@salt ~/custom_pki]# file 123.en
123.en: data
[root@salt ~/custom_pki]# file 123.log
123.log: ASCII text
[root@salt ~/custom_pki]# openssl rsautl -decrypt -in 123.en -inkey jack.key -out hello.log
[root@salt ~/custom_pki]# cat hello.log 
hehe
[root@salt ~/custom_pki]# file hello.log
hello.log: ASCII text
注：
rsautl：加解密
encrypt：加密
decrypt：解密
in：从文件输入
out：输出到文件
inkey：输入的密钥
pubin：表名输入是公钥文件，对inkey参数的补充

1、对称加密算法的应用
1.1 加解密字符串
[root@salt ~]# echo 'hehe' | openssl enc -e -aes128 -a -salt  --加密
enter aes-128-cbc encryption password:
Verifying - enter aes-128-cbc encryption password:
U2FsdGVkX1/zO05l+efEGO8Y4fFTGUuqvZwMdmH5j6Q=
注：密码是123
[root@salt ~]# echo 'U2FsdGVkX1/zO05l+efEGO8Y4fFTGUuqvZwMdmH5j6Q=' | openssl enc -d -aes128 -a -salt   --解密
enter aes-128-cbc decryption password:              --输入密码123
hehe
注：
-e：加密；
-d：解密；
-ciphername：ciphername为相应的对称加密算命名字，如-des3、-ase128、-cast、-blowfish等等。
-a/-base64：使用base-64位编码格式；
-salt：自动插入一个随机数作为文件内容加密，默认选项；
-in FILENAME：指定要加密的文件的存放路径；
-out FILENAME：指定加密后的文件的存放路径；

1.2 加解密文件 
[root@salt ~]# openssl enc -e -des3 -a -salt -in /etc/fstab -out /tmp/fstab   --加密
enter des-ede3-cbc encryption password:
Verifying - enter des-ede3-cbc encryption password:
注：密码是123
[root@salt ~]# cat /tmp/fstab
U2FsdGVkX1/2HLUjXMoESbuO63KgsqfN7ef/HK3qZ++h8n9NgcipP6Db3xZ0+sCk
AG9GvXWc9OXj04ieHRLZflBZiqMyOmEg7xgb2kJESoRXd3Ep1gsKIBf97y9Awn4H
+vARkXPDzQHvcaNZdmgYB1pdTfMsxBW8+eCqZu07bDjUQXV/ylBAVK80DktUtE+a
JT96sy8GhaPGSYQeE1Itb7hC/REnkXQwksoPCEgS0mYQakPtCn+2vUpFQQtzqcoR
JbeWaAdGWfJSUv7vHtOr4q5jB7mo5K9kuIMZfsgRpyosqoINNoF2rKd3S1y+gUSB
COJ2tiu/GAfxD2ypgjK/2c/Ut6125GRGVdMz/fEslWeV3LD2TEw2jUYo3Zz/+IB7
dvjtbC+2xNlZiMTz9Ty+FoJHXAe5DVc5Qz1u2plYQsY2uuHZ5D7RZaQqKMAjTyx8
o7wq9eVrmA1GM5f1EvGUNtqhPeW3pmhslCpJ8rQcQuZF8B9mbY4deRfFky/57q8R
AnB+UG7GtcVh+dDHxqruRlgqdbmYT+/EFGdKzqs1ny5QYskkGjqiNg9vSXC0NnEH
s03dYtTPE/ly8kbJTQGKfAb7bJ+WkmBv
[root@salt ~]# openssl enc -d -des3 -a -salt -in /tmp/fstab   --解密
enter des-ede3-cbc decryption password:
#
# /etc/fstab
# Created by anaconda on Thu May  7 13:47:22 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=edc201ea-e85e-4be3-9bc4-7c5352dceff8 /                       xfs     defaults        0 0
UUID=64103399-5b6f-4fa1-91f8-09c86abd55a9 /boot                   xfs     defaults        0 0
/swap swap swap defaults 0 0

2、单向加密
[root@salt ~]# echo 'hehe' | openssl dgst -md5 
(stdin)= e4439267203fb5277d347e6cd6e440b5
[root@salt ~]# echo 'hehe' | md5sum 
e4439267203fb5277d347e6cd6e440b5  -
[root@salt ~]# openssl dgst -md5 /etc/fstab 
MD5(/etc/fstab)= 7c7f5f4c652d75674379f4b2db0a9fbb
[root@salt ~]# md5sum  /etc/fstab 
7c7f5f4c652d75674379f4b2db0a9fbb  /etc/fstab
注：单向加密除了 openssl dgst 工具还有： md5sum，sha1sum，sha224sum，sha256sum ，sha384sum，sha512sum

3、加密密码
[root@salt ~]# openssl passwd -1 -salt jack homsom
$1$jack$OtcWQG8etMN2t3PkktQzG/
注：-1：基于md5的密码算法，-salt: 是加盐jack，homsom是密码
[root@salt ~]# openssl passwd -apr1 -salt jack homsom
$apr1$jack$NGrjAE0AmBNgSKmx47yC/1
注：-apr1：基于md5的密码算法，是apache的变体

4、生成随机数
[root@salt ~]# openssl rand -hex 10
efd0ef257ce9704d1004
[root@salt ~]# openssl rand -base64 10
5Fq8tY5fktWkSQ==
注：-hex：表示十六进制，-base64：表示base64编码

5、生成密钥对
[root@salt ~/custom_pki]# (umask 077; openssl genrsa -out one.key 1024)
Generating RSA private key, 1024 bit long modulus
...................++++++
...............++++++
e is 65537 (0x10001)
--生成公钥
[root@salt ~/custom_pki]# openssl rsa -in one.key -pubout -out ./one.crt  
writing RSA key
[root@salt ~/custom_pki]# cat ./one.crt
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHBN+Wtwe4GCkfjKrivh2hUvjX
WWXtBdSXgyHTW7zdG3hnoi3h/DCzunSRGvi1ren6btjc3xaz85nooJoK61qkx9xq
iGfRb9rDT230ckjFvPkbm89rl3FjFRluIMPaqPk4RGl6xyldU+1DbmZVJ4udWNPB
GTX2iwb8vS+hRWRlEQIDAQAB
-----END PUBLIC KEY-----
注：-in：表示输出的文件，-pubout：表示输出公钥，-out：表示输出到哪


#6、CA证书中心
--配置CA环境，从/etc/pki/tls/openssl.cnf看出CA环境
[root@salt /etc/pki/CA]# touch index.txt serial
[root@salt /etc/pki/CA]# echo 01 > serial
--生成CA私钥
[root@salt /etc/pki/CA]# (umask 077;openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096)
--生成自签名CA公钥
[root@salt /etc/pki/CA]# openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:hs
Organizational Unit Name (eg, section) []:ops
Common Name (eg, your name or your server's hostname) []:ca.hs.com
Email Address []:
注：
req: 代表请求命令
-new: 表示新的请求
-x509: 表示自签名证书
-key: 表示输入私钥
-out: 表示公钥存放的目录及名称
-days：有效期

#服务器
--生成服务器私钥
[root@tengine ~/custom_cert]# (umask 077;openssl genrsa -out jumpserver.key 4096)
--生成证书签署请求csr(Certificate Singning Request)
[root@tengine ~/custom_cert]# openssl req -new -key jumpserver.key -out jumpserver.csr -days 3650
You are about to be asked to enter information that will be incorporated
into your
------------------------------------
###Openssl命令详解
1、对称加密算法的应用
1.1 加解密字符串
[root@salt ~]# echo 'hehe' | openssl enc -e -aes128 -a -salt  --加密
enter aes-128-cbc encryption password:
Verifying - enter aes-128-cbc encryption password:
U2FsdGVkX1/zO05l+efEGO8Y4fFTGUuqvZwMdmH5j6Q=
注：密码是123
[root@salt ~]# echo 'U2FsdGVkX1/zO05l+efEGO8Y4fFTGUuqvZwMdmH5j6Q=' | openssl enc -d -aes128 -a -salt   --解密
enter aes-128-cbc decryption password:              --输入密码123
hehe
注：
-e：加密；
-d：解密；
-ciphername：ciphername为相应的对称加密算命名字，如-des3、-ase128、-cast、-blowfish等等。
-a/-base64：使用base-64位编码格式；
-salt：自动插入一个随机数作为文件内容加密，默认选项；
-in FILENAME：指定要加密的文件的存放路径；
-out FILENAME：指定加密后的文件的存放路径；

1.2 加解密文件 
[root@salt ~]# openssl enc -e -des3 -a -salt -in /etc/fstab -out /tmp/fstab   --加密
enter des-ede3-cbc encryption password:
Verifying - enter des-ede3-cbc encryption password:
注：密码是123
[root@salt ~]# cat /tmp/fstab
U2FsdGVkX1/2HLUjXMoESbuO63KgsqfN7ef/HK3qZ++h8n9NgcipP6Db3xZ0+sCk
AG9GvXWc9OXj04ieHRLZflBZiqMyOmEg7xgb2kJESoRXd3Ep1gsKIBf97y9Awn4H
+vARkXPDzQHvcaNZdmgYB1pdTfMsxBW8+eCqZu07bDjUQXV/ylBAVK80DktUtE+a
JT96sy8GhaPGSYQeE1Itb7hC/REnkXQwksoPCEgS0mYQakPtCn+2vUpFQQtzqcoR
JbeWaAdGWfJSUv7vHtOr4q5jB7mo5K9kuIMZfsgRpyosqoINNoF2rKd3S1y+gUSB
COJ2tiu/GAfxD2ypgjK/2c/Ut6125GRGVdMz/fEslWeV3LD2TEw2jUYo3Zz/+IB7
dvjtbC+2xNlZiMTz9Ty+FoJHXAe5DVc5Qz1u2plYQsY2uuHZ5D7RZaQqKMAjTyx8
o7wq9eVrmA1GM5f1EvGUNtqhPeW3pmhslCpJ8rQcQuZF8B9mbY4deRfFky/57q8R
AnB+UG7GtcVh+dDHxqruRlgqdbmYT+/EFGdKzqs1ny5QYskkGjqiNg9vSXC0NnEH
s03dYtTPE/ly8kbJTQGKfAb7bJ+WkmBv
[root@salt ~]# openssl enc -d -des3 -a -salt -in /tmp/fstab   --解密
enter des-ede3-cbc decryption password:
#
# /etc/fstab
# Created by anaconda on Thu May  7 13:47:22 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=edc201ea-e85e-4be3-9bc4-7c5352dceff8 /                       xfs     defaults        0 0
UUID=64103399-5b6f-4fa1-91f8-09c86abd55a9 /boot                   xfs     defaults        0 0
/swap swap swap defaults 0 0

2、单向加密
[root@salt ~]# echo 'hehe' | openssl dgst -md5 
(stdin)= e4439267203fb5277d347e6cd6e440b5
[root@salt ~]# echo 'hehe' | md5sum 
e4439267203fb5277d347e6cd6e440b5  -
[root@salt ~]# openssl dgst -md5 /etc/fstab 
MD5(/etc/fstab)= 7c7f5f4c652d75674379f4b2db0a9fbb
[root@salt ~]# md5sum  /etc/fstab 
7c7f5f4c652d75674379f4b2db0a9fbb  /etc/fstab
注：单向加密除了 openssl dgst 工具还有： md5sum，sha1sum，sha224sum，sha256sum ，sha384sum，sha512sum

3、加密密码
[root@salt ~]# openssl passwd -1 -salt jack homsom
$1$jack$OtcWQG8etMN2t3PkktQzG/
注：-1：基于md5的密码算法，-salt: 是加盐jack，homsom是密码
[root@salt ~]# openssl passwd -apr1 -salt jack homsom
$apr1$jack$NGrjAE0AmBNgSKmx47yC/1
注：-apr1：基于md5的密码算法，是apache的变体

4、生成随机数
[root@salt ~]# openssl rand -hex 10
efd0ef257ce9704d1004
[root@salt ~]# openssl rand -base64 10
5Fq8tY5fktWkSQ==
注：-hex：表示十六进制，-base64：表示base64编码

5、生成密钥对
[root@salt ~/custom_pki]# (umask 077; openssl genrsa -out one.key 1024)
Generating RSA private key, 1024 bit long modulus
...................++++++
...............++++++
e is 65537 (0x10001)
--生成公钥
[root@salt ~/custom_pki]# openssl rsa -in one.key -pubout -out ./one.crt  
writing RSA key
[root@salt ~/custom_pki]# cat ./one.crt
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDHBN+Wtwe4GCkfjKrivh2hUvjX
WWXtBdSXgyHTW7zdG3hnoi3h/DCzunSRGvi1ren6btjc3xaz85nooJoK61qkx9xq
iGfRb9rDT230ckjFvPkbm89rl3FjFRluIMPaqPk4RGl6xyldU+1DbmZVJ4udWNPB
GTX2iwb8vS+hRWRlEQIDAQAB
-----END PUBLIC KEY-----
注：-in：表示输出的文件，-pubout：表示输出公钥，-out：表示输出到哪


#6、CA证书中心
--配置CA环境，从/etc/pki/tls/openssl.cnf看出CA环境
[root@salt /etc/pki/CA]# touch index.txt serial
[root@salt /etc/pki/CA]# echo 01 > serial
--生成CA私钥
[root@salt /etc/pki/CA]# (umask 077;openssl genrsa -out /etc/pki/CA/private/cakey.pem 4096)
--生成自签名CA公钥
[root@salt /etc/pki/CA]# openssl req -new -x509 -key /etc/pki/CA/private/cakey.pem -out /etc/pki/CA/cacert.pem -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:hs
Organizational Unit Name (eg, section) []:ops
Common Name (eg, your name or your server's hostname) []:ca.hs.com
Email Address []:
注：
req: 代表请求命令
-new: 表示新的请求
-x509: 表示自签名证书
-key: 表示输入私钥
-out: 表示公钥存放的目录及名称
-days：有效期

#服务器
--生成服务器私钥
[root@tengine ~/custom_cert]# (umask 077;openssl genrsa -out jumpserver.key 4096)
--生成证书签署请求csr(Certificate Singning Request)
[root@tengine ~/custom_cert]# openssl req -new -key jumpserver.key -out jumpserver.csr -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Shanghai
Locality Name (eg, city) [Default City]:Shanghai
Organization Name (eg, company) [Default Company Ltd]:hs
Organizational Unit Name (eg, section) []:ops
Common Name (eg, your name or your server's hostname) []:jumpserver.hs.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
注：
Country Name: 表示国家名称
State or Province Name：表示省份名称
Locality Name (eg, city)：表示城市名称
Organization Name (eg, company) ：表示公司名称
Organizational Unit Name (eg, section)：表示组织单位名称
Common Name (eg, your name or your server's hostname)：表示主机名称，这个必须跟服务器主机名称一样，可以是*.hs.com

#CA签署证书流程
--把服务器证书签署请求发送给CA，让CA签署
[root@tengine ~/custom_cert]# scp jumpserver.csr root@CA.hs.com:~
--CA签署证书
[root@salt /etc/pki/CA]# openssl ca -in /root/jumpserver.csr -out /root/jumpserver.crt -days 3650
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Mar  5 02:42:23 2021 GMT
            Not After : Mar  3 02:42:23 2031 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Shanghai
            organizationName          = hs
            organizationalUnitName    = ops
            commonName                = jumpserver.hs.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                05:42:9A:FE:E5:B0:CD:69:F3:9E:A0:B7:CA:00:C4:4F:AB:AC:5D:9A
            X509v3 Authority Key Identifier: 
                keyid:94:17:8E:52:1C:20:12:86:49:16:CF:79:48:A4:6F:F9:D2:7F:6B:A4

Certificate is to be certified until Mar  3 02:42:23 2031 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
--复制CA签署的证书到服务器
[root@tengine ~/custom_cert]# scp root@CA.hs.com:/root/jumpserver.crt .
--查看CA数据库文件和串号文件
[root@salt /etc/pki/CA]# cat index.txt
V	310303024223Z		01	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
[root@salt /etc/pki/CA]# cat serial
02
--查看证书信息
[root@salt ~/custom_pki]# openssl x509 -in /root/jumpserver.crt -text -noout -serial -dates -subject
...
serial=01
notBefore=Mar  5 02:42:23 2021 GMT
notAfter=Mar  3 02:42:23 2031 GMT
subject= /C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
注：
-noout：不输出加密的证书内容；
-serial：输出证书序列号；
-dates：显示证书有效期的开始和终止时间；
-subject：输出证书的subject；


--吊销证书：
----查看证书信息是否一致
[root@salt /etc/pki/CA]# openssl x509 -in newcerts/01.pem -noout -text -dates -serial -subject 
notBefore=Mar  5 02:42:23 2021 GMT
notAfter=Mar  3 02:42:23 2031 GMT
serial=01
subject= /C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
[root@salt /etc/pki/CA]# cat index.txt
V	310303024223Z		01	unknown	/C=CN/ST=Shanghai/O=hs/OU=ops/CN=jumpserver.hs.com
----核对无误后吊销证书
[root@salt /etc/pki/CA]# openssl ca -revoke /etc/pki/CA/newcerts/01.pem 
Using configuration from /etc/pki/tls/openssl.cnf
Revoking Certificate 01.
Data Base Updated
----生成吊销编号
[root@salt /etc/pki/CA]# echo 01 > /etc/pki/CA/crlnumber
[root@salt /etc/pki/CA]# cat /etc/pki/CA/crlnumber
01
----更新吊销列表
[root@salt /etc/pki/CA]# openssl ca -gencrl -out /etc/pki/CA/crl/01.pem.crl  ----更新吊销列表
Using configuration from /etc/pki/tls/openssl.cnf
注：-gencrl选项为根据/etc/pki/CA/index.txt文件中的信息生成crl文件。
[root@salt /etc/pki/CA]# cat /etc/pki/CA/crl/ca.crl
-----BEGIN X509 CRL-----
MIIC0TCBugIBATANBgkqhkiG9w0BAQsFADBiMQswCQYDVQQGEwJDTjERMA8GA1UE
CAwIU2hhbmdoYWkxETAPBgNVBAcMCFNoYW5naGFpMQswCQYDVQQKDAJoczEMMAoG
A1UECwwDb3BzMRIwEAYDVQQDDAljYS5ocy5jb20XDTIxMDMwNTA2MDkwMVoXDTIx
MDQwNDA2MDkwMVowFDASAgEBFw0yMTAzMDUwNjA2NTdaoA4wDDAKBgNVHRQEAwIB
ATANBgkqhkiG9w0BAQsFAAOCAgEAGL8haHbuSKOqwCR0G1wh6e4hbSY2DrAczIAE
qzAMXwLC4R1ph5LmUtP2wGs1PESEHu3mXwED7X8wSYsdSQJWo90rUaUpI6sUWqXe
dTaM8Tm4CnWKf7pJpHwCcLxapcQOaE/obz4kza0SxUqGZNonchjVxWFO/SXvelas
V5sW71KcbYQ1bZsoCMSkIHJIRxXTTuPEkYygVIUnJoJgEaFGem9/NSs+oeXCHYzz
X+M8LmOlW7CjWNIa/nhFRFhBO4UQobGIAffEN0WmLdIvNPw9EEK1eNhHAAGkALky
K2dppj4lmHBoi6b42mRcYv/g5BTBRRD2ZnuaB01TGcPI8JZBlJSBeSTBLQqUmPSW
ff9niFRvXJQii2pGOmS7HEdIbMG+ocYW9uVHnlxQGNkZalKVyGYI2o1il+jM+oj7
SJGtgaS2drb5NEmbSAumDD0IwKI+EvafbNpa/3K9fVI3f7ysg7OpUq01dLDgW0ar
SYfl/DpQDHsG7gH20bt0XshGSTxlExfa3bs1FnnXjAutNnYfvdgzA/FSC3UilNRu
oi52IsIRWjlqQyNFLo5AfvyVU4oxtM2yrNgDLm0oOxx9lmLCB2VL5j99+aEv9zgR
IgSKFr4lt68vshFoZwWLx1WEuLNFafaHGDWGT8Ybc7+Wq3UiG/W83mbBK7lIIr7M
y6HPMjY=
-----END X509 CRL-----

#windows证书.cer格式转换为.pem
[root@salt ~]# file 123.cer
123.cer: data
[root@salt ~]# openssl x509 -inform der -in 123.cer -out 123.pem
[root@salt ~]# file 123.pem
123.pem: PEM certificate
#导入根证书到linux证书分发机构
方式1:
[root@salt ~]# scp /etc/pki/CA/cacert.pem root@192.168.13.50:/root/
root@192.168.13.50's password: 
cacert.pem         
[root@tengine /etc/pki/tls/certs]# cat /root/cacert.pem >> /etc/pki/tls/certs/ca-bundle.crt  --添加根信任证书
[root@tengine /etc/pki/tls/certs]# !curl  
curl -I https://jumpserver.hs.com   ----此时curl会直接成功访问
HTTP/1.1 200 OK
方式2:
[root@prometheus python_shell]# cp harbor_ca.cer /etc/pki/ca-trust/source/anchors/
[root@prometheus python_shell]# ln -sv /etc/pki/ca-trust/source/anchors/harbor_ca.cer /etc/ssl/certs/ca-harborrepo.trust.cer
‘/etc/ssl/certs/ca-harborrepo.trust.cer’ -> ‘/etc/pki/ca-trust/source/anchors/harbor_ca.cer’
[root@prometheus python_shell]# ll /etc/ssl/certs/
lrwxrwxrwx 1 root root     49 Aug 25  2020 ca-bundle.crt -> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
-r--r--r-- 1 root root 306406 Jun  4  2021 ca-bundle.crt.bak
lrwxrwxrwx 1 root root     55 Aug 25  2020 ca-bundle.trust.crt -> /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
lrwxrwxrwx 1 root root     46 Dec 30 11:22 ca-harborrepo.trust.cer -> /etc/pki/ca-trust/source/anchors/harbor_ca.cer
-rw------- 1 root root   1407 Sep  3  2020 localhost.crt
-rwxr-xr-x 1 root root    610 Aug  9  2019 make-dummy-cert
-rw-r--r-- 1 root root   2516 Aug  9  2019 Makefile
-rwxr-xr-x 1 root root    829 Aug  9  2019 renew-dummy-cert
[root@prometheus python_shell]# update-ca-trust 
此命令一般centos7自带，如果没有则需要安装
yum install ca-certificates
update-ca-trust force-enable


#一条命令生成CAkey和CAcrt
[root@tengine ~/custom_cert]# openssl req -new -x509 -keyout root.key -out origroot.pem -days 3650 -nodes
#通过指定CAcert和CAkey签署证书
[root@tengine ~/custom_cert]# (umask 077;openssl genrsa -out test.key 1024)
[root@tengine ~/custom_cert]# openssl req -new -key test.key -out test.csr -days 365
[root@tengine ~/custom_cert]# openssl x509 -req -in test.csr -CA origroot.pem -CAkey root.key -CAcreateserial -out test.crt -days 3650
Signature ok
subject=/C=CN/ST=Shanghai/L=Shanghai/O=hs/OU=ops/CN=*.hs.com
Getting CA Private Key
[root@tengine ~/custom_cert]# openssl verify -CAfile origroot.pem test.crt   --查看是否被信任
test.crt: OK
------------------------------------

#tftp
[root@prometheus tftpboot]# cat /etc/xinetd.d/tftp 
# default: off
# description: The tftp server serves files using the trivial file transfer \
#       protocol.  The tftp protocol is often used to boot diskless \
#       workstations, download configuration files to network-aware printers, \
#       and to start the installation process for some operating systems.
service tftp
{
        disable                 = no
        socket_type             = dgram
        protocol                = udp
        wait                    = yes
        user                    = root
        server                  = /usr/sbin/in.tftpd
        server_args             = -B 1380 -v -s /var/lib/tftpboot -c
        per_source              = 11
        cps                     = 100 2
        flags                   = IPv4
}
desctiption: -c参数表示启用tftp上传功能 

#jq
安装：sudo yum install -y jq
[jack@ubuntu:~]$ curl -s -X GET "http://192.168.13.50:9401/huazhuhotelpricebookinfo_db_pro-backup/_mapping" | jq '."huazhuhotelpricebookinfo_db_pro-backup".mappings'
{
  "properties": {
    "acceptedCreditCards": {
      "properties": {
        "cardName": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        },
        "cardType": {
          "type": "text",
          "fields": {
            "keyword": {
              "type": "keyword",
              "ignore_above": 256
            }
          }
        }
      }
    },
    "updateTime": {
      "type": "date"
    }
  }
}
--示例
cat json.txt | jq '.'
[
  {
    "name": "站长工具",
    "url": "http://tool.chinaz.com",
    "address": {
      "city": "厦门",
      "country": "中国"
    },
    "arrayBrowser": [
      {
        "name": "Google",
        "url": "http://www.google.com"
      },
      {
        "name": "Baidu",
        "url": "http://www.baidu.com"
      }
    ]
  },
  {
    "name": "站长之家",
    "url": "http://tool.zzhome.com",
    "address": {
      "city": "大连",
      "country": "中国"
    },
    "arrayBrowser": [
      {
        "name": "360",
        "url": "http://www.so.com"
      },
      {
        "name": "bing",
        "url": "http://www.bing.com"
      }
    ]
  }
]
cat json.txt | jq '.[0]'
cat json.txt | jq '.[0] | {name:.name,city:.address.city}'
cat json.txt | jq "[.[] | {name:.arrayBrowser[1].name,city:.address.city}]"
[
  {
    "name": "Baidu",
    "city": "厦门"
  },
  {
    "name": "bing",
    "city": "大连"
  }
]


[root@prometheus ~]# curl -s -upass:pass http://nginx-status.hs.com/checkstatus?format=json | jq '.servers.server[] | select(.status == "down")'
{
  "index": 44,
  "upstream": "BesonDocking_loop",
  "name": "192.168.13.238:12410",
  "status": "down",
  "rise": 0,
  "fall": 296735,
  "type": "tcp",
  "port": 0
}
{
  "index": 45,
  "upstream": "BesonDocking_loop",
  "name": "192.168.13.239:12410",
  "status": "down",
  "rise": 0,
  "fall": 296507,
  "type": "tcp",
  "port": 0
}






#数组
[root@docker02 ~]# a=(1 2 3)
[root@docker02 ~]# echo ${#a[@]}
3
[root@docker02 ~]# echo ${a[1]}
2
#自增
[root@docker02 ~]# i=0
[root@docker02 ~]# ((i++))
[root@docker02 ~]# echo $i
2
[root@docker02 ~]# let i+=1
[root@docker02 ~]# echo $i
3



#vim命令
----多个文件之间复制
vim test1.txt test2.txt
:n 切换下一个文件
:N 切换上一个文件
:f 或 :file 或 :ls 查看当前文件名

----指定行范围内匹配的行前或行后添加内容信息。
--计算修改区间行号1417到
:set nu
--行后增加多行
:.,$s/location.*$/&\r^I^I^Iallow 192.168.3.1;\r^I^I^Iallow 192.168.1.1;\r^I^I^Iallow 222.66.21.210;\r^I^I^Iallow 58.246.78.150;\r^I^I^Ideny all;/g
--行前增加多行
:.,+7s/\}/        allow 192.168.3.1;\r^I^I^Iallow 192.168.1.1;\r^I^I^Iallow 222.66.21.210;\r^I^I^Iallow 58.246.78.150;\r^I^I&/g
注：.,+7表示行范围，&表示匹配的内容，\r表示在匹配的内容前或内容后增加新行，^I表示table键缩进

--非空行前添加注释
:.,+5s/^./# &

--删除有空格的行
:.,+10g/ /d 

--非空行必添加分号
:.,+10s/.$/&;

### 文件logo生成
[root@prometheus ~]# yum install -y figlet 
[root@prometheus ~]# figlet hello
_          _ _
| |__   ___| | | ___  
| '_ \ / _ \ | |/ _ \ 
| | | |  __/ | | (_) |
|_| |_|\___|_|_|\___/ 
                      
[root@prometheus ~]# figlet jack
   _            _    
  (_) __ _  ___| | __
  | |/ _` |/ __| |/ /
  | | (_| | (__|   < 
 _/ |\__,_|\___|_|\_\
|__/                 



</pre>


**bash脚本set使用**

```bash
# set -u 脚本在头部加上它，遇到不存在的变量就会报错，并停止执行。
set -u == set -o nounset	
	
	
# set -x 执行echo bar之前，该命令会先打印出来，行首以+表示。这对于调试复杂的脚本是很有用的。
set -x == set -o xtrace
# 脚本当中如果要关闭命令输出，可以使用set +x
set +x 


# set -e 它使得脚本只要发生错误，就终止执行。
set -e == set -o errexit
# set +e 但是，某些命令的非零返回值可能不表示失败，或者开发者希望在命令失败的情况下，脚本继续执行下去。这时可以暂时关闭set -e，该命令执行结束后，再重新打开set -e。
set +e
command1
command2
set -e
# command || true 上面代码中，set +e表示关闭-e选项，set -e表示重新打开-e选项。
还有一种方法是使用command || true，使得该命令即使执行失败，脚本也不会终止执行。
#!/bin/bash
set -e
foo || true
echo bar


# set -o pipefail 'set -e'有一个例外情况，就是不适用于管道命令，也就是说，只要最后一个子命令不失败，管道命令总是会执行成功，因此它后面命令依然会执行，set -e就失效了
# set -o pipefail 用来解决这种情况，只要一个子命令失败，整个管道命令就失败，脚本就会终止执行。
#!/usr/bin/env bash
set -eo pipefail
foo | echo a
echo bar


# set -E 一旦设置了-e参数，会导致函数内的错误不会被trap命令捕获。-E参数可以纠正这个行为，使得函数也能继承trap命令。
#!/bin/bash
set -Eeuo pipefail
trap "echo ERR trap fired!" ERR
myfunc()
{
  # 'foo' 是一个不存在的命令
  foo
}
myfunc
# 执行上面这个脚本，就可以看到trap命令生效了。
$ bash test.sh
test.sh:行9: foo：未找到命令
ERR trap fired!


# 其他参数 set命令还有一些其他参数。
set -n：等同于set -o noexec，不运行命令，只检查语法是否正确。
set -f：等同于set -o noglob，表示不对通配符进行文件名扩展。
set -v：等同于set -o verbose，表示打印 Shell 接收到的每一行输入。
set -o noclobber：防止使用重定向运算符>覆盖已经存在的文件。
上面的-f和-v参数，可以分别使用set +f、set +v关闭。


# set 命令总结
上面重点介绍的set命令的几个参数，一般都放在一起使用。
# 写法一
set -Eeuxo pipefail

# 写法二
set -Eeux
set -o pipefail
这两种写法建议放在所有 Bash 脚本的头部。
另一种办法是在执行 Bash 脚本的时候，从命令行传入这些参数。
$ bash -euxo pipefail script.sh
```