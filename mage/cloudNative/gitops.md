# GitOps



## CI/CD

- CI/CD是一种在应用开发阶段引入自动化实现以较高频度向客户交付应用的方法
  - 广为接受的模型，存在三个典型阶段：持续集成、持续交付和持续部署
  - CI/CD可以让持续自动化和持续监控贯穿于应用的整个生命周期（从集成到测试、到交付，再到部署）
  - 这些关联的事务通常被统一称作CI/CD Pipeline，它一般需要由开发和运维团队以敏捷方式协同支持
- CI和CD的关系
  - CI是指持续集成，它属于开发人员的自动化流程
  - CD指持续交付和持续部署，两者都事关Pipeline后续的自动化，但有时也会单独使用以评估自动化程度



## 持续交付和持续部署

- 持续交付
  - 通常是指开发人员对应用的更改会自动进行错误测试并上传到存储库（如GitHub或Image Registry），然后由运维团队将其部署到实时生产环境中
  - 旨在解决开发和运维团队之间可见性及沟通较差的问题，目标在于确保尽可能地减少部署新代码时所需的工作量
- 持续部署
  - 通常是指自动将开发人员的更改从存储库发布到生产环境，以供客户使用；
  - 主要解决因手动流程降低应用交付速度，从而使运维团队超负荷的问题
  - 以持续交付为前提，完成Pipeline后续阶段的自动化
- CI/CD术语
  - 通常，CI/CD这一术语既可能仅指持续集成和持续交付构成的关联环节，也可以指持续集成、持续交付和持续部署这三项构成的关联环节
  - 甚至于，很可能有些人口中所谓的"持续交付"也包含了持续部署流程



## CI/CD Pipeline

- CI/CD Pipeline
  - 为了交付新版本的软件而必须执行的一系列步骤
  - 一套专注于使用DevOps或SRE方法来改进软件交付的实践
  - 加入了监控和自动化来改进应用开发过程，尤其是在集成和测试阶段，以及交付和部署过程中
    - 即便可以手动执行CI/CD Pipeline的每个步骤，但CI/CD Pipeline的真正价值就在于自动化
- CI/CD Pipeline的要素
  - 构成CI/CD Pipeline的步骤被划分为不同的任务子集（subsets of tasks），称之为Pipeline Stage
  - Pipeline中典型的Stage包括
    - Build（构建）：应用编译
    - Test（测试）：代码测试
    - Release（发布）：将应用交付到存储库
    - Deploy（部署）：将代码部署到生产环境
    - Validation和Compliance（验证与合规）：镜像安全性扫描（例如Clair）等，具体的步骤取决于实际需求
- 最初，传统的CI/CD系统是为使用虚拟机的Pipeline而设计，但云原生技术却为CI/CD Pipeline的价值实现带来了新的突破
  - 使用Tekton项目，用户可以构建Kubernetes风格的Pipeline，控制微服务的生命周期



## Weave Cloud的DevOps方法

- Weave Cloud的DevOps方法使用Pull机制，它依赖于两种特殊组件
  - Config Updater：用于监视image的变动并更新配置清单；
  - Deploy Synchronizer：维护应用的当前状态；
- 工作机制：Pull Pipeline模型的中心是配置中心或配置仓库（config repo）
  - 开发人员推送代码变更至代码仓库中；
  - CI Server 自动完成CI Pipeline并生成Docker Image；
  - Config Updater，注意到Image的变动，并以此更新config repo中的配置清单；
  - Deploy Synchronizer 在察觉到集群当前状态已过期后，将从配置仓库中pull到变更的配置清单并部署到集群上；



### Pipeline 模型的演进

- Push Pipeline
  - 传统上的大多数CI/CD工具都使用基于Push的模型，即代码从CI系统开始，可以经由一系列脚本代码自动化完成其执行路径，或手动完成相关的Stage；
- Pull Pipeline
  - WeaveNet倡导一种新的基于Image Pull的Pipeline模型，并且将凭据直接保存于集群之上



### 一个典型的GitOps Pipeline

- GitOps模型中存在两个Git仓库 
  - 代码仓库（code repo）：开发人员使用 
    - 推送代码变更 
  - 配置仓库（config repo）：运维人员使用 
    - 推送配置变更 
    - 包括基础设施配置以及应用配置 
- 简要工作流程 
  - 开发人员推送代码变量至代码仓库 
  - CI工具链完成测试和构建 
  - CD工具链完成测试和交付（新版本的Image推送至镜像仓库）
  - Config Update（即Deployment Automator）将Image的变更信息推送至配置仓库
  - 随后，根据使用的分支和发布策略，完成应用的部署



### GitOps的实施要点

- GitOps强调的重心在于，它要求对应用程序、环境、部署操作和基础架构进行的所有变更，都应以声明式描述文件存储于Git中；
  - 基础设施：例如，以Terraform模块或Cloudformation脚本形式存在的声明，此外，aws也支持使用Kops在基础设施上拉起一个集群等；
  - Kubernetes的资源配置：主要包括Deployments、Services、StatefulSets、PVC和用到的镜像等相关的配置
    - 使用Helm包管理器打包管理一个应用程序相关的配置应该是更好的选择；
  - 环境配置：这里仍然是指Kubernetes配置，它主要包括Kubernetes上的ConfigMap资源对象
    - 这些配置同样可以打包在Helm Chart之中；
  - 应用程序代码：存储于git之中，但需要通过声明式的Dockerfile打包为docker image
    - Dockerfile自身同样也样存储于程序的代码仓库中；
- 基于Pull Request完成所有需要进行变更
  - master（或main）分支用于反映系统的当前状态；
  - 在master分支上打开新的PR即可完成可能需要的任何更新；
  - PR合并后，将触发CD/GitOps管道；回滚同样由PR触发；
- 自愈
  - Git配置仓库保存有应用的预期状态，而Kubernetes上保存有应用的当前状态
  - 需要一个专用的Operator来负责实现该功能



### 开放式应用程序模型（OAM）

- 对于一个特定的应用，其声明式配置清单的管理会涉及到诸多方面
  - Dockerfile：将应用程序打包成Docker Image
  - Kubernetes资源配置文件：Deployments、Services、Volumes和ConfigMaps等；
    - 包含敏感信息的Secrets需要独立管理；
  - 环境相关管理策略，例如应用的冗余数量，在预发和生产环境可能会有所不同；
  - 与容灾相关的跨区可用性策略相关的调度机制；
  - 网络安全策略；
  - 路由策略；
  - ……
- 这些信息分别来自
  - 开发人员：定义应用程序组件
  - 应用运维：组件实例及配置的声明
  - 基础架构运维：基础设施组件的声明



#### OAM框架下的各角色职责

- OAM框架有利将各角色职责分离
- 公有云环境下，Cluster Operator的职责大部分都能够由Cloud Provider提供





# 如何实施GitOps

- 遵循GitOps的标准流程
- 基于OAM框架模型，DevOps团队协同管理声明式配置清单
- 选择合理的工具集
- 从变更频率高或易于中断的应用程序开始



## GitOps工具集

- 除了Kubernetes集群外，GitOps的实施通常还要依赖于如下工具
  - Git和Git Server：显然，这是实施GitOps的基础和中心；GitHub、GitLab或任何形式的支持自动化Pipeline必要功能的Git Server均可；
  - CI Server：CI Pipeline的基础设施，如Jenkins和Tekton等；
  - Agent Operator（Deploy Operator）：CD Pipeline的基础组件
    - GitOps中，可用的解决方案包括ArgoCD、Flux、Jenkins X、WKSctl和Gitkube等；
  - Canary Deployer
    - flux提供的名为Flagger的Kubernetes Operator支持金丝雀发布
    - 它能够结合Istio、Linkerd、App Mesh、NGINX、Skipper、Contour、Gloo或Traefik等自动实施流量路由和流量迁移，以及根据Prometheus实现Canary分析



## GitOps基础

- 什么是 GitOps？
  - 一套使用Git来管理基础架构和应用配置的实践，一项事关部署流程的技术
  - 在运行过程中以Git为声明性基础架构和应用的单一事实来源
  - 使用Git拉取请求来自动管理基础架构的置备和部署
  - Git存储库包含系统的全部状态，因此系统状态的修改痕迹既可查看也可审计
  - 与DevOps相比，GitOps更侧重于基于工具和框架的实践
  - 简单来说：GitOps = IaC + MRs + CI/CD
    - MRs：Merge Requests
- 如何开始使用GitOps?
  - 存在支持声明式管理的基础架构
    - 天然适配Kubernetes和云原生开发的运维模式
    - 原生支持基于Kubernetes的持续部署
  - 用于构建开发流程、对应用进行编码、管理配置、置备Kubernetes 集群以及在 Kubernetes 或容器注册中心进行部署



### GitOps示例一：FluxCD

- Manage Helm releases with Flu
- Flagger
  - 支持Canary releases、A/B testing、Blue/Green mirroring等部署策略，它依赖于Service Mesh或Ingress Controller实现流量策略
  - 支持基于Prometheus、Datadog等进行发布分析，以及基于Slack等进行告警

### GitOps示例二：ArgoCD

- ArgoCD：专用于Kubernetes的声明式GitOps CD工具；

### GitOps示例三：Tekton and ArgoCD

- Modern CI/CD workflows for serverless 
- applications with Red Hat OpenShift 
- Pipelines and Argo CD
  - Tekton：CI Pipeline
  - ArgoCD: CD Pipeline

### 基于Tekton和ArgoCD的GitOps示意图

- Tekton负责构建CI Pipeline
- ArgoCD负责构建CD Pipeline





# Tekton基础

Tekton系统组件
- Tekton Pipelines
  - Tekton最核心的组件，由一组CRD和相关的Operator、Webhook共同组成
  - 需要部署并运行于Kubernetes集群之上，作为Kubernetes的集群扩展
- Tekton Triggers
  - 触发器，可触发Pipeline的实例化；可选组件；
- Tekton CLI
  - 命令行客户端工具，用于与Tekton进行交互；可选组件；
- Tekton Dashboard
  - Tekton Pipelines的基于Web的图形界面；可选组件；
- Tekton Catalog
  - 由社区贡献的Tekton构建块（building blocks，例如Tasks和Pipelines等），用户可直接使用
- Tekton Hub
  - 用于访问Catalog的图形界面，基于Web
- Tekton Operator

概念模型
- Tekton Pipelines的Pipeline模型中存在三个核心术语：Step、Task和Pipeline
- Step
  - CI/CD工作流中的一个具体操作，例如Python web app的单元测试，或者是Java程序的编译操作
  - 每个step都会通过一个特定Container（Pod中）运行
- Task
  - 由一组Step组成的序列，按照定义的顺序依次运行于同一个Pod内的不同容器中
  - 可共享一组环境变量，以及存储卷
- Pipeline
  - 由一组Task组成的集合，可按照定义以不同的方式运行：串行、并行和DAG
  - 一个Task的输出可由其后Task引用
- Input和Output resources
  - 每个task或pipeline均可有其Input和Output，它们相应地可被称为Input Resources和Output Resources，例如
    - 某个Task以git repository为input，而output为container image
    - 该Task会从git repository中克隆代码、运行测试、执行构建并打包成容器镜像
  - Tekton支持如下几种类型的resources
    - git：一个特定的git repository
    - Pull Request：某git repository上的一次特定的PR
    - Image：容器镜像
    - Cluster：Kubernetes集群
    - Storage：Blob存储上的object或directory
    - CloudEvent
  - 注意：Input和Output Resources已经被废弃，建议使用Parameters进行替代
- TaskRun and PipelineRun
  - TaskRun代表Task的一次具体执行过程，类似地，PipelineRun代表Pipeline的一次具体执行过程
  - 具体运行时，Task和Pipeline连接至配置的Resource之上，进而创建出TaskRun和PipelineRun
  - 它们既可由用户手动创建，也可由Trigger自动触发
  - 注意：实际上，PipelineRun自身并不执行任何具体任务，它是由按特定顺序运行的TaskRun组合而成

Parameters
- Parameters是使得Task及Pipeline资源定义出的“模板”更加具有通用性的关键要素之一
- 具体到使用逻辑，例如
  - 大多数CI Pipeline的起始位置都是从Git仓库中克隆代码，这通常会在定义一个Task，通过某个具体的Step进行
  - 显然，如若将git仓库的url硬编码在Task及其Step中，将使得该Task失去了绝大部分的通用性
  - 于是，我们可以在Task中，将操作的目标（包括数据）定义为参数（Parameter），而在Step的代码中引用这些参数作为操作对象
  - TaskRun在针对该Task进行实例化时，通过向引用的Task中定义参数传值完成实例化
- 实际应用中，我们一般是通过Pipeline基于Task来创建TaskRun对象的，而非直接创建TaskRun
  - Pipeline可引用已有的Task，或者直接内嵌专有的Task代码，其目标在于创建TaskRun
  - 为了完成实例化，Pipeline需要向Task的Parameter进行赋值，但其值，也可以是对Pipeline级别的某个Parameter的引用
  - 而对Pipeline上的Parameter的赋值，则由PipelineRun进行

TaskRun和Step的运行
- 每个TaskRun运行于一个独立的Pod中，而其内部的各Step则分别运行于一个Container中
  - Tekton Pipelines会在每个Step相关的容器中注入一个entrypoint程序，该程序会在系统就绪后启动并运行用户指定要运行的命令。
  - Tekton Pipelines使用Kubernetes Annotations跟踪Pipeline的状态，而这些Annotations通过DownwardAPI以文件的形式投射进每个Step容器中。由Tekton Pipelines注入到容器中的entrypoint程序负责密切监视这些投射进当前容器中的文件，并在某个特定Annotation作为文件出现时才启动用户指定的命令。例如，对于一个包含多个Step的某Task来说，后一个Step容器会在其annotation报告前一个容器成功执行完成后才会开始运行entrypoint。

Pipeline和Task上的数据共享
- Pipeline上可能会存在数据共享的需要，例如
  - 一个Task的多个Step之间，靠前的Step生成的结果，需要由后面某个Step引用
  - 一个Pipeline的多个Task之间，前面的Task处理的结果，需要由后面的某个Task引用
- 常见的解决方案有两种
  - Results
    - 由Task声明
    - 它将Task中Step生成的结果保存于临时文件中（/tekton/results/<NAME>），而后由同一Task中后面的Step引用，或者由后面其它Task中的Step引用
      - 文件名也能够以变量形式引用，例如“$(results.<NAME>.path)”
    - 由Tekton的Results API负责实现，仅可用于共享小于4096字节规模的小数据片
  - Workspace
    - 由Task声明的，且需要由TaskRun在运行时提供的文件系统
    - 通常对应于Kubernetes上的ConfigMap、Secret、emptyDir、静态PVC类型的卷，或者是VolumeClaimTemplate动态请求的PVC
    - emptyDir的生命周期与Pod相同，因此仅能在一个TaskRun的各Step间共享数据
    - 若要跨Task共享数据，则需要使用PVC



## Tekton Pipelines快速入门



### 部署Tekton

- 环境要求
  - Tekton Pipelines 0.11.0及以上的版本，需要运行于Kubernetes v1.15以上的集群中；
  - 集群上要启用了RBAC鉴权插件；
  - 拥有管理员权限（绑定到了clusterrole/cluster-admin）的用户；
- 部署Tekton Pipelines
  - 根据Tekton Pipelines项目提供的配置文件完成部署
    - kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
  - Tekton Pipelines会部署两个controller和webhook两个应用
    - kubectl get deployments -n tekton-pipelines 
  - 客户端工具tkn
    - 下载页面：https://github.com/tektoncd/cli/releases
    - curl -LO https://github.com/tektoncd/cli/releases/download/v0.22.0/tektoncd-cli-0.22.0_Linux-64bit.deb
    - sudo dpkg -i ./tektoncd-cli-0.22.0_Linux-64bit.deb
- 官方文档：https://tekton.dev/docs/getting-started/tasks/



### 实验环境

```bash
### # 1. Install Tekton Pipelines
root@k8s-master01:~# kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
root@k8s-master01:~# kubectl get ns
NAME               STATUS   AGE
default            Active   8d
kafka              Active   2d6h
kube-node-lease    Active   8d
kube-public        Active   8d
kube-system        Active   8d
tekton-pipelines   Active   13s
root@k8s-master01:~# kubectl get pods -n tekton-pipelines
NAME                                           READY   STATUS              RESTARTS   AGE
tekton-pipelines-controller-795d77dbd6-6ggxn   0/1     ContainerCreating   0          18s
tekton-pipelines-webhook-579c8dc94c-k7lkm      0/1     ContainerCreating   0          18s
root@k8s-master01:~# kubectl api-resources --api-group=tekton.dev
NAME                SHORTNAMES   APIVERSION            NAMESPACED   KIND
clustertasks                     tekton.dev/v1beta1    false        ClusterTask
conditions                       tekton.dev/v1alpha1   true         Condition
pipelineresources                tekton.dev/v1alpha1   true         PipelineResource
pipelineruns        pr,prs       tekton.dev/v1beta1    true         PipelineRun
pipelines                        tekton.dev/v1beta1    true         Pipeline
runs                             tekton.dev/v1alpha1   true         Run
taskruns            tr,trs       tekton.dev/v1beta1    true         TaskRun
tasks                            tekton.dev/v1beta1    true         Task

#配置代理上网，gcr镜像无法下载
root@ansible:~/ansible# cat docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://172.168.2.29:8118"
Environment="HTTPS_PROXY=http://172.168.2.29:8118"
Environment="NO_PROXY=localhost,127.0.0.1,192.168.10.0/24,192.168.13.0/24,172.168.2.0/24,.hs.com,.docker.io,.example.com"

root@ansible:~/ansible# ansible '~172.168.2.2[145]' -m copy -a 'src=./docker.service.d dest=/etc/systemd/system/'
root@ansible:~/ansible# ansible '~172.168.2.2[145]' -m shell -a 'systemctl daemon-reload && systemctl restart docker'
root@ansible:~/ansible# ansible '~172.168.2.2[145]' -m shell -a 'docker info '

#查看tekton POD
root@k8s-master01:~# kubectl get pods -n tekton-pipelines
NAME                                           READY   STATUS    RESTARTS   AGE
tekton-pipelines-controller-795d77dbd6-6ggxn   1/1     Running   0          5m59s
tekton-pipelines-webhook-579c8dc94c-k7lkm      1/1     Running   0          5m59s


#2. Install Dashboard
root@front-envoy:~# curl -sSLO  https://github.com/tektoncd/dashboard/releases/latest/download/tekton-dashboard-release.yaml
root@front-envoy:~# scp tekton-dashboard-release.yaml root@172.168.2.21:~
root@k8s-master01:~# kubectl apply -f tekton-dashboard-release.yaml
root@k8s-master01:~# kubectl get pods -n tekton-pipelines
NAME                                           READY   STATUS    RESTARTS   AGE
tekton-dashboard-b7b8599c6-lf56p               1/1     Running   0          109s
tekton-pipelines-controller-795d77dbd6-6ggxn   1/1     Running   0          10m
tekton-pipelines-webhook-579c8dc94c-k7lkm      1/1     Running   0          10m
--配置tekton dashboard SVC
root@k8s-master01:~# kubectl get svc -n tekton-pipelines
NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                              AGE
tekton-dashboard              ClusterIP   10.68.240.209   <none>        9097/TCP                             23s
tekton-pipelines-controller   ClusterIP   10.68.58.248    <none>        9090/TCP,8008/TCP,8080/TCP           8m56s
tekton-pipelines-webhook      ClusterIP   10.68.74.54     <none>        9090/TCP,8008/TCP,443/TCP,8080/TCP   8m55s
root@k8s-master01:~# kubectl edit svc tekton-dashboard -n tekton-pipelines
spec:
  externalIPs:

  - 172.168.2.27
    root@k8s-master01:~# kubectl get svc tekton-dashboard -n tekton-pipelines
    NAME               TYPE        CLUSTER-IP      EXTERNAL-IP    PORT(S)    AGE
    tekton-dashboard   ClusterIP   10.68.240.209   172.168.2.27   9097/TCP   93s

--WEB访问tekton dashboard: 172.168.2.27:9097
PS C:\Windows\System32\drivers\etc> notepad hosts
172.168.2.27 tekton.magedu.com
--http://tekton.magedu.com:9097/#/about

#3. Install tekton CLI，一定要下载最新版本，这样才能支持新特性
root@front-envoy:~# curl -sSLO https://github.com/tektoncd/cli/releases/download/v0.23.1/tektoncd-cli-0.23.1_Linux-64bit.deb
root@front-envoy:~# scp tektoncd-cli-0.23.1_Linux-64bit.deb root@172.168.2.21:~
root@k8s-master01:~# apt install ./tektoncd-cli-0.23.1_Linux-64bit.deb
root@k8s-master01:~# tkn version
Client version: 0.23.1
Pipeline version: v0.35.1
Dashboard version: v0.26.0
```



### 示例demo
```bash
root@front-envoy:~# git clone https://github.com/iKubernetes/tekton-and-argocd-in-practise.git
root@front-envoy:~# scp -r tekton-and-argocd-in-practise/ root@172.168.2.21:~

#Task 和 TaskRun 初步运行

- TaskRun
  - Tekton Pipelines提供的CRD之一，用于实例化及运行一个Task
  - 负责于一个Pod中使用不同的容器依次运行Task中定义的各个Step
  - 任何一个Step的运行发行错误，TaskRun即会终止
  - TaskRun的运行超时时长可通过spec.timeout字段指定
  - TaskRun引用Task的方式有两种
    - taskRef：通过Task的名称引用
    - taskSpec：直接定义要运行自有的Task
      #示例
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 01-task-hello.yaml
      apiVersion: tekton.dev/v1beta1
      kind: Task
      metadata:
      name: hello
      spec:
      steps:					#创建一个task,里面有一个step，step名称为say-hello
    - name: say-hello
      image: alpine:3.15
      command: ['/bin/sh']
      args: ['-c', 'echo Hello World']
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 01-task-hello.yaml
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl get task
      NAME    AGE
      hello   14s
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task list
      NAME    DESCRIPTION   AGE
      hello                 42 seconds ago

root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 01-taskrun-hello.yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: hello-run-00001
spec:
  taskRef:			#还可以是taskSpec，内联task。这里是引用外部task
    kind: Task		#引用之前创建的task
    name: hello		#task名称
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 01-taskrun-hello.yaml
taskrun.tekton.dev/hello-run-00001 created
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl get pods
NAME                  READY   STATUS     RESTARTS   AGE
hello-run-00001-pod   0/1     Init:0/2   0          3s
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn taskrun list
NAME              STARTED        DURATION   STATUS
hello-run-00001   1 minute ago   ---        Running(Pending)
--等镜像下载完成后，会变成Running, Completed
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl get pods
NAME                  READY   STATUS      RESTARTS   AGE
hello-run-00001-pod   0/1     Completed   0          3m41s
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn taskrun list
NAME              STARTED         DURATION    STATUS
hello-run-00001   3 minutes ago   3 minutes   Succeeded

#在Task上使用parameters

- Task支持接受和传递参数，相关参数以对象定义在spec.params字段中，可嵌套的常用字段有
  - name：参数名称
  - type：参数类型，有string和array两种取值
  - description：参数的简要描述；
  - default：参数的默认值
    #示例
    root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 02-task-with-params.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Task
    metadata:
    name: hello-params
    spec:
    params:
    - name: target		#变量名称
      type: string		#变量值类型，只能为string，array两种类型
      description: Name of somebody or something to greet		#变量描述信息
      default: MageEdu.Com		#变量默认值
      steps:
    - name: say-hello
      image: alpine:3.15
      command:
        - /bin/sh
          args: ['-c', 'echo Hello $(params.target)']		#$()是step中的调用变量，不是linux中的命令引用
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 02-task-with-params.yaml
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task list
          NAME           DESCRIPTION   AGE
          hello                        6 minutes ago
          hello-params                 36 seconds ago

--查看task详细信息
root@k8s-master01:~# tkn task list
NAME           DESCRIPTION   AGE
hello                        10 minutes ago
hello-params                 4 minutes ago
root@k8s-master01:~# tkn task describe hello-params
Name:        hello-params
Namespace:   default

⚓ Params

 NAME       TYPE     DESCRIPTION              DEFAULT VALUE
 ∙ target   string   Name of somebody or...   MageEdu.Com

🦶 Steps

 ∙ say-hello


--测试
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task start hello-params --showlog
? Value for param `target` of type `string`? (Default is `MageEdu.Com`) MageEdu.Com	#没有传值，显示默认值
TaskRun started: hello-params-run-dcvd8
Waiting for logs to be available...
[say-hello] Hello MageEdu.Com		#最终结果
--传入自定义值进行测试
root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task start hello-params --showlog -p target=World!
TaskRun started: hello-params-run-rnbzb
Waiting for logs to be available...
[say-hello] Hello World!

#在Task中使用多个Step

- 在Task中定义的多个Step，它们按次序分别在同Pod下的不同容器中运行
  - 每个Step定义一个要运行的容器，其格式遵循Kubernetes的ContainerSpec
    #示例
    root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 03-task-multi-steps.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Task
    metadata:
    name: multiple
    spec:
    steps:
    - name: first			#第一个step
      image: alpine:3.15
      command:
        - /bin/sh
          args: ['-c', 'echo First Step']
    - name: second			#第二个step
      image: alpine:3.15
      command:
        - /bin/sh
          args: ['-c', 'echo Second Step']
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 03-task-multi-steps.yaml	#新建task
          task.tekton.dev/multiple created
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task start multiple --showlog	#运行taskrun，也可以用清单
          TaskRun started: multiple-run-nnpk9
          Waiting for logs to be available...
          [first] First Step

[second] Second Step
##root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl get taskrun multiple-run-nnpk9 -o yaml #可以导出taskrun清单


#在step中运行脚本

- 需要在Step中执行复杂操作时，可以使用“script”直接指定要运行的脚本
  - 多行脚本，可以使用“|”启用
  - script同command互斥
    #示例：
    root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 04-task-step-with-script.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Task
    metadata:
    name: script
    spec:
    steps:
    - name: step-with-script
      image: alpine:3.15
      script: |
        #!/bin/sh
        echo "Step with Script..."
        echo "Installing necessary tooling"
        apk add curl
        curl -s www.magedu.com && echo "Success" || echo "Fail"
        echo "All done!"
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 04-task-step-with-script.yaml
      task.tekton.dev/script created
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task start script --showlog
      TaskRun started: script-run-nnp2d
      Waiting for logs to be available...
      [step-with-script] Step with Script...
      [step-with-script] Installing necessary tooling
      [step-with-script] fetch https://dl-cdn.alpinelinux.org/alpine/v3.15/main/x86_64/APKINDEX.tar.gz
      [step-with-script] fetch https://dl-cdn.alpinelinux.org/alpine/v3.15/community/x86_64/APKINDEX.tar.gz
      .....
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn taskrun list
      NAME                       STARTED          DURATION     STATUS
      script-run-nnp2d-r-zgxvq   10 minutes ago   ---          Running
      script-run-nnp2d           36 minutes ago   ---          Running
      multiple-run-nnpk9         44 minutes ago   7 seconds    Succeeded
      hello-params-run-rnbzb     1 hour ago       47 seconds   Succeeded
      hello-params-run-dcvd8     2 hours ago      6 seconds    Succeeded
      hello-run-00001            2 hours ago      3 minutes    Succeeded
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn taskrun cancel script-run-nnp2d
      TaskRun cancelled: script-run-nnp2d
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn taskrun cancel script-run-nnp2d-r-zgxvq
      TaskRun cancelled: script-run-nnp2d-r-zgxvq
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn taskrun list
      NAME                       STARTED          DURATION     STATUS
      script-run-nnp2d-r-zgxvq   10 minutes ago   10 minutes   Cancelled(TaskRunCancelled)
      script-run-nnp2d           36 minutes ago   36 minutes   Cancelled(TaskRunCancelled)
      multiple-run-nnpk9         44 minutes ago   7 seconds    Succeeded
      hello-params-run-rnbzb     1 hour ago       47 seconds   Succeeded
      hello-params-run-dcvd8     2 hours ago      6 seconds    Succeeded
      hello-run-00001            2 hours ago      3 minutes    Succeeded


#Task上的script和parameters

- 定义在Task上的Parameters，既可被Steps中的command或args引用，亦可被Steps中的script引用
  #示例
  root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 05-task-script-and-parameters.yaml
  apiVersion: tekton.dev/v1beta1
  kind: Task
  metadata:
  name: logger
  spec:
  params:
    - name: text
      type: string
      description: something to log
      default: "-"
      steps:
    - name: log
      image: alpine:3.15
      script: |
        apk add -q tzdata
        cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        DATETIME=$(date "+%F %T")
        echo [$DATETIME] - $(params.text)
        root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 05-task-script-and-parameters.yaml
        root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task start logger --showlog -p text="Hello"


#Pipeline和PipelineRun

- Pipeline CRD资源规范
  - 在Pipeline资源规范中，仅tasks为必选字段，它以对象列表指定要引用的各Task；
  - tasks字段中的每个列表项使用taskRef字段以名称引用目标Task，且被引用的Task要事先存在；
- PipelineRun
  - Tekton Pipelines提供的CRD之一，用于实例化和运行Pipeline
  - 负责以用户指定的顺序运行其引用的Pipeline中的所有Task
    - PipelineRun会为其引用Pipeline中定义的每个Task自动创建TaskRun；
  - 资源规范中的必选字段为pipelineRef或pipelineSpec
    - pipelineRef：以指定要引用的Pipeline对象的名称
    - pipelineSpec：直接定义要运行的Pipeline的资源配置
  - 几个常用的可选字段
    - params：定义期望使用的执行参数
    - timeout：错误退出前的超时时长
    - serviceAccountName：为运行各TaskRun的Pod指定要使用ServiceAccount
    - serviceAccountNames：分别为每个TaskRun的Pod单独指定要使用的ServiceAccount，map型数据
      #示例
      root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 06-pipeline-demo.yaml
      apiVersion: tekton.dev/v1beta1
      kind: Pipeline
      metadata:
      name: pipeline-demo
      spec:
      tasks:
    - name: first-task
      taskRef:
        name: hello
    - name: second-task
      taskRef:
        name: multiple
      runAfter:				#定义的顺序，如果不定义此顺序将是并行运行。这里定义则是串行运行
        - first-task	
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 06-pipeline-demo.yaml
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn task list
          NAME           DESCRIPTION   AGE
          hello                        2 hours ago
          hello-params                 2 hours ago
          logger                       3 minutes ago
          multiple                     53 minutes ago
          script                       45 minutes ago
          root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn pipeline start pipeline-demo --showlog	#执行pipelinerun
          PipelineRun started: pipeline-demo-run-svrmq
          Waiting for logs to be available...
          [first-task : say-hello] Hello World

[second-task : first] First Step		#在first-task之后运行

[second-task : second] Second Step


#在Pipeline和PipelineRun上使用参数

- Pipeline上可定义执行参数
  - 其下的各Task均可引用
  - Task上若定义了同名的参数，其默认值的优先级更高
- PipelineRun上可向执行参数赋值
  - 其下的各TaskRun均可引用
  - Task上若定义了同名的参数，其默认值的优先级更高
    #示例
    root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 08-pipeline-with-params.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Pipeline
    metadata:
    name: pipeline-with-params
    spec:
    params:
    - name: text
      type: string
      tasks:
    - name: task-one
      taskRef:
        name: hello-params
    - name: task-two	#此两个task是并行运行的
      taskRef:
        name: logger
      params:
        - name: text
          value: $(params.text)
            root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 08-pipeline-with-params.yaml
            pipeline.tekton.dev/pipeline-with-params created
            root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# tkn pipeline start pipeline-with-params --showlog -p text="Jack"


#定义Pipeline上各Task的次序

- 在Pipeline上，各Task的次序可在引用的Task上通过runAfter字段进行定义
  #示例
  root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# cat 10-pipeline-with-ordered-task.yaml
  apiVersion: tekton.dev/v1beta1
  kind: Pipeline
  metadata:
  name: pipeline-task-ordering
  spec:
  tasks:
    - name: task-a
      taskRef:
        name: logger
      params:
      - name: text
        value: "task-A executed"
    - name: task-b
      taskRef:
        name: logger
      params:
      - name: text
        value: "Executed after task-A"
        runAfter: ["task-a"]
    - name: task-c
      taskRef:
        name: logger
      params:
      - name: text
        value: "Executed after task-A"
        runAfter: ["task-a"]
    - name: task-d
      taskRef:
        name: logger
      params:
      - name: text
        value: "Executed after task-B and task-C"
        runAfter: ["task-b", "task-c"]
        root@k8s-master01:~/tekton-and-argocd-in-practise/02-tekton-basics# kubectl apply -f 10-pipeline-with-ordered-task.yaml
```



