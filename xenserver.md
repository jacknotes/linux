# xenserver



## xenserver license过期相关信息

```
7.2
License Expiry
XenCenter notifies you when your license is due to expire. You should purchase a license before it expires. When
a XenServer license expires:
• XenCenter License Manager will display the status as Unlicensed.
• you will no longer be able to access licensed features or receive Citrix Technical Support for any host within
the pool until you purchase another license.



6.5.0
License Expiry
XenCenter notifies you when your license is due to expire. You should purchase a license before it expires. When
a XenServer license expires:
• XenCenter License Manager will display the status as Unlicensed.
• you will no longer be able to access licensed features or receive Citrix Technical Support for any host within
the pool until you purchase another license.


6.2.0
This section discusses miscellaneous licensing information, such as upgrading, license expiry and grace periods.
Upgrading to Citrix XenServer 6.2.0 from a Previous Free Edition of Citrix XenServer
After upgrading a XenServer 6.2.0 host or pool from a previous free edition, you will have an unlicensed, but fully
functional edition of XenServer. However, in XenCenter the status will display as Unsupported and you will be
unable to apply hotfixes or other updates using XenCenter.


6.1.0
After you install a XenServer host, it runs as XenServer (Free) for 30 days. After this period, you cannot start
any new, suspended, or powered-off VMs until you activate it (to continue using the free XenServer product) or
configure Citrix Licensing for it (to use XenServer Advanced editions and higher).
```





## xenserver多块硬盘增加及删除方法

