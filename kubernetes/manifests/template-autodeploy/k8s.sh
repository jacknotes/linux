#!/bin/sh
DATETIME="date +'%Y-%m-%d %H:%M:%S'"
NGINX_SERVER='192.168.13.56'
SOURCE_DIRECTOR="/root/template"
TARGET_DIRECTOR="/tmp/kubernetes/homsom"


check_endpoint(){
	NAMESPACE=$1
	PROJECT_NAME=$2
	IMAGE=$3
	REPLICA=$4
	DEPLOYMENT_NAME=$5
	REPLICASET_RERULT=0
	SECOND_NUMBER=180
	sleep 1
	if [[ `kubectl get replicaset -o wide -n ${NAMESPACE} 2> /dev/null | grep "${DEPLOYMENT_NAME}.*${IMAGE}" 2> /dev/null` ]];then
		REPLICASET_NAME=`kubectl get replicaset -o wide -n ${NAMESPACE} | grep "${DEPLOYMENT_NAME}.*${IMAGE}" 2> /dev/null | awk '{print $1}'`
		echo "`eval ${DATETIME}`: replicaset: ${REPLICASET_NAME} is running, current READY status is not READY, probe BEGIN."
		for i in `seq 1 ${SECOND_NUMBER}`;do
			echo "`eval ${DATETIME}`: probe ${i} second..."	
			REPLICASET_RERULT=`kubectl get replicaset -o wide -n ${NAMESPACE} | grep "${DEPLOYMENT_NAME}.*${IMAGE}" | awk '{if($2==$3 && $3==$4 && $2==replica) print "1"; else print "0";}' replica=$REPLICA`
			if [ ${REPLICASET_RERULT} == 1 ];then
				echo "`eval ${DATETIME}`: replicaset: ${REPLICASET_NAME} is running, current READY status is READY, probe END."
 	                	echo "`eval ${DATETIME}`: endpoint: ${DEPLOYMENT_NAME} currrent status is READY."
				return 0
			fi	
			sleep 1
		done
		echo "`eval ${DATETIME}`: replicaset: ${REPLICASET_NAME} is running, current READY status is not READY, probe END."
		echo "`eval ${DATETIME}`: endpoint: ${DEPLOYMENT_NAME} currrent status is not READY."
		return 5
	else
		echo "`eval ${DATETIME}`: replicaset: ${REPLICASET_NAME:-nameError} is not running."
		echo "`eval ${DATETIME}`: endpoint: ${DEPLOYMENT_NAME} currrent status is not READY."
		return 5
	fi
}

