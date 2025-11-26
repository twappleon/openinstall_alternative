import 'package:logger/logger.dart';
import 'models/tracking_params.dart';
import 'services/tracking_api.dart';

/// OpenInstall Flutter SDK
class OpenInstall {
  static final OpenInstall _instance = OpenInstall._internal();
  factory OpenInstall() => _instance;
  OpenInstall._internal();

  final Logger _logger = Logger();
  TrackingAPI? _trackingAPI;
  TrackingParams? _cachedParams;
  bool _initialized = false;

  /// 初始化 SDK
  ///
  /// [baseUrl] 后端 API 地址，默认为 https://openinstall-backend.zeabur.app/api
  void init({String? baseUrl}) {
    if (_initialized) {
      _logger.w('OpenInstall 已经初始化');
      return;
    }

    _trackingAPI = TrackingAPI(baseUrl: baseUrl);
    _initialized = true;
    _logger.i('OpenInstall 初始化成功');
  }

  /// 获取安装参数
  ///
  /// 返回追踪参数，如果匹配失败返回 null
  Future<TrackingParams?> getInstallParams() async {
    if (!_initialized) {
      _logger.e('OpenInstall 未初始化，请先调用 init()');
      return null;
    }

    // 如果已缓存，直接返回
    if (_cachedParams != null) {
      return _cachedParams;
    }

    try {
      _logger.i('开始获取安装参数...');
      final params = await _trackingAPI!.getInstallParams();

      if (params != null) {
        _logger.i('✅ 获取到安装参数: $params');
        _cachedParams = params;
      } else {
        _logger.w('❌ 未匹配到安装参数');
      }

      return params;
    } catch (e) {
      _logger.e('获取安装参数失败: $e');
      return null;
    }
  }

  /// 获取缓存的参数（如果已获取过）
  TrackingParams? getCachedParams() {
    return _cachedParams;
  }

  /// 清除缓存的参数
  void clearCache() {
    _cachedParams = null;
  }

  /// 保存追踪数据（可选，用于调试）
  Future<bool> saveTrackingData(TrackingParams params) async {
    if (!_initialized) {
      _logger.e('OpenInstall 未初始化，请先调用 init()');
      return false;
    }

    try {
      return await _trackingAPI!.saveTrackingData(params);
    } catch (e) {
      _logger.e('保存追踪数据失败: $e');
      return false;
    }
  }
}
