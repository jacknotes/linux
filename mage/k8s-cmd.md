## k8s常用命令

---

### 节点污点处理
taints的effect定义对pod的排斥等级效果：
1. NoSchedule:仅影响调度过程，对现存的pod对象不产生影响
2. NoExecute：既影响调度过程也影响现存的pod对象，不容忍的pod对象将被驱逐
3. PreferNoSchedule：不能调度到不能容忍的节点上，但是没有节点运行时也可以运行在不容忍时的节点上
```
# 对foo节点进行打污点，key为dedicated、value为special-user、effect为NoSchedule
kubectl taint nodes foo dedicated=special-user:NoSchedule

# 对foo节点进行打污点，key为bar、effect为NoSchedule
kubectl taint nodes foo bar:NoSchedule

# 移除节点foo上key为dedicated、effect为NoSchedule的污点
kubectl taint nodes foo dedicated:NoSchedule-

# 移除节点foo上key为dedicated的污点
kubectl taint nodes foo dedicated-

# 对符合标签为 myLabel=X 的节点进行打污点，key为foo、effect为PreferNoSchedule
kubectl taint node -l myLabel=X  dedicated=foo:PreferNoSchedule
```

#### 批量获取节点的污点
```
NodeName=`kubectl get nodes | grep -v NAME | awk '{print $1}'`
for node in $NodeName;do echo "Node: $node";kubectl get node $node -o jsonpath='{.spec.taints}' | jq .;done
```

#### 批量获取标签
```
# 批量获取所有节点标签
NodeName=`kubectl get nodes | grep -v NAME | awk '{print $1}'`
for node in $NodeName;do echo "Node: $node";kubectl get nodes $node -o jsonpath='{.metadata.labels}' | jq .;done

# 批量获取特定名称空间下所有pod标签
Namespace='default'
PodName=`kubectl get pods -n ${Namespace} | grep -v NAME | awk '{print $1}'`
for pod in $PodName;do echo "Pod: $pod";kubectl get pod $pod -o jsonpath='{.metadata.labels}' | jq .;done

# 批量获取所有名称空间下所有pod标签
NS_POD=(`kubectl get pods -A | grep -v NAME | awk '{print $1,$2}'`)
let Groups=${#NS_POD[*]}/2
SleepTime=0
for i in `seq 1 $Groups`;do let sub_group1=${i}*2-2; let sub_group2=${sub_group1}+1; echo "Namespace: ${NS_POD[$sub_group1]} Pod: ${NS_POD[$sub_group2]}";kubectl get pod ${NS_POD[$sub_group2]} -n ${NS_POD[$sub_group1]} -o jsonpath='{.metadata.labels}' | jq .; sleep ${SleepTime} ;done
```




#### argocd脚本实现批量上线、回滚
```
[root@prometheus ~]# cat rollouts-online-rollback.sh 
#!/bin/bash
# description: argocd onekey deploy and rollback.
# date: 202301121333
# author: jackli

AUTH_PASSWORD='homsom.com'
# rollback() and full_online() use
ARGO_ROLLOUT_PROJECT_NAME=(`kubectl argo rollouts list rollout -A | awk -F ' ' '{if($4=="Paused" && $5=="3/5") print $1,$2}'`)
let group_number=${#ARGO_ROLLOUT_PROJECT_NAME[*]}/2
# online() use
ARGO_ROLLOUT_PROJECT_NAME_FOR_ONLINE=(`kubectl argo rollouts list rollout -A | awk -F ' ' '{if($4=="Paused" && $5=="1/5") print $1,$2}'`)
let group_number_for_online=${#ARGO_ROLLOUT_PROJECT_NAME_FOR_ONLINE[*]}/2

auth(){
	read -s -t 30 -n 16 -p 'please input password:' CMD_PASSWORD
	if [ "${CMD_PASSWORD}" != "${AUTH_PASSWORD}" ];then
		echo -e '\n[ERROR]: password error!'
		exit 10
	else
		echo -e '\n'
	fi
}

list(){
	# list paused application
	echo '[INFO]: paused application list'
	kubectl argo rollouts list rollout -A | awk 'NR==1{print $0} {if($4=="Paused") print $0}'
}

online(){
	echo '[INFO]: application online'
	auth
	if [ $? == 0 ];then
		for i in `seq 1 ${group_number_for_online}`;do
			let sub_group1=${i}*2-2
			let sub_group2=${i}*2-1
			# promote application
			kubectl argo rollouts promote ${ARGO_ROLLOUT_PROJECT_NAME_FOR_ONLINE[${sub_group2}]} -n ${ARGO_ROLLOUT_PROJECT_NAME_FOR_ONLINE[${sub_group1}]}
		done
	fi
}

rollback(){
	echo '[INFO]: application rollback'
	auth
	if [ $? == 0 ];then
		for i in `seq 1 ${group_number}`;do
			let sub_group1=${i}*2-2
			let sub_group2=${i}*2-1
			# rollback application
			kubectl argo rollouts undo ${ARGO_ROLLOUT_PROJECT_NAME[${sub_group2}]} -n ${ARGO_ROLLOUT_PROJECT_NAME[${sub_group1}]}
		done
	fi
}

full_online(){
	echo '[INFO]: application full_online'
	auth
	if [ $? == 0 ];then
		DATETIME=`date +'%Y%m%d%H%M%S'`
		for i in `seq 1 ${group_number}`;do
			let sub_group1=${i}*2-2
			let sub_group2=${i}*2-1
 			# label application full online time
			kubectl label application -n argocd ${ARGO_ROLLOUT_PROJECT_NAME[${sub_group2}]%-rollout} date- &> /dev/null && kubectl label application -n argocd ${ARGO_ROLLOUT_PROJECT_NAME[${sub_group2}]%-rollout} date=${DATETIME} &> /dev/null
			# promote full application
			kubectl argo rollouts promote --full ${ARGO_ROLLOUT_PROJECT_NAME[${sub_group2}]} -n ${ARGO_ROLLOUT_PROJECT_NAME[${sub_group1}]}
		done
	fi
}

case "$1" in
	list)
		$1;;
	online)
		$1;;
	rollback)
		$1;;
	full_online)
		$1;;
	*)    
      		echo "Usage: $0 { list | online | rollback | full_online }" 
        	exit 2 
esac
```





