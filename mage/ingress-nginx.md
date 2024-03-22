# ingress-nginx



## 1. 部署ingress-nginx-controller

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

# 配置yaml文件，使pod可以监听80端口，否则pod无法运行起来
root@ansible:~/k8s/ingress-nginx# grep -i allowPrivilegeEscalation baremetal-deploy-v1.10.0.yaml
          allowPrivilegeEscalation: false
          allowPrivilegeEscalation: false
          allowPrivilegeEscalation: false
root@ansible:~/k8s/ingress-nginx# sed -i 's/allowPrivilegeEscalation: false/allowPrivilegeEscalation: true/g' baremetal-deploy-v1.10.0.yaml
root@ansible:~/k8s/ingress-nginx# grep -i allowPrivilegeEscalation baremetal-deploy-v1.10.0.yaml
          allowPrivilegeEscalation: true
          allowPrivilegeEscalation: true
          allowPrivilegeEscalation: true
		
# 删除并重新应用
root@ansible:~/k8s/ingress-nginx# kubectl delete -f baremetal-deploy.yaml
root@ansible:~/k8s/ingress-nginx# kubectl apply -f baremetal-deploy.yaml

# 查看pod状态
root@ansible:~/k8s/ingress-nginx# kubectl get pods -o wide -n ingress-nginx
NAME                                        READY   STATUS      RESTARTS   AGE   IP              NODE            NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-56fpr        0/1     Completed   0          30s   172.20.217.90   192.168.13.63   <none>           <none>
ingress-nginx-admission-patch-v8b8m         0/1     Completed   0          29s   172.20.217.92   192.168.13.63   <none>           <none>
ingress-nginx-controller-64674dc5d6-lmvrf   1/1     Running     0          30s   172.20.217.98   192.168.13.63   <none>           <none>

# 查看service状态
root@ansible:~/k8s/ingress-nginx# kubectl get svc -n ingress-nginx
NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller             NodePort    10.68.208.129   <none>        80:47255/TCP,443:30042/TCP   2m54s
ingress-nginx-controller-admission   ClusterIP   10.68.164.87    <none>        443/TCP                      2m52s

# ingress-nginx副本增加
root@ansible:~/k8s/ingress-nginx# grep replicas baremetal-deploy-v1.10.0.yaml
  replicas: 4
root@ansible:~/k8s/ingress-nginx# kubectl get pods -n ingress-nginx -o wide
NAME                                        READY   STATUS      RESTARTS   AGE    IP               NODE            NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-56fpr        0/1     Completed   0          83m    172.20.217.90    192.168.13.63   <none>           <none>
ingress-nginx-admission-patch-v8b8m         0/1     Completed   0          83m    172.20.217.92    192.168.13.63   <none>           <none>
ingress-nginx-controller-64674dc5d6-6tspj   1/1     Running     0          4m5s   172.20.217.107   192.168.13.63   <none>           <none>
ingress-nginx-controller-64674dc5d6-9wmcg   1/1     Running     0          4m5s   172.20.58.199    172.168.2.25    <none>           <none>
ingress-nginx-controller-64674dc5d6-lmvrf   1/1     Running     0          83m    172.20.217.98    192.168.13.63   <none>           <none>
ingress-nginx-controller-64674dc5d6-m6tw7   1/1     Running     0          4m5s   172.20.135.143   172.168.2.26    <none>           <none>

```





## 2. 创建服务

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: pro-frontend-nginx-hs-com-rollout
  annotations:
    link.argocd.argoproj.io/external-link: http://newjenkins.hs.com/job/nginx.hs.com
spec:
#  replicas: 2
  strategy:
    canary:
      trafficRouting:
        istio:
          virtualService:
            name: pro-frontend-nginx-hs-com-virtualservice
            routes:
            - primary
          destinationRule:
            name: pro-frontend-nginx-hs-com-destinationrule
            canarySubsetName: canary
            stableSubsetName: stable
      steps:
#      - setWeight: 30
#      - pause: {duration: 5}
#      - setWeight: 60
#      - pause: {duration: 5}
      #- setCanaryScale:
      #    replicas: 1
      - setCanaryScale:
          weight: 100
      - pause: {}
      - setWeight: 100
      - pause: {}
      - pause: {}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: pro-frontend-nginx-hs-com-selector
  template:
    metadata:
      labels:
        app: pro-frontend-nginx-hs-com-selector
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: pro-frontend-nginx-hs-com-selector
              topologyKey: kubernetes.io/hostname
            weight: 50
      containers:
      - name: homsom-container
        image: harborrepo.hs.com/pro/nginx.hs.com:v20230726190839
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: pro-frontend-nginx-hs-com-service
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
  selector:
    app: pro-frontend-nginx-hs-com-selector
```

**运行服务**

```bash
root@ansible:/tmp/frontend-nginx-hs-com/deploy# kubectl apply -f 01-rollout.yaml -f 02-service.yaml -n test-pro-frontend

root@ansible:/tmp/frontend-nginx-hs-com/deploy# kubectl get pods,svc -n test-pro-frontend
NAME                                                    READY   STATUS    RESTARTS   AGE
pod/pro-frontend-nginx-hs-com-rollout-f8b6756f4-ksq9n   1/1     Running   0          6h1m

NAME                                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/pro-frontend-nginx-hs-com-service   ClusterIP   10.68.241.69   <none>        80/TCP    52d

```





## 3. 创建ingress



**创建htpasswd用户及密码**