```
# 查看新增加的未用陈列硬盘

[root@HOMSOM-XEN08 ~]# ll /dev/disk/by-id/
total 0
lrwxrwxrwx 1 root root  9 Dec 13 15:43 ata-HL-DT-ST_DVD+_-RW_GTA0N_KZGECD90325 -> ../../sr0
lrwxrwxrwx 1 root root 10 Dec 13 15:44 dm-name-VG_XenStorage--00af9ae4--a070--ab02--95c7--107f38b01712-MGT -> ../../dm-0
lrwxrwxrwx 1 root root 10 Dec 13 15:44 dm-uuid-LVM-Gb4woscOkvh2sujjXI6dHv7ZiGIAXz44e2RVuErSpM2Nxp181v814ipSXp8eOYnH -> ../../dm-0
lrwxrwxrwx 1 root root  9 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08 -> ../../sda
lrwxrwxrwx 1 root root 10 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08-part1 -> ../../sda1
lrwxrwxrwx 1 root root 10 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08-part2 -> ../../sda2
lrwxrwxrwx 1 root root 10 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08-part3 -> ../../sda3
lrwxrwxrwx 1 root root 10 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08-part4 -> ../../sda4
lrwxrwxrwx 1 root root 10 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08-part5 -> ../../sda5
lrwxrwxrwx 1 root root 10 Dec 13 17:09 scsi-36b82a720d65c190029434a75cec9cc08-part6 -> ../../sda6
lrwxrwxrwx 1 root root  9 Dec 13 17:24 scsi-36b82a720d65c19002949b51036f8cdf7 -> ../../sdb
lrwxrwxrwx 1 root root  9 Dec 13 15:43 wwn-0x5001480000000000 -> ../../sr0
lrwxrwxrwx 1 root root  9 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08 -> ../../sda
lrwxrwxrwx 1 root root 10 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08-part1 -> ../../sda1
lrwxrwxrwx 1 root root 10 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08-part2 -> ../../sda2
lrwxrwxrwx 1 root root 10 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08-part3 -> ../../sda3
lrwxrwxrwx 1 root root 10 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08-part4 -> ../../sda4
lrwxrwxrwx 1 root root 10 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08-part5 -> ../../sda5
lrwxrwxrwx 1 root root 10 Dec 13 17:09 wwn-0x6b82a720d65c190029434a75cec9cc08-part6 -> ../../sda6
lrwxrwxrwx 1 root root  9 Dec 13 17:24 wwn-0x6b82a720d65c19002949b51036f8cdf7 -> ../../sdb

----创建一个本地存储
[root@HOMSOM-XEN08 ~]# xe sr-create content-type=user device-config:device=/dev/disk/by-id/scsi-36b82a720d65c19002949b51036f8cdf7 name-label="Local Storage 2" shared=false type=lvm
eb1a0693-b702-15ae-6e2b-ef4575bce405

----删除一个本地存储
--查看sr
[root@HOMSOM-XEN08 ~]# xe sr-list uuid=b233727a-ca4b-f244-8ee4-6573e6926138 params=all
uuid ( RO)                    : b233727a-ca4b-f244-8ee4-6573e6926138
              name-label ( RW): Local
        name-description ( RW): 
                    host ( RO): XEN08.RACK06.IDC01.HS.COM
      allowed-operations (SRO): VDI.enable_cbt; VDI.list_changed_blocks; unplug; plug; PBD.create; VDI.disable_cbt; update; PBD.destroy; VDI.resize; VDI.clone; VDI.data_destroy; scan; VDI.snapshot; VDI.mirror; VDI.create; VDI.destroy; VDI.set_on_boot
      current-operations (SRO): 
                    VDIs (SRO): 
                    PBDs (SRO): c6efe80b-8b47-b24b-f70e-143b24cd4257
      virtual-allocation ( RO): 0
    physical-utilisation ( RO): 4194304
           physical-size ( RO): 1199088599040
                    type ( RO): lvm
            content-type ( RO): user
                  shared ( RW): false
           introduced-by ( RO): <not in database>
             is-tools-sr ( RO): false
            other-config (MRW): 
               sm-config (MRO): allocation: thick; use_vhd: true; devserial: scsi-36b82a720d65c19002949b51036f8cdf7
                   blobs ( RO): 
     local-cache-enabled ( RO): false
                    tags (SRW): 
               clustered ( RO): false
--查看pbd
[root@HOMSOM-XEN08 ~]# xe pbd-list sr-uuid=b233727a-ca4b-f244-8ee4-6573e6926138
uuid ( RO)                  : c6efe80b-8b47-b24b-f70e-143b24cd4257
             host-uuid ( RO): de343b8e-dd4c-4277-89ae-30a9a2ba2289
               sr-uuid ( RO): b233727a-ca4b-f244-8ee4-6573e6926138
         device-config (MRO): device: /dev/disk/by-id/scsi-36b82a720d65c19002949b51036f8cdf7
    currently-attached ( RO): true
--pbd卸载
[root@HOMSOM-XEN08 ~]# xe pbd-unplug uuid=c6efe80b-8b47-b24b-f70e-143b24cd4257
--遗忘sr，可以再次挂载，数据不会丢失
[root@HOMSOM-XEN08 ~]# xe sr-forget uuid=b233727a-ca4b-f244-8ee4-6573e6926138
--或者删除sr，数据会丢失
[root@HOMSOM-XEN08 ~]# xe sr-destroy uuid=b233727a-ca4b-f244-8ee4-6573e6926138


#关于xenserver7存储在ext模式下硬盘空间不释放的见解
--去xenserver上找到sr存储路径，并且查询vhd的父vhd，默认每块硬盘有两个vhd，一个为父vhd(原始vhd),一个为子vhd(当前vhd)
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# ll | grep -vE 'file|lost|total' 
-rw------- 1 root root    342569472 Jul  8  2021 1469dfb6-a7dd-44e9-a4fa-8216d4804931.vhd
-rw------- 1 root root  78668792320 Jan 11 11:38 21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd
-rw------- 1 root root  21497909760 Jul  8  2021 549d6f6b-8d11-405a-b5f9-c2b9b3d56b51.vhd
-rw------- 1 root root  17549668352 Jan 11 11:36 55116021-4fb3-4747-a641-cb43eb412a4c.vhd
-rw------- 1 root root  40098222592 Jul  8  2021 5c9736b1-bb61-4cec-ba85-d31f4300abe6.vhd
-rw------- 1 root root 172138566144 Jan 10 17:45 615a37d7-fd09-432f-811e-1c6409e08e68.vhd
-rw------- 1 root root  53726917120 Jul  8  2021 6f017c88-58ed-4e09-96ed-b280d6035ef7.vhd
-rw------- 1 root root  64325632512 Jan 10 16:43 730ac751-4df0-4162-80de-78eb25c33679.vhd
-rw------- 1 root root     35848704 Jan 11 11:38 78fd3206-3b43-4c44-bd81-87637e18c138.vhd
-rw------- 1 root root     18977280 Nov 24 08:52 7a42f601-3c4d-42c5-8b9c-f86dba3b9aec.vhd
-rw------- 1 root root 107497959936 Jan 10 16:31 7e114764-1cd4-4014-b099-4fd270ab312b.vhd
-rw------- 1 root root  53565141504 Jan 11 11:38 7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd
-rw------- 1 root root  22912221184 Jan 10 17:49 833251ae-50e4-4b61-9b24-7c197c6b70dc.vhd
-rw------- 1 root root   3725639680 Jan 11 11:43 96d692e2-65bf-4b30-be7d-26e170d42dfd.vhd
-rw------- 1 root root   6362791936 Jan 11 11:43 992416ee-4a5b-4531-a7d0-1c2e4b675d40.vhd
-rw------- 1 root root  94817054720 Jan 11 10:31 b09e407e-3396-4d0d-8069-83488d74e9da.vhd
-rw------- 1 root root    380497920 Jan 11 11:43 c623713d-fd2a-4978-a09f-e57a5acbc84c.vhd
-rw------- 1 root root   8632033280 Jan 11 11:43 f4962308-120d-42fd-9fc5-f688417c02ff.vhd
-rw------- 1 root root  16295284736 Jan 11 11:43 f7473fd6-c9d1-477e-b614-241c06704495.vhd
-rw------- 1 root root  24519676416 Nov 30 09:20 fb466d15-e997-4f62-9f85-026d87c3ae90.vhd

#--快照硬盘状态
o(原始点，父vhd)----o(当前点，子vhd)

1. 在当前点做快照时硬盘状态是这样的
   o(原始点，父vhd)----o(旧当前点快照状态，子vhd)-----o(新当前点，子vhd)
   					|
   					|----------------------o(新当前点的副本快照，子vhd)
   注：当创建第一个快照时，会多出两个vhd，当在第二次及以后创建快照时每次增加一个vhd

--查看vhd的父硬盘
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# for i in `ls`;do echo "name: $i";vhd-util query -n $i -p;done
name: 058e2341-0428-4c32-a950-f0b2c635d44c.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd
name: 1469dfb6-a7dd-44e9-a4fa-8216d4804931.vhd
1469dfb6-a7dd-44e9-a4fa-8216d4804931.vhd has no parent
name: 21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd
21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd has no parent
name: 23a7ac62-8f1d-42b5-85f2-a6df1e640adb.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd
name: 343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd
name: 549d6f6b-8d11-405a-b5f9-c2b9b3d56b51.vhd
549d6f6b-8d11-405a-b5f9-c2b9b3d56b51.vhd has no parent
name: 54d4e352-b9e4-43c1-bdef-c25db8673502.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/23a7ac62-8f1d-42b5-85f2-a6df1e640adb.vhd
name: 55116021-4fb3-4747-a641-cb43eb412a4c.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/549d6f6b-8d11-405a-b5f9-c2b9b3d56b51.vhd
name: 5c9736b1-bb61-4cec-ba85-d31f4300abe6.vhd
5c9736b1-bb61-4cec-ba85-d31f4300abe6.vhd has no parent
name: 615a37d7-fd09-432f-811e-1c6409e08e68.vhd
615a37d7-fd09-432f-811e-1c6409e08e68.vhd has no parent
name: 6f017c88-58ed-4e09-96ed-b280d6035ef7.vhd
6f017c88-58ed-4e09-96ed-b280d6035ef7.vhd has no parent
name: 730ac751-4df0-4162-80de-78eb25c33679.vhd
730ac751-4df0-4162-80de-78eb25c33679.vhd has no parent
name: 78fd3206-3b43-4c44-bd81-87637e18c138.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/23a7ac62-8f1d-42b5-85f2-a6df1e640adb.vhd
name: 7a42f601-3c4d-42c5-8b9c-f86dba3b9aec.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/1469dfb6-a7dd-44e9-a4fa-8216d4804931.vhd
name: 7e114764-1cd4-4014-b099-4fd270ab312b.vhd
7e114764-1cd4-4014-b099-4fd270ab312b.vhd has no parent
name: 7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd
7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd has no parent
name: 833251ae-50e4-4b61-9b24-7c197c6b70dc.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/7e114764-1cd4-4014-b099-4fd270ab312b.vhd
name: 96d692e2-65bf-4b30-be7d-26e170d42dfd.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/730ac751-4df0-4162-80de-78eb25c33679.vhd
name: 992416ee-4a5b-4531-a7d0-1c2e4b675d40.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/fb466d15-e997-4f62-9f85-026d87c3ae90.vhd
name: b09e407e-3396-4d0d-8069-83488d74e9da.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/615a37d7-fd09-432f-811e-1c6409e08e68.vhd
name: c623713d-fd2a-4978-a09f-e57a5acbc84c.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd
name: f4962308-120d-42fd-9fc5-f688417c02ff.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/5c9736b1-bb61-4cec-ba85-d31f4300abe6.vhd
name: f7473fd6-c9d1-477e-b614-241c06704495.vhd
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/6f017c88-58ed-4e09-96ed-b280d6035ef7.vhd
name: fb466d15-e997-4f62-9f85-026d87c3ae90.vhd
fb466d15-e997-4f62-9f85-026d87c3ae90.vhd has no parent

--以一个虚拟机为例，有两块硬盘，一块为80G，一块为60G，当第一次创建完快照后，在xenserver存储中有4个vhd，此时chain depth有3级，分别为1，2，3，为1级为2级父类，2级为3级父类，而2级有两个子类，这里只罗列出了一个子类，这两个子类状态是相互副本快照状态
------80G硬盘
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# vhd-util query -n c623713d-fd2a-4978-a09f-e57a5acbc84c.vhd -vspfmdS
81920
294347264
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd
hidden: 0
marker: 0
chain depth: 3
81920
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# vhd-util query -n 343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd -vspfmdS
81920
26814198272
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd
hidden: 1
marker: 0
chain depth: 2
81920
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# vhd-util query -n 21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd -vspfmdS
81920
78622564864
21f3681a-61c3-4ecd-a1f5-a098057184b3.vhd has no parent
hidden: 1
marker: 0
chain depth: 1
81920
-----计算实际占用大小
PS C:\Users\0799> 294347264+26814198272+78622564864
105731110400
PS C:\Users\0799> 105731110400/1024/1024/1024
98.4697699546814
-------60G硬盘
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# vhd-util query -vspfmdS -n 78fd3206-3b43-4c44-bd81-87637e18c138.vhd 
61440
37949952
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/23a7ac62-8f1d-42b5-85f2-a6df1e640adb.vhd
hidden: 0
marker: 0
chain depth: 3
61440
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# vhd-util query -vspfmdS -n 23a7ac62-8f1d-42b5-85f2-a6df1e640adb.vhd
61440
21096657408
/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd
hidden: 1
marker: 0
chain depth: 2
61440
[root@Xen07 3828a230-7009-569b-5135-9a70e14ee235]# vhd-util query -vspfmdS -n 7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd
61440
53565141504
7f9ee488-1169-4b92-ad12-027383e1cfe4.vhd has no parent
hidden: 1
marker: 0
chain depth: 1
61440
-------计算实际占用大小
PS C:\Users\0799> 37949952+21096657408+53565141504
74699748864
PS C:\Users\0799> 74699748864/1024/1024/1024

69.5695624351501
-------

--当在xencenter上删除快照后过段时间，xenserver会执行在线合并，捕捉到的命令如下
/usr/bin/vhd-util coalesce --debug -n /var/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd
/usr/bin/vhd-util coalesce --debug -n /var/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/23a7ac62-8f1d-42b5-85f2-a6df1e640adb.vhd
注：当删除完快照后状态如下:

1. 删除快照前硬盘状态：
   o(原始点，父vhd)----o(旧当前点快照状态，子vhd)-----o(新当前点，子vhd)
   					|
   					|----------------------o(新当前点的副本快照，子vhd)
2. 删除快照后硬盘状态：
   o(原始点，父vhd)----o(旧当前点快照状态，子vhd)-----o(新当前点，子vhd)
   注：当快照全部删除完后，会有3个vhd，此时xenserver会对"o(旧当前点快照状态，子vhd)"进行在线合并操作，应该就是命令/usr/bin/vhd-util coalesce --debug -n /var/run/sr-mount/3828a230-7009-569b-5135-9a70e14ee235/343fcd8f-10ac-4fe1-9d8b-1e64eaaa715e.vhd，此命令未在生产上实验通过，忽操作，让xenserver自己执行在线合并即可，

3. xenserver执行在线合并完成后状态：
   o(原始点，父vhd)--------o(新当前点，子vhd)
   
   
--查看sr
[root@homsom-xen02 ~]# xe sr-list 
--查看vbd，可以看出所属VM
[root@homsom-xen02 ~]# xe vbd-list params=all
--查看vdi
[root@homsom-xen02 ~]# xe vdi-list | grep 'c373679adec5'
uuid ( RO)                : 33b45e2d-1bd0-412d-837f-c373679adec5
[root@homsom-xen02 ~]# xe vdi-list uuid=33b45e2d-1bd0-412d-837f-c373679adec5 params=all

[root@Xen07 ~]# xe sr-list uuid=3828a230-7009-569b-5135-9a70e14ee235 params=all
uuid ( RO)                    : 3828a230-7009-569b-5135-9a70e14ee235
              name-label ( RW): Local storage
        name-description ( RW): 
                    host ( RO): Xen07.rack05.idc01.hs.com
      allowed-operations (SRO): unplug; plug; PBD.create; update; PBD.destroy; VDI.resize; VDI.clone; scan; VDI.snapshot; VDI.create; VDI.destroy
      current-operations (SRO): 
                    VDIs (SRO): 9efd85d9-b9fa-4111-9e1b-9fa08763e801; 7e114764-1cd4-4014-b099-4fd270ab312b; 833251ae-50e4-4b61-9b24-7c197c6b70dc; 21f3681a-61c3-4ecd-a1f5-a098057184b3; c623713d-fd2a-4978-a09f-e57a5acbc84c; 7f9ee488-1169-4b92-ad12-027383e1cfe4; 78fd3206-3b43-4c44-bd81-87637e18c138; 7a42f601-3c4d-42c5-8b9c-f86dba3b9aec; 615a37d7-fd09-432f-811e-1c6409e08e68; 5c9736b1-bb61-4cec-ba85-d31f4300abe6; fb466d15-e997-4f62-9f85-026d87c3ae90; 1469dfb6-a7dd-44e9-a4fa-8216d4804931; f4962308-120d-42fd-9fc5-f688417c02ff; 96d692e2-65bf-4b30-be7d-26e170d42dfd; 549d6f6b-8d11-405a-b5f9-c2b9b3d56b51; 6f017c88-58ed-4e09-96ed-b280d6035ef7; 730ac751-4df0-4162-80de-78eb25c33679; f7473fd6-c9d1-477e-b614-241c06704495; 992416ee-4a5b-4531-a7d0-1c2e4b675d40; b09e407e-3396-4d0d-8069-83488d74e9da; 55116021-4fb3-4747-a641-cb43eb412a4c
                    PBDs (SRO): 4ddca929-5c4f-dd2a-6fec-076b155f442b
      virtual-allocation ( RO): 5497558138880
    physical-utilisation ( RO): 823705546752
           physical-size ( RO): 1135087456256
                    type ( RO): ext
            content-type ( RO): user
                  shared ( RW): false
           introduced-by ( RO): <not in database>
             is-tools-sr ( RO): false
            other-config (MRW): i18n-original-value-name_label: Local storage; i18n-key: local-storage
               sm-config (MRO): last-coalesce-error: 1615371039; devserial: scsi-361866da0bcfcd400211b52f306011d06
                   blobs ( RO): 
     local-cache-enabled ( RO): true
                    tags (SRW): 
               clustered ( RO): false


[root@Xen07 ~]# xe pbd-list uuid=4ddca929-5c4f-dd2a-6fec-076b155f442b params=all
uuid ( RO)                  : 4ddca929-5c4f-dd2a-6fec-076b155f442b
     host ( RO) [DEPRECATED]: 5f2572ba-4aee-4c4e-8342-ce7fda9725a9
             host-uuid ( RO): 5f2572ba-4aee-4c4e-8342-ce7fda9725a9
       host-name-label ( RO): Xen07.rack05.idc01.hs.com
               sr-uuid ( RO): 3828a230-7009-569b-5135-9a70e14ee235
         sr-name-label ( RO): Local storage
         device-config (MRO): device: /dev/disk/by-id/scsi-361866da0bcfcd400211b52f306011d06-part3
    currently-attached ( RO): true
          other-config (MRW): storage_driver_domain: OpaqueRef:316b74cd-39e7-5708-d0c4-ab12f7850d28


[root@Xen07 ~]# xe vdi-list uuid=55116021-4fb3-4747-a641-cb43eb412a4c params=all
uuid ( RO)                    : 55116021-4fb3-4747-a641-cb43eb412a4c
              name-label ( RW): Homsom-server190 disk D
        name-description ( RW): 
           is-a-snapshot ( RO): false
             snapshot-of ( RO): <not in database>
               snapshots ( RO): 
           snapshot-time ( RO): 20200715T10:52:28Z
      allowed-operations (SRO): clone; snapshot
      current-operations (SRO): 
                 sr-uuid ( RO): 3828a230-7009-569b-5135-9a70e14ee235
           sr-name-label ( RO): Local storage
               vbd-uuids (SRO): aa9dc11e-8ff5-11c7-31ac-a4bb833af1cf
         crashdump-uuids (SRO): 
            virtual-size ( RO): 21474836480
    physical-utilisation ( RO): 67285504
                location ( RO): 55116021-4fb3-4747-a641-cb43eb412a4c
                    type ( RO): User
                sharable ( RO): false
               read-only ( RO): false
            storage-lock ( RO): false
                 managed ( RO): true
                  parent ( RO): <not in database>
                 missing ( RO): false
            is-tools-iso ( RO): false
            other-config (MRW): 
           xenstore-data (MRO): 
               sm-config (MRO): host_OpaqueRef:52745089-d670-a71a-c5b2-9aa3cf2fa15f: RW; read-caching-reason-5f2572ba-4aee-4c4e-8342-ce7fda9725a9: LICENSE_RESTRICTION; read-caching-enabled-on-5f2572ba-4aee-4c4e-8342-ce7fda9725a9: false; vhd-parent: 549d6f6b-8d11-405a-b5f9-c2b9b3d56b51
                 on-boot ( RW): persist
           allow-caching ( RW): false
         metadata-latest ( RO): false
        metadata-of-pool ( RO): <not in database>
                    tags (SRW): 
            

[root@Xen07 ~]# xe vbd-list uuid=aa9dc11e-8ff5-11c7-31ac-a4bb833af1cf params=all
uuid ( RO)                        : aa9dc11e-8ff5-11c7-31ac-a4bb833af1cf
                     vm-uuid ( RO): 436c3d59-e53d-5862-ad2f-3f6a26d7a430
               vm-name-label ( RO): lunxun.Xen07.rack05.idc01.hs.com-192.168.13.194-备用服务器
                    vdi-uuid ( RO): 55116021-4fb3-4747-a641-cb43eb412a4c
              vdi-name-label ( RO): Homsom-server190 disk D
          allowed-operations (SRO): attach; unpause; unplug; unplug_force; pause
          current-operations (SRO): 
                       empty ( RO): false
                      device ( RO): xvdb
                  userdevice ( RW): 1
                    bootable ( RW): false
                        mode ( RW): RW
                        type ( RW): Disk
                 unpluggable ( RW): true
          currently-attached ( RO): true
                  attachable ( RO): <expensive field>
                storage-lock ( RO): false
                 status-code ( RO): 0
               status-detail ( RO): 
          qos_algorithm_type ( RW): 
        qos_algorithm_params (MRW): 
    qos_supported_algorithms (SRO): 
                other-config (MRW): owner: true
                 io_read_kbs ( RO): <expensive field>


[root@Xen07 ~]# xe vm-list uuid=436c3d59-e53d-5862-ad2f-3f6a26d7a430
uuid ( RO)           : 436c3d59-e53d-5862-ad2f-3f6a26d7a430
     name-label ( RW): lunxun.Xen07.rack05.idc01.hs.com-192.168.13.194-备用服务器
    power-state ( RO): running
```








