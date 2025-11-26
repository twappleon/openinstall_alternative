# OpenInstall 实现方案

设备指纹匹配 + 延迟深度链接完整实现

## 📁 项目结构

```
.
├── openinstall-backend/          # Spring Boot 后端服务
│   ├── src/main/java/com/openinstall/
│   │   ├── OpenInstallApplication.java
│   │   ├── controller/          # API 控制器
│   │   ├── service/             # 业务逻辑服务
│   │   ├── model/               # 数据模型
│   │   ├── dto/                 # 数据传输对象
│   │   └── config/             # 配置类
│   ├── src/main/resources/
│   │   └── application.yml      # 配置文件
│   └── pom.xml                  # Maven 依赖
│
├── openinstall-web/             # Web 前端
│   ├── index.html              # 下载页面
│   └── openinstall.js          # Web SDK
│
├── openinstall-flutter/          # Flutter SDK（推荐）
│   ├── lib/                      # Dart 代码
│   ├── android/                  # Android 原生代码
│   ├── ios/                      # iOS 原生代码
│   ├── example/                  # 使用示例
│   └── pubspec.yaml             # Flutter 依赖配置
│
├── openinstall-ios/             # iOS 原生 SDK（可选）
│   ├── DeviceFingerprint.swift
│   ├── TrackingAPI.swift
│   ├── AppDelegate.swift
│   └── Info.plist.example
│
└── openinstall-android/         # Android 原生 SDK（可选）
    ├── DeviceFingerprint.kt
    ├── TrackingAPI.kt
    ├── MainActivity.kt
    ├── AndroidManifest.xml.example
    └── build.gradle.example
```

## 🚀 快速开始

### 1. 后端服务启动

#### 前置要求
- JDK 17+
- Maven 3.6+
- Redis 6.0+

#### 启动步骤

```bash
# 进入后端目录
cd openinstall-backend

# 安装依赖
mvn clean install

# 启动 Redis（如果未运行）
redis-server

# 启动 Spring Boot 应用
mvn spring-boot:run

# 或者使用 IDE 运行 OpenInstallApplication
```

服务将在 `http://localhost:8080` 启动

#### 配置说明

编辑 `src/main/resources/application.yml`:

```yaml
spring:
  data:
    redis:
      host: localhost      # Redis 主机
      port: 6379          # Redis 端口
      password:           # Redis 密码（如有）

tracking:
  expire-hours: 24        # 数据过期时间（小时）
  similarity-threshold: 0.8  # 模糊匹配相似度阈值
  max-match-count: 3      # 最大匹配次数
```

### 2. Web 前端部署

#### 修改配置

编辑 `openinstall-web/index.html` 中的配置：

```javascript
const CONFIG = {
    apiBaseUrl: 'http://your-server.com/api',  // 后端 API 地址
    appScheme: 'yourapp://',                   // App URL Scheme
    universalLink: 'https://yourdomain.com',   // Universal Link 域名
    iosAppStoreUrl: 'https://apps.apple.com/app/your-app',
    androidDownloadUrl: 'https://your-server.com/download/app.apk'
};
```

#### 部署

将 `openinstall-web` 目录部署到 Web 服务器（Nginx、Apache 等）

### 3. Flutter 集成（推荐）

#### 步骤 1: 添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  openinstall_flutter:
    path: ../openinstall-flutter
```

然后运行：

```bash
flutter pub get
```

#### 步骤 2: 初始化 SDK

在 `main.dart` 中：

```dart
import 'package:openinstall_flutter/openinstall_flutter.dart';

void main() {
  // 初始化 OpenInstall
  OpenInstall().init(baseUrl: 'http://your-server.com/api');
  
  runApp(MyApp());
}
```

#### 步骤 3: 获取安装参数

```dart
final params = await OpenInstall().getInstallParams();

if (params != null) {
  // 处理邀请码
  if (params.inviteCode != null) {
    print('邀请码: ${params.inviteCode}');
  }
}
```

#### 步骤 4: 配置平台

**Android**: 在 `android/app/src/main/AndroidManifest.xml` 中添加 URL Scheme 和 App Link

**iOS**: 在 `ios/Runner/Info.plist` 中添加 URL Scheme 和 Universal Link

详细配置请参考 `openinstall-flutter/README.md`

### 4. iOS 原生集成（可选）

如果使用原生 iOS 开发，参考 `openinstall-ios/` 目录中的代码。

#### 步骤 1: 添加文件

将以下文件添加到你的 iOS 项目：
- `DeviceFingerprint.swift`
- `TrackingAPI.swift`

#### 步骤 2: 修改 AppDelegate

参考 `AppDelegate.swift` 示例，在 `didFinishLaunchingWithOptions` 中调用：

```swift
let trackingAPI = TrackingAPI(baseURL: "http://your-server.com/api")
trackingAPI.getInstallParams { params in
    // 处理参数
}
```

#### 步骤 3: 配置 URL Scheme

在 `Info.plist` 中添加：

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>
```

### 5. Android 原生集成（可选）

如果使用原生 Android 开发，参考 `openinstall-android/` 目录中的代码。

#### 步骤 1: 添加依赖