```bash
root@ansible:/tmp/frontend-nginx-hs-com/deploy# htpasswd  -c -b -m ./nginx-password-nginx-hs-com linux linux
Adding password for user linux
root@ansible:/tmp/frontend-nginx-hs-com/deploy# cat nginx-password-nginx-hs-com 
linux:$apr1$6..ZC3R/$ZKRH7gVdgvBc.daPJ46JG1
```

**创建secret**

```bash
root@ansible:/tmp/frontend-nginx-hs-com/deploy# kubectl create secret generic nginx-password-nginx-hs-com --from-file=auth=./nginx-password-nginx-hs-com -n test-pro-frontend
secret/nginx-password-nginx-hs-com created
```

**yaml文件**

```yaml
apiVersion: v1
data:
  auth: bGludXg6JGFwcjEkNi4uWkMzUi8kWktSSDdnVmRndkJjLmRhUEo0NkpHMQo=
kind: Secret
metadata:
  name: nginx-password-nginx-hs-com
type: Opaque
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: pro-frontend-nginx-hs-com-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: nginx-password-nginx-hs-com
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
spec:
  rules:
  - host: nginx.hs.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: pro-frontend-nginx-hs-com-service
            port:
              number: 80
---
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pro-frontend-nginx-hs-com-rollout
spec:
  maxReplicas: 2
  minReplicas: 1
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
  metrics:
  - type: Resource
    resource:
#      name: memory
#      target:
#        type: Utilization
#        averageUtilization: 80
      name: cpu
      target:
        type: Utilization
        averageUtilization: 100
```

**创建ingress**

```bash
root@ansible:/tmp/frontend-nginx-hs-com/deploy# kubectl apply -f 03-secret.yaml -f 03-ingress.yaml -n test-pro-frontend
secret/nginx-password-nginx-hs-com unchanged
ingress.networking.k8s.io/pro-frontend-nginx-hs-com-ingress created
# 查看状态
root@ansible:/tmp/frontend-nginx-hs-com/deploy# kubectl get ingress -n test-pro-frontend
NAME                                CLASS    HOSTS          ADDRESS                                   PORTS   AGE
pro-frontend-nginx-hs-com-ingress   <none>   nginx.hs.com   172.168.2.25,172.168.2.26,192.168.13.63   80      28s
```

**测试ingress服务**

```bash
root@ansible:/tmp/frontend-nginx-hs-com/deploy# kubectl get svc -n ingress-nginx ingress-nginx-controller
NAME                       TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx-controller   NodePort   10.68.208.129   <none>        80:47255/TCP,443:30042/TCP   133m
# 测试无权访问
root@ansible:/tmp/frontend-nginx-hs-com/deploy# curl -H 'Host: nginx.hs.com' 192.168.13.63:47255
<html>
<head><title>401 Authorization Required</title></head>
<body>
<center><h1>401 Authorization Required</h1></center>
<hr><center>nginx</center>
</body>
</html>
# 测试用户名访问
root@ansible:/tmp/frontend-nginx-hs-com/deploy# curl -u 'linux:linux' -H 'Host: nginx.hs.com' 192.168.13.63:47255
this is version v45.
```





## 4. ingress-argoCD实现蓝绿发布



**服务yaml清单**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: pro-frontend-nginx-hs-com-rollout
  annotations:
    link.argocd.argoproj.io/external-link: http://newjenkins.hs.com/job/nginx.hs.com
spec:
#  replicas: 2
  strategy:
    canary:
      canaryService: pro-frontend-nginx-hs-com-service-canary
      stableService: pro-frontend-nginx-hs-com-service-stable
      trafficRouting:
        nginx:
          stableIngress: pro-frontend-nginx-hs-com-ingress
      steps:
#      - setWeight: 30
#      - pause: {duration: 5}
#      - setWeight: 60
#      - pause: {duration: 5}
      #- setCanaryScale:
      #    replicas: 1
      - setCanaryScale:
          weight: 100
      - pause: {}
      - setWeight: 100
      - pause: {}
      - pause: {}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: pro-frontend-nginx-hs-com-selector
  template:
    metadata:
      labels:
        app: pro-frontend-nginx-hs-com-selector
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: pro-frontend-nginx-hs-com-selector
              topologyKey: kubernetes.io/hostname
            weight: 50
      containers:
      - name: homsom-container
        image: harborrepo.hs.com/pro/nginx.hs.com:v20230726190839
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: pro-frontend-nginx-hs-com-service-stable
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
  selector:
    app: pro-frontend-nginx-hs-com-selector
---
apiVersion: v1
kind: Service
metadata:
  name: pro-frontend-nginx-hs-com-service-canary
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
  selector:
    app: pro-frontend-nginx-hs-com-selector
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: pro-frontend-nginx-hs-com-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: nginx-password-nginx-hs-com
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
spec:
  rules:
  - host: nginx.hs.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: pro-frontend-nginx-hs-com-service-stable
            port:
              number: 80
---
apiVersion: v1
data:
  auth: bGludXg6JGFwcjEkNi4uWkMzUi8kWktSSDdnVmRndkJjLmRhUEo0NkpHMQo=
kind: Secret
metadata:
  name: nginx-password-nginx-hs-com
type: Opaque
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pro-frontend-nginx-hs-com-rollout
spec:
  maxReplicas: 2
  minReplicas: 1
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
  metrics:
  - type: Resource
    resource:
#      name: memory
#      target:
#        type: Utilization
#        averageUtilization: 80
      name: cpu
      target:
        type: Utilization
        averageUtilization: 100
