#!/bin/bash
function reconnect_warp() {
    while true; do

    # 检查连接状态
    status=$(warp-cli --accept-tos status)

    # 如果已经连接，断开现有连接
    if [[ $(echo "$status" | grep -c "Status update: Connected") -eq 1 ]]; then
        warp-cli --accept-tos disconnect
    fi

    # 尝试连接并检查连接状态
    warp-cli --accept-tos connect
    status=$(warp-cli --accept-tos status)

    # 等待连接成功
    while [[ $(echo "$status" | grep -c "Status update: Connecting") -eq 1 ]]; do
        echo "正在连接..."
        sleep 1
        status=$(warp-cli --accept-tos status)
    done
    # 如果连接成功，等待10分钟后再次尝试
    if [[ $(echo "$status" | grep -c "Status update: Connected") -eq 1 ]]; then
        echo "连接成功"
        sleep $(($wait_time * 60))
    else
        # 如果连接失败，等待1分钟后重试
        echo "连接失败"
        sleep 10
    fi
    done
}

function init_server(){
    process_status=$(pgrep -c 'socat')
    # 如果未找到 socat 进程，输出 "a"
    if [[ $process_status -eq 0 ]]; then
        screen -dmS warp warp-svc 
        screen -dmS socat socat TCP-LISTEN:1080,fork,reuseaddr TCP:127.0.0.1:40000 
    else
        echo "Server is already running"
    fi
    
}

# 检查是否有输入参数，如果没有，则使用默认的10分钟
if [ -z "$1" ]; then
  wait_time=60
else
  wait_time=$1
fi

init_server
# 等待服务启动
sleep 3
# 自动连接
reconnect_warp