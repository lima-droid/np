#!/bin/bash
set -e

INSTALL_DIR="/etc/Mihomo"
UI_DIR="$INSTALL_DIR/ui"
CONFIG_FILE="$INSTALL_DIR/config.yaml"
SERVICE_FILE="/etc/systemd/system/mihomo.service"
PANEL_SECRET="123456"

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

print_banner() {
    clear
    echo -e "${BOLD}${CYAN}"
    echo '  __  __ _   _ _   _  ____  __  __ ___ '
    echo ' |  \/  | | | | | | |/ ___|  \/  / _ \'
    echo ' | |\/| | |_| | |_| | |  _| |\/| | |_| |'
    echo ' |_|  |_|\___/ \___/|_| (_)_|  |_|\___/'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 裸核版管理脚本${NC}"
    echo ""
}

# 显示菜单
show_menu() {
    print_banner
    print_header "请选择操作"
    
    echo -e "${BOLD}${WHITE}安装类型：裸核版（Systemd）${NC}"
    echo ""
    echo -e "${GREEN}[特点]${NC}"
    echo -e "  • 直接运行 Mihomo 核心"
    echo -e "  • 无需 Docker，资源占用少"
    echo -e "  • 使用 systemd 管理服务"
    echo -e "  • 稳定可靠"
    echo ""
    
    echo -e "${BOLD}${WHITE}请选择操作：${NC}"
    echo ""
    echo -e "  ${GREEN}1${NC}. 安装 Mihomo 裸核版"
    echo -e "  ${RED}2${NC}. 卸载 Mihomo 裸核版"
    echo -e "  ${YELLOW}3${NC}. 查看状态"
    echo -e "  ${BLUE}4${NC}. 重启服务"
    echo -e "  ${PURPLE}5${NC}. 查看日志"
    echo -e "  ${CYAN}6${NC}. 退出"
    echo ""
    print_separator
    echo ""
}

# 检查root权限
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用 root 用户运行此脚本"
        echo "使用: sudo bash $0"
        exit 1
    fi
}

# 检查依赖
check_dependencies() {
    print_step "检查系统依赖..."
    
    # 检查 curl
    if ! command -v curl &> /dev/null; then
        print_error "未找到 curl 命令"
        echo -e "${YELLOW}请安装 curl：${NC}"
        echo "  apt-get install curl  # Ubuntu/Debian"
        echo "  yum install curl      # CentOS/RHEL"
        exit 1
    fi
    
    # 检查 wget
    if ! command -v wget &> /dev/null; then
        print_error "未找到 wget 命令"
        echo -e "${YELLOW}请安装 wget：${NC}"
        echo "  apt-get install wget  # Ubuntu/Debian"
        echo "  yum install wget      # CentOS/RHEL"
        exit 1
    fi
    
    # 检查 tar/gzip
    if ! command -v tar &> /dev/null; then
        print_error "未找到 tar 命令"
        exit 1
    fi
    
    if ! command -v gzip &> /dev/null; then
        print_error "未找到 gzip 命令"
        exit 1
    fi
    
    print_success "依赖检查通过"
}