---
```

**创建服务yaml清单**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: pro-frontend-nginx-hs-com
  namespace: argocd
spec:
  destination:
    namespace: test-pro-frontend
    server: https://kubernetes.default.svc
  project: homsom
  source:
    path: deploy
    repoURL: git@gitlab.hs.com:k8s-deploy/frontend-nginx-hs-com.git
    targetRevision: pro
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
      allowEmpty: false
    syncOptions:
    - Validate=false
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-frontend-nginx-hs-com
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
    customize: homsom
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy/frontend-nginx-hs-com.git
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy
  sshPrivateKey: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAmhCD24CCTEmMWzHGOyO3ZAnX1WHA1fyV6U0Efcz2wduHhPj7
    mquUEZN4dZYC6eL8QuTr5RKigbPg25q0ReAEOkzkpNhvRbxtrmq0b/u7CxXjWJiL
    /OHanH/u6CpS/M0ySxVGcY9dB2uxnWqYze34ljHoXkPuJJn7ufuGKEVZ9JIXdMao
    N9TWUSQWR6+3cd5d3042h6E8cyhkA5urlW+9VfiPWhO2Z8bYeTwerucj7+0Pn4yt
    nD0VAncJZzoOgUet7SY38WeVO76sbM/No2igNnjVLSyaYleDWXOwUSCZtPgUKB+s
    /8ev502Xu3pr6LbnaZysHoGEjw0a1Es1pnM6MQIDAQABAoIBAFDx9mVgepUcW2sa
    lr1BwbwE0+qfxpJneFgwh/iUtN0bu3Mo4gDcvxoQ8kxNedBq2wFGh44+oTUmTjDz
    cl34GiCLf+IAeU4Zd0MZex4PE7H6WQ2WcI54F8T8Dojam+mI4jDCx9UobsdUVOiR
    /JjBabepaXg2IA9W8S2K6QKBgQCDeT7wQnP3iMJzCCO8V0hoyeDP7Ujw0cUFhIVk
    LMwKBxqvtu0HkS6zNJLUFKX6qIBhPdEhd7uAsrFeDrIk4pvCnS7z0kwATO6Ln1yL
    TTysLGRaPvl/ylbJ5xLERyUXYgLuMgm3WxUtX+XyUxdKV16UIAwdYW/E7pQ2X2Hn
    7g/xEQKBgHtPOeB7YaTvTwKZVUGiZcSA0WzTkzjUOIN165K+XO9qEM5Tvj0892bA
    ld2nd6oESKvosa29+laflkdyNT3wGNtA/nfSG1bHkg/VIve5fnvN8LFlAbCOJwCf
    C1iUM1zDoIZ4oggXlvRRhMT4o5AMYJ91t00DM+Nm6ir8E9n4nZb2
    -----END RSA PRIVATE KEY-----
---
```

**创建服务**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# ls
README.md  deploy  kustomize  rollout-application-fat.yaml  rollout-application-pro.yaml  rollout-application-uat.yaml  rollout-application.yaml  rollout-project.yaml
root@ansible:/tmp/frontend-nginx-hs-com# git add -A && git commit -m "update" && git push origin pro

root@ansible:/tmp/frontend-nginx-hs-com# kubectl apply -f rollout-application-pro.yaml -f rollout-project.yaml -f argocd-secret-ssh-template-gitlab.hs.com.yaml
```



**argocd Dashboard界面**

![](../image/k8s/ingress-nginx/01.png)



**访问服务**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# curl -u 'linux:linux' -H 'Host: nginx.hs.com' 192.168.13.63:47255
this is version v45.
```



**服务版本降级**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# cat deploy/01-rollout.yaml  | grep image
        image: harborrepo.hs.com/pro/nginx.hs.com:v20220726144944
        imagePullPolicy: IfNotPresent
root@ansible:/tmp/frontend-nginx-hs-com# git add -A && git commit -m "update" && git push origin pro
```

![](../image/k8s/ingress-nginx/02.png)

![](../image/k8s/ingress-nginx/03.png)



**查看组件运行状态**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# curl -u 'linux:linux' -H 'Host: nginx.hs.com' 192.168.13.63:47255
this is version v45.
root@ansible:/tmp/frontend-nginx-hs-com# kubectl get all -n test-pro-frontend
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/pro-frontend-nginx-hs-com-rollout-66bfdd6fb4-5z8gf   1/1     Running   0          23m
pod/pro-frontend-nginx-hs-com-rollout-74c95fbb75-dpjjs   1/1     Running   0          2m6s

NAME                                               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/pro-frontend-nginx-hs-com-service-canary   ClusterIP   10.68.219.94    <none>        80/TCP    23m
service/pro-frontend-nginx-hs-com-service-stable   ClusterIP   10.68.254.221   <none>        80/TCP    23m

NAME                                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/pro-frontend-nginx-hs-com-rollout-66bfdd6fb4   1         1         1       23m
replicaset.apps/pro-frontend-nginx-hs-com-rollout-74c95fbb75   1         1         1       2m8s

NAME                                                                    REFERENCE                                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/pro-frontend-nginx-hs-com-rollout   Rollout/pro-frontend-nginx-hs-com-rollout   1%/100%   1         2         1          23m

# 此时访问版本还是v45
root@ansible:/tmp/frontend-nginx-hs-com# curl -u 'linux:linux' -H 'Host: nginx.hs.com' 192.168.13.63:47255
this is version v45.

# 需要对ingress进行流量切换
root@ansible:/tmp/frontend-nginx-hs-com# kubectl argo rollouts list rollouts -n test-pro-frontend
NAME                               STRATEGY   STATUS        STEP  SET-WEIGHT  READY  DESIRED  UP-TO-DATE  AVAILABLE
pro-frontend-nginx-hs-com-rollout  Canary     Paused        1/5   0           2/2    1        1           2
root@ansible:/tmp/frontend-nginx-hs-com# kubectl argo rollouts promote pro-frontend-nginx-hs-com-rollout -n test-pro-frontend
rollout 'pro-frontend-nginx-hs-com-rollout' promoted
root@ansible:/tmp/frontend-nginx-hs-com# kubectl argo rollouts list rollouts -n test-pro-frontend
NAME                               STRATEGY   STATUS        STEP  SET-WEIGHT  READY  DESIRED  UP-TO-DATE  AVAILABLE
pro-frontend-nginx-hs-com-rollout  Canary     Paused        3/5   100         2/2    1        1           2
# 此时再访问
root@ansible:/tmp/frontend-nginx-hs-com# curl -u 'linux:linux' -H 'Host: nginx.hs.com' 192.168.13.63:47255
this is version v36.

# 推进到最后一步，也就是上线最近一次发的版本
root@ansible:/tmp/frontend-nginx-hs-com# kubectl argo rollouts promote --full pro-frontend-nginx-hs-com-rollout -n test-pro-frontend 
```

