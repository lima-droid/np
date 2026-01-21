#!/usr/bin/env bash

SCRIPT_VERSION='2.1.0-offline'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

# NodePassDash 配置
NPD_LOCAL_TARGZ="/root/np/NodePassDash_Linux_x86_64.tar.gz"
NPD_BINARY_NAME="nodepassdash"
NPD_INSTALL_DIR="/opt/nodepassdash"
NPD_USER_NAME="nodepass"
NPD_SERVICE_NAME="nodepassdash"
NPD_DEFAULT_PORT="3000"

# 通用函数
info() { echo -e "${GREEN}$*${NC}"; }
warning() { echo -e "${YELLOW}$*${NC}"; }
error() { echo -e "${RED}$*${NC}" && exit 1; }
hint() { echo -e "${BLUE}$*${NC}"; }
reading() { echo -n "$(info "$1")"; read "$2"; }

check_root() { [[ $(id -u) -ne 0 ]] && error "必须以 root 运行"; }

# ========== NodePassDash 相关函数 ==========
check_npd_install() {
  systemctl is-active --quiet $NPD_SERVICE_NAME 2>/dev/null && return 0
  [[ -f "$NPD_INSTALL_DIR/bin/$NPD_BINARY_NAME" ]] && return 1
  return 2
}

install_nodepassdash() {
  check_npd_install; [[ $? -ne 2 ]] && warning "NodePassDash 已安装" && return
  [[ ! -f "$NPD_LOCAL_TARGZ" ]] && error "未找到 $NPD_LOCAL_TARGZ"

  echo
  echo "============================="
  echo -e "${BLUE}NodePassDash 配置${NC}"
  echo "============================="
  echo

  read -p "监听端口 [默认 $NPD_DEFAULT_PORT]: " USER_PORT
  [[ -z "$USER_PORT" ]] && USER_PORT="$NPD_DEFAULT_PORT"

  # 询问IP或域名
  read -p "访问IP或域名（回车自动检测）: " DASH_IP
  [[ -z "$DASH_IP" ]] && DASH_IP=$(curl -s --max-time 5 ipv4.ip.sb || echo "localhost")

  read -p "启用 HTTPS? [y/N]: " https
  if [[ "$https" =~ ^[Yy]$ ]]; then
    ENABLE_HTTPS="true"
    read -p "证书路径 (.crt/.pem): " CERT_PATH
    read -p "私钥路径 (.key): " KEY_PATH
  else
    ENABLE_HTTPS="false"
  fi

  echo
  read -p "确认安装？[Y/n]: " ok
  [[ "$ok" =~ ^[Nn]$ ]] && echo "安装已取消" && return

  # 验证
  [[ ! "$USER_PORT" =~ ^[0-9]+$ || "$USER_PORT" -lt 1 || "$USER_PORT" -gt 65535 ]] && error "端口无效"
  if [[ "$ENABLE_HTTPS" == "true" ]]; then
    [[ ! -f "$CERT_PATH" ]] && error "证书不存在"
    [[ ! -f "$KEY_PATH" ]] && error "私钥不存在"
  fi

  info "开始安装 NodePassDash..."

  # 解压和安装
  temp_dir="/tmp/npdash_tmp"
  rm -rf "$temp_dir"
  mkdir "$temp_dir"
  tar -xzf "$NPD_LOCAL_TARGZ" -C "$temp_dir" >/dev/null 2>&1

  binary=$(find "$temp_dir" -name "$NPD_BINARY_NAME" -type f | head -1)
  [[ -z "$binary" ]] && error "未找到 $NPD_BINARY_NAME"

  mkdir -p "$NPD_INSTALL_DIR"/{bin,db,logs,certs}

  if ! id "$NPD_USER_NAME" &>/dev/null; then
    useradd --system --home "$NPD_INSTALL_DIR" --shell /bin/false "$NPD_USER_NAME" >/dev/null 2>&1
  fi

  cp "$binary" "$NPD_INSTALL_DIR/bin/$NPD_BINARY_NAME"
  chmod 755 "$NPD_INSTALL_DIR/bin/$NPD_BINARY_NAME"
  chown root:root "$NPD_INSTALL_DIR/bin/$NPD_BINARY_NAME"
  ln -sf "$NPD_INSTALL_DIR/bin/$NPD_BINARY_NAME" /usr/local/bin/$NPD_BINARY_NAME

  chown -R "$NPD_USER_NAME:$NPD_USER_NAME" "$NPD_INSTALL_DIR"/{db,logs,certs}
  chown "$NPD_USER_NAME:$NPD_USER_NAME" "$NPD_INSTALL_DIR"

  config="$NPD_INSTALL_DIR/config.env"
  cat > "$config" << CFG
PORT=$USER_PORT
ENABLE_HTTPS=$ENABLE_HTTPS
DB_PATH=$NPD_INSTALL_DIR/db/database.db
CFG

  if [[ "$ENABLE_HTTPS" == "true" ]]; then
    cp "$CERT_PATH" "$NPD_INSTALL_DIR/certs/server.crt"
    cp "$KEY_PATH" "$NPD_INSTALL_DIR/certs/server.key"
    chown "$NPD_USER_NAME:$NPD_USER_NAME" "$NPD_INSTALL_DIR/certs/"*
    chmod 600 "$NPD_INSTALL_DIR/certs/server.key"
    chmod 644 "$NPD_INSTALL_DIR/certs/server.crt"
    cat >> "$config" << CFG
CERT_PATH=$NPD_INSTALL_DIR/certs/server.crt
KEY_PATH=$NPD_INSTALL_DIR/certs/server.key
CFG
  fi

  exec_start="$NPD_INSTALL_DIR/bin/$NPD_BINARY_NAME --port $USER_PORT"
  [[ "$ENABLE_HTTPS" == "true" ]] && exec_start="$exec_start --cert $NPD_INSTALL_DIR/certs/server.crt --key $NPD_INSTALL_DIR/certs/server.key"

  cat > /etc/systemd/system/$NPD_SERVICE_NAME.service << SVC
[Unit]
Description=NodePassDash
After=network.target

[Service]
User=$NPD_USER_NAME
Group=$NPD_USER_NAME
WorkingDirectory=$NPD_INSTALL_DIR
ExecStart=$exec_start
Restart=always
RestartSec=5
EnvironmentFile=-$config

[Install]
WantedBy=multi-user.target
SVC

  systemctl daemon-reload >/dev/null 2>&1
  systemctl enable $NPD_SERVICE_NAME >/dev/null 2>&1
  systemctl start $NPD_SERVICE_NAME >/dev/null 2>&1

  rm -rf "$temp_dir"

  proto="http"
  [[ "$ENABLE_HTTPS" == "true" ]] && proto="https"

  echo
  echo "=========================================="
  info "NodePassDash 安装成功！"
  echo "=========================================="
  echo "访问地址: $proto://$DASH_IP:$USER_PORT"
  echo "本地访问: $proto://localhost:$USER_PORT"
  echo
  echo "默认初始用户名:nodepass 密码:Np123456"
  echo "=========================================="
}

