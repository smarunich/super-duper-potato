#!/bin/bash -e

chmod 0600 /root/.ssh/id_rsa
yum install -y squid

sudo sed -i 's/^\(bind 127.0.0.1\)$/#\1/' /etc/redis.conf
sudo sed -i 's/^\(protected-mode\) yes/\1 no/' /etc/redis.conf

systemctl daemon-reload
systemctl enable redis
systemctl start redis
systemctl enable squid
systemctl start squid
systemctl enable nginx
systemctl start nginx

git clone git://github.com/ansible/ansible-runner /tmp/ansible-runner
pip install /tmp/ansible-runner/

chmod +x /usr/local/bin/handle_bootstrap.py
chmod +x /usr/local/bin/handle_register.py
chmod +x /usr/local/bin/cleanup_controllers.py
chmod +x /usr/local/bin/register.py

systemctl enable handle_bootstrap
systemctl enable handle_register
systemctl start handle_bootstrap
systemctl start handle_register

chmod +x /etc/ansible/hosts


cp /usr/local/bin/register.py /usr/share/nginx/html/
cp /tmp/provision_vm.sh /usr/share/nginx/html/
cp /etc/ansible/hosts /opt/bootstrap/inventory

#Nasty, nasty, very very nasty...
sleep 5
/usr/local/bin/register.py localhost