--vsrsion: lsyncd 2.2.2
--depend: lua lua-devel rsync

--install
--yum install lua lua-devel rsync lsyncd -y
--change set configure.txt
--chkconfig --levels 35 lsyncd on

settings {
    logfile ="/var/log/lsyncd/lsyncd.log",
    statusFile ="/var/run/lsyncd/lsyncd.status",
    inotifyMode = "CloseWrite",
    maxProcesses = 1,
    }

--本地复制同步
sync {
    default.rsync,
    source    = "/root/src",
    target    = "/root/dst",
    excludeFrom = "/usr/local/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true,
    --    bwlimit   = 2000    --是否限制和设置带宽大小
        } 
    }


sync {
    default.rsyncssh,
    source    = "/usr/local/nginx/conf",
    host      = "192.168.1.233",
    targetdir = "/usr/local/nginx/conf",
    excludeFrom = "/usr/local/lsyncd/lsyncd_exclude.lst",
    maxDelays = 0,  --所监控的事件累计到多少次激活一次同步，即使后面的delay延迟时间还未到
    delay = 0,   --等待rsync同步延时时间，默认15秒同步一次，15s内两次修改了同一文件，最后只同步最新的文件
    init = false, --为true表示当服务启动后也同步启动前的更改，为false则表示只同步启动后的更改
    rsync    = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true,
        verbose   = true,
       -- _extra = {"--bwlimit=2000"},  --是否限制和设置带宽大小
        },
    ssh      = {   --需要使用无密证书认证
        port  =  22
        }
    }


<pre>
#20210714
[root@prometheus lsyncd]# cat /etc/lsyncd.conf
----
-- User configuration file for lsyncd.
--
-- Simple example for default rsync, but executing moves through on the target.
--
-- For more examples, see /usr/share/doc/lsyncd*/examples/
-- 

settings {
    logfile ="/var/log/lsyncd/lsyncd.log",
    statusFile ="/var/run/lsyncd/lsyncd.status",
    inotifyMode = "CloseWrite or Modify",
    maxProcesses = 1,
}

sync {
    default.rsync,
    source    = "/etc/grafana",
    target    = "/backup/remoteLocal/grafana",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

sync {
    default.rsync,
    source    = "/usr/local/prometheus",
    target    = "/backup/remoteLocal/prometheus",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

sync {
    default.rsync,
    source    = "/usr/local/alertmanager",
    target    = "/backup/remoteLocal/alertmanager",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

sync {
    default.rsync,
    source    = "/usr/local/blackbox_exporter",
    target    = "/backup/remoteLocal/blackbox_exporter",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

sync {
    default.rsync,
    source    = "/usr/local/consul",
    target    = "/backup/remoteLocal/consul",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

sync {
    default.rsync,
    source    = "/usr/local/snmp_exporter",
    target    = "/backup/remoteLocal/snmp_exporter",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

sync {
    default.rsync,
    source    = "/usr/local/snmp_exporter-two",
    target    = "/backup/remoteLocal/snmp_exporter-two",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

--systemd service backup
sync {
    default.rsync,
    source    = "/usr/lib/systemd/system",
    target    = "/backup/remoteLocal/systemd-service",
    excludeFrom = "/etc/lsyncd/lsyncd_exclude.lst",
    rsync     = {
        binary = "/usr/bin/rsync",
        archive = true,
        compress = true
    } 
}

注：source路径下文件名称不能带":"冒号，否则会导致同步失败


</pre>