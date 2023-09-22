# lvs部署




## 环境


```bash
test-lvs01			172.168.2.31
test-lvs02			172.168.2.32
test-lvs-VIP		172.168.2.33
test-nginx01		172.168.2.34
test-nginx02		172.168.2.35
```


## 查看内核是否支持IPVS

```bash
[root@test-lvs02 ~]# grep -i 'vs' /boot/config-3.10.0-1160.95.1.el7.x86_64
CONFIG_GENERIC_TIME_VSYSCALL=y
# CONFIG_X86_VSMP is not set
CONFIG_NETFILTER_XT_MATCH_IPVS=m
CONFIG_IP_VS=m
CONFIG_IP_VS_IPV6=y
# CONFIG_IP_VS_DEBUG is not set
CONFIG_IP_VS_TAB_BITS=12
# IPVS transport protocol load balancing support
CONFIG_IP_VS_PROTO_TCP=y
CONFIG_IP_VS_PROTO_UDP=y
CONFIG_IP_VS_PROTO_AH_ESP=y
CONFIG_IP_VS_PROTO_ESP=y
CONFIG_IP_VS_PROTO_AH=y
CONFIG_IP_VS_PROTO_SCTP=y
# IPVS scheduler
CONFIG_IP_VS_RR=m
CONFIG_IP_VS_WRR=m
CONFIG_IP_VS_LC=m
CONFIG_IP_VS_WLC=m
CONFIG_IP_VS_LBLC=m
CONFIG_IP_VS_LBLCR=m
CONFIG_IP_VS_DH=m
CONFIG_IP_VS_SH=m
CONFIG_IP_VS_SED=m
CONFIG_IP_VS_NQ=m
# IPVS SH scheduler
CONFIG_IP_VS_SH_TAB_BITS=8
# IPVS application helper
CONFIG_IP_VS_FTP=m
CONFIG_IP_VS_NFCT=y
CONFIG_IP_VS_PE_SIP=m
CONFIG_OPENVSWITCH=m
CONFIG_OPENVSWITCH_GRE=m
CONFIG_OPENVSWITCH_VXLAN=m
CONFIG_OPENVSWITCH_GENEVE=m
CONFIG_VSOCKETS=m
CONFIG_VSOCKETS_DIAG=m
CONFIG_VMWARE_VMCI_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS=m
CONFIG_VIRTIO_VSOCKETS_COMMON=m
CONFIG_HYPERV_VSOCKETS=m
CONFIG_MTD_BLKDEVS=m
CONFIG_SCSI_MVSAS=m
# CONFIG_SCSI_MVSAS_DEBUG is not set
CONFIG_SCSI_MVSAS_TASKLET=y
CONFIG_VMWARE_PVSCSI=m
CONFIG_VSOCKMON=m
CONFIG_VHOST_VSOCK=m
CONFIG_MOUSE_VSXXXAA=m
CONFIG_MAX_RAW_DEVS=8192
# CONFIG_POWER_AVS is not set
CONFIG_USB_SEVSEG=m
```


## 初始化各节点配置

```bash
root@ansible:/etc/ansible/roles# cat ../playbook/base.yml
---
- hosts:
  - 172.168.2.31
  - 172.168.2.32
  - 172.168.2.34
  - 172.168.2.35
  remote_user: root
  become: yes
  gather_facts: true
  roles:
  - base

root@ansible:/etc/ansible/roles# ansible-playbook /etc/ansible/playbook/base.yml
```


## IPVS管理工具安装

```bash
[root@test-lvs01 ~]# yum install ipvsadm -y
[root@test-lvs02 ~]# yum install ipvsadm -y

注：各节点之间的时间偏差不应该超出1秒钟
```


## IPVS常用命令

```bash

```



