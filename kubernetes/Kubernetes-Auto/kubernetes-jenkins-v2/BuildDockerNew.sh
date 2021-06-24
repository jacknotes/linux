#!/bin/sh
#describe: .net core build docker and kubernetes deploy.
#author: Jackli
#datetime: 2021-06-18-14:47

#init variables
DEPLOY_ENV=${DeployENV}
PROJECT_NAMESPACE=${PublishEnvironment}
PUBLISH_PASSWORD=${PublishPassword}
PROJECT_NAME=${JOB_NAME}
MIRROR_NAME=${PROJECT_NAME}
IMAGE_TAG="v"$(date +"%Y%m%d%H%M%S")
ALIYUN_REPOSITORY='registry.cn-shanghai.aliyuncs.com'
ALIYUN_USERNAME='USERNAME'
ALIYUN_PASSWORD='PASSWORD'
REPOSITORY='192.168.13.235:8000'
USERNAME='USERNAME'
PASSWORD='PASSWORD'
SHELL_DIRECTORY="/shell"
DATE_FILE="${SHELL_DIRECTORY}/.date"
CURRENT_DATE=$(date +"%d")
#kubernetes variables
KUBERNETES_DEPLOY_TYPE=${KUBERNETES_DEPLOY_TYPE}
KUBERNETES_PROJECT_DOMAINNAME="${KUBERNETES_PROJECT_DOMAINNAME}"
KUBERNETES_POD_IMAGE="${KUBERNETES_POD_IMAGE}"
KUBERNETES_POD_PORT="${KUBERNETES_POD_PORT}"
KUBERNETES_POD_REPLICA="${KUBERNETES_POD_REPLICA}"
KUBERNETES_DEPLOY_FILE='/shell/k8s.sh'
DATETIME="date +'%Y-%m-%d %H:%M:%S'"

