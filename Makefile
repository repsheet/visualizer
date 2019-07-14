.PHONY: start
start:
	openresty -p `pwd`/ -c nginx.conf

.PHONY: stop
stop:
	openresty -p `pwd`/ -c nginx.conf -s stop

.PHONY: reload
reload:
	openresty -p `pwd`/ -c nginx.conf -s reload

.PHONY: docker
docker:
	docker build -t repsheet_visualizer .

.PHONY: docker-run
docker-run:
	docker run -p 8888:8888 repsheet_visualizer
