#!/usr/bin/env bash
# 当前脚本版本号
SCRIPT_VERSION='0.0.8'

# 环境变量用于在Debian或Ubuntu操作系统中设置非交互式（noninteractive）安装模式
export DEBIAN_FRONTEND=noninteractive

# 本地GitHub包目录
OFFLINE_DIR='/root/np'
# 工作目录和临时目录
TEMP_DIR='/tmp/nodepass'
WORK_DIR='/etc/nodepass'
GOB_DIR="$WORK_DIR/gob"

# 改进的清理函数
cleanup() {
    rm -rf "$TEMP_DIR" >/dev/null 2>&1
    echo ""
    exit 0
}
trap cleanup INT QUIT TERM EXIT

mkdir -p "$TEMP_DIR" 2>/dev/null || error "无法创建临时目录"

# 颜色定义（保持原有但更一致）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

warning() { echo -e "${RED}$*${NC}"; }
error() { echo -e "${RED}$*${NC}" && exit 1; }
info() { echo -e "${GREEN}$*${NC}"; }
hint() { echo -e "${YELLOW}$*${NC}"; }
success() { echo -e "${GREEN}$*${NC}"; }
reading() { read -rp "$(info "$1")" "$2"; }

# 语言定义（保持原有）
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
E[22]="NodePass Script Usage / NodePass 脚本使用方法:\n np - Show menu / 显示菜单\n np -i - Install NodePass / 安装 NodePass\n np -u - Uninstall NodePass / 卸载 NodePass\n np -v - Upgrade NodePass / 升级 NodePass\n np -t - Switch NodePass version between stable and development / 在稳定版和开发版之间切换 NodePass\n np -o - Toggle service status (start/stop) / 切换服务状态 (开启/停止)\n np -k - Change NodePass API key / 更换 NodePass API key\n np -c - Change intranet penetration server / 更换内网穿透\n np -s - Show NodePass API info / 显示 NodePass API 信息\n np -h - Show help information / 显示帮助信息\n np -p - Show port forwarding rules / 显示端口转发规则"
C[22]="${E[22]}"
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

# 文本函数
text() { eval echo "\${${L}[$*]}"; }

# 从备用源下载GitHub包 - 改进错误处理
download_backup_offline_package() {
    info " $(text 114) "
    
    mkdir -p "$OFFLINE_DIR" || error "无法创建GitHub目录"
    
    cd /tmp || error "无法进入/tmp目录"
    
    # 尝试使用wget或curl下载
    if command -v wget >/dev/null 2>&1; then
        if wget -qO npsh.zip https://github.com/lima-droid/np/archive/refs/heads/main.zip; then
            if command -v unzip >/dev/null 2>&1; then
                unzip -j -q npsh.zip "np-main/np/*" -d "$OFFLINE_DIR"
                local status=$?
            else
                # 尝试安装unzip
                if command -v apt-get >/dev/null 2>&1; then
                    apt-get update && apt-get install -y unzip
                    unzip -j -q npsh.zip "np-main/np/*" -d "$OFFLINE_DIR"
                    local status=$?
                else
                    warning "需要unzip工具"
                    return 1
                fi
            fi
        else
            warning "下载失败"
            return 1
        fi
    elif command -v curl >/dev/null 2>&1; then
        if curl -sL -o npsh.zip https://github.com/lima-droid/np/archive/refs/heads/main.zip; then
            if command -v unzip >/dev/null 2>&1; then
                unzip -j -q npsh.zip "np-main/np/*" -d "$OFFLINE_DIR"
                local status=$?
            else
                warning "需要unzip工具"
                return 1
            fi
        else
            warning "下载失败"
            return 1
        fi
    else
        warning "需要wget或curl工具"
        return 1
    fi
    
    rm -f npsh.zip 2>/dev/null
    
    if [ "$status" -eq 0 ]; then
        info " $(text 115) "
        return 0
    else
        warning " $(text 116) "
        return 1
    fi
}

