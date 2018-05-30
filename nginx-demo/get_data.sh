#!/bin/bash -x
readonly BASEURL="https://s3.amazonaws.com"
readonly DIR="tomslee-airbnb-data-2"

mkdir -p ${DIR}

for city in chicago toronto montral philadelphia
do
    curl -o "${DIR}/${city}.zip" "${BASEURL}/${DIR}/${city}.zip"
done
