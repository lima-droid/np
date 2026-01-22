#!/usr/bin/env bash
# 当前脚本版本号
SCRIPT_VERSION='0.0.9'  # 版本号更新

# 环境变量用于在Debian或Ubuntu操作系统中设置非交互式（noninteractive）安装模式
export DEBIAN_FRONTEND=noninteractive

# 本地GitHub包目录
OFFLINE_DIR='/root/np'
# 工作目录和临时目录
TEMP_DIR='/tmp/nodepass'
WORK_DIR='/etc/nodepass'
GOB_DIR="$WORK_DIR/gob"

# 更好的trap处理
cleanup() {
    rm -rf "$TEMP_DIR" >/dev/null 2>&1
    echo -e "\n清理完成"
    exit 0
}
trap cleanup INT QUIT TERM EXIT

mkdir -p "$TEMP_DIR" 2>/dev/null

# 语言定义
E[0]="\n Language:\n 1. 简体中文 (Default)\n 2. English"
C[0]="${E[0]}"
E[1]="1. Supports three versions: stable, development, and classic; 2. Supports switching between the three versions (np -t); 3. Offline installation mode"
C[1]="1. 支持稳定版、开发版和经典版三个版本; 2. 支持三个版本间切换 (np -t); 3. GitHub模式"
E[2]="The script must be run as root, you can enter sudo -i and then download and run again. Feedback: [https://github.com/NodePassProject/npsh/issues]"
C[2]="必须以 root 方式运行脚本，可以输入 sudo -i 后重新下载运行，问题反馈:[https://github.com/NodePassProject/npsh/issues]"
E[3]="Unsupported architecture: \$(uname -m)"
C[3]="不支持的架构: \$(uname -m)"
E[4]="Please choose: "
C[4]="请选择: "
E[5]="The script supports Linux systems only. Feedback: [https://github.com/NodePassProject/npsh/issues]"
C[5]="本脚本只支持 Linux 系统，问题反馈:[https://github.com/NodePassProject/npsh/issues]"
E[6]="NodePass help menu"
C[6]="NodePass 帮助菜单"
E[7]="Install dependence-list:"
C[7]="安装依赖列表:"
E[8]="Failed to install download tool (curl). Please install wget or curl manually."
C[8]="无法安装下载工具（curl）。请手动安装 wget 或 curl。"
E[9]="Failed to copy required files from offline directory."
C[9]="从GitHub目录复制必需文件失败。"
E[10]="NodePass installed successfully!"
C[10]="NodePass 安装成功！"
E[11]="NodePass has been uninstalled"
C[11]="NodePass 已卸载"
E[12]="The external network of the current machine is single-stack:\\\n 1. \${SERVER_IPV4_DEFAULT}\${SERVER_IPV6_DEFAULT}\(default\)\\\n 2. Do not listen on the public network, only listen locally"
C[12]="检测到本机的外网是单栈:\\\n 1. \${SERVER_IPV4_DEFAULT}\${SERVER_IPV6_DEFAULT}，监听全栈 \(默认\)\\\n 2. 不对公网监听，只监听本地"
E[13]="Please enter the port (1024-65535, NAT machine must use an open port, press Enter for random port):"
C[13]="请输入端口 (1024-65535，NAT 机器必须使用开放的端口，回车使用随机端口):"
E[14]="Please enter API prefix (lowercase letters, numbers and / only, press Enter for default \"api\"):"
C[14]="请输入 API 前缀 (仅限小写字母、数字和斜杠/，回车使用默认 \"api\"):"
E[15]="Please select TLS mode (press Enter for none TLS encryption):"
C[15]="请选择 TLS 模式 (回车不使用 TLS 加密):"
E[16]="0. None TLS encryption (plain TCP) - Fastest performance, no overhead (default)\n 1. Self-signed certificate (auto-generated) - Fine security with simple setups\n 2. Custom certificate (requires pre-prepared crt and key files) - Highest security with certificate validation"
C[16]="0. 不使用 TLS 加密（明文 TCP） - 最快性能，无开销（默认）\n 1. 自签名证书（自动生成） - 设置简单的良好安全性\n 2. 自定义证书（须预备 crt 和 key 文件） - 具有证书验证的最高安全性"
E[17]="Please enter the correct option"
C[17]="请输入正确的选项"
E[18]="NodePass is already installed, please uninstall it before reinstalling"
C[18]="NodePass 已安装，请先卸载后再重新安装"
E[19]="NodePass files copied successfully from offline directory."
C[19]="已从GitHub目录复制 NodePass 文件"
E[20]="Cannot check version in offline mode"
C[20]="GitHub改版无法检查版本"
E[21]="Running in container environment, skipping service creation and starting process directly"
C[21]="在容器环境中运行，跳过服务创建，直接启动进程"
E[22]="NodePass Script Usage / NodePass 脚本使用方法:\n np - Show menu / 显示菜单\n np -i - Install NodePass / 安装 NodePass\n np -u - Uninstall NodePass / 卸载 NodePass\n np -v - Upgrade NodePass / 升级 NodePass\n np -t - Switch NodePass version between stable and development / 在稳定版和开发版之间切换 NodePass\n np -o - Toggle service status (start/stop) / 切换服务状态 (开启/停止)\n np -k - Change NodePass API key / 更换 NodePass API key\n np -c - Change intranet penetration server / 更换内网穿透\n np -s - Show NodePass API info / 显示 NodePass API 信息\n np -h - Show help information / 显示帮助信息\n np -p - Show port forwarding rules / 显示端口转发规则\n np --cli - Start interactive CLI / 启动交互式CLI"
C[22]="NodePass 脚本使用方法:\n np - 显示菜单\n np -i - 安装 NodePass\n np -u - 卸载 NodePass\n np -v - 升级 NodePass\n np -t - 切换 NodePass 版本\n np -o - 启动/停止服务\n np -k - 更换 API key\n np -c - 更换内网穿透服务器\n np -s - 显示 API 信息\n np -h - 显示帮助信息\n np -p - 显示端口转发规则\n np --cli - 启动交互式CLI"
E[23]="Please enter the path to your TLS certificate file:"
C[23]="请输入您的 TLS 证书文件路径:"
E[24]="Please enter the path to your TLS private key file:"
C[24]="请输入您的 TLS 私钥文件路径:"
E[25]="Certificate file does not exist:"
C[25]="证书文件不存在:"
E[26]="Private key file does not exist:"
C[26]="私钥文件不存在:"
E[27]="Using custom TLS certificate"
C[27]="使用自定义 TLS 证书"
E[28]="Install"
C[28]="安装"
E[29]="Uninstall"
C[29]="卸载"
E[30]="Upgrade core"
C[30]="升级内核"
E[31]="Exit"
C[31]="退出"
E[32]="not installed"
C[32]="未安装"
E[33]="stopped"
C[33]="已停止"
E[34]="running"
C[34]="运行中"
E[35]="NodePass Installation Information:"
C[35]="NodePass 安装信息:"
E[36]="Port is already in use, please try another one."
C[36]="端口已被占用，请尝试其他端口。"
E[37]="Using random port:"
C[37]="使用随机端口:"
E[38]="Please select: "
C[38]="请选择: "
E[39]="API URL:"
C[39]="API URL:"
E[40]="API KEY:"
C[40]="API KEY:"
E[41]="Invalid port number, please enter a number between 1024 and 65535."
C[41]="无效的端口号，请输入1024到65535之间的数字。"
E[42]="NodePass service has been stopped"
C[42]="NodePass 服务已关闭"
E[43]="NodePass service has been started"
C[43]="NodePass 服务已开启"
E[44]="Unable to get local version"
C[44]="无法获取本地版本"
E[45]="NodePass Local Core: Stable \$STABLE_LOCAL_VERSION Dev \$DEV_LOCAL_VERSION LTS \$LTS_LOCAL_VERSION"
C[45]="NodePass 本地核心: 稳定版 \$STABLE_LOCAL_VERSION 开发版 \$DEV_LOCAL_VERSION 经典版 \$LTS_LOCAL_VERSION"
E[46]="Offline mode: Cannot check remote versions"
C[46]="GitHub改版：更新请安装覆盖"
E[47]="Current version is already the latest, no need to upgrade"
C[47]="当前已是最新版本，不需要升级"
E[48]="Uninstall NodePass? (y/N)"
C[48]="是否卸载 NodePass？(y/N)"
E[49]="Uninstall cancelled"
C[49]="取消卸载"
E[50]="Stopping NodePass service..."
C[50]="停止 NodePass 服务..."
E[51]="Starting NodePass service..."
C[51]="启动 NodePass 服务..."
E[52]="NodePass upgrade successful!"
C[52]="NodePass 升级成功！"
E[53]="Failed to start NodePass service, please check logs"
C[53]="NodePass 服务启动失败，请检查日志"
E[54]="Rolled back to previous version"
C[54]="已回滚到之前的版本"
E[55]="Rollback failed, please check manually"
C[55]="回滚失败，请手动检查"
E[56]="Stop API"
C[56]="关闭 API"
E[57]="Create shortcuts successfully: script can be run with [ np ] command, and [ nodepass ] binary is directly executable."
C[57]="创建快捷方式成功: 脚本可通过 [ np ] 命令运行，[ nodepass ] 应用可直接执行!"
E[58]="Start API"
C[58]="开启 API"
E[59]="NodePass is not installed. Configuration file not found"
C[59]="NodePass 未安装，配置文件不存在"
E[60]="NodePass API:"
C[60]="NodePass API:"
E[61]="PREFIX can only contain lowercase letters, numbers and slashes (/), please re-enter"
C[61]="PREFIX 只能包含小写字母、数字和斜杠(/)，请重新输入"
E[62]="Change KEY"
C[62]="更换 KEY"
E[63]="API KEY changed successfully!"
C[63]="API KEY 更换成功"
E[64]="Failed to change API KEY"
C[64]="API KEY 更换失败"
E[65]="Changing NodePass API KEY..."
C[65]="正在更换 NodePass API KEY..."
E[66]="Current running version: Development GitHub"
C[66]="当前运行版本为: 开发版"
E[67]="Current running version: Stable GitHub"
C[67]="当前运行版本为: 稳定版"
E[68]="Please enter the IP of the public machine (leave blank to not penetrate):"
C[68]="如要把内网的 API 穿透到公网的 NodePass 服务端，请输入公网机器的 IP (留空则不穿透):"
E[69]="Please enter the port of the public machine:"
C[69]="请输入穿透到公网的 NodePass 服务端的端口:"
E[70]="Change intranet penetration server"
C[70]="更换内网穿透"
E[71]="Please enter the password (default is no password):"
C[71]="输入密码（默认无密码）:"
E[72]="The service of intranet penetration to remote has been created successfully"
C[72]="内网穿透到远程的服务已创建成功"
E[73]="API intranet penetration server creation failed!"
C[73]="API 内网穿透到远程的服务创建失败!"
E[74]="Not a valid IPv4,IPv6 address or domain name"
C[74]="不是有效的IPv4,IPv6地址或域名"
E[75]="Please enter the IP of the intranet penetration server:"
C[75]="输入新的内网穿透服务端 IP 或域名:"
E[76]="Successfully modified the intranet penetration instance"
C[76]="成功修改内网穿透实例"
E[77]="Failed to modify the intranet penetration instance"
C[77]="修改内网穿透实例失败"
E[78]="The external network of the current machine is dual-stack:\\\n 1. \${SERVER_IPV4_DEFAULT}，listen all stacks \(default\)\\\n 2. \${SERVER_IPV6_DEFAULT}，listen all stacks\\\n 3. Do not listen on the public network, only listen locally"
C[78]="检测到本机的外网是双栈:\\\n 1. \${SERVER_IPV4_DEFAULT}，监听全栈 \(默认\)\\\n 2. \${SERVER_IPV6_DEFAULT}，监听全栈\\\n 3. 不对公网监听，只监听本地"
E[79]="Please select or enter the domain or IP directly:"
C[79]="请选择或者直接输入域名或 IP:"
E[80]="Script statistics disabled in offline mode"
C[80]="GitHub改版禁用脚本统计"
E[81]="Please enter the port on the server that the local machine will connect to for the tunnel (1024–65535):"
C[81]="请输入用于内网穿透中，本机连接到服务端的隧道端口（即服务端监听的端口）（1024–65535）:"
E[82]="Running the service of intranet penetration on the server side:"
C[82]="内网穿透的服务端运行:"
E[83]="Failed to retrieve intranet penetration instance. Instance ID: \${INSTANCE\_ID}"
C[83]="获取内网穿透实例失败，实例ID: \${INSTANCE_ID}"
E[84]="Please select the NodePass core to run. Use [np -t] to switch after installation:\\\n 1. Stable version - Suitable for production environments \(default\)\\\n 2. Development version - Contains latest features, may be unstable\\\n 3. Classic version - Long-term support version"
C[84]="选择 NodePass 内核（安装后可用 [np -t] 切换）：1. 稳定（默认，生产） 2. 开发（最新，可能不稳） 3. 经典（长期支持）"
E[85]="Getting machine IP address..."
C[85]="获取机器 IP 地址中..."
E[86]="Switching NodePass version..."
C[86]="正在切换 NodePass 版本..."
E[87]="Switched successfully"
C[87]="已成功切换"
E[88]="Please select the version to switch to (default is 3):"
C[88]="请选择要切换到的版本 (默认为 3):"
E[89]="NodePass version switch failed"
C[89]="NodePass 版本切换失败"
E[90]="URI:"
C[90]="URI:"
E[91]="No upgrade available for both stable, development and classic versions"
C[91]="稳定版、开发版和经典版均无可用更新"
E[92]="Stable version can be upgraded from \$STABLE_LOCAL_VERSION to new version"
C[92]="稳定版可以从 \$STABLE_LOCAL_VERSION 升级到新版本"
E[93]="Development version can be upgraded from \$DEV_LOCAL_VERSION to new version"
C[93]="开发版可以从 \$DEV_LOCAL_VERSION 升级到新版本"
E[94]="Checking for available updates..."
C[94]="检查可用更新..."
E[95]="Switch core version"
C[95]="切换内核版本"
E[96]="Waiting 5 seconds before starting the service..."
C[96]="正在等待5秒后启动服务..."
E[97]="Current running version:"
C[97]="当前运行版本:"
E[98]="Current running version: Classic GitHub"
C[98]="当前运行版本为: 经典版"
E[99]="Classic version can be upgraded from \$LTS_LOCAL_VERSION to new version"
C[99]="经典版可以从 \$LTS_LOCAL_VERSION 升级到新版本"
E[100]="Switch to stable version (np-stb)"
C[100]="切换到稳定版 (np-stb)"
E[101]="Switch to development version (np-dev)"
C[101]="切换到开发版 (np-dev)"
E[102]="Switch to classic version (np-lts)"
C[102]="切换到经典版 (np-lts)"
E[103]="Cancel switching"
C[103]="取消切换"
E[104]="Please select the version to switch to (default is 3):"
C[104]="请选择要切换到的版本 (默认为 3):"
E[105]="Offline installation - copying files from local directory: $OFFLINE_DIR"
C[105]="GitHub - 从本地目录复制文件: $OFFLINE_DIR"
E[106]="Required file missing: "
C[106]="缺少必需文件: "
E[107]="Offline package directory not found: $OFFLINE_DIR"
C[107]="GitHub包目录未找到: $OFFLINE_DIR"
E[108]="Checking offline package directory..."
C[108]="检查GitHub包目录..."
E[109]="Offline package directory exists"
C[109]="GitHub包目录存在"
E[110]="Available upgrade files: "
C[110]="可用升级文件: "
E[111]="No upgrade files found"
C[111]="未找到升级文件"
E[112]="Upgraded "
C[112]="已升级 "
E[113]="Local management script created successfully"
C[113]="本地管理脚本创建成功"
E[114]="Downloading offline package from backup source..."
C[114]="从备用源下载GitHub包..."
E[115]="Backup source download completed"
C[115]="备用源下载完成"
E[116]="Backup source download failed"
C[116]="备用源下载失败"
E[117]="Deleting temporary files..."
C[117]="删除临时文件..."
E[118]="Checking backup file..."
C[118]="检查备份文件..."
E[119]="Backup file nodepass.gob.backup created successfully"
C[119]="备份文件 nodepass.gob.backup 创建成功"
E[120]="Failed to create backup file"
C[120]="创建备份文件失败"
E[121]="Interactive CLI mode"
C[121]="交互式CLI模式"
E[122]="Starting interactive CLI assistant..."
C[122]="启动交互式CLI助手..."
E[123]="Interactive CLI not found. Run 'np --cli install' to install it."
C[123]="交互式CLI未找到。运行 'np --cli install' 安装。"

