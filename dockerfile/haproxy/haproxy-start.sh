MasterIP1=192.168.15.201
MasterIP2=192.168.15.202
MasterIP3=192.168.15.203

docker run -d --restart=always --name haproxy-k8s -p 6444:6444 \
	-e MasterIP1=$MasterIP1 \
	-e MasterIP2=$MasterIP2 \
	-e MasterIP3=$MasterIP3 \
	-v /download/ha/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
	192.168.15.200:8888/k8s/haproxy-k8s:latest
