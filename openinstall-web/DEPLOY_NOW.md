# 🚀 立即部署指南

## ✅ APK 已准备好

- **文件位置**：`downloads/app.apk`
- **文件大小**：17MB
- **修复内容**：已添加 MainActivity.kt，解决启动崩溃问题
- **状态**：✅ 已修复，等待部署

## 🎯 最快部署方式

### 方法 1: Vercel 网站（最简单，推荐）

1. **打开浏览器**，访问：https://vercel.com
2. **登录**你的 Vercel 账户
3. **找到项目**：在 Dashboard 中找到 `openinstall-web`
4. **重新部署**：
   - 点击项目进入详情页
   - 点击 "Deployments" 标签
   - 找到最新的部署记录
   - 点击右侧的 "..." 菜单
   - 选择 "Redeploy"
   - 或者直接点击 "Redeploy" 按钮

**优点**：无需命令行，最简单

### 方法 2: 完成 CLI 登录后部署

如果你偏好使用命令行：

```bash
# 1. 登录（会在浏览器中打开）
cd openinstall-web
npx vercel login

# 2. 在浏览器中完成登录后，回到终端按 Enter

# 3. 部署
npx vercel --prod
```

## 📋 部署后验证

部署完成后（通常 1-2 分钟）：

1. **访问网页**：
   https://openinstall-web.vercel.app/?inviteCode=ABC123

2. **测试下载**：
   - 点击"立即下载"按钮
   - 或直接访问：https://openinstall-web.vercel.app/downloads/app.apk

3. **安装测试**：
   ```bash
   # 完全卸载旧版本
   adb uninstall com.openinstall.flutter.example
   
   # 安装新版本 APK
   # 应用应该能正常启动，不再闪退！
   ```

## 🔍 验证新版本

下载 APK 后，可以通过以下方式验证：

```bash
# 检查文件大小（应该是 17MB）
ls -lh downloads/app.apk

# 检查 MD5（应该是 c639709afbd103aef0914b58a9089fef）
md5 downloads/app.apk
```

## ⚠️ 重要提示

1. **清除浏览器缓存**：
   - 如果下载的仍然是旧版本，清除浏览器缓存
   - 或使用无痕模式访问

2. **完全卸载旧版本**：
   - 必须完全卸载后再安装新版本
   - 使用：`adb uninstall com.openinstall.flutter.example`

3. **等待 CDN 更新**：
   - 部署后可能需要几分钟让 CDN 更新
   - 如果立即下载还是旧版本，等待 2-3 分钟再试

## 📝 修复内容回顾

本次修复解决了应用启动时立即崩溃的问题：

**问题**：AndroidManifest.xml 引用了 `.MainActivity`，但文件不存在

**解决**：
- ✅ 创建了 `MainActivity.kt` 文件
- ✅ 位置：`openinstall-flutter/example/android/app/src/main/kotlin/com/openinstall/flutter/example/MainActivity.kt`
- ✅ 内容：标准的 FlutterActivity 实现

## 🎉 预期结果

部署新 APK 后：
- ✅ 应用能正常启动
- ✅ 不再出现 "keeps stopping" 错误
- ✅ 显示正常的 UI 界面

---

**现在请选择一种方式部署，部署完成后测试新版本！**

