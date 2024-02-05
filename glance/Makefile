build:
	cp ../get-pip.py .
	docker build -t haishi/openstack-glance .
run:
	docker -it -d -h glance --name glance haishi/openstack-glance
clean:
	docker rm -f glance
rmi:
	docker rmi haishi/openstack-glance
exec:
	docker exec -it glance bash
log:
	docker logs -f glance
