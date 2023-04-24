FROM amd64/centos:8

COPY cli /root/warp/

RUN set -x \
	&& cd /etc/yum.repos.d/ \
    && sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-* \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-vault-8.5.2111.repo \
     && yum install epel-release -y \
	&& yum clean all \
	&& yum makecache \
    && yum update -y 

WORKDIR /root/warp/

RUN set -x \
    && yum install screen socat client.rpm -y \
    && chmod +x run.sh \
    && screen -dmS warp warp-svc && sleep 3 \
    && warp-cli --accept-tos register  && warp-cli --accept-tos set-mode proxy