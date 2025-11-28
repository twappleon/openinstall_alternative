#!/bin/bash

# OpenInstall 发布脚本
# 用于发布 OpenInstall-flutter 和 OpenInstall-web

set -e

echo "=== OpenInstall 发布流程 ==="
echo ""

# 1. 检查 Flutter 环境
echo "1. 检查 Flutter 环境..."
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter 未安装，请先安装 Flutter"
    exit 1
fi
echo "✅ Flutter 环境正常"
echo ""

# 2. 构建 Flutter APK
echo "2. 构建 Flutter APK..."
cd openinstall-flutter
flutter pub get
cd example
flutter build apk --release
echo "✅ APK 构建完成"
echo ""

# 3. 复制 APK 到 web 目录
echo "3. 复制 APK 到 web 目录..."
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" ../../openinstall-web/downloads/app.apk
    echo "✅ APK 已复制到 openinstall-web/downloads/app.apk"
    ls -lh ../../openinstall-web/downloads/app.apk
else
    echo "❌ APK 文件不存在: $APK_PATH"
    exit 1
fi
echo ""

# 4. 提交代码到 Git
echo "4. 提交代码到 Git..."
cd ../../..
git add -A
git commit -m "发布 OpenInstall-flutter 和 OpenInstall-web

- 后端添加字段值标准化，确保 fingerprintId 一致性
- Web 端使用 crypto-js 计算 MD5
- Flutter 端使用 crypto 包计算 MD5
- 统一所有端的算法和字段格式" || echo "⚠️  没有更改需要提交"
git push origin main || echo "⚠️  Git 推送失败，请手动推送"
echo ""

# 5. 部署到 Vercel
echo "5. 部署到 Vercel..."
cd openinstall-web
npx vercel --prod --yes || echo "⚠️  Vercel 部署失败，请手动部署"
echo ""

echo "=== 发布完成 ==="
echo ""
echo "🌐 访问地址: https://openinstall-web.vercel.app"
echo "📋 测试链接: https://openinstall-web.vercel.app/?inviteCode=ABC123"

