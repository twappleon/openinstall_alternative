#!/bin/bash

echo "=========================================="
echo "OpenInstall Flutter 日志收集工具"
echo "=========================================="
echo ""

# 检查设备连接
if ! adb devices | grep -q "device$"; then
    echo "❌ 错误: 未检测到已连接的 Android 设备"
    echo "请确保:"
    echo "1. 设备已通过 USB 连接"
    echo "2. 已启用 USB 调试"
    echo "3. 已授权此计算机"
    exit 1
fi

echo "✅ 检测到设备连接"
echo ""

# 清除旧日志
echo "清除旧日志..."
adb logcat -c

echo ""
echo "=========================================="
echo "开始收集日志..."
echo "请执行以下操作:"
echo "1. 启动应用"
echo "2. 等待应用运行（或闪退）"
echo "3. 按 Ctrl+C 停止日志收集"
echo "=========================================="
echo ""

# 收集日志，过滤关键信息
adb logcat | grep -E "flutter|openinstall|AndroidRuntime|FATAL|Exception|Error|openinstall_flutter" --line-buffered | tee crash_log_$(date +%Y%m%d_%H%M%S).txt