# 检查GitHub包目录 - 更健壮
check_and_prepare_offline_files() {
    info " $(text 108) "
    
    # 检查GitHub目录是否存在
    if [ ! -d "$OFFLINE_DIR" ]; then
        hint "GitHub包目录未找到，尝试从备用源下载..."
        if ! download_backup_offline_package; then
            error " $(text 107) "
        fi
    fi
    
    # 再次检查
    if [ ! -d "$OFFLINE_DIR" ]; then
        error " $(text 107) "
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
    
    # 再次检查文件
    missing_files=()
    for file in "${required_files[@]}"; do
        if [ ! -f "$OFFLINE_DIR/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -gt 0 ]; then
        for file in "${missing_files[@]}"; do
            warning " $(text 106) $file"
        done
        error " $(text 9) "
    fi
    
    # 复制文件到临时目录
    for file in "${required_files[@]}"; do
        if cp "$OFFLINE_DIR/$file" "$TEMP_DIR/"; then
            chmod +x "$TEMP_DIR/$file" 2>/dev/null
        else
            error "复制 $file 失败"
        fi
    done
    
    info " $(text 19) "
}

# 显示帮助信息
help() {
    echo ""
    echo "------------------------"
    hint " $(text 22) "
    echo ""
}

# 必须以root运行脚本
check_root() {
    [ "$(id -u)" != 0 ] && error " $(text 2) "
}

# 检查系统要求 - 更健壮
check_system() {
    # 只判断是否为 Linux 系统
    [ "$(uname -s)" != "Linux" ] && error " $(text 5) "
    
    # 检查系统信息
    check_system_info
    
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

# 检查系统信息
check_system_info() {
    # 检查架构
    case "$(uname -m)" in
        x86_64 | amd64 ) ARCH=amd64 ;;
        armv8 | arm64 | aarch64 ) ARCH=arm64 ;;
        armv7l ) ARCH=arm ;;
        s390x ) ARCH=s390x ;;
        * ) error " $(text 3) " ;;
    esac
    
    # 检查系统
    if [ -f /etc/openwrt_release ]; then
        SYSTEM="OpenWRT"
        SERVICE_MANAGE="init.d"
    elif [ -f /etc/os-release ]; then
        source /etc/os-release 2>/dev/null || error "无法读取 /etc/os-release"
        SYSTEM=$ID
        [[ $SYSTEM = "centos" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 7 ]] && SYSTEM=centos
        [[ $SYSTEM = "debian" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 10 ]] && SYSTEM=debian
        [[ $SYSTEM = "ubuntu" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 16 ]] && SYSTEM=ubuntu
        [[ $SYSTEM = "alpine" && $(expr "$VERSION_ID" : '.*\s\([0-9]\{1,\}\)\.*') -ge 3 ]] && SYSTEM=alpine
    fi
    
    # 确定服务管理方式
    if [ -z "$SERVICE_MANAGE" ]; then
        if command -v systemctl >/dev/null 2>&1 && systemctl --version >/dev/null 2>&1; then
            SERVICE_MANAGE="systemctl"
        elif command -v openrc-run >/dev/null 2>&1; then
            SERVICE_MANAGE="rc-service"
        elif command -v service >/dev/null 2>&1 && [ -d /etc/init.d ]; then
            SERVICE_MANAGE="init.d"
        else
            SERVICE_MANAGE="none"
        fi
    fi
    
    # 检查是否在容器环境中
    if [ -f /.dockerenv ] || grep -q 'docker\|lxc' /proc/1/cgroup 2>/dev/null; then
        IN_CONTAINER=1
    else
        IN_CONTAINER=0
    fi
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
            grep -q '^ExecStart=.*tls=0' /etc/systemd/system/nodepass.service 2>/dev/null && HTTP_S="http" || HTTP_S="https"
        elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
            grep -q '^command_args=.*tls=0' /etc/init.d/nodepass 2>/dev/null && HTTP_S="http" || HTTP_S="https"
        elif [ "$SERVICE_MANAGE" = "init.d" ]; then
            grep -q '^PROG=.*tls=0' /etc/init.d/nodepass 2>/dev/null && HTTP_S="http" || HTTP_S="https"
        else
            HTTP_S="https" # 默认使用 https
        fi
    fi
    
    if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
        if command -v pgrep >/dev/null 2>&1; then
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