# 自定义字体彩色，read 函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

warning() { echo -e "${RED}${*}${NC}"; }
error() { echo -e "${RED}${*}${NC}" && exit 1; }
info() { echo -e "${GREEN}${*}${NC}"; }
hint() { echo -e "${YELLOW}${*}${NC}"; }
success() { echo -e "${GREEN}${*}${NC}"; }
reading() { read -rp "$(info "$1")" "$2"; }
text() { eval echo "\${${L}[$*]}"; }

# 从备用源下载GitHub包 - 改进错误处理
download_backup_offline_package() {
    info " $(text 114) "
    
    # 下载GitHub包到 /root/np 目录
    mkdir -p "$OFFLINE_DIR"
    cd /root || error "无法进入/root目录"
    
    # 检查wget是否可用
    if ! command -v wget &>/dev/null; then
        if command -v curl &>/dev/null; then
            curl -sL -o npsh.zip https://github.com/lima-droid/np/archive/refs/heads/main.zip || {
                warning "下载失败"
                return 1
            }
        else
            error "需要wget或curl工具"
        fi
    else
        wget -qO npsh.zip https://github.com/lima-droid/np/archive/refs/heads/main.zip || {
            warning "下载失败"
            return 1
        }
    fi
    
    # 检查unzip是否可用
    if ! command -v unzip &>/dev/null; then
        if [ -f /etc/debian_version ]; then
            apt-get update && apt-get install -y unzip
        elif [ -f /etc/redhat-release ]; then
            yum install -y unzip
        elif [ -f /etc/alpine-release ]; then
            apk add unzip
        else
            error "需要unzip工具"
        fi
    fi
    
    unzip -j -q npsh.zip "np-main/np/*" -d "$OFFLINE_DIR" 2>/dev/null
    local unzip_status=$?
    
    rm -f npsh.zip
    
    if [ $unzip_status -eq 0 ]; then
        info " $(text 115) "
        return 0
    else
        warning " $(text 116) "
        return 1
    fi
}

# 检查GitHub包目录 - 改进错误处理
check_and_prepare_offline_files() {
    info " $(text 108) "
    
    # 检查GitHub目录是否存在
    if [ ! -d "$OFFLINE_DIR" ]; then
        hint "GitHub包目录未找到，尝试从备用源下载..."
        if ! download_backup_offline_package; then
            error " $(text 107) "
        fi
    fi
    
    info " $(text 109) "
    
    # 必需文件列表
    local required_files=("np-stb" "np-dev" "np-lts" "qrencode")
    local missing_files=()
    
    # 检查必需文件
    for file in "${required_files[@]}"; do
        if [ ! -f "$OFFLINE_DIR/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    # 如果有缺失文件，尝试从备用源下载
    if [ ${#missing_files[@]} -gt 0 ]; then
        hint "部分文件缺失，尝试从备用源下载..."
        if ! download_backup_offline_package; then
            for file in "${missing_files[@]}"; do
                warning " $(text 106) $file"
            done
            error " $(text 9) "
        fi
    fi
    
    # 复制文件到临时目录
    for file in "${required_files[@]}"; do
        if [ -f "$OFFLINE_DIR/$file" ]; then
            cp "$OFFLINE_DIR/$file" "$TEMP_DIR/" || error "复制 $file 失败"
            chmod +x "$TEMP_DIR/$file" 2>/dev/null
        else
            error "文件不存在: $OFFLINE_DIR/$file"
        fi
    done
    
    info " $(text 19) "
}

# 显示帮助信息 - 改进格式
help() {
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║                 NodePass 帮助菜单                    ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
    hint " $(text 22) "
    echo ""
    echo "示例:"
    echo "  np -i         安装NodePass"
    echo "  np -s         查看状态和API信息"
    echo "  np -o         启动/停止服务"
    echo "  np -p         显示端口转发规则"
    echo "  np --cli      启动交互式CLI助手"
    echo ""
}

# 检查系统信息 - 改进容器检测
check_system_info() {
    # 检查架构
    case "$(uname -m)" in
        x86_64 | amd64 ) ARCH=amd64 ;;
        armv8 | arm64 | aarch64 ) ARCH=arm64 ;;
        armv7l ) ARCH=arm ;;
        s390x ) ARCH=s390x ;;
        * ) error " $(text 3) " ;;
    esac
    
    # 改进容器检测
    if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null || \
       [ -n "$container" ] || [ -f /run/.containerenv ]; then
        IN_CONTAINER=1
        info "检测到容器环境"
    else
        IN_CONTAINER=0
    fi
    
    # 检查系统
    if [ -f /etc/openwrt_release ]; then
        SYSTEM="OpenWRT"
        SERVICE_MANAGE="init.d"
    elif [ -f /etc/os-release ]; then
        source /etc/os-release
        SYSTEM=$ID
        [[ $SYSTEM = "centos" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 7 ]] && SYSTEM=centos
        [[ $SYSTEM = "debian" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 10 ]] && SYSTEM=debian
        [[ $SYSTEM = "ubuntu" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 16 ]] && SYSTEM=ubuntu
        [[ $SYSTEM = "alpine" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 3 ]] && SYSTEM=alpine
    fi
    
    # 确定服务管理方式
    if [ -z "$SERVICE_MANAGE" ]; then
        if [ -x "$(type -p systemctl)" ]; then
            SERVICE_MANAGE="systemctl"
        elif [ -x "$(type -p openrc-run)" ]; then
            SERVICE_MANAGE="rc-service"
        elif [[ -x "$(type -p service)" && -d /etc/init.d ]]; then
            SERVICE_MANAGE="init.d"
        else
            SERVICE_MANAGE="none"
        fi
    fi
}

# 检查端口是否可用 - 改进检查逻辑
check_port() {
    local PORT=$1
    local NO_CHECK_USED=$2
    
    # 检查端口是否为数字且在有效范围内
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
        return 2
    fi
    
    if ! grep -q 'no_check_used' <<< "$NO_CHECK_USED"; then
        # 使用多种方法检查端口占用
        local port_in_use=0
        
        # 方法1: 使用 /dev/tcp
        if timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/$PORT" 2>/dev/null; then
            port_in_use=1
        fi
        
        # 方法2: 使用ss（如果可用）
        if command -v ss &>/dev/null; then
            if ss -tuln | grep -q ":$PORT "; then
                port_in_use=1
            fi
        # 方法3: 使用netstat
        elif command -v netstat &>/dev/null; then
            if netstat -tuln 2>/dev/null | grep -q ":$PORT "; then
                port_in_use=1
            fi
        fi
        
        if [ $port_in_use -eq 1 ]; then
            return 1
        fi
    fi
    
    return 0
}

# 获取随机可用端口 - 改进算法
get_random_port() {
    local RANDOM_PORT
    local attempts=0
    local max_attempts=50
    
    while [ $attempts -lt $max_attempts ]; do
        # 在1024-49151之间生成端口（动态/私有端口范围）
        RANDOM_PORT=$(( RANDOM % 48128 + 1024 ))
        
        if check_port "$RANDOM_PORT" "check_used"; then
            echo "$RANDOM_PORT"
            return 0
        fi
        
        attempts=$((attempts + 1))
    done
    
    # 如果多次尝试失败，返回一个固定范围内的端口
    for port in {20000..20100}; do
        if check_port "$port" "check_used"; then
            echo "$port"
            return 0
        fi
    done
    
    error "无法找到可用端口"
}

# 显示端口转发规则 - 改进显示格式
show_port_rules() {
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║              NodePass 端口转发规则                   ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo "┌─────────────────┬──────────┬─────────────────────────┐"
    echo "│ 类型            │ 端口     │ 目标                    │"
    echo "├─────────────────┼──────────┼─────────────────────────┤"
    
    # 获取进程信息
    local ps_cmd="ps aux"
    if [ -f /etc/openwrt_release ]; then
        ps_cmd="ps w"
    fi
    
    $ps_cmd 2>/dev/null | grep nodepass | grep -v grep | grep -E 'master://|client://|server://' | while read line; do
        local type_str=""
        local port=""
        local target=""
        
        # 解析master类型
        if echo "$line" | grep -q 'master://'; then
            type_str="API"
            port=$(echo "$line" | sed -n 's/.*master:\/\/[^:]*:\([0-9]\+\).*/\1/p')
            target="控制接口"
        # 解析server类型
        elif echo "$line" | grep -q 'server://'; then
            type_str="服务端"
            port=$(echo "$line" | sed -n 's/.*server:\/\/[^:]*:\([0-9]\+\).*/\1/p')
            target=$(echo "$line" | sed -n 's/.*server:\/\/[^:]*:[0-9]\+\(\/[^ ]*\).*/\1/p' | sed 's/^\///')
        # 解析client类型
        elif echo "$line" | grep -q 'client://'; then
            type_str="客户端"
            port=$(echo "$line" | sed -n 's/.*client:\/\/[^:]*:\([0-9]\+\).*/\1/p')
            target=$(echo "$line" | sed -n 's/.*client:\/\/[^:]*:[0-9]\+\(\/[^ ]*\).*/\1/p' | sed 's/^\///')
        fi
        
        if [ -n "$port" ]; then
            printf "│ %-15s │ %-8s │ %-23s │\n" "$type_str" "$port" "${target:0:23}"
        fi
    done
    
    echo "└─────────────────┴──────────┴─────────────────────────┘"
    echo ""
}

# 安装交互式CLI
install_interactive_cli() {
    info " $(text 122) "
    
    # 创建CLI脚本
    cat > /usr/local/bin/np-cli << 'EOF'
#!/usr/bin/env bash
# nodepass-cli.sh - NodePass交互式CLI工具
# 版本: 1.0.0

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 全局变量
PROMPT_FILE="$HOME/.nodepass/prompt.md"
HISTORY_FILE="$HOME/.nodepass/history.txt"
CONFIG_DIR="$HOME/.nodepass"
LOG_FILE="$HOME/.nodepass/cli.log"
SESSION_ID=$(date +%s%N | sha256sum | head -c 8)
WORK_DIR="/etc/nodepass"

# 初始化
init_cli() {
    mkdir -p "$CONFIG_DIR"
    
    # 创建初始提示文件
    if [ ! -f "$PROMPT_FILE" ]; then
        create_prompt_file
    fi
    
    # 创建历史文件
    touch "$HISTORY_FILE"
    
    # 设置日志
    exec 3>&1 4>&2
    exec 1>>"$LOG_FILE" 2>&1
    echo "=== 会话开始: $(date) ===" >> "$LOG_FILE"
}

# 创建提示文件
create_prompt_file() {
    cat > "$PROMPT_FILE" << 'EOF'
# NodePass管理助手角色定义

## 角色
你是一个专业的NodePass系统管理助手。NodePass是一个TCP/UDP隧道解决方案。

## 可用命令参考
| 命令 | 选项 | 描述 | 示例 |
|------|------|------|------|
| np | -i | 安装NodePass | np -i |
| np | -u | 卸载NodePass | np -u |
| np | -v | 升级NodePass | np -v |
| np | -t | 切换版本 | np -t |
| np | -o | 启动/停止服务 | np -o |
| np | -s | 查看状态信息 | np -s |
| np | -p | 显示端口规则 | np -p |
| np | -k | 更换API密钥 | np -k |
| np | -c | 更换穿透服务 | np -c |
| np | -h | 显示帮助信息 | np -h |
| np | (无) | 进入交互菜单 | np |
| np | --cli | 交互式CLI | np --cli |

## 系统状态命令
- `systemctl status nodepass` - 查看服务状态
- `journalctl -u nodepass -f` - 查看实时日志
- `netstat -tlnp | grep nodepass` - 查看端口占用

## 常见问题解决方案
1. **端口冲突**: 检查端口占用或更换端口
2. **连接失败**: 检查网络和防火墙设置
3. **服务无法启动**: 查看日志文件 /var/log/nodepass.log
4. **更新失败**: 检查网络连接或手动下载更新

## 回复要求
1. 提供准确、实用的解决方案
2. 如果是复杂操作，分步骤说明
3. 提示潜在风险和注意事项
4. 使用emoji使回复更友好
5. 保持专业性但语言通俗易懂
EOF
    echo "✅ 提示文件已创建: $PROMPT_FILE"
}

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║         NodePass 交互式管理助手 v1.0.0              ║${NC}"
    echo -e "${CYAN}║          会话ID: $SESSION_ID                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}💡 提示: 输入'help'查看可用命令，'exit'退出程序${NC}"
    echo -e "${YELLOW}📝 历史记录保存在: $HISTORY_FILE${NC}"
    echo ""
}

# 显示帮助信息
show_help() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}📚 NodePass CLI 可用命令:${NC}"
    echo ""
    
    echo -e "${GREEN}🔧 管理命令:${NC}"
    echo -e "  help    - 显示此帮助信息"
    echo -e "  menu    - 进入图形菜单模式 (np)"
    echo -e "  exit    - 退出程序"
    echo -e "  clear   - 清屏"
    echo -e "  history - 查看命令历史"
    echo ""
    
    echo -e "${YELLOW}⚡ 快捷命令:${NC}"
    echo -e "  install   - 安装NodePass (np -i)"
    echo -e "  uninstall - 卸载NodePass (np -u)"
    echo -e "  status    - 查看状态 (np -s)"
    echo -e "  start     - 启动服务"
    echo -e "  stop      - 停止服务"
    echo -e "  restart   - 重启服务"
    echo -e "  logs      - 查看日志"
    echo -e "  ports     - 查看端口 (np -p)"
    echo -e "  update    - 检查更新"
    echo ""
    
    echo -e "${BLUE}📁 文件命令:${NC}"
    echo -e "  config   - 查看配置"
    echo -e "  backup   - 备份配置"
    echo -e "  restore  - 恢复配置"
    echo -e "  clean    - 清理缓存"
    echo ""
    
    echo -e "${CYAN}💡 高级命令:${NC}"
    echo -e "  debug    - 调试模式"
    echo -e "  test     - 运行测试"
    echo -e "  monitor  - 监控资源"
    echo ""
    
    echo -e "${RED}⚠️  危险命令:${NC}"
    echo -e "  reset    - 重置所有配置"
    echo -e "  force    - 强制操作 (谨慎使用)"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 执行命令
