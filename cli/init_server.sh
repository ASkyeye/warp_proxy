#!/bin/bash
screen -dmS warp warp-svc
screen -dmS socat socat TCP-LISTEN:1080,fork,reuseaddr TCP:127.0.0.1:40000 
warp-cli set-mode proxy