### Tekton Pipelines使用进阶

#Workspace

- Workspace是什么？
  - Workspace用于为Task中的各Step提供工作目录，基于该Task运行的TaskRun需要在运行时提供该目录
  - TaskRun的实际运行形式为Pod，因而Workspace对应的实际组件为Pod上的Volume
    - ConfigMap和Secret：只读式的Workspace
    - PersistentVolumeClaim：支持跨Task共享数据的Workspace
      - 静态预配
      - 动态预配：基于VolumeClaimTemplate动态创建
    - emptyDir：临时工作目录，用后即弃
- Workspace的功用
  - 跨Task共享数据
    - 定义在Pipeline上的Workspace
  - 借助于Secrets加载机密凭据
  - 借助于ConfigMap加载配置数据
  - 持久化存储数据
  - 为Task提供缓存以加速构建过程
    - 定义在Task上的Workspace
    - 也可用于与Sidecar共享数据
- 另外，Task上也可以直接使用volumes定义要使用的存储卷，但其管理和使用方式与Workspace不同；

#在Task上使用Workspace
- 在Task配置Workspace
  - 定义在spec.wordspaces字段中
  - 支持嵌套如下字段
    - name：必选字段，该Workspace的唯一标识符
    - description：描述信息，通常标明其使用目的
    - readOnly：是否为只读，默认为false
    - optional：是否为可选，默认为false
    - mountPath：在各Step中的挂载路径，默认为“/workspace/<name>”，其中<name>是当前Workspace的名称
- 在Task中可用的workspace变量
  - $(workspaces.<name>.path)：由<name>指定的Workspace挂载的路径，对于可选且TaskRun未声明时，其值为空；
  - $(workspaces.<name>.bound)：其值为true或false，用于标识指定的Workspace是已经绑定；
    - 对于optional为false的Workspace，该变量的值将始终为true；
  - $(workspaces.<name>.claim)：由<name>标示的Workspace所使用的PVC的名称
    - 对于非PVC类型的存储卷，该变量值为空
  - $(workspaces.<name>.volume)：由<name>标示的Workspace所使用的存储卷的名称

#Workspace使用示例
- TaskRun中适配于Task Workspace的存储卷的定义称为“存储卷源（volume source）”，它支持如下五种类型
  - persistentVolumeClaim
  - volumeClaimTempate
  - emptyDir
  - configMap
  - secret
- 各类型的配置参数遵循对应类型的Kubernetes资源规范



```bash
#简单示例：emptyDir存储卷
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat 01-task-workspace-demo.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: workspace-demo
spec:
  params:

  - name: target
    type: string
    default: MageEdu
    steps:
    - name: write-message
      image: alpine:3.15
      script: |
        #!/bin/sh
        set -xe
        if [ "$(workspaces.messages.bound)" == "true" ] ; then
          echo "Hello $(params.target)" > $(workspaces.messages.path)/message
          cat $(workspaces.messages.path)/message
        fi
        echo "Mount Path: $(workspaces.messages.path)"
        echo "Volume Name: $(workspaces.messages.volume)"
      workspaces:
    - name: messages
      description: |
        The folder where we write the message to. If no workspace
        is provided then the message will not be written.
      optional: true
      mountPath: /data

# -w或--workspace选项用于为TaskRun指定使用的Workspace,其中的参数，name为相应的workspace的名称，而emptyDir则是指定存储卷

root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl apply -f 01-task-workspace-demo.yaml
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# tkn task start workspace-demo --showlog -p target="magedu.com" -w name=messages,emptyDir=""
TaskRun started: workspace-demo-run-bx8hh
Waiting for logs to be available...
[write-message] + '[' true '==' true ]
[write-message] + echo 'Hello magedu.com'
[write-message] + cat /data/message
[write-message] Hello magedu.com
[write-message] Mount Path: /data
[write-message] Volume Name: ws-qtntt
[write-message] + echo 'Mount Path: /data'
[write-message] + echo 'Volume Name: ws-qtntt'


#Workspace使用示例

- Task下的所有Step运行于同一Pod中，这些Step可共享该Task的Workspace；
- 另外，该Workspace直接关联的emptyDir存储卷的生命周期也就与该Pod相同，这意味着，TaskRun结束后，它即被删除，相关的数据也将被删除；

#Pipeline上的Workspace和Parameters

- 以“PipelineRun → Pipeline → （TaskRun）Task”的方式运行Pipeline及其Task的场景中，在Pipeline资源的配置上
  - 在spec.parameters上定义Parameter，而后在引用或内联定义的Task上通过引用进行赋值
  - 在spec.workspaces上定义Workspace，而后在引用或内联定义的Task上通过引用进行关联
- PipelineRun是实例化执行Pipeline的入口
  - 对应的Pipeline上定义的各Parameter都要进行明确赋值，或使用其默认值；
  - 对应的Pipeline上定义的各Workspace都要指定对应的具体存储卷，也可通过emptyDir或volumeClaimTemplate动态置备；
    - emptyDir存储卷的生命周期同Task对应的Pod，因而无法跨Task（TaskRun）使用；
    - volumeClaimTemplate是指卷请求模板资源，它需要用户指定动态置备PV和PVC时需要使用的storageClassName、卷大小、访问模式等属性

#Workspace的生命周期

- Workspace的同其关联的存储卷有相同的生命周期
  - emptyDir类型的存储卷在Pipeline中不能跨Task使用
  - 静态PVC或通过volumeClaimTempate申请的PVC的生命周期可以跨越TaskRun与PipelineRun
- 下方示例
  - 以内联方式在Pipeline定义了两个Task
    - 两个task共享使用同一个Workspace
    - fetch-from-source从指定仓库克隆文件并存储于Workspace的source目录，而source-lister则试图显示Workspace上source目录的内容
  - Pipeline能否成功运行，取决于对应存储卷的生命周期
    root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat 04-pipeline-worlspace-02.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Pipeline
    metadata:
    name: volume-share
    spec:
    params:
    - name: git-url
      type: string
      workspaces:
    - name: codebase
      tasks:
    - name: fetch-from-source
      params:
        - name: url
          value: $(params.git-url)
          taskSpec:
          workspaces:
          - name: source
            params:
          - name: url
            steps:
          - name: git-clone
            image: alpine/git:v2.32.0
            script: git clone -v $(params.url) $(workspaces.source.path)/source
            workspaces:
        - name: source
          workspace: codebase
    - name: source-lister
      runAfter:
        - fetch-from-source
          taskSpec:
          steps:
          - name: list-files
            image: alpine:3.15
            script: ls $(workspaces.source.path)/source
            workspaces:
          - name: source
            workspaces:
        - name: source
          workspace: codebase



#运行task,从github上clone项目
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat task-source-to-package.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: source-to-package
spec:
  params:

  - name: git-repo-url
    type: string
    workspaces:
    - name: source
      description: code storage
      steps:
    - name: fetch-from-source
      image: alpine/git:v2.32.0
      script: |
        git clone $(params.git-repo-url) $(workspaces.source.path)/source
    - name: build-to-package
      image: maven:3.8-openjdk-11-slim
      workingDir: $(workspaces.source.path)/source
      script: |
        mvn clean install
      root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl apply -f task-source-to-package.yaml
      root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# tkn task start source-to-package --showlog -p git-repo-url='https://gitee.com/mageedu/spring-boot-helloWorld.git' -w name=source,emptyDir=''

---外部引用task方法
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat 02-task-with-workspace.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: source-lister
spec:
  params:

  - name: git-repo
    type: string
    description: Git repository to be cloned
    workspaces:
  - name: source
    steps:
  - name: git-clone
    image: alpine/git:v2.32.0
    script: git clone -v $(params.git-repo) $(workspaces.source.path)/source
  - name: list-files
    image: alpine:3.15
    command:
    - /bin/sh
      args:
    - '-c'
    - 'ls $(workspaces.source.path)/source'
      root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat 03-pipeline-workspace.yaml
      apiVersion: tekton.dev/v1beta1
      kind: Pipeline
      metadata:
      name: pipeline-source-lister
      spec:
      workspaces:
  - name: codebase
    params:
  - name: git-url
    type: string
    description: Git repository url to be cloned
    tasks:
  - name: git-clone
    taskRef:
      name: source-lister
    workspaces:
    - name: source
      workspace: codebase
      params:
    - name: git-repo
      value: $(params.git-url)
```





### 回顾
CI/CD:

- Stage:
  - build, test, release, deploy
  - validation, compliance

- DevOps
  - Push Pipeline
    - Jenkins(传统)
	- JenkinsX(面向云原生)
	- Tekton(纯粹云原生)
  - Pull Pipeline
    - CD: deploy
	
- GitOps
  - CI: PUSH 
    - config git repo
  - CD: PULL	
    - Operator
	  - config repo <--> cluster

- GitOps工具：
  - CI/CD push pipeline: Tekton
  - CD(continue deployment): ArgoCD
  
- GitOps渐进式交付组件
  - ArgoCD/ArgoCD Rollouts
  - FluxCD/Flagger

Tekton:
- 组件
  - tekton Pipelines
  - tekton trigger
  - tekton CLI
  - tekton dashboard
  - catalog, hub
- 概念
  - Task,step
    - 模板化的代码
	- parameters, workspace
	- TaskRun
	- Pipeline - > pipelineRun

#### 分支策略

- 单分支策略简介(GitHub模式)
  - 通常也称为Feature Branch Workflow,其中Master Branch承载项目变更历史
  - 研发人员创建短生命周期的Feature分支，完成Feature目标相关的研发任务
  - Feature开发完成后，通过PR流程，请求将代码合并到Master Branch
  - PR(Pull Request)得到Review人员确认后，将会合并到主分支，CI Pipeline即被触发，直至最后将Image推送至Registry
- 多分支策略
  - 多分支策略较适用于需要团队或（和）外部协作的大型项目的管理场景，且存在多个不同的变种，较为主流是Gitflow模型
  - Gitflow模型使用Develop Branch保存项目变更历史，而使用Master Branch承载生产发布历史
  - Feature开发依然使用短生命周期的Feature Branch进行，并在开发目标达成后将代码合并到Develop Branch
    - Develop Branch需要一个专用的CI Pipeline
  - 计划发布时，将从最新的Develop Branch创建一个短生命周期的Release Branch，基于该分支进行持续测试和Bug修复，直到满足生产标准
    - Relese Branch也需要一个专用的CI Pipeline
	- 发布完成后，Release Branch上的所有变更都要合并至Develop Branch和Master Branch
  - Gitflow策略中，仅Release Branch CI过程中生成的镜像才允许部署到生产环境，Develop Branch CI生成的镜像只能用于发布前测试及集成测试；显然，需要回滚时，也只能使用Release Branch此前的CI Pipeline生成的镜像
  - 用于修复Bug的Hotfix Branch要基于Master Branch创建，同时也需要一个独立CI Pipeline完成必要的CI过程

#### 应用的发布环境

- 发布环境，是指应用代码部署及运行的系统及其功能和特性
- 在应用开发周期中，通常会使用几种不同的环境来满足不同的目标
  - 程序员通常在本地开发环境中创建、测试和调试代码
  - 短期开发目标达成后，便可提交代码至相应的Git仓库，随后就需要将代码部署到特定环境中进行集成测试，直到满足向生产发布的条件
  - 这其中涉及到的环境，有如下几种典型实现
    - QA
	- E2E
	- Stage
	- Prod
- 纯测试环境：不承载客户端流量且没有客户端数据
  - QA：针对硬件、数据和其它依赖项进行测试，旨在确保服务的正确性
  - E2E: END-to-End测试，通过模拟真实用户场景来验证目标系统及其组件的完整性，主要目的是用户体验测试
- Stage环境
  - 几乎与生产环境一致，但客户端数据通常为受限数据或脱敏过的数据
  - 也可以访问实际的生产依赖项，例如数据库、缓存及中间件服务
  - 通常会引入一部分测试流量，以shadow的方式进行测试
  - 也可以直接配置使用"真实的"数据库，如此一来便需要仔细审查Stage环境
  

 #### 分支策略和部署环境
- 单分支策略
  - 主分支将始终包含在每个环境中使用的精确配置
  - 可以使用专用子目录，为每个环境提供一个默认配置
    - 可以使用Kustomize的分层配置体系进行支撑
- 多分支策略
  - 每个分支等同一于一个环境，从而可以在分支内为环境提供专用的配置文件
  - 每个分支还有着单独的commit history,能够独立执行审计跟踪和回滚



### 在k8s中部署NFS充当maven cache

```bash
# 安装NFS Server

https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/deploy/example/README.md
https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/deploy/example/nfs-provisioner/README.md
root@front-envoy:~# git clone https://github.com/kubernetes-csi/csi-driver-nfs.git
root@front-envoy:~# scp -r csi-driver-nfs/ root@172.168.2.21:~
root@k8s-master01:~/csi-driver-nfs/deploy# kubectl apply -f ./example/nfs-provisioner/nfs-server.yaml	#将此清单部署在nfs名称空间中
root@k8s-master01:~/csi-driver-nfs# kubectl get pods -n nfs
NAME                          READY   STATUS    RESTARTS   AGE
nfs-server-594768d8b8-p4wpl   1/1     Running   0          6m8s
root@k8s-master01:~/csi-driver-nfs# kubectl get svc -n nfs
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)            AGE
nfs-server   ClusterIP   10.68.238.132   <none>        2049/TCP,111/UDP   6m12s

----安装NFS CSI driver v4.0.0
https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v4.0.0.md
root@k8s-master01:~# cd csi-driver-nfs
#root@k8s-master01:~/csi-driver-nfs# ./deploy/install-driver.sh v4.0.0 local
root@k8s-master01:~/csi-driver-nfs# kubectl apply -f deploy/v3.1.0/		#v4.0.0有问题
root@k8s-master01:~/csi-driver-nfs/deploy/v4.0.0# kubectl -n kube-system get pod -o wide -l app=csi-nfs-controller
NAME                                  READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
csi-nfs-controller-54dc4c6b58-stm6p   3/3     Running   0          6m3s   172.168.2.25   172.168.2.25   <none>           <none>
root@k8s-master01:~/csi-driver-nfs/deploy/v4.0.0# kubectl -n kube-system get pod -o wide -l app=csi-nfs-node
NAME                 READY   STATUS    RESTARTS   AGE    IP             NODE           NOMINATED NODE   READINESS GATES
csi-nfs-node-ccr69   3/3     Running   0          6m8s   172.168.2.24   172.168.2.24   <none>           <none>
csi-nfs-node-mkczj   3/3     Running   0          6m8s   172.168.2.25   172.168.2.25   <none>           <none>
csi-nfs-node-srbwp   3/3     Running   0          6m8s   172.168.2.21   172.168.2.21   <none>           <none>


----创建storage class

root@k8s-master01:~/tekton-and-argocd-in-practise/nfs-csi-driver# cat 03-storageclass-nfs.yaml
---

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: nfs-csi
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.nfs.svc.cluster.local
  share: /

  # csi.storage.k8s.io/provisioner-secret is only needed for providing mountOptions in DeleteVolume

  # csi.storage.k8s.io/provisioner-secret-name: "mount-options"

  # csi.storage.k8s.io/provisioner-secret-namespace: "default"

reclaimPolicy: Retain
volumeBindingMode: Immediate
mountOptions:

  - hard
  - nfsvers=4.1
    root@k8s-master01:~/tekton-and-argocd-in-practise/nfs-csi-driver# kubectl apply -f 03-storageclass-nfs.yaml

----创建PVC

root@k8s-master01:~/tekton-and-argocd-in-practise/nfs-csi-driver# cat 05-pvc-maven-cache.yaml
---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: maven-cache
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 5Gi
  storageClassName: nfs-csi
root@k8s-master01:~/tekton-and-argocd-in-practise/nfs-csi-driver# kubectl apply -f 05-pvc-maven-cache.yaml
root@k8s-master01:~/tekton-and-argocd-in-practise/nfs-csi-driver# kubectl get pvc
NAME          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
maven-cache   Bound    pvc-4123e09e-4b61-46dd-a46d-5b50f44e12a2   5Gi        RWX            nfs-csi        2s

#在Task和Step上使用Volume

- Volume可显式定义要在Task和Step上使用的存储卷
  - 例如，为Maven指定Cache
    - 将下载的模块保存于指定的Volume上，即可由相关的Task和Step重复使用
    - 即便是不同的Pipeline，也能够使用同一个基于PVC等支持多个Pod访问的存储卷的maven cache
  - Volume的定义和使用
    - 在Task的spec.volumes字段中定义存储卷列表
    - 在Step中使用volumeMounts进行引用
  - 其使用方式与在Pod和Container上的方式相同
- 下面示例即为使用了Volume的task/s2p-demo的定义
  - 提示：相关的PVC资源需要事先定义
  - 另外，基于该Pipeline多次运行的PipelineRun便可通过该Volume使用maven cahe；


----运行
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat task-source-to-package-02.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: s2p-demo
spec:
  params:

  - name: git-repo-url
    type: string
    workspaces:
    - name: source
      description: code storage
      steps:
    - name: fetch-from-source
      image: alpine/git:v2.32.0
      script: |
        git clone $(params.git-repo-url) $(workspaces.source.path)/source
    - name: build-to-package
      image: maven:3.8-openjdk-11-slim
      workingDir: $(workspaces.source.path)/source
      script: |
        mvn clean install
      volumeMounts:				
        - name: maven-cache			#挂载PVC，提供持久存储，为maven提供缓存
          mountPath: /root/.m2		#maven缓存在当前用户家目录的.m2目录下
            volumes:
  - name: maven-cache			#创建存储卷，引用PVC
    persistentVolumeClaim:
      claimName: maven-cache
    root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl apply -f task-source-to-package-02.yaml
    root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat pipeline-source-to-package-02.yaml
    apiVersion: tekton.dev/v1beta1
    kind: Pipeline
    metadata:
    name: s2p-demo
    spec:
    params:
    - name: git-repo-url
      type: string
      workspaces:
    - name: source
      tasks:
    - name: s2p-demo
      params:
        - name: git-repo-url
          value: $(params.git-repo-url)
          workspaces:
        - name: source
          workspace: source
          taskRef:
          name: s2p-demo
          root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl apply -f pipeline-source-to-package-02.yaml
          root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# tkn pipeline start s2p-demo --showlog -p git-repo-url='https://github.com/iKubernetes/spring-boot-helloWorld.git' -w name=source,emptyDir=""	#第一次时间花好久，因为要建立缓存

root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat pipelinerun-s2p-demo.yaml
---

apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: s2p-demo-run-00001
spec:
  pipelineRef:
    name: s2p-demo		#调用pipeline
  params:
    - name: git-repo-url
      value: https://gitee.com/mageedu/spring-boot-helloWorld.git
  workspaces:
    - name: source
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: nfs-csi
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl apply -f pipelinerun-s2p-demo.yaml	#第二次运行会很快，直接可以引用缓存
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
maven-cache      Bound    pvc-4123e09e-4b61-46dd-a46d-5b50f44e12a2   5Gi        RWX            nfs-csi        3h55m
pvc-c5a5c21f24   Bound    pvc-fe32da09-a6ad-4c93-9a0d-b57ff1a96026   1Gi        RWO            nfs-csi        2s
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl cp /root/settings.xml nfs-server-594768d8b8-p4wpl:/exports/pvc-fe32da09-a6ad-4c93-9a0d-b57ff1a96026/ -n nfs	#配置maven私服
-----output info
[s2p-demo : build-to-package] [INFO] ------------------------------------------------------------------------
[s2p-demo : build-to-package] [INFO] BUILD SUCCESS
[s2p-demo : build-to-package] [INFO] ------------------------------------------------------------------------
[s2p-demo : build-to-package] [INFO] Total time:  20.565 s
[s2p-demo : build-to-package] [INFO] Finished at: 2022-05-17T13:59:14Z
[s2p-demo : build-to-package] [INFO] ------------------------------------------------------------------------
```







### 使用Results 进行数据传递

- Results简介
  - 在Pipeline的Task之间使用同一个共享的Workspace可以完成数据共享，但对于简单的字符串数据的传递，则可以使用Results API完成
  - Results用于让Task及其Step保存执行结果，并可在同一Pipeline中的后续Task中调用该结果
- 在Task中使用Results
  - 以列表形式定义在spec.results字段中
  - Task将会为每个results条目自动创建一个文件以进行保存，这些文件统一放置于/tektons/results目录中
  - 每个results条目的相关值（value）需要在Step中进行生成并保存，且Task不会对相关数据进行任何多余的操作
  - 在Step代码中引用results条目的便捷格式为“$(results.<resultName>.path)”，这样可以避免硬编码
    - 注意： $(results.<resultName>.path)”会被替换为文件路径，获取结果值需要获取该文件中保存的内容
- 在Task中引用Results时使用的变量
  - results.<resultName>.path
  - results['<resultName>'].path 或 results["<resultName>"].path
- 在Pipeline中引用Results时使用的变量
  - tasks.<taskName>.results.<resultName>
  - tasks.<taskName>.results['<resultName>'] 或 tasks.<taskName>.results["<resultName>"]

```bash
#示例
root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# cat 07-results-demo.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-buildid
spec:
  params:

   - name: version
     description: The version of the application
     type: string
     default: "v0.9"
       results:					#result可以跨step共享，跨task共享，但文件很小，最大最有4096字节
        - name: datetime
          description: The current date and time
             - name: buildId
               description: The build ID
                 steps:
                  - name: generate-datetime
                    image: ikubernetes/admin-box:v1.2
                    script: |
                      #!/usr/bin/env bash
                      datetime=`date +%Y%m%d-%H%M%S`
                      echo -n ${datetime} | tee $(results.datetime.path)
                       - name: generate-buildid
                         image: ikubernetes/admin-box:v1.2
                         script: |
                           #!/usr/bin/env bash
                           buildDatetime=`cat $(results.datetime.path)`
                           buildId=$(params.version)-${buildDatetime}
                           echo -n ${buildId} | tee $(results.buildId.path)
                         root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# kubectl apply -f 07-results-demo.yaml
                         root@k8s-master01:~/tekton-and-argocd-in-practise/03-tekton-advanced# tkn task start --showlog generate-buildid -p version='v1'
                         TaskRun started: generate-buildid-run-qmfx5
                         Waiting for logs to be available...
                         [generate-datetime] 20220517-105844

[generate-buildid] v1-20220517-105844	#共享了20220517-105844
```





### Pipeline高级用法

在Pipeline上定义Task的执行方式
- 使用taskRef或taskSpec可将Task添加至Pipeline上，它们以列表形式定义在spec.tasks字段中；
- 对于这些Task的运行，它们允许用户
  - 使用when表达式来为其添加执行条件
  - 使用conditions添加限制条件（已弃用）
  - 使用timeout定义任务超时时长
  - 使用runAfter定义任务的执行顺序
  - 定义finally任务，定义一个最终任务
  - 使用retries定义重试次数

在Pipeline上使用When表达式
- When表达式共有三个字段组成
  - input
    - 被评估的内容，支持使用静态值或者变量（Parameters或者Results变量）
    - 默认值为空；
  - operator
    - 比较操作符
    - 仅支持in或notin两个
  - values
    - 由字符串组成的列表
    - 必须定义，且不能使用空值，但允许使用静态值或者变量

在Pipeline上使用Finally Task
- 关于finally task
  - 用于在tasks中的各任务执行结束后运行最后的任务
  - 其定义格式与tasks字段相似
  - 支持嵌套定义多个Task
  - 这些Task上支持使用Parameters和Results
  - 支持使用When表达式
- 常用场景
  - 发送通知
    - 将Pipeline的执行结果通知给相关用户
    - 例如右图中的构建和测试的pipeline
  - 清理资源
    - 清理此前任务遗留的资源
    - 释放此前的任务运行时占用的资源
  - 终止任务执行
  - ……

实战案例Source-2-Image
- 案例环境说明
  - 示例项目
    - 代码仓库：github.com/ikubernetes/spring-boot-helloworld.git
    - 项目管理及构建工具：Maven
  - Pipeline中的各Task
    - git-clone：克隆项目的源代码
    - build-to-package：代码测试、构建和打包
    - generate-build-id：生成Build ID
    - image-build-and-push：镜像构建（和推送）
    - deploy-to-cluster：将新版本的镜像更新到Kubernetes集群上
  - Workspace
    - 基于PVC建立，跨Task共享
- kaniko
  - 构建镜像工具，如docker build
  - 文档：https://github.com/GoogleContainerTools/kaniko