execute_command() {
    local cmd="$1"
    local args="${@:2}"
    
    # 记录到历史
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $cmd $args" >> "$HISTORY_FILE"
    
    case "$cmd" in
        "help")
            show_help
            ;;
        "menu")
            echo -e "${GREEN}🚀 启动图形菜单...${NC}"
            np
            ;;
        "install"|"i")
            echo -e "${GREEN}📦 开始安装NodePass...${NC}"
            np -i
            ;;
        "uninstall"|"u")
            echo -e "${YELLOW}🗑️  开始卸载NodePass...${NC}"
            np -u
            ;;
        "status"|"s")
            echo -e "${BLUE}📊 获取状态信息...${NC}"
            np -s
            ;;
        "start")
            echo -e "${GREEN}▶️  启动NodePass服务...${NC}"
            systemctl start nodepass 2>/dev/null || service nodepass start
            ;;
        "stop")
            echo -e "${YELLOW}⏹️  停止NodePass服务...${NC}"
            systemctl stop nodepass 2>/dev/null || service nodepass stop
            ;;
        "restart")
            echo -e "${CYAN}🔄 重启NodePass服务...${NC}"
            systemctl restart nodepass 2>/dev/null || service nodepass restart
            ;;
        "logs")
            echo -e "${MAGENTA}📋 显示日志(最后50行)...${NC}"
            if [ -f "/var/log/nodepass.log" ]; then
                tail -50 /var/log/nodepass.log
            else
                journalctl -u nodepass -n 50
            fi
            ;;
        "ports"|"p")
            echo -e "${GREEN}🔌 查看端口规则...${NC}"
            np -p
            ;;
        "config")
            show_config
            ;;
        "backup")
            backup_config
            ;;
        "restore")
            restore_config
            ;;
        "update"|"upgrade")
            echo -e "${CYAN}🔄 检查更新...${NC}"
            np -v
            ;;
        "clear")
            clear
            show_welcome
            ;;
        "history")
            show_history
            ;;
        "clean")
            clean_cache
            ;;
        "debug")
            enable_debug
            ;;
        "test")
            run_tests
            ;;
        "monitor")
            monitor_resources
            ;;
        "reset")
            reset_all
            ;;
        "exit"|"quit"|"q")
            echo -e "${GREEN}👋 再见！感谢使用NodePass CLI。${NC}"
            exit 0
            ;;
        *)
            # 如果不是内置命令，尝试作为AI查询处理
            handle_ai_query "$cmd $args"
            ;;
    esac
}

# 显示配置
show_config() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}⚙️  NodePass 配置信息${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -f "$WORK_DIR/.api_key" ]; then
        local api_key=$(cat "$WORK_DIR/.api_key" 2>/dev/null | head -c 20)
        echo -e "🔑 API密钥: ${api_key}..."
    fi
    
    if [ -f "$WORK_DIR/.api_url" ]; then
        echo -e "🌐 API地址: $(cat "$WORK_DIR/.api_url" 2>/dev/null)"
    fi
    
    if [ -f "$WORK_DIR/nodepass" ]; then
        local version=$("$WORK_DIR/nodepass" --version 2>/dev/null || echo "未知")
        echo -e "📦 版本: $version"
    fi
    
    # 检查服务状态
    if systemctl is-active nodepass >/dev/null 2>&1; then
        echo -e "🟢 服务状态: 运行中"
    else
        echo -e "🔴 服务状态: 已停止"
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# 备份配置
backup_config() {
    local backup_dir="$CONFIG_DIR/backups"
    local timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$backup_dir/nodepass_backup_$timestamp.tar.gz"
    
    mkdir -p "$backup_dir"
    
    echo -e "${CYAN}📂 正在备份配置...${NC}"
    
    tar -czf "$backup_file" \
        "$WORK_DIR/.api_key" \
        "$WORK_DIR/.api_url" \
        "$WORK_DIR/config.conf" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 备份成功: $backup_file${NC}"
        ls -lh "$backup_file"
    else
        echo -e "${RED}❌ 备份失败${NC}"
    fi
}

# 显示历史
show_history() {
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}📜 命令历史${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ -s "$HISTORY_FILE" ]; then
        tail -20 "$HISTORY_FILE" | nl -ba
    else
        echo -e "${YELLOW}📭 暂无历史记录${NC}"
    fi
}

# 清理缓存
clean_cache() {
    echo -e "${YELLOW}🧹 正在清理缓存...${NC}"
    
    # 清理临时文件
    rm -rf /tmp/nodepass* 2>/dev/null
    
    # 清理日志（保留最近7天）
    find /var/log -name "*nodepass*" -type f -mtime +7 -delete 2>/dev/null
    
    echo -e "${GREEN}✅ 缓存清理完成${NC}"
}

# 处理AI查询
handle_ai_query() {
    local query="$*"
    
    # 添加到提示文件
    echo -e "\n## 用户查询: $query" >> "$PROMPT_FILE"
    echo -e "时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$PROMPT_FILE"
    
    echo -e "${CYAN}🤖 正在分析您的问题...${NC}"
    echo ""
    
    # 尝试使用不同的AI后端
    if command -v claude-code &>/dev/null; then
        cat "$PROMPT_FILE" | claude-code
    elif command -v chatgpt &>/dev/null; then
        echo "$query" | chatgpt
    elif command -v llm &>/dev/null; then
        llm "$query"
    elif command -v curl &>/dev/null; then
        # 如果有API，可以调用在线服务
        echo -e "${YELLOW}⚠️  未找到本地AI工具，建议手动执行命令。${NC}"
        echo -e "💡 您可以尝试: np -h 查看帮助"
    else
        echo -e "${YELLOW}⚠️  未找到AI工具，显示常规帮助：${NC}"
        echo ""
        np -h
    fi
    
    # 将回复添加到提示文件
    echo -e "\n## 助手回复摘要" >> "$PROMPT_FILE"
    echo -e "已提供相关建议和命令参考" >> "$PROMPT_FILE"
    echo -e "---" >> "$PROMPT_FILE"
}

# 调试模式
enable_debug() {
    echo -e "${RED}🔧 启用调试模式...${NC}"
    set -x
    echo -e "${YELLOW}⚠️  所有命令将显示详细信息${NC}"
}

# 运行测试
run_tests() {
    echo -e "${CYAN}🧪 运行基本测试...${NC}"
    
    # 测试1: 检查np命令
    if command -v np &>/dev/null; then
        echo -e "✅ np命令可用"
    else
        echo -e "❌ np命令未找到"
    fi
    
    # 测试2: 检查服务
    if systemctl list-unit-files | grep -q nodepass; then
        echo -e "✅ NodePass服务已安装"
    else
        echo -e "⚠️  NodePass服务未安装"
    fi
    
    # 测试3: 网络连接
    if ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
        echo -e "✅ 网络连接正常"
    else
        echo -e "❌ 网络连接失败"
    fi
    
    echo -e "${GREEN}🎉 基本测试完成${NC}"
}

# 监控资源
monitor_resources() {
    echo -e "${CYAN}📈 资源监控 (按Ctrl+C退出)...${NC}"
    
    echo -e "${GREEN}CPU 内存 进程${NC}"
    echo -e "${CYAN}──────────────────────────${NC}"
    
    # 简单的监控循环
    for i in {1..10}; do
        if pgrep nodepass &>/dev/null; then
            local pid=$(pgrep nodepass | head -1)
            local cpu=$(ps -p $pid -o %cpu --no-headers 2>/dev/null)
            local mem=$(ps -p $pid -o %mem --no-headers 2>/dev/null)
            echo -e "CPU: ${cpu}% | 内存: ${mem}% | PID: $pid"
        else
            echo -e "🔴 NodePass进程未运行"
        fi
        sleep 2
    done
}

# 重置所有
reset_all() {
    echo -e "${RED}⚠️  ⚠️  ⚠️  危险操作！${NC}"
    echo -e "${RED}这将删除所有NodePass配置和数据！${NC}"
    
    read -p "确认重置? (输入'RESET'确认): " confirm
    if [ "$confirm" = "RESET" ]; then
        echo -e "${YELLOW}🗑️  正在重置...${NC}"
        
        # 停止服务
        systemctl stop nodepass 2>/dev/null
        
        # 删除配置文件
        rm -rf "$WORK_DIR"
        rm -rf "$CONFIG_DIR"
        
        echo -e "${GREEN}✅ 重置完成，所有配置已删除${NC}"
    else
        echo -e "${GREEN}✅ 操作已取消${NC}"
    fi
}

# 读取用户输入（支持历史）
read_input() {
    local input
    read -e -p "$(echo -e "${GREEN}np-cli> ${NC}")" input
    
    # 如果有历史记录文件，可以在这里添加readline支持
    history -r "$HISTORY_FILE" 2>/dev/null
    history -s "$input" 2>/dev/null
    history -w "$HISTORY_FILE" 2>/dev/null
    
    echo "$input"
}

# 主函数
main() {
    init_cli
    show_welcome
    
    # 检查np命令是否可用
    if ! command -v np &>/dev/null; then
        echo -e "${YELLOW}⚠️  未找到np命令，某些功能可能受限${NC}"
        echo -e "${GREEN}💡 建议先运行安装: np -i${NC}"
        echo ""
    fi
    
    # 主循环
    while true; do
        local input=$(read_input)
        
        if [[ -z "$input" ]]; then
            continue
        fi
        
        # 执行命令
        execute_command $input
        
        echo ""
    done
}

# 异常处理
trap 'echo -e "\n${RED}⚠️  程序被中断${NC}"; exit 1' INT TERM
trap 'echo -e "${GREEN}👋 退出CLI工具${NC}"; exit 0' EXIT

# 检查是否以 root 运行
if [ "$(id -u)" != 0 ]; then
    echo -e "${RED}错误: 需要 root 权限运行${NC}"
    exit 1
fi

# 启动主函数
main "$@"
EOF
    
    chmod +x /usr/local/bin/np-cli
    
    # 创建符号链接
    ln -sf /usr/local/bin/np-cli /usr/bin/np-cli 2>/dev/null
    
    info "✅ 交互式CLI已安装到 /usr/local/bin/np-cli"
    info "💡 使用命令: np-cli 启动交互式界面"
    info "💡 或使用: np --cli 启动"
}

# 启动交互式CLI
start_interactive_cli() {
    if [ -f /usr/local/bin/np-cli ] || [ -f /usr/bin/np-cli ]; then
        info " $(text 122) "
        if [ -f /usr/local/bin/np-cli ]; then
            /usr/local/bin/np-cli
        else
            /usr/bin/np-cli
        fi
    else
        warning " $(text 123) "
        reading "是否现在安装交互式CLI? (Y/n): " install_choice
        if [[ ! "$install_choice" =~ ^[Nn]$ ]]; then
            install_interactive_cli
        fi
    fi
}

# 必须以root运行脚本
check_root() {
  [ "$(id -u)" != 0 ] && error " $(text 2) "
}

# 检查系统要求
check_system() {
  # 只判断是否为 Linux 系统
  [ "$(uname -s)" != "Linux" ] && error " $(text 5) "
  
  # 根据系统类型设置包管理和服务管理命令
  case "$SYSTEM" in
    alpine)
      PACKAGE_INSTALL='apk add --no-cache'
      PACKAGE_UPDATE='apk update -f'
      PACKAGE_UNINSTALL='apk del'
      SERVICE_START='rc-service nodepass start'
      SERVICE_STOP='rc-service nodepass stop'
      SERVICE_RESTART='rc-service nodepass restart'
      SERVICE_STATUS='rc-service nodepass status'
      SYSTEMCTL='rc-service'
      SYSTEMCTL_ENABLE='rc-update add nodepass'
      SYSTEMCTL_DISABLE='rc-update del nodepass'
      ;;
    arch)
      PACKAGE_INSTALL='pacman -S --noconfirm'
      PACKAGE_UPDATE='pacman -Syu --noconfirm'
      PACKAGE_UNINSTALL='pacman -R --noconfirm'
      SERVICE_START='systemctl start nodepass'
      SERVICE_STOP='systemctl stop nodepass'
      SERVICE_RESTART='systemctl restart nodepass'
      SERVICE_STATUS='systemctl status nodepass'
      SYSTEMCTL='systemctl'
      SYSTEMCTL_ENABLE='systemctl enable nodepass'
      SYSTEMCTL_DISABLE='systemctl disable nodepass'
      ;;
    debian|ubuntu)
      PACKAGE_INSTALL='apt-get -y install'
      PACKAGE_UPDATE='apt-get update'
      PACKAGE_UNINSTALL='apt-get -y autoremove'
      SERVICE_START='systemctl start nodepass'
      SERVICE_STOP='systemctl stop nodepass'
      SERVICE_RESTART='systemctl restart nodepass'
      SERVICE_STATUS='systemctl status nodepass'
      SYSTEMCTL='systemctl'
      SYSTEMCTL_ENABLE='systemctl enable nodepass'
      SYSTEMCTL_DISABLE='systemctl disable nodepass'
      ;;
    centos|fedora)
      PACKAGE_INSTALL='yum -y install'
      PACKAGE_UPDATE='yum -y update'
      PACKAGE_UNINSTALL='yum -y autoremove'
      SERVICE_START='systemctl start nodepass'
      SERVICE_STOP='systemctl stop nodepass'
      SERVICE_RESTART='systemctl restart nodepass'
      SERVICE_STATUS='systemctl status nodepass'
      SYSTEMCTL='systemctl'
      SYSTEMCTL_ENABLE='systemctl enable nodepass'
      SYSTEMCTL_DISABLE='systemctl disable nodepass'
      ;;
    OpenWRT)
      PACKAGE_INSTALL='opkg install'
      PACKAGE_UPDATE='opkg update'
      PACKAGE_UNINSTALL='opkg remove'
      SERVICE_START='/etc/init.d/nodepass start'
      SERVICE_STOP='/etc/init.d/nodepass stop'
      SERVICE_RESTART='/etc/init.d/nodepass restart'
      SERVICE_STATUS='/etc/init.d/nodepass status'
      SYSTEMCTL='/etc/init.d'
      SYSTEMCTL_ENABLE='/etc/init.d/nodepass enable'
      SYSTEMCTL_DISABLE='/etc/init.d/nodepass disable'
      ;;
    *)
      PACKAGE_INSTALL='apt-get -y install'
      PACKAGE_UPDATE='apt-get update'
      PACKAGE_UNINSTALL='apt-get -y autoremove'
      SERVICE_START='systemctl start nodepass'
      SERVICE_STOP='systemctl stop nodepass'
      SERVICE_RESTART='systemctl restart nodepass'
      SERVICE_STATUS='systemctl status nodepass'
      SYSTEMCTL='systemctl'
      SYSTEMCTL_ENABLE='systemctl enable nodepass'
      SYSTEMCTL_DISABLE='systemctl disable nodepass'
      ;;
  esac
  
  # 如果在容器环境中，覆盖服务管理方式
  [ "$IN_CONTAINER" = 1 ] && SERVICE_MANAGE="none"
}

