# WARP_PROXY
利用WARP构造 SOCKS v5代理服务器。

## 使用方法:
1. 编译镜像
```
chmod +x proxy.sh
./proxy.sh build
```


2. 运行socks5服务
```
./proxy run  # 默认开放在 127.0.0.1:1088,更换时间为1小时。
./proxy run  127.0.0.1:1089 10  
```

>其中 10 代表时间，将会间隔10分钟重新申请一个IP（IP有可能不更换）

3. 停止服务
```
./proxy stop
```