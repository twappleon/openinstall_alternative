#!/bin/bash

# 设置 adb 路径
export PATH=$PATH:$HOME/Library/Android/sdk/platform-tools

echo "=========================================="
echo "收集崩溃日志"
echo "=========================================="
echo ""

# 检查 adb
if ! command -v adb &> /dev/null; then
    echo "❌ 错误: adb 未找到"
    echo "请确保 Android SDK 已安装"
    exit 1
fi

# 检查设备
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

# 收集日志
LOG_FILE="crash_log_$(date +%Y%m%d_%H%M%S).txt"
adb logcat | tee "$LOG_FILE" | grep -E "flutter|openinstall|AndroidRuntime|FATAL|Exception|Error|openinstall_flutter|com.openinstall" --line-buffered

echo ""
echo "日志已保存到: $LOG_FILE"