![](../image/k8s/ingress-nginx/04.png)





## 5. istio-argoCD实现蓝绿发布



**服务yaml清单**

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: pro-frontend-nginx-hs-com-rollout
  annotations:
    link.argocd.argoproj.io/external-link: http://newjenkins.hs.com/job/nginx.hs.com
spec:
  replicas: 1
  strategy:
    canary:
      trafficRouting:
        istio:
          virtualService:
            name: pro-frontend-nginx-hs-com-virtualservice
            routes:
            - primary
          destinationRule:
            name: pro-frontend-nginx-hs-com-destinationrule
            canarySubsetName: canary
            stableSubsetName: stable
      steps:
#      - setWeight: 30
#      - pause: {duration: 5}
#      - setWeight: 60
#      - pause: {duration: 5}
      #- setCanaryScale:
      #    replicas: 1
      - setCanaryScale:
          weight: 100
      - pause: {}
      - setWeight: 100
      - pause: {}
      - pause: {}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: pro-frontend-nginx-hs-com-selector
  template:
    metadata:
      labels:
        app: pro-frontend-nginx-hs-com-selector
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: pro-frontend-nginx-hs-com-selector
              topologyKey: kubernetes.io/hostname
            weight: 50
      containers:
      - name: homsom-container
        image: harborrepo.hs.com/prepro/nginx.hs.com:v20230614205205
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: pro-frontend-nginx-hs-com-service
spec:
  ports:
  - name: http-80
    port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
  selector:
    app: pro-frontend-nginx-hs-com-selector
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: pro-frontend-nginx-hs-com-destinationrule
spec:
  host: pro-frontend-nginx-hs-com-service
  subsets:
  - name: canary
    labels:
      app: pro-frontend-nginx-hs-com-selector
  - name: stable
    labels:
      app: pro-frontend-nginx-hs-com-selector
  trafficPolicy:
    tls:
      mode: DISABLE
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: pro-frontend-nginx-hs-com-virtualservice
spec:
  hosts:
  - "nginx.hs.com"
  gateways:
  - istio-system/general-gateway
  http:
  - name: primary
    route:
    - destination:
        host: pro-frontend-nginx-hs-com-service
        subset: stable
      weight: 100
    - destination:
        host: pro-frontend-nginx-hs-com-service
        subset: canary
      weight: 0
---
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pro-frontend-nginx-hs-com-rollout
spec:
  maxReplicas: 1
  minReplicas: 1
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
  metrics:
  - type: Resource
    resource:
#      name: memory
#      target:
#        type: Utilization
#        averageUtilization: 80
      name: cpu
      target:
        type: Utilization
        averageUtilization: 100
---
```



**创建服务yaml清单**

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: prepro-frontend-nginx-hs-com
  namespace: argocd
spec:
  destination:
    namespace: test-prepro-frontend
    server: https://kubernetes.default.svc
  project: homsom
  source:
    path: deploy/
    repoURL: git@gitlab.hs.com:k8s-deploy/frontend-nginx-hs-com.git
    targetRevision: prepro
  syncPolicy:
    automated:
      selfHeal: true
      prune: true
      allowEmpty: false
    syncOptions:
    - Validate=false
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
  ignoreDifferences:
  - group: networking.istio.io
    kind: VirtualService
    jsonPointers:
    - /spec/http/0
```

