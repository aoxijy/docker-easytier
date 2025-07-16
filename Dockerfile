# 使用最小的 Linux 系统作为基础镜像
FROM alpine:latest

# 设置版本号环境变量
ARG VERSION=v2.3.2

# 安装必要工具
RUN apk add --no-cache curl unzip iptables iproute2

# 创建工作目录
WORKDIR /app

# 下载 EasyTier 二进制文件
RUN curl -LO "https://github.com/EasyTier/EasyTier/releases/download/${VERSION}/easytier-linux-x86_64-${VERSION}.zip" \
    && unzip easytier-linux-x86_64-${VERSION}.zip \
    && rm easytier-linux-x86_64-${VERSION}.zip \
    && chmod +x easytier-*

# 创建 TUN 设备
RUN mkdir -p /dev/net \
    && mknod /dev/net/tun c 10 200 \
    && chmod 0666 /dev/net/tun

# 暴露 EasyTier 所需端口
EXPOSE 32379/tcp 32379/udp 32380/tcp

# 设置容器启动命令（使用 -w 参数指定自建 Web 管理器）
CMD ["/app/easytier-core", \
    "-w", "udp://47.119.115.81:22020/gqru", \
    "--hostname", "docker-node", \
    "--rpc-portal", "0.0.0.0:15888", \
    "--network-name", "docker-network", \
    "--network-secret", "your-secret-key", \
    "--default-protocol", "udp"]
