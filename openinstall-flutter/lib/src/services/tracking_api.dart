import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tracking_params.dart';
import '../models/api_response.dart';
import 'fingerprint_service.dart';

/// 追踪 API 服务
class TrackingAPI {
  final String baseUrl;
  final FingerprintService _fingerprintService = FingerprintService();

  TrackingAPI({String? baseUrl})
      : baseUrl = baseUrl ?? 'https://openinstall-backend.zeabur.app/api';

  /// 获取安装参数
  Future<TrackingParams?> getInstallParams() async {
    try {
      final fingerprint = await _fingerprintService.collect();
      final fingerprintId =
          _fingerprintService.generateFingerprintId(fingerprint);

      final requestBody = {
        'fingerprintId': fingerprintId,
        'fingerprint': fingerprint.toJson(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/tracking/get'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse<GetTrackingResponse>.fromJson(
          json,
          (data) => GetTrackingResponse.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.success && apiResponse.data != null) {
          final trackingResponse = apiResponse.data!;
          if (trackingResponse.matched) {
            return TrackingParams.fromMap(trackingResponse.params);
          }
        }
      }

      return null;
    } catch (e) {
      print('获取安装参数失败: $e');
      return null;
    }
  }

  /// 保存追踪数据（可选，用于调试）
  Future<bool> saveTrackingData(TrackingParams params) async {
    try {
      final fingerprint = await _fingerprintService.collect();
      final fingerprintId =
          _fingerprintService.generateFingerprintId(fingerprint);

      final requestBody = {
        'fingerprintId': fingerprintId,
        'fingerprint': fingerprint.toJson(),
        'params': params.toMap(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/tracking/save'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final apiResponse = ApiResponse.fromJson(json, null);
        return apiResponse.success;
      }

      return false;
    } catch (e) {
      print('保存追踪数据失败: $e');
      return false;
    }
  }
}
