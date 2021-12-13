#xenserver

<pre>
#xenserver license过期相关信息
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



#xenserver多块硬盘增加及删除方法
--查看新增加的未用陈列硬盘
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
[root@HOMSOM-XEN08 ~]# [root@HOMSOM-XEN08 ~]# xe sr-create content-type=user device-config:device=/dev/disk/by-id/scsi-36b82a720d65c19002949b51036f8cdf7 name-label="Local Storage 2" shared=false type=lvm
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
[root@HOMSOM-XEN08 ~]# xe sr-forget uuid=b233727a-ca4b-f244-8ee4-6573e6926138


</pre>
