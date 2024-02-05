# docker-openstack
Deploying the Openstack of Mitaka in docker. This repo is based on the [int32bit/docker-nova-compute](https://github.com/int32bit/docker-nova-compute). I create this repo's reason is that the `int32bit/docker-nova-compute` is too old and I met some problems when using it. And I follow [the official guide](https://docs.openstack.org/mitaka/install-guide-rdo/nova.html) to depoly the Openstack in docker.  
I try to use this project to shift our right test to left. If you want to depoly Openstack in production environment, you should use [Kolla](https://github.com/openstack/kolla).

# How to run
We have two ways to run docker instances.
- Using local docker images;
- Using remote docker images from docker.io;

## Using local docker images
```
# Running the base components
docker run -d -e MYSQL_ROOT_PASSWORD=MYSQL_DBPASS -h mysql --name mysql -d mariadb:latest
docker run -d -e RABBITMQ_NODENAME=rabbitmq -h rabbitmq --name rabbitmq rabbitmq:latest

# Running the keystone
cd keystone
make build
make build
docker run -d  --link mysql:mysql --name keystone -h keystone haishi/openstack-keystone:latest

# Running the glance
cd ../glance
# build image
make build
docker run -d --link mysql:mysql  --link keystone:keystone  -e OS_USERNAME=admin  -e OS_PASSWORD=ADMIN_PASS  -e OS_AUTH_URL=http://keystone:5000/v3  -e OS_PROJECT_NAME=admin  --name glance  -h glance  haishi/openstack-glance:latest

# Running the controller node
cd ../nova/nova-controller
# build image
make build
docker run -d --link mysql:mysql --link keystone:keystone --link rabbitmq:rabbitmq --link glance:glance -e OS_USERNAME=admin -e OS_PASSWORD=ADMIN_PASS -e OS_AUTH_URL=http://keystone:5000/v3 -e OS_PROJECT_NAME=admin --privileged --name controller -h controller haishi/openstack-nova-controller:latest

# Running the compute node
cd ../nova-compute
# build image
make build
docker run -d --link mysql:mysql --link keystone:keystone --link rabbitmq:rabbitmq --link glance:glance --link controller:controller -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -e OS_USERNAME=admin -e OS_PASSWORD=ADMIN_PASS -e OS_AUTH_URL=http://keystone:5000/v3 -e OS_TENANT_NAME=admin --privileged --name node1 -h node1 haishi/openstack-nova-compute:latest
```

## Using remote docker images
```shell
# Running the base components
docker run -d -e MYSQL_ROOT_PASSWORD=MYSQL_DBPASS -h mysql --name mysql -d mariadb:latest
docker run -d -e RABBITMQ_NODENAME=rabbitmq -h rabbitmq --name rabbitmq rabbitmq:latest

# Running the keystone
docker run -d  --link mysql:mysql --name keystone -h keystone haishi/openstack-keystone:latest

# Running the glance
docker run -d --link mysql:mysql  --link keystone:keystone  -e OS_USERNAME=admin  -e OS_PASSWORD=ADMIN_PASS  -e OS_AUTH_URL=http://keystone:5000/v3  -e OS_PROJECT_NAME=admin  --name glance  -h glance  haishi/openstack-glance:latest

# Running the controller node
docker run -d --link mysql:mysql --link keystone:keystone --link rabbitmq:rabbitmq --link glance:glance -e OS_USERNAME=admin -e OS_PASSWORD=ADMIN_PASS -e OS_AUTH_URL=http://keystone:5000/v3 -e OS_PROJECT_NAME=admin --privileged --name controller -h controller haishi/openstack-nova-controller:latest

# Running the compute node
docker run -d --link mysql:mysql --link keystone:keystone --link rabbitmq:rabbitmq --link glance:glance --link controller:controller -v /var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket -e OS_USERNAME=admin -e OS_PASSWORD=ADMIN_PASS -e OS_AUTH_URL=http://keystone:5000/v3 -e OS_TENANT_NAME=admin --privileged --name node1 -h node1 haishi/openstack-nova-compute:latest
```
It should be noticed that I use the [`FakeDriver`](https://github.com/shihai1991/docker-openstack/blob/8afe254042ea7e16f6c800baa03d990e28d5fdb9/nova/nova-compute/nova.conf#L21) in compute node. If you want use other [hypervisors](https://github.com/openstack/nova/blob/681f6872fb3fbca290cfc3ff15d34b1d1ba6642d/doc/source/admin/configuration/hypervisors.rst), you can change it.

## Verify operation
Login in the controller node, and to verify the lanuch operation by list service components.
```shell
source /root/admin-openrc

openstack compute service list
```

If the service components is installed successful, you will the output as follows:
```shell
+----+------------------+------------+----------+---------+-------+----------------------------+
| Id | Binary           | Host       | Zone     | Status  | State | Updated At                 |
+----+------------------+------------+----------+---------+-------+----------------------------+
|  1 | nova-consoleauth | controller | internal | enabled | up    | 2024-02-05T11:24:10.000000 |
|  2 | nova-conductor   | controller | internal | enabled | up    | 2024-02-05T11:24:13.000000 |
|  3 | nova-scheduler   | controller | internal | enabled | up    | 2024-02-05T11:24:09.000000 |
| 11 | nova-compute     | node1      | nova     | enabled | up    | 2024-02-05T11:24:16.000000 |
+----+------------------+------------+----------+---------+-------+----------------------------+
```
