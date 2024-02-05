#!/bin/bash
set -x

# create database for glance
export MYSQL_ROOT_PASSWORD=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}
export MYSQL_HOST=${MYSQL_HOST:-mysql}
SQL_SCRIPT=/root/nova.sql
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

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
openstack user create --domain default --password $NOVA_PASSWORD $NOVA_USER_NAME 
openstack role add --user $NOVA_USER_NAME --project service admin
openstack service create --name nova compute --description "OpenStack Compute"
openstack endpoint create --region regionOne compute public http://${NOVA_HOST}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region regionOne compute internal http://${NOVA_HOST}:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region regionOne compute admin http://${NOVA_HOST}:8774/v2.1/%\(tenant_id\)s

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
[api_database]
connection = mysql+pymysql://nova:NOVA_DBPASS@${MYSQL_HOST}/nova_api

[database]
connection = mysql+pymysql://nova:NOVA_DBPASS@${MYSQL_HOST}/nova

[glance]
api_servers = http://${GLANCE_HOST}:9292
EOF

# sync the database
nova-manage api_db sync
nova-manage db sync

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
nova-api &
nova-consoleauth &
nova-scheduler &
nova-conductor &
nova-novncproxy
sleep 5
