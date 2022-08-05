#containerd


##containerd安装

###安装依赖
sudo apt-get update
sudo apt-get install libseccomp2

##下载并解压 Containerd 程序
Containerd 提供了两个压缩包，一个叫 containerd-${VERSION}.${OS}-${ARCH}.tar.gz，另一个叫 cri-containerd-${VERSION}.${OS}-${ARCH}.tar.gz。其中 cri-containerd-${VERSION}.${OS}-${ARCH}.tar.gz 包含了所有 Kubernetes 需要的二进制文件。如果你只是本地测试，可以选择前一个压缩包；如果是作为 Kubernetes 的容器运行时，需要选择后一个压缩包。

Containerd 是需要调用 runc 的，而第一个压缩包是不包含 runc 二进制文件的，如果你选择第一个压缩包，还需要提前安装 runc。所以我建议直接使用 cri-containerd 压缩包。

wget https://github.com/containerd/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-amd64.tar.gz	#原下载地址
wget https://download.fastgit.org/containerd/containerd/releases/download/v1.4.3/cri-containerd-cni-1.4.3-linux-amd64.tar.gz	#加速下载

tar --no-overwrite-dir -C / -xvf cri-containerd-cni-1.4.3-linux-amd64.tar.gz
export PATH=$PATH:/usr/local/bin:/usr/local/sbin
source ~/.bashrc

ctr version
Client:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  Go version: go1.15.5

ctr: failed to dial "/run/containerd/containerd.sock": context deadline exceeded

###生成配置文件
mkdir /etc/containerd
containerd config default > /etc/containerd/config.toml
systemctl start containerd

root@k8s-node02:~# ctr version
Client:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  Go version: go1.15.5

Server:
  Version:  v1.4.3
  Revision: 269548fa27e0089a8b8278fc4fc781d7f65a939b
  UUID: cff7714a-8695-4618-9728-aaf9f86c72fc


#配置镜像加速
由于某些不可描述的因素，在国内拉取公共镜像仓库的速度是极慢的，为了节约拉取时间，需要为 Containerd 配置镜像仓库的 mirror。Containerd 的镜像仓库 mirror 与 Docker 相比有两个区别：
1. Containerd 只支持通过 CRI 拉取镜像的 mirror，也就是说，只有通过 crictl 或者 Kubernetes 调用时 mirror 才会生效，通过 ctr 拉取是不会生效的。
2. Docker 只支持为 Docker Hub 配置 mirror，而 Containerd 支持为任意镜像仓库配置 mirror。
配置镜像加速之前，先来看下 Containerd 的配置结构，乍一看可能会觉得很复杂，复杂就复杂在 plugin 的配置部分：

root@k8s-node02:~# cat /etc/containerd/config.toml
version = 2
root = "/var/lib/containerd"
state = "/run/containerd"
plugin_dir = ""
disabled_plugins = []
required_plugins = []
oom_score = 0

[grpc]
  address = "/run/containerd/containerd.sock"
  tcp_address = ""
  tcp_tls_cert = ""
  tcp_tls_key = ""
  uid = 0
  gid = 0
  max_recv_message_size = 16777216
  max_send_message_size = 16777216

[ttrpc]
  address = ""
  uid = 0
  gid = 0

[debug]
  address = ""
  uid = 0
  gid = 0
  level = ""

[metrics]
  address = ""
  grpc_histogram = false

[cgroup]
  path = ""

[timeouts]
  "io.containerd.timeout.shim.cleanup" = "5s"
  "io.containerd.timeout.shim.load" = "5s"
  "io.containerd.timeout.shim.shutdown" = "3s"
  "io.containerd.timeout.task.state" = "2s"

