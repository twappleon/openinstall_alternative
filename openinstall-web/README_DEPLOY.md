# APK 更新部署说明

## 📦 当前状态

✅ **APK 已修复并准备部署**
- 文件：`downloads/app.apk`
- 大小：17MB
- MD5：`c639709afbd103aef0914b58a9089fef`
- 修复：已添加 MainActivity.kt，解决启动崩溃问题

## 🚀 立即部署

### 最简单的方法：

```bash
cd openinstall-web
npx vercel --prod
```

如果提示需要登录：
```bash
npx vercel login
npx vercel --prod
```

## ✅ 部署后验证

1. **访问网页**：https://openinstall-web.vercel.app/?inviteCode=ABC123
2. **点击"立即下载"**
3. **完全卸载旧版本**：
   ```bash
   adb uninstall com.openinstall.flutter.example
   ```
4. **安装新版本**
5. **测试**：应用应该能正常启动，不再闪退

## 🔍 如果网页上的 APK 仍然闪退

可能的原因：
1. **缓存问题**：浏览器可能缓存了旧版本
   - 解决方法：清除浏览器缓存，或使用无痕模式
   - 或直接访问：https://openinstall-web.vercel.app/downloads/app.apk

2. **未完全卸载旧版本**：
   ```bash
   adb uninstall com.openinstall.flutter.example
   adb shell pm clear com.openinstall.flutter.example
   ```

3. **下载的不是最新版本**：
   - 检查文件大小（应该是 17MB）
   - 检查下载时间

## 📝 修复内容

本次修复解决了应用启动时立即崩溃的问题：

**问题**：AndroidManifest.xml 引用了 `.MainActivity`，但文件不存在

**解决**：创建了 `MainActivity.kt` 文件
- 位置：`openinstall-flutter/example/android/app/src/main/kotlin/com/openinstall/flutter/example/MainActivity.kt`
- 内容：标准的 FlutterActivity 实现

## 🛠️ 手动验证 APK

如果怀疑下载的 APK 不是最新版本：

```bash
# 检查本地 APK
md5 openinstall-flutter/example/build/app/outputs/flutter-apk/app-release.apk

# 应该输出：c639709afbd103aef0914b58a9089fef
```

## 📞 需要帮助？

如果部署后仍然有问题：
1. 确认已完全卸载旧版本
2. 使用 `get_crash_log.sh` 收集日志
3. 检查日志中的错误信息

