#!/bin/bash -x
docker run --name nginx \
    -v "${PWD}/tomslee-airbnb-data-2":/usr/share/nginx/html/tomslee-airbnb-data-2:ro \
    -v "${PWD}/nginx.conf":/etc/nginx/nginx.conf:ro \
    -p 8080:80 \
    -d nginx
