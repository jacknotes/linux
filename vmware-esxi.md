#vmware esxi
<pre>
#snapshot shell
[root@esxi01:~] cat /vmfs/volumes/datastore1/jackli/snapshot-manager.sh 
--------------------------------------------------------
#!/bin/sh

LOGFILE=/vmfs/volumes/datastore1/jackli/autosnapshot.log
DAY=1

echo "start time: $(date +'%Y%m%d%H%M%S')" >> $LOGFILE

for vmid in $(vim-cmd vmsvc/getallvms | grep 'testnginx.esxi01.rack05.hs.com-192.168.13.230' | awk '{print $1}' | grep -e "[0-9]")
do
	#create snapshot step
	SNAPSHOT_TIME_OF_NAME=$(date +'%Y%m%d%H%M%S')
	echo "CREATE SNAPSHOT for VMID: $vmid of SNAPSHOTNAME: $SNAPSHOT_TIME_OF_NAME......" >> $LOGFILE
	vim-cmd vmsvc/snapshot.create $vmid $SNAPSHOT_TIME_OF_NAME autosnapshot 1 1 > /dev/null
	a=0;
	while [ $a == 0 ];do
		vim-cmd vmsvc/snapshot.get $vmid | grep $SNAPSHOT_TIME_OF_NAME > /dev/null
		if [ $? == 0 ];then 
			let a++
		fi;
		sleep 1;
	done	
	
	#delete snapshot step
	SNAPSHOT_COUNT=$(vim-cmd vmsvc/snapshot.get $vmid | grep 'Snapshot Id' | wc -l)
	if [ $SNAPSHOT_COUNT -gt $DAY ]; then
		let NUM=$SNAPSHOT_COUNT-$DAY
		OLD_SNAPSHOT_ID=$(vim-cmd vmsvc/snapshot.get $vmid | grep 'Snapshot Id' | head -$NUM | awk -F: '{print $2}')
		for single_snapshot_id in $OLD_SNAPSHOT_ID
		do
			echo "DELETE VMID: $vmid for SNAPSHOT ID: $single_snapshot_id....." >> $LOGFILE
			vim-cmd vmsvc/snapshot.remove $vmid $single_snapshot_id > /dev/null
			[ $? == 0 ] && echo "DELETE Succeeded" >> $LOGFILE || echo "DELETE Failed" >> $LOGFILE
		done
	fi
done

echo "end time: $(date +'%Y%m%d%H%M%S')" >> $LOGFILE
echo "" >> $LOGFILE
--------------------------------------------------------


#vmware esxi host config auto boot
[root@esxi01:~] /bin/echo '0    18   */7 *   *   /vmfs/volumes/datastore1/jackli/snapshot-manager.sh' >> /var/spool/cron/crontabs/root
[root@esxi01:~] vi /etc/rc.local.d/local.sh
--------------------------------------------------------
/bin/echo '0    18   */7 *   *   /vmfs/volumes/datastore1/jackli/snapshot-manager.sh' >> /var/spool/cron/crontabs/root
exit 0
--------------------------------------------------------

#execute save config in /etc/rc.local/local.sh to system
[root@esxi01:~] /sbin/auto-backup.sh
--------------------------------------------------------
--- /etc/rc.local.d/local.sh
+++ /tmp/auto-backup.4920819//etc/rc.local.d/local.sh
@@ -1,16 +0,0 @@
-#!/bin/sh
-
-# local configuration options
-
-# Note: modify at your own risk!  If you do/use anything in this
-# script that is not part of a stable API (relying on files to be in
-# specific places, specific tools, specific output, etc) there is a
-# possibility you will end up with a broken system after patching or
-# upgrading.  Changes are not supported unless under direction of
-# VMware support.
-
-# Note: This script will not be run when UEFI secure boot is enabled.
-
-/bin/echo '0    18   */7 *   *   /vmfs/volumes/datastore1/jackli/snapshot-manager.sh' >> /var/spool/cron/crontabs/root
-
-exit 0
Saving current state in /bootbank
Clock updated.
Time: 06:16:27   Date: 01/18/2022   UTC
--------------------------------------------------------

[root@esxi01:~] cat /var/spool/cron/crontabs/root 
#min hour day mon dow command
1    1    *   *   *   /sbin/tmpwatch.py
1    *    *   *   *   /sbin/auto-backup.sh
0    *    *   *   *   /usr/lib/vmware/vmksummary/log-heartbeat.py
*/5  *    *   *   *   /bin/hostd-probe.sh ++group=host/vim/vmvisor/hostd-probe/stats/sh
00   1    *   *   *   localcli storage core device purge
0    18   */7 *   *   /vmfs/volumes/datastore1/jackli/snapshot-manager.sh


</pre>
