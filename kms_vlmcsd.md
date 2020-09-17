--windows激活方法
<pre>
 slmgr.vbs -upk
 slmgr.vbs -ipk XXXXX-XXXXX-XXXXX-XXXXX-XXXXX //填入自己Windows版本对应的密钥
 slmgr.vbs -skms 192.168.1.1 //这个IP地址是你KMS服务器的地址
 slmgr.vbs -ato
 slmgr.vbs -dlv

如果不想用kms了，可以重置回原来的状态
slmgr.vbs -ckms  //清除系统KMS信息
slmgr.vbs -rearm //重置计算机的授权状态
</pre>


--office激活方法
<pre>
首先你的OFFICE必须是VOL版本，否则无法激活。 找到你的office安装目录，比如
C:\Program Files (x86)\Microsoft Office\Office16
64位的就是
C:\Program Files\Microsoft Office\Office16
office16是office2016，office15就是2013，office14就是2010.

cd C:\Program Files (x86)\Microsoft Office\Office16
// cscript ospp.vbs /setprt:1688
cscript ospp.vbs /sethst:192.168.1.1 //这个IP地址是你KMS服务器的地址
/sethst参数就是指定kms服务器地址。
一般ospp.vbs可以拖进去cmd窗口，所以也可以这么弄：
cscript "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS" /sethst:192.168.1.1 //这个IP地址是你KMS服务器的地址
一般来说，“一句命令已经完成了”，但一般office不会马上连接kms服务器进行激活，所以我们额外补充一条手动激活命令：
cscript ospp.vbs /act
如果提示看到successful的字样，那么就是激活成功了，重新打开office就好。
检查激活状态：
cscript ospp.vbs /dstatus

如果遇到报错，请检查：
你的系统/OFFICE是否是批量VL版本
是否以管理员权限运行CMD
你的系统/OFFICE是否修改过KEY/未安装GVLK KEY
检查你的网络连接
服务器繁忙，多试试（点击检查KMS服务是否可用）
根据出错代码自己搜索出错原因
</pre>
