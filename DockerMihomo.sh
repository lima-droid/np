#!/bin/bash
set -e

CONTAINER_NAME="Mihomo"
IMAGE_NAME="metacubex/mihomo:latest"
CONFIG_DIR="/etc/Mihomo"

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

print_banner() {
    clear
    echo -e "${BOLD}${RED}"
    echo '  _   _         _                 _       _ '
    echo ' | | | |  ___  | |__     ___     | |__   | |'
    echo ' | | | | / __| |  _ \   / _ \    |  _ \  | |'
    echo ' | |_| | \__ \ | | | | | (_) |   | | | | |_|'
    echo '  \___/  |___/ |_| |_|  \___/    |_| |_| (_)'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 卸载脚本${NC}"
    echo ""
}

# 主卸载流程
main() {
    print_banner
    
    print_header "开始卸载 Mihomo"
    
    echo -e "${YELLOW}[!]${NC} 您正在卸载 Mihomo，此操作不可逆！"
    echo ""
    
    read -p "确定要卸载吗？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消卸载"
        exit 0
    fi
    
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
    echo -e "  ${DIM}2.${NC} 下次安装需要使用安装脚本重新安装"
    echo -e "  ${DIM}3.${NC} 所有相关数据已彻底删除"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢您使用 Mihomo，期待下次再见！${NC}"
    echo ""
}

# 运行主函数
main "$@"
