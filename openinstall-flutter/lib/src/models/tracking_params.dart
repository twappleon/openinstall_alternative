/// 追踪参数
class TrackingParams {
  final String? inviteCode;
  final String? channelId;
  final String? userId;
  final String? custom;
  final Map<String, String>? extra;

  TrackingParams({
    this.inviteCode,
    this.channelId,
    this.userId,
    this.custom,
    this.extra,
  });

  Map<String, String> toMap() {
    final map = <String, String>{};
    if (inviteCode != null) map['inviteCode'] = inviteCode!;
    if (channelId != null) map['channelId'] = channelId!;
    if (userId != null) map['userId'] = userId!;
    if (custom != null) map['custom'] = custom!;
    if (extra != null) map.addAll(extra!);
    return map;
  }

  factory TrackingParams.fromMap(Map<String, dynamic> map) {
    return TrackingParams(
      inviteCode: map['inviteCode'] as String?,
      channelId: map['channelId'] as String?,
      userId: map['userId'] as String?,
      custom: map['custom'] as String?,
      extra: map['extra'] != null
          ? Map<String, String>.from(map['extra'] as Map)
          : null,
    );
  }

  @override
  String toString() {
    return 'TrackingParams(inviteCode: $inviteCode, channelId: $channelId, userId: $userId, custom: $custom)';
  }
}