create(){
	NAMESPACE=$1
	PROJECT_NAME=$2
	PROJECT_DOMAIN_NAME=$3
	#DEPLOY_TYPE=$4
	POD_IMAGE=$4
	POD_PORT=$5
	POD_REPLICAS=$6
	TEMPLATE_DIRECTORY=${TARGET_DIRECTOR}/${NAMESPACE}/template
	DEPLOYMENT_SOURCE_TEMPLATE_FILE=${SOURCE_DIRECTOR}/deployment-template.yaml
	INGRESS_SOURCE_TEMPLATE_FILE=${SOURCE_DIRECTOR}/ingress-template.yaml
	DEPLOYMENT_TARGET_TEMPLATE_FILE=${TEMPLATE_DIRECTORY}/${PROJECT_NAME}-deployment
	INGRESS_TARGET_TEMPLATE_FILE=${TEMPLATE_DIRECTORY}/${PROJECT_NAME}-ingress

	##judge variable DEPLOY_TYPE if legal.
	if [[ ! `kubectl get deployment -n ${NAMESPACE} 2> /dev/null | grep ${PROJECT_NAME}-base` ]];then
		DEPLOY_TYPE='base'
	elif [[ ! `kubectl get deployment -n ${NAMESPACE} 2> /dev/null | grep ${PROJECT_NAME}-canary-weight` ]];then
		DEPLOY_TYPE='canary-weight'
	else
		echo "`eval ${DATETIME}`: deploy type 'base' and 'canary-weight' already exists,call deploy function."
		deploy ${NAMESPACE} ${PROJECT_NAME} ${POD_IMAGE} ${POD_REPLICAS}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: create successful."
			exit 0
		fi
	fi

	#--- service
	Service_metadata_name="${PROJECT_NAME}-${DEPLOY_TYPE}"
	Service_metadata_namespace="${NAMESPACE}"
	Service_spec_selector_app="${PROJECT_DOMAIN_NAME}"
	Service_spec_selector_tag="${DEPLOY_TYPE}"
	Service_spec_ports_targetPort="${POD_PORT}"
	#--- deployment
	Deployment_metadata_name="${PROJECT_NAME}-${DEPLOY_TYPE}"
	Deployment_metadata_namespace="${NAMESPACE}"
	Deployment_spec_replicas="${POD_REPLICAS}"
	Deployment_spec_selector_matchLabels_app="${PROJECT_DOMAIN_NAME}"
	Deployment_spec_selector_matchLabels_tag="${DEPLOY_TYPE}"
	Deployment_spec_template_metadata_labels_app="${PROJECT_DOMAIN_NAME}"
	Deployment_spec_template_metadata_labels_tag="${DEPLOY_TYPE}"
	Deployment_spec_template_spec_containers_name="${PROJECT_NAME}"
	Deployment_spec_template_spec_containers_image="${POD_IMAGE}"
	#--- ingress
	Ingress_metadata_name="${Deployment_metadata_name}"
	Ingress_metadata_namespace="${NAMESPACE}"
	Ingress_spec_rules_host="${PROJECT_DOMAIN_NAME}"
	Ingress_spec_rules_http_paths_backend_serviceName="${Service_metadata_name}"
	
	#judge template directory if exists.
	[ ! -e ${TEMPLATE_DIRECTORY} ] && mkdir -p ${TEMPLATE_DIRECTORY}
	# judge source template file if exists
	if [ ! -e ${DEPLOYMENT_SOURCE_TEMPLATE_FILE} ];then
		echo "`eval ${DATETIME}`: source deployment template file is not exists."
		exit 5
	elif [ ! -e ${INGRESS_SOURCE_TEMPLATE_FILE} ];then
		echo "`eval ${DATETIME}`: source ingress template file is not exists."
                exit 5
	else
		if [ ${DEPLOY_TYPE} == 'base' ];then
			DEPLOYMENT_TARGET_TEMPLATE_FILE=${DEPLOYMENT_TARGET_TEMPLATE_FILE}-${DEPLOY_TYPE}.yaml
			INGRESS_TARGET_TEMPLATE_FILE=${INGRESS_TARGET_TEMPLATE_FILE}-${DEPLOY_TYPE}.yaml
			\cp -a ${DEPLOYMENT_SOURCE_TEMPLATE_FILE} ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
			\cp -a ${INGRESS_SOURCE_TEMPLATE_FILE} ${INGRESS_TARGET_TEMPLATE_FILE}
			if [ $? == 0 ];then
				echo "`eval ${DATETIME}`: copy source template file to target template file successful."
			else
				echo "`eval ${DATETIME}`: copy source template file to target template file failure."
				exit 5
			fi
		elif [ ${DEPLOY_TYPE} == 'canary-weight' ];then
			DEPLOYMENT_TARGET_TEMPLATE_FILE=${DEPLOYMENT_TARGET_TEMPLATE_FILE}-${DEPLOY_TYPE}.yaml
			INGRESS_TARGET_TEMPLATE_FILE=${INGRESS_TARGET_TEMPLATE_FILE}-${DEPLOY_TYPE}.yaml
                        \cp -a ${DEPLOYMENT_SOURCE_TEMPLATE_FILE} ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
                        \cp -a ${INGRESS_SOURCE_TEMPLATE_FILE} ${INGRESS_TARGET_TEMPLATE_FILE}
                        if [ $? == 0 ];then
                                echo "`eval ${DATETIME}`: copy source template file to target template file successful."
                        else
                                echo "`eval ${DATETIME}`: copy source template file to target template file failure."
                                exit 5
                        fi
		fi
	fi
	
	#modify deployment template file
       	echo "`eval ${DATETIME}`: modify deployment template file......"
	# modify service yaml section
	sed -i "s#__Service_metadata_name__#${Service_metadata_name}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Service_metadata_namespace__#${Service_metadata_namespace}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Service_spec_selector_app__#${Service_spec_selector_app}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Service_spec_selector_tag__#${Service_spec_selector_tag}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Service_spec_ports_targetPort__#${Service_spec_ports_targetPort}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	# modify deployment yaml section
	sed -i "s#__Deployment_metadata_name__#${Deployment_metadata_name}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_metadata_namespace__#${Deployment_metadata_namespace}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_replicas__#${Deployment_spec_replicas}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_selector_matchLabels_app__#${Deployment_spec_selector_matchLabels_app}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_selector_matchLabels_tag__#${Deployment_spec_selector_matchLabels_tag}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_template_metadata_labels_app__#${Deployment_spec_template_metadata_labels_app}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_template_metadata_labels_tag__#${Deployment_spec_template_metadata_labels_tag}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_template_spec_containers_name__#${Deployment_spec_template_spec_containers_name}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} && \
	sed -i "s#__Deployment_spec_template_spec_containers_image__#${Deployment_spec_template_spec_containers_image}#g" ${DEPLOYMENT_TARGET_TEMPLATE_FILE} 
	if [ $? != 0 ];then
       		echo "`eval ${DATETIME}`: modify deployment template file failure"
       		exit 10
       	else
       		echo "`eval ${DATETIME}`: modify deployment template file successful"
        fi
	#modify ingress template file
       	echo "`eval ${DATETIME}`: modify ingress template file......"
	sed -i "s,__Ingress_metadata_name__,${Ingress_metadata_name},g" ${INGRESS_TARGET_TEMPLATE_FILE} && \
	sed -i "s,__Ingress_metadata_namespace__,${Ingress_metadata_namespace},g" ${INGRESS_TARGET_TEMPLATE_FILE} && \
	sed -i "s,__Ingress_spec_rules_host__,${Ingress_spec_rules_host},g" ${INGRESS_TARGET_TEMPLATE_FILE} && \
	sed -i "s,__Ingress_spec_rules_http_paths_backend_serviceName__,${Ingress_spec_rules_http_paths_backend_serviceName},g" ${INGRESS_TARGET_TEMPLATE_FILE}
	if [ $? != 0 ];then
       		echo "`eval ${DATETIME}`: modify ingress template file failure"
       		exit 10
       	else
       		echo "`eval ${DATETIME}`: modify ingress template file successful"
        fi

	#apply modify deployment template file
	kubectl apply -f ${DEPLOYMENT_TARGET_TEMPLATE_FILE} -n ${NAMESPACE} &> /dev/null 
	if [ $? != 0 ];then
                echo "`eval ${DATETIME}`: apply deployment template file failure"
	        exit 10
        else
        	echo "`eval ${DATETIME}`: apply deployment template file successful"
        fi
	
	#check apply deployment template file endpoint status
	check_endpoint ${NAMESPACE} ${PROJECT_NAME} ${POD_IMAGE} ${POD_REPLICAS} ${Deployment_metadata_name}
	if [ $? != 0 ];then
		echo "`eval ${DATETIME}`: Service ${Service_metadata_name} is not running"
		echo "`eval ${DATETIME}`: project: ${PROJECT_NAME}, domainname: ${PROJECT_DOMAIN_NAME}, image: ${POD_IMAGE}, replica: ${POD_REPLICAS} create failure."
		kubectl delete -f ${DEPLOYMENT_TARGET_TEMPLATE_FILE} -n ${NAMESPACE}
		exit 5
	else
		echo "`eval ${DATETIME}`: Service ${Service_metadata_name} is running"
		echo "`eval ${DATETIME}`: project: ${PROJECT_NAME}, domainname: ${PROJECT_DOMAIN_NAME}, image: ${POD_IMAGE}, replica: ${POD_REPLICAS} create success."
	fi
	
	#ingress config.
	#judge deploy_type,annotation canary section.
	if [ ${DEPLOY_TYPE} == "base" ];then
		sed -i 's,nginx.ingress.kubernetes.io/canary,#nginx.ingress.kubernetes.io/canary,g' ${INGRESS_TARGET_TEMPLATE_FILE}
	fi
	#apply modify ingress template file.
	kubectl apply -f ${INGRESS_TARGET_TEMPLATE_FILE} -n ${NAMESPACE} &> /dev/nul
        if [ $? != 0 ];then
        	echo "`eval ${DATETIME}`: apply ingress template file failure"
		kubectl delete -f ${INGRESS_TARGET_TEMPLATE_FILE} -n ${NAMESPACE}
		kubectl delete -f ${DEPLOYMENT_TARGET_TEMPLATE_FILE} -n ${NAMESPACE}
        	exit 10
        else
        	echo "`eval ${DATETIME}`: apply ingress template file successful"
		echo "---------------------create info-------------------------"
		echo "`eval ${DATETIME}`: nginx_server: ${NGINX_SERVER}"
		echo "`eval ${DATETIME}`: domain_name: ${PROJECT_DOMAIN_NAME}"
		echo "`eval ${DATETIME}`: namespace: ${NAMESPACE}"
		echo "`eval ${DATETIME}`: project_name: ${PROJECT_NAME}"
		echo "`eval ${DATETIME}`: pod_image: ${POD_IMAGE}"
		echo "`eval ${DATETIME}`: pod_replicas: ${POD_REPLICAS}"
		echo "---------------------------------------------------------"

		if [ ${DEPLOY_TYPE} == "canary-weight" ];then
			sleep 5 
			#patch not usage deployment replica is 1
			kubectl patch deployment/${PROJECT_NAME}-base -p '{"spec": {"replicas": 1}}' -n ${NAMESPACE} 
		fi
        fi


}