show_npd_info() {
  check_npd_install
  case $? in
    0) status="运行中" ;;
    1) status="已安装但未运行" ;;
    2) warning "NodePassDash 未安装" && return ;;
  esac
  
  # 获取端口信息
  local port="$NPD_DEFAULT_PORT"
  if [[ -f "$NPD_INSTALL_DIR/config.env" ]]; then
    source "$NPD_INSTALL_DIR/config.env" 2>/dev/null
    port="${PORT:-$NPD_DEFAULT_PORT}"
  fi
  
  info "NodePassDash $status"
  info "安装目录: $NPD_INSTALL_DIR"
  info "监听端口: $port"
}

uninstall_nodepassdash() {
  systemctl stop $NPD_SERVICE_NAME 2>/dev/null
  systemctl disable $NPD_SERVICE_NAME 2>/dev/null
  rm -f /etc/systemd/system/$NPD_SERVICE_NAME.service
  systemctl daemon-reload 2>/dev/null
  rm -rf "$NPD_INSTALL_DIR"
  rm -f /usr/local/bin/$NPD_BINARY_NAME
  info "NodePassDash 已卸载"
}

# ========== 主菜单 ==========
show_header() {
  clear
  echo "
╔═══════════════════════════════════════╗
║       NodePassDash 离线安装管理器     ║
║         Version $SCRIPT_VERSION         ║
╚═══════════════════════════════════════╝
"
}

main_menu() {
  show_header
  echo "NodePassDash Web面板管理"
  echo "------------------------"

  check_npd_install; local s=$?
  [[ $s -ne 2 ]] && show_npd_info

  echo "------------------------"
  if [[ $s -eq 2 ]]; then
    hint "1. 安装 NodePassDash"
  else
    hint "1. 查看状态"
    hint "2. 重启服务"
    hint "3. 停止服务"
    hint "4. 卸载"
  fi
  hint "0. 退出"
  echo "------------------------"
  
  reading "请选择: " ch
  case "$ch" in
    1) [[ $s -eq 2 ]] && install_nodepassdash || show_npd_info ;;
    2) [[ $s -ne 2 ]] && systemctl restart $NPD_SERVICE_NAME && info "已重启" ;;
    3) [[ $s -ne 2 ]] && systemctl stop $NPD_SERVICE_NAME && info "已停止" ;;
    4) [[ $s -ne 2 ]] && uninstall_nodepassdash ;;
    0) exit 0 ;;
    *) main_menu ;;
  esac
  
  echo
  read -p "按回车键继续..."
  main_menu
}

# ========== 命令行参数处理 ==========
main() {
  check_root
  
  case "$1" in
    -i|--install) install_nodepassdash ;;
    -u|--uninstall) uninstall_nodepassdash ;;
    -s|--status) show_npd_info ;;
    -h|--help)
      echo "用法: $0 [选项]"
      echo "选项:"
      echo "  -i, --install          安装 NodePassDash"
      echo "  -u, --uninstall        卸载 NodePassDash"
      echo "  -s, --status           查看 NodePassDash 状态"
      echo "  无参数                 进入交互式菜单"
      ;;
    *) main_menu ;;
  esac
}

main "$@"
