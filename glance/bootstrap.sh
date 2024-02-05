#!/bin/bash
# create database for glance
export MYSQL_ROOT_PASSWORD=${MYSQL_ENV_MYSQL_ROOT_PASSWORD}
export MYSQL_HOST=mysql
SQL_SCRIPT=/root/glance.sql
mysql -uroot -p$MYSQL_ROOT_PASSWORD -h $MYSQL_HOST <$SQL_SCRIPT

# To create the Identity service credentials
KEYSTONE_HOST=${KEYSTONE_HOST:-keystone}
GLANCE_USER_NAME=${GLANCE_USER_NAME:-glance}
GLANCE_PASSWORD=${GLANCE_PASSWORD:-GLANCE_PASS}
GLANCE_HOST=${GLANCE_HOST:-$HOSTNAME}
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=${OS_PROJECT_NAME:-admin}
export OS_USERNAME=${OS_USERNAME:-admin}
export OS_PASSWORD=${OS_PASSWORD:-ADMIN_PASS}
export OS_AUTH_URL=${OS_AUTH_URL:-http://${KEYSTONE_HOST}:35357/v3}
export OS_IDENTITY_API_VERSION=3
openstack user create --domain default --password $GLANCE_PASSWORD $GLANCE_USER_NAME 
openstack role add --user $GLANCE_USER_NAME --project service admin
openstack service create --name glance image --description "OpenStack Image Service"
openstack endpoint create  --region regionOne image public http://${GLANCE_HOST}:9292
openstack endpoint create  --region regionOne image internal http://${GLANCE_HOST}:9292
openstack endpoint create  --region regionOne image admin http://${GLANCE_HOST}:9292

# update glance-api.conf
API_CONFIG_FILE=/etc/glance/glance-api.conf
sed -i "s#^connection.*=.*#connection = mysql://glance:GLANCE_DBPASS@${MYSQL_HOST}/glance#" $API_CONFIG_FILE
sed -i "s#^auth_uri.*=.*#auth_uri = http://${KEYSTONE_HOST}:5000#" $API_CONFIG_FILE
sed -i "s#^auth_url.*=.*#auth_url = http://${KEYSTONE_HOST}:35357#" $API_CONFIG_FILE
sed -i "s#^username.*=.*#username = ${GLANCE_USER_NAME}#" $API_CONFIG_FILE
sed -i "s#^password.*=.*#password = ${GLANCE_PASSWORD}#" $API_CONFIG_FILE

# update glance-registry.conf
REGISTRY_CONFIG_FILE=/etc/glance/glance-registry.conf
sed -i "s#^connection.*=.*#connection = mysql://glance:GLANCE_DBPASS@${MYSQL_HOST}/glance#" $REGISTRY_CONFIG_FILE
sed -i "s#^auth_uri.*=.*#auth_uri = http://${KEYSTONE_HOST}:5000#" $REGISTRY_CONFIG_FILE
sed -i "s#^auth_url.*=.*#auth_url = http://${KEYSTONE_HOST}:35357#" $REGISTRY_CONFIG_FILE
sed -i "s#^username.*=.*#username = ${GLANCE_USER_NAME}#" $REGISTRY_CONFIG_FILE
sed -i "s#^password.*=.*#password = ${GLANCE_PASSWORD}#" $REGISTRY_CONFIG_FILE

# sync the database
glance-manage db_sync

# create a admin-openrc.sh file
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

# start glance service
glance-registry &
sleep 5
glance-api