```bash
#示例，并推送到repository
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 01-task-git-clone.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  description: Clone the code repository to the workspace.
  params:

   - name: url				#定义git项目地址
     type: string
     description: git url to clone
       workspaces:
        - name: source			#定义一个共享存储，用于存放git代码、编译后存储文件、Dockerfile存储等，等会使用PVC
          description: The git repo will be cloned onto the volume backing this workspace
            steps:
             - name: git-clone
               image: alpine/git:v2.32.0		#git构建镜像，应当下载到本地，提高速度
               script: git clone -v $(params.url) $(workspaces.source.path)/source

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 02-task-source-build.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-to-package
spec:
  description: build application and package the files to image
  workspaces:

   - name: source			#定义一个共享存储，用于存放git代码、编译后存储文件、Dockerfile存储等，等会使用PVC
     description: The git repo that cloned onto the volume backing this workspace
       steps:
        - name: build
          image: maven:3.8-openjdk-11-slim		#maven构建镜像，应当下载到本地，提高速度
          workingDir: $(workspaces.source.path)/source	#指定maven工作目录
          volumeMounts:
       - name: m2
         mountPath: /root/.m2		#挂载PVC，提供持久存储，为maven提供缓存
         script: mvn clean install		#执行构建编译
           volumes:
         - name: m2
           persistentVolumeClaim:
           claimName: maven-cache		#调用PVC

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 03-task-build-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: image-build
spec:
  description: package the application files to image
  params:

   - name: dockerfile				#设置dockerfile名称，默认为Dockerfile
     description: The path to the dockerfile to build (relative to the context)
     default: Dockerfile
        - name: image-url				#镜像的地址名称
          description: Url of image repository
             - name: image-tag				#镜像的tag
               description: Tag to apply to the built image
               default: latest				#默认值为latest
                 workspaces:
                  - name: source					#定义一个共享存储，用于存放git代码、编译后存储文件、Dockerfile存储等，等会使用PVC
     - name: dockerconfig
       mountPath: /kaniko/.docker	#workspace dockerconfig挂载到/kaniko/.docker目录，后面把docker的认证文件赋值到此目录下，为/kaniko/.docker/config.json
       steps:
         - name: build-and-push-image
           image: gcr.io/kaniko-project/executor:debug	#使用构建镜像的方法，默认是docker build(dind{docker in docker，需要挂载宿主机sock文件})，这里使用google的一个项目kaniko来构建镜像，但是此镜像不在本地，需要下载到本地
           securityContext:
           runAsUser: 0				#设定pod支持的用户，此为root
           env:
       - name: DOCKER_CONFIG		#定义环境变量，配置docker的认证目录
         value: /kaniko/.docker
         command:
       - /kaniko/executor			#执行构建的命令
         args:
       - --dockerfile=$(params.dockerfile)				#指定dockerfile名称
       - --context=$(workspaces.source.path)/source	#指定构建的工作目录
       - --destination=$(params.image-url):$(params.image-tag)	#推送到目标仓库的url:tag
         	

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 04-pipeline-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: source-to-image
spec:
  params:

   - name: git-url			#定义git项目地址
     - name: pathToContext
       description: The path to the build context, used by Kaniko - within the workspace
       default: .			#此变量未引用，多余
         - name: image-url		#镜像url
           description: Url of image repository
         - name: image-tag		#镜像tag
           description: Tag to apply to the built image
           workspaces:
         - name: codebase		#共享存储，提供能task之间共享
           tasks:
         - name: git-clone
           taskRef:
           name: git-clone
           params:
       - name: url
         value: "$(params.git-url)"	#此task调用此pipeline的git-url变量值
         workspaces:
       - name: source					#此task调用此pipeline的codebase workspace值
         workspace: codebase
         - name: build-to-package
           taskRef:
           name: build-to-package
           workspaces:
       - name: source		#调用共享存储
         workspace: codebase
         runAfter:
       - git-clone			#运行是task git-clone之后
         - name: image-build
           taskRef:
           name: image-build
           params:
       - name: image-url	#调用变量
         value: "$(params.image-url)"
       - name: image-tag	#调用变量
         value: "$(params.image-tag)"
         workspaces:
       - name: source		#调用共享存储
         workspace: codebase
         runAfter:
       - build-to-package	#运行是task build-to-package之后

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 05-pipelinerun-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: s2i-no-push-run-00001
spec:
  pipelineRef:
    name: source-to-image		#运行pipeline
  params:

   - name: git-url
     value: https://gitee.com/mageedu/spring-boot-helloWorld.git	#赋值给pipeline变量值
        - name: image-url
          value: ikubernetes/spring-boot-helloworld
             - name: image-tag
               value: latest
                 workspaces:
                  - name: codebase			#创建pvc，并把pvc传给codebase workspace，以实现task之间的共享存储
                    volumeClaimTemplate:
                      spec:
                        accessModes:
          - ReadWriteOnce
            resources:
            requests:
            storage: 1Gi		
              storageClassName: nfs-csi


###下面是修改后的示例

#生成secret，用于访问docker repository
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# echo -n 'user:password' | base64
dXNlcjpwYXNzd29yZA==
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat config.json
{
        "auths": {
                "192.168.13.197:8000": {
                        "auth": "dXNlcjpwYXNzd29yZA=="
                }
        }
}
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# kubectl create secret generic docker-config --from-file=./config.json	#此处类型为generic而非docker-registry是因为直接使用我们信息的是kaniko，而非docker hub

#创建kaniko缓存目录，用于加快镜像下载构建

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat kaniko-cache.yaml
---

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: kaniko-cache
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  storageClassName: nfs-csi
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# kubectl apply -f kaniko-cache.yaml


#Pipeline完成Image，且自动将其推送至harbor，完成应用交付
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 01-task-git-clone.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  description: Clone the code repository to the workspace.
  params:
    - name: url
      type: string
      description: git url to clone
  workspaces:
    - name: source
      description: The git repo will be cloned onto the volume backing this workspace
  steps:
    - name: git-clone
      image: 192.168.13.197:8000/gitops/tekton/git-alpine:v2.32.0
      script: git clone -v $(params.url) $(workspaces.source.path)/source
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 02-task-source-build.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-to-package
spec:
  description: build application and package the files to image
  workspaces:
    - name: source
      description: The git repo that cloned onto the volume backing this workspace
  steps:
    - name: build
      image: 192.168.13.197:8000/gitops/tekton/maven:3.8-openjdk-11-slim
      workingDir: $(workspaces.source.path)/source
      volumeMounts:
        - name: m2
          mountPath: /root/.m2
      script: mvn clean install
  volumes:
    - name: m2
      persistentVolumeClaim:
        claimName: maven-cache
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 03-task-build-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: image-build-and-push
spec:
  description: package the application files to image
  params:
    - name: dockerfile
      description: The path to the dockerfile to build (relative to the context)
      default: Dockerfile
    - name: image-url
      description: Url of image repository
    - name: image-tag
      description: Tag to apply to the built image
      default: latest
  workspaces:
    - name: source
    - name: dockerconfig
      mountPath: /kaniko/.docker
  steps:
    - name: image-build-and-push
      image: 192.168.13.197:8000/gitops/tekton/kaniko-project/executor:debug
      securityContext:
        runAsUser: 0
      env:
        - name: DOCKER_CONFIG
          value: /kaniko/.docker
      command:
        - /kaniko/executor
      args:
        - --dockerfile=$(params.dockerfile)
        - --context=$(workspaces.source.path)/source
        - --destination=$(params.image-url):$(params.image-tag)
        - --insecure=192.168.13.197:8000

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 04-pipeline-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: source-to-image
spec:
  params:
    - name: git-url
    - name: image-url
      description: Url of image repository
    - name: image-tag
      description: Tag to apply to the built image
  workspaces:
    - name: codebase
    - name: docker-config
  tasks:
    - name: git-clone
      taskRef:
        name: git-clone
      params:
        - name: url
          value: "$(params.git-url)"
      workspaces:
        - name: source
          workspace: codebase
    - name: build-to-package
      taskRef:
        name: build-to-package
      workspaces:
        - name: source
          workspace: codebase
      runAfter:
        - git-clone
    - name: image-build-and-push
      taskRef:
        name: image-build-and-push
      params:
        - name: image-url
          value: "$(params.image-url)"
        - name: image-tag
          value: "$(params.image-tag)"
      workspaces:
        - name: source
          workspace: codebase
        - name: dockerconfig
          workspace: docker-config
      runAfter:
        - build-to-package
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# cat 05-pipelinerun-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: s2i-image-push-run-00001
spec:
  pipelineRef:
    name: source-to-image
  params:
    - name: git-url
      value: http://gitlab.hs.com/0799/java-test.git
    - name: image-url
      value: 192.168.13.197:8000/k8s-test/java-test
    - name: image-tag
      value: v1
  workspaces:
    - name: codebase
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: nfs-csi
    - name: docker-config
      secret:
        secretName: docker-config
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/02-s2i-push-to-dockerhub# kubectl apply -f .
task.tekton.dev/git-clone created
task.tekton.dev/build-to-package created
task.tekton.dev/image-build-and-push created
pipeline.tekton.dev/source-to-image created
pipelinerun.tekton.dev/s2i-image-push-run-00001 created

#添加Task，生成Build ID，并将之作为Image的标签
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# cat 01-task-git-clone.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  description: Clone the code repository to the workspace.
  params:
    - name: url
      type: string
      description: git url to clone
  workspaces:
    - name: source
      description: The git repo will be cloned onto the volume backing this workspace
  steps:
    - name: git-clone
      image: 192.168.13.197:8000/gitops/tekton/git-alpine:v2.32.0
      script: git clone -v $(params.url) $(workspaces.source.path)/source
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# cat 02-task-source-build.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-to-package
spec:
  description: build application and package the files to image
  workspaces:
    - name: source
      description: The git repo that cloned onto the volume backing this workspace
  steps:
    - name: build
      image: 192.168.13.197:8000/gitops/tekton/maven:3.8-openjdk-11-slim
      workingDir: $(workspaces.source.path)/source
      volumeMounts:
        - name: m2
          mountPath: /root/.m2
      script: mvn clean install
  volumes:
    - name: m2
      persistentVolumeClaim:
        claimName: maven-cache
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# cat 03-generate-build-id.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-build-id
spec:
  params:
    - name: version
      description: The version of the application
      type: string
  results:
    - name: datetime				#创建两个results，用于task之间共享
      description: The current date and time
    - name: buildId					#经过加工最后生成buildId，由推送镜像task进行调用
      description: The build ID
  steps:
    - name: generate-datetime
      image: 192.168.13.197:8000/gitops/admin-box:v1.2
      script: |
        #!/usr/bin/env bash
        datetime=`date +%Y%m%d-%H%M%S`
        echo -n ${datetime} | tee $(results.datetime.path)
    - name: generate-buildid
      image: 192.168.13.197:8000/gitops/admin-box:v1.2
      script: |
        #!/usr/bin/env bash
        buildDatetime=`cat $(results.datetime.path)`
        buildId=$(params.version)-${buildDatetime}
        echo -n ${buildId} | tee $(results.buildId.path)
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# cat 04-task-build-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: image-build-and-push
spec:
  description: package the application files to image
  params:
    - name: dockerfile
      description: The path to the dockerfile to build (relative to the context)
      default: Dockerfile
    - name: image-url
      description: Url of image repository
    - name: image-tag
      description: Tag to apply to the built image
      default: latest
  workspaces:
    - name: source
    - name: dockerconfig
      mountPath: /kaniko/.docker
  steps:
    - name: image-build-and-push
      image: 192.168.13.197:8000/gitops/tekton/kaniko-project/executor:debug
      securityContext:
        runAsUser: 0
      env:
        - name: DOCKER_CONFIG
          value: /kaniko/.docker
      command:
        - /kaniko/executor
      args:
        - --dockerfile=$(params.dockerfile)
        - --context=$(workspaces.source.path)/source
        - --destination=$(params.image-url):$(params.image-tag)
        - --insecure-registry=192.168.13.197:8000

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# cat 05-pipeline-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: source-to-image
spec:
  params:
    - name: git-url
    - name: pathToContext
      description: The path to the build context, used by Kaniko - within the workspace
      default: .
    - name: image-url
      description: Url of image repository
    - name: version
      description: The version of the application
      type: string
      default: "v0.9"
  results:
    - name: datetime
      description: The current date and time
    - name: buildId
      description: The build ID
  workspaces:
    - name: codebase
    - name: docker-config
  tasks:
    - name: git-clone
      taskRef:
        name: git-clone
      params:
        - name: url
          value: "$(params.git-url)"
      workspaces:
        - name: source
          workspace: codebase
    - name: build-to-package
      taskRef:
        name: build-to-package
      workspaces:
        - name: source
          workspace: codebase
      runAfter:
        - git-clone
    - name: generate-build-id
      taskRef:
        name: generate-build-id
      params:
        - name: version
          value: "$(params.version)"
      runAfter:
        - git-clone
    - name: image-build-and-push
      taskRef:
        name: image-build-and-push
      params:
        - name: image-url
          value: "$(params.image-url)"
        - name: image-tag
          value: "$(tasks.generate-build-id.results.buildId)"		#这里调用generate-build-id中的results.buildId的值
      workspaces:
        - name: source
          workspace: codebase
        - name: dockerconfig
          workspace: docker-config
      runAfter:
        - generate-build-id
        - build-to-package
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# cat 06-pipelinerun-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: s2i-image-push-run-00009
spec:
  pipelineRef:
    name: source-to-image
  params:
    - name: git-url
      value: http://gitlab.hs.com/0799/helloWorld.git
      #value: http://gitlab.hs.com/0799/java-test.git
    - name: image-url
      value: 192.168.13.197:8000/k8s-test/helloworld-test
      #value: 192.168.13.197:8000/k8s-test/java-test
    - name: image-tag
      value: v2
  workspaces:
    - name: codebase
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: nfs-csi
    - name: docker-config
      secret:
        secretName: docker-config
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/03-s2i-auto-gen-build-id# kubectl apply -f .


#添加Task，完成自动部署
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 01-task-git-clone.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  description: Clone the code repository to the workspace.
  params:
    - name: url
      type: string
      description: git url to clone
  workspaces:
    - name: source
      description: The git repo will be cloned onto the volume backing this workspace
  steps:
    - name: git-clone
      image: 192.168.13.197:8000/gitops/tekton/git-alpine:v2.32.0
      script: git clone -v $(params.url) $(workspaces.source.path)/source
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 02-task-source-build.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-to-package
spec:
  description: build application and package the files to image
  workspaces:
    - name: source
      description: The git repo that cloned onto the volume backing this workspace
  steps:
    - name: build
      image: 192.168.13.197:8000/gitops/tekton/maven:3.8-openjdk-11-slim
      workingDir: $(workspaces.source.path)/source
      volumeMounts:
        - name: m2
          mountPath: /root/.m2
      script: mvn clean install
  volumes:
    - name: m2
      persistentVolumeClaim:
        claimName: maven-cache
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 03-generate-build-id.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-build-id
spec:
  params:
    - name: version
      description: The version of the application
      type: string
  results:
    - name: datetime
      description: The current date and time
    - name: buildId
      description: The build ID
  steps:
    - name: generate-datetime
      image: 192.168.13.197:8000/gitops/admin-box:v1.2
      script: |
        #!/usr/bin/env bash
        datetime=`date +%Y%m%d-%H%M%S`
        echo -n ${datetime} | tee $(results.datetime.path)
    - name: generate-buildid
      image: 192.168.13.197:8000/gitops/admin-box:v1.2
      script: |
        #!/usr/bin/env bash
        buildDatetime=`cat $(results.datetime.path)`
        buildId=$(params.version)-${buildDatetime}
        echo -n ${buildId} | tee $(results.buildId.path)
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 04-task-build-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: image-build-and-push
spec:
  description: package the application files to image
  params:
    - name: dockerfile
      description: The path to the dockerfile to build (relative to the context)
      default: Dockerfile
    - name: image-url
      description: Url of image repository
    - name: image-tag
      description: Tag to apply to the built image
      default: latest
  workspaces:
    - name: source
    - name: dockerconfig
      mountPath: /kaniko/.docker
  steps:
    - name: image-build-and-push
      image: 192.168.13.197:8000/gitops/tekton/kaniko-project/executor:debug
      securityContext:
        runAsUser: 0
      env:
        - name: DOCKER_CONFIG
          value: /kaniko/.docker
      command:
        - /kaniko/executor
      args:
        - --dockerfile=$(params.dockerfile)
        - --context=$(workspaces.source.path)/source
        - --destination=$(params.image-url):$(params.image-tag)
        - --insecure-registry=192.168.13.197:8000
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 05-task-deploy.yaml
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-using-kubectl
spec:
  workspaces:
    - name: source
      description: The git repo
  params:
    - name: deploy-config-file		#会调用all-in-one.yaml文件进行部署
      description: The path to the yaml file to deploy within the git source
    - name: image-url
      description: Image name including repository
    - name: image-tag
      description: Image tag
  steps:
    - name: update-yaml
      image: 192.168.13.197:8000/gitops/alpine:3.15
      command: ["sed"]
      args:
        - "-i"
        - "-e"
        - "s@__IMAGE__@$(params.image-url):$(params.image-tag)@g"
        - "$(workspaces.source.path)/source/deploy/$(params.deploy-config-file)"		#更改为最新镜像版本
    - name: run-kubectl
      image: 192.168.13.197:8000/gitops/tekton/k8s-kubectl:latest
      command: ["kubectl"]
      args:
        - "apply"
        - "-f"
        - "$(workspaces.source.path)/source/deploy/$(params.deploy-config-file)"		#部署
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 06-pipeline-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: source-to-image
spec:
  params:
    - name: git-url
    - name: pathToContext
      description: The path to the build context, used by Kaniko - within the workspace
      default: .
    - name: image-url
      description: Url of image repository
    - name: deploy-config-file				#会传入all-in-one.yaml文件
      description: The path to the yaml file to deploy within the git source
      default: all-in-one.yaml
    - name: version
      description: The version of the application
      type: string
      default: "v0.9"
  results:
    - name: datetime
      description: The current date and time
    - name: buildId
      description: The build ID
  workspaces:
    - name: codebase
    - name: docker-config
  tasks:
    - name: git-clone
      taskRef:
        name: git-clone
      params:
        - name: url
          value: "$(params.git-url)"
      workspaces:
        - name: source
          workspace: codebase
    - name: build-to-package
      taskRef:
        name: build-to-package
      workspaces:
        - name: source
          workspace: codebase
      runAfter:
        - git-clone
    - name: generate-build-id
      taskRef:
        name: generate-build-id
      params:
        - name: version
          value: "$(params.version)"
      runAfter:
        - git-clone
    - name: image-build-and-push
      taskRef:
        name: image-build-and-push
      params:
        - name: image-url
          value: "$(params.image-url)"
        - name: image-tag
          value: "$(tasks.generate-build-id.results.buildId)"	#直接调用results生成的值，不用parameters传入
      workspaces:
        - name: source
          workspace: codebase
        - name: dockerconfig
          workspace: docker-config
      runAfter:
        - generate-build-id
        - build-to-package
    - name: deploy-to-cluster
      taskRef:
        name: deploy-using-kubectl
      workspaces:
        - name: source
          workspace: codebase
      params:
        - name: deploy-config-file
          value: $(params.deploy-config-file)
        - name: image-url
          value: $(params.image-url)
        - name: image-tag
          value: "$(tasks.generate-build-id.results.buildId)"	#直接调用results生成的值，不用parameters传入
      runAfter:
        - image-build-and-push

root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 07-rbac.yaml
---

apiVersion: v1
kind: ServiceAccount
metadata:

  name: helloworld-admin
---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helloworld-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin		#集群管理员权限，因为部署清单有要创建名称空间，可以自己先创建名称空间，再来最小化这里的权限
subjects:

- kind: ServiceAccount
  name: helloworld-admin
  namespace: default
  root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 08-pipelinerun-source-to-image.yaml
  apiVersion: tekton.dev/v1beta1
  kind: PipelineRun
  metadata:
  name: s2i-buildid-run-00010
  spec:
  serviceAccountNames:				#指定特定task使用什么sa进行运行，这里是deploy到集群，而且要创建名称空间，所以需要使用admin SA。如果为所有task设定sa，则例如可以使用serviceAccountName: default
    - taskName: deploy-to-cluster
      serviceAccountName: helloworld-admin
      pipelineRef:
      name: source-to-image
      params:
    - name: git-url
      value: http://gitlab.hs.com/0799/helloWorld.git
    - name: image-url
      value: 192.168.13.197:8000/k8s-test/helloworld-test
    - name: version
      value: v0.9.2
      workspaces:
    - name: codebase
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: nfs-csi
    - name: docker-config
      secret:
        secretName: docker-config
      root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# kubectl apply -f .
      root@k8s-master01:~/git-project/helloWorld# kubectl get pods -n hello
      NAME                                     READY   STATUS    RESTARTS   AGE
      spring-boot-helloworld-98c6b999b-7hxnr   1/1     Running   0          23s
      root@k8s-master01:~/git-project/helloWorld# kubectl get all  -n hello
      NAME                                         READY   STATUS    RESTARTS   AGE
      pod/spring-boot-helloworld-98c6b999b-7hxnr   1/1     Running   0          32s

NAME                             TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/spring-boot-helloworld   NodePort   10.68.116.212   <none>        80:45925/TCP   23m

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/spring-boot-helloworld   1/1     1            1           23m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/spring-boot-helloworld-98c6b999b    1         1         1       33s

#升级为v0.9.3
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# cat 09-pipelinerun-source-to-image-local-repo.yaml
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: s2i-buildid-run-00011
spec:
  serviceAccountNames:
    - taskName: deploy-to-cluster
      serviceAccountName: helloworld-admin
  pipelineRef:
    name: source-to-image
  params:
    - name: git-url
      value: http://gitlab.hs.com/0799/helloWorld.git
    - name: image-url
      value: 192.168.13.197:8000/k8s-test/helloworld-test
    - name: version
      value: v0.9.3
  workspaces:
    - name: codebase
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
          storageClassName: nfs-csi
    - name: docker-config
      secret:
        secretName: docker-config
root@k8s-master01:~/tekton-and-argocd-in-practise/04-tekton-pipeline-in-practise/04-s2i-auto-deploy# kubectl apply -f 09-pipelinerun-source-to-image-local-repo.yaml
root@k8s-master01:~/git-project/helloWorld# curl 10.68.116.212/version
Spring Boot Helloworld, version 0.9.3
```



## Tekton Trigger 基础

Tekton Trigger简介

- Tekton Trigger简介
  - 监控特定的事件，并在满足条件时自动触发Tekton Pipeline
    - 例如，代码仓库上的创建pull request, push代码, 以及合并pull request至main分支等
  - Tekton Triggers为用户提供了一种声明式API
    - 它允许用户按需定义监视的事件，并将其与特定的Pipeline连接，从而实例化出PipelineRun/TaskRun
	- 还允许将事件中的某些属性值信息注入到Pipeline中
- Tekton Trigger的关键组件(CRD)
  - Trigger
  - TriggerBinding
  - TriggerTemplate
  - EventListener
  - Interceptor
  

Tekton Trigger的关键组件
- Trigger
  - EventListener Pod用于监视并筛选Event时使用的筛选条件
  - 由TriggerTemplate, TriggerBinding和ClusterInterceptor组成
- TriggerTemplate
  - 可由EventListener筛选出的Event触发，从而实例化并完成资源创建，例如TaskRun或PipelineRun
  - 支持通过参数从TriggerBinding接受配置信息
- TriggerBinding（名称空间级别）和ClusterTriggerBinding（集群级别）
  - 负责指定在事件上（由EventListener筛选出）感兴趣的字段，并从这些字段中取出数据传递给TriggerTemplate
  - 而后，TriggerTemplate将相应的数据赋值比例关联的TaskRun或PipelineRun资源上的参数
- EventListener
  - 以pod形式运行于Kubernetes集群上，通过监听的特定端口接收Event
  - Event的过滤则需由一到多个Trigger进行定义
- ClusterInterceptor
  - 负责在Trigger进行事件筛选之前，接收特定平台或系统（如GitLab）上全部事件，进而支持一些预处理操作，例如内容过滤、校验、转换、Trigger条件测试等
  - 预处理完成后的事件，由Trigger进行筛选，符合条件的Event将传递给TriggerBinding

Tekton Trigger各组件间的逻辑关系
- EventListener Pod是Tekton Trigger的物理表现形式，它主要由一至多个Trigger组成
- Trigger CRD即可以单独定义，也能够以内联方式定义在EventListener之上
- 每个Trigger可由一个template、一组bindings以及一组interceptors构成
  - template可引用一个独立的TriggerTemplate资源，亦可内联定义
  - bindings可引用一至多个独立的TriggerBinding资源，亦可内联定义
  - interceptors的定义，通常是引用ClusterInterceptor定义出的过滤规则
  



## TektonTrigger部署

```bash
文档：https://tekton.dev/docs/triggers/install/
#部署TektonTrigger
root@k8s-master01:~# kkubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
root@k8s-master01:~# kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-triggers
NAME                                          READY   STATUS    RESTARTS   AGE
tekton-triggers-controller-6d769dddf7-4xfxl   1/1     Running   0          110s
tekton-triggers-webhook-7c4fc7c74-26xhz       1/1     Running   0          110s
root@k8s-master01:~# kubectl get svc -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-triggers
NAME                         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
tekton-triggers-controller   ClusterIP   10.68.47.53   <none>        9000/TCP   2m25s
tekton-triggers-webhook      ClusterIP   10.68.62.27   <none>        443/TCP    2m25s
root@k8s-master01:~# kubectl api-resources --api-group=triggers.tekton.dev
NAME                     SHORTNAMES   APIVERSION                     NAMESPACED   KIND
clusterinterceptors      ci           triggers.tekton.dev/v1alpha1   false        ClusterInterceptor
clustertriggerbindings   ctb          triggers.tekton.dev/v1beta1    false        ClusterTriggerBinding
eventlisteners           el           triggers.tekton.dev/v1beta1    true         EventListener
triggerbindings          tb           triggers.tekton.dev/v1beta1    true         TriggerBinding
triggers                 tri          triggers.tekton.dev/v1beta1    true         Trigger
triggertemplates         tt           triggers.tekton.dev/v1beta1    true         TriggerTemplate

----部署interceptors
root@k8s-master01:~# kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
root@k8s-master01:~# kubectl get svc -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-triggers
NAME                                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
tekton-triggers-core-interceptors   ClusterIP   10.68.137.141   <none>        8443/TCP   57s
root@k8s-master01:~# kubectl get pods -n tekton-pipelines -l app.kubernetes.io/part-of=tekton-triggers
NAME                                                 READY   STATUS    RESTARTS   AGE
tekton-triggers-core-interceptors-69c47c4bb7-j5nhj   1/1     Running   0          59s
root@k8s-master01:~# kubectl get clusterInterceptor		#内置支持四种事件类型
NAME        AGE
bitbucket   107s
cel         107s
github      107s
gitlab      107s
```



### TriggerTemplate CRD资源规范

- TriggerTemplate CRD遵循Kubernetes resource API规范，其spec字段主要由以下两个嵌套字段组成
  - params
    - 当前TriggerTemplate的参数，从TriggerBinding接受传值
	- resourcetemplates中的资源模板中的参数，通过引用TriggerTemplate的参数值完成实例化
	  - 引用格式：$(tt.params.<NAME>)
  - resourcetemplates
    - 用于定义资源模板
	- 在Tekton的环境中，通常用于定义PipelineRun或TaskRun资源
	- 资源的名称，通常要使用generateName定义其前缀，而非使用name直接指定
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/01-trigger-basics# cat 01-triggertemplate-demo.yaml
    apiVersion: triggers.tekton.dev/v1alpha1
    kind: TriggerTemplate
    metadata:
    name: pipeline-template-demo
    spec:
    params:
    - name: image-url
      default: ikubernetes/spring-boot-helloworld
    - name: git-revision
      description: The git revision (SHA)
      default: master
    - name: git-url
      description: The git repository url ("https://github.com/foo/bar.git")
    - name: version
      description: The version of application
      resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: pipeline-run-
      spec:
        pipelineRef:
          name: source-to-image
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: image-url
            value: $(tt.params.image-url)
          - name: version
            value: $(tt.params.version)
        workspaces:
          - name: codebase
            volumeClaimTemplate:
              spec:
                accessModes:
                  - ReadWriteOnce
                resources:
                  requests:
                    storage: 1Gi
                storageClassName: nfs-csi
          - name: docker-config
            secret:
              secretName: docker-config

### TriggerBinding CRD资源规范

- TriggerBinding的功能
  - 主要用于将Event中特定属性的值传递给TriggerTemplate上的参数从而完成其resourcetemplates中模板资源的实例化
  - 其spec字段，主要定义params，每个Parameters主要是name和value两个字段组成
    - name即为同一Trigger当中引用的TriggerTemplate上声明的某个参数的名称
	- value通常要引用Event中的特定属性，例如"$(body.repository.clone_url)"
- ClusterTriggerBinding CRD
  - 集群级别的TriggerBinding，资源格式与TriggerBinding相似
  - 在Trigger上的spec.bindings字段中引用ClusterTriggerBinding时，要显示使用kind字段指明资源类别
   root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/01-trigger-basics# cat 02-triggerbinding-demo.yaml
    apiVersion: triggers.tekton.dev/v1beta1
    kind: TriggerBinding
    metadata:
    name: pipeline-binding-demo
    spec:
    params:
  - name: git-url
    value: $(body.head_commit.id)
  - name: image-url
    value: $(body.repository.url)
  - name: version
    value: $(header.Content-Type)

### Trigger CRD资源规范

- Trigger
  - CRD资源，遵循Kubernetes resource API规范
  - EventListener上的关键组件，主要由TriggerTemplate、TriggerBinding和Interceptor组成
    - TriggerTemplate是必选组件，定义在spec.template字段上，支持引用和内联两种定义方式
	- TriggerBinding可选，定义在spec.bindings字段上，支持引用和内联两种定义方式
	- CluisterInterceptor可选，定义在spec.interceptors字段上
  - 事实上，Trigger也完全能够以内联方式直接定义在EventListener之上，这甚至也是更为常用的方式

### Tekton Trigger案例

- 安全环境说明
  - 代码仓库位于Gitlab之上
    - gitlab服务同样运行于Kubernetes集群之上
	- code.magedu.com, code.gitlab.svc.cluster.local
	- 示例代码仓库：root/spring-boot-helloworld
  - EventListener
    - 通过webhook，接收代码仓库root/spring-boot-helloWorld上的Push事件
	- ClusterInterceptor将gitlab事件规范化
	- TriggerBinding资源gitlab-push-binding负责读取规范后的Push事件并完成参数赋值
	  - 将事件上checkout_sha属性的值传递给git-revision参数
	  - 将事件上repository.git_http_url属性的值传递给git-repo-url参数
	- TriggerTemplate资源gitlab-trigger-template从gitlab-push-binding接受传递的参数值，并根据resourcetemplates中定义的资源模板完成TaskRun资源实例化，即创建并运行TaskRun实例
	- 注：EventListener Pod因需要完成诸多资源的管理，以及通过webhook与Gitlab的通信等，因此要依赖于Secret和一些RBAC的资源授权
	
	
	

### 配置TektonTrigger