# 安装系统依赖及定义下载工具 - 更健壮
check_dependencies() {
    DEPS_INSTALL=()
    
    # 检查 wget 和 curl
    if command -v curl >/dev/null 2>&1; then
        DOWNLOAD_TOOL="curl"
        DOWNLOAD_CMD="curl -sL"
    elif command -v wget >/dev/null 2>&1; then
        DOWNLOAD_TOOL="wget"
        DOWNLOAD_CMD="wget -q"
        # 如果是 Alpine，先升级 wget
        if grep -qi 'alpine' /etc/os-release 2>/dev/null && wget --help 2>&1 | head -n1 | grep -qi 'busybox'; then
            apk add --no-cache wget >/dev/null 2>&1
        fi
    else
        # 如果都没有，尝试安装 curl
        info "安装 curl..."
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update && apt-get install -y curl
        elif command -v yum >/dev/null 2>&1; then
            yum install -y curl
        elif command -v apk >/dev/null 2>&1; then
            apk add --no-cache curl
        else
            error " $(text 8) "
        fi
        
        if command -v curl >/dev/null 2>&1; then
            DOWNLOAD_TOOL="curl"
            DOWNLOAD_CMD="curl -sL"
        else
            error " $(text 8) "
        fi
    fi
    
    # 检查是否有 ps 命令
    if ! command -v ps >/dev/null 2>&1; then
        DEPS_INSTALL+=("procps")
    fi
    
    # 检查 tar
    if ! command -v tar >/dev/null 2>&1; then
        DEPS_INSTALL+=("tar")
    fi
    
    if [ ${#DEPS_INSTALL[@]} -gt 0 ]; then
        info "\n $(text 7) ${DEPS_INSTALL[@]} \n"
        ${PACKAGE_UPDATE} >/dev/null 2>&1
        ${PACKAGE_INSTALL} "${DEPS_INSTALL[@]}" >/dev/null 2>&1
    fi
}

# 验证IPv4或IPv6地址格式
validate_ip_address() {
    local IP="$1"
    
    # 移除可能的方括号（IPv6）
    IP=$(echo "$IP" | sed 's/[][]//g')
    
    # localhost 特殊处理
    [ "$IP" = "localhost" ] && IP="127.0.0.1"
    
    # IPv4正则表达式
    local IPV4_REGEX='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    # IPv6正则表达式（简化版）
    local IPV6_REGEX='^([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4}$'
    # 域名正则表达式
    local DOMAIN_REGEX='^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
    
    if [[ "$IP" =~ $IPV4_REGEX ]] || [[ "$IP" =~ $IPV6_REGEX ]] || [[ "$IP" =~ $DOMAIN_REGEX ]]; then
        return 0
    else
        warning " $(text 74) "
        return 1
    fi
}

# 检查端口是否可用 - 更可靠
check_port() {
    local PORT=$1
    local NO_CHECK_USED=$2
    
    # 检查端口是否为数字且在有效范围内
    if ! [[ "$PORT" =~ ^[0-9]+$ ]] || [ "$PORT" -lt 1024 ] || [ "$PORT" -gt 65535 ]; then
        return 2
    fi
    
    if ! echo "$NO_CHECK_USED" | grep -q 'no_check_used'; then
        # 使用多种方法检查端口占用
        local port_in_use=0
        
        # 方法1: 使用ss（最快）
        if command -v ss >/dev/null 2>&1; then
            if ss -tuln | grep -q ":${PORT} "; then
                port_in_use=1
            fi
        # 方法2: 使用netstat
        elif command -v netstat >/dev/null 2>&1; then
            if netstat -tuln 2>/dev/null | grep -q ":${PORT} "; then
                port_in_use=1
            fi
        # 方法3: 使用 /dev/tcp
        else
            if timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${PORT}" 2>/dev/null; then
                port_in_use=1
            fi
        fi
        
        if [ $port_in_use -eq 1 ]; then
            return 1
        fi
    fi
    
    return 0
}

# 获取随机可用端口 - 更可靠
get_random_port() {
    local RANDOM_PORT
    local attempts=0
    
    while [ $attempts -lt 10 ]; do
        RANDOM_PORT=$((RANDOM % 7168 + 1024))
        if check_port "$RANDOM_PORT" "check_used"; then
            echo "$RANDOM_PORT"
            return 0
        fi
        attempts=$((attempts + 1))
    done
    
    # 如果随机失败，尝试固定范围
    for port in {20000..20100}; do
        if check_port "$port" "check_used"; then
            echo "$port"
            return 0
        fi
    done
    
    error "无法找到可用端口"
}

# 显示端口转发规则 - 改进显示
show_port_rules() {
    echo ""
    echo "          NodePass 端口转发规则"
    echo "──────────────────────────────────────────"
    
    # 自动检测系统类型并选择合适的ps命令
    if [ -f /etc/openwrt_release ]; then
        PS_CMD="ps w"
    else
        PS_CMD="ps -axu"
    fi

    $PS_CMD 2>/dev/null | grep nodepass | grep -v grep | grep -E 'master://|client://|server://' \
    | sed -E 's/.*master:\/\/:([0-9]+).*/API \1 控制接口/;
            s/.*server:\/\/:([0-9]+)\/([^?]+).*/转发 \1 \2/;
            s/.*client:\/\/:([0-9]+)\/([^?]+).*/转发 \1 \2/;
            s/.*client:\/\/([^:]+):([0-9]+)\/([^?]+).*/转发 \2 \1→\3/' \
    | awk '{
        gsub(/[?"&].*/, "", $3)
        gsub(/[[:space:]]+$/, "", $3)
        print $1 " " $2 " " $3
    }' | awk '{
        if ($1 == "API") {
            printf " %-8s   %6s   %-26s\n", "API端口", $2, "   控制接口"
        } else if ($1 == "转发") {
            split($3, arr, "→")
            if (length(arr) == 2) {
                printf " %-8s   %6s   → %-23s\n", "转发端口", $2, arr[2]
            } else {
                printf " %-8s   %6s   → %-23s\n", "转发端口", $2, $3
            }
        }
    }'
    
    echo "──────────────────────────────────────────"
}

# 选择语言
select_language() {
    UTF8_LOCALE=$(locale -a 2>/dev/null | grep -iEm1 "UTF-8|utf8")
    [ -n "$UTF8_LOCALE" ] && export LC_ALL="$UTF8_LOCALE" LANG="$UTF8_LOCALE" LANGUAGE="$UTF8_LOCALE"
    
    # 优先使用命令行参数指定的语言
    if [ -n "$ARGS_LANGUAGE" ]; then
        case "$ARGS_LANGUAGE" in
            1|zh|CN|cn|chinese|C|c)
                L=C
                ;;
            2|en|EN|english|E|e)
                L=E
                ;;
            *)
                L=C
                ;;
        esac
    # 其次读取保存的配置信息
    elif [ -s ${WORK_DIR}/data ]; then
        source ${WORK_DIR}/data
        L=$LANGUAGE
    # 最后使用交互方式选择
    else
        L=C
        if [ -z "$NON_INTERACTIVE" ]; then
            hint " $(text 0) \n"
            reading " $(text 4) " LANGUAGE_CHOICE
            [ "$LANGUAGE_CHOICE" = 2 ] && L=E
        fi
    fi
}

# 查询 NodePass API URL - 更可靠
get_api_url() {
    # 从data文件中获取SERVER_IP
    [ -s "$WORK_DIR/data" ] && source "$WORK_DIR/data"
    
    # 检查是否已安装
    if [ ! -s "$WORK_DIR/gob/nodepass.gob" ]; then
        warning " $(text 59) "
        return
    fi
    
    # 在容器环境中优先从data文件获取参数
    if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
        if [ -s "$WORK_DIR/data" ] && grep -q "CMD=" "$WORK_DIR/data"; then
            local CMD_LINE=$(grep "CMD=" "$WORK_DIR/data" | cut -d= -f2-)
        else
            # 如果data文件中没有CMD，则从进程中获取，过滤掉僵尸进程
            if command -v pgrep >/dev/null 2>&1; then
                local CMD_LINE=$(pgrep -af "nodepass" | grep -v "grep\|sed\|<defunct>" | sed -n 's/.*nodepass \(.*\)/\1/p')
            else
                local CMD_LINE=$(ps -ef | grep -v "grep\|sed\|<defunct>" | grep "nodepass" | sed -n 's/.*nodepass \(.*\)/\1/p')
            fi
        fi
    # 根据不同系统类型获取守护文件路径
    elif [ "$SERVICE_MANAGE" = "systemctl" ] && [ -s "/etc/systemd/system/nodepass.service" ]; then
        local CMD_LINE=$(sed -n 's/.*ExecStart=.*\(master.*\)"/\1/p' "/etc/systemd/system/nodepass.service")
    elif [ "$SERVICE_MANAGE" = "rc-service" ] && [ -s "/etc/init.d/nodepass" ]; then
        local CMD_LINE=$(sed -n 's/.*command_args.*\(master.*\)/\1/p' "/etc/init.d/nodepass")
    elif [ "$SERVICE_MANAGE" = "init.d" ] && [ -s "/etc/init.d/nodepass" ]; then
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

# 生成 URI
get_uri() {
    get_api_url
    get_api_key
    
    if [ -n "$API_URL" ] && [ -n "$KEY" ]; then
        if command -v base64 >/dev/null 2>&1; then
            URI="np://master?url=$(echo -n "$API_URL" | base64 -w0 2>/dev/null || echo "$API_URL" | base64)&key=$(echo -n "$KEY" | base64 -w0 2>/dev/null || echo "$KEY" | base64)"
        else
            # 如果没有base64，使用简单编码
            URI="np://master?url=$API_URL&key=$KEY"
        fi
        
        grep -q 'output' <<< "$1" && info " $(text 90) $URI"
        if [ -x "${WORK_DIR}/qrencode" ]; then
            ${WORK_DIR}/qrencode "$URI" 2>/dev/null
        fi
    fi
}

# 获取本地版本 - 更可靠
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

# 启动 NodePass 服务 - 更可靠
start_nodepass() {
    info " $(text 51) "
    
    # 先清理可能存在的僵尸进程
    if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
        # 查找僵尸进程并尝试清理
        if command -v pgrep >/dev/null 2>&1; then
            pgrep -f "nodepass" | xargs -r kill -9 >/dev/null 2>&1
        else
            ps -ef | grep -v grep | grep "nodepass" | awk '{print $2}' | xargs -r kill -9 >/dev/null 2>&1
        fi
        
        # 从 data 文件中获取 CMD 参数
        if [ -s "$WORK_DIR/data" ] && grep -q "CMD=" "$WORK_DIR/data"; then
            source "$WORK_DIR/data"
        else
            # 如果data文件中没有CMD，使用默认值
            CMD="master://0.0.0.0:8080/api?tls=0"
        fi
        
        nohup "$WORK_DIR/nodepass" $CMD >/dev/null 2>&1 &
        local pid=$!
        
        # 等待进程启动
        sleep 2
        if kill -0 $pid 2>/dev/null; then
            return 0
        else
            return 1
        fi
    elif [ "$SERVICE_MANAGE" = "systemctl" ]; then
        if systemctl start nodepass; then
            sleep 2
            return 0
        else
            return 1
        fi
    elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
        if rc-service nodepass start; then
            sleep 2
            return 0
        else
            return 1
        fi
    elif [ "$SERVICE_MANAGE" = "init.d" ]; then
        if /etc/init.d/nodepass start; then
            sleep 2
            return 0
        else
            return 1
        fi
    fi
}

# 停止 NodePass 服务 - 更可靠
stop_nodepass() {
    info " $(text 50) "
    
    if [ "$IN_CONTAINER" = 1 ] || [ "$SERVICE_MANAGE" = "none" ]; then
        # 查找所有nodepass进程（包括僵尸进程）并终止
        if command -v pgrep >/dev/null 2>&1; then
            pgrep -f "nodepass" | xargs -r kill -9 >/dev/null 2>&1
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

# 切换 NodePass 服务状态（开启/停止）
on_off() {
    local INSTALL_STATUS=$1
    
    if [ "$INSTALL_STATUS" -eq 0 ]; then
        if stop_nodepass; then
            info " $(text 42) "
        else
            warning "停止服务失败"
        fi
    elif [ "$INSTALL_STATUS" -eq 1 ]; then
        if start_nodepass; then
            info " $(text 43) "
        else
            warning " $(text 53) "
        fi
    fi
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

# 升级 NodePass - 更可靠
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
    
    if [[ ! "$UPGRADE_CHOICE" =~ ^[Yy]$ ]] && [ -n "$UPGRADE_CHOICE" ]; then
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
    if [ "$NEED_RESTART" = 1 ]; then
        check_install
        if [ $? -eq 0 ]; then
            stop_nodepass
        fi
    fi
    
    # 备份并升级文件
    for file in "${upgrade_files[@]}"; do
        # 备份旧版本
        [ -f "$WORK_DIR/$file" ] && cp "$WORK_DIR/$file" "$WORK_DIR/$file.old"
        # 升级新版本
        if cp "$OFFLINE_DIR/$file" "$WORK_DIR/$file"; then
            chmod +x "$WORK_DIR/$file"
            info " $(text 112) $file"
        else
            warning "升级 $file 失败"
        fi
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

# 切换 NodePass 版本
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
    
    # 检查服务状态
    check_install
    local service_status=$?
    
    # 停止服务（如果正在运行）
    if [ $service_status -eq 0 ]; then
        stop_nodepass
    fi
    
    # 切换版本
    ln -sf "$TARGET_FILE" "$WORK_DIR/nodepass"
    
    # 启动服务（如果之前是运行状态）
    if [ $service_status -eq 0 ]; then
        info " $(text 96) "
        sleep 5
        
        if start_nodepass; then
            get_local_version running
            info " $(text 87)\n $TARGET_TEXT $RUNNING_LOCAL_VERSION"
        else
            warning " $(text 89) "
            # 尝试回滚
            [ -f "$WORK_DIR/nodepass.bak" ] && mv "$WORK_DIR/nodepass.bak" "$WORK_DIR/nodepass"
            start_nodepass
            return 1
        fi
    else
        info " $(text 87)"
    fi
    
    # 清理备份文件
    rm -f "$WORK_DIR/nodepass.bak" 2>/dev/null
}

# 解析命令行参数
parse_args() {
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
            --non-interactive)
                NON_INTERACTIVE=1
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# 主安装函数 - 保持原有逻辑但更健壮
install() {
    # 检查并准备GitHub文件
    check_and_prepare_offline_files
    
    # 询问用户选择版本类型
    echo ""
    info " $(text 84) "
    echo ""
    hint " 1. 稳定版 - 适合生产环境 (默认)"
    hint " 2. 开发版 - 包含最新功能，可能不稳定"
    hint " 3. 经典版 - 长期支持版本"
    reading "\n $(text 4) " VERSION_TYPE_CHOICE
    VERSION_TYPE_CHOICE=${VERSION_TYPE_CHOICE:-1}
    
    # 获取服务器 IP
    hint "\n $(text 85) "
    
    # 尝试获取公网 IP
    SERVER_IPV4_DEFAULT=""
    SERVER_IPV6_DEFAULT=""
    
    if command -v curl >/dev/null 2>&1; then
        SERVER_IPV4_DEFAULT=$(curl -s --retry 2 --max-time 3 http://api-ipv4.ip.sb 2>/dev/null || curl -s --retry 2 --max-time 3 http://ipv4.icanhazip.com 2>/dev/null || echo "")
        SERVER_IPV6_DEFAULT=$(curl -s --retry 2 --max-time 3 http://api-ipv6.ip.sb 2>/dev/null || curl -s --retry 2 --max-time 3 http://ipv6.icanhazip.com 2>/dev/null || echo "")
    elif command -v wget >/dev/null 2>&1; then
        SERVER_IPV4_DEFAULT=$(wget -qO- --tries=2 --timeout=3 http://api-ipv4.ip.sb 2>/dev/null || wget -qO- --tries=2 --timeout=3 http://ipv4.icanhazip.com 2>/dev/null || echo "")
        SERVER_IPV6_DEFAULT=$(wget -qO- --tries=2 --timeout=3 http://api-ipv6.ip.sb 2>/dev/null || wget -qO- --tries=2 --timeout=3 http://ipv6.icanhazip.com 2>/dev/null || echo "")
    fi
    
    # 如果获取到 IPv4 和 IPv6，则提示用户选择
    if [ -n "$SERVER_IPV4_DEFAULT" ] && [ -n "$SERVER_IPV6_DEFAULT" ]; then
        echo ""
        info " $(text 78) "
        echo ""
        hint " 1. ${SERVER_IPV4_DEFAULT}，监听全栈 (默认)"
        hint " 2. ${SERVER_IPV6_DEFAULT}，监听全栈"
        hint " 3. 不对公网监听，只监听本地"
        reading "\n $(text 79) " SERVER_INPUT
        SERVER_INPUT=${SERVER_INPUT:-1}
        
        case "$SERVER_INPUT" in
            1) SERVER_IP="$SERVER_IPV4_DEFAULT" ;;
            2) SERVER_IP="$SERVER_IPV6_DEFAULT" ;;
            3) SERVER_IP="127.0.0.1" ;;
            *) SERVER_IP="$SERVER_INPUT" ;;
        esac
    elif [ -n "$SERVER_IPV4_DEFAULT" ] || [ -n "$SERVER_IPV6_DEFAULT" ]; then
        echo ""
        info " $(text 12) "
        echo ""
        hint " 1. ${SERVER_IPV4_DEFAULT}${SERVER_IPV6_DEFAULT}，监听全栈 (默认)"
        hint " 2. 不对公网监听，只监听本地"
        reading "\n $(text 79) " SERVER_INPUT
        SERVER_INPUT=${SERVER_INPUT:-1}
        
        case "$SERVER_INPUT" in
            1) SERVER_IP="${SERVER_IPV4_DEFAULT}${SERVER_IPV6_DEFAULT}" ;;
            2) SERVER_IP="127.0.0.1" ;;
            *) SERVER_IP="$SERVER_INPUT" ;;
        esac
    else
        SERVER_IP="127.0.0.1"
    fi
    
    # 验证 IP 地址
    while ! validate_ip_address "$SERVER_IP"; do
        reading "\n请输入有效的 IP 地址或域名: " SERVER_IP
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
    
    # API 前缀
    while true; do
        [ -n "$ARGS_PREFIX" ] && PREFIX="$ARGS_PREFIX" || reading "\n $(text 14) " PREFIX
        
        # 如果用户直接回车，使用默认值 api
        [ -z "$PREFIX" ] && PREFIX="api" && break
        
        # 检查输入是否只包含小写字母、数字和斜杠
        if [[ "$PREFIX" =~ ^[a-z0-9/]*$ ]]; then
            # 去掉前后空格和前后斜杠
            PREFIX=$(echo "$PREFIX" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s#^/##;s#/$##')
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
    
    # 构建命令行
    CMD="master://${SERVER_IP}:${PORT}/${PREFIX}?tls=${TLS_MODE}"
    
    # 移动到工作目录，保存配置
    mkdir -p "$WORK_DIR" || error "无法创建工作目录"
    echo -e "LANGUAGE=$L\nSERVER_IP=$SERVER_IP" > "$WORK_DIR/data"
    [[ "$IN_CONTAINER" = 1 || "$SERVICE_MANAGE" = "none" ]] && echo -e "CMD='$CMD'" >> "$WORK_DIR/data"
    
    # 移动文件并设置权限
    for file in np-stb np-dev np-lts qrencode; do
        if [ -f "$TEMP_DIR/$file" ]; then
            mv "$TEMP_DIR/$file" "$WORK_DIR/"
            chmod +x "$WORK_DIR/$file" 2>/dev/null
        fi
    done
    
    # 根据选择设置软链接
    case "$VERSION_TYPE_CHOICE" in
        2) ln -sf "$WORK_DIR/np-dev" "$WORK_DIR/nodepass" ;;
        3) ln -sf "$WORK_DIR/np-lts" "$WORK_DIR/nodepass" ;;
        *) ln -sf "$WORK_DIR/np-stb" "$WORK_DIR/nodepass" ;;
    esac
    
    # 创建目录
    mkdir -p "$WORK_DIR/gob"
    
    # 创建服务
    create_service
    
    # 创建快捷方式
    create_shortcut
    
    # 检查服务是否成功启动
    sleep 2
    check_install
    local INSTALL_STATUS=$?
    
    if [ $INSTALL_STATUS -eq 0 ]; then
        get_api_key
        get_uri
        info "\n $(text 10) "
        
        # 输出安装信息
        echo "------------------------"
        info " $(text 60) $(text 34) "
        info " $(text 35) "
        get_api_url output
        get_api_key output
        get_uri output
        echo "------------------------"
    else
        warning " $(text 53) "
    fi
    
    help
}

