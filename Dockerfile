# 使用最小的 Linux 系统作为基础镜像
FROM alpine:latest
 
# 安装必要的工具
RUN apk add --no-cache curl
 
# 创建工作目录
WORKDIR /data
 
# 下载 EasyTier 二进制文件
RUN curl -L -o easytier-core.zip https://github.com/EasyTier/EasyTier/releases/download/v2.1.2/easytier-linux-x86_64-v2.1.2.zip \
    && unzip -j -d /easytier easytier-core.zip \
    && rm -f easytier-core.zip \
    && chmod +x /easytier/easytier-cli \
    && chmod +x /easytier/easytier-web \
    && chmod +x /easytier/easytier-core
 
# 暴露 EasyTier 所需的端口
EXPOSE 32379 32380
 
# 设置容器启动时的默认命令
CMD ["/easytier/easytier-core", "--config-file", "/data/config.toml"]