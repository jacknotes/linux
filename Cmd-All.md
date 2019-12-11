#command 
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
[root@master-nginx backup]# echo | awk ‘{a="hello";b="nihao";c="minggongge";print a,b,c;}'  
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

#echo
echo -e "next\n" #意思是在引号内容中""引用回车键

#Linux三剑客命令之sed
[root@master-nginx backup]# sed -n '1,3p' passwd  #-n为安装模式，打开1到3行
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

#iptables防火墙
iptables表：
filter（过滤）,nat（地址软的）,mangle（对包拆开，封装，修改）,raw（只看不做任何修改）
规则链：
PREROUTING
POSTROUTING
INPUT
OUTPUT
FORWARD
iptables最大处理连接数：
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
iptables -t nat -A POSTROUTING -s 192.168.1.0/24 -j MASAUERADE  #用于外网ip不是固定的时候，内网用户可上网，仅限内网用户主动发起
iptables -t nat -A FORWARD -s 192.168.0.0/24 -p icmp -j REJECT #拒绝转发icmp的所有协议，其他协议允许通过 
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT #开启转发ftp数据服务，RELATED就是打开数据服务的   #ip_nat_ftp 和ip_conntrack_ftp两个模块必须安装
iptables -A FORWARD -s 192.168.1.0/24 -p tcp --dport 21 -m state --state NEW -j ACCEPT #开启转发ftp命令服务
DNAT:（目标地址转换，用于互联网访问局域网服务器）
iptables -t nat -A PREROUTING -d 180.1.1.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1 #目标地址转换，用于互联网访问局域网的服务器的，外网地址为180.1.1.1:80，内网地址为192.168.1.1:80
iptables -t nat -R PREROUTING -d 180.1.1.1 -p tcp --dport 80 -j DNAT --to-destination 192.168.1.1:8080  #目标地址转换，PAT,用于互联网访问局域网的服务器的，外网地址为180.1.1.1:80，内网地址为192.168.1.1:8080,
iptables -A FORWARD -m string --algo kmp --string "h7n9" -j DROP #丢弃带"h7n9"信息的请求

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


##tcpdump
[root@autodep ~]# tcpdump -i eth0 ip host 192.168.1.254  #在eth0接口上，ip协议，抓取关于主机是192.168.1.254的包
[root@autodep ~]# tcpdump -i eth0 ip host 192.168.1.234 and tcp port 22  #在eth0接口上，ip协议，抓取关于主机是192.168.1.254并且端口是22的
[root@autodep ~]# tcpdump -i eth0 src 192.168.1.234 and dst 192.168.1.232
[root@autodep ~]# tcpdump -i eth0 src 192.168.1.234 and dst ! 192.168.1.232


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



</pre>