```bash
root@ansible:/tmp/frontend-nginx-hs-com# ls
README.md  backup  deploy  kustomize  rollout-application-kustomize.yaml  rollout-application-prepro.yaml  rollout-project.yaml
# 推送到git仓库
root@ansible:/tmp/frontend-nginx-hs-com# git add -A && git commit -m "update" && git push origin prepro
# 创建application
root@ansible:/tmp/frontend-nginx-hs-com# kubectl apply -f rollout-application-prepro.yaml

# 查看application状态
root@ansible:/tmp/frontend-nginx-hs-com# kubectl get all -n test-prepro-frontend
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/pro-frontend-nginx-hs-com-rollout-59b978cb55-twxnq   1/1     Running   0          2m30s

NAME                                        TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
service/pro-frontend-nginx-hs-com-service   ClusterIP   10.68.132.59   <none>        80/TCP    2m36s

NAME                                                           DESIRED   CURRENT   READY   AGE
replicaset.apps/pro-frontend-nginx-hs-com-rollout-59b978cb55   1         1         1       2m32s

NAME                                                                    REFERENCE                                   TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
horizontalpodautoscaler.autoscaling/pro-frontend-nginx-hs-com-rollout   Rollout/pro-frontend-nginx-hs-com-rollout   1%/100%   1         1         1          2m36s

# 访问服务
root@ansible:/tmp/frontend-nginx-hs-com# curl -H 'Host: nginx.hs.com' 192.168.13.63:30080
this is version v45.

```





## 6. ingress-nginx替换istio



**当前应用访问状态，现在使用的依然是istio**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# while true;do date curl -H 'Host: nginx.hs.com' 192.168.13.63:30080; sleep 1; done
Thu Mar 21 13:22:17 CST 2024
this is version v45.
Thu Mar 21 13:22:18 CST 2024
this is version v45.
Thu Mar 21 13:22:19 CST 2024
this is version v45.

root@ansible:/tmp/frontend-nginx-hs-com# while true;do date;curl -u 'linux:linux' -H 'Host: nginx02.hs.com' 192.168.13.63:47255;sleep 1;done
Thu Mar 21 13:22:19 CST 2024
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx</center>
</body>
</html>
```



**替换应用清单**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# cat deploy/*
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: pro-frontend-nginx-hs-com-rollout
  annotations:
    link.argocd.argoproj.io/external-link: http://newjenkins.hs.com/job/nginx.hs.com
spec:
#  replicas: 2
  strategy:
    canary:
      canaryService: pro-frontend-nginx-hs-com-service-canary
      stableService: pro-frontend-nginx-hs-com-service-stable
      trafficRouting:
        nginx:
          stableIngress: pro-frontend-nginx-hs-com-ingress
      steps:
#      - setWeight: 30
#      - pause: {duration: 5}
#      - setWeight: 60
#      - pause: {duration: 5}
      #- setCanaryScale:
      #    replicas: 1
      - setCanaryScale:
          weight: 100
      - pause: {}
      - setWeight: 100
      - pause: {}
      - pause: {}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: pro-frontend-nginx-hs-com-selector
  template:
    metadata:
      labels:
        app: pro-frontend-nginx-hs-com-selector
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: pro-frontend-nginx-hs-com-selector
              topologyKey: kubernetes.io/hostname
            weight: 50
      containers:
      - name: homsom-container
        image: harborrepo.hs.com/pro/nginx.hs.com:v20220726144944
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 256Mi
        readinessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /index.html
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
          timeoutSeconds: 3
          successThreshold: 1
          failureThreshold: 3
---
apiVersion: v1
kind: Service
metadata:
  name: pro-frontend-nginx-hs-com-service-stable
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
  selector:
    app: pro-frontend-nginx-hs-com-selector
---
apiVersion: v1
kind: Service
metadata:
  name: pro-frontend-nginx-hs-com-service-canary
spec:
  ports:
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
  selector:
    app: pro-frontend-nginx-hs-com-selector
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: pro-frontend-nginx-hs-com-ingress
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: nginx02.hs.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: pro-frontend-nginx-hs-com-service-stable
            port:
              number: 80
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pro-frontend-nginx-hs-com-rollout
spec:
  maxReplicas: 2
  minReplicas: 1
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
  metrics:
  - type: Resource
    resource:
#      name: memory
#      target:
#        type: Utilization
#        averageUtilization: 80
      name: cpu
      target:
        type: Utilization
        averageUtilization: 100

```

> 这里域名更改为`nginx02.hs.com`是因为ingress-nginx`域名全局唯一`，因为前面test-pro-frontend已经存在nginx.hs.com了，而且访问入口是同一个，所以不能配置一样，如果ingress-nginx未存在此域名，则可以使用跟istio相同的域名，因为入口不一样



**argocd自动部署应用**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# git add -A && git commit -m "update" && git push origin prepro
```

> 此时argocd会自动部署新的配置清单，因为此应用`不是第一次`部署，所以应用会`处于暂停状态`，需要手动`推进`



**应该运行起来后状态，此时还未手动推进**

```bash
# 使用ingress-nginx入口进行访问
[root@prometheus tmp]# while true;do date;curl -u 'linux:linux' -H 'Host: nginx02.hs.com' 192.168.13.63:47255;sleep 1;done 
Thu Mar 21 13:27:16 CST 2024
this is version v45.
Thu Mar 21 13:27:17 CST 2024
this is version v45.
Thu Mar 21 13:27:19 CST 2024
this is version v45.
Thu Mar 21 13:27:20 CST 2024
this is version v45.

