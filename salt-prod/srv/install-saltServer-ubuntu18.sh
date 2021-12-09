#!/bin/sh
# os by ubuntu

# Download key
sudo curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/3003/salt-archive-keyring.gpg
# Create apt sources list file
echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg arch=amd64] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/3003 focal main" | sudo tee /etc/apt/sources.list.d/salt.list

# install salt component
sudo apt-get update
sudo apt-get install -y salt-master salt-minion salt-ssh

# config salt master 
sudo sh -c 'cat > /etc/salt/master << EOF
file_recv: True
file_recv_max_size: 100
file_roots:
  base:
    - /srv/salt/base
  dev:
    - /srv/salt/dev
  prod:
    - /srv/salt/prod
pillar_roots:
  base:
   - /srv/pillar/base
  dev:
   - /srv/pillar/dev
  prod:
   - /srv/pillar/prod
EOF' && echo "copy master config successful"
# create directory
sudo mkdir -p /srv/{pillar,salt}/{base,dev,prod} && echo 'create successful' || echo "create fail"
# restart slat-master
sudo systemctl restart salt-master
sudo systemctl enable salt-master

# config slat minion 
sudo sed -i "s/#master: salt/master: 127.0.0.1/" /etc/salt/minion
# restart salt-minion
sudo systemctl restart salt-minion
sudo systemctl enable salt-minion

