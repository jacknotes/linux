# redis for single




```bash
[root@prometheus ~]# kubectl get nodes --show-labels -l fat-middleware
NAME            STATUS   ROLES   AGE   VERSION   LABELS
192.168.13.39   Ready    node    11d   v1.23.7   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,fat-middleware=allow,kubernetes.io/arch=amd64,kubernetes.io/hostname=192.168.13.39,kubernetes.io/os=linux,kubernetes.io/role=node

root@k8s-node04:~# mkdir -p /data/k8s/fat-redis

[root@prometheus ~]# kubectl create ns fat-middleware
[root@prometheus ~]# kubectl apply -f redis.yaml
```