#if deploy type is create, call code section
if [ ${KUBERNETES_DEPLOY_TYPE} == "create" ];then
	# test if is pro envionment,namespace,is true will password.
	if [ ${PROJECT_NAMESPACE} == 'pro' ] && [ ${PUBLISH_PASSWORD}  != 'homsom+4006123123' ];then
		echo "`eval ${DATETIME}`: ERROR: PUBLISH_PASSWORD wrong" 
		exit 6
	fi

	# test init environments if legal.
	#if [ -z ${KUBERNETES_PROJECT_DOMAINNAME} ];then
	#     	 echo "`eval ${DATETIME}`: arguments PROJECT_MAP_DOMAINNAME is null"
	#        exit 10
	#elif [ -z ${KUBERNETES_POD_PORT} ];then
	#	echo "`eval ${DATETIME}`: arguments KUBERNETES_POD_PORT is null"
	#	exit 10
	#fi

	#init Date Parameter,use whether delete clear_docker
	group=`ls -l -d /shell | awk '{print $4}'`
	[ ${group} == 'jenkins' ] || (sudo /usr/bin/chown -R root:jenkins ${SHELL_DIRECTORY}; sudo /usr/bin/chmod -R 770 ${SHELL_DIRECTORY})
	[ -f ${DATE_FILE} ] || (sudo /usr/bin/touch ${DATE_FILE}; sudo /usr/bin/chown jenkins:jenkins ${DATE_FILE}; sudo /usr/bin/chmod 770 ${DATE_FILE})
	[ -z ${DATE_FILE} ] && echo $(date +"%d") > ${DATE_FILE}
	Date=$(cat ${DATE_FILE})
	
	#clear docker container and image cache
	clear_docker(){
		#delete docker container is Exited.
		echo "delete docker container is Exited.------------------------------"
		Exited_Containers=$(sudo docker ps -a | grep -v CONTAINER | grep 'Exited' |  awk '{print $1}')
		for i in ${Exited_Containers};do
			echo "Delete Exited Container $i ........."
			sudo docker rm $i 
			if [ $? == 0 ];then
				echo "INFO: Exited Status Container ${i} Delete Succeed" 
			else
				echo "ERROR: Exited Status Container ${i} Delete Failure" 
			fi
		done
		
		#delete local name is <none> image
		echo "delete local name is <none> image---------------------------"
		NoNameImage=$(sudo docker image ls | grep '<none>' | awk '{print $3}') #if not delete name is <none> image,annotation can be. 
		for i in ${NoNameImage};do
			echo "delete local not name image $i ........."
			sudo docker image rm $i 
			if [ $? == 0 ];then
				echo "INFO: Local not name Image ${i} Delete Succeed" 
			else
				echo "ERROR: Local not name Image ${i} Delete Failure" 
			fi
		done
	}
	
	#change to workspace
	cd /var/lib/jenkins/workspace/${PROJECT_NAME}
	
	#build docker image
	echo "build docker image---------------------------------"
	echo "build image ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG}........"
	sudo docker build -t ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} . 
	if [ $? == 0 ];then
		echo "INFO: Docker Build Image Succeed" 
	else
		echo "ERROR: Docker Build Image Failure" 
		clear_docker
		exit 6
	fi
	
	#login private repository
	echo "login private repository-----------------------------"
	echo "login ${REPOSITORY}........."
	sudo docker login -u ${USERNAME} -p ${PASSWORD} ${REPOSITORY} 
	if [ $? == 0 ];then
		echo "INFO: Login Succeed"
	else
		echo "ERROR: Login Failure"
		exit 6
	fi
	
	#tag image 
	echo "tag image---------------------------------"
	echo "tag image ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} to ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG}........"
	sudo docker tag ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} 
	if [ $? == 0 ];then
		echo "INFO: Tag Image Succeed" 
	else
		echo "ERROR: Tag Image Failure" 
		exit 6
	fi
	
	#push local image to remote repository
	echo "push local image to remote repository----------------------------"
	echo "push local image ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} to remote repository ${REPOSITORY}......."
	sudo docker push ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} 
	if [ $? == 0 ];then
		KUBERNETES_POD_IMAGE="${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG}"
		echo "INFO: Push ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} Image To Remote REPOSITORY Succeed" 
	else
		echo "ERROR: Push ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} Image To Romote REPOSITORY Failure" 
		exit 6
	fi
	
	#logout private repository
	echo "logout ${REPOSITORY}-------------------------------"
	sudo docker logout ${REPOSITORY} 
	if [ $? == 0 ];then
		echo "INFO: Logout Succeed" 
	else
		echo "ERROR: Logout Failure" 
		exit 6
	fi
	
	#ALiYun Push
	#if [ ${DeployENV} ];then
		if [ ${DeployENV} == 'homsom-aliyun' ];then
			echo "INFO: Start Push Image to ALiYun REPOSITORY-------------------------------"
			echo "Login ${ALIYUN_REPOSITORY}.........."
			sudo docker login -u ${ALIYUN_USERNAME} -p ${ALIYUN_PASSWORD} ${ALIYUN_REPOSITORY} 
			if [ $? == 0 ];then
				echo "ALiYunINFO: Login ALiYun REPOSITORY Succeed"
			else
				echo "ALiYunERROR: Login ALiYun REPOSITORY  Failure"
				exit 6
			fi
			
			echo "Tag Image ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG}.........."
			sudo docker tag ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG}  
			if [ $? == 0 ];then
				echo "ALiYunINFO: Tag ALiYun Image Succeed" 
			else
				echo "ALiYunERROR: Tag ALiYun Image Failure" 
				exit 6
			fi
		
			echo "Push Image To ALiYun REPOSITORY.........."
			sudo docker push ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG}
			if [ $? == 0 ];then
				echo "------------------------------------------------------------------------------------------------------------------------------"
			        echo "ALiYunINFO: Push ALiYunImage ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG} To Remote REPOSITORY Succeed" 
				echo "------------------------------------------------------------------------------------------------------------------------------"
			else
				echo "------------------------------------------------------------------------------------------------------------------------------"
			        echo "ALiyunERROR: Push ALiYunImage ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG} To Romote REPOSITORY Failure" 
				echo "------------------------------------------------------------------------------------------------------------------------------"
			        exit 6
			fi
			
			echo "logout ${ALIYUN_REPOSITORY}.........."
			sudo docker logout ${ALIYUN_REPOSITORY}
			if [ $? == 0 ];then
			        echo "INFO: Logout ALIYUN_REPOSITORY Succeed" 
			else
			        echo "ERROR: Logout ALIYUN_REPOSITORY Failure" 
			        exit 6
			fi
		fi
	#fi
	
	#delete local build and push image
	echo "delete local build and push image------------------------------"
	#if [ ${DeployENV} ];then
		if [ ${DeployENV} == 'homsom-aliyun' ];then
			echo "delete local image ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG}........"
			sudo docker image rm ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG} 
			if [ $? == 0 ];then
				echo "INFO: Local Image ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG} Delete Succeed" 
			else
				echo "ERROR: Local Image ${ALIYUN_REPOSITORY}/${DEPLOY_ENV}/${MIRROR_NAME}:${IMAGE_TAG} Delete Failure" 
				exit 6
			fi
		fi
	#fi
	
	echo "delete local image ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} and ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG}........"
	sudo docker image rm ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG}
	if [ $? == 0 ];then
		echo "INFO: Local Image ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} Delete Succeed" 
	else
		echo "ERROR: Local Image ${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} ${REPOSITORY}/${PROJECT_NAMESPACE}/${MIRROR_NAME}:${IMAGE_TAG} Delete Failure" 
		exit 6
	fi
	
	#call clear_docker function	
	if [[ ${CURRENT_DATE} != ${Date} ]];then
		clear_docker
		#insert new date
		echo $(date +"%d") > ${DATE_FILE}
	fi

	#kubernetes code section
	if [ ${PROJECT_NAMESPACE} == 'pro' ] && [ ${DEPLOY_ENV} == 'homsom-hs' ];then
		echo "`eval ${DATETIME}`: deploy_type is ${KUBERNETES_DEPLOY_TYPE}"
		echo "--------------------------------------------"
		echo "`eval ${DATETIME}`: start kubernetes deploy..............."
		# test KUBERNETES_PROJECT_DOMAINNAME,KUBERNETES_POD_PORT,KUBERNETES_POD_REPLICA value if legal
		if [ -z ${KUBERNETES_PROJECT_DOMAINNAME} ];then
			echo "`eval ${DATETIME}`: KUBERNETES_PROJECT_DOMAINNAME is null"
			exit 10
		elif [ ! `echo "${KUBERNETES_PROJECT_DOMAINNAME}" | grep ^.*hs.com$` ];then
			echo "`eval ${DATETIME}`: KUBERNETES_PROJECT_DOMAINNAME not regex '^.*hs.com$'"
		        exit 10
		elif [ -z ${KUBERNETES_POD_PORT} ];then
			echo "`eval ${DATETIME}`: KUBERNETES_POD_PORT is null"
		        exit 10
		elif [[ ! ${KUBERNETES_POD_PORT} -gt 0 ]] || [[ ! ${KUBERNETES_POD_PORT} -lt 65536 ]];then
			echo "`eval ${DATETIME}`: KUBERNETES_POD_PORT values not is 1-65535"
		        exit 10
		elif [ -z ${KUBERNETES_POD_REPLICA} ];then
			echo "`eval ${DATETIME}`: KUBERNETES_POD_REPLICA is null"
		        exit 10
		elif [[ ! ${KUBERNETES_POD_REPLICA} -gt 0 ]] || [[ ! ${KUBERNETES_POD_REPLICA} -lt 5 ]];then
			echo "`eval ${DATETIME}`: KUBERNETES_POD_REPLICA values not is 1-4"
		        exit 10
		fi
		
		# call kubernetes shell
		echo "`eval ${DATETIME}`: execute kuberenetes ${KUBERNETES_DEPLOY_TYPE} step...."
		#/k8s.sh create NAMESPACE PROJECT_NAME PROJECT_DOMAIN_NAME KUBERNETES_POD_IMAGE KUBERNETES_POD_PORT KUBERNETES_POD_REPLICA
		echo '--------------------------'
		echo "`eval ${DATETIME}`: namespace: ${PROJECT_NAMESPACE}"
		echo "`eval ${DATETIME}`: project_name: ${PROJECT_NAME}"
		echo "`eval ${DATETIME}`: kubernetes_project_domainname: ${KUBERNETES_PROJECT_DOMAINNAME}"
		echo "`eval ${DATETIME}`: kubernetes_pod_image: ${KUBERNETES_POD_IMAGE}"
		echo "`eval ${DATETIME}`: kubernetes_pod_port: ${KUBERNETES_POD_PORT}"
		echo "`eval ${DATETIME}`: kubernetes_pod_replica: ${KUBERNETES_POD_REPLICA}"
		echo '--------------------------'
		${KUBERNETES_DEPLOY_FILE} ${KUBERNETES_DEPLOY_TYPE} ${PROJECT_NAMESPACE} ${PROJECT_NAME} ${KUBERNETES_PROJECT_DOMAINNAME} ${KUBERNETES_POD_IMAGE} ${KUBERNETES_POD_PORT} ${KUBERNETES_POD_REPLICA}
	fi
