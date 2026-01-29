#!/bin/bash
set -e

# 常量定义
CONTAINER_NAME="Mihomo"
IMAGE_NAME="metacubex/mihomo:latest"
CONFIG_DIR="/etc/Mihomo"
UI_DIR="$CONFIG_DIR/ui"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
PANEL_SECRET="123456"
UI_URL="https://github.com/MetaCubeX/metacubexd/releases/latest/download/compressed-dist.tgz"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# 输出样式
BOLD='\033[1m'
DIM='\033[2m'

# 分隔线函数
print_separator() {
    echo -e "${CYAN}==================================================${NC}"
}

print_header() {
    echo ""
    print_separator
    echo -e "${BOLD}${WHITE} $1 ${NC}"
    print_separator
    echo ""
}

print_success() {
    echo -e "${GREEN}[+]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[x]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[>]${NC} $1"
}

# 系统检测函数
detect_system() {
    # 检查是否是软路由（OpenWrt/LEDE）
    if [ -f "/etc/openwrt_release" ] || [ -f "/etc/openwrt_version" ] || [ -d "/etc/openwrt" ]; then
        echo "openwrt"
    # 检查是否是 VPS（通常有 systemd）
    elif command -v systemctl &>/dev/null && systemctl --version &>/dev/null; then
        echo "vps"
    # 默认认为是普通 Linux
    else
        echo "linux"
    fi
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "未找到 $1 命令，请先安装 $1"
        exit 1
    fi
}

# 检查 Docker 是否运行（根据系统类型）
check_docker() {
    local system_type=$(detect_system)
    
    case $system_type in
        "openwrt")
            # OpenWrt 使用 procd 管理服务
            if pgrep -x "dockerd" >/dev/null || pgrep -f "docker daemon" >/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
        "vps")
            # VPS 使用 systemctl
            if systemctl is-active --quiet docker; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            # 普通 Linux 直接检查 Docker 进程
            if docker info &>/dev/null; then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

# 启动 Docker 服务
start_docker() {
    local system_type=$(detect_system)
    
    print_step "尝试启动 Docker 服务..."
    
    case $system_type in
        "openwrt")
            # OpenWrt
            if command -v /etc/init.d/docker &>/dev/null; then
                /etc/init.d/docker start && return 0
            elif command -v service &>/dev/null; then
                service docker start && return 0
            else
                print_error "无法启动 Docker，请手动启动"
                return 1
            fi
            ;;
        "vps")
            # VPS 使用 systemctl
            if systemctl start docker; then
                return 0
            else
                print_error "无法启动 Docker，请手动启动"
                return 1
            fi
            ;;
        *)
            # 普通 Linux
            print_warning "无法自动启动 Docker，请手动启动后再试"
            echo ""
            echo -e "${YELLOW}请执行以下命令启动 Docker：${NC}"
            echo "  sudo systemctl start docker  # 对于 systemd 系统"
            echo "  sudo service docker start    # 对于 sysvinit 系统"
            echo ""
            return 1
            ;;
    esac
}

# 检查容器状态
check_container_status() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        return 0
    else
        return 1
    fi
}

# 显示安装信息
show_installation_info() {
    IP_ADDR=$(ip route get 1 2>/dev/null | awk '{print $7; exit}' || echo "localhost")
    
    print_header "安装完成"
    
    echo -e "${BOLD}${GREEN}安装成功！${NC}"
    echo ""
    
    # 服务状态
    echo -e "${BOLD}${WHITE}服务状态：${NC}"
    echo -e "  ${GREEN}[+]${NC} Mihomo 已在 Docker 中运行"
    echo ""
    
    # 访问信息
    echo -e "${BOLD}${WHITE}访问信息：${NC}"
    echo -e "  ${CYAN}+-----------------------------------------------+${NC}"
    echo -e "  ${CYAN}|  控制面板：    http://${IP_ADDR}:9090/ui      ${NC}"
    echo -e "  ${CYAN}|  密钥：        ${PANEL_SECRET}                ${NC}"
    echo -e "  ${CYAN}+-----------------------------------------------+${NC}"
    echo ""
    
    # 端口信息
    echo -e "${BOLD}${WHITE}端口配置：${NC}"
    echo -e "  ${DIM}混合端口：${NC}   7890"
    echo -e "  ${DIM}HTTP端口：${NC}   7891"
    echo -e "  ${DIM}SOCKS端口：${NC}  7892"
    echo -e "  ${DIM}重定向端口：${NC} 7893"
    echo -e "  ${DIM}TProxy端口：${NC} 7894"
    echo ""
    
    # 文件路径
    echo -e "${BOLD}${WHITE}文件位置：${NC}"
    echo -e "  ${DIM}配置文件：${NC}   $CONFIG_FILE"
    echo -e "  ${DIM}UI目录：${NC}     $UI_DIR"
    echo -e "  ${DIM}安装目录：${NC}   $CONFIG_DIR"
    echo ""
    
    # 管理命令
    echo -e "${BOLD}${WHITE}管理命令：${NC}"
    echo -e "  ${DIM}查看日志：${NC}     docker logs ${CONTAINER_NAME}"
    echo -e "  ${DIM}重启服务：${NC}     docker restart ${CONTAINER_NAME}"
    echo -e "  ${DIM}停止服务：${NC}     docker stop ${CONTAINER_NAME}"
    echo -e "  ${DIM}启动服务：${NC}     docker start ${CONTAINER_NAME}"
    echo -e "  ${DIM}删除容器：${NC}     docker rm -f ${CONTAINER_NAME}"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢使用 Mihomo！${NC}"
    echo ""
}

