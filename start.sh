#!/bin/sh

/usr/bin/openresty -g "daemon off;" -p /visualizer/ -c /visualizer/nginx.conf
