import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:openinstall_flutter/openinstall_flutter.dart';
import 'package:logger/logger.dart';

void main() {
  // 添加全局错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack trace: ${details.stack}');
  };

  // 处理异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Platform Error: $error');
    debugPrint('Stack trace: $stack');
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenInstall Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const SafeHomePage(),
    );
  }
}

class SafeHomePage extends StatefulWidget {
  const SafeHomePage({super.key});

  @override
  State<SafeHomePage> createState() => _SafeHomePageState();
}

class _SafeHomePageState extends State<SafeHomePage> {
  final Logger _logger = Logger();
  TrackingParams? _params;
  bool _loading = false;
  String _status = '应用已启动';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initOpenInstall();
  }

  /// 初始化 OpenInstall
  void _initOpenInstall() {
    // 延迟初始化，确保应用完全启动
    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (!mounted) return;

      try {
        setState(() {
          _loading = true;
          _status = '正在初始化 SDK...';
        });

        // 初始化 SDK
        OpenInstall()
            .init(baseUrl: 'https://openinstall-backend.zeabur.app/api');
        _logger.i('OpenInstall SDK 初始化成功');

        // 获取安装参数
        await _getInstallParams();
      } catch (e, stackTrace) {
        _logger.e('初始化 OpenInstall 失败: $e');
        _logger.e('堆栈跟踪: $stackTrace');
        if (mounted) {
          setState(() {
            _loading = false;
            _errorMessage = '初始化失败: $e';
            _status = '初始化失败';
          });
        }
      }
    });
  }

  /// 获取安装参数
  Future<void> _getInstallParams() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _status = '正在获取安装参数...';
    });

    try {
      final params = await OpenInstall().getInstallParams().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          _logger.w('获取安装参数超时');
          return null;
        },
      );

      if (!mounted) return;

      setState(() {
        _params = params;
        _loading = false;
      });

      if (params != null) {
        _logger.i('✅ 获取到安装参数: $params');
        _logger.i('邀请码: ${params.inviteCode ?? "无"}');
        _logger.i('渠道ID: ${params.channelId ?? "无"}');
        _logger.i('用户ID: ${params.userId ?? "无"}');
        setState(() {
          _status = '✅ 成功获取到参数';
        });
      } else {
        _logger.w('❌ 未匹配到安装参数');
        setState(() {
          _status = '未匹配到安装参数';
        });
      }
    } catch (e, stackTrace) {
      _logger.e('获取安装参数失败: $e');
      _logger.e('堆栈跟踪: $stackTrace');

      if (!mounted) return;

      setState(() {
        _loading = false;
        _errorMessage = '获取失败: $e';
        _status = '获取参数失败';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenInstall 参数验证'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getInstallParams,
            tooltip: '重新获取',
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('正在获取参数...'),
                ],
              ),
            )
          : _params != null
              ? _buildParamsView()
              : _buildNoParamsView(),
    );
  }

  /// 构建参数显示视图
  Widget _buildParamsView() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 成功提示
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✅ 成功获取到安装参数',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _status,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 参数详情
            const Text(
              '参数详情',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
                '邀请码', _params?.inviteCode ?? '-', Icons.card_giftcard),
            const SizedBox(height: 10),
            _buildInfoCard('渠道ID', _params?.channelId ?? '-', Icons.tag),
            const SizedBox(height: 10),
            _buildInfoCard('用户ID', _params?.userId ?? '-', Icons.person),
            const SizedBox(height: 10),
            _buildInfoCard('自定义参数', _params?.custom ?? '-', Icons.settings),

            // 额外参数
            if (_params?.extra != null && _params!.extra!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                '额外参数',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ..._params!.extra!.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildInfoCard(entry.key, entry.value, Icons.info),
                  )),
            ],

            const SizedBox(height: 30),

            // 操作按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _getInstallParams,
                icon: const Icon(Icons.refresh),
                label: const Text('重新获取参数'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建无参数视图
  Widget _buildNoParamsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _errorMessage != null ? Icons.error_outline : Icons.info_outline,
              size: 64,
              color: _errorMessage != null ? Colors.red : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage ?? '未匹配到安装参数',
              style: TextStyle(
                fontSize: 20,
                color: _errorMessage != null ? Colors.red : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (_errorMessage == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '可能原因：\n1. 未从分享链接访问网页\n2. 数据已过期\n3. 设备指纹不匹配\n4. 网页未上传设备指纹',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _getInstallParams,
              icon: const Icon(Icons.refresh),
              label: const Text('重新获取'),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建信息卡片
  Widget _buildInfoCard(String label, String value, IconData icon) {
    final hasValue = value != '-' && value.isNotEmpty;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasValue ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (hasValue)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
