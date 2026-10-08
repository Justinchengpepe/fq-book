#!/bin/bash

# 《这本书能让你连接互联网》本地部署脚本
# 功能：安装锁定版本的依赖并启动本地预览服务器

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 打印欢迎信息
print_banner() {
    echo -e "${GREEN}"
    echo "======================================"
    echo "  《这本书能让你连接互联网》"
    echo "  本地部署工具"
    echo "======================================"
    echo -e "${NC}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 检查 Node.js 环境
check_node() {
    print_info "检查 Node.js 环境..."
    if ! command_exists node; then
        print_error "未检测到 Node.js，请先安装 Node.js"
        print_info "下载地址: https://nodejs.org/zh-cn"
        exit 1
    fi
    
    NODE_VERSION=$(node -v)
    print_success "Node.js 版本: $NODE_VERSION"
}

# 检查 npm 环境
check_npm() {
    print_info "检查 npm 环境..."
    if ! command_exists npm; then
        print_error "未检测到 npm"
        exit 1
    fi
    
    NPM_VERSION=$(npm -v)
    print_success "npm 版本: $NPM_VERSION"
}

# 检查 Python 环境（用于零依赖静态服务器）
check_python() {
    print_info "检查 Python 环境..."
    if ! command_exists python3; then
        print_error "未检测到 Python 3"
        exit 1
    fi
    print_success "Python 版本: $(python3 --version)"
}

# 安装项目依赖
install_dependencies() {
    print_info "安装项目依赖..."
    npm ci
    print_success "项目依赖安装完成"
}

# 启动 docsify 服务器
start_server() {
    print_info "正在启动本地服务器..."
    echo ""
    print_success "服务器启动成功！"
    print_info "访问地址: ${GREEN}http://localhost:3000${NC}"
    print_info "按 ${YELLOW}Ctrl+C${NC} 停止服务器"
    echo ""
    
    # 启动服务器
    npm run serve
}

# 主流程
main() {
    print_banner
    
    # 检查环境
    check_node
    check_npm
    check_python
    
    # 安装依赖
    install_dependencies
    
    # 启动服务器
    start_server
}

# 执行主流程
main
