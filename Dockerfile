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

# 创建配置目录和默认配置文件
RUN mkdir -p /etc/easytier && \
    cat > /etc/easytier/config.toml << 'EOF'
# EasyTier 默认配置
instance_name = "default"
host_name = "docker-node"

# 虚拟网络设置
ipv4 = "10.110.0.1"
dhcp = false
exit_nodes = []

# RPC 管理接口
rpc_portal = "0.0.0.0:15888"

# 监听器配置
listeners = [
    "tcp://0.0.0.0:11010",
    "udp://0.0.0.0:11010",
    "tcp://[::]:11010",
    "udp://[::]:11010",
    "wss://0.0.0.0:11011/",
    "wss://[::]:11011/"
]

# 网络凭证
[network_identity]
network_name = "default-network"
network_secret = "change-me-please"

# 初始对等节点
[[peer]]
uri = "tcp://public.easytier.top:11010"

# 高级参数
[flags]
dev_name = "easytier0"
enable_ipv6 = false
enable_exit_node = false
EOF

# 创建 entrypoint 脚本
RUN echo $'#!/bin/sh\n\
# 如果设置了环境变量，更新配置文件\n\
if [ -n "$ET_CONFIG_SERVER" ]; then\n\
    tmp_file=$(mktemp)\n\
    jq --arg server "$ET_CONFIG_SERVER" \'\
.config_server = $server\' \
/etc/easytier/config.toml > "$tmp_file" \\\
    && mv "$tmp_file" /etc/easytier/config.toml\n\
fi\n\
\n\
if [ -n "$ET_MACHINE_ID" ]; then\n\
    tmp_file=$(mktemp)\n\
    jq --arg id "$ET_MACHINE_ID" \'\
.machine_id = $id\' \
/etc/easytier/config.toml > "$tmp_file" \\\
    && mv "$tmp_file" /etc/easytier/config.toml\n\
fi\n\
\n\
# 启动 EasyTier\n\
exec /app/easytier-core --config-file /etc/easytier/config.toml' > /app/entrypoint.sh \
    && chmod +x /app/entrypoint.sh

# 暴露标准端口
EXPOSE 11010/tcp 11010/udp 11011/tcp 11020/tcp 15888/tcp

# 设置容器启动命令
ENTRYPOINT ["/app/entrypoint.sh"]
