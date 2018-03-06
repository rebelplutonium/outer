#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --major)
            export MAJOR="${2}" &&
                shift 2
        ;;
        --minor)
            export MINOR="${2}" &&
                shift 2
        ;;
        --patch)
            export PATCH="${2}" &&
                shift 2
        ;;
        --execute)
            shift &&
                xhost +local: &&
                cleanup(){
                    xhost -
                } &&
                trap cleanup EXIT &&
                echo LOADING SCRIPT ... &&
                sudo \
                    --preserve-env \
                    /usr/bin/docker \
                    run \
                    --interactive \
                    --rm \
                    --label expiry=$(($(date +%s)+60*60*24*7)) \
                    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
                    --env DISPLAY \
                    --env TARGET_UID=${UID} \
                    rebelplutonium/outer:${MAJOR}.${MINOR}.${PATCH} \
                        "${@}" &&
                shift ${#}
        ;;
        *)
            echo Unknown Option &&
                echo ${0} &&
                echo ${@} &&
                exit 64
        ;;
    esac
done