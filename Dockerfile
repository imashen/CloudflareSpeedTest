# 第一阶段：构建 Go 应用
FROM golang:1.22 AS builder

# 设置工作目录
WORKDIR /app

# 复制 go.mod 和 go.sum 文件
COPY go.mod go.sum ./

# 下载依赖
RUN go mod download

# 复制源码
COPY . .

# 复制 VERSION 文件
COPY VERSION ./VERSION

# 获取版本号
ARG VERSION
RUN echo "Building version $VERSION" && \
    go build -ldflags "-s -w -X main.version=$VERSION" -o CloudflareST

# 第二阶段：运行应用
FROM debian:bookworm-slim

# 设置工作目录
WORKDIR /app

# 复制从 builder 阶段生成的可执行文件
COPY --from=builder /app/CloudflareST .

# 复制本地的 shell 脚本
COPY dnspod.sh .

# 使脚本可执行
RUN chmod +x dnspod.sh

# 添加定时任务，使用环境变量来设置间隔时间
ENV UPDATE_INTERVAL=30

# 设置定时任务
RUN echo "*/${UPDATE_INTERVAL} * * * * /app/dnspod.sh >> /var/log/cron.log 2>&1" > /etc/cron.d/dnspod-cron

# 创建日志文件以使cron可以运行
RUN touch /var/log/cron.log

# 启动 cron 服务
CMD ["cron", "-f"]