```bash
#创建secert，用于gitlab访问EventListener的weebhook的token
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat 01-gitlab-token-secret.yaml	
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-webhook-token
type: Opaque
stringData:

  # Generated by command "openssl rand -base64 12"

  webhookToken: "DXeqvozMlTA67aQB"
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl apply -f 01-gitlab-token-secret.yaml

#配置rbac，用于访问TriggerBinding、TriggerTemplate和terceptors的权限
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat 02-gitlab-eventlistener-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-triggers-gitlab-sa
secrets:

- name: gitlab-webhook-token		#创建sa用户，并且此用户具有一个token

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tekton-triggers-gitlab-minimal			#创建角色
rules:

  # Permissions for every EventListener deployment to function

  - apiGroups: ["triggers.tekton.dev"]										#api group下
    resources: ["eventlisteners", "triggerbindings", "triggertemplates"]	#能够get这些资源
    verbs: ["get"]

  - apiGroups: [""]

    # secrets are only needed for Github/Gitlab interceptors, serviceaccounts only for per trigger authorization

    resources: ["configmaps", "secrets", "serviceaccounts"]		#能够在v1群组下，get、list、watch这些资源
    verbs: ["get", "list", "watch"]

  # Permissions to create resources in associated TriggerTemplates

  - apiGroups: ["tekton.dev"]
    resources: ["pipelineruns", "pipelineresources", "taskruns"]	#能够create这些资源
    verbs: ["create"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-triggers-gitlab-binding	#创建角色绑定，将sa:tekton-triggers-gitlab-sa和role:tekton-triggers-gitlab-minimal进行绑定
subjects:

  - kind: ServiceAccount
    name: tekton-triggers-gitlab-sa
      roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: tekton-triggers-gitlab-minimal

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tekton-triggers-gitlab-minimal	
rules:

  - apiGroups: ["triggers.tekton.dev"]
    resources: ["clusterinterceptors"]	#创建集群角色，能够get、list这些资源
    verbs: ["get","list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tekton-triggers-gitlab-binding	#集群角色绑定，将sa：tekton-triggers-gitlab-sa和ClusterRole:tekton-triggers-gitlab-minimal进行绑定
subjects:

  - kind: ServiceAccount
    name: tekton-triggers-gitlab-sa
    namespace: default
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: tekton-triggers-gitlab-minimal
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl apply -f 02-gitlab-eventlistener-rbac.yaml

#创建TriggerBinding，TriggerBinding将会从Trigger获取事件信息并将特定的值取出来并赋值给新params
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat 03-gitlab-push-binding.yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: gitlab-push-binding
spec:
  params:

  - name: git-revision
    value: $(body.checkout_sha)
  - name: git-repo-url
    value: $(body.repository.git_http_url)
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl apply -f 03-gitlab-push-binding.yaml

#创建TriggerTemplate
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat 04-gitlab-trigger-template.yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: gitlab-trigger-template
spec:
  params:  # 定义参数

  - name: git-revision	#TriggerBinding将会把自己的params的值对应起来赋值给TriggerTemplate的params
  - name: git-repo-url
    resourcetemplates:
  - apiVersion: tekton.dev/v1beta1
    kind: TaskRun		#创建TaskRun，也可以是PipelineRun
    metadata:
      generateName: gitlab-trigger-run-  # TaskRun 名称前缀
    spec:
      serviceAccountName: tekton-triggers-gitlab-sa	#task运行的sa名称，就是上面创建的sa，才有对应的权限
      params:
        - name: git-revision
          value: $(tt.params.git-revision)	#TaskRun上定义的params，值将从TriggerTemplate的params中引用，简写tt
        - name: git-repo-url
          value: $(tt.params.git-repo-url)
      workspaces:
        - name: source
          emptyDir: {}
      taskSpec:
        workspaces:
          - name: source
        params:
          - name: git-revision
          - name: git-repo-url
        steps:
          - name: fetch-from-git-repo
            image: 192.168.13.197:8000/gitops/tekton/git-alpine:v2.32.0
            script: |
              git clone -v $(params.git-repo-url) $(workspaces.source.path)/source
              cd $(workspaces.source.path)/source && git reset --hard $(params.git-revision)	#git重写到特定的checkout_sha
          - name: list-files
            image: 192.168.13.197:8000/gitops/alpine:3.15
            script: ls -la $(workspaces.source.path)/source
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl apply -f 04-gitlab-trigger-template.yaml

#创建EventListener，将绑定Trigger,TriggerBinding,TriggerTemplate，EventListener会生成一个Service，就是weebhook的地址
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat 05-gitlab-event-listener.yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: gitlab-event-listener
spec:
  serviceAccountName: tekton-triggers-gitlab-sa	#这里用于获取interceptors信息，并赋值给bindings的params，template中有定义同名sa，不冲突
  triggers:

  - name: gitlab-push-events-trigger
    interceptors:
    - ref:
      name: "gitlab"		#用于格式化gitlab为标准event事件
      params:
      - name: "secretRef"	#用于配置EventListener的认证token，gitlab访问EventListener时认证使用
        value:
          secretName: gitlab-webhook-token
          secretKey: webhookToken
      - name: "eventTypes"
        value: ["Push Hook"]	#并且定义只是gitlab的"Push Hook"事件才允许调用此webhook
          bindings:
    - ref: gitlab-push-binding
      template:
      ref: gitlab-trigger-template
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl apply -f 05-gitlab-event-listener.yaml

#查看eventlistener
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl get pods
NAME                                        READY   STATUS    RESTARTS   AGE
el-gitlab-event-listener-5ddd86b7f9-449pf   1/1     Running   0          44s
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl get svc el-gitlab-event-listener
NAME                       TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
el-gitlab-event-listener   ClusterIP   10.68.205.211   <none>        8080/TCP,9000/TCP   10m
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl get eventlistener	#内部访问地址
NAME                    ADDRESS                                                          AVAILABLE   REASON                     READY   REASON
gitlab-event-listener   http://el-gitlab-event-listener.default.svc.cluster.local:8080   True        MinimumReplicasAvailable   True


#创建service以选中eventlistener，用于外部访问
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat el-service.yaml
apiVersion: v1
kind: Service
metadata:
  labels:
    app.kubernetes.io/managed-by: EventListener
    app.kubernetes.io/part-of: Triggers
  name: el-gitlab-event-listener-02
  namespace: default
spec:
  ports:

  - name: http-listener
    port: 8080
    protocol: TCP
    targetPort: 8080
  - name: http-metrics
    port: 9000
    protocol: TCP
    targetPort: 9000
    selector:
    app.kubernetes.io/managed-by: EventListener
    app.kubernetes.io/part-of: Triggers
    type: NodePort
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# kubectl get svc
    NAME                          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                         AGE
    el-gitlab-event-listener      ClusterIP   10.68.205.211   <none>        8080/TCP,9000/TCP               20m
    el-gitlab-event-listener-02   NodePort    10.68.165.109   <none>        8080:58045/TCP,9000:40484/TCP   51s
    kubernetes                    ClusterIP   10.68.0.1       <none>        443/TCP                         11d
    注：event-listener外部访问地址：http://172.168.2.21:58045 

#gitlab UI上配置weebhook
进入项目webhook -> 填入地址http://172.168.2.21:58045 -> 输入上面的token: DXeqvozMlTA67aQB -> 勾选 'Push Event' -> 取消勾选ssl验证并确定

#测试是否可以运行克隆gitlab和列出文件
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/02-trigger-gitlab# cat test.yaml
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  name: gitlab-run-00001
spec:
  serviceAccountName: tekton-triggers-gitlab-sa
  params:
    - name: git-revision
      value: master
    - name: git-repo-url
      value: http://gitlab.hs.com/0799/helloWorld.git
  workspaces:
    - name: source
      emptyDir: {}
  taskSpec:
    params:
      - name: git-revision
      - name: git-repo-url
    workspaces:
      - name: source
    steps:
      - name: fetch-from-git-repo
        image: 192.168.13.197:8000/gitops/tekton/git-alpine:v2.32.0
        script: git clone -v $(params.git-repo-url) $(workspaces.source.path)/source
      - name: list-files
        image: 192.168.13.197:8000/gitops/alpine:3.15
        script: ls -la $(workspaces.source.path)/source

#测试trigger事件，在gitlab模拟push event或者在仓库中push代码，随后去taskRun中查看结果


###TektonTrigger实战案例

#访问私有gitlab仓库，sa需要绑定特定secret
------#创建secret
----Basic Auth:
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-project-basic-auth
type: Opaque
stringData:
  username: "uaername"
  password: "password"
----ssh Auth:
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-project-ssh-auth
type: Opaque
stringData:
  ssh-privatekey: |
    .....
  known_hosts: |
    .....
----or
kubectl create secret generic gitlab-project-basic-auth username="username" password="password"
kubectl create secret generic gitlab-project-ssh-auth --from-file=ssh-privatekey=/PATH/TO/PRIVATEKEY-FILE --from-file=known_hosts=/PATH/TO/KNOWN_HOST-FILE

------创建sa
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-triggers-gitlab-auth-sa
secrets:

- name: gitlab-project-ssh-auth

----代码片段
    kind: PipelineRun
    spec:
      serviceAccountNames:
        - taskName: gitlab-clone								#指定task上使用
          serviceAccountName: tekton-triggers-gitlab-auth-sa	#然后这里引用即可
注：以上就可以clone私有仓库的代码了


##实现PipelineRun的TektonTrigger
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 01-gitlab-token-secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: gitlab-webhook-token
type: Opaque
stringData:

  # Generated by command "openssl rand -base64 12"

  webhookToken: "DXeqvozMlTA67aQB"
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 02-gitlab-eventlistener-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tekton-triggers-gitlab-sa
secrets:

- name: gitlab-webhook-token

---

kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tekton-triggers-gitlab-minimal
rules:

  # Permissions for every EventListener deployment to function

  - apiGroups: ["triggers.tekton.dev"]
    resources: ["eventlisteners", "triggerbindings", "triggertemplates"]
    verbs: ["get"]

  - apiGroups: [""]

    # secrets are only needed for Github/Gitlab interceptors, serviceaccounts only for per trigger authorization

    resources: ["configmaps", "secrets", "serviceaccounts"]
    verbs: ["get", "list", "watch"]

  # Permissions to create resources in associated TriggerTemplates

  - apiGroups: ["tekton.dev"]
    resources: ["pipelineruns", "pipelineresources", "taskruns"]
    verbs: ["create"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tekton-triggers-gitlab-binding
subjects:

  - kind: ServiceAccount
    name: tekton-triggers-gitlab-sa
      roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: Role
    name: tekton-triggers-gitlab-minimal

---

kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: tekton-triggers-gitlab-minimal
rules:

  - apiGroups: ["triggers.tekton.dev"]
    resources: ["clusterinterceptors"]
    verbs: ["get","list"]

---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tekton-triggers-gitlab-binding
subjects:

  - kind: ServiceAccount
    name: tekton-triggers-gitlab-sa
    namespace: default
    roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: tekton-triggers-gitlab-minimal
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 03-task-deploy-to-cluster-rbac.yaml

---

apiVersion: v1
kind: ServiceAccount
metadata:

  name: helloworld-admin
---

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helloworld-admin
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:

- kind: ServiceAccount
  name: helloworld-admin
  namespace: default
  root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 04-pvc-manen-cache.yaml
  apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
  name: maven-cache
  spec:
  accessModes:
  - ReadWriteMany
    resources:
    requests:
      storage: 5Gi
    storageClassName: nfs-csi
    volumeMode: Filesystem
    root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 05-tasks-source-to-image.yaml

# Maintainer: MageEdu "<mage@magedu.com>"

# Version: v1.0.1

---

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
spec:
  description: Clone the code repository to the workspace.
  params:
    - name: git-repo-url
      type: string
      description: git repository url to clone
    - name: git-revision
      type: string
      description: git revision to checkout (branch, tag, sha, ref)
  workspaces:
    - name: source
      description: The git repo will be cloned onto the volume backing this workspace
  steps:
    - name: git-clone
      image: 192.168.13.197:8000/gitops/tekton/git-alpine:v2.32.0
      script: |
        git clone -v $(params.git-repo-url) $(workspaces.source.path)/source

        cd $(workspaces.source.path)/source && git reset --hard $(params.git-revision)
---

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: build-to-package
spec:
  description: build application and package the files to image
  workspaces:
    - name: source
      description: The git repo that cloned onto the volume backing this workspace
  steps:
    - name: build
      image: 192.168.13.197:8000/gitops/tekton/maven:3.8-openjdk-11-slim
      workingDir: $(workspaces.source.path)/source
      volumeMounts:
        - name: m2
          mountPath: /root/.m2
      script: mvn clean install
  volumes:
    - name: m2
      persistentVolumeClaim:

        claimName: maven-cache
---

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: generate-build-id
spec:
  params:
    - name: version
      description: The version of the application
      type: string
  results:
    - name: datetime
      description: The current date and time
    - name: buildId
      description: The build ID
  steps:
    - name: generate-datetime
      image: 192.168.13.197:8000/gitops/admin-box:v1.2
      script: |
        #!/usr/bin/env bash
        datetime=`date +%Y%m%d-%H%M%S`
        echo -n ${datetime} | tee $(results.datetime.path)
    - name: generate-buildid
      image: 192.168.13.197:8000/gitops/admin-box:v1.2
      script: |
        #!/usr/bin/env bash
        buildDatetime=`cat $(results.datetime.path)`
        buildId=$(params.version)-${buildDatetime}

        echo -n ${buildId} | tee $(results.buildId.path)
---

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: image-build-and-push
spec:
  description: package the application files to image
  params:
    - name: dockerfile
      description: The path to the dockerfile to build (relative to the context)
      default: Dockerfile
    - name: image-url
      description: Url of image repository
    - name: image-tag
      description: Tag to apply to the built image
  workspaces:
    - name: source
    - name: dockerconfig
      mountPath: /kaniko/.docker
  steps:
    - name: image-build-and-push
      image: 192.168.13.197:8000/gitops/tekton/kaniko-project/executor:debug
      securityContext:
        runAsUser: 0
      env:
        - name: DOCKER_CONFIG
          value: /kaniko/.docker
      command:
        - /kaniko/executor
      args:
        - --dockerfile=$(params.dockerfile)
        - --context=$(workspaces.source.path)/source
        - --destination=$(params.image-url):$(params.image-tag)

        - --insecure-registry=192.168.13.197:8000
---

apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-using-kubectl
spec:
  workspaces:
    - name: source
      description: The git repo
  params:
    - name: deploy-config-file
      description: The path to the yaml file to deploy within the git source
    - name: image-url
      description: Image name including repository
    - name: image-tag
      description: Image tag
  steps:
    - name: update-yaml
      image: 192.168.13.197:8000/gitops/alpine:3.15
      command: ["sed"]
      args:
        - "-i"
        - "-e"
        - "s@__IMAGE__@$(params.image-url):$(params.image-tag)@g"
        - "$(workspaces.source.path)/source/deploy/$(params.deploy-config-file)"
    - name: run-kubectl
      image: 192.168.13.197:8000/gitops/tekton/k8s-kubectl:latest
      command: ["kubectl"]
      args:
        - "apply"
        - "-f"

        - "$(workspaces.source.path)/source/deploy/$(params.deploy-config-file)"
---

root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 06-pipeline-source-to-image.yaml
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: source-to-image
spec:
  params:
    - name: git-repo-url
      type: string
      description: git repository url to clone
    - name: git-revision
      type: string
      description: git revision to checkout (branch, tag, sha, ref)
      default: main
    - name: image-build-context
      description: The path to the build context, used by Kaniko - within the workspace
      default: .
    - name: image-url
      description: Url of image repository
    - name: version
      description: The version of the application
      type: string
      default: "v0.9"
    - name: deploy-config-file
      description: The path to the yaml file to deploy within the git source
      default: all-in-one.yaml
  results:
    - name: datetime
      description: The current date and time
    - name: buildId
      description: The build ID
  workspaces:
    - name: codebase
    - name: docker-config
  tasks:
    - name: git-clone
      taskRef:
        name: git-clone
      params:
        - name: git-repo-url
          value: "$(params.git-repo-url)"
        - name: git-revision
          value: "$(params.git-revision)"
      workspaces:
        - name: source
          workspace: codebase
    - name: build-to-package
      taskRef:
        name: build-to-package
      workspaces:
        - name: source
          workspace: codebase
      runAfter:
        - git-clone
    - name: generate-build-id
      taskRef:
        name: generate-build-id
      params:
        - name: version
          value: "$(params.version)"
      runAfter:
        - git-clone
    - name: image-build-and-push
      taskRef:
        name: image-build-and-push
      params:
        - name: image-url
          value: "$(params.image-url)"
        - name: image-tag
          value: "$(tasks.generate-build-id.results.buildId)"
      workspaces:
        - name: source
          workspace: codebase
        - name: dockerconfig
          workspace: docker-config
      runAfter:
        - generate-build-id
        - build-to-package
    - name: deploy-to-cluster
      taskRef:
        name: deploy-using-kubectl
      workspaces:
        - name: source
          workspace: codebase
      params:
        - name: deploy-config-file
          value: $(params.deploy-config-file)
        - name: image-url
          value: $(params.image-url)
        - name: image-tag
          value: "$(tasks.generate-build-id.results.buildId)"
      runAfter:
        - image-build-and-push
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 07-gitlab-push-binding.yaml
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: s2i-binding
spec:
  params:

  - name: git-revision
    value: $(body.checkout_sha)
  - name: git-repo-url
    value: $(body.repository.git_http_url)
  - name: image-url
    value: 192.168.13.197:8000/k8s-test/helloworld-test
  - name: version
    value: v0.9
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 08-gitlab-triggertemplate-s2i.yaml
      apiVersion: triggers.tekton.dev/v1beta1
      kind: TriggerTemplate
      metadata:
    name: s2i-tt
      spec:
    params:  # 定义参数
  - name: git-revision
  - name: git-repo-url
  - name: image-url
  - name: version
    resourcetemplates:
  - apiVersion: tekton.dev/v1beta1
    kind: PipelineRun
    metadata:
      generateName: s2i-trigger-run-  # TaskRun 名称前缀
    spec:
      serviceAccountNames:
        - taskName: deploy-to-cluster
          serviceAccountName: helloworld-admin
      pipelineRef:
        name: source-to-image
      params:
        - name: git-repo-url
          value: $(tt.params.git-repo-url)
        - name: git-revision
          value: $(tt.params.git-revision)
        - name: image-url
          value: $(tt.params.image-url)
        - name: version
          value: $(tt.params.version)
      workspaces:
        - name: codebase
          volumeClaimTemplate:
            spec:
              accessModes:
                - ReadWriteOnce
              resources:
                requests:
                  storage: 1Gi
              storageClassName: nfs-csi
        - name: docker-config
          secret:
            secretName: docker-config
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# cat 09-gitlab-eventlister-s2i.yaml
      apiVersion: triggers.tekton.dev/v1beta1
      kind: EventListener
      metadata:
    name: s2i-listener
      spec:
    serviceAccountName: tekton-triggers-gitlab-sa
    triggers:
  - name: gitlab-push-events-trigger
    interceptors:
    - ref:
      name: "gitlab"
      params:
      - name: "secretRef"
        value:
          secretName: gitlab-webhook-token
          secretKey: webhookToken
      - name: "eventTypes"
        value: ["Push Hook"]
          bindings:
    - ref: s2i-binding
      template:
      ref: s2i-tt
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# kubectl apply -f .
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# kubectl get pods
      NAME                               READY   STATUS    RESTARTS   AGE
      el-s2i-listener-5c945b65d9-zgtjh   1/1     Running   0          82s
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# kubectl apply -f ../02-trigger-gitlab/el-service.yaml
      service/el-gitlab-event-listener-02 created
      root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# kubectl get svc
      NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                         AGE
      el-gitlab-event-listener-02   NodePort    10.68.54.164   <none>        8080:54356/TCP,9000:46583/TCP   1s
      el-s2i-listener               ClusterIP   10.68.23.204   <none>        8080/TCP,9000/TCP               29s
      kubernetes                    ClusterIP   10.68.0.1      <none>        443/TCP                         11d

#验证测试
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# tkn pipelinerun list
NAME                    STARTED         DURATION   STATUS
s2i-trigger-run-snf8q   2 minutes ago   1 minute   Succeeded
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# kubectl get pods -n hello -o wide
NAME                                      READY   STATUS    RESTARTS   AGE   IP              NODE           NOMINATED NODE   READINESS GATES
spring-boot-helloworld-6946d95f94-qw4ds   1/1     Running   0          14s   172.20.58.215   172.168.2.25   <none>           <none>
root@k8s-master01:~/tekton-and-argocd-in-practise/05-tekton-triggers/03-trigger-gitlab# curl 172.20.58.215
Hello Spring Boot 2.0!


#作业
作业1：使用Knative Eventing中的broker和trigger 实现gitlab的事件分类，并发送到不同的tekton中的EventListenerPod上，在请求量大的时候可以减轻EventListenerPod上的压力，并且可以实现不同的webhoo推送
作业2：使用Knative Serving将低频的业务部署上去，并借助istio服务网格(针对特定名称空间开启service mesh)将流量暴露出去。实现tekton+knative+istio+k8s功能
```



# ArgoCD



## ArgoCD概览

- Argo项目于2017年由Applatix公司创立，2018年初被Intuit收购
- 之后，BlackRock为Argo项目贡献了Argo Events这一子项目
- Argo及其子项目为Workflow、Trigger和Application的管理提供了一种简单便捷的方式
  - Argo的所有组件都通过专用的Kubernetes CRD实现
  - 支持使用或集成其它CNCF项目，如gRPC, Prometheus, NATS, Helm和CloudEvents等
- Argo生态目前主要由四个子项目组成
  - Argo Workflows
    - 第一个Argo项目
	  - 基于Kubernetes平台的原生工作流引擎，支持DAG和step-based工作流
  - Argo Events
    - Kubernetes上的基于事件的依赖管理器，用于触发Kubernetes中的Argo工作流和其它操作
  - ArgoCD
    - 由Argo社区和Intuit维护的开源项目
	  - 支持GitOps范式的声明式Kubernetes资源管理
  - Argo Rollouts
    - ArgoCD的高级交付策略工具
	  - 支持声明式渐进式交付策略，例如canary, blue-green等
	



## ArgoCD简介

- ArgoCD是什么？
  - 将应用程序部署到Kubernetes之上的GitOps工具
  - 核心组件：Application Controller及相关的一组CRD
  - 基础工作模型
    - 以特定Repository（配置仓库）为应用程序部署和管理的惟一可信源，该Repository负责定义Application的期望状态
	- 以Application Controller负责将Repository中定义的Application运行于一个特定的目标Kubernetes Cluster之上
	- Application Controller持续监视、对比Application的期望状态和实际状态，并确保实际状态与期望状态一致
	



## ArgoCD的主要功能

- 可协同使用各种配置管理工具（如ksonnet/jsonnet, helm, kustomize）确保应用程序的真实状态与GitRepo中定义的期望状态保持一致
- 将应用程序自动部署到指定的目标环境
- 持续监控已部署的应用程序
- 基于Web和CLI的操作接口，以及应用程序可视化
- 部署或回滚到GitRepo仓库中提交的应用程序的任何状态
- PreSync, Sync, PostSync Hooks以支持复杂的应用程序部署策略
  - 例如blue/green和canary upgrades
- SSO集成
  - 集成OIDC, LDAP, SAML 2.0, GitLab, Microsoft, LinkedIn等
- Weebhook集成
  - GitHub, BitBucket和GitLab
- 可以独立使用，也可以作为现有Pipeline的一部分使用，例如与Argo Workflow、Jenkins以及GitLab CI等配合使用

声明式配置
- Application CRD
  - 定义由ArgoCD管理的应用程序
  - 定义的这些应用程序受控于Application Controller
- ApplicationSet CRD
  - 以模板化形式自动生成由ArgoCD管理的应用程序
  - 支持从多个不同的角度构建模板，例如不同的Git Repo，或者不同的Kubernetes Cluster等
  - ApplicationSet受控于专用的Application Controller
- AppProject CRD
  - 为Application提供逻辑分组，同时提供如下功能
    - 限制可用部署的内容，例如指定受信任的Git Repository白名单
	- 限制应用程序可以部署到目标位置，包括目标集群和目标名称空间
	- 限制可以部署或者不能部署的资源类型，例如RBAC, CRD, DaemonSet等
  - 每个Application都必须隶属某个AppProject，未指定时，则隶属于名为"default"的默认项目
  - default项目可以被修改，但不能删除
  

核心工作模型
- ArgoCD的两个核心概念为Application和Project，它们可分别基于Application CRD和AppProject CRD创建
- Application
  - 从本质上来说，它包含如下两个部分
    - 一组在Kubernetes上部署和运行某个应用的资源配置文件
	- 这组资源相关的source和destination
	  - source: 定义从何处获取资源配置文件，包括repoURL和配置文件所在的目录
	  - destination: 定义这组资源配置文件中定义的对象应该创建并运行于何处，其中的Cluster可以是ArgoCD所在集群之外的其它集群
	- 支持的配置管理工具
	  - Helm、Kustomize、Jsonnet、Ksonnet
	- ArgoCD Application还存在两个非常重要的属性：Sync Status和Health Status
	- Sync Status：Application的实际状态与Git Repo中定义的期望状态是否一致
	  - Synced: 一致
	  - OutOfSync: 不一致
	- Health Status: Application的健康状态，是各资源的健康状态的聚合信息
	  - Healthy: 健康
	  - Processing: 处于尝试转为健康状态的进程中
	  - Degraded: 降级
	  - Missing: 缺失，即在GitRepo中存在资源定义，但并未完成部署
- Project
  - 能够将Application进行分组的逻辑组件
  - 主要用于将租房或团队间的Application彼此隔离，并且支持在组内进行细粒度的权限管控
  - 支持为内部Application上的Source和Destination分别指定各自的黑白名单
  

ArgoCD程序组件
- ArgoCD API Server
  - ArgoCD Server API接口，为WebUI, CLI, 以及相关的CI/CD系统提供服务，相关功能包括
    - 管理应用程序并报告其状态
	- 调用并发起应用程序的特定操作，例如sync, rollback以及用户定义的其它行为
	- 管理Repository和Cluster相关的凭据
	- 将身份认证与授权功能委派给外部IdP（Identity Providers）服务
	- 强制实施RBAC
	- 监听及转发Git webhook相关的事件等
- Repository Server
  - 内部服务，用于为相关的Git仓库维护一个本地缓存
  - 负责根据以下输入生成和返回Kubernetes资源配置
    - repository URL, revision(commit,tag,branch)及application path等
	- template specific settings: parameters, ksonnet environments, helm values.yaml
- Application Controller
  - 负责为管理的目标应用程序提供遵循Kubernetes控制器模式的调谐循环
  - 它持续监视正在运行的应用程序，并将其当前的活动状态与定义在GitRepo中的期望状态进行比较
  - 确保活动状态不断逼近或等同于期望状态
- ApplicationSet Controller
  - 以模板化形式自动生成由ArgoCD管理的应用程序
  - 支持从多个不同的角度构建模板，例如不同的Git Repo，或者不同的Kubernetes Cluster等
  - ApplicationSet受控于专用的ApplicationSet Controller
- Notification Controller
  - 持续监控ArgoCD管理的Application，并支持通过多种不同的方式将其状态变化通知给用户
  - 支持Trigger和Template
- Redis和Dex-Server
  - Redis负责提供缓存服务
  - 而Dex-Server则主要用于提供in-memory Database
- Argo Rollouts
  - 可选组件，需要单独部署，由一个控制器和一组CRD组成
  - 与Ingress Controller和ServiceMesh集成，为Application提供高级部署功能，如blue-green, canary, canary analysis和渐进式交付等
- argocd-notifications-controller的功用
  - 为ArgoCD Application提供的通用通知引擎，支持十多种通知机制的开箱即用
  - 支持Trigger和Template，允许用户灵活地配置通知机制而无须修改程序源代码
  



## ArgoCD快速入门

ArgoCD的部署要点

- ArgoCD有两种部署方式：多租户部署和核心化部署
- 多租户（推荐这种）
  - 常用于为多个应用程序开发团队提供服务，并由平台团队维护的场景
  - 有两类可选择的部署方式
    - 非高可用性部署：适用于演示和测试的目的
	  - 高可用部署：适用于生产用途（吃资源，结合生产环境性能）
  - 支持用户通过Web UI或CLI进行访问
  - 支持集群级别部署和名称空间级两种安装机制
    - 配置文件install.yaml: 具有集群管理员访问权限的集群级安装
	  - 配置文件namespace-install.yaml: 仅需要名称空间级别权限的安装
- 核心化部署
  - 安装的组件较小且更易于维护，它不包含APIServer和UI，且不提供高可用机制
  - 仅适用于独立使用ArgoCD且不需要多租户特性的集群管理员
  - 用户要通过Kubernetes的访问权限来管理ArgoCD
  
	

## ArgoCD多租户非高可用性部署（集群级别）步骤

- 在Kubernetes集群上部署ArgoCD
  - 采用的示例环境
    - 集群级别的部署
	- 非高可用模式
  - 默认的部署配置使用argocd名称空间，资源引用的路径亦使用该名称空间
    - kubectl create namespace argocd
	  - kubectl apply -n argocd -f https://ARGOCD-CONFIG-FILE-ADDRES
- 在管理节点上安装ArgoCD CLI
- 将ArgoCD API Server相关的Service暴露到集群外部
  - LoadBalancer Service、Ingress或者Port Forwarding
- 使用ArgoCD CLI或Web UI完成登录
  - 默认密码：kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d;echo
  - 登录：argocd login <ARGOCD_SERVER>
  - 修改密码：argocd account update-password
- 添加一个部署Application的目标Kubernetes Cluster
  - Application部署的目标集群与ArgoCD自身在同一集群时，该步骤可选
  



## 部署
文档地址：https://argo-cd.readthedocs.io/en/stable/getting_started/

