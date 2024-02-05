build:
	cp ../../get-pip.py .
	docker build -t haishi/openstack-nova-controller .
run:
	docker -it -d -h nova-controller --name nova-controller haishi/openstack-nova-controller
clean:
	docker rm -f nova-controller
rmi:
	docker rmi haishi/openstack-nova-controller
exec:
	docker exec -it nova-controller bash
log:
	docker logs -f nova-controller