# 使用istio入口进行访问
root@ansible:/tmp/frontend-nginx-hs-com# while true;do date curl -H 'Host: nginx.hs.com' 192.168.13.63:30080; sleep 1; done
Thu Mar 21 13:27:17 CST 2024
this is version v45.
Thu Mar 21 13:27:18 CST 2024
this is version v36.
Thu Mar 21 13:27:19 CST 2024
this is version v45.
Thu Mar 21 13:27:20 CST 2024
this is version v36.
```

> 第一次部署的版本为v45，第二次部署的版本为v36
>
> 由于新配置应用运行后，ingress-nginx选择的是stable版的service，所以请求的服务一直是第一次的版本v45
>
> 而istio中VirtualService的lable选择的是`app: pro-frontend-nginx-hs-com-selector`，所以会选中stable版和canary版的service，所以请求的服务是第一次的版本v45和第二次的版本v36
>
> 此时argoCD部署当前服务的对象状态是：ingress是生效且新增的、VirtualService和DestinationRule是生效待修剪删除的



**推进一步**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# kubectl argo rollouts promote pro-frontend-nginx-hs-com-rollout -n test-prepro-frontend
```



**再次查看应用状态**

```bash
# 使用ingress-nginx入口进行访问
[root@prometheus tmp]# while true;do date;curl -u 'linux:linux' -H 'Host: nginx02.hs.com' 192.168.13.63:47255;sleep 1;done 
Thu Mar 21 13:29:16 CST 2024
this is version v36.
Thu Mar 21 13:29:17 CST 2024
this is version v36.
Thu Mar 21 13:29:19 CST 2024
this is version v36.
Thu Mar 21 13:29:20 CST 2024
this is version v36.

# 使用istio入口进行访问
root@ansible:/tmp/frontend-nginx-hs-com# while true;do date curl -H 'Host: nginx.hs.com' 192.168.13.63:30080; sleep 1; done
Thu Mar 21 13:29:17 CST 2024
this is version v45.
Thu Mar 21 13:29:18 CST 2024
this is version v45.
Thu Mar 21 13:29:19 CST 2024
this is version v36.
Thu Mar 21 13:29:20 CST 2024
this is version v36.
```

> 因为推进了一步，所以ingerss访问的是v36了，因为ingress指向了canary版的service。
>
> 而istio访问的依然是v45和v36，因为istio中VirtualService的lable依然选择的是`app: pro-frontend-nginx-hs-com-selector`，所以会选中stable版和canary版的service



**服务全部推进**

```bash
[root@prometheus tmp]# while true;do date;curl -u 'linux:linux' -H 'Host: nginx02.hs.com' 192.168.13.63:47255;sleep 1;done 
Thu Mar 21 13:31:16 CST 2024
this is version v36.
Thu Mar 21 13:31:17 CST 2024
this is version v36.
Thu Mar 21 13:31:19 CST 2024
this is version v36.
Thu Mar 21 13:31:20 CST 2024
this is version v36.

# 使用istio入口进行访问
root@ansible:/tmp/frontend-nginx-hs-com# while true;do date curl -H 'Host: nginx.hs.com' 192.168.13.63:30080; sleep 1; done
Thu Mar 21 13:31:17 CST 2024
this is version v45.
Thu Mar 21 13:31:18 CST 2024
this is version v36.
Thu Mar 21 13:31:19 CST 2024
Thu Mar 21 13:31:20 CST 2024
Thu Mar 21 13:31:21 CST 2024
Thu Mar 21 13:31:22 CST 2024
```

> 因为全部`推进完成`，所以VirtualService和DestinationRule被修剪删除了，所以通过istio入口访问才不会在生效了，最终生效的只有Ingress了。



**总结**

> 如果第二次版本和第一次版本一致，则不会出现前面的版本变化情况，在实际将istio替换为ingress-nginx时，必须保持其它清单配置一样，而只变更ingress、VirtualService、DestinationRule部分，这样才不会带来上面的版本不一致情况。
>
> 经过上面的测试，将istio切换为ingress-nginx是平滑的，并不会导致服务中断。





## 7. ingress蓝绿原理



**ingress stable**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# kubectl get ingress -n test-prepro-frontend pro-frontend-nginx-hs-com-ingress -o yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.k8s.io/v1","kind":"Ingress","metadata":{"annotations":{"kubernetes.io/ingress.class":"nginx"},"labels":{"app.kubernetes.io/instance":"prepro-frontend-nginx-hs-com"},"name":"pro-frontend-nginx-hs-com-ingress","namespace":"test-prepro-frontend"},"spec":{"rules":[{"host":"nginx02.hs.com","http":{"paths":[{"backend":{"service":{"name":"pro-frontend-nginx-hs-com-service-stable","port":{"number":80}}},"path":"/","pathType":"Prefix"}]}}]}}
    kubernetes.io/ingress.class: nginx
  creationTimestamp: "2024-03-21T05:17:07Z"
  generation: 1
  labels:
    app.kubernetes.io/instance: prepro-frontend-nginx-hs-com
  name: pro-frontend-nginx-hs-com-ingress
  namespace: test-prepro-frontend
  resourceVersion: "64200333"
  uid: 9695d640-f265-4b55-9656-5fc2648510ab
spec:
  rules:
  - host: nginx02.hs.com
    http:
      paths:
      - backend:
          service:
            name: pro-frontend-nginx-hs-com-service-stable
            port:
              number: 80
        path: /
        pathType: Prefix
status:
  loadBalancer:
    ingress:
    - ip: 172.168.2.25
    - ip: 172.168.2.26
    - ip: 192.168.13.63