# 创建服务文件
create_service() {
    # 如果在容器环境中，不创建服务文件
    if [ "$IN_CONTAINER" = 1 ]; then
        info " $(text 21) "
        nohup "$WORK_DIR/nodepass" "$CMD" >/dev/null 2>&1 &
        return
    fi
    
    if [ "$SERVICE_MANAGE" = "systemctl" ]; then
        cat > /etc/systemd/system/nodepass.service << EOF
[Unit]
Description=NodePass Service
After=network.target

[Service]
Type=simple
ExecStart=$WORK_DIR/nodepass $CMD
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
    \$PROG \$CMD >/dev/null 2>&1 &
    echo \$! > \$PID
}

stop_service() {
    kill \$(cat \$PID 2>/dev/null) 2>/dev/null
    rm -f \$PID
}

restart() {
    stop
    sleep 2
    start
}
EOF
        chmod +x /etc/init.d/nodepass
        /etc/init.d/nodepass enable
        /etc/init.d/nodepass start
    fi
}

# 创建快捷方式
create_shortcut() {
    ln -sf "${WORK_DIR}/np.sh" /usr/bin/np 2>/dev/null
    ln -sf "${WORK_DIR}/nodepass" /usr/bin/nodepass 2>/dev/null
    info "\n $(text 57) "
}