deploy(){
	NAMESPACE=$1
	PROJECT_NAME=$2
	IMAGE=$3
	REPLICA=$4
	#WEIGHT_VALUE=$5
	#deployment base name
	DEPLOYMENT_BASE_NAME=${PROJECT_NAME}-base
	#deployment canary weight name
	DEPLOYMENT_CANARY_WEIGHT_NAME=${PROJECT_NAME}-canary-weight
	#ingress base name
	INGRESS_BASE_NAME=${DEPLOYMENT_BASE_NAME}
	#ingress canary weight name
	INGRESS_CANARY_WEIGHT_NAME=${DEPLOYMENT_CANARY_WEIGHT_NAME}
	#ingress weight values
	INGRESS_WEIGHT_RESULT=`kubectl get ingress/${INGRESS_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -o yaml 2>  /dev/null | grep 'canary-weight: "' | awk -F '"' '{print $2}'`
	#patch directory
	TARGET_PATCH_DIRECTOR="${TARGET_DIRECTOR}/${NAMESPACE}/patch"
	#target ingress template file
	PATCH_INGRESS_CANARY_WEIGHT_FILE=${TARGET_PATCH_DIRECTOR}/patch-ingress-${DEPLOYMENT_CANARY_WEIGHT_NAME}.yaml
	#source patch deployment template file
	SOURCE_PATCH_DEPLOYMENT_FILE="${SOURCE_DIRECTOR}/patch-deployment-template.yaml"
	#source patch ingress template file
	SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE="${SOURCE_DIRECTOR}/patch-ingress-template.yaml"

	#patch directory create
	if [ ! -e ${TARGET_PATCH_DIRECTOR} ];then
		mkdir -p ${TARGET_PATCH_DIRECTOR}
	fi

	# set ingress weight value is 100,enable ingress for weight.
	if [ ${INGRESS_WEIGHT_RESULT} == 0 ];then
		WEIGHT_VALUE=100
		PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE=${TARGET_PATCH_DIRECTOR}/patch-deployment-${DEPLOYMENT_CANARY_WEIGHT_NAME}.yaml

		#backup target template fiile
		if [ -e ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE} ];then
			\cp -a ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE} ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE}-backup
		fi

		#copy source template to target template
		\cp -a ${SOURCE_PATCH_DEPLOYMENT_FILE} ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE}
		if [ $? != 0 ];then
			echo "`eval ${DATETIME}`: copy ${SOURCE_PATCH_DEPLOYMENT_FILE} to ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE} failure." 
			exit 5
		fi

		echo "`eval ${DATETIME}`: current running ingress is ${INGRESS_BASE_NAME}"	
		echo "`eval ${DATETIME}`: modify yaml for deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME}"
		# modify deployment file
		#1. modify container_name
		sed -i "s#`cat ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE} | grep 'name: .*'`#      - name: ${PROJECT_NAME}#g" ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_name' successful"
		else
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_name' failure."
			exit 10
		fi
		#2. modify container_image
		sed -i "s#`cat ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE} | grep 'image: .*'`#        image: ${IMAGE}#g" ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_image' successful" 
		else
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_image' failure."
			exit 10
		fi
		#3. modify pod replica
		sed -i "s#`cat ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE} | grep 'replicas: .*'`#  replicas: ${REPLICA}#g" ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify deployment file for args: 'pod replica' successful" 
		else
			echo "`eval ${DATETIME}`: modify deployment file for args: 'pod replica' failure."
			exit 10
		fi

		# path deployment
		echo "`eval ${DATETIME}`: patch deplooyment/${DEPLOYMENT_CANARY_WEIGHT_NAME}"
		kubectl patch deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -p "$(cat ${PATCH_DEPLOYMENT_CANARY_WEIGHT_FILE})" &> /dev/null
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: patch deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME} successful." 
		else
			echo "`eval ${DATETIME}`: patch deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME} failure."
			exit 10
		fi

		# check endpoint READY status
		echo "`eval ${DATETIME}`: check_endpoint ${DEPLOYMENT_CANARY_WEIGHT_NAME}...."
		check_endpoint ${NAMESPACE} ${PROJECT_NAME} ${IMAGE} ${REPLICA} ${DEPLOYMENT_CANARY_WEIGHT_NAME}
		if [ $? == 0 ] ;then
			#backup target template fiile
			if [ -e ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ];then
				\cp -a ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}-backup
			fi

			#copy source template to target template
			\cp -a ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}
			if [ $? != 0 ];then
				echo "`eval ${DATETIME}`: copy ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} to ${PATCH_INGRESS_CANARY_WEIGHT_FILE} failure." 
				exit 5
			fi

			# modify ingress file
			echo "`eval ${DATETIME}`: modify yaml for ingress/${INGRESS_CANARY_WEIGHT_NAME}"
			#1. modify ingress weight value
			sed -i "s#`cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE} | grep 'nginx.ingress.kubernetes.io/canary-weight: .*' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`#${WEIGHT_VALUE}#g" ${PATCH_INGRESS_CANARY_WEIGHT_FILE} 
			if [ $? == 0 ];then
				echo "`eval ${DATETIME}`: modify ingress file for args: 'canary-weight' successful" 
			else
				echo "`eval ${DATETIME}`: modify ingress file for args: ''canary-weight failure."
				exit 10
			fi

			# patch ingress, set canary weight is 100
			echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} weight value"
			kubectl patch ingress/${INGRESS_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -p "$(cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE})" &> /dev/null
			if [ $? == 0 ];then
				echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} successful."
				echo "----------------deploy info-------------------"
				echo "`eval ${DATETIME}`: namespace: ${NAMESPACE}"
				echo "`eval ${DATETIME}`: project_name: ${PROJECT_NAME}"
				echo "`eval ${DATETIME}`: pod_image: ${IMAGE}"
				echo "`eval ${DATETIME}`: pod_replicas: ${REPLICA}"
				echo "---------------------------------------------"
				#patch not usage deployment replica is 1
				sleep 5
				kubectl patch deployment/${DEPLOYMENT_BASE_NAME} -p '{"spec": {"replicas": 1}}' -n ${NAMESPACE}
				return 0
			else
				echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} failure."
				exit 10
			fi
							

		else
			echo "`eval ${DATETIME}`: check_endpoint ${DEPLOYMENT_CANARY_WEIGHT_NAME} failue."
			exit 10
		fi
	# set ingress weight value is 0,disable ingress for base.
	elif [ ${INGRESS_WEIGHT_RESULT} == 100 ];then 
		WEIGHT_VALUE=0
		PATCH_DEPLOYMENT_BASE_FILE=${TARGET_PATCH_DIRECTOR}/patch-deployment-${DEPLOYMENT_BASE_NAME}.yaml

		#backup target template fiile
		if [ -e ${PATCH_DEPLOYMENT_BASE_FILE} ];then
			\cp -a ${PATCH_DEPLOYMENT_BASE_FILE} ${PATCH_DEPLOYMENT_BASE_FILE}-backup
		fi

		#copy source template to target template
		\cp -a ${SOURCE_PATCH_DEPLOYMENT_FILE} ${PATCH_DEPLOYMENT_BASE_FILE}
		if [ $? != 0 ];then
			echo "`eval ${DATETIME}`: copy ${SOURCE_PATCH_DEPLOYMENT_FILE} to ${PATCH_DEPLOYMENT_BASE_FILE} failure." 
			exit 5
		fi

		echo "`eval ${DATETIME}`: current running ingress is ${INGRESS_CANARY_WEIGHT_NAME}"	
		echo "`eval ${DATETIME}`: patch deployment/${DEPLOYMENT_BASE_NAME}"
		# modify deployment file
		#1. modify container_name
		sed -i "s#`cat ${PATCH_DEPLOYMENT_BASE_FILE} | grep 'name: .*'`#      - name: ${PROJECT_NAME}#g" ${PATCH_DEPLOYMENT_BASE_FILE}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_name' successful"
		else
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_name' failure."
			exit 10
		fi
		#2. modify container_image
		sed -i "s#`cat ${PATCH_DEPLOYMENT_BASE_FILE} | grep 'image: .*'`#        image: ${IMAGE}#g" ${PATCH_DEPLOYMENT_BASE_FILE}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_image' successful" 
		else
			echo "`eval ${DATETIME}`: modify deployment file for args: 'container_image' failure."
			exit 10
		fi
		#3. modify pod replica
		sed -i "s#`cat ${PATCH_DEPLOYMENT_BASE_FILE} | grep 'replicas: .*'`#  replicas: ${REPLICA}#g" ${PATCH_DEPLOYMENT_BASE_FILE}
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify deployment file for args: 'pod replica' successful" 
		else
			echo "`eval ${DATETIME}`: modify deployment file for args: 'pod replica' failure."
			exit 10
		fi

		# path deployment
		echo "`eval ${DATETIME}`: patch deplooyment/${DEPLOYMENT_BASE_NAME}"
		kubectl patch deployment/${DEPLOYMENT_BASE_NAME} -n ${NAMESPACE} -p "$(cat ${PATCH_DEPLOYMENT_BASE_FILE})" &> /dev/null
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: patch deployment/${DEPLOYMENT_BASE_NAME} successful." 
		else
			echo "`eval ${DATETIME}`: patch deployment/${DEPLOYMENT_BASE_NAME} failure."
			exit 10
		fi

		# check endpoint READY status
		echo "`eval ${DATETIME}`: check_endpoint ${DEPLOYMENT_BASE_NAME}...."
		check_endpoint ${NAMESPACE} ${PROJECT_NAME} ${IMAGE} ${REPLICA} ${DEPLOYMENT_BASE_NAME}
		if [ $? == 0 ] ;then
			#backup target template fiile
			if [ -e ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ];then
				\cp -a ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}-backup
			fi

			#copy source template to target template
			\cp -a ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}
			if [ $? != 0 ];then
				echo "`eval ${DATETIME}`: copy ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} to ${PATCH_INGRESS_CANARY_WEIGHT_FILE} failure." 
				exit 5
			fi

			# modify ingress file
			echo "`eval ${DATETIME}`: modify yaml for ingress/${INGRESS_CANARY_WEIGHT_NAME}"
			#1. modify ingress weight value
			sed -i "s#`cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE} | grep 'nginx.ingress.kubernetes.io/canary-weight: .*' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`#${WEIGHT_VALUE}#g" ${PATCH_INGRESS_CANARY_WEIGHT_FILE}
			if [ $? == 0 ];then 
				echo "`eval ${DATETIME}`: modify ingress file for args: 'canary-weight' successful" 
			else
				echo "`eval ${DATETIME}`: modify ingress file for args: ''canary-weight failure." 
				exit 10
			fi

			# patch ingress, set canary weight value is 100
			echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} weight value."
			kubectl patch ingress/${INGRESS_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -p "$(cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE})" &> /dev/null
			if [ $? == 0 ];then
				echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} successful."
				echo "----------------deploy info-------------------"
				echo "`eval ${DATETIME}`: namespace: ${NAMESPACE}"
				echo "`eval ${DATETIME}`: project_name: ${PROJECT_NAME}"
				echo "`eval ${DATETIME}`: pod_image: ${IMAGE}"
				echo "`eval ${DATETIME}`: pod_replicas: ${REPLICA}"
				echo "---------------------------------------------"
				#patch not usage deployment replica is 1
				sleep 5
				kubectl patch deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME} -p '{"spec": {"replicas": 1}}' -n ${NAMESPACE}
				return 0
			else
				echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} failure."
				exit 10
			fi
		else
			echo "`eval ${DATETIME}`: check_endpoint ${DEPLOYMENT_BASE_NAME} failue."
			exit 10
		fi
		
	fi
}

