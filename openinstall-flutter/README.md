# OpenInstall Flutter SDK

设备指纹匹配 + 延迟深度链接 Flutter 插件

## 📦 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  openinstall_flutter:
    git:
      url: https://github.com/yourusername/openinstall-flutter.git
    # 或者使用本地路径
    # path: ../openinstall-flutter
```

然后运行：

```bash
flutter pub get
```

## 🚀 快速开始

### 1. 初始化 SDK

在 `main.dart` 中初始化：

```dart
import 'package:openinstall_flutter/openinstall_flutter.dart';

void main() {
  runApp(MyApp());
  
  // 初始化 OpenInstall
  OpenInstall().init(baseUrl: 'http://your-server.com/api');
}
```

### 2. 获取安装参数

```dart
// 在 App 启动时获取安装参数
final params = await OpenInstall().getInstallParams();

if (params != null) {
  // 处理邀请码
  if (params.inviteCode != null) {
    print('邀请码: ${params.inviteCode}');
    // 建立邀请关系
  }
  
  // 处理渠道ID
  if (params.channelId != null) {
    print('渠道ID: ${params.channelId}');
    // 上报渠道信息
  }
  
  // 处理用户ID
  if (params.userId != null) {
    print('用户ID: ${params.userId}');
    // 跳转到用户页面
  }
}
```

### 3. 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:openinstall_flutter/openinstall_flutter.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TrackingParams? _params;

  @override
  void initState() {
    super.initState();
    _initOpenInstall();
  }

  void _initOpenInstall() {
    // 初始化 SDK
    OpenInstall().init(baseUrl: 'http://your-server.com/api');
    
    // 获取安装参数
    _getInstallParams();
  }

  Future<void> _getInstallParams() async {
    final params = await OpenInstall().getInstallParams();
    
    setState(() {
      _params = params;
    });

    if (params != null) {
      // 处理参数
      _handleParams(params);
    }
  }

  void _handleParams(TrackingParams params) {
    if (params.inviteCode != null) {
      // 处理邀请码
      _handleInviteCode(params.inviteCode!);
    }
  }

  void _handleInviteCode(String code) {
    // 保存邀请码
    // 建立邀请关系（调用你的业务 API）
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('OpenInstall Example')),
        body: Center(
          child: _params != null
              ? Text('邀请码: ${_params!.inviteCode ?? "无"}')
              : Text('未匹配到参数'),
        ),
      ),
    );
  }
}
```

## 📱 平台配置

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<!-- URL Scheme -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="yourapp" />
</intent-filter>

<!-- App Link -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="yourdomain.com"
        android:pathPrefix="/open" />
</intent-filter>
```

### iOS 配置

在 `ios/Runner/Info.plist` 中添加：

```xml
<!-- URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>yourapp</string>
        </array>
    </dict>
</array>

<!-- Universal Link -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:yourdomain.com</string>
</array>
```

## 🔧 API 文档

### OpenInstall 类

#### init()

初始化 SDK

```dart
OpenInstall().init(baseUrl: 'http://your-server.com/api');
```

**参数**:
- `baseUrl`: 后端 API 地址（可选，默认为 `http://localhost:8080/api`）

#### getInstallParams()

获取安装参数

```dart
Future<TrackingParams?> getInstallParams()
```

**返回**: `TrackingParams?` - 追踪参数，如果匹配失败返回 `null`

#### getCachedParams()

获取缓存的参数

```dart
TrackingParams? getCachedParams()
```

#### clearCache()

清除缓存的参数

```dart
void clearCache()
```

### TrackingParams 类

追踪参数模型

**属性**:
- `inviteCode`: 邀请码
- `channelId`: 渠道ID
- `userId`: 用户ID
- `custom`: 自定义参数
- `extra`: 额外参数

## 🔄 工作流程

```
1. 用户点击分享链接
   ↓
2. Web 页面收集设备指纹 + 参数 → 上传到服务器
   ↓
3. 用户安装 App → App 收集设备指纹 → 请求服务器匹配
   ↓
4. 服务器通过设备指纹匹配 → 返回参数给 App
   ↓
5. App 自动处理参数（填充邀请码、建立关系等）
```

## 📝 注意事项

1. **初始化时机**: 建议在 `main()` 函数中尽早初始化
2. **网络权限**: 确保 Android 和 iOS 都已配置网络权限
3. **后端地址**: 生产环境请修改为实际的后端 API 地址
4. **隐私合规**: 必须在隐私政策中说明收集设备信息

## 🐛 故障排查

### 问题 1: 无法匹配到参数

**可能原因**:
- 设备指纹差异过大
- 数据已过期
- 后端服务未启动

**解决方案**:
- 检查后端服务是否正常运行
- 确认数据未过期（默认 24 小时）
- 检查网络连接

### 问题 2: 初始化失败

**解决方案**:
- 检查 `baseUrl` 是否正确
- 确认网络权限已配置
- 查看日志输出

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！