```

**ingress canary**

```bash
root@ansible:/tmp/frontend-nginx-hs-com# kubectl get ingress -n test-prepro-frontend pro-frontend-nginx-hs-com-rollout-pro-frontend-nginx-hs-com-ingress-canary -o yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "0"
  creationTimestamp: "2024-03-21T05:17:08Z"
  generation: 1
  name: pro-frontend-nginx-hs-com-rollout-pro-frontend-nginx-hs-com-ingress-canary
  namespace: test-prepro-frontend
  ownerReferences:
  - apiVersion: argoproj.io/v1alpha1
    blockOwnerDeletion: true
    controller: true
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
    uid: e6dafde5-0c02-45c2-b639-08ece2be2601
  resourceVersion: "64208088"
  uid: f152dffc-8b8e-4817-bfe6-fdb14a95cc5f
spec:
  rules:
  - host: nginx02.hs.com
    http:
      paths:
      - backend:
          service:
            name: pro-frontend-nginx-hs-com-service-canary
            port:
              number: 80
        path: /
        pathType: Prefix
status:
  loadBalancer:
    ingress:
    - ip: 172.168.2.25
    - ip: 172.168.2.26
    - ip: 192.168.13.63
```

> 当ingress应该部署后，会配置两个ingress，分别为`ingress-stable`、`ingress-canary`，分别调度到`pro-frontend-nginx-hs-com-service-stable`、`pro-frontend-nginx-hs-com-service-canary`
>
> 而ingress-canary默认是不接入流量的，所以`nginx.ingress.kubernetes.io/canary-weight: "0"`，当argocd rollout推进应用接入流量后`nginx.ingress.kubernetes.io/canary-weight`的值将被改变，此时最新版本的应用也对应的处理接入流量



**service-stable、service-canary原理**

> 当argoCD部署ingress相关的应用时，会创建两个service，分别为service-stable和serrvice-canary，我们自己定义的service标签选择器时，标签键值都是一样的，而argoCD帮我们部署时会添加其它标签，以便控制 ：
>
> * 当第一次部署时，会将pod添加label `rollouts-pod-template-hash: 5c8b78596`（值跟pod所属replicaset的id一样），并随后也将service-stable添加label `rollouts-pod-template-hash: 5c8b78596`，从而将pod和service对应起来
> * 当第二次部署时，针对第二个版本创建的pod，也会添加label `rollouts-pod-template-hash: 1sgf4df`，而此时lable值将会和之前的不同，并随后也将service-canary添加label `rollouts-pod-template-hash: 1sgf4df`，从而将pod和service对应起来



**多版本pod并存原理**

> pod是因为受ReplicaSet管理，而ReplicaSet又受Deployment管理(Rollout)，所以当部署第二个版本时，会实现类似`kubectl set image deployment myapp-deploy myapp=ikubernetes/myapp:v3 &&  kubectl rollout pause `的功能，使同时存在两个版本。
>
> 再通过对象细分，将service-stable和service-canary对应两个不同的ReplicaSet，即可实现蓝绿功能



**应用蓝绿实现过程**

> * 当第一次部署时，会将pod添加label `rollouts-pod-template-hash: 5c8b78596`（值跟pod所属replicaset的id一样），并随后也将service-stable添加label `rollouts-pod-template-hash: 5c8b78596`，从而将pod和service对应起来
> * 当第二次部署时，针对第二个版本创建的pod，也会添加label `rollouts-pod-template-hash: 1sgf4df`，而此时lable值将会不同，并随后也将service-canary添加label `rollouts-pod-template-hash: 1sgf4df`，从而将pod和service对应起来
> * 然后通过argo-rollouts控制流量，将请求从stable版本慢慢切换到canary版本，实际是将ingress-stable版慢慢切换到ingress-canary版本
> * 当流量切换到ingress-canary版本时，ingress-canary会选择service-canary，而service-canary会选择最新一次发布的pod，从而达到测试最新服务的功能
> * 如果ingress-canary测试通过、应用全部推进同步后：
>   1. 会将`service-stable`的标签选择器中`rollouts-pod-template-hash`的值`更改`为`service-canary`的标签选择器中`rollouts-pod-template-hash`的值。
>   2. 然后配置Deployment(Rollout)，类似命令`kubectl rollout resume deployment myapp-deploy`，使新版本继续运行，而将老版本删除，此命令执行过后，pod删除则由k8s自己完成。
>   3. 最后将ingress-canary的`nginx.ingress.kubernetes.io/canary-weight: "100"`变更为`nginx.ingress.kubernetes.io/canary-weight: "0"`，使用户流量最终从ingerss-stable接入。
>   4. 最终的资源流程是这样的：ingress-stable -> service-stable(指向新RS) -> Rollout(指向新RS) -> ReplicaSet(新RS) -> pod(新pod)
> * 如果ingress-canary测试未通过则回滚后：
>   1. 将ingress-canary的`nginx.ingress.kubernetes.io/canary-weight: "100"`变更为`nginx.ingress.kubernetes.io/canary-weight: "0"`
>   2. 执行类似命令`kubectl rollout undo deployment myapp-deploy`，将deployment(rollout)回滚到老版本的pod
>   3. 此时并`不会修改server-stable`的标签选择器了。
>   4. 最终的资源流程是这样的：ingress-stable -> service-stable(指向老RS) -> Rollout(指向老RS) -> ReplicaSet(老RS) -> pod(老pod)





## 8. ingress-nginx其它配置



### 8.1 日志配置

```bash
# 配置日志格式，$proxy_add_x_forwarded_for会保留多及客户端的IP地址，是个列表，但前提必须是ingress-nginx前面还有多个代理
log-format-upstream: '{"time": "$time_iso8601", "remote_addr": "$remote_addr", "x-forward-for":
    "$proxy_add_x_forwarded_for", "request_id": "$req_id", "remote_user": "$remote_user",
    "bytes_sent": $bytes_sent, "request_time": $request_time, "status":$status, "vhost":
    "$host", "request_proto": "$server_protocol", "path": "$uri", "request_query":
    "$args", "request_length": $request_length, "duration": $request_time,"method":
    "$request_method", "http_referrer": "$http_referer", "http_user_agent": "$http_user_agent"}'
   
