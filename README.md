# docker-easytier

run easytier in docker.

## install and use:

```bash
git clone https://github.com/kenny8zeng/docker-easytier.git
cd docker-easytier
docker compose up -d
```

## 配置

```toml
instance_name = "default"

# 注意：替换你的主机名
host_name = "comm.host.xxx"

# 虚拟网络的 IPv4 地址
# 注意：替换你想要的地址
ipv4 = "10.10.1.250"

# 是否启用 DHCP 功能
dhcp = false

# 远程节点列表
exit_nodes = []

# RPC 门户地址
rpc_portal = "127.0.0.1:15888"

# 监听器配置
listeners = [
    "tcp://0.0.0.0:32379",
    "udp://0.0.0.0:32379",
    "udp://[::]:32379",
    "tcp://[::]:32379",
    "wss://0.0.0.0:32380/",
    "wss://[::]:32380/",
]

# 网络凭证
# 注意：需要替换为你自己的网络名称和密钥
[network_identity]
network_name = "net.common.xxx"
network_secret = "b9a6f0fd40ce26d81d54"

# 连接的对等节点
# 注意：这里可以填写多个已经部署的公网行星结点
# [[peer]]
# uri = "tcp://ch01.xxxnet.com:32379"
# 
# [[peer]]
# uri = "tcp://ch02.xxxnet.com:32379"

# 其他参数
[flags]
dev_name = "easytier0"
enable_ipv6 = true
enable_exit_node = false
```