#if deploy type is rollback, call code section
elif [ ${KUBERNETES_DEPLOY_TYPE} == "rollback" ];then
	# test if is pro envionment,namespace,is true will password.
	if [ ${DEPLOY_ENV} == 'homsom-hs' ] && [ ${PROJECT_NAMESPACE} == 'pro' ] && [ ${PUBLISH_PASSWORD}  != 'homsom+4006123123' ];then
		echo "`eval ${DATETIME}`: ERROR: PUBLISH_PASSWORD wrong" 
		exit 6
	else
		echo "`eval ${DATETIME}`: DEPLOY_ENV must is 'homsom-hs', PROJECT_NAMESPACE must is 'pro', PUBLISH_PASSWORD must input correct!"
	fi

	echo "`eval ${DATETIME}`: kubernetes_deploy_type is ${KUBERNETES_DEPLOY_TYPE}"
	echo "`eval ${DATETIME}`: execute kuberenetes ${KUBERNETES_DEPLOY_TYPE} step...."
	# call kubernetes shell
	# ./k8s.sh rollback NAMESPACE PROJECT_NAME
	echo '--------------------------'
	echo "`eval ${DATETIME}`: project_namespace: ${PROJECT_NAMESPACE}"
	echo "`eval ${DATETIME}`: project_name: ${PROJECT_NAME}"
	echo '--------------------------'
	${KUBERNETES_DEPLOY_FILE} ${KUBERNETES_DEPLOY_TYPE} ${PROJECT_NAMESPACE} ${PROJECT_NAME}