```bash
root@k8s-master01:~# kubectl get nodes
NAME           STATUS                     ROLES    AGE   VERSION
172.168.2.21   Ready,SchedulingDisabled   master   13d   v1.23.1
172.168.2.24   Ready                      node     13d   v1.23.1
172.168.2.25   Ready                      node     13d   v1.23.1
root@k8s-master01:~# kubectl create namespace argocd
#root@k8s-master01:~# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml #非高可用
#kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.3.4/manifests/ha/install.yaml	#高可用
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argocd# kubectl apply -f install.yaml -n argocd	#这里安装非高可用
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argocd# kubectl get pods -n argocd
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          8m45s
argocd-applicationset-controller-79f97597cb-ng9k4   1/1     Running   0          8m48s
argocd-dex-server-6fd8b59f5b-2slpq                  1/1     Running   0          8m48s
argocd-notifications-controller-5549f47758-9whj8    1/1     Running   0          8m48s
argocd-redis-79bdbdf78f-zg4h8                       1/1     Running   0          8m47s
argocd-repo-server-5569c7b657-vrc9t                 1/1     Running   0          8m47s
argocd-server-664b7c6878-h8qcj                      1/1     Running   0          8m46s

root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argocd# kubectl get svc -n argocd
NAME                                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
argocd-applicationset-controller          ClusterIP   10.68.193.119   <none>        7000/TCP                     83s
argocd-dex-server                         ClusterIP   10.68.53.60     <none>        5556/TCP,5557/TCP,5558/TCP   83s
argocd-metrics                            ClusterIP   10.68.255.5     <none>        8082/TCP                     83s
argocd-notifications-controller-metrics   ClusterIP   10.68.1.136     <none>        9001/TCP                     83s
argocd-redis                              ClusterIP   10.68.150.74    <none>        6379/TCP                     82s
argocd-repo-server                        ClusterIP   10.68.54.144    <none>        8081/TCP,8084/TCP            82s
argocd-server                             ClusterIP   10.68.98.231    <none>        80/TCP,443/TCP               81s	#暴露UI和ArgoCD API
argocd-server-metrics                     ClusterIP   10.68.247.53    <none>        8083/TCP                     81s

root@k8s-master01:~# kubectl api-resources --api-group=argoproj.io
NAME                       SHORTNAMES         APIVERSION             NAMESPACED   KIND
applications               app,apps           argoproj.io/v1alpha1   true         Application
applicationsets            appset,appsets     argoproj.io/v1alpha1   true         ApplicationSet
appprojects                appproj,appprojs   argoproj.io/v1alpha1   true         AppProject



#部署istio，把ArgoCD service argocd-server 暴露出去
--部署istio，省略
--暴露服务
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argocd# cat 02-argocd-dashboard-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: argocd-dashboard-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:
    - hosts:
        - "argocd.magedu.com"
      port:
        number: 80
        name: http
        protocol: HTTP
      tls:
        httpsRedirect: true
    - hosts:
        - "argocd.magedu.com"
      port:
        number: 443
        name: https
        protocol: HTTPS
      tls:
        mode: PASSTHROUGH	#透传，相当于四层代理
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: argocd-dashboard-virtualservice
  namespace: argocd
spec:
  hosts:
  - "argocd.magedu.com"
    gateways:
  - istio-system/argocd-dashboard-gateway
    tls:
  - match:
    - port: 443
      sniHosts:
      - argocd.magedu.com
        route:
    - destination:
      host: argocd-server
      port:
        number: 443
      root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argocd# kubectl apply -f 02-argocd-dashboard-virtualservice.yaml
      root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argocd# kubectl get svc -n istio-system
      NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                      AGE
      istio-ingressgateway   LoadBalancer   10.68.162.21   172.168.2.28   15021:59630/TCP,80:48809/TCP,443:46900/TCP   45h
      istiod                 ClusterIP      10.68.9.121    <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP        45h

--WebUI访问：https://argocd.magedu.com	#此时密码需要借助于CLI，下面安装

#安装ArgoCD CLI
Download:  https://github.com/argoproj/argo-cd/releases/latest
root@front-envoy:~# curl -OL https://github.com/argoproj/argo-cd/releases/download/v2.3.4/argocd-linux-amd64
root@front-envoy:~# scp argocd-linux-amd64 root@172.168.2.21:/usr/local/bin/argocd
root@k8s-master01:~# chmod +x /usr/local/bin/argocd
----更改默认密码
root@k8s-master01:~# kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d;echo
uVxR7QFXPOaknsIv	#获取的密码
root@k8s-master01:~# argocd login 10.68.98.231	#登录argocd-server
WARNING: server certificate had error: x509: cannot validate certificate for 10.68.98.231 because it doesn't contain any IP SANs. Proceed insecurely (y/n)? y
Username: admin		#用户名admin
Password:			#输入默认密码
'admin:login' logged in successfully
Context '10.68.98.231' updated
root@k8s-master01:~# argocd account update-password		#更新当前登录用户的密码
*** Enter password of currently logged in user (admin):		#输入当前登录的默认密码
*** Enter new password for user admin:						#设定新密码，这里是magedu.com
*** Confirm new password for user admin:
Password updated
Context '10.68.98.231' updated
注：新密码设定好后就可以登录到ArgoCD UI界面了

#注：在UI上添加凭据时可以是用户ssh key或deploy key如果报错，请添加known_hosts，必须是centos系统，ubuntu系统有问题
argocd repo add git@gitlab.hs.com:kubernetes/netcore.git --ssh-private-key-path ~/.ssh/id_rsa

##使用ArgoCD
项目地址：https://gitee.com/mageedu/spring-boot-helloworld-deployment
clone推送到自己仓库：https://gitee.com/jacknotes/spring-boot-helloworld-deployment

root@front-envoy:~/spring-boot-helloworld-deployment/deploy/kubernetes# cat 01-service.yaml
---

kind: Service
apiVersion: v1
metadata:
  name: spring-boot-helloworld
  labels:
    app: spring-boot-helloworld
spec:
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
  selector:
    app: spring-boot-helloworld
root@front-envoy:~/spring-boot-helloworld-deployment/deploy/kubernetes# cat 02-deployment.yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: spring-boot-helloworld
  labels:
    app: spring-boot-helloworld
spec:
  replicas: 3
  selector:
    matchLabels:
      app: spring-boot-helloworld
  template:
    metadata:
      name: spring-boot-helloworld
      labels:
        app: spring-boot-helloworld
    spec:
      containers:
      - name: spring-boot-helloworld
        image: ikubernetes/spring-boot-helloworld:v0.9.4	#修改版本为v0.9.4并推送
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
root@front-envoy:~/spring-boot-helloworld-deployment/kubernetes# git add -A && git commit -m "version v0.9.4" && git push
注：此时去gitee确认仓库版本是否同步，并将仓库配置为公共仓库
```



## 配置ArgoCD

1. 进入ArgoCD UI界面-- 'manager your repository,projects,settings' -- 可以添加repository(私用或公有仓库，如果公有仓库这里可不添加)，查看cluster(默认会有in cluster，是argo所属集群)，查看project(默认有一个default，可以创建新project name，用于分类管理项目，实现项目中的名称空间、资源类型等限制) 
2. 我们添加公有仓库，直接到 'manager your applications,and diagnose health problems' -- 'new app'
3. 配置app信息：设定'application name'为"spring-boot-helloworld" -- 'project'为default -- 'sync policy'为automatic，并勾选'self heal'(自愈)， 'PRUNE RESOURCES'这个看自己情况是否勾选,作用是当git config repo仓库中没有项目时是否自动删除k8s中已经存在的资源， 'sync options'勾选"AUTO-CREATE NAMESPACE"(自动创建名称空间) -- ‘SOURCE’填入公有仓库地址"https://gitee.com/jacknotes/spring-boot-helloworld-deployment.git"并选择Branch为HEAD，Path为“deploy/kubernetes”(表示此目录下为此项目的yaml配置清单) -- 'DESTINATION'为in-cluster，表示部署在哪个集群，名称空间为'helloworld'(不存在会创建，上面已经勾选自动创建) -- 最后保存

```bash
#配置保存即运行
root@k8s-master01:~# kubectl get pods  -n helloworld
NAME                                      READY   STATUS    RESTARTS   AGE
spring-boot-helloworld-86d6866454-ldbpl   1/1     Running   0          2m48s
spring-boot-helloworld-86d6866454-n5g2m   1/1     Running   0          2m45s
spring-boot-helloworld-86d6866454-x9mcm   1/1     Running   0          3m54s
root@k8s-master01:~# kubectl get svc -n helloworld
NAME                     TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
spring-boot-helloworld   ClusterIP   10.68.178.165   <none>        80/TCP    19m

root@k8s-master01:~# argocd app list	#此命令也可以列出
NAME                    CLUSTER                         NAMESPACE   PROJECT  STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                               PATH               TARGET
spring-boot-helloworld  https://kubernetes.default.svc  helloworld  default  Synced  Healthy  Auto-Prune  <none>      https://gitee.com/jacknotes/spring-boot-helloworld-deployment.git  deploy/kubernetes  HEAD
root@k8s-master01:~# kubectl get application -n argocd	#application默认部署在argocd名称空间上
NAME                     SYNC STATUS   HEALTH STATUS
spring-boot-helloworld   Synced        Healthy


#测试
root@k8s-master01:~# kubectl run client $RAMDOM --image ikubernetes/admin-box:v1.2 --rm -it --restart Never --command -- /bin/bash
If you don't see a command prompt, try pressing enter.
root@client /# while true;do curl spring-boot-helloworld.helloworld/version;echo; sleep 0.$RANDOM;done
version 0.9.2
version 0.9.2
version 0.9.2
version 0.9.2

--更改版本为 image: ikubernetes/spring-boot-helloworld:v0.9.5
root@front-envoy:~/spring-boot-helloworld-deployment/deploy/kubernetes# git add -A && git commit -m "v0.9.5" && git push
root@client /# while true;do curl spring-boot-helloworld.helloworld/version;echo; sleep 0.$RANDOM;done
version 0.9.5
version 0.9.5
version 0.9.5
注：argoCD这样配置在版本迭代时会有失败的请求

--命令行删除applications，此时相应的pod和service都将被删除，使用kubectl命令删除则不会
root@k8s-master01:~# argocd app delete spring-boot-helloworld

--命令行添加application
root@k8s-master01:~# argocd app create spring-boot-helloworld --repo https://gitee.com/jacknotes/spring-boot-helloworld-deployment.git --path deploy/kubernetes --dest-namespace helloworld --dest-server https://kubernetes.default.svc --sync-policy automated --self-heal
application 'spring-boot-helloworld' created

--命令行添加其它集群
root@k8s-master01:~/argocd/cluster# argocd cluster add context-fat-cluster --kubeconfig config --name fat-cluster	#config是k8s管理员用户kubeconfig文件，在~/.kube/config
WARNING: This will create a service account `argocd-manager` on the cluster referenced by context `context-fat-cluster` with full cluster level admin privileges. Do you want to continue [y/N]? y
INFO[0001] ServiceAccount "argocd-manager" created in namespace "kube-system"
INFO[0001] ClusterRole "argocd-manager-role" created
INFO[0001] ClusterRoleBinding "argocd-manager-role-binding" created
Cluster 'https://172.168.2.31:6443' added

root@k8s-master01:~/argocd/cluster# argocd cluster list	#此时fat-cluster还未部署application状态所以是unknow
SERVER                          NAME         VERSION  STATUS      MESSAGE                                              PROJECT
https://172.168.2.31:6443       fat-cluster           Unknown     Cluster has no application and not being monitored.
https://kubernetes.default.svc  in-cluster   1.23     Successful

root@k8s-master01:~/argocd/cluster# argocd cluster list	#此时fat-cluster部署了application状态所以是Successful
SERVER                          NAME         VERSION  STATUS      MESSAGE  PROJECT
https://172.168.2.31:6443       fat-cluster  1.23     Successful
https://kubernetes.default.svc  in-cluster   1.23     Successful


----gitlab添加webhook触发argoCD
Documentation: https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/
uv6uHEyPI6Xbvh7I4b5tDfdNs1bBBtOL	#生成secret，用于访问argoCD

kubectl edit secret argocd-secret -n argocd-secret	#编辑argocd-secret添加gitlab添加的secret
type: Opaque
stringData:
  webhook.gitlab.secret: uv6uHEyPI6Xbvh7I4b5tDfdNs1bBBtOL	#增加此行

----添加基于SSH的gitlab认证
# 下面为创建多个存储库示例,使用同一个凭据
root@k8s-master01:~# cat argocd-secret-ssh-template.yaml
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-000001
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy/frontend-www-homsom-com-test.git
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-000002
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy/frontend-www-homsom-com.git
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-000003
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: git@gitlab.hs.com:k8s-deploy/java-flightrefund-order-service-hs-com.git
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
    NiGUM3SuWhkU9c0zPif0OAN2lJHDU3EDe8Wwy1lI5VNDJuUKyDZUfd2riOczzV/E
    xePoswcCqgLfxO674ywOOPcmA2zQS6m9fB+QusQG6M6UjN2agQ+jPM4I4vpLdmpK
    pflEf/DIuPvjIrN0M/4xXcdDVfDHJV256OHcsCfidybXzx1a1F9bDPCcEACZi5Uh
    J+gGQEECgYEAx5CX1bHKI6X4SyDY7ibCXccesBjNPC3022xOLx2ciqq3T4LtefSN
    ej6CuHSc1DIhbUWeKQkPDByXFGZ8EDHDSm7Rm39ZmgXYdpf/qpLzXdVbPW17mBw3
    EwmUvvxIA8Zauf8HvGgkD9+0bkgFhh90dmMy8yNvdULLdD8DqEMzMbkCgYEAxaHy
    jPSfKWaRqseciLbCW6MwAcYb3knCz7UXsOhWeTCEaiAKg3KwrIKT81BTtGitZMMB
    cLV+AA9Ta2troM9xmoRQMQyBhjlHXpU3RQEjlG8xKaabFFnOoY6DYl1Gsy3xamQ4
    SKalSG3wrQN/UkeqSrSAXddHnXABiEJgdVeqaDkCgYBf6qw/hls8dQn4ugnptPFY
    d1rVkqYaFZCJYe3WEWpq75B5g9k184eISME1fL7f8lREm+Bfor37uUYYBQX+Fpzh
    io/uJ/Bd6g9XOMkmJ8kWwXQ/+v4bZvxFhyZaARFv1wdGPEBwmrEye/fRxYX6J+Ym
    /JjBabepaXg2IA9W8S2K6QKBgQCDeT7wQnP3iMJzCCO8V0hoyeDP7Ujw0cUFhIVk
    LMwKBxqvtu0HkS6zNJLUFKX6qIBhPdEhd7uAsrFeDrIk4pvCnS7z0kwATO6Ln1yL
    TTysLGRaPvl/ylbJ5xLERyUXYgLuMgm3WxUtX+XyUxdKV16UIAwdYW/E7pQ2X2Hn
    7g/xEQKBgHtPOeB7YaTvTwKZVUGiZcSA0WzTkzjUOIN165K+XO9qEM5Tvj0892bA
    ld2nd6oESKvosa29+laflkdyNT3wGNtA/nfSG1bHkg/VIve5fnvN8LFlAbCOJwCf
    C1iUM1zDoIZ4oggXlvRRhMT4o5AMYJ91t00DM+Nm6ir8E9n4nZb2
    -----END RSA PRIVATE KEY-----
    
    
--声明式配置applicaion
root@k8s-master01:~# kubectl get application -o yaml -n argocd  > application.yaml
root@k8s-master01:~# vim application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: spring-boot-helloworld
  annotations:
    argocd.argoproj.io/sync-options: Validate=false
  namespace: argocd
spec:
  destination:
    namespace: helloworld
    server: https://kubernetes.default.svc
  project: default
  source:
    path: deploy/kubernetes
    repoURL: https://gitee.com/jacknotes/spring-boot-helloworld-deployment.git
  syncPolicy:
    automated:
      selfHeal: true
    syncOptions:
    - ApplyOutOfSyncOnly=true
    - CreateNamespace=true
root@k8s-master01:~# kubectl apply -f application.yaml
```




同步选项
- 同步选项（Sync Options）用于禁用或启用同步过程中的某些特性
  - ApplicationOutOfSyncOnly
    - 仅对那些处于OutOfSync状态的资源执行同步操作
  - PrunePropagationPolicy
    - 资源修剪传播策略，默认使用foreground策略
	- 另外可选的策略还有background和orphan
  - PruneLast
    - 在同步操作的最后再执行修剪操作，即其它资源已经部署且转为健康状态后再进行Prune
  - Replace
    - 对资源的修改，以replace方式进行，而非默认的apply
  - FailOnShareResource
    - 默认的同步操作不会考虑GitRepo中定义的资源是否已经被其它Application所使用
	- 将该选项设置为true，意味着在发现资源已经被其它Application所使用时，则将同步状态设置为fail
  - RespectIgnoreDifferences
    - 在同步阶段忽略期望状态的字段
  - CreateNamespace
    - 创建缺失的名称空间
  - Validation
    - 是否执行资源规范格式的校验，相当于"kubectl applly --validate={true|false}"，默认为true

关于Projects CRD
- Projects负责为Application提供逻辑分组，它主要实现如下功能
  - 限制可以部署的内容（指定受信任的Git Source仓库）
  - 限制Application可以部署到的目标位置（指定目标Cluster和Namespace）
  - 限制能够及不能够部署的对象类型，例如RBAC, CRD, DeamonSets, NetworkPolicy等
  - 定义Project Role，从而为Application提供RBAC机制，以绑定到OIDC组或JWT token
- ArgoCD的默认项目
  - default project由ArgoCD自动部署，它允许用户按需修改，但不能被删除
  root@k8s-master01:~# kubectl get appprojects default -o yaml -n argocd
  apiVersion: argoproj.io/v1alpha1
  kind: AppProject
  metadata:
  creationTimestamp: "2022-05-21T10:24:19Z"
  generation: 1
  name: default
  namespace: argocd
  resourceVersion: "1332622"
  uid: abd66d11-af5c-4c1e-9bb1-5be7cc09ffd0
  spec:
  clusterResourceWhitelist:	#允许部署任意资源类型的资源 
  - group: '*'		#api群组
    kind: '*'		#api群组下的资源类型
    destinations:		#允许将Application部署至任意目标Cluster和Namespace
  - namespace: '*'	#apiserver名称空间
    server: '*'		#apiserver地址
    sourceRepos:		#允许从任意Source Repo获取资源配置
  - '*'				#source repo地址

关于ApplicationSet CRD
- ApplicationSet CRD
  - ApplicationSet CRD用于定义可自动生成Application的模板，从而能够在monorepo（单个Repo中定义了多个ArgoCD Application）或多个Repo，以及跨大量Cluster的场景中自动化管理ArgoCD Application
  - ApplicationSet CRD需要同其专用的ApplicationSet控制器支撑实现
    - ApplicationSet控制器是ArgoCD的独立子项目，会随同ArgoCD一起部署
- ApplicationSet可提供如下功能
  - 目标Cluster的模板化，从而能够在单个资源配置文件中适配部署到多个Kubernetes集群
  - 源Git配置仓库的模板化
  - 较好地支持monorepo
- 注：ApplicationSet由Generator和Application模板组成，Generator生成KV参数，这些参数能够替换到Application模板中生成Application配置

ApplicationSet CRD资源规范
- ApplicationSet CRD资源规范遵循Kubernetes Resource API规范，其spec支持内嵌如下三个字段
  - generators <[]Object>
    - 定义负责生成参数的生成器，这些参数会被用于渲染template字段中定义的模板
	- 生成器的关键作用在于，它们是模板参数的数据源
	- ApplicationSet支持多种不同类型的generator
  - syncPolicy  <Object>
    - 资源同步策略
	- 仅支持内嵌一个布尔型字段preserveResourceOnDeletion
  - template  <Object>
    - Application资源模板，配置格式与Application规范相同，但它含有一些能数化的配置
	- 通过将这些参数替换为generators生成的"值"完成模板的实例化
	

ApplicationSet资源示例
- helloworld Application示例
  - 使用了列表生成器（list generator)
    - 有三个元素，分别为environment参数传递不同的值
	- 该参数既作为配置文件获取位置，也是目标集群上的名称空间
  - Application模板
    - 给出了模板化的source
	- 定义了模板化的destination
	- 定义了共用的syncPolicy
  - ApplicationSet的syncPolicy
    - preserveResourcesOnDeletion: 是否在删除当前ApplicationSet资源时，一并删除由其创建的Application，即是否执行级联删除操作
- 目前，有七种不同的generator可用，常用的有如下4个
  - List Generator
  - Cluster Generator
  - Git Generator
  - Matrix Generator（可以交叉组合git和cluster，实现更高级的组合）

示例配置

