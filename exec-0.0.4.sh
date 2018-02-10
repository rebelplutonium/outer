#!/bin/sh

xhost +local: &&
    cleanup(){
        xhost -
    } &&
    trap cleanup EXIT &&
    sudo         /usr/bin/docker         --preserve-env         run         --interactive         --rm         --label expiry=$(($(date +%s)+60*60*24*7))         --volume /var/run/docker.sock:/var/run/docker.sock:ro         --env DISPLAY         rebelplutonium/outer:0.0.4             "${@}"    