在 `build.gradle` 中添加：

```gradle
dependencies {
    implementation 'org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3'
    implementation 'com.squareup.okhttp3:okhttp:4.12.0'
}
```

#### 步骤 2: 添加文件

将以下文件添加到你的 Android 项目：
- `DeviceFingerprint.kt`
- `TrackingAPI.kt`

#### 步骤 3: 修改 MainActivity

参考 `MainActivity.kt` 示例，在 `onCreate` 中调用：

```kotlin
lifecycleScope.launch {
    val params = TrackingAPI.getInstallParams(this@MainActivity)
    // 处理参数
}
```

#### 步骤 4: 配置 URL Scheme

在 `AndroidManifest.xml` 中添加：

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="yourapp" />
</intent-filter>
```

## 📡 API 接口

### 1. 保存追踪数据

**接口**: `POST /api/tracking/save`

**请求体**:
```json
{
    "fingerprintId": "abc123",
    "fingerprint": {
        "userAgent": "...",
        "screenWidth": 375,
        "screenHeight": 812,
        ...
    },
    "params": {
        "inviteCode": "ABC123",
        "channelId": "channel1"
    },
    "timestamp": 1234567890
}
```

**响应**:
```json
{
    "success": true,
    "message": "操作成功",
    "data": {
        "fingerprintId": "abc123"
    }
}
```

### 2. 获取追踪数据

**接口**: `POST /api/tracking/get`

**请求体**:
```json
{
    "fingerprintId": "abc123",
    "fingerprint": {
        "userAgent": "...",
        "screenWidth": 375,
        "screenHeight": 812,
        ...
    }
}
```

**响应**:
```json
{
    "success": true,
    "message": "操作成功",
    "data": {
        "params": {
            "inviteCode": "ABC123",
            "channelId": "channel1"
        },
        "matched": true,
        "fingerprintId": "abc123"
    }
}
```

## 🔄 工作流程

```
1. 用户点击分享链接
   ↓
2. Web 页面收集设备指纹 + 参数 → 上传到服务器
   ↓
3. 用户点击下载按钮 → 尝试拉起 App（失败）→ 跳转应用商店
   ↓
4. 用户安装并打开 App
   ↓
5. App 收集设备指纹 → 请求服务器匹配
   ↓
6. 服务器通过设备指纹匹配 → 返回参数给 App
   ↓
7. App 自动处理参数（填充邀请码、建立关系等）
```

## 🎯 核心特性

### 1. 设备指纹技术
- 多维度特征收集（屏幕、时区、Canvas、WebGL等）
- 高精度匹配算法
- 支持模糊匹配（相似度阈值 80%）

### 2. 延迟深度链接
- 跨安装参数传递
- 无需配置 Universal Link / App Link
- 适用于任何下载场景

### 3. 高可用性
- Redis 存储，支持分布式部署
- 自动过期清理
- 防重复使用机制

## ⚙️ 配置说明

### 后端配置

| 配置项 | 说明 | 默认值 |
|--------|------|--------|
| `tracking.expire-hours` | 数据过期时间（小时） | 24 |
| `tracking.similarity-threshold` | 模糊匹配相似度阈值 | 0.8 |
| `tracking.max-match-count` | 最大匹配次数 | 3 |

### Web 配置

| 配置项 | 说明 |
|--------|------|
| `apiBaseUrl` | 后端 API 地址 |
| `appScheme` | App URL Scheme |
| `universalLink` | Universal Link 域名 |
| `iosAppStoreUrl` | iOS App Store 链接 |
| `androidDownloadUrl` | Android APK 下载链接 |

## 🔒 隐私合规

⚠️ **重要提示**：

1. **隐私政策**：必须在隐私政策中说明收集设备信息
2. **敏感信息**：不收集 IDFA、IMEI 等敏感标识
3. **合规要求**：符合 GDPR、CCPA 等隐私法规
4. **用户同意**：建议在收集前获取用户同意

## 🐛 故障排查

### 问题 1: 无法匹配到参数

**可能原因**：
- 设备指纹差异过大
- 数据已过期
- Redis 连接失败

**解决方案**：
- 检查相似度阈值设置
- 确认数据未过期
- 检查 Redis 连接

### 问题 2: 匹配率低

**可能原因**：
- 指纹特征不足
- 相似度阈值过高

**解决方案**：
- 增加更多指纹特征
- 适当降低相似度阈值（建议不低于 0.7）

### 问题 3: Redis 连接失败

**解决方案**：
```bash
# 检查 Redis 是否运行
redis-cli ping

# 检查配置
cat src/main/resources/application.yml
```

## 📊 性能优化

### 生产环境建议

1. **使用 Redis 集群**：提高可用性和性能
2. **添加数据库持久化**：防止数据丢失
3. **实现分布式部署**：支持高并发
4. **添加监控告警**：及时发现问题

### 代码优化

1. **异步处理**：使用异步方式处理匹配逻辑
2. **缓存优化**：合理设置 Redis 过期时间
3. **索引优化**：优化模糊匹配索引策略

## 📝 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📧 联系方式

如有问题，请提交 Issue 或联系开发团队。

