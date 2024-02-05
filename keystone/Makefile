build:
	cp ../get-pip.py .
	docker build -t haishi/openstack-keystone .
run:
	docker -it -d -h keystone --name keystone haishi/openstack-keystone
clean:
	docker rm -f keystone
rmi:
	docker rmi haishi/openstack-keystone
exec:
	docker exec -it keystone bash
log:
	docker logs -f keystone