```bash
root@k8s-master01:~# argocd app delete spring-boot-helloworld
Are you sure you want to delete 'spring-boot-helloworld' and all its resources? [y/n]
y
root@k8s-master01:~/tekton-and-argocd-in-practise/07-argocd-basics# cat 02-applicationset-demo.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: helloworld
  namespace: argocd		#必须部署在argocd名称空间，因为applicationset控制器也在argocd名称空间
spec:
  generators:
  - list:
    elements:
    - environment: dev		#元素列表
    - environment: staging
    - environment: prod
      template:
      metadata:
      name: '{{environment}}-spring-boot-helloworld'	#引用元素列表，会跟下面的一一对应,#例如引用dev
      spec:
      project: default
      source:
        repoURL: https://gitee.com/jacknotes/spring-boot-helloworld-deployment.git
        targetRevision: HEAD
        path: helloworld/{{environment}}	#例如引用dev
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{environment}}'	#例如引用dev
      syncPolicy:			#同步策略每个application都一样
        automated:
          prune: true
          selfHeal: true
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
            syncPolicy:
          preserveResourcesOnDeletion: false
            root@k8s-master01:~/tekton-and-argocd-in-practise/07-argocd-basics# kubectl apply -f 02-applicationset-demo.yaml
            root@k8s-master01:~/tekton-and-argocd-in-practise/07-argocd-basics# kubectl get application -n argocd	此时自动生成3个application
            NAME                             SYNC STATUS   HEALTH STATUS
            dev-spring-boot-helloworld       Synced        Progressing
            prod-spring-boot-helloworld      Synced        Progressing
            staging-spring-boot-helloworld   Synced        Progressing
            root@k8s-master01:~/tekton-and-argocd-in-practise/07-argocd-basics# kubectl get pods -n dev
            NAME                                      READY   STATUS    RESTARTS   AGE
            spring-boot-helloworld-6fcf674d56-788vs   1/1     Running   0          108s
            root@k8s-master01:~/tekton-and-argocd-in-practise/07-argocd-basics# kubectl get pods -n staging
            NAME                                      READY   STATUS    RESTARTS   AGE
            spring-boot-helloworld-5d65c967db-sggx5   1/1     Running   0          115s
            root@k8s-master01:~/tekton-and-argocd-in-practise/07-argocd-basics# kubectl get pods -n prod
            NAME                                      READY   STATUS    RESTARTS   AGE
            spring-boot-helloworld-5d65c967db-6vcrs   1/1     Running   0          2m1s
            spring-boot-helloworld-5d65c967db-7rdp4   1/1     Running   0          2m1s
            spring-boot-helloworld-5d65c967db-dxkpz   1/1     Running   0          2m1s
            注：配置清单放在gitlab上，生成application使用applicationSet生成

root@k8s-master01:~# kubectl delete applicationsets helloworld -n argocd	#删除application时只能删除applicationsets
applicationset.argoproj.io "helloworld" deleted
root@k8s-master01:~# argocd app list
NAME  CLUSTER  NAMESPACE  PROJECT  STATUS  HEALTH  SYNCPOLICY  CONDITIONS  REPO  PATH  TARGET

作业1：结合git webhook实现ArgoCD怎么部署(其实ArgoCD定时3分钟轮循部署也算是自动化部署)
作业2：使用notification实现构建后操作  


#针对不同集群不同分支配置的ApplicationSet
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test# cat applicationset.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: frontend-www-homsom-com-test
  namespace: argocd
spec:
  generators:
  - list:
    elements:
    - cluster: pro
      url: https://kubernetes.default.svc
    - cluster: uat
      url: https://172.168.2.31:6443
    - cluster: fat
      url: https://172.168.2.31:6443
      template:
      metadata:
      name: '{{cluster}}-frontend-www-homsom-com-test'
      spec:
      project: homsom
      source:
        path: ./deploy/
        repoURL: git@gitlab.hs.com:k8s-deploy/frontend-www-homsom-com-test.git
        targetRevision: '{{cluster}}'
      destination:
        namespace: '{{cluster}}-frontend'
        server: '{{url}}'
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



## 部署Notification template和trigger
Documentation: https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/

```bash
#安装notification template和trigger，会生成ConfigMap argocd-notifications-cm
root@ansible:~/k8s/argocd# curl -L -o argocd-notification-template https://raw.githubusercontent.com/argoproj/argo-cd/stable/notifications_catalog/install.yaml
root@ansible:~/k8s/argocd# kubectl apply -n argocd -f argocd-notification-template
root@k8s-master01:~# argocd admin notifications template get -n argocd	#查看模板
NAME                     PREVIEW
app-created              Application {{.app.metadata.name}} has been created.
app-deleted              Application {{.app.metadata.name}} has been deleted.
app-deployed             {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} is now r...
app-health-degraded      {{if eq .serviceType "slack"}}:exclamation:{{end}} Application {{.app.metadata.name}} has degraded.
app-sync-failed          {{if eq .serviceType "slack"}}:exclamation:{{end}}  The sync operation of application {{.app.metada...
app-sync-running         The sync operation of application {{.app.metadata.name}} has started at {{.app.status.operationStat...
app-sync-status-unknown  {{if eq .serviceType "slack"}}:exclamation:{{end}} Application {{.app.metadata.name}} sync is 'Unkn...
app-sync-succeeded       {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} has been...
root@k8s-master01:~# argocd admin notifications trigger get -n argocd	#查看触发器
NAME                    TEMPLATE                 CONDITION
on-created              app-created              true
on-deleted              app-deleted              app.metadata.deletionTimestamp != nil
on-deployed             app-deployed             app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
on-health-degraded      app-health-degraded      app.status.health.status == 'Degraded'
on-sync-failed          app-sync-failed          app.status.operationState.phase in ['Error', 'Failed']
on-sync-running         app-sync-running         app.status.operationState.phase in ['Running']
on-sync-status-unknown  app-sync-status-unknown  app.status.sync.status == 'Unknown'
on-sync-succeeded       app-sync-succeeded       app.status.operationState.phase in ['Succeeded']

#将电子邮件用户名和密码令牌添加到argocd-notifications-secret
export EMAIL_USER='test@test.com'
export PASSWORD='test@123!@#'
kubectl apply -n argocd -f - << EOF
apiVersion: v1
kind: Secret
metadata:
  name: argocd-notifications-secret
stringData:
  email-username: $EMAIL_USER
  email-password: $PASSWORD
type: Opaque
EOF

root@ansible:~/k8s/argocd# kubectl get secret argocd-notifications-secret -o yaml -n argocd
apiVersion: v1
data:
  email-password: SG9tc29YhQCM=
  email-username: cHJvbWV0aGV29t
kind: Secret
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Secret","metadata":{"annotations":{},"name":"argocd-notifications-secret","namespace":"argocd"},"stringData":{"email-password":"Homsom@4006!@#","email-username":"prometheus@homsom.com"},"type":"Opaque"}
  creationTimestamp: "2022-05-31T08:40:01Z"
  name: argocd-notifications-secret
  namespace: argocd
  resourceVersion: "2202905"
  uid: 1316f48c-9c3e-4f26-ac1a-e70eafdf0715
type: Opaque

#注册电子邮件通知服务，配置ConfigMap argocd-notifications-cm，自己会默认调用secret argocd-notifications-secret的用户和密码
root@ansible:~/k8s/argocd# kubectl patch cm argocd-notifications-cm -n argocd --type merge -p '{"data": {"service.email.gmail": "{ username: $email-username, password: $email-password, host: smtp.qiye.163.com, port: 465, from: $email-username }" }}'
configmap/argocd-notifications-cm patched

root@ansible:~/k8s/argocd# kubectl get cm argocd-notifications-cm -o yaml -n argocd | head -n 10
apiVersion: v1
data:
  service.email.gmail: '{ username: $email-username, password: $email-password, host:
    smtp.qiye.163.com, port: 465, from: $email-username }'	#实际添加了此行
  template.app-created: |
    email:
      subject: Application {{.app.metadata.name}} has been created.
    message: Application {{.app.metadata.name}} has been created.
    teams:
      title: Application {{.app.metadata.name}} has been created.

#创建application
root@k8s-master01:~/git/kubernetes/ops/argocd/04-applicationset# cat application-test.yaml

# 基于istio实现的canary时需要使用此application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: pro-frontend-www-homsom-com-test
  namespace: argocd
spec:
  destination:
    namespace: pro-frontend
    server: https://kubernetes.default.svc
  project: homsom
  source:
    path: deploy/
    repoURL: git@gitlab.hs.com:k8s-deploy/frontend-www-homsom-com-test.git
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
  ignoreDifferences:

  - group: networking.istio.io
    kind: VirtualService
    jsonPointers:
    - /spec/http/0
      root@k8s-master01:~/git/kubernetes/ops/argocd/04-applicationset# kubectl apply -f application-test.yaml

#通过将注释添加到 Argo CD 应用程序来订阅通知：
root@ansible:~/k8s/argocd# kubectl patch app pro-frontend-www-homsom-com-test -n argocd -p '{"metadata": {"annotations": {"notifications.argoproj.io/subscribe.on-sync-succeeded.gmail": "test@test.com"}}}' --type merge
application.argoproj.io/pro-frontend-www-homsom-com-test patched

# 配置所有项目的所有应用默认订阅信息，也可以针对特定project或特定application在annotations中进行定义

root@ansible:~# kubectl edit cm argocd-notifications-cm -n argocd
apiVersion: v1
data:
  service.email.email: '{ username: $email-username, password: $email-password, host:
    smtp.qiye.163.com, port: 465, from: $email-username }'
  subscriptions: |
    - recipients:
      - email:jack.li@homsom.com
      triggers:
      - on-deleted
      - on-health-degraded
      - on-sync-failed
      - on-sync-status-unknown
    - recipients:
      - email:595872348@qq.com
      triggers:
      - on-deployed
	  
#更改argocd notification时区
root@ansible:~# kubectl edit deploy argocd-notifications-controller -n argocd
    spec:
      containers:
      - command:
        - argocd-notifications
        image: quay.io/argoproj/argocd:v2.3.4
        name: argocd-notifications-controller
        env:
        - name: TZ
          value: Asia/Shanghai		#更改通知服务时间
```



## 基于RBAC来创建argocd本地用户

注：argocd本地用户不提供高级功能，例如组，登录历史记录等。因此，如果您需要此类功能，强烈建议使用SSO。

```bash
#创建alice用户

root@ansible:~# kubectl get cm argocd-cm -o yaml -n argocd
apiVersion: v1
data:
  accounts.alice: login				#登录方式有login,apiKey
  accounts.alice.enabled: "true"	#默认是true，可不写
  accounts.jack: login, apiKey
  #admin.enabled: "false"			#关闭admin用户
  users.anonymous.enabled: "true"	#启用匿名用户访问，但是需要在cm/argocd-rbac-cm中配置默认策略为role:readonly
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
--获取用户列表
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test# argocd account list
NAME   ENABLED  CAPABILITIES
admin  true     login
alice  true     login
root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test# argocd account get --account alice
Name:               alice
Enabled:            true
Capabilities:       login

Tokens:
NONE
--设置alice用户密码

# if you are managing users as the admin user, <current-user-password> should be the current admin password.

argocd account update-password \
  --account alice \
  --current-password <current-user-password> \
  --new-password <new-user-password>
注：current-password为admin管理员用户密码，new-password为alice用户密码

root@k8s-master01:~/git/k8s-deploy/frontend-www-homsom-com-test# argocd account update-password \
 --account alice \
 --current-password password \
 --new-password alice@1234
Password updated

#为alice用户绑定权限
- 权限结构
  - 分解权限定义在应用程序和 Argo CD 中的所有其他资源类型之间略有不同。
    - 除应用程序权限之外的所有资源（请参阅下一个项目符号）：
      p, <role/user/group>, <resource>, <action>, <object>
    - 应用程序（属于应用程序项目）：
      p, <role/user/group>, <resource>, <action>, <appproject>/<object>
- RBAC 资源和操作
  - 资源：clusters projects applications repositories certificates accounts gpgkeys
  - 行动：get create update delete sync override action
- 可以在 ConfigMap/argocd-rbac-cm中配置其他用户、角色和组


**Argo CD有两个预定义的角色，但RBAC配置允许定义角色和组**
* role:readonly- 对所有资源的只读访问权限
* role:admin- 不受限制地访问所有资源

root@ansible:~# kubectl get cm argocd-rbac-cm -o yaml -n argocd	#以下权限只有application的回滚权限
apiVersion: v1
data:
  policy.csv: |
    p, alice, applications, update, */*, allow
    p, alice, applications, sync, */*, allow
	p, alice, applications, delete, default/*, allow		#可以对default项目下的application进行删除
	g, ops, role:admin										#将ops用户加入role:admin组
	g, test, role:test										#将test加入role:test组
	p, role:test, applications, sync, */*, allow			#配置role:test组权限

  policy.default: role:readonly
kind: ConfigMap
metadata:
  name: argocd-rbac-cm

  namespace: argocd
---

#使用alice用户登录argocd UI，测试权限即可
```


### argocd命令--20230526
```bash
# 对特定application打特定标签，为后面批量选择做准备
kubectl label application -n argocd prepro-frontend-nginx-bg-hs-com prepro-frontend-nginx-hs-com env=prepro

# 列出打好标签的application
root@k8s-master01:~# argocd app list -l env=prepro
NAME                             CLUSTER                     NAMESPACE     PROJECT        STATUS  HEALTH   SYNCPOLICY  CONDITIONS  REPO                                                       PATH     TARGET
prepro-frontend-nginx-bg-hs-com  https://192.168.13.90:6443  pro-frontend  prepro-homsom  Synced  Healthy  <none>      <none>      git@gitlab.hs.com:k8s-deploy/frontend-nginx-bg-hs-com.git  deploy/  prepro
prepro-frontend-nginx-hs-com     https://192.168.13.90:6443  pro-frontend  prepro-homsom  Synced  Healthy  <none>      <none>      git@gitlab.hs.com:k8s-deploy/frontend-nginx-hs-com.git     deploy/  prepro

# 列出其中1个application的发布历史
root@k8s-master01:~# argocd app history prepro-frontend-nginx-bg-hs-com 
ID  DATE                           REVISION
11  2023-05-25 19:53:03 +0800 CST  prepro (c6578a8)
12  2023-05-25 20:03:27 +0800 CST  prepro (c6578a8)
13  2023-05-25 20:05:58 +0800 CST  prepro (662d8e9)
14  2023-05-25 20:10:51 +0800 CST  prepro (5a530d0)
15  2023-05-25 20:15:13 +0800 CST  prepro (3d84edb)
16  2023-05-25 20:17:07 +0800 CST  prepro (5a530d0)
17  2023-05-25 20:17:53 +0800 CST  prepro (c6578a8)
18  2023-05-25 20:18:35 +0800 CST  prepro (5a530d0)
19  2023-05-25 20:43:04 +0800 CST  prepro (0be71f0)
20  2023-05-25 20:44:27 +0800 CST  prepro (5141ac5)

# 列出上一个版本的ID号，为倒数第2个
root@k8s-master01:~# argocd app history prepro-frontend-nginx-bg-hs-com | awk '{print $1}' | tail -n 2 | head -n 1
19

# 回滚指定的application到指定版本
root@k8s-master01:~# argocd app rollback prepro-frontend-nginx-bg-hs-com 19      

# 对特定的application标签对象进行批量手动同步，当application未开启自动同步功能时，此功能可以实现一键同步发布
argocd app sync -l env=prepro --force --async


## 批量回滚deployment/rollout
for i in `argocd app list -l env=prepro | awk '{print $1}' | tail -n +2`;do REVERSION_ID=`argocd app history $i | awk '{print $1}' | tail -n 2 | head -n 1`; argocd app rollback $i ${REVERSION_ID};done
```

### argocd命令--20230614
```bash
#### 列出k8s资源概要信息

## resource limits list
NAMESPACE=pro-dotnet
rollout_name=`kubectl get rollout -n ${NAMESPACE} | grep -v NAME | awk '{print $1}'`; for i in $rollout_name;do kubectl get rollout $i -o jsonpath='{.spec.template.spec.containers[].resources.limits}' -n ${NAMESPACE};echo $i; sleep 1;done


## image version、replicas list
NAMESPACE=pro-dotnet
rollout_name=`kubectl get rollout -n ${NAMESPACE} | grep -v NAME | awk '{print $1}'`; for i in $rollout_name;do kubectl get rollout $i -o jsonpath='{.spec.template.spec.containers[].image} {.spec.replicas} ' -n ${NAMESPACE};echo $i; sleep 1;done



#### argocd批量命令

## 开启application的自动同步策略及参数，通过标签build=manual来筛选
for i in `argocd app list -l build=manual | awk '{print $1}' | tail -n +2`;do argocd app set $i --sync-policy=automated --auto-prune --self-heal --sync-option Validate=false,CreateNamespace=true,PrunePropagationPolicy=foreground,PruneLast=true --sync-retry-limit 5 --sync-retry-backoff-duration 5s --sync-retry-backoff-factor 2 --sync-retry-backoff-max-duration 3m;done

## 关闭application的自动同步策略
for i in `argocd app list -l build=manual | awk '{print $1}' | tail -n +2`;do argocd app set $i --sync-policy none --grpc-web --insecure;done




#### 批量同步

## 获取未同步的application
[root@prometheus ~]# kubectl get application -A --show-labels | grep OutOfSync 
argocd      prepro-frontend-nginx-bg-hs-com                      OutOfSync     Healthy         env=prepro
argocd      prepro-frontend-nginx-hs-com                         OutOfSync     Healthy         env=prepro

## 对未同步的application进行手动打标签：build=manual
[root@prometheus ~]# for i in `kubectl get application -A | grep OutOfSync | awk '{print $2}'`;do kubectl label application $i -n argocd build=manual ;done
application.argoproj.io/prepro-frontend-nginx-bg-hs-com labeled
application.argoproj.io/prepro-frontend-nginx-hs-com labeled

## 通过标签匹配批量同步
[root@prometheus ~]# argocd app sync --async -l build=manual
## 通过资源匹配批量同步，格式：GROUP:KIND:NAME
[root@prometheus ~]# argocd app sync --force --async --resource apps/v1:Deployment: 

## 批量回滚deployment/rollout
for i in `argocd app list -l build=manual | awk '{print $1}' | tail -n +2`;do REVERSION_ID=`argocd app history $i | awk '{print $1}' | tail -n 2 | head -n 1`; argocd app rollback $i ${REVERSION_ID};done

## 删除带有build标签的application
APP_NAME=`kubectl get application -A --show-labels | grep 'build=' | awk '{print $2}'`
for i in $APP_NAME;do kubectl label application $i -n argocd build-;done

```



## Argo Rollouts概览

- Argo Rollouts
  - 由一个控制器和一组CRD组成，可为Kubernetes提供高级部署功能，包括
    - blue-green
	  - canary
	  - canary analysis
	  - experimentation
	  - progressive delivery
  - 支持与Ingress Controller（Nginx和ALB）及ServiceMesh（Istio, Linkerd和SMI）集成，利用它们的流量治理能力实现流量迁移过程
  - 能够查询和解释来自多种指标系统（Prometheus、Kubernetes Jobs、Web、Datadog等）的指标来验证Blue-Green或Canary部署结果，并根据结果自动决定执行升级或回滚
  - 几个相关的CRD
    - Rollout、AnalysisTemplate、ClusterAnalysisTemplate、AnalysisRun
- 基本工作机制
  - 与Deployment相似，Argo Rollouts控制器借助于ReplicaSet完成应用的创建、缩放和删除
  - ReplicaSet资源由Rollout的spec.template字段进行定义
  

Argo Rollouts架构
- Argo Rollout主要由Argo Rollout Controller、Rollout CRD、ReplicaSet、Ingress/Service、AnalysisTemplate/AnalysisRun、Metric providers和CLI/GUI等组件构成

Argo Rollouts架构组件
- Rollout Controller
  - 负责管理Rollout CRD资源对象
- Rollout CRD
  - 由Argo Rollout引入的自定义资源类型，与Kubernetes Deployment兼容，但具有控制高级部署方法的阶段、阈值和方法的额外字段
  - 并不会对Kubernetes Deployment施加任何影响，或要使用Rollout的功能，用户需要手动将资源从Deployment迁移至Rollout
- Ingress/Service（依赖外部组件）
  - Argo Rollouts使用标准的Kubernetes Service，但需要一些额外的元数据
  - 针对Canary部署，Rollout支持多种不同的ServiceMesh和Ingress Controller，实现精细化的流量分割和迁移
- AnalysisTemplate和AnalysisRun（依赖外部组件）
  - Analysis是将Rollout连接至特定的Metric Provider，并为其支持的某些指标定义特定的阈值的能力，于是，这些指标的具体值将决定更新操作是否成功进行
  - 若指标查询结果满足阈值，则继续进行；若不能满足，则执行回滚；若查询结果不确定，则暂停；
  - 为了执行Analysis，Argo Rollouts提供了AnalysisTemplate和AnalysisRun两个CRD
  



## 部署ArgoRollout

文档：https://argoproj.github.io/argo-rollouts/installation/
文档：https://github.com/argoproj/argo-rollouts/releases
--下载配置清单
https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/install.yaml		#集群级别安装
https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/dashboard-install.yaml	#以pod方式运行的dashboard，推荐这种运行
#https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/kubectl-argo-rollouts-linux-amd64	#以kubectl插件方式运行的dashboard
#https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/namespace-install.yaml		#名称空间级别安装

```bash
#部署Argo Rollout
curl -OL https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/install.yaml	
curl -OL https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/dashboard-install.yaml
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl create namespace argo-rollouts	#只能部署在此名称空间下
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl apply -f install.yaml -n argo-rollouts
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get pods -n argo-rollouts
NAME                             READY   STATUS              RESTARTS   AGE
argo-rollouts-85fdf688d9-z9md9   0/1     ContainerCreating   0          21s
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get svc -n argo-rollouts
NAME                    TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
argo-rollouts-metrics   ClusterIP   10.68.13.235   <none>        8090/TCP   27s
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl api-resources --api-group=argoproj.io
NAME                       SHORTNAMES         APIVERSION             NAMESPACED   KIND
analysisruns               ar                 argoproj.io/v1alpha1   true         AnalysisRun
analysistemplates          at                 argoproj.io/v1alpha1   true         AnalysisTemplate
applications               app,apps           argoproj.io/v1alpha1   true         Application
applicationsets            appset,appsets     argoproj.io/v1alpha1   true         ApplicationSet
appprojects                appproj,appprojs   argoproj.io/v1alpha1   true         AppProject
clusteranalysistemplates   cat                argoproj.io/v1alpha1   false        ClusterAnalysisTemplate
experiments                exp                argoproj.io/v1alpha1   true         Experiment
rollouts                   ro                 argoproj.io/v1alpha1   true         Rollout


#部署Argo Rollout Dashboard
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl apply -f dashboard-install.yaml -n argo-rollouts
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get pod -n argo-rollouts
NAME                                      READY   STATUS    RESTARTS        AGE
argo-rollouts-85fdf688d9-z9md9            1/1     Running   2 (9m57s ago)   45m
argo-rollouts-dashboard-ff9668f57-z6mjd   1/1     Running   1 (14m ago)     44m

root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get svc -n argo-rollouts
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
argo-rollouts-dashboard   ClusterIP   10.68.152.156   <none>        3100/TCP   44m	#rollout dashboard
argo-rollouts-metrics     ClusterIP   10.68.13.235    <none>        8090/TCP   45m	#rollout


#部署istio，用于暴露Argo Rollout Dashboard服务
root@k8s-master01:~/istio-1.13.3# export PATH=$PATH:`pwd`/bin
root@k8s-master01:~/istio-1.13.3# istioctl profile dump default > istio-default.yaml
root@k8s-master01:~/istio-1.13.3# cat istio-default.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  components:
    base:
      enabled: true
    cni:
      enabled: false
    egressGateways:
    - enabled: false
      name: istio-egressgateway
    ingressGateways:
    - enabled: true
      name: istio-ingressgateway
      k8s:
        replicaCount: 3
    istiodRemote:
      enabled: false
    pilot:
      enabled: true
  hub: docker.io/istio
  meshConfig:
    defaultConfig:
      proxyMetadata: {}
    enablePrometheusMerge: true
  profile: default
  tag: 1.13.3
  values:
    base:
      enableCRDTemplates: false
      validationURL: ""
    defaultRevision: ""
    gateways:
      istio-egressgateway:
        autoscaleEnabled: true
        env: {}
        name: istio-egressgateway
        secretVolumes:
        - mountPath: /etc/istio/egressgateway-certs
          name: egressgateway-certs
          secretName: istio-egressgateway-certs
        - mountPath: /etc/istio/egressgateway-ca-certs
          name: egressgateway-ca-certs
          secretName: istio-egressgateway-ca-certs
        type: ClusterIP
      istio-ingressgateway:
        autoscaleEnabled: true
        env: {}
        name: istio-ingressgateway
        secretVolumes:
        - mountPath: /etc/istio/ingressgateway-certs
          name: ingressgateway-certs
          secretName: istio-ingressgateway-certs
        - mountPath: /etc/istio/ingressgateway-ca-certs
          name: ingressgateway-ca-certs
          secretName: istio-ingressgateway-ca-certs
        type: LoadBalancer
    global:
      configValidation: true
      defaultNodeSelector: {}
      defaultPodDisruptionBudget:
        enabled: true
      defaultResources:
        requests:
          cpu: 10m
      imagePullPolicy: ""
      imagePullSecrets: []
      istioNamespace: istio-system
      istiod:
        enableAnalysis: false
      jwtPolicy: third-party-jwt
      logAsJson: false
      logging:
        level: default:info
      meshNetworks: {}
      mountMtlsCerts: false
      multiCluster:
        clusterName: ""
        enabled: false
      network: ""
      omitSidecarInjectorConfigMap: false
      oneNamespace: false
      operatorManageWebhooks: false
      pilotCertProvider: istiod
      priorityClassName: ""
      proxy:
        autoInject: enabled
        clusterDomain: cluster.local
        componentLogLevel: misc:error
        enableCoreDump: false
        excludeIPRanges: ""
        excludeInboundPorts: ""
        excludeOutboundPorts: ""
        image: proxyv2
        includeIPRanges: '*'
        logLevel: warning
        privileged: false
        readinessFailureThreshold: 30
        readinessInitialDelaySeconds: 1
        readinessPeriodSeconds: 2
        resources:
          limits:
            cpu: 2000m
            memory: 1024Mi
          requests:
            cpu: 100m
            memory: 128Mi
        statusPort: 15020
        tracer: zipkin
      proxy_init:
        image: proxyv2
        resources:
          limits:
            cpu: 2000m
            memory: 1024Mi
          requests:
            cpu: 10m
            memory: 10Mi
      sds:
        token:
          aud: istio-ca
      sts:
        servicePort: 0
      tracer:
        datadog: {}
        lightstep: {}
        stackdriver: {}
        zipkin: {}
      useMCP: false
    istiodRemote:
      injectionURL: ""
    pilot:
      autoscaleEnabled: true
      autoscaleMax: 5
      autoscaleMin: 1
      configMap: true
      cpu:
        targetAverageUtilization: 80
      enableProtocolSniffingForInbound: true
      enableProtocolSniffingForOutbound: true
      env: {}
      image: pilot
      keepaliveMaxServerConnectionAge: 30m
      nodeSelector: {}
      podLabels: {}
      replicaCount: 3
      traceSampling: 1
    telemetry:
      enabled: true
      v2:
        enabled: true
        metadataExchange:
          wasmEnabled: false
        prometheus:
          enabled: true
          wasmEnabled: false
        stackdriver:
          configOverride: {}
          enabled: false
          logging: false
          monitoring: false
          topology: false
root@k8s-master01:~/istio-1.13.3# istioctl apply -f istio-default.yaml
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS        AGE
istio-ingressgateway-6dc56fc9f9-kqhzd   1/1     Running   1 (11m ago)     29m
istio-ingressgateway-6dc56fc9f9-lmvf9   1/1     Running   0               2m43s
istio-ingressgateway-6dc56fc9f9-st94k   1/1     Running   0               2m43s
istiod-8488b9bdc7-7vpnt                 1/1     Running   0               2m43s
istiod-8488b9bdc7-lqfxr                 1/1     Running   2 (8m46s ago)   34m
istiod-8488b9bdc7-xrdhq                 1/1     Running   0               30s

root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get svc -n istio-system
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)                                      AGE
istio-ingressgateway   LoadBalancer   10.68.162.21   <pending>     15021:59630/TCP,80:48809/TCP,443:46900/TCP   33m
istiod                 ClusterIP      10.68.9.121    <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP        38m
spec:
  externalIPs:

  - 172.168.2.28
    root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get svc -n istio-system
    NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                      AGE
    istio-ingressgateway   LoadBalancer   10.68.162.21   172.168.2.28   15021:59630/TCP,80:48809/TCP,443:46900/TCP   34m
    istiod                 ClusterIP      10.68.9.121    <none>         15010/TCP,15012/TCP,443/TCP,15014/TCP        39m


#将argo rollout dashboard暴露出去

root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# cat 03-argo-rollouts-dashboard-virtualservice.yaml
---

apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: argo-rollouts-dashboard
  namespace: argo-rollouts
spec:
  host: argo-rollouts-dashboard
  trafficPolicy:
    tls:

      mode: DISABLE
---

apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: argo-rollouts-dashboard-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:

  - port:
    number: 80
    name: http
    protocol: HTTP
    hosts:
    - "argo-rollouts.magedu.com"
    - "rollouts.magedu.com"

---

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: argo-rollouts-dashboard-virtualservice
  namespace: argo-rollouts
spec:
  hosts:

  - "argo-rollouts.magedu.com"
  - "rollouts.magedu.com"
    gateways:
  - istio-system/argo-rollouts-dashboard-gateway
    http:
  - match:
    - uri:
      prefix: /
      route:
    - destination:
      host: argo-rollouts-dashboard
      port:
        number: 3100

---

root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl apply -f 03-argo-rollouts-dashboard-virtualservice.yaml
root@k8s-master01:~/tekton-and-argocd-in-practise/06-deploy-argocd/argo-rollouts# kubectl get vs -n argo-rollouts
NAME                                     GATEWAYS                                           HOSTS                                                AGE
argo-rollouts-dashboard-virtualservice   ["istio-system/argo-rollouts-dashboard-gateway"]   ["argo-rollouts.magedu.com","rollouts.magedu.com"]   11s

--windows hosts配置
172.168.2.28 argo-rollouts.magedu.com rollouts.magedu.com
--WEB访问rollouts.magedu.com

#安装argo rollout CLI
root@front-envoy:~/tekton-and-argocd-in-practise# curl -OL https://github.com/argoproj/argo-rollouts/releases/download/v1.2.1/kubectl-argo-rollouts-linux-amd64
root@front-envoy:~/tekton-and-argocd-in-practise# chmod +x kubectl-argo-rollouts-linux-amd64
root@front-envoy:~/tekton-and-argocd-in-practise# scp kubectl-argo-rollouts-linux-amd64 root@172.168.2.21:/usr/local/bin/kubectl-argo-rollouts
root@k8s-master01:~# kubectl
kubectl                kubectl-argo-rollouts
root@k8s-master01:~# kubectl argo rollouts --help	#使用kubectl内建命令调用argo rollout
```



### Rollout更新策略之Canary

- 通过spec.strategy.canary启用
- 支持内嵌的字段
  - canaryService <string>: 由控制器用来匹配到Canary Pods上的Service，trafficRouting依赖于该字段
  - stableService <string>: 由控制器用来匹配到Stable Pods上的Service，trafficRouting依赖于该字段
  - canaryMetadata <Object>: 需要添加到Canary版本的Pod上的元数据，仅存于Canary更新期间，更新完成后即成为Stable
  - stableMetadata <Object>: 需要添加到Stable版本的Pod上的元数据
  - maxSurge <>
  - maxUnavailable <>
  - scaleDownDelayRevisionLimit <integer>: 在旧RS上启动缩容之前，可运行着的旧RS的数量
  - abordScaleDownDelaySeconds <integer>: 启用了trafficRouting时，因更新中止而收缩Canary版本Pod数量之前的延迟时长，默认为30s
  - scaleDownDelaySeconds <integer>: 启用了trafficRouting时，缩容前一个ReplicaSet规模的延迟时长，默认为30s
  - analysis <Object>: 在滚动更新期间于后台运行的analysis，可选
  - steps <[]Object>: Canary更新期间要执行的步骤，可选
  - trafficRouting <Object>: 设定Ingress Controller或ServiceMesh如何动态调整配置以完成精细化地流量分割和流量迁移
  - antiAffinity <Object>: 定义Canary Pod与旧ReplicaSet Pod之间的反亲和关系
  

配置Canary策略
- 常用的Step
  - pause <Object>: 暂停step
    - 用于暂停滚动过程
	- 可内嵌duration字段指定暂停时长，或留空而一直暂停至由用户设定继续进行
  - setWeight <integer>: 设定Canary版本ReplicaSet激活的Pod比例，以及调度至Canary版本的流量比例
  - setCanaryScale <Object>: 设定Canary扩容期间Pod扩增也流量扩增的对应关系，支持如下三种配置之一
    - replicas <integer>: 明确设定Canary RS的规模为该处指定的Pod数量，但不改变先前设定的流量比例
	- weight  <integer>: 明确设定Canary RS的规模为该处指定的比例，但不改变先前设定的流量比例
	- matchTrafficWeight  <boolean>: 设定Canary的Pod规模与调度至这些Pod的流量同比例滚动
  - analysis  <Object>: 内联定义或调用的analysis step
    - args <[]Object>
	- dryRun <[]Object>
	- templates <[]Object>
	- measurementRetention <[]Object>
  - experiment <Object>: 内联定义或调用的experiment step
    - analysis <[]Object>
	- duration <string>
	- templates <[]Object>
- analysis的相关配置
  - args <[]Object>: Canary更新期间，要按需临时设定的参数
    - name <string>: 要动态设定其值的参数的名称
	- value <string>: 为相关参数指定一个具体值
	- valueFrom <Object>: 相关参数的值引用自其它属性或字段的值
  - templates <[]Object>: 要引用的AnalysisTemplate
    - clusterScope <boolean>
	- templateName <string>: 引用的AnalysisTemplate的名称
  - dryRun <[]Object>
  - startingStep <integer>
  - measurementRetention
	

实战案例1：结合Service进行Canary部署
- 案例环境说明
  - 应用：spring-boot-helloworld
    - 微服务、默认监听于80/tcp
	- 相关的path: /, /version 和 /hello
  - 使用Argo Rollouts提供的Rollout资源编排运行该应用
    - 使用Canary更新策略
	- 推出一个Canary Pod后即暂停，需要用户手动Promote
- 相关的常用命令
  - 更新应用
    - kubectl argo rollouts set image ROLLOUT_NAME CONTAINER=NEW_IMAGE
  - 继续更新
    - kubectl argo rollouts promote ROLLOUT_NAME [flas]
  - 中止更新
    - kubectl argo rollouts abort ROLLOUT_NAME [flas]
  - 回滚
    - kubectl argo rollouts undo ROLLOUT_NAME [flas]



案例实验1

```bash
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# cat 01-argo-rollouts-demo.yaml

# CopyRight: MageEdu <http://www.magedu.com>

apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollouts-spring-boot-helloworld
spec:
  replicas: 10
  strategy:
    canary:
      steps:
      - setWeight: 10
      - pause: {}
      - setWeight: 20
      - pause: {duration: 20}
      - setWeight: 30
      - pause: {duration: 20}
      - setWeight: 40
      - pause: {duration: 20}
      - setWeight: 60
      - pause: {duration: 20}
      - setWeight: 80
      - pause: {duration: 20}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: spring-boot-helloworld
  template:
    metadata:
      labels:
        app: spring-boot-helloworld
    spec:
      containers:
      - name: spring-boot-helloworld
        image: ikubernetes/spring-boot-helloworld:v0.9.5
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        resources:
          requests:
            memory: 32Mi
            cpu: 50m
        livenessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP
          initialDelaySeconds: 3
        readinessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP

          initialDelaySeconds: 5
---

apiVersion: v1
kind: Service
metadata:
  name: spring-boot-helloworld
spec:
  ports:

  - port: 80
    targetPort: http
    protocol: TCP
    name: http
    selector:
    app: spring-boot-helloworld
    root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl apply -f 01-argo-rollouts-demo.yaml
    root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl get pods
    NAME                                              READY   STATUS    RESTARTS        AGE
    el-s2i-listener-5c945b65d9-zgtjh                  1/1     Running   6 (103s ago)    4h26m
    rollouts-spring-boot-helloworld-96697f77d-42g8m   1/1     Running   3 (104s ago)    3m54s
    rollouts-spring-boot-helloworld-96697f77d-69wvc   1/1     Running   2 (2m42s ago)   3m54s
    rollouts-spring-boot-helloworld-96697f77d-8t45x   1/1     Running   3 (104s ago)    3m54s
    rollouts-spring-boot-helloworld-96697f77d-ds94c   1/1     Running   3 (103s ago)    3m55s
    rollouts-spring-boot-helloworld-96697f77d-fl4br   1/1     Running   2 (2m42s ago)   3m54s
    rollouts-spring-boot-helloworld-96697f77d-hfbh4   1/1     Running   4 (61s ago)     3m55s
    rollouts-spring-boot-helloworld-96697f77d-hpqwx   1/1     Running   3 (103s ago)    3m54s
    rollouts-spring-boot-helloworld-96697f77d-jvrww   1/1     Running   2 (2m43s ago)   3m54s
    rollouts-spring-boot-helloworld-96697f77d-mjxrp   1/1     Running   3 (103s ago)    3m54s
    rollouts-spring-boot-helloworld-96697f77d-vjgg5   1/1     Running   3 (94s ago)     3m54s
    root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl get svc
    NAME                          TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                         AGE
    el-gitlab-event-listener-02   NodePort    10.68.54.164   <none>        8080:54356/TCP,9000:46583/TCP   4h26m
    el-s2i-listener               ClusterIP   10.68.23.204   <none>        8080/TCP,9000/TCP               4h27m
    kubernetes                    ClusterIP   10.68.0.1      <none>        443/TCP                         11d
    spring-boot-helloworld        ClusterIP   10.68.19.194   <none>        80/TCP                          4m17s

#测试访问
root@k8s-node02:~# while true; do curl 10.68.19.194/version;sleep 0.$RANDOM;echo;done
version 0.9.5
version 0.9.5
version 0.9.5
version 0.9.5
version 0.9.5
version 0.9.5


#更新应用到v0.9.6
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts set image rollouts-spring-boot-helloworld spring-boot-helloworld=ikubernetes/spring-boot-helloworld:v0.9.6
rollout "rollouts-spring-boot-helloworld" image updated

#当暂停后点击此继续更新
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts promote rollouts-spring-boot-helloworld

#回滚版本
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts undo rollouts-spring-boot-helloworld

#中断回滚
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts abort rollouts-spring-boot-helloworld

#查看状态
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts status rollouts-spring-boot-helloworld
Degraded - RolloutAborted: Rollout aborted update to revision 5
Error: The rollout is in a degraded state with message: RolloutAborted: Rollout aborted update to revision 5

#更新并重试
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts set image rollouts-spring-boot-helloworld spring-boot-helloworld=ikubernetes/spring-boot-helloworld:v0.9.5
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts retry rollout rollouts-spring-boot-helloworld

#命令行查看rollout状态
kubectl argo rollouts get rollout rollouts-spring-boot-helloworld --watch 
Name:            rollouts-spring-boot-helloworld
Namespace:       default
Status:          ◌ Progressing
Message:         more replicas need to be updated
Strategy:        Canary
  Step:          10/12
  SetWeight:     80
  ActualWeight:  75
Images:          ikubernetes/spring-boot-helloworld:v0.9.5 (canary)
                 ikubernetes/spring-boot-helloworld:v0.9.6 (stable)
Replicas:
  Desired:       10
  Current:       10
  Updated:       8
  Ready:         8
  Available:     8

NAME                                                         KIND        STATUS               AGE    INFO
⟳ rollouts-spring-boot-helloworld                            Rollout     ◌ Progressing        33m
├──# revision:5
│  └──⧉ rollouts-spring-boot-helloworld-96697f77d            ReplicaSet  ◌ Progressing        33m    canary
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-8rmxb   Pod         ✔ Running            5m57s  ready:1/1
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-mmpqh   Pod         ✔ Running            2m43s  ready:1/1
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-wjtkx   Pod         ✔ Running            2m2s   ready:1/1
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-zxskf   Pod         ✔ Running            82s    ready:1/1
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-4k5pn   Pod         ✔ Running            42s    ready:1/1
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-4kpcs   Pod         ✔ Running            42s    ready:1/1
│     ├──□ rollouts-spring-boot-helloworld-96697f77d-5zwpm   Pod         ◌ ContainerCreating  1s     ready:0/1
│     └──□ rollouts-spring-boot-helloworld-96697f77d-shps2   Pod         ◌ ContainerCreating  1s     ready:0/1
└──# revision:4
   └──⧉ rollouts-spring-boot-helloworld-576b6b94cc           ReplicaSet  ✔ Healthy            22m    stable
      ├──□ rollouts-spring-boot-helloworld-576b6b94cc-klh9v  Pod         ✔ Running            19m    ready:1/1
      ├──□ rollouts-spring-boot-helloworld-576b6b94cc-s57b6  Pod         ◌ Terminating        15m    ready:1/1
      ├──□ rollouts-spring-boot-helloworld-576b6b94cc-9r9nl  Pod         ✔ Running            14m    ready:1/1
      └──□ rollouts-spring-boot-helloworld-576b6b94cc-dgz8s  Pod         ◌ Terminating        14m    ready:1/1
```




实战案例2：结合Istio进行Canary流量迁移
- Istio环境中支持两种流量分割模式
  - 基于host进行流量分割
    - Canary和Stable版本分别对应一个独立的Service
	- 每个Service代表着一个Host
	- 分别为Canary和Stable的Pod添加rollouts-pod-template-hash标签，其值为相应的RS模板的hash值
	- 动态调整VS上route中Canary Service和Stable Service的weight进行流量迁移
  - 基于subset进行流量分割（下面的示例即属于此种）
    - Canary和Stable版本共用一个Service
	- 需要通过DestinationRule将Service的后端不同版本(分别隶属于Canary和Stable)的pod，分别划分到不同的subset
	- Pod上的子集划分依赖于一个动态变动的标签进行
	- 分别为Canary和Stable对应的subset上的Pod设定rollouts-pod-template-hash，其值为相应的RS模板的hash值
	- 动态调整VS上route中Canary subset和Stable subset的weight进行流量迁移
- 提示：这个Canary期间VS的动态调整可能会导致通过GitOps自动化部署时的问题：权重的瞬时摆动
- 总结：例如stable有5个pod，此时发布canary，则这时rollout会新建1个pod到canary中，而stable中5个pod不会减少，直到canary中5个pod运行正常后等待大概30s后再删除stable5个pod，其中最多会有10个pod并存。而rollout会将canary改成stable, stable改成canary
- 总结：istio可以精细化流量，例如10个pod，5%流量时会新建1个pod，10%流量时也只有1个pod，而20%流量时会有2个pod



实战案例2

```bash
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# cat 02-argo-rollouts-with-istio-traffic-shifting.yaml

# rollout结合istio会自动配置canary的weight来达到滚动发布

---

apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollouts-helloworld-with-traffic-shifting
spec:
  replicas: 5		#副本数
  strategy:			#更新策略
    canary:			#canary策略
      trafficRouting:	#流量路由方法
        istio:			#使用istio
          virtualService:
            name: helloworld-rollout-vsvc        # VS名称
            routes:
            - primary                 # route名称
          destinationRule:
            name: helloworld-rollout-destrule    # DR名称
            canarySubsetName: canary  # canary子集名称
            stableSubsetName: stable  # stable子集名称
      steps:
      - setCanaryScale:
          matchTrafficWeight: true	#配置流量跟权重相等
      - setWeight: 5				#配置权重为5
      - pause: {duration: 1m}		#暂停1分钟
      - setWeight: 10				#随后权重加到10
      - pause: {duration: 20}
      - setWeight: 20
      - pause: {duration: 20}
      - setWeight: 60
      - pause: {duration: 20}
      - setWeight: 80				#权重为80，并暂停20秒
      - pause: {duration: 20}
  revisionHistoryLimit: 5			#保留5个历史版本
  selector:
    matchLabels:
      app: spring-boot-helloworld	#匹配pod的标签
  template:
    metadata:
      labels:
        app: spring-boot-helloworld		#pod模板的标签
    spec:
      containers:
      - name: spring-boot-helloworld
        image: ikubernetes/spring-boot-helloworld:v0.9.5
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        resources:
          requests:
            memory: 32Mi
            cpu: 50m
        livenessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP
          initialDelaySeconds: 3
        readinessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP

          initialDelaySeconds: 5
---

apiVersion: v1
kind: Service
metadata:
  name: spring-boot-helloworld
spec:
  ports:

  - port: 80
    targetPort: http
    protocol: TCP
    name: http
    selector:
    app: spring-boot-helloworld

---

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: helloworld-rollout-vsvc
spec:
  #gateways:
  #- istio-rollout-gateway
  hosts:

  - spring-boot-helloworld		#访问VS host名称时会走如下route
    http:
  - name: primary       # 定义route，rollout上面会调用，初始流量权重
    route:
    - destination:
      host: spring-boot-helloworld	#DR 名称
      subset: stable  # 子集名称
      weight: 100		#权重为100
    - destination:
      host: spring-boot-helloworld	#DR 名称
      subset: canary  # 子集名称
      weight: 0			#权重为0

---

apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: helloworld-rollout-destrule
spec:
  host: spring-boot-helloworld		#匹配VS host
  subsets:

  - name: canary   #子集名称
    labels:        
      app: spring-boot-helloworld
  - name: stable   
    labels:        #子集名称
      app: spring-boot-helloworld

---

#部署
root@k8s-master01:~# kubectl create namespace demo
namespace/demo created
root@k8s-master01:~# kubectl label namespace demo istio-injection=enabled	#为demo空间自动注入sidecar
namespace/demo labeled
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl apply -f 02-argo-rollouts-with-istio-traffic-shifting.yaml -n demo
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl get vs -n demo
NAME                      GATEWAYS   HOSTS                        AGE
helloworld-rollout-vsvc              ["spring-boot-helloworld"]   3m11s
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl get dr -n demo
NAME                          HOST                     AGE
helloworld-rollout-destrule   spring-boot-helloworld   2m56s

#部署客户端请求 http://spring-boot-helloworld.demo.svc测试
root@k8s-master01:~/istio-1.13.3# export ISTIO_DIR=/root/istio-1.13.3
root@k8s-master01:~/istio-1.13.3# kubectl apply -f ${ISTIO_DIR}/samples/sleep/sleep.yaml
serviceaccount/sleep created
service/sleep created
deployment.apps/sleep created
root@k8s-master01:~/istio-1.13.3# export SLEEP=$(kubectl get pods -l app=sleep -o jsonpath='{.items[0].metadata.name}')
root@k8s-master01:~/istio-1.13.3# kubectl exec -it $SLEEP -- /bin/sh
/ $ while true; do curl http://spring-boot-helloworld.demo.svc.cluster.local/version; echo; sleep 1; done	#没有注入sidecar客户端
version 0.9.5
version 0.9.5

----升级镜像
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts set image rollouts-helloworld-with-traffic-shifting spring-boot-helloworld=ikubernetes/spring-boot-helloworld:v0.9.6 -n demo

----监视VS权重 
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl get vs helloworld-rollout-vsvc -o yaml -w -n demo
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.istio.io/v1beta1","kind":"VirtualService","metadata":{"annotations":{},"name":"helloworld-rollout-vsvc","namespace":"demo"},"spec":{"hosts":["spring-boot-helloworld"],"http":[{"name":"primary","route":[{"destination":{"host":"spring-boot-helloworld","subset":"stable"},"weight":100},{"destination":{"host":"spring-boot-helloworld","subset":"canary"},"weight":0}]}]}}
  creationTimestamp: "2022-05-20T03:04:04Z"
  generation: 1
  name: helloworld-rollout-vsvc
  namespace: demo
  resourceVersion: "926989"
  uid: 39821923-14ce-4fff-9ba0-056344a3ae7d
spec:
  hosts:

  - spring-boot-helloworld
    http:
  - name: primary
    route:
    - destination:
      host: spring-boot-helloworld
      subset: stable
      weight: 100
    - destination:
      host: spring-boot-helloworld
      subset: canary
      weight: 0

---

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"networking.istio.io/v1beta1","kind":"VirtualService","metadata":{"annotations":{},"name":"helloworld-rollout-vsvc","namespace":"demo"},"spec":{"hosts":["spring-boot-helloworld"],"http":[{"name":"primary","route":[{"destination":{"host":"spring-boot-helloworld","subset":"stable"},"weight":100},{"destination":{"host":"spring-boot-helloworld","subset":"canary"},"weight":0}]}]}}
  creationTimestamp: "2022-05-20T03:04:04Z"
  generation: 2
  name: helloworld-rollout-vsvc
  namespace: demo
  resourceVersion: "928127"
  uid: 39821923-14ce-4fff-9ba0-056344a3ae7d
