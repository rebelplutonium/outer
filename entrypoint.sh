#!/bin/sh

while [ ${#} -gt 0 ]
do
    case ${1} in
        --cloud9-port)
            export CLOUD9_PORT="${2}" &&
                shift 2
        ;;
        --project-name)
            export PROJECT_NAME="${2}" &&
                shift 2
        ;;
        --user-name)
            export USER_NAME="${2}" &&
                shift 2
        ;;
        --user-email)
            export USER_EMAIL="${2}" &&
                shift 2
        ;;
        --gpg-secret-key)
            export GPG_SECRET_KEY="${2}" &&
                shift 2
        ;;
        --gpg2-secret-key)
            export GPG2_SECRET_KEY="${2}" &&
                shift 2
        ;;
        --gpg-owner-trust)
            export GPG_OWNER_TRUST="${2}" &&
                shift 2
        ;;
        --gpg2-owner-trust)
            export GPG2_OWNER_TRUST="${2}" &&
                shift 2
        ;;
        --gpg-key-id)
            export GPG_KEY_ID="${2}" &&
                shift 2
        ;;
        --secrets-organization)
            export SECRETS_ORGANIZATION="${2}" &&
                shift 2
        ;;
        --secrets-repository)
            export SECRETS_REPOSITORY="${2}" &&
                shift 2
        ;;
        --docker-semver)
            export DOCKER_SEMVER="${2}" &&
                shift 2
        ;;
        --browser-semver)
            export BROWSER_SEMVER="${2}" &&
                shift 2
        ;;
        --middle-semver)
            export MIDDLE_SEMVER="${2}" &&
                shift 2
        ;;
        --inner-semver)
            export INNER_SEMVER="${2}" &&
                shift 2
        ;;
        *)
            echo Unsupported Option &&
                echo ${0} &&
                echo ${@} &&
                exit 64
        ;;
    esac
done &&
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
    cleanup(){
        sudo --preserve-env docker stop $(cat docker) $(cat middle) &&
            sudo --preserve-env docker rm -fv $(cat docker) $(cat middle) &&
            sudo --preserve-env docker network rm $(cat network)
    } &&
    trap cleanup EXIT &&
    sudo \
        --preserve-env \
        docker \
        create \
        --cidfile docker \
        --privileged \
        --volume /:/srv/host:ro \
        --label expiry=$(date --date "now + 1 month" +%s) \
        docker:${DOCKER_SEMVER}-ce-dind \
            --host tcp://0.0.0.0:2376 &&
    sudo \
        --preserve-env \
        docker \
        create \
        --cidfile middle \
        --interactive \
        --env DISPLAY \
        --env DOCKER_HOST=tcp://docker:2376 \
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
        --label expiry=$(date --date "now + 1 month" +%s) \
        rebelplutonium/middle:${MIDDLE_SEMVER} \
            "${@}" &&
    sudo --preserve-env docker network create $(uuidgen) > network &&
    sudo \
        --preserve-env \
        docker \
        network \
        connect \
        --alias docker \
        $(cat network) \
        $(cat docker) &&
    sudo --preserve-env docker network connect $(cat network) $(cat middle) &&
    sudo --preserve-env docker start $(cat docker) &&
    sudo --preserve-env docker start --interactive $(cat middle)