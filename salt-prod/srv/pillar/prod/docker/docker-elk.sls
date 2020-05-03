ELK_NODENAME: {{ grains['host'] }}
ELK_NODEIP: {{ grains['fqdn_ip4'][0] }}
ELK_CLUSTER_IPLIST: 192.168.43.201,192.168.43.202