# 显示安装完成信息
show_installation_summary() {
    local IP_ADDR=""
    local MIHOMO_VER=""
    
    # 获取IP地址
    IP_ADDR=$(ip route get 1 | awk '{print $7; exit}' 2>/dev/null) || IP_ADDR="本地网络"
    
    # 获取版本
    if [ -x "$INSTALL_DIR/mihomo" ]; then
        MIHOMO_VER=$("$INSTALL_DIR/mihomo" -v 2>/dev/null || echo "未知版本")
    fi
    
    print_header "安装完成"
    
    echo -e "${BOLD}${GREEN}Mihomo 裸核版安装成功！${NC}"
    echo ""
    
    echo -e "${BOLD}${WHITE}访问信息：${NC}"
    echo -e "  ${CYAN}+-----------------------------------------------+${NC}"
    echo -e "  ${CYAN}|  控制面板：    http://127.0.0.1:9090/ui          ${NC}"
    if [ "$IP_ADDR" != "本地网络" ]; then
        echo -e "  ${CYAN}|                http://$IP_ADDR:9090/ui        ${NC}"
    fi
    echo -e "  ${CYAN}|  密钥：        $PANEL_SECRET                ${NC}"
    echo -e "  ${CYAN}+-----------------------------------------------+${NC}"
    echo ""
    
    echo -e "${BOLD}${WHITE}核心信息：${NC}"
    echo -e "  ${DIM}版本：${NC}     ${MIHOMO_VER}"
    echo -e "  ${DIM}安装目录：${NC} $INSTALL_DIR"
    echo -e "  ${DIM}配置文件：${NC} $CONFIG_FILE"
    echo ""
    
    echo -e "${BOLD}${WHITE}端口配置：${NC}"
    echo -e "  ${DIM}混合端口：${NC}   7890 (HTTP+SOCKS)"
    echo -e "  ${DIM}HTTP端口：${NC}   7891"
    echo -e "  ${DIM}SOCKS端口：${NC}  7892"
    echo -e "  ${DIM}重定向端口：${NC} 7893"
    echo -e "  ${DIM}TProxy端口：${NC} 7894"
    echo ""
    
    echo -e "${BOLD}${WHITE}服务管理：${NC}"
    echo -e "  ${DIM}启动服务：${NC}     systemctl start mihomo"
    echo -e "  ${DIM}停止服务：${NC}     systemctl stop mihomo"
    echo -e "  ${DIM}重启服务：${NC}     systemctl restart mihomo"
    echo -e "  ${DIM}查看状态：${NC}     systemctl status mihomo"
    echo -e "  ${DIM}查看日志：${NC}     journalctl -u mihomo -f"
    echo -e "  ${DIM}开机自启：${NC}     systemctl enable mihomo"
    echo -e "  ${DIM}禁用自启：${NC}     systemctl disable mihomo"
    echo ""
    
    print_separator
    echo -e "${GREEN}感谢使用 Mihomo！${NC}"
    echo ""
}

# 安装流程
install_mihomo() {
    clear
    print_banner
    print_header "安装 Mihomo 裸核版"
    
    # 检查是否已安装
    if systemctl is-active mihomo &>/dev/null; then
        print_warning "Mihomo 已经在运行！"
        echo ""
        read -p "是否重新安装？(y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "取消安装"
            return
        fi
        
        # 停止旧服务
        systemctl stop mihomo 2>/dev/null || true
    fi
    
    # 检查依赖
    check_dependencies
    
    # 创建目录
    print_step "1. 创建安装目录"
    echo -e "${DIM}   安装目录: $INSTALL_DIR${NC}"
    mkdir -p "$INSTALL_DIR"
    print_success "目录创建完成"
    echo ""
    
    # 获取最新 Mihomo
    print_step "2. 下载 Mihomo 核心"
    echo -e "${DIM}   正在获取最新版本信息...${NC}"
    LATEST_URL=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest \
        | grep "browser_download_url.*linux-amd64.*gz" \
        | cut -d '"' -f 4 \
        | head -n1)
    
    if [ -z "$LATEST_URL" ]; then
        print_error "无法获取 Mihomo 下载链接"
        exit 1
    fi
    
    echo -e "${DIM}   下载地址: $(echo $LATEST_URL | cut -d'/' -f5-)${NC}"
    curl -L -o "$INSTALL_DIR/mihomo.gz" "$LATEST_URL" 2>/dev/null
    print_success "下载完成"
    
    print_step "3. 解压并配置可执行权限"
    gzip -df "$INSTALL_DIR/mihomo.gz" 2>/dev/null
    chmod +x "$INSTALL_DIR/mihomo"
    print_success "解压完成"
    
    if "$INSTALL_DIR/mihomo" -v >/dev/null 2>&1; then
        MIHOMO_VER=$("$INSTALL_DIR/mihomo" -v)
        echo -e "${DIM}   版本: $MIHOMO_VER${NC}"
    fi
    echo ""
    
    # 下载 UI
    print_step "4. 下载 Web UI 面板"
    mkdir -p "$UI_DIR"
    
    echo -e "${DIM}   正在获取 UI 版本信息...${NC}"
    UI_URL=$(curl -s https://api.github.com/repos/MetaCubeX/metacubexd/releases/latest \
        | grep browser_download_url \
        | grep compressed-dist.tgz \
        | cut -d '"' -f 4)
    
    if [ -z "$UI_URL" ]; then
        print_error "无法获取 UI 下载链接"
        exit 1
    fi
    
    echo -e "${DIM}   下载地址: $(echo $UI_URL | cut -d'/' -f5-)${NC}"
    wget -q -O /tmp/ui.tar.gz "$UI_URL"
    tar -xzf /tmp/ui.tar.gz -C "$UI_DIR" --strip-components=1 2>/dev/null
    rm -f /tmp/ui.tar.gz
    print_success "UI 面板安装完成"
    echo ""
    
    # 创建配置文件
    print_step "5. 创建配置文件"
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
    echo ""
    
    # 创建 systemd 服务
    print_step "6. 创建 systemd 服务"
    cat > "$SERVICE_FILE" <<EOL
