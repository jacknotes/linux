net.ipv4.ip_local_port_range:    #客户端打口随机端口范围
  sysctl.present:
    - value: 10000 65000
net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1
net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1
net.ipv4.ip_forward: 
  sysctl.present:
    - value: 1
net.ipv4.tcp_tw_recycle:
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
net.ipv6.conf.all.disable_ipv6:
  sysctl.present:
    - value: 1
net.netfilter.nf_conntrack_max:
  sysctl.present:
    - value: 2310720