# 显示状态
show_status() {
    local system_type=$(detect_system)
    
    print_header "Mihomo 状态检查"
    
    # 显示系统类型
    echo -e "${BOLD}系统类型：${NC} ${system_type}"
    echo ""
    
    # 检查 Docker
    print_step "检查 Docker 服务..."
    if check_docker; then
        print_success "Docker 服务运行正常"
    else
        print_error "Docker 服务未运行"
    fi
    
    # 检查容器
    print_step "检查容器状态..."
    if check_container_status; then
        CONTAINER_INFO=$(docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || true)
        print_success "容器正在运行"
        if [ -n "$CONTAINER_INFO" ]; then
            echo ""
            echo -e "${BOLD}容器信息：${NC}"
            echo "$CONTAINER_INFO"
        fi
    else
        if docker ps -a --format '{{.Names}}' 2>/dev/null | grep -q "^${CONTAINER_NAME}$"; then
            print_warning "容器存在但未运行"
        else
            print_info "容器不存在"
        fi
    fi
    
    # 检查配置文件
    print_step "检查配置文件..."
    if [ -f "$CONFIG_FILE" ]; then
        print_success "配置文件存在: $CONFIG_FILE"
    else
        print_info "配置文件不存在"
    fi
    
    # 检查 UI 文件
    print_step "检查 UI 文件..."
    if [ -d "$UI_DIR" ] && [ "$(ls -A $UI_DIR 2>/dev/null)" ]; then
        print_success "UI 文件存在: $UI_DIR"
    else
        print_info "UI 文件不存在"
    fi
    
    echo ""
    print_separator
}

