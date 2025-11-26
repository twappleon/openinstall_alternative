import 'package:flutter/material.dart';
import 'package:openinstall_flutter/openinstall_flutter.dart';
import 'package:logger/logger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Logger _logger = Logger();
  TrackingParams? _params;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initOpenInstall();
  }

  /// 初始化 OpenInstall
  void _initOpenInstall() {
    // 初始化 SDK
    OpenInstall().init(baseUrl: 'https://openinstall-backend.zeabur.app/api');
    
    // 获取安装参数
    _getInstallParams();
  }

  /// 获取安装参数
  Future<void> _getInstallParams() async {
    setState(() {
      _loading = true;
    });

    try {
      final params = await OpenInstall().getInstallParams();
      
      setState(() {
        _params = params;
        _loading = false;
      });

      if (params != null) {
        _logger.i('✅ 获取到安装参数: $params');
        _handleParams(params);
      } else {
        _logger.w('❌ 未匹配到安装参数');
      }
    } catch (e) {
      _logger.e('获取安装参数失败: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  /// 处理参数
  void _handleParams(TrackingParams params) {
    // 处理邀请码
    if (params.inviteCode != null) {
      _logger.i('📝 邀请码: ${params.inviteCode}');
      _handleInviteCode(params.inviteCode!);
    }

    // 处理渠道ID
    if (params.channelId != null) {
      _logger.i('📊 渠道ID: ${params.channelId}');
      _handleChannelId(params.channelId!);
    }

    // 处理用户ID
    if (params.userId != null) {
      _logger.i('👤 用户ID: ${params.userId}');
      _handleUserId(params.userId!);
    }
  }

  /// 处理邀请码
  void _handleInviteCode(String code) {
    // 保存邀请码
    // 建立邀请关系（调用你的业务 API）
    // YourAPI.establishInviteRelation(code: code);
  }

  /// 处理渠道ID
  void _handleChannelId(String channelId) {
    // 保存渠道ID
    // 上报渠道信息（调用你的业务 API）
    // YourAPI.reportChannel(channelId: channelId);
  }

  /// 处理用户ID
  void _handleUserId(String userId) {
    // 保存用户ID
    // 跳转到用户页面等业务逻辑
    // navigateToUserPage(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenInstall Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('OpenInstall Flutter SDK'),
        ),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _params != null
                  ? _buildParamsView()
                  : _buildNoParamsView(),
        ),
      ),
    );
  }

  /// 构建参数显示视图
  Widget _buildParamsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✅ 获取到安装参数',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoCard('邀请码', _params?.inviteCode ?? '-'),
          const SizedBox(height: 10),
          _buildInfoCard('渠道ID', _params?.channelId ?? '-'),
          const SizedBox(height: 10),
          _buildInfoCard('用户ID', _params?.userId ?? '-'),
          const SizedBox(height: 10),
          _buildInfoCard('自定义参数', _params?.custom ?? '-'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _getInstallParams,
            child: const Text('重新获取'),
          ),
        ],
      ),
    );
  }

  /// 构建无参数视图
  Widget _buildNoParamsView() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 20),
          const Text(
            '未匹配到安装参数',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '可能原因：\n1. 未从分享链接访问\n2. 数据已过期\n3. 设备指纹不匹配',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _getInstallParams,
            child: const Text('重新获取'),
          ),
        ],
      ),
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


