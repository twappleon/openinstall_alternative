#!/bin/bash

echo "部署 OpenInstall Web 到 Vercel"
echo "================================"
echo ""

# 检查文件
if [ ! -f "downloads/app.apk" ]; then
    echo "❌ 错误: downloads/app.apk 不存在"
    exit 1
fi

echo "✅ APK 文件存在: $(ls -lh downloads/app.apk | awk '{print $5}')"
echo ""

# 尝试部署
echo "开始部署..."
npx vercel --prod --yes

echo ""
echo "部署完成！"
echo "访问: https://openinstall-web.vercel.app/"
