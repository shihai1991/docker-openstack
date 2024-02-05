#!/bin/bash
set -x

# To create the Identity service credentials
KEYSTONE_HOST=${KEYSTONE_HOST:-keystone}
GLANCE_HOST=${GLANCE_HOST:-glance}
NOVA_USER_NAME=${NOVA_USER_NAME:-nova}
NOVA_PASSWORD=${NOVA_PASSWORD:-NOVA_PASS}
NOVA_HOST=${NOVA_HOST:-$HOSTNAME}
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=${OS_PROJECT_NAME:-admin}
export OS_USERNAME=${OS_USERNAME:-admin}
export OS_PASSWORD=${OS_PASSWORD:-ADMIN_PASS}
export OS_AUTH_URL=${OS_AUTH_URL:-http://${KEYSTONE_HOST}:35357/v3}
export OS_IDENTITY_API_VERSION=3

# update nova.conf
CONFIG_FILE=/etc/nova/nova.conf
sed -i "s#^auth_uri.*=.*#auth_uri = http://${KEYSTONE_HOST}:5000#" $CONFIG_FILE
sed -i "s#^auth_url.*=.*#auth_url = http://${KEYSTONE_HOST}:35357#" $CONFIG_FILE
sed -i "s#^username.*=.*#username = ${NOVA_USER_NAME}#" $CONFIG_FILE
sed -i "s#^password.*=.*#password = ${NOVA_PASSWORD}#" $CONFIG_FILE
RABBITMQ_HOST=${RABBITMQ_HOST:-rabbitmq}
RABBITMQ_USER=${RABBITMQ_USER:-guest}
RABBITMQ_PASSWORD=${RABBITMQ_PASSWORD:-guest}
sed -i "s#^rabbit_host.*=.*#rabbit_host = ${RABBITMQ_HOST}#" $CONFIG_FILE
sed -i "s#^rabbit_userid.*=.*#rabbit_userid = ${RABBITMQ_USER}#" $CONFIG_FILE
sed -i "s#^rabbit_password.*=.*#rabbit_password = ${RABBITMQ_PASSWORD}#" $CONFIG_FILE
MY_IP=`ifconfig  | grep 'inet '|grep -v '127.0.0.1'|cut -c 14-21`
sed -i "s#^my_ip.*=.*#my_ip = ${MY_IP}#" $CONFIG_FILE
sed -i "s#^vncserver_listen.*=.*#vncserver_listen = ${MY_IP}#" $CONFIG_FILE
sed -i "s#^vncserver_proxyclient_address*=.*#vncserver_proxyclient_address = ${MY_IP}#" $CONFIG_FILE
cat >>$CONFIG_FILE <<EOF
[glance]
api_servers = http://${GLANCE_HOST}:9292
EOF

# create a admin-openrc file
ADMIN_OPENRC=/root/admin-openrc
cat >$ADMIN_OPENRC <<EOF
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=$OS_USERNAME
export OS_PASSWORD=$OS_PASSWORD
export OS_AUTH_URL=$OS_AUTH_URL
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

#start nova service
#libvirtd &
nova-compute
sleep 5 
