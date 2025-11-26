package com.openinstall.model;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * 追踪数据实体
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TrackingData {
    
    /**
     * 设备指纹ID
     */
    private String fingerprintId;
    
    /**
     * 设备指纹详情
     */
    private DeviceFingerprint fingerprint;
    
    /**
     * 传递的参数（如邀请码、渠道ID等）
     */
    private Map<String, String> params;
    
    /**
     * 创建时间戳
     */
    private Long timestamp;
    
    /**
     * 客户端IP
     */
    private String clientIp;
    
    /**
     * 过期时间戳（默认24小时后过期）
     */
    private Long expiresAt;
    
    /**
     * 是否已被匹配使用
     */
    private Boolean matched = false;
    
    /**
     * 匹配次数（防重复使用）
     */
    private Integer matchCount = 0;
}