#if deploy type is scale, call code section
elif [ ${KUBERNETES_DEPLOY_TYPE} == "scale" ];then
	# test if is pro envionment,namespace,is true will password.
	if [ ${DEPLOY_ENV} == 'homsom-hs' ] && [ ${PROJECT_NAMESPACE} == 'pro' ] && [ ${PUBLISH_PASSWORD}  != 'homsom+4006123123' ];then
		echo "`eval ${DATETIME}`: ERROR: PUBLISH_PASSWORD wrong" 
		exit 6
	else
		echo "`eval ${DATETIME}`: DEPLOY_ENV must is 'homsom-hs', PROJECT_NAMESPACE must is 'pro', PUBLISH_PASSWORD must input correct!"
	fi

	echo "`eval ${DATETIME}`: kubernetes_deploy_type is ${KUBERNETES_DEPLOY_TYPE}"
	echo "`eval ${DATETIME}`: execute kuberenetes ${KUBERNETES_DEPLOY_TYPE} step...."
	# test KUBERNETES_POD_IMAGE,KUBERNETES_POD_REPLICA value if legal
	if [ -z ${KUBERNETES_POD_IMAGE} ];then
		echo "`eval ${DATETIME}`: KUBERNETES_POD_IMAGE is null"
	        exit 10
	elif [ -z ${KUBERNETES_POD_REPLICA} ];then
		echo "`eval ${DATETIME}`: KUBERNETES_POD_REPLICA is null"
	        exit 10
	elif [[ ! ${KUBERNETES_POD_REPLICA} -gt 0 ]] || [[ ! ${KUBERNETES_POD_REPLICA} -lt 7 ]];then
		echo "`eval ${DATETIME}`: KUBERNETES_POD_REPLICA values not is 1-6"
	        exit 10
	fi
	
	# test pod image tag if is old image.
	REPOSITORY_IP=`echo ${KUBERNETES_POD_IMAGE} | egrep '^[0-9]' &> /dev/null && echo ip`
	REPOSITORY_DOMAIN=`echo ${KUBERNETES_POD_IMAGE} | grep 'hs.com' &> /dev/null && echo domain`
	if [ ${REPOSITORY_IP} == 'ip' ];then
		KUBERNETES_POD_IMAGE_TAG=`echo ${KUBERNETES_POD_IMAGE} | awk -F":" '{print $3}' | tr -dc '0-9'`
		if [ ${KUBERNETES_POD_IMAGE_TAG} -ge `date +"%Y%m%d%H%M%S"` ];then
			echo "`eval ${DATETIME}`: KUBERNETES_POD_IMAGE_TAG version:${KUBERNETES_POD_IMAGE_TAG} is greater than `date +"%Y%m%d%H%M%S"`,not is old image."
			exit 10	
		fi
	elif [ ${REPOSITORY_DOMAIN} == 'domain' ];then
		KUBERNETES_POD_IMAGE_TAG=`echo ${KUBERNETES_POD_IMAGE} | awk -F":" '{print $2}' | tr -dc '0-9'`
		exit 1
		if [ ${KUBERNETES_POD_IMAGE_TAG} -ge `date +"%Y%m%d%H%M%S"` ];then
			echo "`eval ${DATETIME}`: KUBERNETES_POD_IMAGE_TAG version:${KUBERNETES_POD_IMAGE_TAG} is greater than `date +"%Y%m%d%H%M%S"`,not is old image."
			exit 10
		fi
	fi

	##test deployment controller subfix base and canary-weight if exists.
        if [[ ! `sudo kubectl get deployment -n ${PROJECT_NAMESPACE} 2> /dev/null | grep ${PROJECT_NAME}-base` ]];then
                echo "`eval ${DATETIME}`: Deployment controller ${PROJECT_NAME}-base is not exists, please use 'KUBERNETES_DEPLOY_TYPE:create' build"
                exit 10
        elif [[ ! `sudo kubectl get deployment -n ${PROJECT_NAMESPACE} 2> /dev/null | grep ${PROJECT_NAME}-canary-weight` ]];then
                echo "`eval ${DATETIME}`: Deployment controller ${PROJECT_NAME}-canary-weight is not exists, please use 'KUBERNETES_DEPLOY_TYPE:create' build"
                exit 10
        fi

	# call kubernetes shell
	# ./k8s.sh deploy NAMESPACE PROJECT_NAME KUBERNETES_POD_IMAGE KUBERNETES_POD_REPLICA
	echo '--------------------------'
	echo "`eval ${DATETIME}`: project_namespace: ${PROJECT_NAMESPACE}"
	echo "`eval ${DATETIME}`: project_name: ${PROJECT_NAME}"
	echo "`eval ${DATETIME}`: kubernetes_pod_image: ${KUBERNETES_POD_IMAGE}"
	echo "`eval ${DATETIME}`: kubernetes_pod_replica: ${KUBERNETES_POD_REPLICA}"
	echo '--------------------------'
	${KUBERNETES_DEPLOY_FILE} deploy ${PROJECT_NAMESPACE} ${PROJECT_NAME} ${KUBERNETES_POD_IMAGE} ${KUBERNETES_POD_REPLICA}
#if deploy type is not legal, call code section
else
	echo "`eval ${DATETIME}`: deploy_type values is not legal."
	exit 10
fi



