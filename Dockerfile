# 使用最小的 Linux 系统作为基础镜像
FROM alpine:latest

# 设置版本号环境变量
ARG VERSION=v2.3.2

# 安装必要工具
RUN apk add --no-cache curl unzip iptables iproute2 jq

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

# 创建默认配置文件目录
RUN mkdir -p /etc/easytier

# 创建默认配置文件
RUN echo '[network_identity]' > /etc/easytier/config.toml \
    && echo 'network_name = "default"' >> /etc/easytier/config.toml \
    && echo 'network_secret = "change-me"' >> /etc/easytier/config.toml \
    && echo '' >> /etc/easytier/config.toml \
    && echo '[flags]' >> /etc/easytier/config.toml \
    && echo 'dev_name = "easytier0"' >> /etc/easytier/config.toml \
    && echo 'enable_ipv6 = false' >> /etc/easytier/config.toml

# 暴露 EasyTier 标准端口
EXPOSE 11010/tcp 11010/udp 11011/tcp 11020/tcp

# 设置入口点脚本
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# 设置容器启动命令
ENTRYPOINT ["/app/entrypoint.sh"]
