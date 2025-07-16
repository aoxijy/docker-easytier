# 使用最小的 Linux 系统作为基础镜像
FROM alpine:latest

# 设置版本号环境变量
ARG VERSION=v2.1.2

# 安装必要工具
RUN apk add --no-cache curl unzip iptables iproute2

# 创建工作目录
WORKDIR /app

# 下载 EasyTier 二进制文件
RUN curl -LO "https://github.com/EasyTier/EasyTier/releases/download/${VERSION}/easytier-linux-x86_64-${VERSION}.zip" \
    && unzip -j easytier-linux-x86_64-${VERSION}.zip \
    && rm easytier-linux-x86_64-${VERSION}.zip \
    && chmod +x easytier-*

# 创建 TUN 设备
RUN mkdir -p /dev/net \
    && mknod /dev/net/tun c 10 200 \
    && chmod 0666 /dev/net/tun

# 暴露 EasyTier 标准端口 (TCP/UDP)
EXPOSE 11010/tcp 11010/udp 11011/tcp 11020/tcp

# 设置环境变量
ENV ET_CONFIG_SERVER="udp://47.119.115.81:22020/gqru" \
    ET_MACHINE_ID="docker-$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)" \
    ET_RPC_PORTAL="0.0.0.0:15888" \
    ET_HOSTNAME="docker-node"

# 设置容器启动命令
CMD ["/app/easytier-core", \
    "--config-server", "${ET_CONFIG_SERVER}", \
    "--machine-id", "${ET_MACHINE_ID}", \
    "--rpc-portal", "${ET_RPC_PORTAL}", \
    "--hostname", "${ET_HOSTNAME}"]