rollback(){
	NAMESPACE=$1
	PROJECT_NAME=$2
	#deployment base name
	DEPLOYMENT_BASE_NAME=${PROJECT_NAME}-base
	#deployment canary weight name
	DEPLOYMENT_CANARY_WEIGHT_NAME=${PROJECT_NAME}-canary-weight
	#ingress base name
	INGRESS_BASE_NAME=${DEPLOYMENT_BASE_NAME}
	#ingress canary weight name
	INGRESS_CANARY_WEIGHT_NAME=${DEPLOYMENT_CANARY_WEIGHT_NAME}
	#ingress weight values
	INGRESS_WEIGHT_RESULT=`kubectl get ingress/${INGRESS_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -o yaml 2>  /dev/null | grep 'canary-weight: "' | awk -F '"' '{print $2}'`
	#patch directory
	TARGET_PATCH_DIRECTOR="${TARGET_DIRECTOR}/${NAMESPACE}/patch"
	#target ingress template file
	PATCH_INGRESS_CANARY_WEIGHT_FILE=${TARGET_PATCH_DIRECTOR}/patch-ingress-${DEPLOYMENT_CANARY_WEIGHT_NAME}.yaml
	#source patch ingress template file
	SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE="${SOURCE_DIRECTOR}/patch-ingress-template.yaml"

	#patch directory create
	if [ ! -e ${TARGET_PATCH_DIRECTOR} ];then
		mkdir -p ${TARGET_PATCH_DIRECTOR}
	fi

	#judge if have deployment is running.	
	if [[ ! `kubectl get deployment -n ${NAMESPACE} 2> /dev/null | grep ${PROJECT_NAME}-base` ]];then
		echo "`eval ${DATETIME}`: deployment/${PROJECT_NAME}-base is not running, not allow rollback. please use $0 create ...."
		exit 10
	elif [[ ! `kubectl get deployment -n ${NAMESPACE} 2> /dev/null | grep ${PROJECT_NAME}-canary-weight` ]];then
		echo "`eval ${DATETIME}`: deployment/${PROJECT_NAME}-canary-weight is not running, not allow rollback. please use $0 create ...."
		exit 10
	fi

	#judge canary weight value.
	#set ingress weight value is 100,enable ingress for weight.
	if [ ${INGRESS_WEIGHT_RESULT} == 0 ];then
		WEIGHT_VALUE=100
		#backup target template fiile
                if [ -e ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ];then
                	\cp -a ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}-backup
                fi

                #copy source template to target template
                \cp -a ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}
                if [ $? != 0 ];then
                        echo "`eval ${DATETIME}`: copy ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} to ${PATCH_INGRESS_CANARY_WEIGHT_FILE} failure." 
	        	exit 5
                fi

		# modify ingress file
		echo "`eval ${DATETIME}`: modify yaml for ingress/${INGRESS_CANARY_WEIGHT_NAME}"
		#1. modify ingress weight value
		sed -i "s#`cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE} | grep 'nginx.ingress.kubernetes.io/canary-weight: .*' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`#${WEIGHT_VALUE}#g" ${PATCH_INGRESS_CANARY_WEIGHT_FILE} 
		if [ $? == 0 ];then
			echo "`eval ${DATETIME}`: modify ingress file for args: 'canary-weight' successful" 
		else
			echo "`eval ${DATETIME}`: modify ingress file for args: ''canary-weight failure."
			exit 10
		fi

		# patch ingress, set canary weight is 100
		echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} weight value"
		kubectl patch ingress/${INGRESS_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -p "$(cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE})" &> /dev/null
		if [ $? == 0 ];then
			ROLLBACK_IMAGE_VERSION=`kubectl get deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.template.spec.containers[0].image}'`
			ROLLBACK_IMAGE_REPLICAS=`kubectl get deployment/${DEPLOYMENT_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.replicas}'`
			echo "`eval ${DATETIME}`: rollback successful."
			echo "----------------rollback info-------------------"
			echo "namespace: ${NAMESPACE}"
			echo "project_name: ${PROJECT_NAME}"
			echo "pod_image: ${ROLLBACK_IMAGE_VERSION}"
			echo "pod_replicas: ${ROLLBACK_IMAGE_REPLICAS}"
			echo "---------------------------------------------"
			return 0
		else
			echo "`eval ${DATETIME}`: rollback failure."
			exit 10
		fi
	#set ingress weight value is 0,disable ingress for weight.
	elif [ ${INGRESS_WEIGHT_RESULT} == 100 ];then 
		WEIGHT_VALUE=0
		#backup target template fiile
                if [ -e ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ];then
                	\cp -a ${PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}-backup
                fi

                #copy source template to target template
                \cp -a ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} ${PATCH_INGRESS_CANARY_WEIGHT_FILE}
                if [ $? != 0 ];then
                        echo "`eval ${DATETIME}`: copy ${SOURCE_PATCH_INGRESS_CANARY_WEIGHT_FILE} to ${PATCH_INGRESS_CANARY_WEIGHT_FILE} failure." 
	        	exit 5
                fi

		# modify ingress file
		echo "`eval ${DATETIME}`: modify yaml for ingress/${INGRESS_CANARY_WEIGHT_NAME}"
		#1. modify ingress weight value
		sed -i "s#`cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE} | grep 'nginx.ingress.kubernetes.io/canary-weight: .*' | awk -F ':' '{print $2}' | awk -F '"' '{print $2}'`#${WEIGHT_VALUE}#g" ${PATCH_INGRESS_CANARY_WEIGHT_FILE}
		if [ $? == 0 ];then 
			echo "`eval ${DATETIME}`: modify ingress file for args: 'canary-weight' successful" 
		else
			echo "`eval ${DATETIME}`: modify ingress file for args: ''canary-weight failure." 
			exit 10
		fi

		# patch ingress, set canary weight value is 100
		echo "`eval ${DATETIME}`: patch ingress/${INGRESS_CANARY_WEIGHT_NAME} weight value."
		kubectl patch ingress/${INGRESS_CANARY_WEIGHT_NAME} -n ${NAMESPACE} -p "$(cat ${PATCH_INGRESS_CANARY_WEIGHT_FILE})" &> /dev/null
		if [ $? == 0 ];then
			ROLLBACK_IMAGE_VERSION=`kubectl get deployment/${DEPLOYMENT_BASE_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.template.spec.containers[0].image}'`
			ROLLBACK_IMAGE_REPLICAS=`kubectl get deployment/${DEPLOYMENT_BASE_NAME} -n ${NAMESPACE} -o jsonpath='{.spec.replicas}'`
			echo "`eval ${DATETIME}`: rollback successful."
			echo "----------------rollback info-------------------"
			echo "namespace: ${NAMESPACE}"
			echo "project_name: ${PROJECT_NAME}"
			echo "pod_image: ${ROLLBACK_IMAGE_VERSION}"
			echo "pod_replicas: ${ROLLBACK_IMAGE_REPLICAS}"
			echo "---------------------------------------------"
			return 0
		else
			echo "`eval ${DATETIME}`: rollback failure."
			exit 10
		fi
	fi
}