# 创建本地管理脚本
create_local_management_script() {
    cat > "$WORK_DIR/np.sh" << 'EOF'
#!/usr/bin/env bash
# NodePass 本地管理脚本

WORK_DIR="/etc/nodepass"

# 简单的命令转发
case "$1" in
    -s|--status)
        if [ -f "$WORK_DIR/nodepass" ]; then
            echo "NodePass 状态:"
            if pgrep -f nodepass >/dev/null; then
                echo "运行中"
            else
                echo "已停止"
            fi
        else
            echo "NodePass 未安装"
        fi
        ;;
    -o|--toggle)
        if pgrep -f nodepass >/dev/null; then
            pkill -f nodepass
            echo "服务已停止"
        else
            if [ -f "$WORK_DIR/data" ]; then
                source "$WORK_DIR/data"
                nohup "$WORK_DIR/nodepass" $CMD >/dev/null 2>&1 &
                echo "服务已启动"
            fi
        fi
        ;;
    -p|--ports)
        ps aux | grep nodepass | grep -v grep | grep -E 'master://|client://|server://'
        ;;
    -h|--help)
        echo "NodePass 本地管理命令:"
        echo "  np -s    查看状态"
        echo "  np -o    启动/停止服务"
        echo "  np -p    查看端口"
        echo "  np -h    显示帮助"
        ;;
    *)
        if [ -f "$WORK_DIR/nodepass" ]; then
            echo "NodePass 已安装"
        else
            echo "NodePass 未安装"
        fi
        ;;
