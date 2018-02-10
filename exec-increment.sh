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
        *)
            echo Unknown Option &&
                echo ${0} &&
                echo ${@} &&
                exit 64
        ;;
    esac
done &&
    if [ -z "${MAJOR}" ]
    then
        echo Unspecified MAJOR &&
            exit 65
    fi &&
    if [ -z "${MINOR}" ]
    then
        echo Unspecified MINOR &&
            exit 66
    fi &&
    if [ -z "${PATCH}" ]
    then
        echo Unspecified PATCH &&
            exit 67
    fi &&
    if [ -f "exec-${MAJOR}.${MINOR}.${PATCH}.sh" ]
    then
        echo exec-${MAJOR}-${MINOR}-${PATCH}.sh already exists &&
            exit 68
    fi &&
    if [ ${PATCH} -gt 0 ] && [ ! -f "exec-${MAJOR}.${MINOR}.$((${PATCH}-1)).sh" ]
    then
        echo "exec-${MAJOR}.${MINOR}.$((${PATCH}-1)).sh" does not exist &&
            exit 69
    fi &&
    if [ ${MINOR} -gt 0 ] && [ ! -f "exec-${MAJOR}.$((${MINOR}-1)).0.sh" ]
    then
        echo "exec-${MAJOR}.$((${MINOR}-1)).0.sh" does not exist &&
            exit 70
    fi &&
    if [ ${MAJOR} -gt 0 ] && [ ! -f "exec-$((${MAJOR}-1)).0.0.sh" ]
    then
        echo "exec-$((${MAJOR}-1)).0.0.sh" does not exist &&
            exit 71
    fi &&
    (cat > exec-${MAJOR}.${MINOR}.${PATCH}.sh <<EOF
#!/bin/sh

xhost +local: &&
    cleanup(){
        xhost -
    } &&
    trap cleanup EXIT &&
    sudo \
        --preserve-env \
        /usr/bin/docker \
        run \
        --interactive \
        --rm \
        --label expiry=\$((\$(date +%s)+60*60*24*7)) \
        --volume /var/run/docker.sock:/var/run/docker.sock:ro \
        --env DISPLAY \
        rebelplutonium/outer:${MAJOR}.${MINOR}.${PATCH} \
            "\${@}"    
EOF
    ) &&
    git add exec-${MAJOR}.${MINOR}.${PATCH}.sh