case $1 in 
	check_endpoint)
		if [ "$#" -gt 6 ];then echo 'args is great than 6, args must is 6' ; exit 5 
		elif [ "$#" -lt 6 ];then echo 'args is less than 6, args must is 6' ; exit 5
		fi
		check_endpoint $2 $3 $4 $5 $6
		;;
	
	create)
		if [ "$#" -gt 7 ];then echo 'args is great than 7, args must is 7' ; exit 5 
		elif [ "$#" -lt 7 ];then echo 'args is less than 7, args must is 7' ; exit 5
		fi
		create $2 $3 $4 $5 $6 $7 
		;;

	deploy)
		if [ "$#" -gt 5 ];then echo 'args is great than 5, args must is 5' ; exit 5 
		elif [ "$#" -lt 5 ];then echo 'args is less than 5, args must is 5' ; exit 5
		fi
		deploy $2 $3 $4 $5
		;;	

	rollback)
		if [ "$#" -gt 3 ];then echo 'args is great than 3, args must is 3' ; exit 5 
		elif [ "$#" -lt 3 ];then echo 'args is less than 3, args must is 3' ; exit 5
		fi
		rollback $2 $3
		;;	


	*)
		echo "USAGE: $0 { deploy NAMESPACE PROJECT_NAME IMAGE REPLICA } | { rollback NAMESPACE PROJECT_NAME } | { check_endpoint NAMESPACE PROJECT_NAME IMAGE REPLICA DEPLOYMENT_NAME } | { create NAMESPACE PROJECT_NAME PROJECT_DOMAIN_NAME POD_IMAGES POD_PORT POD_REPLICAS }"
		;;
esac
