#!/bin/bash
set -e

INSTALL_DIR="/etc/Mihomo"
UI_DIR="$INSTALL_DIR/ui"
CONFIG_FILE="$INSTALL_DIR/config.yaml"
PANEL_SECRET="123456"

# 颜色定义（使用英文变量名）
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

print_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo '  __  __ _   _ _   _  ____  __  __ ___ '
    echo ' |  \/  | | | | | | |/ ___|  \/  / _ \'
    echo ' | |\/| | |_| | |_| | |  _| |\/| | |_| |'
    echo ' |_|  |_|\___/ \___/|_| (_)_|  |_|\___/'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 一键安装脚本${NC}"
    echo ""
}

# 显示安装信息
show_installation_info() {
    IP_ADDR=$(ip route get 1 | awk '{print $7; exit}')
    
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
    echo -e "  ${CYAN}|  控制面板：    http://$IP_ADDR:9090/ui          ${NC}"
    echo -e "  ${CYAN}|  密钥：        $PANEL_SECRET                ${NC}"
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
    echo -e "  ${DIM}安装目录：${NC}   $INSTALL_DIR"
    echo ""
    
    # 管理命令
    echo -e "${BOLD}${WHITE}管理命令：${NC}"
    echo -e "  ${DIM}查看日志：${NC}     docker logs Mihomo"
    echo -e "  ${DIM}重启服务：${NC}     docker restart Mihomo"
    echo -e "  ${DIM}停止服务：${NC}     docker stop Mihomo"
    echo -e "  ${DIM}启动服务：${NC}     docker start Mihomo"
    echo -e "  ${DIM}删除容器：${NC}     docker rm -f Mihomo"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢使用 Mihomo！${NC}"
    echo ""
}

# 检查依赖但不检查 Docker 服务状态
check_dependencies() {
    print_step "检查系统依赖..."
    
    # 检查 curl
    if ! command -v curl &> /dev/null; then
        print_error "未找到 curl 命令，请先安装 curl"
        exit 1
    fi
    
    # 检查 wget
    if ! command -v wget &> /dev/null; then
        print_error "未找到 wget 命令，请先安装 wget"
        exit 1
    fi
    
    # 检查 tar
    if ! command -v tar &> /dev/null; then
        print_error "未找到 tar 命令，请先安装 tar"
        exit 1
    fi
    
    # 检查 docker 命令是否存在（但不检查服务状态）
    if ! command -v docker &> /dev/null; then
        print_error "未找到 docker 命令"
        echo ""
        echo -e "${YELLOW}对于 iStoreOS/OpenWrt，请确保已安装 Docker：${NC}"
        echo "  1. 在 iStore 中搜索安装 Docker"
        echo "  2. 或使用命令：opkg install docker"
        echo ""
        exit 1
    fi
    
    print_success "依赖检查通过"
}

# 主安装流程
main() {
    print_banner
    
    print_header "开始安装"
    
    # 检查依赖（但不检查 Docker 服务状态）
    check_dependencies
    
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
        -v "$INSTALL_DIR":/root/.config/mihomo \
        metacubex/mihomo:latest > /dev/null 2>&1
    
    # 等待容器启动
    sleep 2
    if docker ps | grep -q Mihomo; then
        print_success "容器启动成功"
    else
        print_error "容器启动失败"
        echo ""
        echo -e "${YELLOW}如果 Docker 服务未运行，请先启动 Docker：${NC}"
        echo "  1. 检查 Docker 是否安装：opkg list-installed | grep docker"
        echo "  2. 启动 Docker：/etc/init.d/docker start"
        echo "  3. 设置开机自启：/etc/init.d/docker enable"
        echo ""
        exit 1
    fi
    
    # 显示安装信息
    show_installation_info
}

# 运行主函数
main "$@"
