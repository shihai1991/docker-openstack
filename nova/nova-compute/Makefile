build:
	cp ../../get-pip.py .
	docker build -t haishi/openstack-nova-compute .
run:
	docker -it -d -h nova-compute --name nova-compute haishi/openstack-nova-compute
clean:
	docker rm -f nova-compute
rmi:
	docker rmi haishi/openstack-nova-compute
exec:
	docker exec -it nova-compute bash
log:
	docker logs -f nova-compute
