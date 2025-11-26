import 'dart:convert';
import 'dart:io' as dart;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:platform/platform.dart';
import '../models/device_fingerprint.dart';

/// 设备指纹服务
class FingerprintService {
  static final FingerprintService _instance = FingerprintService._internal();
  factory FingerprintService() => _instance;
  FingerprintService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Platform _platform = const LocalPlatform();

  /// 收集设备指纹
  Future<DeviceFingerprint> collect() async {
    // 基础信息
    final userAgent = await _getUserAgent();
    final language = _getLanguage();
    final platform = _platform.operatingSystem;

    // 屏幕信息
    final screenData = await _getScreenInfo();
    final screenWidth = screenData['width'] as int?;
    final screenHeight = screenData['height'] as int?;
    final screenColorDepth = screenData['colorDepth'] as int?;
    final pixelRatio = screenData['pixelRatio'] as double?;
    final screenScale = screenData['scale'] as double?;
    final screenDensity = screenData['density'] as double?;

    // 时区
    final timezoneData = _getTimezone();
    final timezone = timezoneData['timezone'] as String?;
    final timezoneOffset = timezoneData['offset'] as int?;

    // 设备信息
    String? osVersion;
    String? deviceModel;
    String? deviceBrand;
    String? deviceName;

    if (_platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      osVersion = androidInfo.version.release;
      deviceModel = androidInfo.model;
      deviceBrand = androidInfo.brand;
      deviceName = androidInfo.device;
    } else if (_platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      osVersion = iosInfo.systemVersion;
      deviceModel = iosInfo.model;
      deviceName = iosInfo.name;
    }

    return DeviceFingerprint(
      userAgent: userAgent,
      language: language,
      platform: platform,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      screenColorDepth: screenColorDepth,
      pixelRatio: pixelRatio,
      screenScale: screenScale,
      screenDensity: screenDensity,
      timezone: timezone,
      timezoneOffset: timezoneOffset,
      osVersion: osVersion,
      deviceModel: deviceModel,
      deviceBrand: deviceBrand,
      deviceName: deviceName,
    );
  }

  /// 生成设备指纹ID
  String generateFingerprintId(DeviceFingerprint fingerprint) {
    final json = jsonEncode(fingerprint.toJson());
    int hash = 0;
    for (int i = 0; i < json.length; i++) {
      final char = json.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.abs().toRadixString(36);
  }

  /// 获取 User Agent
  Future<String> _getUserAgent() async {
    if (_platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return 'Android/${androidInfo.version.release} ${androidInfo.model}';
    } else if (_platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return 'iOS/${iosInfo.systemVersion} ${iosInfo.model}';
    }
    return 'Unknown';
  }

  /// 获取语言
  String _getLanguage() {
    try {
      return dart.Platform.localeName.split('_').first;
    } catch (e) {
      return 'en';
    }
  }

  /// 获取屏幕信息
  Future<Map<String, dynamic>> _getScreenInfo() async {
    try {
      const platform = MethodChannel('com.openinstall.flutter/screen');
      final result = await platform.invokeMethod('getScreenInfo');
      return Map<String, dynamic>.from(result as Map);
    } catch (e) {
      // 如果原生方法不可用，返回默认值
      return {
        'width': 375,
        'height': 812,
        'colorDepth': 24,
        'pixelRatio': 2.0,
        'scale': 2.0,
        'density': 2.0,
      };
    }
  }

  /// 获取时区
  Map<String, dynamic> _getTimezone() {
    final now = DateTime.now();
    final timezone = now.timeZoneName;
    final offset = now.timeZoneOffset.inMinutes;
    return {
      'timezone': timezone,
      'offset': offset,
    };
  }
}

