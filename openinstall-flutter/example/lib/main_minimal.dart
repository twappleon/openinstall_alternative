import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenInstall Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('测试应用'),
        ),
        body: const Center(
          child: Text(
            '应用运行正常',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

