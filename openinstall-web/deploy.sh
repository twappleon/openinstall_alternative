#!/bin/bash

# OpenInstall Web 部署脚本

echo "🚀 OpenInstall Web 部署工具"
echo "================================"
echo ""
echo "请选择部署方式："
echo "1. Vercel (推荐)"
echo "2. Netlify"
echo "3. 查看部署说明"
echo ""
read -p "请输入选项 (1-3): " choice

case $choice in
  1)
    echo ""
    echo "📦 部署到 Vercel..."
    echo "首次使用需要登录，请在浏览器中完成登录"
    echo ""
    npx vercel login
    npx vercel --prod
    ;;
  2)
    echo ""
    echo "📦 部署到 Netlify..."
    echo "首次使用需要登录，请在浏览器中完成登录"
    echo ""
    npx netlify-cli login
    npx netlify-cli deploy --prod --dir .
    ;;
  3)
    echo ""
    cat README.md
    ;;
  *)
    echo "无效选项"
    exit 1
    ;;
esac

