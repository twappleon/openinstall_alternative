import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
  String _status = '应用已启动';

  @override
  void initState() {
    super.initState();
    _testInit();
  }

  Future<void> _testInit() async {
    try {
      setState(() {
        _status = '正在测试初始化...';
      });

      // 延迟一下，确保 UI 完全渲染
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      setState(() {
        _status = '初始化成功！\n可以安全地添加功能了';
      });
    } catch (e, stack) {
      if (kDebugMode) {
        print('初始化错误: $e');
        print('堆栈: $stack');
      }
      if (mounted) {
        setState(() {
          _status = '初始化错误: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpenInstall Flutter SDK - 安全测试'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 64,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
