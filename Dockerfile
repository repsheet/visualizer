FROM ubuntu:18.04

RUN apt-get -y update
RUN apt-get -y install wget gpg luarocks
RUN wget -qO - https://openresty.org/package/pubkey.gpg | apt-key add -
RUN apt-get -y install software-properties-common
RUN add-apt-repository -y "deb http://openresty.org/package/ubuntu $(lsb_release -sc) main"
RUN apt-get -y update
RUN apt-get -y install --no-install-recommends openresty

RUN luarocks install lua-resty-redis

WORKDIR /visualizer
COPY start.sh .
COPY nginx.conf .
COPY mime.types .
COPY src/ src
RUN mkdir /visualizer/logs

EXPOSE 8888

CMD ["sh", "start.sh"]

STOPSIGNAL SIGQUIT