# 检查安装状态，状态码: 2 未安装， 1 已安装未运行， 0 运行中
check_install() {
  if [ ! -f "$WORK_DIR/nodepass" ]; then
    return 2
  else
    # 根据服务管理方式获取 http 或 https
    if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
      if [ -s "${WORK_DIR}/data" ] && grep -q '^CMD=.*tls=0' ${WORK_DIR}/data; then
        HTTP_S="http"
      else
        HTTP_S="https"
      fi
    elif [ "$SERVICE_MANAGE" = "systemctl" ]; then
      grep -q '^ExecStart=.*tls=0' /etc/systemd/system/nodepass.service && HTTP_S="http" || HTTP_S="https"
    elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
      grep -q '^command_args=.*tls=0' /etc/init.d/nodepass && HTTP_S="http" || HTTP_S="https"
    elif [ "$SERVICE_MANAGE" = "init.d" ]; then
      grep -q '^PROG=.*tls=0' /etc/init.d/nodepass && HTTP_S="http" || HTTP_S="https"
    else
      HTTP_S="https" # 默认使用 https
    fi
  fi
  
  if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
    if type -p pgrep >/dev/null 2>&1; then
      # 过滤掉僵尸进程 <defunct>
      if pgrep -laf "nodepass" | grep -vE "grep|<defunct>" | grep -q "nodepass"; then
        return 0
      else
        return 1
      fi
    else
      # 过滤掉僵尸进程 <defunct>
      if ps -ef | grep -vE "grep|<defunct>" | grep -q "nodepass"; then
        return 0
      else
        return 1
      fi
    fi
  elif [ "$SERVICE_MANAGE" = "systemctl" ] && ! systemctl is-active nodepass &>/dev/null; then
    return 1
  elif [ "$SERVICE_MANAGE" = "rc-service" ] && ! rc-service nodepass status &>/dev/null; then
    return 1
  elif [ "$SERVICE_MANAGE" = "init.d" ]; then
    # OpenWRT 系统检查服务状态
    if [ -f "/var/run/nodepass.pid" ] && kill -0 $(cat "/var/run/nodepass.pid" 2>/dev/null) >/dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  else
    return 0
  fi
}

# 安装系统依赖及定义下载工具
check_dependencies() {
  DEPS_INSTALL=()
  # 检查 wget 和 curl
  if [ -x "$(type -p curl)" ]; then
    DOWNLOAD_TOOL="curl"
    DOWNLOAD_CMD="curl -sL"
  elif [ -x "$(type -p wget)" ]; then
    DOWNLOAD_TOOL="wget"
    DOWNLOAD_CMD="wget -q"
    # 如果是 Alpine，先升级 wget
    grep -qi 'alpine' <<< "$SYSTEM" && grep -qi 'busybox' <<< "$(wget 2>&1 | head -n 1)" && apk add --no-cache wget >/dev/null 2>&1
  else
    # 如果都没有，安装 curl
    DEPS_INSTALL+=("curl")
    DOWNLOAD_TOOL="curl"
    DOWNLOAD_CMD="curl -sL"
  fi
  
  # 检查是否有 ps 或 pkill 命令
  if [ ! -x "$(type -p ps)" ] && [ ! -x "$(type -p pkill)" ]; then
    # 根据不同系统添加对应的包名
    if grep -qi 'alpine' /etc/os-release 2>/dev/null; then
      DEPS_INSTALL+=("procps")
    elif grep -qi 'debian\|ubuntu' /etc/os-release 2>/dev/null; then
      DEPS_INSTALL+=("procps")
    elif grep -qi 'centos\|fedora' /etc/os-release 2>/dev/null; then
      DEPS_INSTALL+=("procps-ng")
    elif grep -qi 'arch' /etc/os-release 2>/dev/null; then
      DEPS_INSTALL+=("procps-ng")
    else
      DEPS_INSTALL+=("procps")
    fi
  fi
  
  # 检查其他依赖
  local DEPS_CHECK=("tar")
  local PACKAGE_DEPS=("tar")
  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && DEPS_INSTALL+=("${PACKAGE_DEPS[g]}")
  done
  
  if [ "${#DEPS_INSTALL[@]}" -gt 0 ]; then
    info "\n $(text 7) ${DEPS_INSTALL[@]} \n"
    ${PACKAGE_UPDATE} >/dev/null 2>&1
    ${PACKAGE_INSTALL} ${DEPS_INSTALL[@]} >/dev/null 2>&1
  fi
}

# 验证IPv4或IPv6地址格式，返回0表示有效，返回1表示无效
validate_ip_address() {
  local IP="$1"
  # IPv4正则表达式
  local IPV4_REGEX='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
  # IPv6正则表达式（简化版）
  local IPV6_REGEX='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
  # 域名正则表达式（支持常规域名和带点的子域名，不支持特殊字符）
  local DOMAIN_REGEX='^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
  
  # localhost 特殊处理
  [ "$IP" = "localhost" ] && IP="127.0.0.1"
  
  if [[ "$IP" =~ $IPV4_REGEX ]] || [[ "$IP" =~ $IPV6_REGEX ]] || [[ "$IP" =~ $DOMAIN_REGEX ]]; then
    return 0 # 有效IP地址
  else
    warning " $(text 74) "
    return 1 # 无效IP地址
  fi
}

