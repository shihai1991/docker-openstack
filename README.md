# docker-openstack
Deploying the openstack of mitaka in docker. This repo is based on the [int32bit/docker-nova-compute](https://github.com/int32bit/docker-nova-compute). I create this repo's reason is that the `int32bit/docker-nova-compute` is too old and I met some problems when using it.

# How to Install

## Install base component
```shell
docker run -d -e MYSQL_ROOT_PASSWORD=MYSQL_DBPASS -h mysql --name mysql -d mariadb:latest
```

## Install keystone
```shell
docker run -d  --link mysql:mysql --name keystone -h keystone haishi/openstack-keystone:latest
```

## Install glance
```shell
```

## Install nova
```shell
```