spec:
  hosts:

  - spring-boot-helloworld
    http:
  - name: primary
    route:
    - destination:
      host: spring-boot-helloworld
      subset: stable
      weight: 95
    - destination:
      host: spring-boot-helloworld
      subset: canary
      weight: 5		#从0变成5权重了，后续为10，20，60，80

root@k8s-master01:~/istio-1.13.3# kubectl exec -it $SLEEP -- /bin/sh
/ $ while true; do curl http://spring-boot-helloworld.demo.svc.cluster.local/version; echo; sleep 1; done
version 0.9.5
Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6

version 0.9.5
Spring Boot Helloworld, version 0.9.6

upstream connect error or disconnect/reset before headers. reset reason: connection failure, transport failure reason: delayed connect error: 111		#此报错是因为删除旧pod时还有连接在pod所以会报此错误
Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6
```





### 分析和渐进式交付

- Argo Rollouts中的分析（Analysis）是用于根据阶段性交付效果的测量结果来推动渐进式交付的机制
  - 分析机制通过分析模板（AnalysisTemplate CRD）定义，而后在Rollout中调用它
  - 运行某次特定的交付过程时，Argo Rollouts会将该Rollout调用的AnalysisTemplate实例化为AnalysisRun（CRD）
  

AnalysisTemplate CRD资源规范
- AnalysisTemplate CRD资源规范
  - metrics <[]Object>: 必选字段，定义用于对交付效果进行分析的指标，常用的嵌套字段有如下几个
    - name <string>: 指标名称，必选字段
	- provider <Object>: 指标供应方，支持prometheus, web, job, graphite等，使用prometheus时支持嵌套如下字段
	  - address <string>: Prometheus服务的访问入口
	  - query <string>: 向Prometheus服务发起的查询请求（PromQL）
	- successCondition <string>: 测量结果为"成功"的条件表达式
	- interval <string>: 多次测试时的测试间隔时长
	- count <integer>: 总共测试的次数
  - args <[]Object>: 模板参数，模板内部引用的格式为"{{args.NAME}}"; 可在调用该模板时对其赋值
    - name <string>
	- value <string>
	- valueFrom <string>
  - dryRun <[]Object>: 运行于dryRun模式的metric列表，这些metic的结果不会影响最终分析结果
    - metricName <string>
  - measurementRetention <[]Object>: 测量结果历史的保留数，dryRun模式的参数与支持历史结果保留
    - metricName <string>: 指标名称
	- limit <string>: 保留数量
	



### 部署istio prometheus插件
```bash
root@k8s-master01:~/istio-1.13.3/samples/addons# kubectl apply -f .
root@k8s-master01:~/istio-1.13.3/samples/addons# kubectl get pods -n istio-system
NAME                                    READY   STATUS    RESTARTS        AGE
grafana-67f5ccd9d7-9pxxl                1/1     Running   0               12m
istio-ingressgateway-6dc56fc9f9-kqhzd   1/1     Running   1 (2d12h ago)   2d12h
istio-ingressgateway-6dc56fc9f9-lmvf9   1/1     Running   0               2d12h
istio-ingressgateway-6dc56fc9f9-st94k   1/1     Running   0               2d12h
istiod-8488b9bdc7-7vpnt                 1/1     Running   0               2d12h
istiod-8488b9bdc7-lqfxr                 1/1     Running   2 (2d12h ago)   2d12h
istiod-8488b9bdc7-xrdhq                 1/1     Running   0               2d12h
kiali-c946fb5bc-857gd                   1/1     Running   0               12m
prometheus-7cc96d969f-pmdtt             2/2     Running   0               12m
#将prometheus服务暴露出去
root@k8s-master01:~/istio-in-practise/Traffic-Management-Basics/prometheus# cat prometheus-gateway.yaml
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: prometheus-gateway
  namespace: istio-system
spec:
  selector:
    app: istio-ingressgateway
  servers:

  - port:
    number: 80
    name: http
    protocol: HTTP
    hosts:
    - "prometheus.magedu.com"

---

root@k8s-master01:~/istio-in-practise/Traffic-Management-Basics/prometheus# cat prometheus-destinationrule.yaml
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: prometheus
  namespace: istio-system
spec:
  host: prometheus
  trafficPolicy:
    tls:

      mode: DISABLE
---

root@k8s-master01:~/istio-in-practise/Traffic-Management-Basics/prometheus# cat prometheus-virtualservice.yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: prometheus-virtualservice
  namespace: istio-system
spec:
  hosts:

  - "prometheus.magedu.com"
    gateways:
  - prometheus-gateway
    http:
  - match:
    - uri:
      prefix: /
      route:
    - destination:
      host: prometheus
      port:
        number: 9090

---

root@k8s-master01:~/istio-in-practise/Traffic-Management-Basics/prometheus# kubectl apply -f .
destinationrule.networking.istio.io/prometheus created
gateway.networking.istio.io/prometheus-gateway created
virtualservice.networking.istio.io/prometheus-virtualservice created

172.1682.28 prometheus.magedu.com	#做好hosts解析并访问prometheus.magedu.com
```



### 渐进式交付示例

```bash
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# cat 03-argo-rollouts-with-analysis.yaml

# CopyRight: MageEdu <http://www.magedu.com>

---

apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate		#analysis模板
metadata:
  name: success-rate
spec:
  args:

  - name: service-name	#定义参数，调用者会传入此参数的值
    metrics:

  - name: success-rate

    # NOTE: prometheus queries return results in the form of a vector.

    # So it is common to access the index 0 of the returned array to obtain the value

    successCondition: result[0] >= 0.95		#当查询结果>= 0.95时将会继续发布，否则将会回滚
    interval: 20s		#每20s执行一次查询
    #count: 3			#没有确定次数将会一直查询
    failureLimit: 3		#限制失败次数为3
    provider:
      prometheus:
        address: http://prometheus.istio-system.svc.cluster.local:9090	#prometheus地址，下面是查询语句
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[1m]	
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[1m]	
          ))
    	  #报告者是发起者，destination_service调用传入的参数值，如果reporter="source"无值则可换成reporter="destination"(服务网格外访问时无source，当服务网格内访问时有source)

---

apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollouts-helloworld-with-analysis
spec:
  replicas: 3
  strategy:
    canary:
      trafficRouting:
        istio:
          virtualService:
            name: helloworld-rollout-vsvc
            routes:
            - primary
          destinationRule:
            name: helloworld-rollout-destrule
            canarySubsetName: canary
            stableSubsetName: stable
      analysis:
        templates:
        - templateName: success-rate	#引用AnalysisTemplate
        args:
        - name: service-name
          # change this value to your service name
          value: spring-boot-helloworld.demo.svc.cluster.local		#传入service-name参数的值，这里填错地址可以模拟分析失败的情景
        startingStep: 2		#在第二个步骤结束后开始进行分析
      steps:
      - setWeight: 5
      - pause: {duration: 1m}		#从这步完成后开始分析
      - setWeight: 10		
      - pause: {duration: 1m}
      - setWeight: 30
      - pause: {duration: 1m}
      - setWeight: 60
      - pause: {duration: 1m}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: spring-boot-helloworld
  template:
    metadata:
      labels:
        app: spring-boot-helloworld
    spec:
      containers:
      - name: spring-boot-helloworld
        image: ikubernetes/spring-boot-helloworld:v0.9.5
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        resources:
          requests:
            memory: 32Mi
            cpu: 50m
        livenessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP
        readinessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP

          initialDelaySeconds: 5
---

apiVersion: v1
kind: Service
metadata:
  name: spring-boot-helloworld
spec:
  ports:

  - port: 80
    targetPort: http
    protocol: TCP
    name: http
    selector:
    app: spring-boot-helloworld

---

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: helloworld-rollout-vsvc
spec:
  #gateways:
  #- istio-rollout-gateway
  hosts:

  - spring-boot-helloworld
    http:
  - name: primary
    route:
    - destination:
      host: spring-boot-helloworld
      subset: stable
      weight: 100
    - destination:
      host: spring-boot-helloworld
      subset: canary
      weight: 0

---

apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: helloworld-rollout-destrule
spec:
  host: spring-boot-helloworld
  subsets:

  - name: canary
    labels:
      app: spring-boot-helloworld
  - name: stable
    labels:
      app: spring-boot-helloworld

---

root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl apply -f 03-argo-rollouts-with-analysis.yaml -n demo
#测试收集指标
root@k8s-master01:~/istio-1.13.3# kubectl apply -f samples/sleep/sleep.yaml -n demo	#必须在网格内
root@k8s-master01:~/istio-1.13.3# kubectl exec -it sleep-698cfc4445-brc2w -n demo -- /bin/sh
/ $ while true; do curl http://spring-boot-helloworld.demo.svc.cluster.local/version; echo; sleep 0.$RANDOM; done
version 0.9.5
version 0.9.5
--发布新版本
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts set image rollouts-helloworld-with-analysis spring-boot-helloworld=ikubernetes/spring-boot-helloworld:v0.9.6 -n demo

/ $ while true; do curl http://spring-boot-helloworld.demo.svc.cluster.local/version; echo; sleep 0.$RANDOM; done
Spring Boot Helloworld, version 0.9.6

Spring Boot Helloworld, version 0.9.6
```



### rollout更新策略之blueGreen

- blueGreen
  - spec.strategy.blueGreen
  - 支持内嵌的关键字段
    - activeService <string>: 当前活动状态的服务，也是即将更新的服务
	- previewService <string>: 预览版的服务，也是要更新成的目标服务版本
	- autoPromotionEnabled <boolean>: 是否允许自动进行Promote
	- autoPromotionSeconds <integer>: 在指定的时长之后执行Promote
	- maxUnavailable <integer> OR <percentage>: 更新期间最多允许处于不可用状态的Pod数量或百分比
	- previewReplicaCount <ingeter>: preview版本RS应运行的Podovt，默认为100%
	- previewMetadata <Object>: 更新期间添加到preview版本相关Pod上的元数据
	- prePromotionAnalysis <Object>: Promote操作之前要运行的Analysis，分析的结果决定了Rollout是进行流量切换，还是中止Rollout
	  - args <[]Object>
	  - templates <[]Object>
	  - dryRun <[]Object>
	  - measurementRetention <[]Object>
	- postPromotionAnalysis <[]Object>: Promote操作之后要运行的Analysis，若分析运行失败或出错，则Rollout进入路上状态并将流量切回之前的稳定ReplicaSet
	



### 蓝绿部署结合analysis

```bash
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# cat 06-argo-rollouts-bluegreen-with-analysis.yaml

# CopyRight: MageEdu <http://www.magedu.com>

---

apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:

  - name: service-name
    metrics:
  - name: success-rate
    successCondition: result[0] >= 0.95
    interval: 20s
    count: 5
    failureLimit: 5		#此参数值必须小于等于count
    provider:
      prometheus:
        address: http://prometheus.istio-system.svc.cluster.local:9090
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[1m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[1m]
          ))

---

apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollout-helloworld-bluegreen-with-analysis
spec:
  replicas: 3
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: rollout-helloworld-bluegreen
  template:
    metadata:
      labels:
        app: rollout-helloworld-bluegreen
    spec:
      containers:

   - name: spring-boot-helloworld
     image: ikubernetes/spring-boot-helloworld:v0.9.5
     ports:
     - containerPort: 80
       strategy:
         blueGreen:
           activeService: spring-boot-helloworld				#设定当前版本service名称
           previewService: spring-boot-helloworld-preview	#设定新版本service名称
           prePromotionAnalysis:		#切换前推进分析，就是在previewService服务启动后对此服务进行分析是否成功，成功则进行切换至previewService版本，否则进行回滚
       templates:
     - templateName: success-rate
       args:
     - name: service-name
       value: spring-boot-helloworld-preview.demo.svc.cluster.local
           postPromotionAnalysis:	#切换后推进分析，就是在服务切换为新版本后，再对当前线上提供服务的版本进行分析是否成功，当前版本是activeService，否则进行回滚
       templates:
     - templateName: success-rate
       args:
     - name: service-name
       value: spring-boot-helloworld.demo.svc.cluster.local

      autoPromotionEnabled: true	#是否进行自动推进切换
---

kind: Service
apiVersion: v1
metadata:
  name: spring-boot-helloworld			#当前版本
spec:
  selector:
    app: rollout-helloworld-bluegreen	
  ports:

  - protocol: TCP
    port: 80
    targetPort: 80

---

kind: Service
apiVersion: v1
metadata:
  name: spring-boot-helloworld-preview	#新版本
spec:
  selector:
    app: rollout-helloworld-bluegreen
  ports:

  - protocol: TCP
    port: 80
    targetPort: 80
    root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl apply -f 06-argo-rollouts-bluegreen-with-analysis.yaml -n demo
    ----更新应用
    root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl argo rollouts set image rollout-helloworld-bluegreen-with-analysis spring-boot-helloworld=ikubernetes/spring-boot-helloworld:v0.9.6 -n demo
```



### ArgoCD结合ArgoRollout进行纯自动化部署

```bash
root@front-envoy:~/spring-boot-helloworld-deployment/rollouts/helloworld-canary-with-analysis# cat argo-rollouts-with-analysis.yaml

# CopyRight: MageEdu <http://www.magedu.com>

---

apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:

  - name: service-name
    metrics:

  - name: success-rate

    # NOTE: prometheus queries return results in the form of a vector.

    # So it is common to access the index 0 of the returned array to obtain the value

    successCondition: result[0] >= 0.95
    interval: 20s
    #count: 3
    failureLimit: 3
    provider:
      prometheus:
        address: http://prometheus.istio-system.svc.cluster.local:9090
        query: |
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}",response_code!~"5.*"}[1m]
          )) /
          sum(irate(
            istio_requests_total{reporter="source",destination_service=~"{{args.service-name}}"}[1m]
          ))

---

apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: rollouts-helloworld-with-analysis
spec:
  replicas: 3
  strategy:
    canary:
      trafficRouting:
        istio:
          virtualService:
            name: helloworld-rollout-vsvc
            routes:
            - primary
          destinationRule:
            name: helloworld-rollout-destrule
            canarySubsetName: canary
            stableSubsetName: stable
      analysis:
        templates:
        - templateName: success-rate
        args:
        - name: service-name
          # change this value to your service name
          value: spring-boot-helloworld.demo.svc.cluster.local
        startingStep: 2
      steps:
      - setWeight: 5
      - pause: {duration: 1m}
      - setWeight: 10
      - pause: {duration: 1m}
      - setWeight: 30
      - pause: {duration: 1m}
      - setWeight: 60
      - pause: {duration: 1m}
  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: spring-boot-helloworld
  template:
    metadata:
      labels:
        app: spring-boot-helloworld
    spec:
      containers:
      - name: spring-boot-helloworld
        image: ikubernetes/spring-boot-helloworld:v0.9.5
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        resources:
          requests:
            memory: 32Mi
            cpu: 50m
        livenessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP
        readinessProbe:
          httpGet:
            path: '/'
            port: 80
            scheme: HTTP

          initialDelaySeconds: 5
---

apiVersion: v1
kind: Service
metadata:
  name: spring-boot-helloworld
spec:
  ports:

  - port: 80
    targetPort: http
    protocol: TCP
    name: http
    selector:
    app: spring-boot-helloworld

---

apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: helloworld-rollout-vsvc
spec:
  #gateways:
  #- istio-rollout-gateway
  hosts:

  - spring-boot-helloworld
    http:
  - name: primary
    route:
    - destination:
      host: spring-boot-helloworld
      subset: stable
      weight: 100
    - destination:
      host: spring-boot-helloworld
      subset: canary
      weight: 0

---

apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: helloworld-rollout-destrule
spec:
  host: spring-boot-helloworld
  subsets:

  - name: canary
    labels:
      app: spring-boot-helloworld
  - name: stable
    labels:
      app: spring-boot-helloworld

---

----配置github仓库配置进行直接部署
root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# cat 07-argocd-applicatio-and-argo-rollouts.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: spring-boot-helloworld
  namespace: argocd		#需要部署到argocd名称空间，因为需要application controller进行管理
spec:
  project: default
  source:
    repoURL: https://gitee.com/jacknotes/spring-boot-helloworld-deployment.git
    targetRevision: HEAD
    path: rollouts/helloworld-canary-with-analysis
  destination:
    server: https://kubernetes.default.svc
    # This sample must run in demo namespace.
    namespace: demo
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
    - Validate=false
    - CreateNamespace=true
    - PrunePropagationPolicy=foreground
    - PruneLast=true
    - ApplyOutOfSyncOnly=true
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
    - /spec/http/0		#后期部署新版本时忽略VS中的配置，因为ArgoCD会动态调整VS的权重值，为了避免在动态调整权重值时被ArgoCD重置导致服务异常，我们这里需要忽略
      root@k8s-master01:~/tekton-and-argocd-in-practise/08-argo-rollouts# kubectl apply -f 07-argocd-applicatio-and-argo-rollouts.yaml
      / $ while true; do curl http://spring-boot-helloworld.demo.svc.cluster.local/version; echo; sleep 0.$RANDOM; done
      version 0.9.5
      version 0.9.5
      version 0.9.5

----仓库配置镜像版本为v0.9.6
root@front-envoy:~/spring-boot-helloworld-deployment/rollouts/helloworld-canary-with-analysis# vim argo-rollouts-with-analysis.yaml
root@front-envoy:~/spring-boot-helloworld-deployment/rollouts/helloworld-canary-with-analysis# git add . && git commit -m "update v0.9.6" && git push
/ $ while true; do curl http://spring-boot-helloworld.demo.svc.cluster.local/version; echo; sleep 0.$RANDOM; done
version 0.9.5
version 0.9.5
version 0.9.5
version 0.9.5
Spring Boot Helloworld, version 0.9.6	#自动更新为v0.9.6
version 0.9.5
version 0.9.5
version 0.9.5
Spring Boot Helloworld, version 0.9.6
version 0.9.5
version 0.9.5
version 0.9.5
```















### 云原生课程总结

#实现微服务的几个要素
- 微服务如何落地（容器化，镜像构建，依赖解决，镜像分发，容器中的配置文件参数变更及管理）
- 微服务如何快速扩容（kubernetes实现容器编排与弹性伸缩）
- 微服务之间如何发现对方（注册中心，服务发现）
- 微服务如何治理与访问对方（服务访问 -> restful API, gRPC, Istio, Envoy)
- 微服务如何监控（prometheus)
- 微服务如何升级与回滚（CI/CD）
- 微服务访问日志如何查看（ELK)
- 如何实现请求链路追踪（APM）

#技术栈
- 安全：iptables/CDN/WAF/硬件防火墙/lua
- 负载层：LVS/Haproxy/Nginx/SLB
- 关系型数据库：Mysql/MariaDB/PostgreSQL
- 非关系型数据库：Redis/Memcache/MongoDB
- 列式数据库：ClickHouse/Hbase
- 监控方面：Zabbix/Prometheus/第三方商业监控（监控宝，听云）
- 虚拟化：KVM/OpenStack/VMware
- 分布式存储：Ceph/glusterfs/TFS/MFS/HDFS
- 访问统计：piwik/CCNZ/百度统计/google统计等
- 脚本能力：shell/go/python
- 公有云：阿里云/AWS/Azure/...
- 网络知识：华为/思科
- 容器与编排：docker/containerd/kubernetes/镜像仓库/镜像构建
- 微服务治理相关：istio/envoy/nginx-ingress/apisix/kong/Serverless/Knative
- 链路追踪相关：SkyWalking/jaeger/Zipkin/Pinpoint/OpenTracing
- CI/CD相关：Gitlab/Jenkins/ArgoCD/Tekton/Drone/Spinnaker/DevOps/GitOps/AIOps/NoOps
- 日志收集相关：EFK/ELK/Grafana Loki/第三方商业工具
- 个人能力：学习能力/沟通能力/工作能力其它能力





# 监控argocd



## 部署prometheus-server并监控argocd

```bash
[root@prometheus prometheus]# cat 10-promehteus-server.yaml 

# Source: prometheus/templates/server/serviceaccount.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: prometheus-server

  namespace: kube-system
---

# Source: prometheus/templates/server/cm.yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-server
  namespace: kube-system