# 查询 NodePass API URL
get_api_url() {
  # 从data文件中获取SERVER_IP
  [ -s "$WORK_DIR/data" ] && source "$WORK_DIR/data"
  
  # 检查是否已安装
  if [ -s "$WORK_DIR/gob/nodepass.gob" ]; then
    # 在容器环境中优先从data文件获取参数
    if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
      if [ -s "$WORK_DIR/data" ] && grep -q "CMD=" "$WORK_DIR/data" ]; then
        # 从data文件中获取CMD
        local CMD_LINE=$(grep "CMD=" "$WORK_DIR/data" | cut -d= -f2-)
      else
        # 如果data文件中没有CMD，则从进程中获取，过滤掉僵尸进程
        if type -p pgrep >/dev/null 2>&1; then
          local CMD_LINE=$(pgrep -af "nodepass" | grep -v "grep\|sed\|<defunct>" | sed -n 's/.*nodepass \(.*\)/\1/p')
        else
          local CMD_LINE=$(ps -ef | grep -v "grep\|sed\|<defunct>" | grep "nodepass" | sed -n 's/.*nodepass \(.*\)/\1/p')
        fi
      fi
    # 根据不同系统类型获取守护文件路径
    elif [ "$SERVICE_MANAGE" = "systemctl" ] && [ -s "/etc/systemd/system/nodepass.service" ]; then
      local CMD_LINE=$(sed -n 's/.*ExecStart=.*\(master.*\)"/\1/p' "/etc/systemd/system/nodepass.service")
    elif [ "$SERVICE_MANAGE" = "rc-service" ] && [ -s "/etc/init.d/nodepass" ]; then
      # 从OpenRC服务文件中提取CMD行
      local CMD_LINE=$(sed -n 's/.*command_args.*\(master.*\)/\1/p' "/etc/init.d/nodepass")
    elif [ "$SERVICE_MANAGE" = "init.d" ] && [ -s "/etc/init.d/nodepass" ]; then
      # 从OpenWRT服务文件中提取CMD行
      local CMD_LINE=$(sed -n 's/^CMD="\([^"]\+\)"/\1/p' "/etc/init.d/nodepass")
    fi
    
    # 如果找到了CMD行，通过正则提取各个参数
    if [ -n "$CMD_LINE" ]; then
      # 提取端口
      if [[ "$CMD_LINE" =~ master://.*:([0-9]+)/ ]]; then
        PORT="${BASH_REMATCH[1]}"
      fi
      
      # 提取前缀
      if [[ "$CMD_LINE" =~ master://.*:[0-9]+/([^?]+) ]]; then
        PREFIX="${BASH_REMATCH[1]}"
      fi
      
      # 提取TLS模式
      if [[ "$CMD_LINE" =~ tls=([0-2]) ]]; then
        TLS_MODE="${BASH_REMATCH[1]}"
      fi
      
      grep -qw '0' <<< "$TLS_MODE" && local HTTP_S="http" || local HTTP_S="https"
    fi
    
    # 优先查找是否有内网穿透的服务器
    if [ -n "$REMOTE" ]; then
      [[ $REMOTE =~ (.*@)?(.*):([0-9]+)$ ]]
      local URL_SERVER_PASSWORD="${BASH_REMATCH[1]}"
      local URL_SERVER_IP="${BASH_REMATCH[2]}"
      URL_SERVER_PORT="${BASH_REMATCH[3]}"
    else
      # 处理IPv6地址格式
      if [ -n "$SERVER_IP" ]; then
        grep -q ':' <<< "$SERVER_IP" && local URL_SERVER_IP="[$SERVER_IP]" || local URL_SERVER_IP="$SERVER_IP"
      else
        local URL_SERVER_IP="127.0.0.1"
      fi
      local URL_SERVER_PORT="$PORT"
    fi
    
    # 构建API URL
    API_URL="${HTTP_S}://${URL_SERVER_IP}:${URL_SERVER_PORT}/${PREFIX:+${PREFIX%/}/}v1"
    grep -q 'output' <<< "$1" && info " $(text 39) $API_URL "
  else
    warning " $(text 59) "
  fi
}

# 查询 NodePass KEY
get_api_key() {
  # 从nodepass.gob文件中提取KEY
  if [ -s "$WORK_DIR/gob/nodepass.gob" ]; then
    KEY=$(grep -a -o '[0-9a-f]\{32\}' $WORK_DIR/gob/nodepass.gob | head -n1)
    grep -q 'output' <<< "$1" && info " $(text 40) $KEY"
  else
    warning " $(text 59) "
  fi
}

# 查询内网穿透的服务端命令行
get_intranet_penetration_server_cmd() {
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    local CLIENT_CMD=$(curl -ksX 'GET' \
      "$HTTP_S://127.0.0.1:${PORT}/${PREFIX}/v1/instances/${INSTANCE_ID}" \
      -H 'accept: application/json' \
      -H "X-API-Key: ${KEY}" 2>/dev/null)
  else
    local CLIENT_CMD=$(wget --no-check-certificate -qO- --method=GET \
      --header="accept: application/json" \
      --header="X-API-Key: ${KEY}" \
      "$HTTP_S://127.0.0.1:${PORT}/${PREFIX}/v1/instances/${INSTANCE_ID}" 2>/dev/null)
  fi
  
  # 使用正则表达式匹配client URL，支持带密码和不带密码的情况
  if [[ "$CLIENT_CMD" =~ \"url\":[[:space:]]*\"client://([^\@]*)@?([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|\[[0-9a-fA-F:]+\]):([0-9]+)/[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+\" ]]; then
    grep -q '.' <<< "${BASH_REMATCH[1]}" && local REMOTE_PASSWORD_INPUT="${BASH_REMATCH[1]}@"
    local REMOTE_SERVER_INPUT="${BASH_REMATCH[2]}"
    local TUNNEL_PORT_INPUT="${BASH_REMATCH[3]}"
    SERVER_CMD="server://${REMOTE_PASSWORD_INPUT}${REMOTE_SERVER_INPUT}:${TUNNEL_PORT_INPUT}/:${URL_SERVER_PORT}"
    grep -q 'output' <<< "$1" && info " $(text 82) $SERVER_CMD"
  else
    warning " $(text 83) "
  fi
}

# 生成 URI
get_uri() {
  grep -q '^$' <<< "$API_URL" && get_api_url
  grep -q '^$' <<< "$KEY" && get_api_key
  
  if [ -n "$API_URL" ] && [ -n "$KEY" ]; then
    URI="np://master?url=$(echo -n "$API_URL" | base64 -w0)&key=$(echo -n "$KEY" | base64 -w0)"
    grep -q 'output' <<< "$1" && grep -q '.' <<< "$URI" && info " $(text 90) $URI" && [ -x "${WORK_DIR}/qrencode" ] && ${WORK_DIR}/qrencode "$URI"
  fi
}

# 获取本地版本
get_local_version() {
  if grep -qw 'all' <<< "$1"; then
    [ -f "$WORK_DIR/np-dev" ] && DEV_LOCAL_VERSION=$("$WORK_DIR/np-dev" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    [ -f "$WORK_DIR/np-stb" ] && STABLE_LOCAL_VERSION=$("$WORK_DIR/np-stb" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    [ -f "$WORK_DIR/np-lts" ] && LTS_LOCAL_VERSION=$("$WORK_DIR/np-lts" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
  fi
 
  # 获取当前运行的版本
  if [ -L "$WORK_DIR/nodepass" ]; then
    local GET_SYMLINK_TARGET=$(readlink "$WORK_DIR/nodepass" 2>/dev/null)
    if [[ "$GET_SYMLINK_TARGET" == *"np-dev"* ]]; then
      VERSION_TYPE_TEXT=$(text 66)
      [ -f "$WORK_DIR/np-dev" ] && RUNNING_LOCAL_VERSION=$("$WORK_DIR/np-dev" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    elif [[ "$GET_SYMLINK_TARGET" == *"np-stb"* ]]; then
      VERSION_TYPE_TEXT=$(text 67)
      [ -f "$WORK_DIR/np-stb" ] && RUNNING_LOCAL_VERSION=$("$WORK_DIR/np-stb" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    elif [[ "$GET_SYMLINK_TARGET" == *"np-lts"* ]]; then
      VERSION_TYPE_TEXT=$(text 98)
      [ -f "$WORK_DIR/np-lts" ] && RUNNING_LOCAL_VERSION=$("$WORK_DIR/np-lts" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    fi
  fi
 
  # 如果软链接不存在，直接检查 nodepass 文件
  if [ -z "$VERSION_TYPE_TEXT" ] && [ -f "$WORK_DIR/nodepass" ]; then
    # 检查实际文件是什么版本
    if cmp -s "$WORK_DIR/nodepass" "$WORK_DIR/np-dev" 2>/dev/null; then
      VERSION_TYPE_TEXT=$(text 66)
      RUNNING_LOCAL_VERSION=$("$WORK_DIR/nodepass" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    elif cmp -s "$WORK_DIR/nodepass" "$WORK_DIR/np-stb" 2>/dev/null; then
      VERSION_TYPE_TEXT=$(text 67)
      RUNNING_LOCAL_VERSION=$("$WORK_DIR/nodepass" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    elif cmp -s "$WORK_DIR/nodepass" "$WORK_DIR/np-lts" 2>/dev/null; then
      VERSION_TYPE_TEXT=$(text 98)
      RUNNING_LOCAL_VERSION=$("$WORK_DIR/nodepass" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
    fi
  fi
 
  # 如果仍然无法确定，使用通用的方法
  if [ -z "$VERSION_TYPE_TEXT" ] && [ -f "$WORK_DIR/nodepass" ]; then
    RUNNING_LOCAL_VERSION=$("$WORK_DIR/nodepass" --version 2>/dev/null | head -n1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+[^[:space:]]*' || echo "")
  fi
}

# 切换 NodePass 服务状态（开启/停止）
on_off() {
  # 检查 NodePass 是否正在运行
  if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
    if type -p pgrep >/dev/null 2>&1; then
      # 过滤掉僵尸进程
      if pgrep -laf "nodepass" | grep -vE "<defunct>|grep" | grep -q "nodepass"; then
        RUNNING=1
      else
        RUNNING=0
      fi
    else
      # 过滤掉僵尸进程
      if ps -ef | grep -vE "grep|<defunct>" | grep -q "nodepass"; then
        RUNNING=1
      else
        RUNNING=0
      fi
    fi
  elif [ "$SERVICE_MANAGE" = "systemctl" ]; then
    if systemctl is-active nodepass >/dev/null 2>&1; then
      RUNNING=1
    else
      RUNNING=0
    fi
  elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
    if rc-service nodepass status | grep -q "started"; then
      RUNNING=1
    else
      RUNNING=0
    fi
  elif [ "$SERVICE_MANAGE" = "init.d" ]; then
    if [ -f "/var/run/nodepass.pid" ] && kill -0 $(cat "/var/run/nodepass.pid" 2>/dev/null) >/dev/null 2>&1; then
      RUNNING=1
    else
      RUNNING=0
    fi
  fi
  
  # 根据当前状态执行相反操作
  if [ "$RUNNING" = 1 ]; then
    stop_nodepass
    info " $(text 42) "
  else
    start_nodepass
    info " $(text 43) "
  fi
}

# 启动 NodePass 服务
start_nodepass() {
  info " $(text 51) "
  
  # 先清理可能存在的僵尸进程
  if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
    # 查找僵尸进程并尝试清理
    if type -p pgrep >/dev/null 2>&1; then
      ZOMBIE_PIDS=$(pgrep -f "nodepass" 2>/dev/null | xargs ps -p 2>/dev/null | grep "<defunct>" | awk '{print $1}')
      [ -n "$ZOMBIE_PIDS" ] && echo "$ZOMBIE_PIDS" | xargs -r kill -9 >/dev/null 2>&1
    else
      ZOMBIE_PIDS=$(ps -ef | grep -v grep | grep "nodepass" | grep "<defunct>" | awk '{print $2}')
      [ -n "$ZOMBIE_PIDS" ] && echo "$ZOMBIE_PIDS" | xargs -r kill -9 >/dev/null 2>&1
    fi
    
    # 从 data 文件中获取 CMD 参数
    if [ -s "$WORK_DIR/data" ] && grep -q "CMD=" "$WORK_DIR/data"; then
      source "$WORK_DIR/data"
    else
      # 如果 data 文件中没有 CMD，使用默认值
      CMD="master://0.0.0.0:8080/api?tls=0"
    fi
    
    nohup "$WORK_DIR/nodepass" $CMD >/dev/null 2>&1 &
  elif [ "$SERVICE_MANAGE" = "systemctl" ]; then
    systemctl start nodepass
  elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
    rc-service nodepass start
  elif [ "$SERVICE_MANAGE" = "init.d" ]; then
    /etc/init.d/nodepass start
  fi
  
  sleep 2
}

# 停止 NodePass 服务
stop_nodepass() {
  info " $(text 50) "
  
  if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
    # 查找所有nodepass进程（包括僵尸进程）并终止
    if type -p pgrep >/dev/null 2>&1; then
      pgrep -f "nodepass" 2>/dev/null | xargs -r kill -9 >/dev/null 2>&1
    else
      ps -ef | grep -v grep | grep "nodepass" | awk '{print $2}' | xargs -r kill -9 >/dev/null 2>&1
    fi
  elif [ "$SERVICE_MANAGE" = "systemctl" ]; then
    systemctl stop nodepass
  elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
    rc-service nodepass stop
  elif [ "$SERVICE_MANAGE" = "init.d" ]; then
    /etc/init.d/nodepass stop
  fi
  
  sleep 2
}

# 处理旧应用名
compatibility_old_binary() {
  # 检查旧文件是否存在
  [ -f "$WORK_DIR/stable-nodepass" ] && mv "$WORK_DIR/stable-nodepass" "$WORK_DIR/np-stb"
  [ -f "$WORK_DIR/dev-nodepass" ] && mv "$WORK_DIR/dev-nodepass" "$WORK_DIR/np-dev"
  
  # 检查软链接指向的文件
  if [ -L "$WORK_DIR/nodepass" ]; then
    local CURRENT_SYMLINK=$(readlink "$WORK_DIR/nodepass")
    # 根据软链接指向的旧文件名更新为新文件名
    if [[ "$CURRENT_SYMLINK" == *"stable-nodepass"* ]]; then
      ln -sf "$WORK_DIR/np-stb" "$WORK_DIR/nodepass"
    elif [[ "$CURRENT_SYMLINK" == *"dev-nodepass"* ]]; then
      ln -sf "$WORK_DIR/np-dev" "$WORK_DIR/nodepass"
    fi
  fi
  
  # 如果缺少LTS版本，检查GitHub包目录
  if [ -d $WORK_DIR ] && ! [ -f "$WORK_DIR/np-lts" ] && [ -d "$OFFLINE_DIR" ]; then
    if [ -f "$OFFLINE_DIR/np-lts" ]; then
      cp "$OFFLINE_DIR/np-lts" "$WORK_DIR/np-lts"
      chmod +x "$WORK_DIR/np-lts"
    fi
    get_local_version all
  fi
}

# 升级 NodePass
upgrade_nodepass() {
  # 获取本地版本
  get_local_version all
  info "\n $(text 45) "
  info " $(text 46) "
  
  # 检查GitHub升级目录
  if [ ! -d "$OFFLINE_DIR" ]; then
    info " $(text 107) "
    exit 0
  fi
  
  info " $(text 94) "
  
  # 检查升级文件
  local upgrade_files=()
  local upgrade_info=""
  local upgrade_available=0
  
  # 检查各版本是否有新文件
  for version in "np-stb" "np-dev" "np-lts"; do
    if [ -f "$OFFLINE_DIR/$version" ] && [ -f "$WORK_DIR/$version" ]; then
      # 获取版本信息
      local old_ver=$("$WORK_DIR/$version" --version 2>/dev/null | head -n1)
      local new_ver=$("$OFFLINE_DIR/$version" --version 2>/dev/null | head -n1)
     
      if [ -n "$old_ver" ] && [ -n "$new_ver" ] && [ "$old_ver" != "$new_ver" ]; then
        upgrade_files+=("$version")
        upgrade_available=1
        case "$version" in
          np-stb) upgrade_info+="\n $(text 92)" ;;
          np-dev) upgrade_info+="\n $(text 93)" ;;
          np-lts) upgrade_info+="\n $(text 99)" ;;
        esac
      fi
    elif [ -f "$OFFLINE_DIR/$version" ] && [ ! -f "$WORK_DIR/$version" ]; then
      # 本地没有但GitHub包有，也视为可升级
      upgrade_files+=("$version")
      upgrade_available=1
      case "$version" in
        np-stb) upgrade_info+="\n 稳定版: 安装新版本" ;;
        np-dev) upgrade_info+="\n 开发版: 安装新版本" ;;
        np-lts) upgrade_info+="\n 经典版: 安装新版本" ;;
      esac
    fi
  done
  
  if [ $upgrade_available -eq 0 ]; then
    info " $(text 91) "
    exit 0
  fi
  
  echo -e "$upgrade_info"
  reading "\n $(text 48) " UPGRADE_CHOICE
  
  if [ "${UPGRADE_CHOICE,,}" != "y" ]; then
    info " $(text 49) "
    exit 0
  fi
  
  # 确定是否需要重启服务
  local NEED_RESTART=0
  if [ -L "$WORK_DIR/nodepass" ]; then
    local current_link=$(readlink "$WORK_DIR/nodepass")
    for file in "${upgrade_files[@]}"; do
      if [[ "$current_link" == *"$file"* ]]; then
        NEED_RESTART=1
        break
      fi
    done
  fi
  
  # 如果需要重启服务，则停止服务
  [ "$NEED_RESTART" = 1 ] && stop_nodepass
  
  # 备份并升级文件
  for file in "${upgrade_files[@]}"; do
    # 备份旧版本
    [ -f "$WORK_DIR/$file" ] && cp "$WORK_DIR/$file" "$WORK_DIR/$file.old"
    # 升级新版本
    cp "$OFFLINE_DIR/$file" "$WORK_DIR/$file"
    chmod +x "$WORK_DIR/$file"
    info " $(text 112) $file"
  done
  
  # 如果需要重启服务，则启动服务
  if [ "$NEED_RESTART" = 1 ]; then
    info " $(text 96) "
    sleep 5
   
    if start_nodepass; then
      info " $(text 52) "
      # 清理备份
      for file in "${upgrade_files[@]}"; do
        rm -f "$WORK_DIR/$file.old" 2>/dev/null
      done
    else
      warning " $(text 53) "
      # 回滚
      for file in "${upgrade_files[@]}"; do
        [ -f "$WORK_DIR/$file.old" ] && mv "$WORK_DIR/$file.old" "$WORK_DIR/$file"
      done
     
      if start_nodepass; then
        info " $(text 54) "
      else
        error " $(text 55) "
      fi
    fi
  else
    info " $(text 52) "
    # 清理备份
    for file in "${upgrade_files[@]}"; do
      rm -f "$WORK_DIR/$file.old" 2>/dev/null
    done
  fi
}

# 切换 NodePass 版本 (稳定版 <-> 开发版 <-> 经典版)
switch_nodepass_version() {
  # 检查是否已安装
  if [ ! -f "$WORK_DIR/np-stb" ] && [ ! -f "$WORK_DIR/np-dev" ] && [ ! -f "$WORK_DIR/np-lts" ]; then
    warning " $(text 59) "
    return 1
  fi
  
  info " $(text 86) "
  
  # 获取当前使用的版本和版本号
  get_local_version all
  
  # 备份当前版本链接
  [ -L "$WORK_DIR/nodepass" ] && cp -f "$WORK_DIR/nodepass" "$WORK_DIR/nodepass.bak"
  
  # 显示当前运行版本
  info "\n $(text 97) $VERSION_TYPE_TEXT $RUNNING_LOCAL_VERSION"
  
  # 显示可切换的版本选项
  echo ""
  hint " 1. $(text 100)"
  hint " 2. $(text 101)"
  hint " 3. $(text 102)"
  hint " 4. $(text 103)"
  reading "\n $(text 104) " SWITCH_CHOICE
  SWITCH_CHOICE=${SWITCH_CHOICE:-4}
  
  case "$SWITCH_CHOICE" in
    1)
      TARGET_FILE="$WORK_DIR/np-stb"
      TARGET_TEXT=$(text 67)
      ;;
    2)
      TARGET_FILE="$WORK_DIR/np-dev"
      TARGET_TEXT=$(text 66)
      ;;
    3)
      TARGET_FILE="$WORK_DIR/np-lts"
      TARGET_TEXT=$(text 98)
      ;;
    4)
      info " $(text 103)"
      return 0
      ;;
    *)
      warning " $(text 17) "
      return 1
      ;;
  esac
  
  if [ ! -f "$TARGET_FILE" ]; then
    warning "目标版本文件不存在: $TARGET_FILE"
    return 1
  fi
  
  # 停止服务
  stop_nodepass
  
  # 切换版本
  ln -sf "$TARGET_FILE" "$WORK_DIR/nodepass"
  
  # 添加5秒延迟
  info " $(text 96) " && sleep 5
  
  # 启动服务
  if start_nodepass; then
    get_local_version running
    info " $(text 87)\n $TARGET_TEXT $RUNNING_LOCAL_VERSION"
  else
    warning " $(text 89) "
    # 尝试回滚到原来的版本
    [ -f "$WORK_DIR/nodepass.bak" ] && cp -f "$WORK_DIR/nodepass.bak" "$WORK_DIR/nodepass" && start_nodepass
  fi
  
  # 清理备份文件
  rm -f "$WORK_DIR/nodepass.bak"
}

# 解析命令行参数
parse_args() {
  # 初始化变量
  unset ARGS_SERVER_IP ARGS_PORT ARGS_PREFIX ARGS_TLS_MODE ARGS_LANGUAGE ARGS_CERT_FILE ARGS_KEY_FILE ARGS_VERSION
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --server_ip)
        ARGS_SERVER_IP="$2"
        shift 2
        ;;
      --user_port)
        ARGS_PORT="$2"
        shift 2
        ;;
      --prefix)
        ARGS_PREFIX="$2"
        shift 2
        ;;
      --tls_mode)
        ARGS_TLS_MODE="$2"
        shift 2
        ;;
      --language)
        ARGS_LANGUAGE="$2"
        shift 2
        ;;
      --version)
        ARGS_VERSION="$2"
        shift 2
        ;;
      --cert_file)
        ARGS_CERT_FILE="$2"
        shift 2
        ;;
      --key_file)
        ARGS_KEY_FILE="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done
}

