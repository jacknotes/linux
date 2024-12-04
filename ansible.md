

# Ansible



## 1. ansible升级

### 1.1 centos7升级ansible

#### 方法 1：使用 EPEL
```bash
sudo yum install epel-release
sudo yum update ansible
```



#### 方法2：使用官方Ansible存储库

```bash
sudo tee /etc/yum.repos.d/ansible.repo <<EOF
[ansible]
name=Ansible Repository
baseurl=https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/
enabled=1
gpgcheck=0
EOF

sudo yum update ansible
```



#### 方法 3：使用 pip

```bash
sudo yum install python-pip
sudo pip install --upgrade pip
sudo pip install --upgrade ansible
```




### 1.2 ubuntu18升级ansible

#### 方法1：使用官方Ansible存储库(推荐)
```bash
apt update
apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt update -y
apt upgrade -y ansible

root@ansible:~# ansible --version
ansible 2.9.27
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.17 (default, Mar  8 2023, 18:40:28) [GCC 7.5.0]\
```



#### 方法2：使用 pip
```bash
apt update
apt install -y python3-pip python3-dev
pip3 install --upgrade pip
pip3 install --upgrade ansible -i https://pypi.tuna.tsinghua.edu.cn/simple
ansible --version
```



