kubectl create ns efk
# elasticsearch
helm repo add azure-stable http://mirror.azure.cn/kubernetes/charts/ 
helm repo update
#helm pull azure-stable/elasticsearch --version 1.32.4   
#vim values.yaml
helm install elasticsearch-jack -f values.yaml --namespace=efk --version=1.32.4 azure-stable/elasticsearch

# fluentd
helm install fluentd1 -f values.yaml --namespace=efk --version=2.0.7 azure-stable/fluentd-elasticsearch

# kibana
helm install kibana1 -f values.yaml --namespace=efk --version=3.2.6 azure-stable/kibana
