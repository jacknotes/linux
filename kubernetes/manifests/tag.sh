#!/bin/sh
#version: v2
#author: jackli

Repository="192.168.13.235:8000"
Project="ops/kubernetes"
Kubernetes_domain="k8s.gcr.io"
Kubernetes_Version='v1.15.12'
Aliyun_Repository='registry.aliyuncs.com/google_containers'
Packages="coredns:1.3.1 pause:3.1 kube-scheduler:v1.15.12 kube-proxy:v1.15.12 kube-controller-manager:v1.15.12 kube-apiserver:v1.15.12 etcd:3.3.10"

#batch docker pull
function pull_k8s_FromAliyun(){
	kubeadm config images pull --image-repository=${Aliyun_Repository} --kubernetes-version=${Kubernetes_Version}
	[ $? == 0 ] && echo "pull from aliyun registry successful" || echo "pull from aliyun registry failure"
}

function untag_k8s_FromAliyun(){
	aliyun=(`docker image ls | grep aliyuncs | awk '{ sub(/\ +/,":"); print $1}' | sort`) #error point
	google=(`docker image ls | grep aliyuncs | awk '{ sub(/\ +/,":"); print $1}' | awk -F '/' '{print k8s"/"$3}' k8s=${Kubernetes_domain} | sort`)
	let k8s_sum=${#aliyun[@]}-1
	for i in `seq 0 ${k8s_sum}`;do
		docker tag ${aliyun[$i]} ${google[$i]}
	done
	[ $? == 0 ] && echo "tag aliyun name to google name successful" || echo "tag aliyun to google failure"
}

#batch docker tag 
function tag_ToPriRegistry(){
	for i in `docker image ls  | grep registry | grep -v REPOSITORY | awk '{ sub(/\ +/,":"); print $1}' `;do docker tag $i ${Repository}/${Project}/${Kubernetes_domain}/`echo ${i} | awk -F '/' '{print $3}'`;done
	[ $? == 0 ] && echo "tag to private registry name successful" || echo "tag to private registry name failure"
}

#batch docker push
function push_ToPriRegistry(){
	docker login ${Repository}
	for i in `docker image ls  | grep ${Repository} | grep -v REPOSITORY | awk '{ sub(/\ +/,":"); print $1}'`;do docker push $i;done
	[ $? == 0 ] && echo "push to private registry successful" || echo "push to private registry failure"
	docker logout
}

function pull_FromPriRegistry(){
	for i in ${Packages};do 
		docker pull ${Repository}/${Project}/${Kubernetes_domain}/$i
	done
	[ $? == 0 ] && echo "pull from private registry successful" || echo "pull from private registry failure"
}

#batch docker untag
function untag_FromPriRegistry(){
	local_image="docker image ls  | grep ${Repository} | grep -v REPOSITORY | awk '{ sub(/\ +/,\":\"); print \$1}' | sort"
	pri_image=(`eval ${local_image}`)
	k8s_image=(`eval ${local_image} | sed "s#${Repository}\/${Project}\/##g"`)
	let sum=${#pri_image[@]}-1
	for i in `seq 0 ${sum}`;do
		docker tag ${pri_image[$i]} ${k8s_image[$i]}
	done
	[ $? == 0 ] && echo "untag from private registry successful" || echo "untag from private registry failure"
}

case $1 in
	pull_k8s_FromAliyun)
		pull_k8s_FromAliyun;;
	untag_k8s_FromAliyun)
		untag_k8s_FromAliyun;;
	tag_ToPriRegistry)
		tag_ToPriRegistry;;
	push_ToPriRegistry)
		push_ToPriRegistry;;
	pull_FromPriRegistry)
		pull_FromPriRegistry;;
	untag_FromPriRegistry)
		untag_FromPriRegistry;;
	*)
		echo "Usage: $0 (pull_k8s_FromAliyun | untag_k8s_FromAliyun | tag_ToPriRegistry | push_ToPriRegistry | pull_FromPriRegistry | untag_FromPriRegistry)"
esac
