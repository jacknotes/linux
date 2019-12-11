#Centos下的光纤基本配置
<pre>
#简单说明
HBA：
光纤通道主机总线适配器(Fiber Channel Host Bus Adapter)
是一块像以太网卡一样的接口卡设备，传输光信号
比如DELL机架服务器插HBA卡，经过光纤线接入光纤交换机
同样的存储也是光纤线接入存储的HBA卡，另外一端接入光纤交换机
这样就使得服务器和存储之间建立了存储链路，实现存储和服务器之间的多对多应用
所谓的存储设备，其实也是一台服务器

WWN：
每一个以太网卡都有自己独一无二的MAC地址，同样的HBA卡也有相应的WWN
所谓的WWN就是 World Wide Name，分为两种：Node WWN(WWNN)和Port WWN(WWPN)
如果不特殊指明，一般WWN信息是指 Port WWN(WWPN)信息
WWN是一串长度为8字节的十六进制字符串

直接查询：
# 查看当前有几个HBA卡，该目录下host数量就是HBA卡数量
cd /sys/class/fc_host
ls |wc -l

# 查看 Port WWN(WWPN)信息
cd host1
cat port_name|\
awk -F'"|0x' '{print $2}'|\
sed 's/\w/& /g'|\
awk '{for(i=1;i<=NF;i++)
       {     if(i==NF) {print $i}
        else if(i%2==0){printf $i":"}
        else           {printf $i}
       }
     }'

systool命令简录：
在CentOS6u9中可以使用systool获取相关的信息，该命令的功能是：查看系统总线、设备类型和拓扑设备信息

# 查看命令所在的工具包并安装命令
yum provides */systool
yum -y install sysfsutils

# 查看帮助
systool -h
# 使用-v参数输出所有信息
# 使用-b参数根据总线类型查看信息
# 使用-c参数根据设备类型查看信息
# 使用-m参数根据模块类型查看信息

# 查看当前系统支持的总线、设备类型、设备和模块信息
systool

# 结合输出信息和-b、-c、-m参数，查看相应的信息
systool -v -b usb
# 查看当前系统支持的USB总线信息
systool -v -c block
# 查看当前系统支持的块设备信息

HBA信息获取：
当前系统是否支持某种总线或者设备，取决于物理硬件是否存在、驱动是否加载生效
因此需要找到一台真实使用了HBA卡的主机设备才能够查看信息
总线是接口，模块指驱动，HBA卡属于设备，也就是class类型，它的前缀缩写是fc

# 获取当前支持的HBA卡类型名
systool|grep fc
# fc_host
# fc_remote_ports
# fc_transport
# fc_vports
# scsi_transport_fc
# 其中fc_host就是HBA信息

systool -v -c fc_host
# 查看HBA卡的全部信息

systool -v -c fc_host|grep 'Class Device ='
# 查看当前HBA卡的数量，这个数量和服务器配置HBA卡物理硬件数量一致
# 一般情况下为了防止单点故障，都是成双成对的

systool -v -c fc_host|grep 'Class Device path'
# 查看HBA卡的系统路径映射

systool -v -c fc_host|grep 'fabric_name'
# 查看HBA卡的名字，一串16进制的8字节字符串

systool -v -c fc_host|grep 'node_name'
# 查看HBA卡的Node WWN(WWNN)

systool -v -c fc_host|grep -E ' port| speed'
# 查看HBA卡的port相关的信息
# 包括id、name、stage、type和speed
# 从此处可以看出，HBA卡主要信息是port相关的信息
# 数据传输都是基于port的

systool -v -c fc_host|grep 'port_name'
# 查看HBA卡的Port WWN(WWPN)

# 我们一般需要提供给存储工程师或者网络工程师类似MAC地址格式的字符串
systool -v -c fc_host|\
awk -F'"|0x' '{if($1~/\<port_name/)print $3}'|sed 's/\w/& /g'|
awk '{for(i=1;i<=NF;i++)
  {     if(i==NF) {print $i}
   else if(i%2==0){printf $i":"}
     else           {printf $i}
       }
     }'

#linux服务器挂载FC-SAN
存储端：
1.激活HBA接口
2.绑定wwn编号
3.划分lun        #fdisk -l
4.创建group    #lvdisplay
5.绑定lun进group
6.scst服务检查  #scstadmin -list_session      #检查存储端挂载
7.reboot


linux服务器端：
1.lsmod  查看模块使用   lspci  检查硬件   
2.fdisk -l  查看挂载
3.parted       #大于2T分区需要用parted命令进去配置   mklabel GPT   y   sdb1   ext3/4    #redhat5.4只支持3  5.6以上版本支持到4   起始点 0    结束点 根据实际情况  计算单位B   p                                         #查看分区情况   quit  退出  /rm+ID  移除 
4. mkfs.ext3 -F /dev/sdb1        #格式化分区，ext3如果不指定block size的大小为8K最大只能支持到8TB，优选用ext4
    mount /dev/sdb1 /FCsan     #挂载    mount                                    #检查挂载 
    /etc/fstab                               # vi /etc/fstab   #修改配置  手动mount避免失效



</pre>