data:
  alerting_rules.yml: |
    {}
  alerts: |
    {}
  prometheus.yml: |
    global:
      evaluation_interval: 1m
      scrape_interval: 15s
      scrape_timeout: 10s
    rule_files:
    - /etc/config/recording_rules.yml
    - /etc/config/alerting_rules.yml
    - /etc/config/rules
    - /etc/config/alerts
    scrape_configs:
    - job_name: prometheus
      static_configs:
      - targets:
        - localhost:9090
    - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      job_name: kubernetes-apiservers
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - action: keep
        regex: default;kubernetes;https
        source_labels:
        - __meta_kubernetes_namespace
        - __meta_kubernetes_service_name
        - __meta_kubernetes_endpoint_port_name
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: true
    - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      job_name: kubernetes-nodes
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - replacement: kubernetes.default.svc:443
        target_label: __address__
      - regex: (.+)
        replacement: /api/v1/nodes/$1/proxy/metrics
        source_labels:
        - __meta_kubernetes_node_name
        target_label: __metrics_path__
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: true
    - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
      job_name: kubernetes-nodes-cadvisor
      kubernetes_sd_configs:
      - role: node
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_node_label_(.+)
      - replacement: kubernetes.default.svc:443
        target_label: __address__
      - regex: (.+)
        replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
        source_labels:
        - __meta_kubernetes_node_name
        target_label: __metrics_path__
      scheme: https
      tls_config:
        ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        insecure_skip_verify: true
    - job_name: kubernetes-service-endpoints
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - action: keep
        regex: true
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_scrape
      - action: replace
        regex: (https?)
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_scheme
        target_label: __scheme__
      - action: replace
        regex: (.+)
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_path
        target_label: __metrics_path__
      - action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        source_labels:
        - __address__
        - __meta_kubernetes_service_annotation_prometheus_io_port
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
        replacement: __param_$1
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - action: replace
        source_labels:
        - __meta_kubernetes_namespace
        target_label: namespace
      - action: replace
        source_labels:
        - __meta_kubernetes_service_name
        target_label: service
      - action: replace
        source_labels:
        - __meta_kubernetes_pod_node_name
        target_label: node
    - job_name: kubernetes-service-endpoints-slow
      kubernetes_sd_configs:
      - role: endpoints
      relabel_configs:
      - action: keep
        regex: true
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_scrape_slow
      - action: replace
        regex: (https?)
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_scheme
        target_label: __scheme__
      - action: replace
        regex: (.+)
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_path
        target_label: __metrics_path__
      - action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        source_labels:
        - __address__
        - __meta_kubernetes_service_annotation_prometheus_io_port
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_service_annotation_prometheus_io_param_(.+)
        replacement: __param_$1
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - action: replace
        source_labels:
        - __meta_kubernetes_namespace
        target_label: namespace
      - action: replace
        source_labels:
        - __meta_kubernetes_service_name
        target_label: service
      - action: replace
        source_labels:
        - __meta_kubernetes_pod_node_name
        target_label: node
      scrape_interval: 5m
      scrape_timeout: 30s
    - job_name: argocd-server-metrics
      scrape_interval: 90s
      scrape_timeout: 90s
      metrics_path: /metrics
      scheme: http
      static_configs:
      - targets: ["argocd-metrics.argocd:8082", "argocd-server-metrics.argocd:8083", "argocd-repo-server.argocd:8084"]
    - honor_labels: true
      job_name: prometheus-pushgateway
      kubernetes_sd_configs:
      - role: service
      relabel_configs:
      - action: keep
        regex: pushgateway
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_probe
    - job_name: kubernetes-services
      kubernetes_sd_configs:
      - role: service
      metrics_path: /probe
      params:
        module:
        - http_2xx
      relabel_configs:
      - action: keep
        regex: true
        source_labels:
        - __meta_kubernetes_service_annotation_prometheus_io_probe
      - source_labels:
        - __address__
        target_label: __param_target
      - replacement: blackbox
        target_label: __address__
      - source_labels:
        - __param_target
        target_label: instance
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels:
        - __meta_kubernetes_namespace
        target_label: namespace
      - source_labels:
        - __meta_kubernetes_service_name
        target_label: service
    - job_name: kubernetes-pods
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - action: keep
        regex: true
        source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_scrape
      - action: replace
        regex: (https?)
        source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_scheme
        target_label: __scheme__
      - action: replace
        regex: (.+)
        source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_path
        target_label: __metrics_path__
      - action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        source_labels:
        - __address__
        - __meta_kubernetes_pod_annotation_prometheus_io_port
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
        replacement: __param_$1
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - action: replace
        source_labels:
        - __meta_kubernetes_namespace
        target_label: namespace
      - action: replace
        source_labels:
        - __meta_kubernetes_pod_name
        target_label: pod
      - action: drop
        regex: Pending|Succeeded|Failed|Completed
        source_labels:
        - __meta_kubernetes_pod_phase
    - job_name: kubernetes-pods-slow
      kubernetes_sd_configs:
      - role: pod
      relabel_configs:
      - action: keep
        regex: true
        source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_scrape_slow
      - action: replace
        regex: (https?)
        source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_scheme
        target_label: __scheme__
      - action: replace
        regex: (.+)
        source_labels:
        - __meta_kubernetes_pod_annotation_prometheus_io_path
        target_label: __metrics_path__
      - action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        source_labels:
        - __address__
        - __meta_kubernetes_pod_annotation_prometheus_io_port
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_pod_annotation_prometheus_io_param_(.+)
        replacement: __param_$1
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - action: replace
        source_labels:
        - __meta_kubernetes_namespace
        target_label: namespace
      - action: replace
        source_labels:
        - __meta_kubernetes_pod_name
        target_label: pod
      - action: drop
        regex: Pending|Succeeded|Failed|Completed
        source_labels:
        - __meta_kubernetes_pod_phase
      scrape_interval: 5m
      scrape_timeout: 30s
  recording_rules.yml: |
    {}
  rules: |

    {}
---

# Source: prometheus/templates/server/clusterrole.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  labels:
    app: prometheus-server
  name: prometheus-server
rules:

  - apiGroups:
    - ""
      resources:
    - nodes
    - nodes/proxy
    - nodes/metrics
    - services
    - endpoints
    - pods
    - ingresses
    - configmaps
      verbs:
    - get
    - list
    - watch
  - apiGroups:
    - "extensions"
    - "networking.k8s.io"
      resources:
    - ingresses/status
    - ingresses
      verbs:
    - get
    - list
    - watch
  - nonResourceURLs:
    - "/metrics"
      verbs:
    - get

---

# Source: prometheus/templates/server/clusterrolebinding.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  labels:
    app: prometheus-server
  name: prometheus-server
subjects:

  - kind: ServiceAccount
    name: prometheus-server
    namespace: kube-system
      roleRef:
    apiGroup: rbac.authorization.k8s.io
    kind: ClusterRole
    name: prometheus-server

---

# Source: prometheus/templates/server/service.yaml

apiVersion: v1
kind: Service
metadata:
  labels:
    app: prometheus-server
  name: prometheus-server
  namespace: kube-system
spec:
  ports:
    - name: http
      port: 9090
      protocol: TCP
      targetPort: 9090
      nodePort: 30005
  selector:
    app: prometheus-server
  sessionAffinity: None

  type: "NodePort"
---

# Source: prometheus/templates/server/deploy.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: prometheus-server
  name: prometheus-server
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: prometheus-server
  replicas: 1
  template:
    metadata:
      labels:
        app: prometheus-server
    spec:
      enableServiceLinks: true
      serviceAccountName: prometheus-server
      containers:
        - name: prometheus-server-configmap-reload
          image: "harborrepo.hs.com/k8s/configmap-reload:v0.5.0"
          imagePullPolicy: "IfNotPresent"
          args:
            - --volume-dir=/etc/config
            - --webhook-url=http://127.0.0.1:9090/-/reload
          resources:
            {}
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
              readOnly: true

        - name: prometheus-server
          image: "harborrepo.hs.com/k8s/prometheus:v2.31.1"
          imagePullPolicy: "IfNotPresent"
          args:
            - --storage.tsdb.retention.time=7d
            - --config.file=/etc/config/prometheus.yml
            - --storage.tsdb.path=/data
            - --web.console.libraries=/etc/prometheus/console_libraries
            - --web.console.templates=/etc/prometheus/consoles
            - --web.enable-lifecycle
          ports:
            - containerPort: 9090
          readinessProbe:
            httpGet:
              path: /-/ready
              port: 9090
              scheme: HTTP
            initialDelaySeconds: 0
            periodSeconds: 5
            timeoutSeconds: 4
            failureThreshold: 3
            successThreshold: 1
          livenessProbe:
            httpGet:
              path: /-/healthy
              port: 9090
              scheme: HTTP
            initialDelaySeconds: 30
            periodSeconds: 15
            timeoutSeconds: 10
            failureThreshold: 3
            successThreshold: 1
          resources:
            {}
          volumeMounts:
            - name: config-volume
              mountPath: /etc/config
            - name: storage-volume
              mountPath: /data
              subPath: ""
      hostNetwork: false
      dnsPolicy: ClusterFirst
      securityContext:
        fsGroup: 65534
        runAsGroup: 65534
        runAsNonRoot: true
        runAsUser: 65534
      terminationGracePeriodSeconds: 300
      volumes:
        - name: config-volume
          configMap:
            name: prometheus-server
        - name: storage-volume
          emptyDir:
            {}

---------------------------------

######外部prometheus-server抓取联邦节点的argocd指标(k8s中Prometheus-server是联邦节点)

  - job_name: 'prometheus-federate-kubernetes'
    scheme: http
    metrics_path: /federate
    scrape_interval: 30s
    honor_labels: true
    params:
      'match[]':
      - '{job="argocd-server-metrics"}'
        static_configs:
    - targets: 
      - "monitor.k8s.hs.com"
        ######外部grafana添加argocd Dashboard
        dashboard地址：https://github.com/argoproj/argo-cd/blob/master/examples/dashboard.json


##在deployment或者rollout是添加外部链接
[root@prometheus dotnet]# cat deploy/01-rollout.yaml 
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: pro-dotnet-tripapplicationform-api-hs-com-rollout
  annotations:
    link.argocd.argoproj.io/external-link: http://newjenkins.hs.com/job/tripapplicationform.api.hs.com


#####kustomize例子
[root@prometheus kustomize]# ls
base  fat  pro  uat
[root@prometheus kustomize]# tree .
.
├── base
│   ├── destinationrule.yaml
│   ├── kustomization.yaml
│   ├── rollout.yaml
│   ├── service.yaml
│   └── virtualservice.yaml
├── fat
│   ├── kustomization.yaml
│   ├── patch-rollout.yaml
│   ├── patch-viatualservice.yaml
│   └── replicas-rollout.yaml
├── pro
│   ├── kustomization.yaml
│   ├── patch-rollout.yaml
│   ├── patch-viatualservice.yaml
│   └── replicas-rollout.yaml
└── uat
    ├── kustomization.yaml
    ├── patch-rollout.yaml
    ├── patch-viatualservice.yaml
    └── replicas-rollout.yaml

4 directories, 17 files
[root@prometheus kustomize]# cat base/kustomization.yaml 
resources:

- rollout.yaml
- service.yaml
- virtualservice.yaml
- destinationrule.yaml

[root@prometheus kustomize]# cat base/rollout.yaml 
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: frontend-nginx-hs-com-rollout
spec:
  strategy:
    canary:
      trafficRouting:
        istio:
          virtualService:
            name: frontend-nginx-hs-com-virtualservice
            routes:
            - primary
          destinationRule:
            name: frontend-nginx-hs-com-destinationrule
            canarySubsetName: canary
            stableSubsetName: stable
      steps:

#      - setWeight: 30

#      - pause: {duration: 5}

#      - setWeight: 60

#      - pause: {duration: 5}

      - setWeight: 100

  revisionHistoryLimit: 5
  selector:
    matchLabels:
      app: frontend-nginx-hs-com-selector
  template:
    metadata:
      labels:
        app: frontend-nginx-hs-com-selector
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
          - podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: frontend-nginx-hs-com-selector
              topologyKey: kubernetes.io/hostname
            weight: 50
      containers:
      - name: homsom-container
        image: harborrepo.hs.com/base/helloworld:v1
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          protocol: TCP
          name: http
        resources:
          requests:
            cpu: 100m
            memory: 100Mi
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

[root@prometheus kustomize]# cat base/service.yaml 
apiVersion: v1
kind: Service
metadata:
  name: frontend-nginx-hs-com-service
spec:
  ports:

  - name: http-80
    port: 80
    targetPort: 80
    protocol: TCP
    type: ClusterIP
    selector:
    app: frontend-nginx-hs-com-selector

[root@prometheus kustomize]# cat base/virtualservice.yaml 
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: frontend-nginx-hs-com-virtualservice
spec:
  hosts:

  - "nginx.hs.com"
    gateways:
  - istio-system/general-gateway
    http:
  - name: primary
    route:
    - destination:
      host: frontend-nginx-hs-com-service
      subset: stable
      weight: 100
    - destination:
      host: frontend-nginx-hs-com-service
      subset: canary
      weight: 0

---

[root@prometheus kustomize]# cat base/destinationrule.yaml 
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: frontend-nginx-hs-com-destinationrule
spec:
  host: frontend-nginx-hs-com-service
  subsets:

  - name: canary
    labels:
      app: frontend-nginx-hs-com-selector
  - name: stable
    labels:
      app: frontend-nginx-hs-com-selector
    trafficPolicy:
    tls:
      mode: DISABLE

---

[root@prometheus kustomize]# cat fat/kustomization.yaml 		#fat环境配置清单
bases:

- ../base			#引入base中kustomize中include的配置清单文件

patchesStrategicMerge:		#普通的打补丁方法

- replicas-rollout.yaml		#合并的配置清单文件

patchesJson6902:		#更高级的打补丁方法

- target:
  group: networking.istio.io
  version: v1beta1
  kind: VirtualService
  name: frontend-nginx-hs-com-virtualservice
  path: patch-viatualservice.yaml	#打补丁的参数文件
    [root@prometheus kustomize]# cat fat/replicas-rollout.yaml 
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    metadata:
  name: frontend-nginx-hs-com-rollout
    spec:
  replicas: 1		#使用此replicas覆盖../base中的rollout对象的replicas 
    [root@prometheus kustomize]# cat fat/patch-viatualservice.yaml 
- op: replace
  path: /spec/hosts		#覆盖virtualserver中的hosts名称
  value: 
  - "fat.nginx.hs.com"
    [root@prometheus kustomize]# cat uat/kustomization.yaml 	#uat环境配置清单
    bases:
- ../base

patchesStrategicMerge:

- replicas-rollout.yaml

patchesJson6902:

- target:
  group: networking.istio.io
  version: v1beta1
  kind: VirtualService
  name: frontend-nginx-hs-com-virtualservice
  path: patch-viatualservice.yaml
    [root@prometheus kustomize]# cat uat/replicas-rollout.yaml 
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    metadata:
  name: frontend-nginx-hs-com-rollout
    spec:
  replicas: 1
    [root@prometheus kustomize]# cat uat/patch-viatualservice.yaml 
- op: replace
  path: /spec/hosts
  value: 
  - "uat.nginx.hs.com"
    [root@prometheus kustomize]# cat pro/kustomization.yaml 	#pro环境配置清单
    bases:
- ../base

patchesStrategicMerge:

- replicas-rollout.yaml

patchesJson6902:

- target:
  group: networking.istio.io
  version: v1beta1
  kind: VirtualService
  name: frontend-nginx-hs-com-virtualservice
  path: patch-viatualservice.yaml
    [root@prometheus kustomize]# cat pro/replicas-rollout.yaml 
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    metadata:
  name: frontend-nginx-hs-com-rollout
    spec:
  replicas: 2
    [root@prometheus kustomize]# cat pro/patch-viatualservice.yaml 
- op: replace
  path: /spec/hosts
  value: 
  - "pro.nginx.hs.com"


####argocd API使用
API文档地址：https://argocd.k8s.hs.com/swagger-ui
--获取token
[root@prometheus application]# curl -k https://argocd.k8s.baidu.com/api/v1/session -d $'{"username":"jack","password":"password"}'
{"token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJqYWNrOmxvZ2luIiwiZXhwIjoxNjU5MDg0NDQ1LCJuYmYiOjE2NTg5OTgwNDUsImlhdCI6MTY1ODk5ODA0NSwianRpIjoiZjFmNTExOWMtZWMzZi00MjBkLWE3YWQtMWVmNjM1MjFlDrg8UKyf0ehkSLHpBn6hlVmdA"}

--request message
curl -k https://argocd.k8s.hs.com/api/v1/account -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhcmdvY2QiLCJzdWIiOiJqYWNrOmxvZ2luIiwiZXhwIjoxNjU5MDg0NDQ1LCJuYmYiOjE2NTg5OTgwNDUsImlhdCI6MTY1ODk5ODA0NSwianRpIjoiZjFmNTExOWMtZWMzZi00MjBkLWE3YWQtMWVmNjM1MjFjNmY5In0.6OpjFicb2OQsQGHcWlDrg8UKyf0ehkSLHpBn6hlVmdA" -d '{
  "items": [
    {
      "capabilities": [
        "string"
      ],
      "enabled": true,
      "name": "string",
      "tokens": [
        {
          "expiresAt": "string",
          "id": "string",
          "issuedAt": "string"
        }
      ]
    }
  ]
}'
--response message
{"items":[{"name":"admin","enabled":true,"capabilities":["login"]},{"name":"dev","enabled":true,"capabilities":["login"]},{"name":"jack","enabled":true,"capabilities":["login","apiKey"]},{"name":"ops","enabled":true,"capabilities":["login"]},{"name":"test","enabled":true,"capabilities":["login"]}]}


###argocd使用hpa
[root@prometheus k8s-deploy]# cat hpa-v1.yaml 
apiVersion: autoscaling/v1			#hpa v1只支持CPU，不支持内存
kind: HorizontalPodAutoscaler
metadata:
  name: pro-frontend-nginx-hs-com-rollout
spec:
  maxReplicas: 4
  minReplicas: 2
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
  targetCPUUtilizationPercentage: 20
[root@prometheus k8s-deploy]# cat hpa-v2.yaml 
apiVersion: autoscaling/v2beta2		#argocd目前不支持autoscaling/v2，需要写成v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: pro-frontend-nginx-hs-com-rollout
spec:
  maxReplicas: 4
  minReplicas: 2
  scaleTargetRef:
    apiVersion: argoproj.io/v1alpha1
    kind: Rollout
    name: pro-frontend-nginx-hs-com-rollout
  metrics:

  - type: Resource
    resource:			#resource只能使用memory或者cpu。其它类型有Pods、Object、External、ContainerResource

#      name: memory

#      target: 

#        type: Utilization

#        averageUtilization: 20
    name: cpu						#在同一个类型下，memory和cpu不能同时使用，后者会覆盖前者
    target: 
        type: Utilization
    averageUtilization: 20
```





# argocd使用问题汇总：

```bash
问题1：
ssh连接太繁忙，argocd同步git太频繁，报如下错；
Application pro-java-regionalsource-service-hs-com sync is 'Unknown'.
Application details: <no value>/applications/pro-java-regionalsource-service-hs-com.


    * rpc error: code = Unknown desc = ssh: handshake failed: read tcp 172.20.85.211:39090->192.168.13.213:22: read: connection reset by peer

措施1：
[root@gitlab ~]# vim /etc/ssh/sshd_config 
MaxSessions 1000
MaxStartups 1000
[root@gitlab ~]# service sshd restart
措施2：
调整argocd默认刷新时间为30分钟，默认情况下，控制器每 3m 轮询一次 Git。您可以使用ConfigMaptimeout.reconciliation中的设置来增加此持续时间。argocd-cm的值timeout.reconciliation是一个持续时间字符串，例如60s、或。1m1h1d
[root@prometheus prometheus]# kubectl get cm -n argocd argocd-cm -o yaml
apiVersion: v1
data:
  accounts.dev: login
  accounts.jack: login, apiKey
  accounts.ops: login
  accounts.test: login
  timeout.reconciliation: 30m



问题2：
jenkins pull k8s清单仓库失败，因为git仓库不是全小写地址。
当把git仓库地址变成全小写地址后，在argocd中填写的是大小写地址，此时argocd pull git仓库失败。
当在argocd中把git仓库地址变成全小写后，有argocd中部署应用时偶尔会报如下错误：
Application pro-java-foodmeituan-api-hs-com sync is 'Unknown'.
Application details: <no value>/applications/pro-java-foodmeituan-api-hs-com.


    * rpc error: code = Internal desc = Failed to fetch default: `git fetch origin --tags --force` failed exit status 128: fatal: '/home/git/repositories/k8s-deploy/java-FoodMeituan-api-hs-com.git' does not appear to be a git repository

fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
措施：
从jenkins到git再到k8s，最后到argocd，命名标准化一定要一致，否则会导致雪崩效应的问题。所以需要按照DNS规范来创建使用，例如全小写DNS名称
删除argocd-repo-server POD重建后正常。


问题3：
我忘记了管理员密码，如何重置？
措施：
对于 Argo CD v1.8 及更早版本，初始密码设置为服务器 pod 的名称，根据入门指南。对于 Argo CD v1.9 及更高版本，初始密码可从名为argocd-initial-admin-secret.

# bcrypt(password)=$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa

kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$rRyBsGSHK6.uc8fntPwVIuLVHgsAhAX7TcdrqW/RADU0uh7CaChLa",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

要更改密码，请编辑密码并使用新的 bcrypt 哈希argocd-secret更新该字段。admin.password您可以使用https://www.browserling.com/tools/bcrypt 之类的网站来生成新的哈希值。例如：
另一种选择是删除admin.password和admin.passwordMtime键并重新启动 argocd-server。这将根据入门指南生成一个新密码，因此可以是 pod 的名称（Argo CD 1.8 及更早版本）或存储在密钥中的随机生成的密码（Argo CD 1.9 及更高版本）。


问题4：
git迁移后，argocd如何配置更新git仓库连接
**1 配置known hosts，是ssh客户端配置，不是sshd服务端配置**
root@ansible:~/k8s/application/test-k8s-application/frontend-testf-k8s-hs-com# vim /etc/ssh/ssh_config
Host *
	HashKnownHosts no	# 增加或修改此行为no
root@ansible:~/k8s/application/test-k8s-application/frontend-testf-k8s-hs-com# rm -rf /root/.ssh/known_hosts
root@ansible:~/k8s/application/test-k8s-application/frontend-testf-k8s-hs-com# git pull
The authenticity of host '192.168.13.211 (192.168.13.211)' can't be established.
ECDSA key fingerprint is SHA256:kjKXlkoqq8Qx6V25uNJvId5oYTe0FwAJzhHCPKnhYTM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '192.168.13.211' (ECDSA) to the list of known hosts.
Already up to date.
root@ansible:~/k8s/application/test-k8s-application/frontend-testf-k8s-hs-com# cat /root/.ssh/known_hosts
192.168.13.211 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBHs+fptdg855kofxLC1CQ/MdlUb+rn3rBTl1nZCbtueh+DAd9FbPQOsGIY3P7qA/QxP3It9Bbp7GLbHUSME+e00=

**在argocd中添加known host**
路径：Certificates -> ADD SSH KNOWN HOSTS -> 添加Known host并确定

**2 配置ssh私钥模板**
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds-192.168.13.211
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: git@192.168.13.211:k8s-deploy
  sshPrivateKey: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAqeWuYGY5StShEmZ1mMzBbkHdkazf61hkqZZbwrgnqgzlOGW1
    2GFs/ib1gQrwbmz3dVBJZC9ylndOa8dk7N34yVg+S6hHnRJ2DzIVqT3D5zELhAUZ
    lBLHBGlWZbnxcUSoW3TCwoUvsboK58iOxUWAwj7dUQHnWRXSWUysZiCT82u2i2Z7
    Tbvlai+jDwsMbydxxzOtyF/1XCHKk6Nv8rQ0+pVrIY/1vZvLY5l2rPSNPxASDyhw
    iukItGC7yKeKaCNv0KKBc2+jtkfXAiu8qje4XSufGCwr1R24mmPaY/x5Y6ShOLbk
    zO7N3hlYAcUKrxXplzmSuWoy/5YwMw5HRBNDtQIDAQABAoIBABE6n4JbG3hBM8xf
    45EJQpxhxYxeUZ7WKe8gtlF6x1rxT9V2SwiUaK8lWEQrzdIE7ttQtwCX5zDnDGbV
    o6B5qh8Q+dBGUmzVUG+eDqBJCTLKwHY05jEj7la+L+rE/n0UD1am8pEzXHDTgwOa
    TRAoSjRol5z9am6YTeqMYfdBWn+WxG+q4yMRn37043FFcscMkhF2NFG1pXm8wVfg
    0kQn4jP9K1his61B1OK7/EFWHzc7tpIVl4vjnq+CBqmpb/DQmqpOftYbdEHZfAmZ
    5tzEbLIlqmPzy+6+cahxBBvwwWhDG/ExqkR9Hia5tlktNSGO82/VBSugU/TEs/sk
    7Ymhl0kCgYEA1M+TwdtMiC6BKIKTyHJ4C5SKljSdTGrthHQOw6+pHPz6oAgrQ/R4
    8C0E1JRGHBFNowgxF3frs6zjNyJKEowcYu0goNo/E3u5Wj5AUKxPEwrRZXTTkNnf
    pTaFhN0V1uMIOBlVxtQOWV0gWWtnmfeWJ5QpkwQMYix5LjiA8SPXa3sCgYEAzGCO
    5jVQX3Hm7stLlSqz0w1wtUdqjxS1z8Rv/zHvWI3YczcNLQykHzd4tP8+e8IGARnB
    5bCko2lNXMF6mqvbd2X3ZQFCCYPA4AbKqZjcfoyUch9LW/Fd9E8yNUmy48rHi2Sn
    AxRnP5WMGOaAopvDDSvz11CyMHbzEdrG72lgjo8CgYBDN31YEchOi0HIZdX/zggU
    wEo1v1CfvnZfC7lOHcGwokcXHP1tbV51ngKUknDClMSM5h17aClOiyEJXQ9AZHji
    1jskE0sxADc/RcJSuNoRDa2t+gSJEAgPyvTJTnuDcBo8feQV9QzDNSLum3oRq54F
    ykqHYRP4PkvYSYiQod182QKBgH32ZRxtb4Pj57j1gzgEgaBqgDS6N2rIEOZk48Id
    PK8PfYBFRdGmIOE8hyDGz/PmuVykS2UNYet1U0D/3ljF4xXLupZ+F/1VPuLUTMQK
    eptkeXl84C1irc2NohxFuAO9Tw8SkfzL7na57QbLyixuY+ESXc8u5SQJq/YtKL8V
    B7ZTIZe+mQVi8szUmk2zkXRde3CNtWUuEteEbcoCsSnnw9fjD5m+
    -----END RSA PRIVATE KEY-----
---
查看路径：Repositories -> `CREDENTIALS TEMPLATE URL`
注：确保此私钥对应的公钥已放置到新git中某个用户的`SSH密钥`列表中，并确保这个用户有jenkins项目对应的git项目群组权限 


问题5：
git迁移后，jenkins如何配置跟新git仓库连接（代码仓库），并发布到k8s的新git（yaml配置仓库）
**1 配置jenkins**
在jenkins添加凭据/更新凭据，类型为`SSH Username with private key`，username随便写（用于区别），填入上方的private key

**2 配置jenkins项目使用新凭据**
配置jenkins项目 -> 使用新凭据 -> 配置自由脚本中的k8s的新git（yaml配置仓库）地址
注：使jenkins项目使用git仓库连接（代码仓库）拉代码编译并构建镜像上传到harbor，最后更新镜像到k8s的新git（yaml配置仓库）
`/shell/cicd.sh-192.168.13.211 vue`
GIT_K8S_ADDRESS_PREFIX='git@192.168.13.211:k8s-deploy'	# 更改脚本中的变量地址



# 问题6：
报错：rpc error: code = Unknown desc = ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey], no supported methods remain

原因：gitlab v8.9.2迁移到gitlab v16.6.6后，新gitlab由OpenSSH 7.8及其以后的版本生成的新格式私钥`BEGIN OPENSSH PRIVATE KEY`，在新git服务器上clone时生成的known_hosts，可以得知服务器使用的公钥类型为ed25519，猜测私钥最好使用此跟服务器一样的类型，此服务器的known_host跟客户端不一样，不用能于argocd 
root@git:/# cat /root/.ssh/known_hosts
git.hs.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJkmmcXzBgOp7Nl9PYzYM97pmLwR02xlLTq29FyXHm6R

解决：
1. 客户端生产ed25519类型的密钥对
root@git:/tmp# ssh-keygen -t ed25519 -C "argocd" -f argocd 
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in argocd.
Your public key has been saved in argocd.pub.
The key fingerprint is:
SHA256:/Q4nCabSJQU5PEhFTemvWUu6X5u3S4hhys/Mto4t59k argocd
The key's randomart image is:
+--[ED25519 256]--+
|   ..=++..       |
|    . =.o        |
|       +.        |
|       ...       |
|      . S.+      |
|     . * ++= .   |
|    . o o*=.= .  |
|     .  =B+O +.  |
|        oO%.E.oo |
+----[SHA256]-----+
root@git:/tmp# ll argocd*
-rw------- 1 root root 399 May 24 11:53 argocd
-rw-r--r-- 1 root root  88 May 24 11:53 argocd.pub
2. 客户端使用特定私钥clone
GIT_SSH_COMMAND='ssh -i /tmp/argocd' git clone git@git.hs.com:k8s-deploy/frontend-nginx-hs-com.git
3. 客户端clone生成的known_hosts
root@git:/tmp# cat /root/.ssh/known_hosts 
git.hs.com,192.168.13.206 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKxX5NzvK6Ye2QIJcw/nivjUAg48z5TGWkZEotv8H7D4ZgRdfHOOA8znEU8vsDauVFswhH9QPAlpGT5oBN9Qcgg=
4. 在argoCD中Certificates -> ADD SSH KNOWN HOSTS -> 添加客户端生成的Known host
5. 将argocd.pub的内容添加到gitlab用户的SSH密钥中，
6. 将argocd私钥 添加到argocd中
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds-192.168.13.206
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: git@git.hs.com:k8s-deploy
  sshPrivateKey: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
    QyNTUxOQAAACCQNlDlDLIIU9xdiECDX9aAeitE67C6MtGFo3QEjfyi+QAAAJDkmM4r5JjO
    KwAAAAtzc2gtZWQyNTUxlDlDLIIU9xdiECDX9aAeitE67C6MtGFo3QEjfyi+Q
    AAAECJZs70bI5FHsAmb9Rct+hYgQSD6vPL7oyvjKrio0aV+pA2UOUMsghT3F2IQINf1oB6
    K0TrsLoy0YWjdASN/KL5AAAABmFyZ29jZAECAwQFBgc=
    -----END OPENSSH PRIVATE KEY-----
7. argoCD中刷新application即可，状态变为正常可用。
```