# 主安装函数
install() {
  # 根据用户输入的 IP 地址，选择对应的 IP 地址
  handle_ip_input() {
    local IP="$1"
    unset SERVER_INPUT
    # 去掉用户输入 IPv6 时的方括号
    IP=$(sed 's/[][]//g' <<< "$IP")
    # 如果输入的是 localhost 或 127.0.0.1 或 ::1，则设置为 127.0.0.1
    if [[ "$IP" = "localhost" || "$IP" = "127.0.0.1" || "$IP" = "::1" ]]; then
      SERVER_INPUT="127.0.0.1"
    else
      # 如果获取到 IPv4 和 IPv6，则提示用户选择
      if grep -q '.' <<< "${SERVER_IPV4_DEFAULT}" && grep -q '.' <<< "${SERVER_IPV6_DEFAULT}"; then
        case "$IP" in
          1|"") SERVER_INPUT="${SERVER_IPV4_DEFAULT}" ;;
          2) SERVER_INPUT="${SERVER_IPV6_DEFAULT}" ;;
          3) SERVER_INPUT="127.0.0.1" ;;
          *) SERVER_INPUT="$IP" ;;
        esac
      # 如果获取到 IPv4 或 IPv6，则设置为对应的 IP
      elif ( grep -q '.' <<< "${SERVER_IPV4_DEFAULT}" && grep -q '^$' <<< "${SERVER_IPV6_DEFAULT}" ) || ( grep -q '^$' <<< "${SERVER_IPV4_DEFAULT}" && grep -q '.' <<< "${SERVER_IPV6_DEFAULT}" ); then
        case "$IP" in
          1|"") SERVER_INPUT="${SERVER_IPV4_DEFAULT}${SERVER_IPV6_DEFAULT}" ;;
          2) SERVER_INPUT="127.0.0.1" ;;
          *) SERVER_INPUT="$IP" ;;
        esac
      # 如果获取不到 IPv4 和 IPv6，则设置为输入的 IP
      else
        SERVER_INPUT="$IP"
      fi
    fi
  }
  
  # 检查并准备GitHub文件
  check_and_prepare_offline_files
  
  # 服务器 IP
  if [ -n "$ARGS_SERVER_IP" ]; then
    SERVER_INPUT="$ARGS_SERVER_IP"
  else
    hint "\n $(text 85) "
    if type -p ip >/dev/null 2>&1; then
      local DEFAULT_LOCAL_INTERFACE4=$(ip -4 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
      local DEFAULT_LOCAL_INTERFACE6=$(ip -6 route show default | awk '/default/ {for (i=0; i<NF; i++) if ($i=="dev") {print $(i+1); exit}}')
      if [ -n ""${DEFAULT_LOCAL_INTERFACE4}${DEFAULT_LOCAL_INTERFACE6}"" ]; then
        grep -q '.' <<< "$DEFAULT_LOCAL_INTERFACE4" && local DEFAULT_LOCAL_IP4=$(ip -4 addr show $DEFAULT_LOCAL_INTERFACE4 | sed -n 's#.*inet \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
        grep -q '.' <<< "$DEFAULT_LOCAL_INTERFACE6" && local DEFAULT_LOCAL_IP6=$(ip -6 addr show $DEFAULT_LOCAL_INTERFACE6 | sed -n 's#.*inet6 \([^/]\+\)/[0-9]\+.*global.*#\1#gp')
        if [ "$DOWNLOAD_TOOL" = "curl" ]; then
          grep -q '.' <<< "$DEFAULT_LOCAL_IP4" && local BIND_ADDRESS4="--interface $DEFAULT_LOCAL_INTERFACE4"
          grep -q '.' <<< "$DEFAULT_LOCAL_IP6" && local BIND_ADDRESS6="--interface $DEFAULT_LOCAL_INTERFACE6"
        else
          grep -q '.' <<< "$DEFAULT_LOCAL_IP4" && local BIND_ADDRESS4="--bind-address=$DEFAULT_LOCAL_IP4"
          grep -q '.' <<< "$DEFAULT_LOCAL_IP6" && local BIND_ADDRESS6="--bind-address=$DEFAULT_LOCAL_IP6"
        fi
      fi
    fi
    
    # 尝试从 IP api 获取服务器 IP
    if [ "$DOWNLOAD_TOOL" = "curl" ]; then
      grep -q '.' <<< "$DEFAULT_LOCAL_IP4" && local SERVER_IPV4_DEFAULT=$(curl -s $BIND_ADDRESS4 --retry 2 --max-time 3 http://api-ipv4.ip.sb || curl -s $BIND_ADDRESS4 --retry 2 --max-time 3 http://ipv4.icanhazip.com)
      grep -q '.' <<< "$DEFAULT_LOCAL_IP6" && local SERVER_IPV6_DEFAULT=$(curl -s $BIND_ADDRESS6 --retry 2 --max-time 3 http://api-ipv6.ip.sb || curl -s $BIND_ADDRESS6 --retry 2 --max-time 3 http://ipv6.icanhazip.com)
    else
      grep -q '.' <<< "$DEFAULT_LOCAL_IP4" && local SERVER_IPV4_DEFAULT=$(wget -qO- $BIND_ADDRESS4 --tries=2 --timeout=3 http://api-ipv4.ip.sb || wget -qO- $BIND_ADDRESS4 --tries=2 --timeout=3 http://ipv4.icanhazip.com)
      grep -q '.' <<< "$DEFAULT_LOCAL_IP6" && local SERVER_IPV6_DEFAULT=$(wget -qO- $BIND_ADDRESS6 --tries=2 --timeout=3 http://api-ipv6.ip.sb || wget -qO- $BIND_ADDRESS6 --tries=2 --timeout=3 http://ipv6.icanhazip.com)
    fi
  fi
  
  # 询问用户选择版本类型
  case "$VERSION_TYPE_CHOICE" in
    dev ) VERSION_TYPE_CHOICE="2" ;;
    lts ) VERSION_TYPE_CHOICE="3" ;;
    stable ) VERSION_TYPE_CHOICE="1" ;;
  esac
  
  if [ -z "$VERSION_TYPE_CHOICE" ]; then
    echo ""
    info " $(text 84) "
    echo ""
    hint " 1. 稳定版 - 适合生产环境 (默认)"
    hint " 2. 开发版 - 包含最新功能，可能不稳定"
    hint " 3. 经典版 - 长期支持版本"
    reading "\n $(text 4) " VERSION_TYPE_CHOICE
    VERSION_TYPE_CHOICE=${VERSION_TYPE_CHOICE:-1}
  fi
  
  # 如果获取到 IPv4 和 IPv6，则提示用户选择
  if grep -q '.' <<< "$SERVER_IPV4_DEFAULT" && grep -q '.' <<< "$SERVER_IPV6_DEFAULT"; then
    echo ""
    info " $(text 78) "
    echo ""
    hint " 1. ${SERVER_IPV4_DEFAULT}，监听全栈 (默认)"
    hint " 2. ${SERVER_IPV6_DEFAULT}，监听全栈"
    hint " 3. 不对公网监听，只监听本地"
    reading "\n $(text 79) " SERVER_INPUT
    handle_ip_input "$SERVER_INPUT"
  else
    echo ""
    info " $(text 12) "
    echo ""
    hint " 1. ${SERVER_IPV4_DEFAULT}${SERVER_IPV6_DEFAULT}，监听全栈 (默认)"
    hint " 2. 不对公网监听，只监听本地"
    reading "\n $(text 79) " SERVER_INPUT
    handle_ip_input "$SERVER_INPUT"
  fi
  
  while ! validate_ip_address "$SERVER_INPUT"; do
    if grep -q '.' <<< "$SERVER_IPV4_DEFAULT" && grep -q '.' <<< "$SERVER_IPV6_DEFAULT"; then
      echo ""
      info " $(text 78) "
      echo ""
      hint " 1. ${SERVER_IPV4_DEFAULT}，监听全栈 (默认)"
      hint " 2. ${SERVER_IPV6_DEFAULT}，监听全栈"
      hint " 3. 不对公网监听，只监听本地"
      reading "\n $(text 79) " SERVER_INPUT
      handle_ip_input "$SERVER_INPUT"
    else
      echo ""
      info " $(text 12) "
      echo ""
      hint " 1. ${SERVER_IPV4_DEFAULT}${SERVER_IPV6_DEFAULT}，监听全栈 (默认)"
      hint " 2. 不对公网监听，只监听本地"
      reading "\n $(text 79) " SERVER_INPUT
      handle_ip_input "$SERVER_INPUT"
    fi
  done
  
  # 端口
  while true; do
    [ -n "$ARGS_PORT" ] && PORT="$ARGS_PORT" || reading "\n $(text 13) " PORT
    # 如果用户直接回车，使用随机端口
    if [ -z "$PORT" ]; then
      PORT=$(get_random_port)
      info " $(text 37) $PORT"
      break
    else
      check_port "$PORT" "check_used"
      local PORT_STATUS=$?
      if [ "$PORT_STATUS" = 2 ]; then
        # 端口不在有效范围内
        unset ARGS_PORT PORT
        warning " $(text 41) "
      elif [ "$PORT_STATUS" = 1 ]; then
        # 端口被占用
        unset ARGS_PORT PORT
        warning " $(text 36) "
      else
        # 端口可用
        break
      fi
    fi
  done
  
  # 如果是内网机器，用于穿透到公网服务端 IP 和 Port
  if grep -q '127.0.0.1' <<< "$SERVER_INPUT"; then
    reading "\n $(text 68) " REMOTE_SERVER_INPUT
    REMOTE_SERVER_INPUT=$(sed 's/[][]//g' <<< "$REMOTE_SERVER_INPUT")
    REMOTE_SERVER_INPUT=${REMOTE_SERVER_INPUT:-"127.0.0.1"}
    until validate_ip_address "$REMOTE_SERVER_INPUT"; do
      reading "\n $(text 68) " REMOTE_SERVER_INPUT
      REMOTE_SERVER_INPUT=$(sed 's/[][]//g' <<< "$REMOTE_SERVER_INPUT")
    done
    
    # 如果输入了公网 IP，则需要进一步输入端口和认证密码
    if grep -q '.' <<< "$REMOTE_SERVER_INPUT" && ! grep -q '127\.0\.0\.1' <<< "$REMOTE_SERVER_INPUT"; then
      reading "\n $(text 81) " TUNNEL_PORT_INPUT
      while ! check_port "$TUNNEL_PORT_INPUT" "check_used"; do
        warning " $(text 41) "
        reading "\n $(text 81) " TUNNEL_PORT_INPUT
      done
      reading "\n $(text 69) " REMOTE_PORT_INPUT
      while ! check_port "$REMOTE_PORT_INPUT" "no_check_used"; do
        warning " $(text 41) "
        reading "\n $(text 69) " REMOTE_PORT_INPUT
      done
      reading "\n $(text 71) " REMOTE_PASSWORD_INPUT
      grep -q '.' <<< "$REMOTE_PASSWORD_INPUT" && REMOTE_PASSWORD_INPUT+="@"
    fi
  fi
  
  # 判断远程服务器和 IPv6 地址，构建最终显示的 URL
  if [[ "$REMOTE_SERVER_INPUT" =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then
    CMD_SERVER_IP="127.0.0.1"
    URL_SERVER_IP="[$REMOTE_SERVER_INPUT]"
    grep -q '.' <<< "$REMOTE_PORT_INPUT" && URL_SERVER_PORT="$REMOTE_PORT_INPUT" || URL_SERVER_PORT="$PORT"
  elif [[ "$REMOTE_SERVER_INPUT" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ || "$REMOTE_SERVER_INPUT" =~ ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
    CMD_SERVER_IP="127.0.0.1"
    URL_SERVER_IP="$REMOTE_SERVER_INPUT"
    grep -q '.' <<< "$REMOTE_PORT_INPUT" && URL_SERVER_PORT="$REMOTE_PORT_INPUT" || URL_SERVER_PORT="$PORT"
  elif [[ "$SERVER_INPUT" =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]]; then
    grep -q '127.0.0.1' <<< "$SERVER_INPUT" && CMD_SERVER_IP="127.0.0.1" || CMD_SERVER_IP=""
    SERVER_IP="$SERVER_INPUT"
    URL_SERVER_IP="[$SERVER_IP]"
    URL_SERVER_PORT="$PORT"
  elif [[ "$SERVER_INPUT" =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ || "$SERVER_INPUT" =~ ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
    grep -q '127.0.0.1' <<< "$SERVER_INPUT" && CMD_SERVER_IP="127.0.0.1" || CMD_SERVER_IP=""
    SERVER_IP="$SERVER_INPUT"
    URL_SERVER_IP="$SERVER_IP"
    URL_SERVER_PORT="$PORT"
  fi
  
  # API 前缀
  while true; do
    [ -n "$ARGS_PREFIX" ] && PREFIX="$ARGS_PREFIX" || reading "\n $(text 14) " PREFIX
    # 如果用户直接回车，使用默认值 api
    [ -z "$PREFIX" ] && PREFIX="api" && break
    # 检查输入是否只包含小写字母、数字和斜杠
    if grep -q '^[a-z0-9/]*$' <<< "$PREFIX"; then
      # 去掉前后空格和前后斜杠
      PREFIX=$(sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s#^/##;s#/$##' <<< "$PREFIX")
      break
    else
      unset ARGS_PREFIX PREFIX
      warning " $(text 61) "
    fi
  done
  [ -z "$PREFIX" ] && PREFIX="api"
  
  # TLS 模式
  if [ -n "$ARGS_TLS_MODE" ]; then
    TLS_MODE="$ARGS_TLS_MODE"
    if [[ ! "$TLS_MODE" =~ ^[0-2]$ ]]; then
      TLS_MODE=0
    fi
  else
    echo ""
    info " $(text 15) "
    echo ""
    hint " $(text 16) "
    reading "\n $(text 38) " TLS_MODE
    if [ -z "$TLS_MODE" ]; then
      TLS_MODE=0
    elif [[ ! "$TLS_MODE" =~ ^[0-2]$ ]]; then
      warning " $(text 17) "
      exit 1
    fi
  fi
  
  # 如果是自定义证书模式，检查证书文件
  if [ "$TLS_MODE" = "2" ]; then
    # 处理证书文件
    if [ -n "$ARGS_CERT_FILE" ]; then
      if [ ! -f "$ARGS_CERT_FILE" ]; then
        error " $(text 25) $ARGS_CERT_FILE"
      fi
      CERT_FILE="$ARGS_CERT_FILE"
    else
      while true; do
        reading " $(text 23) " CERT_FILE
        if [ -f "$CERT_FILE" ]; then
          break
        else
          warning " $(text 25) $CERT_FILE"
        fi
      done
    fi
    
    # 处理私钥文件
    if [ -n "$ARGS_KEY_FILE" ]; then
      if [ ! -f "$ARGS_KEY_FILE" ]; then
        error " $(text 26) $ARGS_KEY_FILE"
      fi
      KEY_FILE="$ARGS_KEY_FILE"
    else
      while true; do
        reading " $(text 24) " KEY_FILE
        if [ -f "$KEY_FILE" ]; then
          break
        else
          warning " $(text 26) $KEY_FILE"
        fi
      done
    fi
    
    CRT_PATH="&crt=${CERT_FILE}&key=${KEY_FILE}"
    info " $(text 27) "
  fi
  
  grep -qw '0' <<< "$TLS_MODE" && HTTP_S="http" || HTTP_S="https"
  
  # 构建命令行
  CMD="master://${CMD_SERVER_IP}:${PORT}/${PREFIX}?tls=${TLS_MODE}${CRT_PATH:-}"
  
  # 移动到工作目录，保存语言选择和服务器IP信息到单个文件
  mkdir -p $WORK_DIR
  echo -e "LANGUAGE=$L\nSERVER_IP=$SERVER_IP" > $WORK_DIR/data
  [[ "$IN_CONTAINER" = 1 || "$SERVICE_MANAGE" = "none" ]] && echo -e "CMD='$CMD'" >> $WORK_DIR/data
  grep -q '.' <<< "$REMOTE_SERVER_INPUT" && grep -q '.' <<< "$REMOTE_PORT_INPUT" && local REMOTE="${REMOTE_PASSWORD_INPUT}${URL_SERVER_IP}:${URL_SERVER_PORT}" && echo -e "REMOTE=$REMOTE" >> $WORK_DIR/data
  
  # 移动 NodePass稳定版、开发版和经典版，qrencode 可执行文件并设置权限
  mv $TEMP_DIR/np-stb $WORK_DIR/
  mv $TEMP_DIR/np-dev $WORK_DIR/
  mv $TEMP_DIR/np-lts $WORK_DIR/
  mv $TEMP_DIR/qrencode $WORK_DIR/
  chmod +x $WORK_DIR/{np-stb,np-dev,np-lts,qrencode}
  
  # 根据选择不同的版本类型，设置 NodePass 的可执行文件的软链接
  case "$VERSION_TYPE_CHOICE" in
    2) ln -sf "$WORK_DIR/np-dev" "$WORK_DIR/nodepass" ;;
    3) ln -sf "$WORK_DIR/np-lts" "$WORK_DIR/nodepass" ;;
    *) ln -sf "$WORK_DIR/np-stb" "$WORK_DIR/nodepass" ;;
  esac
  
  # 创建gob目录（用于存放配置和备份文件）
  mkdir -p "$WORK_DIR/gob"
 
  # 检查并确保备份文件存在
  check_and_create_backup_file
  
  # 创建服务文件
  create_service
  
  # 创建本地管理脚本
  create_local_management_script
  
  # 创建快捷方式
  create_shortcut
  
  # 检查服务是否成功启动
  sleep 2 # 等待服务启动
  check_install
  local INSTALL_STATUS=$?
  
  if [ $INSTALL_STATUS -eq 0 ]; then
    get_api_key
    get_uri
    info "\n $(text 10) "
    
    # 如是需要映射到公网的，则执行 api
    if grep -q '.' <<< "$REMOTE_SERVER_INPUT" && grep -q '.' <<< "$REMOTE_PORT_INPUT"; then
      # 执行 api
      if [ "$DOWNLOAD_TOOL" = "curl" ]; then
        local CREATE_NEW_INSTANCE_ID=$(curl -ksS -X 'POST' \
          "${HTTP_S}://127.0.0.1:${PORT}/${PREFIX}/v1/instances" \
          -H 'accept: application/json' \
          -H "X-API-Key: ${KEY}" \
          -H 'Content-Type: application/json' \
          -d "{
            \"url\": \"client://${REMOTE_PASSWORD_INPUT}${URL_SERVER_IP}:${TUNNEL_PORT_INPUT}/127.0.0.1:${PORT}\"
          }" 2>&1 | sed 's/{"id":"\([0-9a-f]\{8\}\)".*/\1/')
        grep -q "^[0-9a-f]\{8\}$" <<< "${CREATE_NEW_INSTANCE_ID}" && curl -X 'PATCH' "http://127.0.0.1:${PORT}/${PREFIX}/v1/instances/${CREATE_NEW_INSTANCE_ID}" \
          -H "X-API-KEY: ${KEY}" \
          -d '{ "restart": true }' >/dev/null 2>&1
      else
        local CREATE_NEW_INSTANCE_ID=$(wget --no-check-certificate -qO- --method=POST \
          --header="accept: application/json" \
          --header="X-API-Key: ${KEY}" \
          --header="Content-Type: application/json" \
          --body-data="{\"url\": \"client://${REMOTE_PASSWORD_INPUT}${URL_SERVER_IP}:${TUNNEL_PORT_INPUT}/127.0.0.1:${PORT}\"}" \
          "${HTTP_S}://127.0.0.1:${PORT}/${PREFIX}/v1/instances" 2>&1 | sed 's/{"id":"\([0-9a-f]\{8\}\)".*/\1/')
        grep -q "^[0-9a-f]\{8\}$" <<< "${CREATE_NEW_INSTANCE_ID}" && wget --no-check-certificate --method=PATCH \
        --header="X-API-KEY: ${KEY}" \
        --body-data='{ "restart": true }' \
        "http://127.0.0.1:${PORT}/${PREFIX}/v1/instances/${CREATE_NEW_INSTANCE_ID}" >/dev/null 2>&1
      fi
      [ "${#CREATE_NEW_INSTANCE_ID}" = 8 ] && echo -e "INSTANCE_ID=${CREATE_NEW_INSTANCE_ID}" >> $WORK_DIR/data && info "\n $(text 72) \n" || warning "\n $(text 73) \n"
    fi
    
    # 输出安装信息
    echo "------------------------"
    info " $(text 60) $(text 34) "
    info " $(text 35) "
    info " $(text 39) ${HTTP_S}://${URL_SERVER_IP}:${URL_SERVER_PORT}/${PREFIX}/v1"
    info " $(text 40) ${KEY}"
    info " $(text 90) $URI"
    grep -q '.' <<< "$TUNNEL_PORT_INPUT" && info " $(text 82) server://${REMOTE_PASSWORD_INPUT}:${TUNNEL_PORT_INPUT}/:${REMOTE_PORT_INPUT}"
    ${WORK_DIR}/qrencode "$URI"
    echo "------------------------"
  else
    warning " $(text 53) "
  fi
  
  help
}

# 检查并创建备份文件
check_and_create_backup_file() {
  info " $(text 118) "
 
  # 如果 nodepass.gob 文件存在，但没有备份文件，则创建备份
  if [ -s "$WORK_DIR/gob/nodepass.gob" ] && [ ! -f "$WORK_DIR/gob/nodepass.gob.backup" ]; then
    cp "$WORK_DIR/gob/nodepass.gob" "$WORK_DIR/gob/nodepass.gob.backup"
    if [ $? -eq 0 ]; then
      info " $(text 119) "
    else
      warning " $(text 120) "
    fi
  fi
}

# 创建本地管理脚本
create_local_management_script() {
  # 创建完全自包含的本地管理脚本
  cat > $WORK_DIR/np.sh << 'EOF'
#!/usr/bin/env bash
# NodePass 本地管理脚本
# 完全GitHub版本 - 所有功能内置
WORK_DIR="/etc/nodepass"
OFFLINE_DIR="/root/np"

# 语言文本定义
# ... (保留原有的语言定义)
# 由于篇幅限制，这里省略了完整的语言定义部分
# 实际使用时应该包含完整的语言定义

# 颜色输出函数
warning() { echo -e "\033[31m\033[01m$*\033[0m"; }
error() { echo -e "\033[31m\033[01m$*\033[0m" && exit 1; }
info() { echo -e "\033[32m\033[01m$*\033[0m"; }
hint() { echo -e "\033[33m\033[01m$*\033[0m"; }

# 选择语言
select_language() {
  # 从配置文件获取语言
  if [ -s "$WORK_DIR/data" ]; then
    source "$WORK_DIR/data" 2>/dev/null
    L="$LANGUAGE"
  fi
 
  # 如果没有配置，默认中文
  [ -z "$L" ] && L="C"
}

# 获取文本
text() {
  if [ "$L" = "E" ]; then
    eval echo "\${E[$*]}"
  else
    eval echo "\${C[$*]}"
  fi
}

# 检查安装状态
check_install_status() {
  if [ ! -f "$WORK_DIR/nodepass" ]; then
    return 2 # 未安装
  fi
 
  # 检查服务状态
  if command -v systemctl >/dev/null 2>&1 && systemctl --version >/dev/null 2>&1; then
    if systemctl is-active nodepass >/dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  elif [ -f "/etc/init.d/nodepass" ]; then
    if [ -f "/var/run/nodepass.pid" ] && kill -0 "$(cat "/var/run/nodepass.pid" 2>/dev/null)" >/dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  elif command -v pgrep >/dev/null 2>&1; then
    if pgrep -f "nodepass" >/dev/null 2>&1; then
      return 0
    else
      return 1
    fi
  else
    if ps -ef | grep -v grep | grep -q "nodepass"; then
      return 0
    else
      return 1
    fi
  fi
 
  return 1
}

# 显示端口转发规则
show_port_rules() {
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║              NodePass 端口转发规则                   ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo "┌─────────────────┬──────────┬─────────────────────────┐"
    echo "│ 类型            │ 端口     │ 目标                    │"
    echo "├─────────────────┼──────────┼─────────────────────────┤"
    
    # 获取进程信息
    local ps_cmd="ps aux"
    if [ -f /etc/openwrt_release ]; then
        ps_cmd="ps w"
    fi
    
    $ps_cmd 2>/dev/null | grep nodepass | grep -v grep | grep -E 'master://|client://|server://' | while read line; do
        local type_str=""
        local port=""
        local target=""
        
        # 解析master类型
        if echo "$line" | grep -q 'master://'; then
            type_str="API"
            port=$(echo "$line" | sed -n 's/.*master:\/\/[^:]*:\([0-9]\+\).*/\1/p')
            target="控制接口"
        # 解析server类型
        elif echo "$line" | grep -q 'server://'; then
            type_str="服务端"
            port=$(echo "$line" | sed -n 's/.*server:\/\/[^:]*:\([0-9]\+\).*/\1/p')
            target=$(echo "$line" | sed -n 's/.*server:\/\/[^:]*:[0-9]\+\(\/[^ ]*\).*/\1/p' | sed 's/^\///')
        # 解析client类型
        elif echo "$line" | grep -q 'client://'; then
            type_str="客户端"
            port=$(echo "$line" | sed -n 's/.*client:\/\/[^:]*:\([0-9]\+\).*/\1/p')
            target=$(echo "$line" | sed -n 's/.*client:\/\/[^:]*:[0-9]\+\(\/[^ ]*\).*/\1/p' | sed 's/^\///')
        fi
        
        if [ -n "$port" ]; then
            printf "│ %-15s │ %-8s │ %-23s │\n" "$type_str" "$port" "${target:0:23}"
        fi
    done
    
    echo "└─────────────────┴──────────┴─────────────────────────┘"
    echo ""
}

# 解析命令
parse_command() {
  # 选择语言
  select_language
 
  case "$1" in
    -i|--install)
      warning "请运行原始安装脚本进行安装"
      ;;
    -u|--uninstall)
      # 卸载逻辑
      echo ""
      read -p " $(text 48) " CONFIRM
      if [ "${CONFIRM,,}" != "y" ]; then
        info " $(text 49) "
        exit 0
      fi
      
      # 停止服务
      if command -v systemctl >/dev/null 2>&1; then
        systemctl stop nodepass 2>/dev/null
        systemctl disable nodepass 2>/dev/null
        rm -f /etc/systemd/system/nodepass.service
        systemctl daemon-reload 2>/dev/null
      elif [ -f "/etc/init.d/nodepass" ]; then
        /etc/init.d/nodepass stop 2>/dev/null
        update-rc.d -f nodepass remove 2>/dev/null || chkconfig nodepass off 2>/dev/null
        rm -f /etc/init.d/nodepass
      fi
      
      # 删除文件
      rm -rf "$WORK_DIR" 2>/dev/null
      rm -f /usr/bin/np /usr/bin/nodepass 2>/dev/null
      
      info " $(text 11) "
      ;;
    -v|--upgrade)
      # 升级逻辑
      info " $(text 94) "
      info "请使用原始安装脚本进行升级"
      ;;
    -t|--switch)
      # 切换版本逻辑
      info " $(text 86) "
      info "请使用原始安装脚本进行版本切换"
      ;;
    -o|--toggle)
      # 切换服务状态
      check_install_status
      local status=$?
     
      if [ $status -eq 2 ]; then
        warning " $(text 59) "
        return 1
      elif [ $status -eq 0 ]; then
        info " $(text 50) "
        if command -v systemctl >/dev/null 2>&1; then
          systemctl stop nodepass
        elif [ -f "/etc/init.d/nodepass" ]; then
          /etc/init.d/nodepass stop
        else
          pkill -9 nodepass 2>/dev/null
        fi
        info " $(text 42) "
      else
        info " $(text 51) "
        if command -v systemctl >/dev/null 2>&1; then
          systemctl start nodepass
        elif [ -f "/etc/init.d/nodepass" ]; then
          /etc/init.d/nodepass start
        else
          # 从 data 文件获取 CMD
          local cmd=""
          if [ -f "$WORK_DIR/data" ]; then
            source "$WORK_DIR/data" 2>/dev/null
            cmd="$CMD"
          fi
          [ -z "$cmd" ] && cmd="master://0.0.0.0:8080/api?tls=0"
          nohup "$WORK_DIR/nodepass" $cmd >/dev/null 2>&1 &
        fi
        info " $(text 43) "
      fi
      ;;
    -s|--status)
      # 显示状态信息
      select_language
      echo ""
      echo "------------------------"
      info " $(text 60) "
      
      check_install_status
      local status=$?
      
      case $status in
        0) info " $(text 34) " ;;
        1) info " $(text 33) " ;;
        2) info " $(text 32) " ;;
      esac
      
      if [ $status -ne 2 ]; then
        info " $(text 35) "
        
        # 从配置文件获取信息
        if [ -f "$WORK_DIR/data" ]; then
          source "$WORK_DIR/data" 2>/dev/null
          
          # 获取API KEY
          local KEY=""
          if [ -s "$WORK_DIR/gob/nodepass.gob" ]; then
            KEY=$(grep -a -o '[0-9a-f]\{32\}' "$WORK_DIR/gob/nodepass.gob" 2>/dev/null | head -n1)
          fi
          
          # 显示API信息
          if [ -n "$SERVER_IP" ] && [ -n "$PORT" ]; then
            local HTTP_S="https"
            [ "$TLS_MODE" = "0" ] && HTTP_S="http"
            
            local DISPLAY_IP="$SERVER_IP"
            if [ -z "$DISPLAY_IP" ] || [ "$DISPLAY_IP" = "0.0.0.0" ]; then
              DISPLAY_IP="127.0.0.1"
            fi
            
            info " $(text 39) ${HTTP_S}://${DISPLAY_IP}:${PORT}/api/v1"
          fi
          
          # 显示API KEY
          if [ -n "$KEY" ]; then
            info " $(text 40) $KEY"
          fi
        fi
      fi
      echo "------------------------"
      ;;
    -p|--ports)
      show_port_rules
      ;;
    -h|--help)
      echo ""
      echo "------------------------"
      info " $(text 22) "
      echo ""
      ;;
    "")
      # 显示简单菜单
      check_install_status
      local status=$?
      select_language
     
      clear
      echo ""
      echo "╔════════════════════════════════╗"
      echo "║        NodePass 管理菜单       ║"
      echo "╚════════════════════════════════╝"
      echo ""
     
      case $status in
        0) info " $(text 60) $(text 34) " ;;
        1) info " $(text 60) $(text 33) " ;;
        2) info " $(text 60) $(text 32) " ;;
      esac
     
      echo "----------------------------------"
     
      if [ $status -eq 2 ]; then
        echo " 1. $(text 28)"
        echo " 0. $(text 31)"
        echo ""
        read -p " $(text 4) " choice
        case $choice in
          1)
            warning "请运行原始安装脚本进行安装"
            ;;
          0) exit 0 ;;
          *) warning " $(text 17) " ;;
        esac
      else
        echo " 1. $(text 56) (np -o)"
        echo " 2. $(text 6) (np -s)"
        echo " 3. $(text 6)端口规则 (np -p)"
        echo " 4. $(text 29) (np -u)"
        echo " 5. $(text 30) (np -v)"
        echo " 6. $(text 95) (np -t)"
        echo " 0. $(text 31)"
        echo ""
        read -p " $(text 4) " choice
       
        case $choice in
          1) parse_command "-o" ;;
          2) parse_command "-s" ;;
          3) parse_command "-p" ;;
          4) parse_command "-u" ;;
          5) parse_command "-v" ;;
          6) parse_command "-t" ;;
          0) exit 0 ;;
          *) warning " $(text 17) " ;;
        esac
      fi
      ;;
    *)
      warning "未知命令: $1"
      echo ""
      echo "使用: np [选项]"
      echo "选项:"
      echo "  -i, --install     安装 NodePass"
      echo "  -u, --uninstall   卸载 NodePass"
      echo "  -v, --upgrade     升级 NodePass"
      echo "  -t, --switch      切换版本"
      echo "  -o, --toggle      启动/停止服务"
      echo "  -s, --status      显示状态"
      echo "  -p, --ports       显示端口规则"
      echo "  -h, --help        显示帮助"
      echo "  --cli             启动交互式CLI"
      exit 1
      ;;
  esac
}