# 安装流程（保持原始逻辑）
install_mihomo() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo '  __  __ _   _ _   _  ____  __  __ ___ '
    echo ' |  \/  | | | | | | |/ ___|  \/  / _ \'
    echo ' | |\/| | |_| | |_| | |  _| |\/| | |_| |'
    echo ' |_|  |_|\___/ \___/|_| (_)_|  |_|\___/'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 一键安装脚本${NC}"
    
    print_header "开始安装"
    
    # 检查依赖
    print_step "检查系统依赖..."
    check_command "curl"
    check_command "docker"
    check_command "wget"
    check_command "tar"
    print_success "依赖检查通过"
    
    # 检查 Docker
    print_step "检查 Docker 服务..."
    if ! check_docker; then
        print_error "Docker 服务未运行"
        echo ""
        echo -e "${YELLOW}尝试启动 Docker...${NC}"
        if start_docker; then
            print_success "Docker 启动成功"
            sleep 2
        else
            echo ""
            echo -e "${RED}请手动启动 Docker 后重新运行脚本${NC}"
            exit 1
        fi
    else
        print_success "Docker 服务正常"
    fi
    
    # 检查是否已安装
    if check_container_status; then
        print_warning "Mihomo 已经在运行！"
        echo ""
        read -p "是否重新安装？(y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "取消安装"
            return
        fi
    fi
    
    # 创建目录
    print_step "创建目录..."
    mkdir -p "$UI_DIR"
    print_success "目录创建完成"
    
    # 获取 UI
    print_step "获取最新 UI 版本..."
    URL=$(curl -fsSL https://api.github.com/repos/MetaCubeX/metacubexd/releases/latest | \
        grep -o 'https://[^"]*compressed-dist.tgz' | head -1)
    
    [ -n "$URL" ] || { print_error "无法获取 UI 下载链接"; exit 1; }
    print_success "找到最新版本"
    
    # 下载 UI
    print_step "下载 UI 组件..."
    wget -q --show-progress -O /tmp/ui.tar.gz "$URL" || { 
        print_error "UI 下载失败"; 
        exit 1; 
    }
    print_success "UI 下载完成"
    
    # 清理并解压
    print_step "解压文件..."
    rm -rf "$UI_DIR"/*
    mkdir -p "$UI_DIR"
    tar -xzf /tmp/ui.tar.gz -C "$UI_DIR" --strip-components=1 || { 
        print_error "解压失败"; 
        exit 1; 
    }
    rm -f /tmp/ui.tar.gz
    print_success "文件解压完成"
    
    # 创建配置文件
    print_step "创建配置文件..."
    cat > "$CONFIG_FILE" <<EOL
mixed-port: 7890
port: 7891
socks-port: 7892
redir-port: 7893
tproxy-port: 7894
allow-lan: true
mode: rule
log-level: info
external-controller: 0.0.0.0:9090
secret: '$PANEL_SECRET'
external-ui: ui
ipv6: true
EOL
    print_success "配置文件创建完成"
    
    # 停止旧容器
    print_step "停止现有容器..."
    docker rm -f Mihomo 2>/dev/null || true
    print_success "旧容器已移除"
    
    # 启动新容器
    print_step "启动 Mihomo 容器..."
    docker run -d \
        --name Mihomo \
        --restart always \
        --network host \
        --cap-add=NET_ADMIN \
        --device /dev/net/tun \
        --log-driver=none \
        -v "$CONFIG_DIR":/root/.config/mihomo \
        metacubex/mihomo:latest > /dev/null 2>&1
    
    # 等待容器启动
    sleep 2
    if docker ps | grep -q Mihomo; then
        print_success "容器启动成功"
    else
        print_error "容器启动失败"
        exit 1
    fi
    
    # 显示安装信息
    show_installation_info
}

# 卸载流程（保持原始逻辑）
uninstall_mihomo() {
    clear
    echo -e "${BOLD}${RED}"
    echo '  _   _         _                 _       _ '
    echo ' | | | |  ___  | |__     ___     | |__   | |'
    echo ' | | | | / __| |  _ \   / _ \    |  _ \  | |'
    echo ' | |_| | \__ \ | | | | | (_) |   | | | | |_|'
    echo '  \___/  |___/ |_| |_|  \___/    |_| |_| (_)'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 卸载脚本${NC}"
    
    print_header "开始卸载 Mihomo"
    
    echo -e "${YELLOW}[!]${NC} 您正在卸载 Mihomo，此操作不可逆！"
    echo ""
    
    # 1. 停止并删除容器
    print_step "1. 停止并删除容器 ${CONTAINER_NAME}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${DIM}   正在停止容器...${NC}"
        docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
        echo -e "${DIM}   正在删除容器...${NC}"
        docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
        print_success "容器 ${CONTAINER_NAME} 已删除"
    else
        echo -e "${DIM}   容器 ${CONTAINER_NAME} 不存在，跳过${NC}"
    fi
    echo ""
    
    # 2. 删除镜像
    print_step "2. 删除镜像 ${IMAGE_NAME}"
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        echo -e "${DIM}   正在删除镜像...${NC}"
        docker rmi ${IMAGE_NAME} >/dev/null 2>&1 || true
        print_success "镜像 ${IMAGE_NAME} 已删除"
    else
        echo -e "${DIM}   镜像 ${IMAGE_NAME} 不存在，跳过${NC}"
    fi
    echo ""
    
    # 3. 删除配置目录
    print_step "3. 删除配置目录 ${CONFIG_DIR}"
    if [ -d "${CONFIG_DIR}" ]; then
        echo -e "${DIM}   正在删除配置文件...${NC}"
        rm -rf ${CONFIG_DIR}
        print_success "配置目录已删除"
    else
        echo -e "${DIM}   配置目录不存在，跳过${NC}"
    fi
    echo ""
    
    # 4. 清理可能残留的 tun 设备
    print_step "4. 清理网络设备"
    if ip link show tun0 >/dev/null 2>&1; then
        echo -e "${DIM}   发现残留 tun0 设备，正在删除...${NC}"
        ip link delete tun0 2>/dev/null || true
        print_success "网络设备已清理"
    else
        echo -e "${DIM}   未发现残留网络设备${NC}"
    fi
    
    print_header "卸载完成"
    
    echo -e "${BOLD}${GREEN}✓ 卸载成功！${NC}"
    echo ""
    
    echo -e "${BOLD}${WHITE}已清理的项目：${NC}"
    echo -e "  ${DIM}•${NC} 容器: ${CONTAINER_NAME}"
    echo -e "  ${DIM}•${NC} 镜像: ${IMAGE_NAME}"
    echo -e "  ${DIM}•${NC} 配置目录: ${CONFIG_DIR}"
    echo -e "  ${DIM}•${NC} 网络设备: tun0 (如果存在)"
    echo ""
    
    echo -e "${BOLD}${WHITE}注意事项：${NC}"
    echo -e "  ${DIM}1.${NC} 如果您有自定义规则，建议提前备份"
    echo -e "  ${DIM}2.${NC} 下次安装需要使用新的脚本"
    echo -e "  ${DIM}3.${NC} 所有相关数据已彻底删除"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢您使用 Mihomo，期待下次再见！${NC}"
    echo ""
}

# 显示主菜单
show_menu() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo '  __  __ _   _ _   _  ____  __  __ ___ '
    echo ' |  \/  | | | | | | |/ ___|  \/  / _ \'
    echo ' | |\/| | |_| | |_| | |  _| |\/| | |_| |'
    echo ' |_|  |_|\___/ \___/|_| (_)_|  |_|\___/'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 一键管理脚本${NC}"
    print_separator
    echo ""
    echo -e "${BOLD}${WHITE}请选择操作：${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}. 安装 Mihomo"
    echo -e "  ${RED}2${NC}. 卸载 Mihomo"
    echo -e "  ${YELLOW}3${NC}. 查看状态"
    echo -e "  ${BLUE}4${NC}. 重启服务"
    echo -e "  ${PURPLE}5${NC}. 查看日志"
    echo -e "  ${CYAN}6${NC}. 退出"
    echo ""
    print_separator
    echo ""
}

# 主函数
main() {
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户运行此脚本"
        echo "使用: sudo bash $0"
        exit 1
    fi
    
    # 显示系统检测信息（可选）
    local system_type=$(detect_system)
    if [ "$SHOW_SYSTEM_INFO" = "1" ]; then
        echo -e "${BOLD}检测到的系统类型：${NC} ${system_type}"
        echo ""
    fi
    
    while true; do
        show_menu
        
        read -p "请选择 (1-6): " choice
        echo ""
        
        case $choice in
            1)
                install_mihomo
                ;;
            2)
                uninstall_mihomo
                ;;
            3)
                show_status
                read -p "按任意键继续..." -n 1 -s
                continue
                ;;
            4)
                if check_container_status; then
                    print_step "重启服务..."
                    docker restart ${CONTAINER_NAME} 2>/dev/null && print_success "服务重启成功" || print_error "重启失败"
                else
                    print_error "服务未运行"
                fi
                ;;
            5)
                if check_container_status; then
                    print_step "查看日志（Ctrl+C 退出）..."
                    docker logs -f ${CONTAINER_NAME}
                else
                    print_error "服务未运行"
                fi
                ;;
            6)
                echo "再见！"
                exit 0
                ;;
            *)
                print_error "无效的选择，请输入 1-6"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键返回主菜单...${NC}"
        read -n 1 -s
    done
}

# 如果没有参数，显示菜单；否则执行对应命令
if [ $# -eq 0 ]; then
    main "$@"
else
    case "$1" in
        "install")
            install_mihomo
            ;;
        "uninstall")
            uninstall_mihomo
            ;;
        "status")
            show_status
            ;;
        "restart")
            if check_container_status; then
                docker restart ${CONTAINER_NAME}
            else
                print_error "服务未运行"
            fi
            ;;
        "logs")
            if check_container_status; then
                docker logs -f ${CONTAINER_NAME}
            else
                print_error "服务未运行"
            fi
            ;;
        "info")
            SHOW_SYSTEM_INFO=1
            main
            ;;
        *)
            echo "用法: $0 {install|uninstall|status|restart|logs|info}"
            echo ""
            echo "命令说明:"
            echo "  install    安装 Mihomo"
            echo "  uninstall  卸载 Mihomo"
            echo "  status     查看状态"
            echo "  restart    重启服务"
            echo "  logs       查看日志"
            echo "  info       显示系统信息并进入菜单"
            echo ""
            echo "或者直接运行脚本进入菜单模式"
            exit 1
            ;;
    esac
fi
