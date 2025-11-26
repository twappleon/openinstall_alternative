package com.openinstall.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * 设备指纹信息
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class DeviceFingerprint {
    
    private String userAgent;
    private String language;
    private String platform;
    private Integer screenWidth;
    private Integer screenHeight;
    private Integer screenColorDepth;
    private Double pixelRatio;
    private String timezone;
    private Integer timezoneOffset;
    private String canvasFingerprint;
    private Map<String, Object> webglFingerprint;
    private Boolean cookieEnabled;
    private String doNotTrack;
    
    // iOS/Android 特有字段
    private String osVersion;
    private String deviceModel;
    private String deviceBrand;
    private String deviceName;
    private Double screenScale;
    private Double screenDensity;
}