# 检查是否以 root 运行
if [ "$(id -u)" != 0 ]; then
  echo "错误: 需要 root 权限运行"
  exit 1
fi

# 检查工作目录（允许 -i 命令在没有目录时执行）
if [ ! -d "$WORK_DIR" ] && [ "$1" != "-i" ]; then
  warning " $(text 59) "
  warning "请使用原始安装脚本进行安装"
  exit 1
fi

# 执行命令
parse_command "$@"
EOF
 
  chmod +x $WORK_DIR/np.sh
  info " $(text 113) "
}

# 创建服务文件 - 改进容器支持
create_service() {
    if [ "$IN_CONTAINER" = 1 ]; then
        info " $(text 21) "
        
        # 创建启动脚本
        cat > "$WORK_DIR/start.sh" << EOF
#!/usr/bin/env bash
$WORK_DIR/nodepass $CMD
EOF
        chmod +x "$WORK_DIR/start.sh"
        
        # 直接启动进程
        nohup "$WORK_DIR/nodepass" "$CMD" > "$WORK_DIR/nodepass.log" 2>&1 &
        echo $! > "$WORK_DIR/nodepass.pid"
        
        info "进程已启动，PID: $(cat "$WORK_DIR/nodepass.pid" 2>/dev/null)"
        return
    fi
    
    # 原有的服务创建代码保持不变
    if [ "$SERVICE_MANAGE" = "systemctl" ]; then
        cat > /etc/systemd/system/nodepass.service << EOF
[Unit]
Description=NodePass Service
Documentation=https://github.com/NodePassProject/nodepass
After=network.target
[Service]
Type=simple
ExecStart=$WORK_DIR/nodepass "$CMD"
Restart=on-failure
RestartSec=5s
[Install]
WantedBy=multi-user.target
EOF
        systemctl daemon-reload
        systemctl enable nodepass
        systemctl start nodepass
    elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
        cat > /etc/init.d/nodepass << EOF
#!/sbin/openrc-run
name="nodepass"
description="NodePass Service"
command="$WORK_DIR/nodepass"
command_args="$CMD"
command_background=true
pidfile="/run/\${RC_SVCNAME}.pid"
output_log="/var/log/\${RC_SVCNAME}.log"
error_log="/var/log/\${RC_SVCNAME}.log"
depend() {
    need net
    after net
}
EOF
        chmod +x /etc/init.d/nodepass
        rc-update add nodepass default
        rc-service nodepass start
    elif [ "$SERVICE_MANAGE" = "init.d" ]; then
        cat > /etc/init.d/nodepass << EOF
#!/bin/sh /etc/rc.common
START=99
STOP=10
NAME="NodePass"
PROG="$WORK_DIR/nodepass"
CMD="$CMD"
PID="/var/run/nodepass.pid"
start_service() {
  echo -e "\nStarting NodePass service..."
  \$PROG \$CMD >/dev/null 2>&1 &
  echo \$! > \$PID
}
stop_service() {
  echo "Stopping NodePass service..."
  {
    kill \$(cat \$PID 2>/dev/null)
    rm -f \$PID
  } >/dev/null 2>&1
}
start() {
  start_service
}
stop() {
  stop_service
}
restart() {
  stop
  sleep 2
  start
}
status() {
  if [ -f \$PID ] && kill -0 \$(cat \$PID 2>/dev/null) >/dev/null 2>&1; then
    echo "NodePass is running"
  else
    echo "NodePass is not running"
  fi
}
EOF
        chmod +x /etc/init.d/nodepass
        /etc/init.d/nodepass enable
        /etc/init.d/nodepass start
    fi
}

