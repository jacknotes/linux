net.ipv4.ip_local_port_range:    #客户端打口随机端口范围
  sysctl.present:
    - value: 10000 65000
fs.file-max:
  sysctl.present:
    - value: 2000000
net.ipv4.ip_forward:     #打开ipv4转发
  sysctl.present:
    - value: 1
vm.swappiness:   #swap为0,尽量不要使用swap内存
  sysctl.present:
    - value: 0
