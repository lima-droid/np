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
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo -e "${PURPLE}[→]${NC} $1"
}

# 检查命令是否存在
check_command() {
    if ! command -v "$1" &> /dev/null; then
        print_error "未找到 $1 命令，请先安装 $1"
        exit 1
    fi
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
    echo -e "  ${BLUE}4${NC}. 退出"
    echo ""
    print_separator
    echo ""
}

# 检查 Docker 是否运行
check_docker() {
    if ! systemctl is-active --quiet docker; then
        print_error "Docker 服务未运行，请先启动 Docker"
        echo ""
        echo -e "${YELLOW}尝试启动 Docker...${NC}"
        if systemctl start docker; then
            print_success "Docker 启动成功"
        else
            print_error "无法启动 Docker，请手动启动后再试"
            exit 1
        fi
    fi
}

# 检查容器状态
check_status() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        return 0
    else
        return 1
    fi
}

# 显示状态
show_status() {
    clear
    print_header "Mihomo 状态检查"
    
    # 检查 Docker
    print_step "检查 Docker 服务..."
    if systemctl is-active --quiet docker; then
        print_success "Docker 服务运行正常"
    else
        print_error "Docker 服务未运行"
    fi
    
    # 检查容器
    print_step "检查容器状态..."
    if check_status; then
        CONTAINER_INFO=$(docker ps --filter "name=${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep ${CONTAINER_NAME})
        print_success "容器正在运行"
        echo ""
        echo -e "${BOLD}容器信息：${NC}"
        echo "$CONTAINER_INFO" | while read line; do
            echo -e "  ${DIM}${line}${NC}"
        done
    else
        if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
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
    if [ -d "$UI_DIR" ] && [ "$(ls -A $UI_DIR)" ]; then
        print_success "UI 文件存在: $UI_DIR"
    else
        print_info "UI 文件不存在"
    fi
    
    echo ""
    print_separator
    echo -e "${YELLOW}按任意键返回主菜单...${NC}"
    read -n 1 -s
}

# 显示安装信息
show_installation_info() {
    IP_ADDR=$(ip route get 1 | awk '{print $7; exit}' 2>/dev/null || echo "localhost")
    
    print_header "安装完成"
    
    echo -e "${BOLD}${GREEN}安装成功！${NC}"
    echo ""
    
    # 服务状态
    echo -e "${BOLD}${WHITE}服务状态：${NC}"
    echo -e "  ${GREEN}[✓]${NC} Mihomo 已在 Docker 中运行"
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
    echo -e "  ${DIM}查看日志：${NC}     docker logs $CONTAINER_NAME"
    echo -e "  ${DIM}重启服务：${NC}     docker restart $CONTAINER_NAME"
    echo -e "  ${DIM}停止服务：${NC}     docker stop $CONTAINER_NAME"
    echo -e "  ${DIM}启动服务：${NC}     docker start $CONTAINER_NAME"
    echo -e "  ${DIM}删除容器：${NC}     docker rm -f $CONTAINER_NAME"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢使用 Mihomo！${NC}"
    echo ""
}

# 安装流程
install_mihomo() {
    clear
    print_header "安装 Mihomo"
    
    # 检查依赖
    print_step "检查系统依赖..."
    check_command "curl"
    check_command "docker"
    check_command "wget"
    check_command "tar"
    print_success "依赖检查通过"
    
    # 检查 Docker
    check_docker
    
    # 检查是否已安装
    if check_status; then
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
    if curl -fsSL "$UI_URL" -o /dev/null --silent --head --fail; then
        print_success "UI 版本可用"
    else
        print_error "无法访问 UI 下载地址"
        exit 1
    fi
    
    # 下载 UI
    print_step "下载 UI 组件..."
    if wget --show-progress -q -O /tmp/ui.tar.gz "$UI_URL"; then
        print_success "UI 下载完成"
    else
        print_error "UI 下载失败"
        exit 1
    fi
    
    # 清理并解压
    print_step "解压文件..."
    rm -rf "$UI_DIR"/*
    tar -xzf /tmp/ui.tar.gz -C "$UI_DIR" --strip-components=1 || {
        print_error "解压失败"
        exit 1
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
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker rm -f ${CONTAINER_NAME} >/dev/null 2>&1
        print_success "旧容器已移除"
    else
        print_info "未找到旧容器"
    fi
    
    # 拉取最新镜像
    print_step "拉取最新镜像..."
    docker pull ${IMAGE_NAME} >/dev/null 2>&1 || {
        print_error "镜像拉取失败"
        exit 1
    }
    print_success "镜像拉取完成"
    
    # 启动新容器
    print_step "启动 Mihomo 容器..."
    if docker run -d \
        --name ${CONTAINER_NAME} \
        --restart always \
        --network host \
        --cap-add=NET_ADMIN \
        --device /dev/net/tun \
        --log-driver=none \
        -v "$CONFIG_DIR":/root/.config/mihomo \
        ${IMAGE_NAME} > /dev/null 2>&1; then
        
        # 等待容器启动
        sleep 3
        if check_status; then
            print_success "容器启动成功"
        else
            print_error "容器启动失败"
            exit 1
        fi
    else
        print_error "容器启动失败"
        exit 1
    fi
    
    # 显示安装信息
    show_installation_info
}

# 卸载流程
uninstall_mihomo() {
    clear
    print_header "卸载 Mihomo"
    
    echo -e "${YELLOW}[!]${NC} 您正在卸载 Mihomo，此操作不可逆！"
    echo ""
    
    read -p "确定要卸载吗？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消卸载"
        return
    fi
    
    # 1. 停止并删除容器
    print_step "1. 停止并删除容器 ${CONTAINER_NAME}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        docker stop ${CONTAINER_NAME} >/dev/null 2>&1 || true
        docker rm ${CONTAINER_NAME} >/dev/null 2>&1 || true
        print_success "容器 ${CONTAINER_NAME} 已删除"
    else
        print_info "容器 ${CONTAINER_NAME} 不存在，跳过"
    fi
    
    # 2. 删除镜像
    print_step "2. 删除镜像 ${IMAGE_NAME}"
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
        docker rmi ${IMAGE_NAME} >/dev/null 2>&1 || true
        print_success "镜像 ${IMAGE_NAME} 已删除"
    else
        print_info "镜像 ${IMAGE_NAME} 不存在，跳过"
    fi
    
    # 3. 删除配置目录
    print_step "3. 删除配置目录 ${CONFIG_DIR}"
    if [ -d "${CONFIG_DIR}" ]; then
        rm -rf ${CONFIG_DIR}
        print_success "配置目录已删除"
    else
        print_info "配置目录不存在，跳过"
    fi
    
    # 4. 清理可能残留的 tun 设备
    print_step "4. 清理网络设备"
    if ip link show tun0 >/dev/null 2>&1; then
        ip link delete tun0 2>/dev/null || true
        print_success "网络设备已清理"
    else
        print_info "未发现残留网络设备"
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
    echo -e "  ${DIM}2.${NC} 所有相关数据已彻底删除"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢您使用 Mihomo，期待下次再见！${NC}"
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
    
    while true; do
        show_menu
        
        read -p "请选择 (1-4): " choice
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
                continue
                ;;
            4)
                echo "再见！"
                exit 0
                ;;
            *)
                print_error "无效的选择，请输入 1-4"
                ;;
        esac
        
        echo ""
        echo -e "${YELLOW}按任意键返回主菜单...${NC}"
        read -n 1 -s
    done
}

# 运行主函数
main "$@"