esac
EOF
    chmod +x "$WORK_DIR/np.sh"
}

# 卸载 NodePass
uninstall() {
    echo ""
    reading "\n $(text 48) " CONFIRM
    
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]] && [ -n "$CONFIRM" ]; then
        info " $(text 49) "
        exit 0
    fi
    
    # 停止服务
    stop_nodepass
    
    # 禁用服务
    if [ "$SERVICE_MANAGE" = "systemctl" ]; then
        systemctl disable nodepass 2>/dev/null
        rm -f /etc/systemd/system/nodepass.service
        systemctl daemon-reload
    elif [ "$SERVICE_MANAGE" = "rc-service" ]; then
        rc-update del nodepass 2>/dev/null
        rm -f /etc/init.d/nodepass
    elif [ "$SERVICE_MANAGE" = "init.d" ]; then
        /etc/init.d/nodepass disable 2>/dev/null
        rm -f /etc/init.d/nodepass
    fi
    
    # 删除文件
    rm -rf "$WORK_DIR" /usr/bin/np /usr/bin/nodepass 2>/dev/null
    
    info " $(text 11) "
}

# 菜单设置函数
menu_setting() {
    local INSTALL_STATUS=$1
    
    unset OPTION ACTION
    
    if [ "$INSTALL_STATUS" = 2 ]; then
        NODEPASS_STATUS=$(text 32)
        OPTION[1]="1. $(text 28)"
        OPTION[0]="0. $(text 31)"
        ACTION[1]() { install; exit 0; }
        ACTION[0]() { exit 0; }
    else
        get_local_version all
        
        if [ $INSTALL_STATUS -eq 0 ]; then
            NODEPASS_STATUS=$(text 34)
            OPTION[1]="1. $(text 56) (np -o)"
        else
            NODEPASS_STATUS=$(text 33)
            OPTION[1]="1. $(text 58) (np -o)"
        fi
        
        OPTION[2]="2. $(text 30) (np -v)"
        OPTION[3]="3. $(text 95) (np -t)"
        OPTION[4]="4. $(text 6) (np -s)"
        OPTION[5]="5. $(text 6)端口规则 (np -p)"
        OPTION[6]="6. $(text 29) (np -u)"
        OPTION[0]="0. $(text 31)"
        
        ACTION[1]() { on_off $INSTALL_STATUS; exit 0; }
        ACTION[2]() { upgrade_nodepass; exit 0; }
        ACTION[3]() { switch_nodepass_version; exit 0; }
        ACTION[4]() { 
            echo ""
            get_api_url output
            get_api_key output
            get_uri output
            echo ""
            exit 0
        }
        ACTION[5]() { show_port_rules; exit 0; }
        ACTION[6]() { uninstall; exit 0; }
        ACTION[0]() { exit 0; }
    fi
}

