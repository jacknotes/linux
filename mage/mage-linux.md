#Linux基础
<pre>
man命令：
1.用户命令
2.系统调用
3.库用户
4.特殊文件（设备文件）
5.文本格式（配置文件的语法）
6.游戏
7.杂项
8.管理员命令
<>:必选
[]:可选
|:多选一
...:可以出现多次
{}:分组
NAME:命令名称及功能简要说明
SYNOPSIS：用法说明，包括可用的选项
DESCRIPTION:命令功能的详尽说明，可能包括每一个选项的意义
FILES:此命令相关的配置文件 
BUGS:报告BUG给谁的
EXAMPLES:示例
SEE ALSO:另外参照

文件目录：
/boot:系统启动的文件，如内核、initrd,以及grub(bootloader)
/dev:设备文件
设备文件：
	块设备：随机访问，数据块
	字符设备：线性访问，按字符为单位
/etc:配置文件
/home:用户家目录
/sys:伪文件系统，跟硬件设备相关的属性映射文件
/proc:伪文件系统，内核映射文件 
/opt:可选目录，第三方程序的安装目录
/lib:库文件
	静态库 .a
	动态库 .dll .so(share object)
	/lib/modules:内核映射文件
/tmp:临时文件目录，一个月内自动清理，每个人只能清理自己的文件
/var:可变化的文件，/var/tmp/
/bin:可执行文件，用户命令
/sbin:可执行文件，管理命令
/usr:全局共享只读文件
	/usr/bin
	/usr/sbin
	/usr/lib
/usr/local: #第三方软件的安装目录
	/usr/local/bin
	/usr/local/sbin
	/usr/local/lib
/media:挂载目录，移动设备
/mnt:挂载目录

命名规则：
1、长度不能超过255个字符
2、不能使用/当文件名
相对路径、绝对路径

文件管理
ls
cd
pwd
mkdir
mkdir ./{a/x,b}_{c,d} -pv
touch
rm
stat
[root@smb-server tmp]# touch -m -t 12100915 a
[root@smb-server tmp]# stat a
  File: "a"
  Size: 4096            Blocks: 8          IO Block: 4096   目录
