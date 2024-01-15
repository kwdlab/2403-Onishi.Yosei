#!/bin/bash

OUT_PUT="targetList/${2}/${1}.txt"

curl -s https://hub.docker.com/v2/repositories/$1/?page_size=10000 | jq -r '.results|.[]|.name' > ${OUT_PUT}