## 增加控制域内存


[xenserver7手册](https://docs.xenserver.com/zh-cn/xenserver/7-0/downloads/administrators-guide.pdf)

```bash
# 通过root用户连接到xenserver主机，使用此命令配置xenserver控制域内存，需要重启xenserver生效
# 其中 <nn> 代表分配给 dom0 的内存量（以 MB 为单位）。
/opt/xensource/libexec/xen-cmdline --set-xen dom0_mem=<nn>M,max:<nn>M
```





## 配置虚拟机随系统自动启动

```bash
# 设置XenServer开启自动启动功能
[root@XEN01 ~]# xe pool-list
uuid ( RO)                : c33a1c52-75e2-7cfe-3a91-138b886c951a
          name-label ( RW): 
    name-description ( RW): 
              master ( RO): 82148d13-c2ee-4ede-8825-82338283787a
          default-SR ( RW): 5c0169d0-b82d-8176-ab2d-0be369317d0d


[root@XEN01 ~]# xe pool-list params=all | grep other-config
                    other-config (MRW): memory-ratio-hvm: 0.25; memory-ratio-pv: 0.25


[root@XEN01 ~]# xe pool-param-set uuid=c33a1c52-75e2-7cfe-3a91-138b886c951a other-config:auto_poweron=true
[root@XEN01 ~]# xe pool-list params=all | grep other-config
                    other-config (MRW): auto_poweron: true; memory-ratio-hvm: 0.25; memory-ratio-pv: 0.25



# 设置虚拟机随XenServer系统自动启动
[root@XEN01 ~]# xe vm-list 
uuid ( RO)           : e4d3e382-b1a3-4c05-b974-ac0d25a43def
     name-label ( RW): Control domain on host: XEN01.RACK06.IDC01.HS.COM
    power-state ( RO): running


uuid ( RO)           : a797c79b-898c-b58a-d8fe-461029a1da43
     name-label ( RW): WebBackup-XenLicenseServer.xen01.rack06.hs.com-192.168.13.72
    power-state ( RO): running


uuid ( RO)           : 6f2a290a-7923-e4eb-f281-4a92a3903a0c
     name-label ( RW): wsus02.xen01.rack06.idc01.hs.com-192.168.13.73
    power-state ( RO): running


[root@XEN01 ~]# xe vm-list params=all | grep other-config
                          other-config (MRW): base_template_name: Windows Server 2008 R2 (64-bit); import_task: OpaqueRef:1c7c7441-8516-40a5-b727-7aa35fc5760e; mac_seed: 212466be-ff89-e99a-41c1-18deb6e59e25; install-methods: cdrom
                          other-config (MRW): base_template_name: Windows Server 2019 (64-bit); import_task: OpaqueRef:5b1ae095-d5df-4a1d-b660-99ce164d3348; mac_seed: 2e59b3fd-a03e-5266-9c91-26c3773a5d8c; install-methods: cdrom

# 添加自动启动配置
for i in `xe vm-list params=uuid --minimal | sed 's/,/ /g'`;do xe vm-param-set uuid=$i other-config:auto_poweron=true;done

[root@XEN01 ~]# xe vm-list params=other-config
other-config (MRW)    : auto_poweron: true; storage_driver_domain: OpaqueRef:128c4b27-c794-4df1-8d7a-aa6c607719e5; is_system_domain: true; perfmon: <config><variable><name value="fs_usage"/><alarm_trigger_level value="0.9"/><alarm_trigger_period value="60"/><alarm_auto_inhibit_period value="3600"/></variable><variable><name value="mem_usage"/><alarm_trigger_level value="0.95"/><alarm_trigger_period value="60"/><alarm_auto_inhibit_period value="3600"/></variable><variable><name value="log_fs_usage"/><alarm_trigger_level value="0.9"/><alarm_trigger_period value="60"/><alarm_auto_inhibit_period value="3600"/></variable></config>


other-config (MRW)    : auto_poweron: true; base_template_name: Windows Server 2008 R2 (64-bit); import_task: OpaqueRef:1c7c7441-8516-40a5-b727-7aa35fc5760e; mac_seed: 212466be-ff89-e99a-41c1-18deb6e59e25; install-methods: cdrom


other-config (MRW)    : auto_poweron: true; base_template_name: Windows Server 2019 (64-bit); import_task: OpaqueRef:5b1ae095-d5df-4a1d-b660-99ce164d3348; mac_seed: 2e59b3fd-a03e-5266-9c91-26c3773a5d8c; install-methods: cdrom

# 移除自动启动配置
xe vm-param-remove uuid=虚拟机UUID param-name=other-config param-key=auto_poweron


## 批量配置自动开机启动
# 1 
for i in `xe pool-list params=uuid --minimal | sed 's/,/ /g'`;do xe pool-param-set uuid=$i other-config:auto_poweron=true;done 
xe pool-list params=other-config

# 2
for i in `xe vm-list params=uuid --minimal | sed 's/,/ /g'`;do xe vm-param-set uuid=$i other-config:auto_poweron=true;done
xe vm-list params=other-config

```

