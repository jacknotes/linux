net.ipv4.ip_local_port_range:    #客户端打口随机端口范围
  sysctl.present:
    - value: 10000 65000
net.ipv4.ip_forward: 
  sysctl.present:
    - value: 1
net.ipv6.conf.all.disable_ipv6:
  sysctl.present:
    - value: 1
net.ipv6.conf.default.disable_ipv6:
  sysctl.present:
    - value: 1
net.ipv4.icmp_echo_ignore_broadcasts:
  sysctl.present:
    - value: 1
net.ipv4.icmp_ignore_bogus_error_responses:
  sysctl.present:
    - value: 1
net.ipv4.conf.all.send_redirects:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.send_redirects:
  sysctl.present:
    - value: 0
net.ipv4.conf.all.rp_filter:
  sysctl.present:
    - value: 1
net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 1
net.ipv4.conf.all.accept_source_route:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.accept_source_route:
  sysctl.present:
    - value: 0
kernel.sysrq:
  sysctl.present:
    - value: 0
kernel.core_uses_pid:
  sysctl.present:
    - value: 1
net.ipv4.tcp_syncookies:
  sysctl.present:
    - value: 1
kernel.msgmnb:
  sysctl.present:
    - value: 65536
kernel.msgmax:
  sysctl.present:
    - value: 65536
kernel.shmmax:
  sysctl.present:
    - value: 68719476736
kernel.shmall:
  sysctl.present:
    - value: 4294967296
net.ipv4.tcp_max_tw_buckets:
  sysctl.present:
    - value: 6000
net.ipv4.tcp_sack:
  sysctl.present:
    - value: 1
net.ipv4.tcp_window_scaling:
  sysctl.present:
    - value: 1
net.ipv4.tcp_rmem:
  sysctl.present:
    - value: 4096        87380   4194304
net.ipv4.tcp_wmem:
  sysctl.present:
    - value: 4096        16384   4194304
net.core.wmem_default:
  sysctl.present:
    - value: 8388608
net.core.rmem_default:
  sysctl.present:
    - value: 8388608
net.core.rmem_max:
  sysctl.present:
    - value: 16777216
net.core.wmem_max:
  sysctl.present:
    - value: 16777216
net.core.netdev_max_backlog:
  sysctl.present:
    - value: 262144
net.ipv4.tcp_max_orphans:
  sysctl.present:
    - value: 3276800
net.ipv4.tcp_max_syn_backlog:
  sysctl.present:
    - value: 262144
net.ipv4.tcp_timestamps:
  sysctl.present:
    - value: 0
net.ipv4.tcp_synack_retries:
  sysctl.present:
    - value: 1
net.ipv4.tcp_syn_retries:
  sysctl.present:
    - value: 1
net.ipv4.tcp_tw_reuse:
  sysctl.present:
    - value: 1
net.ipv4.tcp_mem:
  sysctl.present:
    - value: 94500000 915000000 927000000
net.ipv4.tcp_fin_timeout:
  sysctl.present:
    - value: 1
net.ipv4.tcp_keepalive_time:
  sysctl.present:
    - value: 30
net.ipv4.conf.all.accept_redirects:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.accept_redirects:
  sysctl.present:
    - value: 0
net.ipv4.conf.all.secure_redirects:
  sysctl.present:
    - value: 0
net.ipv4.conf.default.secure_redirects:
  sysctl.present:
    - value: 0
vm.swappiness:
  sysctl.present:
    - value: 0
vm.overcommit_memory:
  sysctl.present:
    - value: 1
vm.panic_on_oom:
  sysctl.present:
    - value: 0
fs.inotify.max_user_instances:
  sysctl.present:
    - value: 8192
fs.inotify.max_user_watches:
  sysctl.present:
    - value: 1048576
fs.file-max:
  sysctl.present:
    - value: 52706963
fs.nr_open:
  sysctl.present:
    - value: 52706963
