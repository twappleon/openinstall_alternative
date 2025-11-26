/// 设备指纹信息
class DeviceFingerprint {
  final String? userAgent;
  final String? language;
  final String? platform;
  final int? screenWidth;
  final int? screenHeight;
  final int? screenColorDepth;
  final double? pixelRatio;
  final String? timezone;
  final int? timezoneOffset;
  final String? canvasFingerprint;
  final Map<String, dynamic>? webglFingerprint;
  final bool? cookieEnabled;
  final String? doNotTrack;
  
  // iOS/Android 特有字段
  final String? osVersion;
  final String? deviceModel;
  final String? deviceBrand;
  final String? deviceName;
  final double? screenScale;
  final double? screenDensity;

  DeviceFingerprint({
    this.userAgent,
    this.language,
    this.platform,
    this.screenWidth,
    this.screenHeight,
    this.screenColorDepth,
    this.pixelRatio,
    this.timezone,
    this.timezoneOffset,
    this.canvasFingerprint,
    this.webglFingerprint,
    this.cookieEnabled,
    this.doNotTrack,
    this.osVersion,
    this.deviceModel,
    this.deviceBrand,
    this.deviceName,
    this.screenScale,
    this.screenDensity,
  });

  Map<String, dynamic> toJson() {
    return {
      'userAgent': userAgent,
      'language': language,
      'platform': platform,
      'screenWidth': screenWidth,
      'screenHeight': screenHeight,
      'screenColorDepth': screenColorDepth,
      'pixelRatio': pixelRatio,
      'timezone': timezone,
      'timezoneOffset': timezoneOffset,
      'canvasFingerprint': canvasFingerprint,
      'webglFingerprint': webglFingerprint,
      'cookieEnabled': cookieEnabled,
      'doNotTrack': doNotTrack,
      'osVersion': osVersion,
      'deviceModel': deviceModel,
      'deviceBrand': deviceBrand,
      'deviceName': deviceName,
      'screenScale': screenScale,
      'screenDensity': screenDensity,
    };
  }

  factory DeviceFingerprint.fromJson(Map<String, dynamic> json) {
    return DeviceFingerprint(
      userAgent: json['userAgent'],
      language: json['language'],
      platform: json['platform'],
      screenWidth: json['screenWidth'],
      screenHeight: json['screenHeight'],
      screenColorDepth: json['screenColorDepth'],
      pixelRatio: json['pixelRatio']?.toDouble(),
      timezone: json['timezone'],
      timezoneOffset: json['timezoneOffset'],
      canvasFingerprint: json['canvasFingerprint'],
      webglFingerprint: json['webglFingerprint'] != null
          ? Map<String, dynamic>.from(json['webglFingerprint'])
          : null,
      cookieEnabled: json['cookieEnabled'],
      doNotTrack: json['doNotTrack'],
      osVersion: json['osVersion'],
      deviceModel: json['deviceModel'],
      deviceBrand: json['deviceBrand'],
      deviceName: json['deviceName'],
      screenScale: json['screenScale']?.toDouble(),
      screenDensity: json['screenDensity']?.toDouble(),
    );
  }
}


