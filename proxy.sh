#!/bin/bash

IMAGE_NAME="auto_proxy"
CONTAINER_NAME="auto_proxy_container"
CONTAINER_PORT="1080"
WORKDIR="/root/warp"
CLI_DIR="$(pwd)/cli/"

RED='\033[31m'
GREEN='\033[32m'
NC='\033[0m'

function build_image() {
    echo "Building Docker image..."
    docker build -t $IMAGE_NAME .
}

function validate_host_port() {
    local HOST_PORT=$1
    if [[ ! $HOST_PORT =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}:[0-9]+$ ]]; then
        echo -e "${RED}Invalid HOST_PORT format. It should be 'ip:port'.${NC}"
        exit 1
    fi
    local PORT=$(echo $HOST_PORT | cut -d ':' -f 2)
    if lsof -i :$PORT > /dev/null; then
        echo -e "${RED}The specified port ($PORT) is already in use. Please choose a different port.${NC}"
        exit 1
    fi
}

function run_container() {
    local HOST_PORT=$1
    local NUMBER=$2
    validate_host_port $HOST_PORT
    local RUN="$WORKDIR/run.sh $NUMBER"
    local CONTAINER_RUNNING=$(docker ps --filter "name=$CONTAINER_NAME" --format "{{.Names}}")

    # echo "Running Docker container..."
    if [ -z "$CONTAINER_RUNNING" ]; then
        # echo "Running Docker container..."
        docker run -d --rm \
            --name "$CONTAINER_NAME" \
            -v "$CLI_DIR:$WORKDIR" \
            -p "$HOST_PORT:$CONTAINER_PORT" \
            "$IMAGE_NAME" \
            sh -c "$RUN"
        echo -e "[+] Socks5 proxy started on port ${GREEN} $HOST_PORT ${NC}, and every ${GREEN} $NUMBER minutes ${NC} “warp” client will reconnect."
        echo -e "[+] Done."
    else
        echo -e "[!] Docker container with name ${RED} $CONTAINER_NAME ${NC} is already running."
        echo -e "[+] Socks5 proxy started on port ${GREEN} $HOST_PORT ${NC}."
    fi
}

function stop_container() {
    echo "Stopping Docker container..."
    docker stop $CONTAINER_NAME
}

if [ $# -eq 0 ]; then
    echo "Usage: $0 {build|run|stop} [host_port] [minute]"
    exit 1
fi

COMMAND=$1
shift

case $COMMAND in
    build)
        build_image
        ;;
    run)
        if [ $# -eq 0 ]; then
            HOST_PORT="127.0.0.1:1088"
        else
            HOST_PORT=$1
        fi
        if [ $# -lt 2 ]; then
            NUMBER=60
        else
            NUMBER=$2
        fi
        run_container $HOST_PORT $NUMBER
        ;;
    stop)
        stop_container
        ;;
    *)
        echo "Invalid command: $COMMAND"
        echo "Usage: $0 {build|run|stop} [host_port] [minute]"
        exit 1
        ;;
esac