# 菜单显示函数
menu() {
    clear
    echo ""
    echo "╭───────────────────────────────────────────╮"
    echo "│ ░░█▀█░█▀█░░▀█░█▀▀░█▀█░█▀█░█▀▀░█▀▀░░ │"
    echo "│ ░░█░█░█░█░█▀█░█▀▀░█▀▀░█▀█░▀▀█░▀▀█░░ │"
    echo "│ ░░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀░░░▀░▀░▀▀▀░▀▀▀░░ │"
    echo "├───────────────────────────────────────────┤"
    echo "│ TCP/UDP Tunneling Solution                │"
    echo "╰───────────────────────────────────────────╯"
    
    if grep -q '.' <<< "$DEV_LOCAL_VERSION" && grep -q '.' <<< "$STABLE_LOCAL_VERSION" && grep -q '.' <<< "$LTS_LOCAL_VERSION"; then
        info " $(text 45) "
    fi
    
    info " $(text 46) "
    
    if grep -q '.' <<< "$RUNNING_LOCAL_VERSION"; then
        info " $VERSION_TYPE_TEXT $RUNNING_LOCAL_VERSION"
    fi
    
    if grep -qE '0|1' <<< "$INSTALL_STATUS"; then
        info " $(text 60) $NODEPASS_STATUS "
    fi
    
    echo "------------------------"
    
    # 显示菜单选项
    for ((b=1; b<${#OPTION[@]}; b++)); do
        hint " ${OPTION[b]} "
    done
    echo ""
    hint " ${OPTION[0]} "
    
    echo "------------------------"
    
    reading " $(text 38) " MENU_CHOICE
    
    if [[ "$MENU_CHOICE" =~ ^[0-9]+$ ]] && [ "$MENU_CHOICE" -ge 0 ] && [ "$MENU_CHOICE" -lt ${#OPTION[@]} ]; then
        ACTION[$MENU_CHOICE]
    else
        warning " $(text 17) [0-$((${#OPTION[@]}-1))] "
        sleep 1
        menu
    fi
}

# 主程序入口
main() {
    # 解析命令行参数
    parse_args "$@"
    
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
    case "${1}" in
        -i|--install)
            if [ "$INSTALL_STATUS" != 2 ]; then
                warning " $(text 18) "
                exit 1
            fi
            install
            ;;
        -u|--uninstall)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            uninstall
            ;;
        -v|--upgrade)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            upgrade_nodepass
            ;;
        -t|--switch)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            switch_nodepass_version
            ;;
        -o|--toggle)
            if [ "$INSTALL_STATUS" = 2 ]; then
                warning " $(text 59) "
                exit 1
            fi
            on_off $INSTALL_STATUS
            ;;
        -s|--status)
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
        -p|--ports)
            show_port_rules
            ;;
        -h|--help)
            help
            ;;
        *)
            menu_setting $INSTALL_STATUS
            menu
            ;;
    esac
}

# 执行主程序
main "$@"