[plugins]
  [plugins."io.containerd.gc.v1.scheduler"]
    pause_threshold = 0.02
    deletion_threshold = 0
    mutation_threshold = 100
    schedule_delay = "0s"
    startup_delay = "100ms"
  [plugins."io.containerd.grpc.v1.cri"]
    disable_tcp_service = true
    stream_server_address = "127.0.0.1"
    stream_server_port = "0"
    stream_idle_timeout = "4h0m0s"
    enable_selinux = false
    selinux_category_range = 1024
    sandbox_image = "k8s.gcr.io/pause:3.2"
    stats_collect_period = 10
    systemd_cgroup = false
    enable_tls_streaming = false
    max_container_log_line_size = 16384
    disable_cgroup = false
    disable_apparmor = false
    restrict_oom_score_adj = false
    max_concurrent_downloads = 3
    disable_proc_mount = false
    unset_seccomp_profile = ""
    tolerate_missing_hugetlb_controller = true
    disable_hugetlb_controller = true
    ignore_image_defined_volumes = false
    [plugins."io.containerd.grpc.v1.cri".containerd]
      snapshotter = "overlayfs"
      default_runtime_name = "runc"
      no_pivot = false
      disable_snapshot_annotations = true
      discard_unpacked_layers = false
      [plugins."io.containerd.grpc.v1.cri".containerd.default_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
        base_runtime_spec = ""
      [plugins."io.containerd.grpc.v1.cri".containerd.untrusted_workload_runtime]
        runtime_type = ""
        runtime_engine = ""
        runtime_root = ""
        privileged_without_host_devices = false
        base_runtime_spec = ""
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          runtime_engine = ""
          runtime_root = ""
          privileged_without_host_devices = false
          base_runtime_spec = ""
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
      conf_dir = "/etc/cni/net.d"
      max_conf_num = 1
      conf_template = ""
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://registry-1.docker.io"]
    [plugins."io.containerd.grpc.v1.cri".image_decryption]
      key_model = ""
    [plugins."io.containerd.grpc.v1.cri".x509_key_pair_streaming]
      tls_cert_file = ""
      tls_key_file = ""
  [plugins."io.containerd.internal.v1.opt"]
    path = "/opt/containerd"
  [plugins."io.containerd.internal.v1.restart"]
    interval = "10s"
  [plugins."io.containerd.metadata.v1.bolt"]
    content_sharing_policy = "shared"
  [plugins."io.containerd.monitor.v1.cgroups"]
    no_prometheus = false
  [plugins."io.containerd.runtime.v1.linux"]
    shim = "containerd-shim"
    runtime = "runc"
    runtime_root = ""
    no_shim = false
    shim_debug = false
  [plugins."io.containerd.runtime.v2.task"]
    platforms = ["linux/amd64"]
  [plugins."io.containerd.service.v1.diff-service"]
    default = ["walking"]
  [plugins."io.containerd.snapshotter.v1.devmapper"]
    root_path = ""
    pool_name = ""
    base_image_size = ""
    async_remove = false
---

每一个顶级配置块的命名都是 plugins."io.containerd.xxx.vx.xxx" 这种形式，其实每一个顶级配置块都代表一个插件，其中 io.containerd.xxx.vx 表示插件的类型，vx 后面的 xxx 表示插件的 ID。可以通过 ctr 一览无余：
root@k8s-node02:~# ctr plugin ls
TYPE                            ID                       PLATFORMS      STATUS
io.containerd.content.v1        content                  -              ok
io.containerd.snapshotter.v1    aufs                     linux/amd64    ok
io.containerd.snapshotter.v1    btrfs                    linux/amd64    error
io.containerd.snapshotter.v1    devmapper                linux/amd64    error
io.containerd.snapshotter.v1    native                   linux/amd64    ok
io.containerd.snapshotter.v1    overlayfs                linux/amd64    ok
io.containerd.snapshotter.v1    zfs                      linux/amd64    error
io.containerd.metadata.v1       bolt                     -              ok
io.containerd.differ.v1         walking                  linux/amd64    ok
io.containerd.gc.v1             scheduler                -              ok
io.containerd.service.v1        introspection-service    -              ok
io.containerd.service.v1        containers-service       -              ok
io.containerd.service.v1        content-service          -              ok
io.containerd.service.v1        diff-service             -              ok
io.containerd.service.v1        images-service           -              ok
io.containerd.service.v1        leases-service           -              ok
io.containerd.service.v1        namespaces-service       -              ok
io.containerd.service.v1        snapshots-service        -              ok
io.containerd.runtime.v1        linux                    linux/amd64    ok
io.containerd.runtime.v2        task                     linux/amd64    ok
io.containerd.monitor.v1        cgroups                  linux/amd64    ok
io.containerd.service.v1        tasks-service            -              ok
io.containerd.internal.v1       restart                  -              ok
io.containerd.grpc.v1           containers               -              ok
io.containerd.grpc.v1           content                  -              ok
io.containerd.grpc.v1           diff                     -              ok
io.containerd.grpc.v1           events                   -              ok
io.containerd.grpc.v1           healthcheck              -              ok
io.containerd.grpc.v1           images                   -              ok
io.containerd.grpc.v1           leases                   -              ok
io.containerd.grpc.v1           namespaces               -              ok
io.containerd.internal.v1       opt                      -              ok
io.containerd.grpc.v1           snapshots                -              ok
io.containerd.grpc.v1           tasks                    -              ok
io.containerd.grpc.v1           version                  -              ok
io.containerd.grpc.v1           cri                      linux/amd64    ok
---

顶级配置块下面的子配置块表示该插件的各种配置，比如 cri 插件下面就分为 containerd、cni 和 registry 的配置，而 containerd 下面又可以配置各种 runtime，还可以配置默认的 runtime。镜像加速的配置就在 cri 插件配置块下面的 registry 配置块，所以需要修改的部分如下：
    [plugins."io.containerd.grpc.v1.cri".registry]
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          endpoint = ["https://dockerhub.mirrors.nwafu.edu.cn"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
          endpoint = ["https://registry.aliyuncs.com/k8sxio"]
registry.mirrors.“xxx” : 表示需要配置 mirror 的镜像仓库。例如，registry.mirrors."docker.io" 表示配置 docker.io 的 mirror。
endpoint : 表示提供 mirror 的镜像加速服务。例如，这里推荐使用西北农林科技大学提供的镜像加速服务作为 docker.io 的 mirror。


##存储配置
Containerd 有两个不同的存储路径，一个用来保存持久化数据，一个用来保存运行时状态。
root = "/var/lib/containerd"
state = "/run/containerd"

root用来保存持久化数据，包括 Snapshots, Content, Metadata 以及各种插件的数据。每一个插件都有自己单独的目录，Containerd 本身不存储任何数据，它的所有功能都来自于已加载的插件，真是太机智了。
root@k8s-node02:~# tree -L 2 /var/lib/containerd/
/var/lib/containerd/
|-- io.containerd.content.v1.content
|   `-- ingest
|-- io.containerd.grpc.v1.introspection
|   `-- uuid
|-- io.containerd.metadata.v1.bolt
|   `-- meta.db
|-- io.containerd.runtime.v1.linux
|-- io.containerd.runtime.v2.task
|-- io.containerd.snapshotter.v1.aufs
|   `-- snapshots
|-- io.containerd.snapshotter.v1.btrfs
|-- io.containerd.snapshotter.v1.native
|   `-- snapshots
|-- io.containerd.snapshotter.v1.overlayfs
|   `-- snapshots
`-- tmpmounts

state 用来保存临时数据，包括 sockets、pid、挂载点、运行时状态以及不需要持久化保存的插件数据。
root@k8s-node02:~# tree -L 2 /run/containerd/
/run/containerd/
|-- containerd.sock
|-- containerd.sock.ttrpc
|-- io.containerd.runtime.v1.linux
`-- io.containerd.runtime.v2.task


##OOM
还有一项配置需要留意：
oom_score = 0
Containerd 是容器的守护者，一旦发生内存不足的情况，理想的情况应该是先杀死容器，而不是杀死 Containerd。所以需要调整 Containerd 的 OOM 权重，减少其被 OOM Kill 的几率。最好是将 oom_score 的值调整为比其他守护进程略低的值。这里的 oom_socre 其实对应的是 /proc/<pid>/oom_socre_adj，在早期的 Linux 内核版本里使用 oom_adj 来调整权重, 后来改用 oom_socre_adj 了。

在计算最终的 badness score 时，会在计算结果是中加上 oom_score_adj ,这样用户就可以通过该在值来保护某个进程不被杀死或者每次都杀某个进程。其取值范围为 -1000 到 1000。如果将该值设置为 -1000，则进程永远不会被杀死，因为此时 badness score 永远返回0。建议 Containerd 将该值设置为 -999 到 0 之间。如果作为 Kubernetes 的 Worker 节点，可以考虑设置为 -999。


##Systemd 配置
建议通过 systemd 配置 Containerd 作为守护进程运行，配置文件在上文已经被解压出来了：
root@k8s-node02:~# cat /etc/systemd/system/containerd.service
# Copyright The containerd Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd

Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
# Comment TasksMax if your systemd version does not supports it.
# Only systemd 226 and above support this version.
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
---
这里有两个重要的参数：
Delegate : 这个选项允许 Containerd 以及运行时自己管理自己创建的容器的 cgroups。如果不设置这个选项，systemd 就会将进程移到自己的 cgroups 中，从而导致 Containerd 无法正确获取容器的资源使用情况。
KillMode : 这个选项用来处理 Containerd 进程被杀死的方式。默认情况下，systemd 会在进程的 cgroup 中查找并杀死 Containerd 的所有子进程，这肯定不是我们想要的。KillMode字段可以设置的值如下：
	control-group（默认值）：当前控制组里面的所有子进程，都会被杀掉
	process：只杀主进程
	mixed：主进程将收到 SIGTERM 信号，子进程收到 SIGKILL 信号
	none：没有进程会被杀掉，只是执行服务的 stop 命令。
	我们需要将 KillMode 的值设置为 process，这样可以确保升级或重启 Containerd 时不杀死现有的容器。



##ctr使用
ctr 目前很多功能做的还没有 docker 那么完善，但基本功能已经具备了。下面将围绕镜像和容器这两个方面来介绍其使用方法。

###镜像下载
root@k8s-node02:~# ctr image pull harborrepo.hs.com/base/helloworld:v3
ctr: failed to resolve reference "harborrepo.hs.com/base/helloworld:v3": failed to do request: Head "https://harborrepo.hs.com/v2/base/helloworld/manifests/v3": dial tcp 192.168.13.197:443: connect: connection refused
原因：默认情况下，ctr 将用于https处理请求。如果注册表是http服务器，我们应该使用--plain-http参数，如果是不受信任的https，则使用--skip-verify。

root@k8s-node02:~# ctr image pull --plain-http=true harborrepo.hs.com/base/helloworld:v3
harborrepo.hs.com/base/helloworld:v3:                                             resolved       |++++++++++++++++++++++++++++++++++++++|
manifest-sha256:263cc12a1f7d1be13d95cd1523d48003237152410f6ec67622320c36b2102265: done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:d803b651eb66cd2f6b4e768a27f06b5115020e718fa48d8b9d7c111428a39dfe:    done           |++++++++++++++++++++++++++++++++++++++|
config-sha256:e2f06283a88efa8dbefcb2c34701898c8e559edbf5c322a56a019fc29c8ef216:   done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:2408cc74d12b6cd092bb8b516ba7d5e290f485d3eb9672efc00f0583730179e8:    done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:90950720101a3473a4f622d73637b3462980acf5c1eb611c1bf014056f37c112:    done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:506a8a07806b68fceded1e745f91621cde12fd9e6f3d43da51679249a46ca5bf:    done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:f624b86dc08299257d3d87fa74cc080cf8ff53c6308e06f043d10ef1bb2bf217:    done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:735bfeb5dcedfc40d8d7e3dfeb31cbf7ea8fe9b59daeddd09b090b25d73e76f9:    done           |++++++++++++++++++++++++++++++++++++++|
layer-sha256:50450591706f943301643c60c642c62b053aeecfeaec448e822087c4a2350cf2:    done           |++++++++++++++++++++++++++++++++++++++|
elapsed: 1.7 s                                                                    total:  8.7 Mi (5.1 MiB/s)
unpacking linux/amd64 sha256:263cc12a1f7d1be13d95cd1523d48003237152410f6ec67622320c36b2102265...
done

###镜像查看
root@k8s-node02:~# ctr i ls
REF                                  TYPE                                                 DIGEST                                                                  SIZE    PLATFORMS   LABELS
harborrepo.hs.com/base/helloworld:v3 application/vnd.docker.distribution.manifest.v2+json sha256:263cc12a1f7d1be13d95cd1523d48003237152410f6ec67622320c36b2102265 9.7 MiB linux/amd64 -

###将镜像挂载到主机目录：
root@k8s-node02:~# ctr i mount harborrepo.hs.com/base/helloworld:v3 /mnt
sha256:51fe4831abfd6c871b106c16cb2a11a6125d38a2921faefcfe27c8f0b96ee4fd
/mnt
root@k8s-node02:~# ls /mnt/
bin  dev  docker-entrypoint.d  docker-entrypoint.sh  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
root@k8s-node02:~# ctr i unmount /mnt	#卸载
/mnt

###将镜像导出为压缩包
root@k8s-node02:~# ctr i export helloworld-v3.tar.gz harborrepo.hs.com/base/helloworld:v3

###删除镜像
root@k8s-node02:~# ctr i remove harborrepo.hs.com/base/helloworld:v3
harborrepo.hs.com/base/helloworld:v3

###导入镜像
root@k8s-node02:~# ctr i list
REF TYPE DIGEST SIZE PLATFORMS LABELS
root@k8s-node02:~# ctr i import helloworld-v3.tar.gz
unpacking harborrepo.hs.com/base/helloworld:v3 (sha256:263cc12a1f7d1be13d95cd1523d48003237152410f6ec67622320c36b2102265)...done
root@k8s-node02:~# ctr i list
REF                                  TYPE                                                 DIGEST                                                                  SIZE    PLATFORMS   LABELS
harborrepo.hs.com/base/helloworld:v3 application/vnd.docker.distribution.manifest.v2+json sha256:263cc12a1f7d1be13d95cd1523d48003237152410f6ec67622320c36b2102265 9.7 MiB linux/amd64 -


###创建容器
root@k8s-node02:~# ctr c create harborrepo.hs.com/base/helloworld:v3 helloworld
root@k8s-node02:~# ctr c ls
CONTAINER     IMAGE                                   RUNTIME
helloworld    harborrepo.hs.com/base/helloworld:v3    io.containerd.runc.v2

###查看容器信息
root@k8s-node02:~# ctr c info helloworld	#和 docker inspect 类似
{
    "ID": "helloworld",
    "Labels": {
        "io.containerd.image.config.stop-signal": "SIGQUIT"
    },
    "Image": "harborrepo.hs.com/base/helloworld:v3",
    "Runtime": {
        "Name": "io.containerd.runc.v2",
        "Options": {
            "type_url": "containerd.runc.v1.Options"
        }
    },
    "SnapshotKey": "helloworld",
    "Snapshotter": "overlayfs",
    "CreatedAt": "2022-08-03T02:48:18.076891901Z",
    "UpdatedAt": "2022-08-03T02:48:18.076891901Z",
    "Extensions": null,
    "Spec": {
        "ociVersion": "1.0.2-dev",
        "process": {
            "user": {
                "uid": 0,
                "gid": 0,
                "additionalGids": [
                    1,
                    2,
                    3,
                    4,
                    6,
                    10,
                    11,
                    20,
                    26,
                    27
                ]
            },
            "args": [
                "/docker-entrypoint.sh",
                "nginx",
                "-g",
                "daemon off;"
            ],
            "env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.22.0",
                "NJS_VERSION=0.7.5",
                "PKG_RELEASE=1"
            ],
            "cwd": "/",
            "capabilities": {
                "bounding": [
                    "CAP_CHOWN",
                    "CAP_DAC_OVERRIDE",
                    "CAP_FSETID",
                    "CAP_FOWNER",
                    "CAP_MKNOD",
                    "CAP_NET_RAW",
                    "CAP_SETGID",
                    "CAP_SETUID",
                    "CAP_SETFCAP",
                    "CAP_SETPCAP",
                    "CAP_NET_BIND_SERVICE",
                    "CAP_SYS_CHROOT",
                    "CAP_KILL",
                    "CAP_AUDIT_WRITE"
                ],
                "effective": [
                    "CAP_CHOWN",
                    "CAP_DAC_OVERRIDE",
                    "CAP_FSETID",
                    "CAP_FOWNER",
                    "CAP_MKNOD",
                    "CAP_NET_RAW",
                    "CAP_SETGID",
                    "CAP_SETUID",
                    "CAP_SETFCAP",
                    "CAP_SETPCAP",
                    "CAP_NET_BIND_SERVICE",
                    "CAP_SYS_CHROOT",
                    "CAP_KILL",
                    "CAP_AUDIT_WRITE"
                ],
                "inheritable": [
                    "CAP_CHOWN",
                    "CAP_DAC_OVERRIDE",
                    "CAP_FSETID",
                    "CAP_FOWNER",
                    "CAP_MKNOD",
                    "CAP_NET_RAW",
                    "CAP_SETGID",
                    "CAP_SETUID",
                    "CAP_SETFCAP",
                    "CAP_SETPCAP",
                    "CAP_NET_BIND_SERVICE",
                    "CAP_SYS_CHROOT",
                    "CAP_KILL",
                    "CAP_AUDIT_WRITE"
                ],
                "permitted": [
                    "CAP_CHOWN",
                    "CAP_DAC_OVERRIDE",
                    "CAP_FSETID",
                    "CAP_FOWNER",
                    "CAP_MKNOD",
                    "CAP_NET_RAW",
                    "CAP_SETGID",
                    "CAP_SETUID",
                    "CAP_SETFCAP",
                    "CAP_SETPCAP",
                    "CAP_NET_BIND_SERVICE",
                    "CAP_SYS_CHROOT",
                    "CAP_KILL",
                    "CAP_AUDIT_WRITE"
                ]
            },
            "rlimits": [
                {
                    "type": "RLIMIT_NOFILE",
                    "hard": 1024,
                    "soft": 1024
                }
            ],
            "noNewPrivileges": true
        },
        "root": {
            "path": "rootfs"
        },
        "mounts": [
            {
                "destination": "/proc",
                "type": "proc",
                "source": "proc",
                "options": [
                    "nosuid",
                    "noexec",
                    "nodev"
                ]
            },
            {
                "destination": "/dev",
                "type": "tmpfs",
                "source": "tmpfs",
                "options": [
                    "nosuid",
                    "strictatime",
                    "mode=755",
                    "size=65536k"
                ]
            },
            {
                "destination": "/dev/pts",
                "type": "devpts",
                "source": "devpts",
                "options": [
                    "nosuid",
                    "noexec",
                    "newinstance",
                    "ptmxmode=0666",
                    "mode=0620",
                    "gid=5"
                ]
            },
            {
                "destination": "/dev/shm",
                "type": "tmpfs",
                "source": "shm",
                "options": [
                    "nosuid",
                    "noexec",
                    "nodev",
                    "mode=1777",
                    "size=65536k"
                ]
            },
            {
                "destination": "/dev/mqueue",
                "type": "mqueue",
                "source": "mqueue",
                "options": [
                    "nosuid",
                    "noexec",
                    "nodev"
                ]
            },
            {
                "destination": "/sys",
                "type": "sysfs",
                "source": "sysfs",
                "options": [
                    "nosuid",
                    "noexec",
                    "nodev",
                    "ro"
                ]
            },
            {
                "destination": "/run",
                "type": "tmpfs",
                "source": "tmpfs",
                "options": [
                    "nosuid",
                    "strictatime",
                    "mode=755",
                    "size=65536k"
                ]
            }
        ],
        "linux": {
            "resources": {
                "devices": [
                    {
                        "allow": false,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 1,
                        "minor": 3,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 1,
                        "minor": 8,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 1,
                        "minor": 7,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 5,
                        "minor": 0,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 1,
                        "minor": 5,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 1,
                        "minor": 9,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 5,
                        "minor": 1,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 136,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 5,
                        "minor": 2,
                        "access": "rwm"
                    },
                    {
                        "allow": true,
                        "type": "c",
                        "major": 10,
                        "minor": 200,
                        "access": "rwm"
                    }
                ]
            },
            "cgroupsPath": "/default/helloworld",
            "namespaces": [
                {
                    "type": "pid"
                },
                {
                    "type": "ipc"
                },
                {
                    "type": "uts"
                },
                {
                    "type": "mount"
                },
                {
                    "type": "network"
                }
            ],
            "maskedPaths": [
                "/proc/acpi",
                "/proc/asound",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/sys/firmware",
                "/proc/scsi"
            ],
            "readonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        }
    }
}

###任务
上面 create 的命令创建了容器后，并没有处于运行状态，只是一个静态的容器。一个 container 对象只是包含了运行一个容器所需的资源及配置的数据结构，这意味着 namespaces、rootfs 和容器的配置都已经初始化成功了，只是用户进程(这里是 helloworld)还没有启动。然而一个容器真正的运行起来是由 Task 对象实现的，task 代表任务的意思，可以为容器设置网卡，还可以配置工具来对容器进行监控等。

root@k8s-node02:~# ctr task list
TASK    PID    STATUS

root@k8s-node02:~# ctr task start -d helloworld
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/

root@k8s-node02:~# ctr task list
TASK          PID      STATUS
helloworld    13734    RUNNING

####当然，也可以一步到位直接创建并运行容器：
root@k8s-node02:~# ctr run -d harborrepo.hs.com/base/helloworld:v3 test
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/

root@k8s-node02:~# ctr task list
TASK          PID      STATUS
helloworld    13734    RUNNING
test          13844    RUNNING

###进入容器：
root@k8s-node02:~# ctr task exec --exec-id 0 -t test /bin/sh
/ # netstat -tnl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
tcp        0      0 :::80                   :::*                    LISTEN

root@k8s-node02:~# ctr task pause test	#暂停
root@k8s-node02:~# ctr task ls
TASK          PID      STATUS
test          13844    PAUSED
helloworld    13734    RUNNING
root@k8s-node02:~# ctr task resume test	#恢复

###ctr 没有 stop 容器的功能，只能暂停或者杀死容器。
root@k8s-node02:~# ctr task kill test
root@k8s-node02:~# ctr task list
TASK          PID      STATUS
test          13844    STOPPED
helloworld    13734    RUNNING


###命名空间
除了 k8s 有命名空间以外，Containerd 也支持命名空间。如果不指定，ctr 默认是 default 空间。
root@k8s-node02:~# ctr namespace ls	
NAME    LABELS
default

###Containerd 和 Docker
目前 Containerd 的定位还是解决运行时，所以目前他还不能完全替代 dockerd，例如使用 Dockerfile 来构建镜像。其实这不是什么大问题，我再给大家介绍这个大招
事实上，Docker 和 Containerd 是可以同时使用的，只不过 Docker 默认使用的 Containerd 的命名空间不是 default，而是 moby。下面就是见证奇迹的时刻。

首先从其他装了 Docker 的机器或者 GitHub 上下载 Docker 相关的二进制文件，然后使用下面的命令启动 Docker：

###下载装docker二进制
root@k8s-node02:~# curl -OL https://download.docker.com/linux/static/stable/x86_64/docker-19.03.15.tgz
root@k8s-node02:~# tar -C /usr/local/bin/ -tvf docker-19.03.15.tgz
drwxrwxr-x ubuntu/ubuntu     0 2021-01-30 11:19 docker/
-rwxr-xr-x ubuntu/ubuntu 71555008 2021-01-30 11:19 docker/dockerd
-rwxr-xr-x ubuntu/ubuntu  2928566 2021-01-30 11:19 docker/docker-proxy
-rwxr-xr-x ubuntu/ubuntu  7172096 2021-01-30 11:19 docker/containerd-shim
-rwxr-xr-x ubuntu/ubuntu   708616 2021-01-30 11:19 docker/docker-init
-rwxr-xr-x ubuntu/ubuntu 61133792 2021-01-30 11:19 docker/docker
-rwxr-xr-x ubuntu/ubuntu  9600824 2021-01-30 11:19 docker/runc
-rwxr-xr-x ubuntu/ubuntu 19161064 2021-01-30 11:19 docker/ctr
-rwxr-xr-x ubuntu/ubuntu 36789288 2021-01-30 11:19 docker/containerd

###运行docker
root@k8s-node02:~# cat /etc/docker/daemon.json
{
        "registry-mirrors": ["http://hub-mirror.c.163.com","https://docker.mirrors.ustc.edu.cn","https://registry.docker-cn.com"],
        "insecure-registries": ["http://192.168.13.235:8000","http://192.168.13.197:8000","harbor.hs.com","harborrepo.hs.com"],
        "log-driver":"json-file",
        "log-opts": {"max-size":"100m", "max-file":"3"}
}

root@k8s-node02:~# dockerd --containerd /run/containerd/containerd.sock --cri-containerd
INFO[2022-08-03T11:10:33.310561460+08:00] Starting up
WARN[2022-08-03T11:10:33.348612395+08:00] could not change group /var/run/docker.sock to docker: group docker not found
INFO[2022-08-03T11:10:33.356022723+08:00] detected 127.0.0.53 nameserver, assuming systemd-resolved, so using resolv.conf: /run/systemd/resolve/resolv.conf
INFO[2022-08-03T11:10:33.399145140+08:00] parsed scheme: "unix"                         module=grpc
INFO[2022-08-03T11:10:33.400054064+08:00] scheme "unix" not registered, fallback to default scheme  module=grpc
INFO[2022-08-03T11:10:33.400332565+08:00] ccResolverWrapper: sending update to cc: {[{unix:///run/containerd/containerd.sock 0  <nil>}] <nil>}  module=grpc
INFO[2022-08-03T11:10:33.400574284+08:00] ClientConn switching balancer to "pick_first"  module=grpc
INFO[2022-08-03T11:10:33.404834206+08:00] parsed scheme: "unix"                         module=grpc
INFO[2022-08-03T11:10:33.405275622+08:00] scheme "unix" not registered, fallback to default scheme  module=grpc
INFO[2022-08-03T11:10:33.405629095+08:00] ccResolverWrapper: sending update to cc: {[{unix:///run/containerd/containerd.sock 0  <nil>}] <nil>}  module=grpc
INFO[2022-08-03T11:10:33.405665103+08:00] ClientConn switching balancer to "pick_first"  module=grpc
WARN[2022-08-03T11:10:33.446386890+08:00] Your kernel does not support swap memory limit
WARN[2022-08-03T11:10:33.446439425+08:00] Your kernel does not support cgroup rt period
WARN[2022-08-03T11:10:33.446448891+08:00] Your kernel does not support cgroup rt runtime
INFO[2022-08-03T11:10:33.446800873+08:00] Loading containers: start.
INFO[2022-08-03T11:10:33.794542196+08:00] Default bridge (docker0) is assigned with an IP address 172.17.0.0/16. Daemon option --bip can be used to set a preferred IP address
INFO[2022-08-03T11:10:34.024483792+08:00] Loading containers: done.
INFO[2022-08-03T11:10:34.072514483+08:00] Docker daemon                                 commit=99e3ed8 graphdriver(s)=overlay2 version=19.03.15
INFO[2022-08-03T11:10:34.072649044+08:00] Daemon has completed initialization
INFO[2022-08-03T11:10:34.090520743+08:00] API listen on /var/run/docker.sock

###运行docker容器
root@k8s-node02:~# docker pull harborrepo.hs.com/base/helloworld:v3
root@k8s-node02:~# ctr ns list
NAME    LABELS
default
root@k8s-node02:~# docker run -d --name hellov1 harborrepo.hs.com/base/helloworld:v3
037056ce789ff4d698d4cbea3c4614db80def6dd524be9ba3cbba1c6986b8591
root@k8s-node02:~# ctr ns list
NAME    LABELS
default
moby

#containerd查看docker
root@k8s-node02:~# ctr -n moby c ls
CONTAINER                                                           IMAGE    RUNTIME
037056ce789ff4d698d4cbea3c4614db80def6dd524be9ba3cbba1c6986b8591    -        io.containerd.runtime.v1.linux
看来以后用 Containerd 不耽误我 docker build 了~~
kubernetes 用户不用惊慌，Kubernetes 默认使用的是 Containerd 的 k8s.io 命名空间，所以 ctr -n k8s.io 就能看到 Kubernetes 创建的所有容器啦