```

```bash
root@ansible:~# kubectl get cm -n ingress-nginx ingress-nginx-controller -o yaml
apiVersion: v1
data:
  allow-snippet-annotations: "false"
  compute-full-forwarded-for: "true"
  log-format-upstream: '{"time": "$time_iso8601", "remote_addr": "$remote_addr", "x-forward-for":
    "$proxy_add_x_forwarded_for", "request_id": "$req_id", "remote_user": "$remote_user",
    "bytes_sent": $bytes_sent, "request_time": $request_time, "status":$status, "vhost":
    "$host", "request_proto": "$server_protocol", "path": "$uri", "request_query":
    "$args", "request_length": $request_length, "duration": $request_time,"method":
    "$request_method", "http_referrer": "$http_referer", "http_user_agent": "$http_user_agent"}'
kind: ConfigMap
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","data":{"allow-snippet-annotations":"false"},"kind":"ConfigMap","metadata":{"annotations":{},"labels":{"app.kubernetes.io/component":"controller","app.kubernetes.io/instance":"ingress-nginx","app.kubernetes.io/name":"ingress-nginx","app.kubernetes.io/part-of":"ingress-nginx","app.kubernetes.io/version":"1.10.0"},"name":"ingress-nginx-controller","namespace":"ingress-nginx"}}
  creationTimestamp: "2024-03-19T07:06:41Z"
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/instance: ingress-nginx
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
    app.kubernetes.io/version: 1.10.0
  name: ingress-nginx-controller
  namespace: ingress-nginx
  resourceVersion: "64273892"
  uid: 98ccfd2c-eea0-44d2-91a0-03bfc0cd88ef
```

**配置代理到ingress-nginx**

```bash
    server {
        listen       80;
        server_name  nginx02.hs.com;

        location / {
                proxy_next_upstream  error timeout http_502 http_503 http_504;
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Real-Port $remote_port;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_http_version 1.1;
                proxy_pass  http://192.168.13.63:47255;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

```

**测试**

```bash
# 客户端模拟测试
[root@prometheus tmp]# while true;do date;curl -H 'Host: nginx02.hs.com' http://172.168.2.12;sleep 1;done
Fri Mar 22 11:39:58 CST 2024
this is version v39.
Fri Mar 22 11:39:59 CST 2024
this is version v39.
Fri Mar 22 11:40:00 CST 2024
this is version v39.

# 查看ingress-nginx日志
root@ansible:~# kubectl logs -f -l pod-template-hash=64674dc5d6 -n ingress-nginx
{"time": "2024-03-22T03:41:02+00:00", "remote_addr": "172.20.217.64", "x-forward-for": "192.168.13.236, 172.20.217.64", "request_id": "f127d086445b137135ce5514a656be84", "remote_user": "-", "bytes_sent": 230, "request_time": 0.001, "status":200, "vhost": "nginx02.hs.com", "request_proto": "HTTP/1.1", "path": "/", "request_query": "-", "request_length": 177, "duration": 0.001,"method": "GET", "http_referrer": "-", "http_user_agent": "curl/7.29.0"}
{"time": "2024-03-22T03:41:03+00:00", "remote_addr": "192.168.13.63", "x-forward-for": "192.168.13.236, 192.168.13.63", "request_id": "ff4703f2e82825968823244339f8ab0c", "remote_user": "-", "bytes_sent": 230, "request_time": 0.001, "status":200, "vhost": "nginx02.hs.com", "request_proto": "HTTP/1.1", "path": "/", "request_query": "-", "request_length": 177, "duration": 0.001,"method": "GET", "http_referrer": "-", "http_user_agent": "curl/7.29.0"}
{"time": "2024-03-22T03:41:04+00:00", "remote_addr": "172.20.217.64", "x-forward-for": "192.168.13.236, 172.20.217.64", "request_id": "7f86935fcfabecac640ef56acf5bc660", "remote_user": "-", "bytes_sent": 230, "request_time": 0.002, "status":200, "vhost": "nginx02.hs.com", "request_proto": "HTTP/1.1", "path": "/", "request_query": "-", "request_length": 177, "duration": 0.002,"method": "GET", "http_referrer": "-", "http_user_agent": "curl/7.29.0"}
{"time": "2024-03-22T03:41:05+00:00", "remote_addr": "192.168.13.63", "x-forward-for": "192.168.13.236, 192.168.13.63", "request_id": "b93984e4268afef29d86d9019c7978f3", "remote_user": "-", "bytes_sent": 230, "request_time": 0.043, "status":200, "vhost": "nginx02.hs.com", "request_proto": "HTTP/1.1", "path": "/", "request_query": "-", "request_length": 177, "duration": 0.043,"method": "GET", "http_referrer": "-", "http_user_agent": "curl/7.29.0"}

# 可见客户端地址为"x-forward-for": "192.168.13.236, 172.20.217.64" 和 "x-forward-for": "192.168.13.236, 192.168.13.63"，原始客户端IP为192.168.13.236，第二级客户端为172.20.217.64/192.168.13.63
# 172.20.217.64是192.168.13.63(node)的calico网络地址
```