Device: 812h/2066d      Inode: 7340039     Links: 6
Access: (0755/drwxr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2019-04-23 16:05:24.442942913 +0800
Modify: 2019-12-10 09:15:00.000000000 +0800
Change: 2019-04-23 16:09:27.983343327 +0800
cp -a
mv
目录管理

运行程序
设备管理
软件管理
进程管理
网络管理

命令行快捷键：
ctrl+a ctrl+e ctrl+u ctrl+k ctrl+l
history命令：
!!
!-4
!789
!cd
!$ | ESC . #打开前一个命令的最后一个参数

#包管理器：rpm
软件包管理器的核心功能：
1、制件软件包
2、安装、卸载、升级、查询、校验
打包成一个软件包：二进制程序、库文件、配置文件、帮助文件
Redhat、SUSE:RPM
Debian:dpt
后端工具：RPM,dpt
前端工具：yum,apt-get

rpm命令：
	rpm：管理rpm包的
	rpmbuild:构建rpm包的
rpm数据库：/var/lib/rpm  #一般是hash格式的数据库，因为查找快得多
rpm提供的功能：安装、查询、卸载、升级、校验、数据库的重建、验证数据包等工作
rpm命名：
包：组成部分
	主包：
		bind-version
		bind-9.7.1-1.el5.i586.rpm
	子包:
		bind-libs-9.7.1-1.el5.i586.rpm
		bind-utils-9.7.1-1.el5.i586.rpm
	包名：
		name-version-release.arch.rpm
		bind-major.minor.release-release.arch.rpm  #major.minor.release-release主版本，次版本，修证号，发行号
rpm包：
	源码包：需要编译
	二进制包：直接使用
1、rpm安装：
rpm -ivh *.rpm #安装rpm包
--nodeps:忽略依赖关系
--force:强行安装,可以实现重装或降级 --replacepags:重新安装，替换原有安装 --oldpackage：降级软件包
--test:测试安装rpm包，检查依赖关系
2、rpm查询：
rpm -qa | grep softwarename    查看需要查找的软件是否安装
rpm -qi softwarename    查看软件的信息
rpm -qd softwarename    查看软件的手册信息
rpm -qf  /bin/ls   查看执行文件软件于个软件包
rpm -ql  softwarename  列出软件包里面的文件
rpm -qc  softwarename  列出软件包里面的配置文件 
rpm -q --scripts softwarename 列出软件包的脚本
rpm -qpl softwarename 查询尚未安装的软件包如果安装后生成的说明信息及文件，l可为i，c，d
3、rpm包升级
rpm -Uvh softwarename 如果有老版本则升级，如果没老版本则安装 --oldpackage包降级
rpm -Fvh softwarename 如果有教务处槽 升级，如果没有老版本则退出
4、rpm卸载包
rpm -e softwarename   删除包 --nodeps
5、rpm包校验：
 rpm -V axel-2.4-1.el6.rf.x86_64 检验软件是否被非法更改的，具体属性解释请查看man rpm
6、重建数据库
rpm --rebuilddb:重建数据库，一定会重新建立
rpm --initdb:初始化数据库，有就不会覆盖，没有则初始化

7、检验来源合法性及软件完整性：
三种加密和解密算法：
对称：DES,3DES,AES 加密解密使用同一个密钥
公钥：一对密钥，公钥和私钥
单向：sha1,md5,hash算法
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 #导入centos的对称密钥
rpm -K axel-2.4-1.el6.rf.x86_64 #使用导入centos的对称密钥解密验证从centos官方下载的包的完整校验和来源合法性检验是否具有合法性，dsa,gpg验证来源合法性，sha1,md5完整校验,可以使用--nodigest来略过完整性检验，使用--nosignature略过来源合法性校验
[root@smb-server src]# ls /var/lib/rpm/  #rpm的数据库
Basenames     __db.002  Dirnames     Installtid    Packages        Pubkeys         Sha1header
Conflictname  __db.003  Filedigests  Name          Providename     Requirename     Sigmd5
__db.001      __db.004  Group        Obsoletename  Provideversion  Requireversion  Triggername

#包管理器：yum
createrepo:创建元数据文件
HTML:HyperText Mark Language
XML:eXtended Mark Language
XML,JSON:半结构化的数据
yum仓库中的元数据文件：
primary.xml.gz
	所有RPM包的列表
	依赖关系
	每个RPM安装生成的文件列表
filelists.xml.gz
	当前仓库中所有RPM包的所有文件列表
other.xml.gz
	额外信息：RPM的修改日志
repomd.xml
	记录的是上面三个文件的时间戳和校验和
comps*.xml：RPM包分组信息
	
yum:
yum localinstall package #本地安装rpm包，可解决依赖关系，比rpm -ivh强
reinstall 重新安装 
downgrade 降级
repolist 列出所有可用仓库
list all | avaliable #列出包
--nogpgcheck #不做gpgcheck检查
update #升级最新版本
update-to #升级为指定版本
remove | erase #卸载
info #查看包信息，类似qi
provides #查看文件是由哪个包提供的，类似qf

如何为yum定义repo文件：
[Repo_Id] #repo名称，唯一标识符
name=jack repo  #描述信息
baseurl=file:///mnt/repodate  #repo的包路径,支持ftp://,http://,本地路径file:///
enable={1|0} #1表示启用，0表示禁用
gpgcheck={1|0} #验证gpg的来源合法性和完整性，1为开启，0为禁用
gpgkey=file:///mnt/RPM-GPG-KEY-CentOS-7 #校验yum的包的密钥路径，支持ftp://,http://,本地路径file:///


#RPM和YUM区别
rpm:
	二进制格式：
	源程序--编译--二进制格式
		有些特性是编译选定的，如果未选定此特性，将无法使用
		rpm包的版本会落后于源码包，甚至落后很多
所以需要定制安装：手动编译安装
编译环境，开发环境
开发库，开发工具，
C,C++,perl,java,python
gcc:GNU C Compile，C编译器
g++: C++编译器
make:C或C++的项目管理工具
makefile:定义了make(c,c++)按何种次序去编译源文件中的源程序
automake-->makefile.in-->makefile
autoconf-->configure
手动编译时使用configure指定参数来结合makefile.in来生成makefile,然后用make来根据makefile编译源代码，最后使用make install来安装源程序 
./configure 
	--prefix=/usr/local/  #例如指定软件安装目录
	--sysconfdir=/etc/  #例如指定配置文件目录
./configure --help #获取编译帮助
编译前提：安装开发环境
yum grouplist "Development and Creative Workstation" #安装开发环境
./configure --prefix=/usr/local/nginx
make 
make install 
1.修改环境变量，使nginx在环境变量当中
2.默认情况下，源码安装的软件库文件是不被其他程序调用的，其他程序调用的库路径是/lib,/usr/lib. 需要在/etc/ld.so.conf.d/中创建.conf为后缀名的文件，而后要把源码的库文件路径添加到.conf文件中
	需要即时生效需要执行ldconfig -v命令
3.头文件：输出给系统
	默认：头文件默认在/usr/include中
	增添头文件搜寻路径，使用链接进行：
		ln -s /usr/local/tengine/include/* /usr/include 或
		ln -s /usr/local/tengine/incllude /usr/include/tengine
4.man文件路径：安装--prefix目录下的/usr/local/tengine/man
	1 man -M /usr/local/nginx/man httpd  #临时生效
	2 在/etc/man.config中添加一条MANPATH #永久生效

#进程管理：
停止状态、就绪状态、执行中、不可中断睡眠、可中断睡眠、僵尸进程
进程有状态、有父子关系、有优先级关系
0-139，总共有140个优先级
其中0-99是内核控制的，100-139是由用户控制的
大O标准：O(1),O(n),O(logn),O(n^2),O(2^n)
O(1):无论队列多长，所花时间是一样的，XY轴平行线，也就是y等于1，
O(n)：随着队列的增长时间也随着增长，XY轴线性增长,也就是y会变化
优先级越低获得CPU的运行时间越长，并且更优先获得运行的机会
用nice值来调：-20到19，对应100-139,每一个进程nice值是0
普通用户只能调大nice值，root可以调大和调小nice值
ps命令：
	SysV风格：加-
	BSD网格：不加-

euid是有效运行的用户，uid是谁发起的用户
pgrep -t pts/0
pidof 
top
	 load average: 0.00, 0.01, 0.05 #1、5、15分钟的平均负载
	 0.0 us（用户空间使用率）,  0.0 sy（系统使用率）,  0.0 ni（nice值）,100.0 id(cpu空闲比率),  0.0 wa（io等待）,  0.0 hi（硬中断）,  0.0 si（软中断）,  0.0 st（偷走的CPU）
	 PID USER      PR（优先级，rt实时优先级）  NI（nice值）    VIRT（虚拟内存级）    RES（常驻内存级）    SHR（共享内存大小） S（状态）  %CPU %MEM     TIME+ （运行时长，真正占用cpu时长）COMMAND
交互命令：T表示cpu占用时长，M表示内存比率排序，P表示CPU比率排序

##grub
修复stage1：
1. grub  #进入命令行
2. root (hd0,0) #指定内核所在的分区，hd0为BIOS第一块硬盘，0为第一个分区，/dev/sda1 /boot
3. setup hd0  #安装stage1并指定硬盘
重新安装grup:
mkdir /mnt/boot && mount /dev/hda1 /mnt/boot
1. grub-install --root-derictory=/mnt /dev/hda  #指定修复的硬盘boot所在的父目录，例如一块硬盘/dev/hda挂载的是/mnt，则boot的父目录是/mnt,并且指定要安装的硬盘
2. sync 同步数据到硬盘
3. vim /mnt/boot/grub/gurb.conf  #创建gurb配置文件

如何修复grub.conf配置文件故障：
1. 当grub.conf故障，你重启系统的时候只会启动第1阶段，不会启动第2阶段，所以会给你grub命令行
2. find (hd0,0)/ #使用find目录查找内核所在的分区，只能一个个去找，find (hd1,0)/,然后按tab键，直至找到内核
3.  root (hd0,0) #指定内核目录
4.  kernel /vmlinuz  #指定kernel,按tab键补全
5.  initrd /initrd  ##指定initrd,按tab键补全,版本要跟内核版本一致
6.  boot  #启动系统

##kerner的初始化过程：
1. 设备探测
2. 加载驱动初始化（可能会从initrd文件中装载驱动模块）
3. 以只读方式挂载根文件系统
4. 装载第一个进程init
/etc/inittabz:
initdefault:设定默认运行级别
sysinit:系统初始化
wait:等待级别切换到此级别时运行
respawn:一旦程序终止，会重新启动
/etc/rc.d/rc.sysinit完成的任务：
1. 激活udev和selinux
2. 根据/etc/sysctl.conf文件，来设定内核参数。
3. 设定系统时钟。
4. 装载键盘映射。
5. 启用交换分区。
6. 设置主机名
7. 根文件系统检测，并以读写方式重新挂载。
8. 激活软RAID和LVM设备。
9. 启用磁盘配额。
10. 根据/etc/fstab检查并挂载其它文件系统。
11. 清理过期的锁和PID文件。

#内核模块管理：
sysctl -w vm.drop_cache=1
sysctl -w net.ipv4.ip_forward=1
sysctl -w kerner.hostname=www.jack.com
vim /etc/sysctl.conf
	vm.drop_cache=1
	net.ipv4.ip_forward=1
	kerner.hostname=www.jack.com
sysctl -p  #永久生效
sysctl -a  #显示所有内核参数及其值
#系统模块管理：
lsmod  #列出当前系统所有的模块
modprobe MODULE_NAME  #装载模块，只需要指定模块名称不需要指定模块路径
modprobe -r MODULE_NAME  #卸载模块，只需要指定模块名称不需要指定模块路径，自己会去/lib/module/kerner_version/下去找模块
modinfo MODULE_NAME  #查看模块的具体信息
insmod /PATH/to/file #装载模块，必须指定模块路径
rmmod MODULE_NAME #移除模块
depmod /PATH/TO/MODULE_DIR  #生成模块间的依赖关系到这个目录当中，用得不多
#加网卡加驱动时下载源代码手动编译成ko模式，放在特定的路径下。编译驱动时
linux版本必须跟自己系统一致才能用
#内核中的功能除了核心功能之外(不能选择操作的核心)，在编译时，大多功能都有三种选择：
	1. 不使用此功能
	2. 编译成内核模块(成为模块，内核后续装载)
	3. 编译进内核(只要内核装载就装载)

######如何手动编译内核
升级为2.6.28
安装编译环境和编译工具
安装两个开发组：1. Development Libraries  2. Development Tools
挂载本地光驱安装：
yum groupinstall -y "Development Libraries" "Development Tools"
get linux-2.6.28.tar.gz #下载内核文件
[root@localhost ~]# tar -zxf linux-2.6.28.tar.gz -C /usr/src #解压到路径
[root@localhost src]# ln -sv linux-2.6.28/ linux #一般来说当前编译的linux版本链接为linux
create symbolic link `linux' to `linux-2.6.28/'
[root@localhost linux]# ls arch/ #各种平台的cpu架构
alpha  blackfin  h8300    m32r       mips     powerpc  sparc    x86
arm    cris      ia64     m68k       mn10300  s390     sparc64  xtensa
avr32  frv       Kconfig  m68knommu  parisc   sh       um
#编译方式
1. make gconfig:gnome桌面环境下使用，需要安装图形开发库GNOME Software Development
2. make kconfig:kde桌面环境下使用，需要安装图形开发库KDE Software Development
3. make menuconfig:一定要在内核目录下打开，并且窗口要足够大，否则会打开文字窗口失败
 .config - Linux Kernel v2.6.28 Configuration
 ------------------------------------------------------------------------------
  +---------------------- Linux Kernel Configuration -----------------------+
  |  Arrow keys navigate the menu.  <Enter> selects submenus --->.          |
  |  Highlighted letters are hotkeys.  Pressing <Y> includes, <N> excludes, |
  |  <M> modularizes features.  Press <Esc><Esc> to exit, <?> for Help, </> |
  |  for Search.  Legend: [*] built-in  [ ] excluded  <M> module  < >       |
  | +---------------------------------------------------------------------+ |
  | |        General setup  --->                                          | | #有箭头表示有子条目，enter键进入，如果是*表示做进内核，如果是m表示做成模块
  | |    [*] Enable loadable module support  --->                         | |
  | |    -*- Enable the block layer  --->                                 | |
  | |        Processor type and features  --->                            | |
  | |        Power management and ACPI options  --->                      | |
  | |        Bus options (PCI etc.)  --->                                 | |
  | |        Executable file formats / Emulations  --->                   | |
  | |    -*- Networking support  --->                                     | |
  | |        Device Drivers  --->                                         | |
  | |        Firmware Drivers  --->                                       | |
  | |        File systems  --->                                           | |
  | |        Kernel hacking  --->                                         | |
  | |        Security options  --->                                       | |
  | |    -*- Cryptographic API  --->                                      | |
  | |    [*] Virtualization (NEW)  --->                                   | |
  | |        Library routines  --->                                       | |
  | |    ---                                                              | |
  | |        Load an Alternate Configuration File                         | |
  | |        Save an Alternate Configuration File                         | |
  | |                                                                     | |
  | |                                                                     | |
  | +---------------------------------------------------------------------+ |
  +-------------------------------------------------------------------------+
  |                    <Select>    < Exit >    < Help >                     |
  +-------------------------------------------------------------------------+

#进入General setup  --->    
 .config - Linux Kernel v2.6.28 Configuration
 ------------------------------------------------------------------------------
  +----------------------------- General setup -----------------------------+
  |  Arrow keys navigate the menu.  <Enter> selects submenus --->.          |
  |  Highlighted letters are hotkeys.  Pressing <Y> includes, <N> excludes, |
  |  <M> modularizes features.  Press <Esc><Esc> to exit, <?> for Help, </> |
  |  for Search.  Legend: [*] built-in  [ ] excluded  <M> module  < >       |
  | +---------------------------------------------------------------------+ |
  | |    [*] Prompt for development and/or incomplete code/drivers        | |
  | |    ()  Local version - append to kernel release                     | | #需要让你输入字符串，这个字符串是本地版本号，2.6.18-348.el5中的-348.el5是本地版本号
  | |    [ ] Automatically append version information to the version strin| |
  | |    [*] Support for paging of anonymous memory (swap)                | |
  | |    [*] System V IPC                                                 | |
  | |    [*] POSIX Message Queues                                         | |
  | |    [*] BSD Process Accounting                                       | |
  | |    [ ]   BSD Process Accounting version 3 file format               | |
  | |    [*] Export task/process statistics through netlink (EXPERIMENTAL)| |
  | |    [*]   Enable per-task delay accounting (EXPERIMENTAL)            | |
  | |    [*]   Enable extended accounting over taskstats (EXPERIMENTAL)   | |
  | |    [*]     Enable per-task storage I/O accounting (EXPERIMENTAL)    | |
  | |    [*] Auditing support                                             | |
  | |    [*]   Enable system-call auditing support                        | |
  | |    < > Kernel .config support                                       | |
  | |    (19) Kernel log buffer size (16 => 64KB, 17 => 128KB)            | |
  | |    [ ] Control Group support (NEW)                                  | |
  | |    [ ] Group CPU scheduler (NEW)                                    | |
  | |    [*] Create deprecated sysfs files (NEW)                          | |
  | |    -*- Kernel->user space relay support (formerly relayfs)          | |
  | |    -*- Namespaces support                                           | |
  | +----v(+)-------------------------------------------------------------+ |
  +-------------------------------------------------------------------------+
  |                    <Select>    < Exit >    < Help >                     |
  +-------------------------------------------------------------------------+
#保存退出内核编辑
[root@localhost linux]# ls -a
.        COPYING        firmware    ipc       MAINTAINERS  REPORTING-BUGS  usr
..       CREDITS        fs          Kbuild    Makefile     samples         virt
arch     crypto         .gitignore  kernel    mm           scripts
block    Documentation  include     lib       net          security
.config  drivers        init        .mailmap  README       sound
注：.config文件是你编辑过的配置文件，是保存在这个文件上的
[root@localhost linux]# ls /boot/
config-2.6.18-348.el5      lost+found                 System.map-2.6.18-348.el5
grub                       message                    vmlinuz-2.6.18-348.el5
initrd-2.6.18-348.el5.img  symvers-2.6.18-348.el5.gz
[root@localhost linux]# cp /boot/config-2.6.18-348.el5 /usr/src/linux/.config  #因为你自己编辑的配置文件会容易出错，而redhat的配置文件可以运行在你机器上，所以我们把redhat的配置文件复制过来在此基础上更改即可。
cp: overwrite `/usr/src/linux/.config'? y
make menuconfig #再次执行编辑内核硬件驱动用不着可取消掉，会导致编辑非常非常慢
 .config - Linux Kernel v2.6.28 Configuration
 ------------------------------------------------------------------------------
  +---------------------- Linux Kernel Configuration -----------------------+
  |  Arrow keys navigate the menu.  <Enter> selects submenus --->.          |
  |  Highlighted letters are hotkeys.  Pressing <Y> includes, <N> excludes, |
  |  <M> modularizes features.  Press <Esc><Esc> to exit, <?> for Help, </> |
  |  for Search.  Legend: [*] built-in  [ ] excluded  <M> module  < >       |
  | +---------------------------------------------------------------------+ |
  | |        General setup  --->                                          | |
  | |    [*] Enable loadable module support  --->                         | |
  | |    -*- Enable the block layer  --->                                 | |
  | |        Processor type and features  --->  #处理器类型和特性           | |
  | |        Power management and ACPI options  --->                      | |
  | |        Bus options (PCI etc.)  --->                                 | |
  | |        Executable file formats / Emulations  --->                   | |
  | |    -*- Networking support  --->                                     | |
  | |        Device Drivers  --->                                         | |
  | |        Firmware Drivers  --->                                       | |
  | |        File systems  --->                                           | |
  | |        Kernel hacking  --->                                         | |
  | |        Security options  --->                                       | |
  | |    -*- Cryptographic API  --->                                      | |
  | |    [*] Virtualization (NEW)  --->                                   | |
  | |        Library routines  --->                                       | |
  | |    ---                                                              | |
  | |        Load an Alternate Configuration File                         | |
  | |        Save an Alternate Configuration File                         | |
  | |                                                                     | |
  | |                                                                     | |
  | +---------------------------------------------------------------------+ |
  +-------------------------------------------------------------------------+
  |                    <Select>    < Exit >    < Help >                   

.config - Linux Kernel v2.6.28.9 Configuration
 ------------------------------------------------------------------------------
  +---------------------- Processor type and features ----------------------+
  |  Arrow keys navigate the menu.  <Enter> selects submenus --->.          |
  |  Highlighted letters are hotkeys.  Pressing <Y> includes, <N> excludes, |
  |  <M> modularizes features.  Press <Esc><Esc> to exit, <?> for Help, </> |
  |  for Search.  Legend: [*] built-in  [ ] excluded  <M> module  < >       |
  | +---------------------------------------------------------------------+ |
  | |    [ ] Tickless System (Dynamic Ticks) (NEW)                        | |
  | |    [ ] High Resolution Timer Support (NEW)                          | |
  | |    [*] Symmetric multi-processing support                           | |
  | |    [*] Enable MPS table (NEW)                                       | |
  | |        Subarchitecture Type (PC-compatible)  --->                   | |
  | |    [ ] Paravirtualized guest support (NEW)  --->                    | |
  | |    [ ] Memtest (NEW)                                                | |
  | |        Processor family (Generic-x86-64)  --->  #设置处理器类型跟你物理机cpu一样                    | |
  | |    [*] IBM Calgary IOMMU support                                    | |
  | |    [ ]   Should Calgary be enabled by default?                      | |
  | |    [*] AMD IOMMU support                                            | |
  | |    (255) Maximum number of CPUs (2-512)                             | |
  | |    [*] SMT (Hyperthreading) scheduler support                       | |
  | |    [*] Multi-core scheduler support                                 | |
  | |        Preemption Model (Voluntary Kernel Preemption (Desktop))  ---| |
  | |    [*] Machine Check Exception                                      | |
  | |    [*]   Intel MCE features                                         | |
  | |    [*]   AMD MCE features                                           | |
  | |    < > Dell laptop support (NEW)                                    | |
  | |    <M> /dev/cpu/microcode - microcode support                       | |
  | |    [*]   Intel microcode patch loading support (NEW)                | |
  | +----v(+)-------------------------------------------------------------+ |
  +-------------------------------------------------------------------------+
  |                    <Select>    < Exit >    < Help >                     |
  +-------------------------------------------------------------------------+
make  #编译
make moules_install #安装模块
make install  #安装内核
yum install screen -y #这个能够在当前窗口中模拟好多窗口，可以用于编译内核时，以防断开需要从头开始编译
screen #进入一个新的屏幕
screen -S jack #进入新屏幕并设置名称
screen -ls #列出屏幕会话
screen -r screen_id #还原屏幕会话
ctrl+a后松开按d：从当前窗口剥离掉
exit #退出当前屏幕

当内核不是自己想像的那样，则需要重新编译安装，或者如下
make clean #清理此前安装好的二进制模块
make mrproper #清理此前编译残留的文件包括.config

#怎么让自己编译的内核启动
加一块硬盘到自己现在所在的系统，并对硬盘进行分两个区/mnt/boot和/mnt/sysroot
1. [root@localhost ~]# fdisk -l

Disk /dev/sda: 53.6 GB, 53687091200 bytes
255 heads, 63 sectors/track, 6527 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          13      104391   83  Linux
/dev/sda2              14        6527    52323705   8e  Linux LVM

Disk /dev/sdb: 21.4 GB, 21474836480 bytes  #创建两个分区
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1           3       24066   83  Linux
/dev/sdb2               4        2610    20940727+  83  Linux
2. [root@localhost ~]# mke2fs -j /dev/sdb1 #用ext3来格式化分区
[root@localhost ~]# mke2fs -j /dev/sdb2
root@localhost ~]# mkdir /mnt/boot
[root@localhost ~]# mkdir /mnt/sysinit
[root@localhost ~]# mount /dev/sdb1 /mnt/boot/
[root@localhost ~]# mount /dev/sdb2 /mnt/sysroot/
[root@localhost ~]# grub-install --root-directory=/mnt /dev/sdb #安装grub,指定新硬盘boot的根目录，及指定哪个硬盘
Probing devices to guess BIOS drives. This may take a long time.
Installation finished. No error reported.
This is the contents of the device map /mnt/boot/grub/device.map.
Check if this is correct or not. If any of the lines is incorrect,
fix it and re-run the script `grub-install'.

(fd0)   /dev/fd0
(hd0)   /dev/sda
(hd1)   /dev/sdb
[root@localhost boot]# cp /boot/vmlinuz-2.6.18-348.el5 /mnt/boot/vmlinuz #复制编译好的系统内核到新硬盘/boot目录下
[root@localhost boot]# cp /boot/initrd-`uname -r`.img /root #设置init文件
[root@localhost ~]# mv initrd-2.6.18-348.el5.img initrd-2.6.18-348.el5.img.gz
[root@localhost ~]# gzip -d initrd-2.6.18-348.el5.img 
[root@localhost ~]# file initrd-2.6.18-348.el5.img 
initrd-2.6.18-348.el5.img: ASCII cpio archive (SVR4 with no CRC)
[root@localhost ~]# mkdir test
[root@localhost ~]# cd test/
[root@localhost test]# cpio -id < ../initrd-2.6.18-348.el5.img  #展开init文件到当前目录下
17850 blocks
[root@localhost test]# ls
bin  dev  etc  init  lib  proc  sbin  sys  sysroot
[root@localhost iso]# zcat /boot/initrd-2.6.18-348.el5.img | cpio -id  #一条命令搞定前面的，zcat读取压缩文件，并通过管道给cpio从传过来的存档文件复制出文件来，-i为提取，-d为在需要的地方创建目录
17850 blocks
[root@localhost iso]# ls
bin  dev  etc  init  lib  proc  sbin  sys  sysroot
[root@localhost iso]# vim init #设定initrd挂载根的设备
mkrootdev -t ext3 -o defaults,ro /dev/sdb2 #设定根设备
#resume /dev/VolGroup00/LogVol01
[root@localhost iso]# find . | cpio -H newc --quiet -o | gzip -9 > /mnt/boot/initrd.gz #查看当前目录所有文件通过管理传至cpio命令，让cpio来归档，类型为新归档(newc)，静默输出至管道给gzip,压缩等级为9，最后重定向给/mnt/boot/initrd.gz
[root@localhost iso]# cd /mnt/boot/
[root@localhost boot]# ll -h
total 5.5M
drwxr-xr-x 2 root root 1.0K May  7 16:04 grub
-rw-r--r-- 1 root root 3.5M May  7 16:30 initrd.gz
drwx------ 2 root root  12K May  7 16:02 lost+found
-rw-r--r-- 1 root root 2.1M May  7 16:07 vmlinuz 
[root@localhost ~]# cd /mnt/boot/grub/
[root@localhost grub]# cat grub.conf #编辑grub.conf配置文件
default=0
timeout=5
title test linux(magedu team)
        root (hd0,0)
        kernel /vmlinuz
        initrd /initrd.gz
[root@localhost sysroot]# mkdir proc sys dev etc/rc.d lib lib64 bin sbin boot home var/log usr/{bin,sbin} root tmp -pv #创建根下的目录
[root@localhost sysroot]# tree
.
|-- bin
|-- boot
|-- dev
|-- etc
|   `-- rc.d
|-- home
|-- lib
|-- lib64
|-- lost+found
|-- proc
|-- root
|-- sbin
|-- sys
|-- tmp
|-- usr
|   |-- bin
|   `-- sbin
`-- var
    `-- log

[root@localhost sysroot]# cp /sbin/init /mnt/sysroot/sbin/
[root@localhost sysroot]# cp /bin/bash /mnt/sysroot/bin/
 [root@localhost sysroot]# ldd /sbin/init #查看init依赖的库文件
        linux-vdso.so.1 =>  (0x00007fff6e7fd000)
        libsepol.so.1 => /lib64/libsepol.so.1 (0x00000037c8800000)
        libselinux.so.1 => /lib64/libselinux.so.1 (0x00000037c8400000)
        libc.so.6 => /lib64/libc.so.6 (0x00000037c0c00000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00000037c1400000)
        /lib64/ld-linux-x86-64.so.2 (0x00000037c0800000)
[root@localhost sysinit]# cp /lib64/libsepol.so.1 /mnt/sysroot/lib64/ #复制init依赖的库文件
[root@localhost sysinit]# cp /lib64/libselinux.so.1 /mnt/sysroot/lib64/
[root@localhost sysroot]# cp /lib64/libc.so.6 /mnt/sysroot/lib64/
[root@localhost sysroot]# cp /lib64/libdl.so.2 /mnt/sysroot/lib64/
[root@localhost sysroot]# cp /lib64/ld-linux-x86-64.so.2 /mnt/sysinit/lib64/
[root@localhost sysroot]# ls /mnt/sysroot/lib64
ld-linux-x86-64.so.2  libc.so.6  libdl.so.2  libselinux.so.1  libsepol.so.1
[root@localhost ~]# ldd /bin/bash
        linux-vdso.so.1 =>  (0x00007fff47bfd000)
        libtermcap.so.2 => /lib64/libtermcap.so.2 (0x00000037c1c00000)
        libdl.so.2 => /lib64/libdl.so.2 (0x00000037c1400000)
        libc.so.6 => /lib64/libc.so.6 (0x00000037c0c00000)
        /lib64/ld-linux-x86-64.so.2 (0x00000037c0800000)
[root@localhost ~]# cp /lib64/libtermcap.so.2 /mnt/sysroot/lib64/
[root@localhost ~]# chroot /mnt/sysroot/
bash-3.2# exit
[root@localhost sysroot]# cat /mnt/sysroot/etc/inittab 
id:3:initdefault:
si::sysinit:/etc/rc.d/rc.sysinit
[root@localhost sysroot]# cat /mnt/sysroot/etc/rc.d/rc.sysinit
#!/bin/bash
#
echo -e "\tWelcome to \033[31mMagEdu Team\033[0m Linux."
/bin/bash
[root@localhost sysinit]# chmod +x etc/rc.d/rc.sysinit
[root@localhost sysroot]# tree 
.
|-- bin
|   `-- bash
|-- boot
|-- dev
|-- etc
|   |-- inittab
|   `-- rc.d
|       `-- rc.sysinit
|-- home
|-- lib
|-- lib64
|   |-- ld-linux-x86-64.so.2
|   |-- libc.so.6
|   |-- libdl.so.2
|   |-- libselinux.so.1
|   |-- libsepol.so.1
|   `-- libtermcap.so.2
|-- lost+found
|-- proc
|-- root
|-- sbin
|   `-- init
|-- sys
|-- tmp
|-- usr
|   |-- bin
|   `-- sbin
`-- var
    `-- log
[root@localhost sysroot]# sync 
[root@localhost sysroot]# sync 
[root@localhost sysroot]# sync 
[root@localhost sysroot]# sync 









</pre>