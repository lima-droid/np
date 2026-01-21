NodePass部署 运行脚本：
bash <(wget -qO- https://raw.githubusercontent.com/lima-droid/np/main/np.sh)
稳定版：v1.15.0
开发版本：v1.15.1-b1
经典版:v1.10.3
NodePass是一款通用的
TCP/UDP 隧道解决方案
采用控制数据分离架构
支持零延迟连接池和多模式通信
可在网络限制下实现高性能、安全的访问。

系统要求
操作系统：兼容 Debian、Ubuntu、OpenWRT 等。
架构：支持 x86_64 (amd64)
权限：需要 root 权限才能运行
1.np.sh脚本（主程序安装）
请按照提示提供以下信息：
语言选择（默认：中文）
服务器 IP 地址（如果是 127.0.0.1，您可以选择创建一个具有内网渗透 API 的实例。）
端口（留空则使用 1024–8192 范围内的自动分配端口）
API 前缀（默认值api：）
TLS 模式（0：无加密，1：自签名证书，2：自定义证书）
非交互式部署
示例 1：未使用 TLS 加密
示例 2：自签名证书
示例 3：自定义证书
快捷命令
安装完成后，np快捷命令即被创建：

命令	描述
np	显示交互式菜单
np -i	安装 NodePass
np -u	卸载 NodePass
np -v	升级 NodePass
np -t	在稳定版和开发版之间切换
np -o	启动/停止服务
np -k	更改 API 密钥
np -s	查看 API 信息
np -h	显示帮助信息
目录结构
/etc/nodepass/
├── data                
├── nodepass           
├── np-dev            
├── np-stb              
├── nodepass.gob      
└── np.sh              
运行脚本：
bash <(wget -qO- https://raw.githubusercontent.com/lima-droid/np/main/np.sh)
提供信息：
域名或 IP：输入域名将启用 HTTPS 反向代理和 SSL 证书颁发；输入 IP 将跳过反向代理和 Caddy 安装。
端口：默认值为 3000，可自定义。
检查端口冲突
卸载 ：np -u
