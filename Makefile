.PHONY: start
start:
	openresty -p `pwd`/ -c nginx.conf

.PHONY: stop
stop:
	openresty -p `pwd`/ -c nginx.conf -s stop

.PHONY: reload
reload:
	openresty -p `pwd`/ -c nginx.conf -s reload