#### 常用命令

```bash
## 获取所有rollout项目名称
TMP_FILE='/tmp/test.txt'
kubectl get rollout -A | awk '{print $2}' | awk -F'-rollout' '{print $1}' | sed -e 's/pro-//g' -e 's|-|.|g' | grep -v NAME | tee ${TMP_FILE}
## 过滤特定名称空间特定镜像，查看是否发过项目，并从项目文件列表中删除从未发布的项目
NS='pro-frontend'
IMAGE_FILTER='helloworld'
 FILTER_PROJECT=$(for i in `kubectl get rollout -n $NS | grep -v NAME | awk '{print $1}'`;do kubectl get rollout -n $NS $i -o jsonpath="{.spec.template.spec.containers[0].image}" | grep $IMAGE_FILTER > /dev/null && echo $i | sed -e "s/pro-//g" -e "s|-rollout||" -e "s|-|.|g" ;done); for i in $FILTER_PROJECT;do echo $i;sed -i "/$i/d" $TMP_FILE;done 
 
 
 
## 查看 指定名称空间 所有pod的 延迟时间 存活探测
for i in `kubectl get rollout -n pro-java | grep -v NAME | awk '{print $1}'`;do echo $i; kubectl get rollout -n pro-java $i -o jsonpath="{.spec.template.spec.containers[0].livenessProbe.initialDelaySeconds}";echo;done




## 1. 批量查看 指定名称空间 deployment requests.cpu 值，并过滤值为100m的项目名称进行格式处理后打印
NS='uat-frontend'
OUT_FILE="/tmp/$NS-resources_requests_cpu.txt"
for i in `kubectl get deploy -n $NS | grep -v NAME | awk '{print $1}'`;do V=`kubectl get deploy $i -n $NS -o jsonpath="{.spec.template.spec.containers[0].resources.requests.cpu}"`; echo $V | grep '100' >& /dev/null && echo $i | sed 's/-deployment//';done > $OUT_FILE

## 2. 批量修改test分支请求资源值，从/cpu: 100m/cpu: 10m/，/memory: 100Mi/memory: 50Mi/
for i in `cat $OUT_FILE`;do cd $i; git checkout test && pulltest && sed -i -e 's/cpu: 100m/cpu: 10m/g' -e 's/memory: 100Mi/memory: 50Mi/g' kustomize/base/deployment.yaml && pushtest; cd ..;done



## 批量强制删除指定状态下指定名称空间的pod
for i in `kubectl  get pods -o wide -A | grep 'Terminating' | grep 'fat-dotnet' | awk '{print $2}'`;do kubectl delete pods --force=true --grace-period=0 $i -n fat-dotnet ;done


# 截取Virtualservice域名
kubectl get vs -A | grep -i 'hs\.com' | awk '{print $4}' | tr -d '["]' | tr ',' '\n' | sort
```



