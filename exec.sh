#!/bin/sh

cleanup(){
    xhost -
} &&
    trap cleanup EXIT &&
    xhost +local: &&
    while [ ${#} -gt 0 ]
    do
        case ${1} in
            --major)
                MAJOR="${2}" &&
                    shift 2
            ;;
            --minor)
                MINOR="${2}" &&
                    shift 2
            ;;
            --patch)
                PATCH="${2}" &&
                    shift 2
            ;;
           *)
                echo Unknown Option &&
                    echo ${0} &&
                    echo ${@} &&
                    exit 64
            ;;
        esac
    done &&
    sudo \
        /usr/bin/docker \
        run \
        --interactive \
        --rm \
        --label expiry=$(($(date +%s)+60*60*24*7)) \
        --mount type=bind,source=/var/run/docker.sock,destination=/var/run/docker.sock,readonly=true \
        --mount type=bind,source=$(pwd),destination=/srv/working \
        --env DISPLAY \
        rebelplutonium/outer:${MAJOR}.${MINOR}.${PATCH} \
            "${@}"
