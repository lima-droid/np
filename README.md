NodePass 小手册

一键部署命令：

    bash <(wget -qO- https://raw.githubusercontent.com/lima-droid/np/main/np.sh)

版本信息：
- 稳定版：v1.15.0
- 开发版本：v1.15.1-b1
- 经典版：v1.10.3

项目简介：
NodePass 是一款通用的 TCP/UDP 隧道解决方案
采用控制与数据分离架构
支持零延迟连接池和多模式通信
可在网络限制下实现高性能、安全访问

系统要求：
- 操作系统：兼容 Debian / Ubuntu / OpenWRT
- 架构    ：x86_64 (amd64)
- 权限    ：需要 root 权限运行

np.sh 脚本说明（主程序安装）：
请按照提示提供以下信息：
- 语言选择（默认：中文）
- 服务器 IP 地址（127.0.0.1 可创建内网渗透 API 实例）
- 端口（留空则自动分配 1024–8192 范围端口）
- API 前缀（默认：api）
- TLS 模式：
    0：无加密
    1：自签名证书
    2：自定义证书

非交互式部署示例：
示例 1：未使用 TLS 加密
示例 2：自签名证书
示例 3：自定义证书

快捷命令：
np         显示交互式菜单
np -i      安装 NodePass
np -u      卸载 NodePass
np -v      升级 NodePass
np -t      切换稳定版 / 开发版
np -o      启动 / 停止服务
np -k      修改 API Key
np -s      查看 API 信息
np -h      显示帮助信息

目录结构：
/etc/nodepass/
├── data                # Configuration data
├── nodepass            # Main program symlink pointing to the currently used kernel file
├── np-dev              # Development version kernel file
├── np-stb              # Stable version kernel file
├── np-lts              # LTS version kernel file
├── qrencode            # QR code utility
├── nodepass.gob        # Data storage file
└── np.sh               # Installer and management script

提供信息说明：
- 域名或 IP：输入域名启用 HTTPS 反向代理与 SSL 证书；输入 IP 跳过反向代理和 Caddy 安装
- 端口：默认 3000，可自定义
- 自动检查端口冲突

卸载命令：
$ np -u

========================================