[Unit]
Description=mihomo core service
After=network.target

[Service]
Type=simple
ExecStart=$INSTALL_DIR/mihomo -d $INSTALL_DIR
Restart=on-failure
RestartSec=3
User=root
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOL
    
    systemctl daemon-reload
    print_success "服务文件创建完成"
    echo ""
    
    # 启动服务
    print_step "7. 启动服务"
    systemctl enable --now mihomo >/dev/null 2>&1
    
    echo -e "${DIM}   等待服务启动...${NC}"
    for i in {1..10}; do
        if systemctl is-active mihomo >/dev/null 2>&1; then
            print_success "服务启动成功"
            break
        fi
        sleep 1
        if [ $i -eq 10 ]; then
            print_warning "服务启动较慢，正在检查状态..."
            systemctl status mihomo --no-pager -l
        fi
    done
    echo ""
    
    # 显示安装总结
    show_installation_summary
}

# 卸载流程
uninstall_mihomo() {
    clear
    echo -e "${BOLD}${RED}"
    echo '  __  __ _   _         _                 _       _ '
    echo ' |  \/  | | | |  ___  | |__     ___     | |__   | |'
    echo ' | |\/| | | | | / __| |  _ \   / _ \    |  _ \  | |'
    echo ' | |  | | |_| | \__ \ | | | | | (_) |   | | | | |_|'
    echo ' |_|  |_|\___/  |___/ |_| |_|  \___/    |_| |_| (_)'
    echo -e "${NC}"
    echo -e "${DIM}          Mihomo 卸载${NC}"
    
    print_header "卸载 Mihomo 裸核版"
    
    echo -e "${YELLOW}[!]${NC} 警告：此操作将完全删除 Mihomo 及其所有配置数据"
    echo ""
    
    read -p "确定要卸载吗？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消卸载"
        return
    fi
    
    # 1. 停止服务
    print_step "1. 停止 Mihomo 服务"
    if systemctl stop mihomo 2>/dev/null; then
        print_success "服务已停止"
    else
        echo -e "${DIM}   服务未运行或不存在${NC}"
    fi
    echo ""
    
    # 2. 禁用服务
    print_step "2. 禁用 Mihomo 服务"
    if systemctl disable mihomo 2>/dev/null; then
        print_success "服务已禁用"
    else
        echo -e "${DIM}   服务未启用或不存在${NC}"
    fi
    echo ""
    
    # 3. 删除服务文件
    print_step "3. 删除 systemd 服务文件"
    if [ -f "$SERVICE_FILE" ]; then
        rm -f "$SERVICE_FILE"
        print_success "服务文件已删除"
    else
        echo -e "${DIM}   服务文件不存在${NC}"
    fi
    echo ""
    
    # 4. 重新加载 systemd
    print_step "4. 重新加载 systemd 配置"
    systemctl daemon-reload 2>/dev/null
    systemctl reset-failed 2>/dev/null
    print_success "systemd 配置已重载"
    echo ""
    
    # 5. 删除安装目录
    print_step "5. 删除 Mihomo 安装目录"
    if [ -d "$INSTALL_DIR" ]; then
        rm -rf "$INSTALL_DIR"
        print_success "安装目录已删除"
    else
        echo -e "${DIM}   安装目录不存在${NC}"
    fi
    echo ""
    
    print_header "卸载完成"
    
    echo -e "${BOLD}${GREEN}Mihomo 裸核版已彻底卸载${NC}"
    echo ""
    
    echo -e "${BOLD}${WHITE}已清理的项目：${NC}"
    echo -e "  ${DIM}•${NC} Mihomo 系统服务"
    echo -e "  ${DIM}•${NC} 配置文件目录：/etc/Mihomo"
    echo -e "  ${DIM}•${NC} 所有相关数据"
    echo ""
    
    print_separator
    echo -e "${GREEN}卸载完成，感谢您的使用！${NC}"
    echo ""
}

