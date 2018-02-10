#!/bin/sh

xhost +local: &&
    cleanup(){
        xhost -
    } &&
    trap cleanup EXIT &&
    sudo \
        /usr/bin/docker \
        run \
        --interactive \
        --rm \
        --label expiry=$(date --date "now + 1 month" +%s) \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --env DISPLAY \
        rebelplutonium/outer:0.0.2 \
            "${@}"