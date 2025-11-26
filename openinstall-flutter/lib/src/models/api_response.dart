/// API 响应
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data: json['data'] != null
          ? (fromJsonT != null ? fromJsonT(json['data']) : json['data'] as T)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}

/// 保存追踪数据响应
class SaveTrackingResponse {
  final String fingerprintId;

  SaveTrackingResponse({required this.fingerprintId});

  factory SaveTrackingResponse.fromJson(Map<String, dynamic> json) {
    return SaveTrackingResponse(
      fingerprintId: json['fingerprintId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fingerprintId': fingerprintId,
    };
  }
}

/// 获取追踪数据响应
class GetTrackingResponse {
  final Map<String, String> params;
  final bool matched;
  final String? fingerprintId;

  GetTrackingResponse({
    required this.params,
    required this.matched,
    this.fingerprintId,
  });

  factory GetTrackingResponse.fromJson(Map<String, dynamic> json) {
    return GetTrackingResponse(
      params: (json['params'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ?? {},
      matched: json['matched'] as bool,
      fingerprintId: json['fingerprintId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'params': params,
      'matched': matched,
      'fingerprintId': fingerprintId,
    };
  }
}