# 查看状态
show_status() {
    clear
    print_banner
    print_header "服务状态"
    
    print_step "服务状态检查..."
    echo ""
    
    # 检查服务状态
    if systemctl is-active mihomo &>/dev/null; then
        echo -e "${GREEN}✓ 服务正在运行${NC}"
        echo ""
        systemctl status mihomo --no-pager -l | head -20
    elif systemctl is-enabled mihomo &>/dev/null; then
        echo -e "${YELLOW}⚠ 服务已启用但未运行${NC}"
    else
        echo -e "${RED}✗ 服务未安装或未启用${NC}"
    fi
    echo ""
    
    # 检查配置文件
    if [ -f "$CONFIG_FILE" ]; then
        echo -e "${GREEN}✓ 配置文件存在${NC}"
        echo -e "  位置: $CONFIG_FILE"
    else
        echo -e "${YELLOW}⚠ 配置文件不存在${NC}"
    fi
    echo ""
    
    # 检查核心文件
    if [ -x "$INSTALL_DIR/mihomo" ]; then
        echo -e "${GREEN}✓ 核心文件存在${NC}"
        echo -e "  位置: $INSTALL_DIR/mihomo"
        if "$INSTALL_DIR/mihomo" -v &>/dev/null; then
            echo -e "  版本: $("$INSTALL_DIR/mihomo" -v)"
        fi
    else
        echo -e "${YELLOW}⚠ 核心文件不存在${NC}"
    fi
    echo ""
}

# 重启服务
restart_service() {
    clear
    print_banner
    print_header "重启服务"
    
    if systemctl is-active mihomo &>/dev/null; then
        print_step "正在重启服务..."
        if systemctl restart mihomo; then
            print_success "服务重启成功"
            echo ""
            systemctl status mihomo --no-pager -l | head -10
        else
            print_error "服务重启失败"
        fi
    else
        print_error "服务未运行"
        echo ""
        echo -e "${YELLOW}是否尝试启动服务？(y/N): ${NC}"
        read -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if systemctl start mihomo; then
                print_success "服务启动成功"
            else
                print_error "服务启动失败"
            fi
        fi
    fi
    echo ""
}

# 查看日志
view_logs() {
    clear
    print_banner
    print_header "查看日志"
    
    if systemctl is-active mihomo &>/dev/null; then
        echo -e "${YELLOW}[提示] 按 Ctrl+C 退出日志查看${NC}"
        echo ""
        journalctl -u mihomo -f
    else
        print_error "服务未运行"
        echo ""
        echo -e "${YELLOW}最近日志：${NC}"
        journalctl -u mihomo --no-pager -n 20
    fi
}

# 主函数
main() {
    # 检查root权限
    check_root
    
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
                ;;
            4)
                restart_service
                ;;
            5)
                view_logs
                ;;
            6)
                echo "再见！"
                exit 0
                ;;
            *)
                print_error "无效的选择，请输入 1-6"
                ;;
        esac
        
        if [ "$choice" != "5" ] && [ "$choice" != "3" ]; then
            echo ""
            echo -e "${YELLOW}按任意键返回主菜单...${NC}"
            read -n 1 -s
        elif [ "$choice" = "5" ]; then
            echo ""
            echo -e "${YELLOW}日志查看结束，按任意键返回主菜单...${NC}"
            read -n 1 -s
        fi
    done
}

# 运行主函数
main "$@"
