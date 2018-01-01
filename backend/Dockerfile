FROM openresty/openresty:centos

COPY nginx.conf /usr/local/openresty/nginx/conf

WORKDIR /code
COPY api.lua .
COPY blacklist.lua .
COPY json.lua .

EXPOSE 8888

CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]