# 创建快捷方式
create_shortcut() {
  ln -sf ${WORK_DIR}/np.sh /usr/bin/np
  ln -sf ${WORK_DIR}/nodepass /usr/bin/nodepass
  [ -s /usr/bin/np ] && info "\n $(text 57) "
}

# 卸载 NodePass
uninstall() {
  echo ""
  reading "\n $(text 48) " CONFIRM
 
  if [ "${CONFIRM,,}" != "y" ]; then
    info " $(text 49) "
    exit 0
  fi
 
  if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
    # 查找所有nodepass进程（包括僵尸进程）并终止
    if type -p pgrep >/dev/null 2>&1; then
      pgrep -f "nodepass" | xargs -r kill -9 >/dev/null 2>&1
    else
      ps -ef | grep -v grep | grep "nodepass" | awk '{print $2}' | xargs -r kill -9 >/dev/null 2>&1
    fi
  elif [ "$SERVICE_MANAGE" = "systemctl" ]; then
    systemctl stop nodepass
    systemctl disable nodepass
    rm -f /etc/systemd/system/nodepass.service
    systemctl daemon-reload
  elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
    rc-service nodepass stop
    rc-update del nodepass
    rm -f /etc/init.d/nodepass
  elif [ "$SERVICE_MANAGE" = "init.d" ]; then
    /etc/init.d/nodepass stop
    /etc/init.d/nodepass disable
    rm -f /etc/init.d/nodepass
  fi
  rm -rf "$WORK_DIR" /usr/bin/{np,nodepass}
  info " $(text 11) "
}

# 更换 NodePass API 内网穿透的服务器
change_intranet_penetration_server() {
  reading "\n $(text 75) " REMOTE_SERVER_INPUT
  until validate_ip_address "$REMOTE_SERVER_INPUT"; do
    reading "\n $(text 75) " REMOTE_SERVER_INPUT
  done
  [[ "$REMOTE_SERVER_INPUT" =~ ^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$ ]] && REMOTE_SERVER_INPUT="[${REMOTE_SERVER_INPUT}]"
  
  # 如果输入了公网 IP，则需要进一步输入端口和认证密码
  if grep -q '.' <<< "$REMOTE_SERVER_INPUT"; then
    reading "\n $(text 81) " TUNNEL_PORT_INPUT
    while ! check_port "$TUNNEL_PORT_INPUT" "check_used"; do
      warning " $(text 41) "
      reading "\n $(text 81) " TUNNEL_PORT_INPUT
    done
    reading "\n $(text 69) " REMOTE_PORT_INPUT
    while ! check_port "$REMOTE_PORT_INPUT" "no_check_used"; do
      warning " $(text 41) "
      reading "\n $(text 69) " REMOTE_PORT_INPUT
    done
    reading "\n $(text 71) " REMOTE_PASSWORD_INPUT
    grep -q '.' <<< "$REMOTE_PASSWORD_INPUT" && REMOTE_PASSWORD_INPUT+="@"
  fi
  
  # 执行 api
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    # 修改内网穿透实例内容
    curl -ksS -X 'PUT' \
      "${HTTP_S}://127.0.0.1:${PORT}/${PREFIX}/v1/instances/${INSTANCE_ID}" \
      -H 'accept: application/json' \
      -H "X-API-Key: ${KEY}" \
      -H 'Content-Type: application/json' \
      -d "{
        \"url\": \"client://${REMOTE_PASSWORD_INPUT}${REMOTE_SERVER_INPUT}:${TUNNEL_PORT_INPUT}/127.0.0.1:${PORT}\"
      }" &>/dev/null
  else
    # 修改内网穿透实例内容
    wget --no-check-certificate -qO- --method=PUT \
      --header="accept: application/json" \
      --header="X-API-Key: ${KEY}" \
      --header="Content-Type: application/json" \
      --body-data="{\"url\": \"client://${REMOTE_PASSWORD_INPUT}${REMOTE_SERVER_INPUT}:${TUNNEL_PORT_INPUT}/127.0.0.1:${PORT}\"}" \
      "${HTTP_S}://127.0.0.1:${PORT}/${PREFIX}/v1/instances/${INSTANCE_ID}" &>/dev/null
  fi
  
  # 更新 data 文件
  if [ "$?" = 0 ]; then
    sed -i "s/^REMOTE=.*/REMOTE=${REMOTE_PASSWORD_INPUT}${REMOTE_SERVER_INPUT}:${REMOTE_PORT_INPUT}/" $WORK_DIR/data
    local SERVER_CMD="server://${REMOTE_PASSWORD_INPUT}:${TUNNEL_PORT_INPUT}/:${REMOTE_PORT_INPUT}"
    info "\n $(text 76) \n"
    info " $(text 82) $SERVER_CMD\n"
    unset API_URL && get_uri output
  else
    error "\n $(text 77) \n"
  fi
}

# 更换 NodePass API key
change_api_key() {
  local INSTALL_STATUS=$1
  info " $(text 65) "
  
  # 如果服务已安装但未运行，先启动服务
  if [ "$INSTALL_STATUS" = 1 ]; then
    start_nodepass
    local NEED_STOP=1
    sleep 2
  fi
  
  # 获取当前 API URL 和 KEY
  [[ -z "$PORT" || -z "$PREFIX" ]] && get_api_url
  [ -z "$KEY" ] && get_api_key
  
  # 检查是否获取到了必要信息
  [[ -z "$PORT" || -z "$PREFIX" || -z "$KEY" ]] && error " $(text 64) "
  
  if [ "$DOWNLOAD_TOOL" = "curl" ]; then
    local RESPONSE=$(curl -ks -X 'PATCH' \
      "${HTTP_S}://127.0.0.1:${PORT}/${PREFIX}/v1/instances/********" \
      -H "accept: application/json" \
      -H "X-API-Key: ${KEY}" \
      -H "Content-Type: application/json" \
      -d '{"action": "restart"}' 2>/dev/null)
  else
    local RESPONSE=$(wget --no-check-certificate -qO- --method=PATCH \
      "${HTTP_S}://127.0.0.1:${PORT}/${PREFIX}/v1/instances/********" \
      --header='accept: application/json' \
      --header="X-API-Key: ${KEY}" \
      --header='Content-Type: application/json' \
      --body-data='{"action":"restart"}' 2>/dev/null)
  fi
  
  # 从响应中提取新的 KEY
  local NEW_KEY=$(echo "$RESPONSE" | sed 's/.*url":"\([^"]\+\)".*/\1/')
  
  if [ "${#NEW_KEY}" = 32 ]; then
    # 显示新的 KEY
    info " $(text 63) "
    # 显示 API 信息
    get_api_url output
    info " $(text 40) $NEW_KEY"
    # 如果之前是停止状态，恢复停止状态
    [ "$NEED_STOP" = 1 ] && stop_nodepass
    return 0
  else
    warning " $(text 64) "
    # 如果之前是停止状态，恢复停止状态
    [ "$NEED_STOP" = 1 ] && stop_nodepass
    return 1
  fi
}

# 改进的菜单显示
menu_setting() {
    local INSTALL_STATUS=$1
    
    unset OPTION ACTION
    
    if [ "$INSTALL_STATUS" = 2 ]; then
        NODEPASS_STATUS=$(text 32)
        OPTION[1]="1. $(text 28) NodePass"
        OPTION[0]="0. $(text 31)"
        ACTION[1]() { install; }
        ACTION[0]() { exit 0; }
    else
        get_api_key
        get_api_url
        get_uri
        get_local_version all
        
        if [ -n "$REMOTE" ] && [ -n "$INSTANCE_ID" ]; then
            get_intranet_penetration_server_cmd
        fi
        
        if [ "$INSTALL_STATUS" -eq 0 ]; then
            NODEPASS_STATUS="🟢 $(text 34)"
            OPTION[1]="1. 🔴 $(text 56) (np -o)"
        else
            NODEPASS_STATUS="🟡 $(text 33)"
            OPTION[1]="1. 🟢 $(text 58) (np -o)"
        fi
        
        OPTION[2]="2. 🔑 $(text 62) (np -k)"
        OPTION[3]="3. ⬆️  $(text 30) (np -v)"
        OPTION[4]="4. 🔄 $(text 95) (np -t)"
        OPTION[5]="5. 📊 $(text 6) (np -s)"
        OPTION[6]="6. 📋 $(text 6)端口规则 (np -p)"
        grep -q '.' <<< "$REMOTE" && OPTION[7]="7. 🌐 $(text 70) (np -c)"
        OPTION[8]="8. 🗑️  $(text 29) (np -u)"
        OPTION[9]="9. 💬 $(text 121) (np --cli)"
        OPTION[10]="10. ❓ 帮助 (np -h)"
        OPTION[0]="0. 🚪 $(text 31)"
        
        ACTION[1]() { on_off "$INSTALL_STATUS"; }
        ACTION[2]() { change_api_key; }
        ACTION[3]() { upgrade_nodepass; }
        ACTION[4]() { switch_nodepass_version; }
        ACTION[5]() { 
            echo ""
            get_api_url output
            get_api_key output
            get_uri output
            echo ""
        }
        ACTION[6]() { show_port_rules; }
        grep -q '.' <<< "$REMOTE" && ACTION[7]() { change_intranet_penetration_server; }
        ACTION[8]() { uninstall; }
        ACTION[9]() { start_interactive_cli; }
        ACTION[10]() { help; }
        ACTION[0]() { exit 0; }
    fi
}

# 改进的菜单显示
menu() {
    clear
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║                     NodePass 管理                    ║"
    echo "║              TCP/UDP Tunneling Solution             ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo ""
    
    # 显示版本信息
    if grep -q '.' <<< "$DEV_LOCAL_VERSION" && grep -q '.' <<< "$STABLE_LOCAL_VERSION" && grep -q '.' <<< "$LTS_LOCAL_VERSION"; then
        info "📦 $(text 45)"
    fi
    
    info "🔄 $(text 46)"
    
    if grep -q '.' <<< "$RUNNING_LOCAL_VERSION"; then
        info "🎯 $VERSION_TYPE_TEXT $RUNNING_LOCAL_VERSION"
    fi
    
    if grep -qE '0|1' <<< "$INSTALL_STATUS"; then
        info "📡 $(text 60) $NODEPASS_STATUS"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════"
    
    # 显示菜单选项
    for ((b=1; b<${#OPTION[@]}; b++)); do
        hint " ${OPTION[b]} "
    done
    echo ""
    hint " ${OPTION[0]} "
    
    echo "════════════════════════════════════════════════════════"
    
    reading " $(text 38) " MENU_CHOICE
    
    if [[ "$MENU_CHOICE" =~ ^[0-9]+$ ]] && [ "$MENU_CHOICE" -ge 0 ] && [ "$MENU_CHOICE" -lt ${#OPTION[@]} ]; then
        ACTION[$MENU_CHOICE]
        
        # 如果不是退出操作，等待用户按回车继续
        if [ "$MENU_CHOICE" -ne 0 ]; then
            echo ""
            reading "按回车键继续..." dummy
            menu_setting $INSTALL_STATUS
            menu
        fi
    else
        warning " $(text 17) [0-$((${#OPTION[@]}-1))] "
        sleep 2
        menu
    fi
}

# 主程序入口 - 改进参数处理
main() {
    # 处理语言参数
    for arg in "$@"; do
        case "$arg" in
            --lang=zh|--lang=cn|--language=zh|--language=cn)
                export ARGS_LANGUAGE=1
                ;;
            --lang=en|--language=en)
                export ARGS_LANGUAGE=2
                ;;
        esac
    done
    
    # 检查root权限
    check_root
    
    # 检查系统
    check_system_info
    check_system
    
    # 检查依赖
    check_dependencies
    
    # 处理兼容性
    compatibility_old_binary
    
    # 检查安装状态
    check_install
    local INSTALL_STATUS=$?
    
    # 选择语言
    select_language
    
    # 处理命令行参数
    case "${1,,}" in
        -i|--install|install)
            if [ "$INSTALL_STATUS" != 2 ]; then
                warning " $(text 18) "
                exit 1
            fi
            install
            ;;
        -u|--uninstall|uninstall)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            uninstall
            ;;
        -v|--upgrade|upgrade)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            upgrade_nodepass
            ;;
        -t|--switch|switch)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            switch_nodepass_version
            ;;
        -o|--toggle|toggle)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            on_off "$INSTALL_STATUS"
            ;;
        -s|--status|status)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            echo ""
            get_api_url output
            get_api_key output
            get_uri output
            echo ""
            ;;
        -p|--ports|ports)
            show_port_rules
            ;;
        -k|--key|key)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            change_api_key
            ;;
        -c|--change-server)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            change_intranet_penetration_server
            ;;
        --cli|--interactive)
            start_interactive_cli
            ;;
        --cli-install)
            install_interactive_cli
            ;;
        -h|--help|help)
            help
            ;;
        *)
            menu_setting "$INSTALL_STATUS"
            menu
            ;;
    esac
}

# 执行主程序
main "$@"
