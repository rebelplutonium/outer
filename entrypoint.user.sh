#!/bin/sh

cleanup(){
    sudo /usr/local/bin/docker stop $(cat docker) $(cat middle) &&
        sudo /usr/local/bin/docker rm -fv $(cat docker) $(cat middle) &&
        if [ ! -z "${MONIKER}" ]
        then
            sudo /usr/local/bin/docker volume ls --quiet --filter label=moniker=${MONIKER} --filter label=expiry | while read VOLUME
            do
                if [ $(sudo /usr/local/bin/docker volume inspect --format "{{.Labels.expiry}}" ${VOLUME}) -lt $(date +%s) ]
                then
                    sudo /usr/local/bin/docker volume rm ${VOLUME}
                fi
            done
        fi
} &&
    trap cleanup EXIT &&
    source /srv/working/public.env &&
    export GPG_SECRET_KEY="$(cat /srv/working/private/gpg.secret.key)" &&
    export GPG2_SECRET_KEY="$(cat /srv/working/private/gpg2.secret.key)" &&
    export GPG_OWNER_TRUST="$(cat /srv/working/public/gpg.owner.trust)" &&
    export GPG2_OWNER_TRUST="$(cat /srv/working/public/gpg2.owner.trust)" &&
    export TARGET_UID="$(stat -c %u /srv/working)" &&
    if [ -z "${CLOUD9_PORT}" ]
    then
        echo Unspecified CLOUD9_PORT &&
            exit 65
    fi &&
    if [ -z "${PROJECT_NAME}" ]
    then
        echo Unspecified PROJECT_NAME &&
            exit 66
    fi &&
    if [ -z "${USER_NAME}" ]
    then
        echo Unspecified USER_NAME &&
            exit 67
    fi &&
    if [ -z "${USER_EMAIL}" ]
    then
        echo Unspecified USER_EMAIL &&
            exit 68
    fi &&
    if [ -z "${GPG_SECRET_KEY}" ]
    then
        echo Unspecified GPG_SECRET_KEY &&
            exit 69
    fi &&
    if [ -z "${GPG2_SECRET_KEY}" ]
    then
        echo Unspecified GPG2_SECRET_KEY &&
            exit 70
    fi &&
    if [ -z "${GPG_OWNER_TRUST}" ]
    then
        echo Unspecified GPG_OWNER_TRUST &&
            exit 71
    fi &&
    if [ -z "${GPG2_OWNER_TRUST}" ]
    then
        echo Unspecified GPG2_OWNER_TRUST &&
            exit 72
    fi &&
    if [ -z "${SECRETS_ORGANIZATION}" ]
    then
        echo Unspecified SECRETS_ORGANIZATION &&
            exit 73
    fi &&
    if [ -z "${SECRETS_REPOSITORY}" ]
    then
        echo Unspecified SECRETS_REPOSITORY &&
            exit 74
    fi &&
    if [ -z "${DOCKER_SEMVER}" ]
    then
        echo Unspecified DOCKER_SEMVER &&
            exit 75
    fi &&
    if [ -z "${BROWSER_SEMVER}" ]
    then
        echo Unspecified BROWSER_SEMVER &&
            exit 76
    fi &&
    if [ -z "${MIDDLE_SEMVER}" ]
    then
        echo Unspecified MIDDLE_SEMVER &&
            exit 77
    fi &&
    if [ -z "${TARGET_UID}" ]
    then
        echo Unspecified TARGET_UID &&
            exit 78
    fi &&
    if [ "${TARGET_UID}" != 1000 ]
    then
        echo TARGET_UID must be 1000 &&
            exit 79
    fi
    IMAGE_VOLUME=$(sudo /usr/local/bin/docker volume ls --quiet --filter label=moniker=${MONIKER} | head -n 1) &&
    if [ -z "${IMAGE_VOLUME}" ]
    then
        IMAGE_VOLUME=$(sudo /usr/local/bin/docker volume create --label moniker=${MONIKER} --label expiry=$(date --date "now + 1 month" +%s))
    fi &&
    sudo \
        /usr/local/bin/docker \
        create \
        --cidfile docker \
        --privileged \
        --mount type=bind,source=/,destination=/srv/host,readonly=true \
        --mount type=bind,destination=/srv/pulse,source=/run/user/${TARGET_UID}/pulse,readonly=false \
        --mount type=bind,destination=/srv/machine-id,source=/etc/machine-id,readonly=false \
        --mount type=bind,destination=/srv/system_bus_socket,source=/var/run/dbus/system_bus_socket,readonly=false \
        --mount type=bind,destination=/srv/dbus,source=/var/lib/dbus,readonly=false \
        --mount type=bind,destination=/srv/tmp,source=/tmp,readonly=false \
        --mount type=bind,destination=/srv/working,source=/srv/working,readonly=false \
        --mount type=volume,source=${IMAGE_VOLUME},destination=/var/lib/docker,readonly=false \
        --label expiry=$(date --date "now + 1 month" +%s) \
        docker:${DOCKER_SEMVER}-ce-dind \
            --host tcp://0.0.0.0:2376 &&
    sudo /usr/local/bin/docker start $(cat docker) &&
    sudo /usr/local/bin/docker exec --interactive $(cat docker) mkdir /opt &&
    sudo /usr/local/bin/docker exec --interactive $(cat docker) mkdir /opt/cloud9 &&
    sudo /usr/local/bin/docker exec --interactive $(cat docker) mkdir /opt/cloud9/workspace &&
    sudo /usr/local/bin/docker exec --interactive $(cat docker) chown $(stat -c %u /srv/working) /opt/cloud9/workspace &&
    sudo \
        --preserve-env \
        /usr/local/bin/docker \
        create \
        --cidfile middle \
        --interactive \
        --env DISPLAY \
        --env DOCKER_HOST \
        --env CLOUD9_PORT \
        --env PROJECT_NAME \
        --env USER_NAME \
        --env USER_EMAIL \
        --env GPG_SECRET_KEY \
        --env GPG2_SECRET_KEY \
        --env GPG_OWNER_TRUST \
        --env GPG2_OWNER_TRUST \
        --env GPG_KEY_ID \
        --env SECRETS_ORGANIZATION \
        --env SECRETS_REPOSITORY \
        --env DOCKER_SEMVER \
        --env BROWSER_SEMVER \
        --env MIDDLE_SEMVER \
        --env INNER_SEMVER \
        --env TARGET_UID \
        --env DOCKER_HOST=$(sudo /usr/local/bin/docker inspect --format "tcp://{{ .NetworkSettings.Networks.bridge.IPAddress }}:2376" $(cat docker)) \
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/middle:${MIDDLE_SEMVER} \
            "${@}" &&
    sudo /usr/local/bin/docker start --interactive $(cat middle)