# ingress-nginx



## 部署

```bash
root@ansible:~/k8s/ingress-nginx# curl -L -o baremetal-deploy.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/baremetal/deploy.yaml
root@ansible:~/k8s/ingress-nginx# kubectl apply -f baremetal-deploy.yaml 
root@ansible:~# kubectl get pods -n ingress-nginx
NAME                                        READY   STATUS              RESTARTS   AGE
ingress-nginx-admission-create-2r4gx        0/1     ImagePullBackOff    0          126m
ingress-nginx-admission-patch-p2n92         0/1     ImagePullBackOff    0          126m
ingress-nginx-controller-7d5948c6cb-bkfbx   0/1     ContainerCreating   0          126m
```
> 由于镜像在谷歌仓库，国内无法访问，从网上找到了处理方法，就是对镜像地址进行替换，替换地址如下：

| 源站 | 替换为 |
| ---- | ---- |
| cr.l5d.io | l5d.m.daocloud.io |
| docker.elastic.co | elastic.m.daocloud.io |
| docker.io | docker.m.daocloud.io |
| gcr.io | gcr.m.daocloud.io |
| ghcr.io | ghcr.m.daocloud.io |
| k8s.gcr.io | k8s-gcr.m.daocloud.io |
| registry.k8s.io | k8s.m.daocloud.io |
| mcr.microsoft.com | mcr.m.daocloud.io |
| nvcr.io | nvcr.m.daocloud.io |
| quay.io | quay.m.daocloud.io |
| registry.jujucharms.com | jujucharms.m.daocloud.io |
| rocks.canonical.com | rocks-canonical.m.daocloud.io |



**替换镜像地址**

```bash
# 查看镜像地址
root@ansible:~/k8s/ingress-nginx# grep -i 'image: '  baremetal-deploy.yaml
        image: registry.k8s.io/ingress-nginx/controller:v1.10.0@sha256:42b3f0e5d0846876b1791cd3afeb5f1cbbe4259d6f35651dcc1b5c980925379c
        image: registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.0@sha256:44d1d0e9f19c63f58b380c5fddaca7cf22c7cee564adeff365225a5df5ef3334
        image: registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.0@sha256:44d1d0e9f19c63f58b380c5fddaca7cf22c7cee564adeff365225a5df5ef3334
# 手动下载镜像1
root@ansible:~/k8s/ingress-nginx# docker pull k8s.m.daocloud.io/ingress-nginx/controller:v1.10.0
v1.10.0: Pulling from ingress-nginx/controller
4abcf2066143: Pull complete
4d17307cc386: Pull complete
cb71730f6575: Pull complete
2d4cd0caa91c: Pull complete
9dfdf2421ff6: Pull complete
3fddda0d1cd8: Pull complete
4f4fb700ef54: Pull complete
44ac16e7ee32: Pull complete
c45ef9a06ea9: Pull complete
3bbe4fa9abc9: Pull complete
d755c7edfc06: Pull complete
8589ba84a487: Pull complete
657ae484861b: Pull complete
781c7c949d94: Pull complete
67ddfa26ae47: Pull complete
Digest: sha256:42b3f0e5d0846876b1791cd3afeb5f1cbbe4259d6f35651dcc1b5c980925379c
Status: Downloaded newer image for k8s.m.daocloud.io/ingress-nginx/controller:v1.10.0
k8s.m.daocloud.io/ingress-nginx/controller:v1.10.0
# 重新命名镜像
root@ansible:~/k8s/ingress-nginx# docker tag k8s.m.daocloud.io/ingress-nginx/controller:v1.10.0 harborrepo.hs.com/k8s/ingress-nginx/controller:v1.10.0
root@ansible:~/k8s/ingress-nginx# docker login harborrepo.hs.com
root@ansible:~/k8s/ingress-nginx# docker push harborrepo.hs.com/k8s/ingress-nginx/controller:v1.10.0
# 手动下载镜像2
root@ansible:~/k8s/ingress-nginx# docker pull k8s.m.daocloud.io/ingress-nginx/kube-webhook-certgen:v1.4.0
root@ansible:~/k8s/ingress-nginx# docker tag k8s.m.daocloud.io/ingress-nginx/kube-webhook-certgen:v1.4.0 harborrepo.hs.com/k8s/ingress-nginx/kube-webhook-certgen:v1.4.0
root@ansible:~/k8s/ingress-nginx# docker push harborrepo.hs.com/k8s/ingress-nginx/kube-webhook-certgen:v1.4.0

# 替换baremetal-deploy.yaml中的镜像地址
root@ansible:~/k8s/ingress-nginx# grep -i 'image: '  baremetal-deploy.yaml
        image: harborrepo.hs.com/k8s/ingress-nginx/controller:v1.10.0
        image: harborrepo.hs.com/k8s/ingress-nginx/kube-webhook-certgen:v1.4.0
        image: harborrepo.hs.com/k8s/ingress-nginx/kube-webhook-certgen:v1.4.0
		
# 删除并重新应用
root@ansible:~/k8s/ingress-nginx# kubectl delete -f baremetal-deploy.yaml
root@ansible:~/k8s/ingress-nginx# kubectl apply -f baremetal-deploy.yaml


```



