package com.openinstall.dto;

import com.openinstall.model.DeviceFingerprint;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.Map;

/**
 * 保存追踪数据请求
 */
@Data
public class SaveTrackingRequest {
    
    @NotBlank(message = "fingerprintId不能为空")
    private String fingerprintId;
    
    @NotNull(message = "fingerprint不能为空")
    @Valid
    private DeviceFingerprint fingerprint;
    
    @NotNull(message = "params不能为空")
    private Map<String, String> params;
    
    private Long timestamp;
    private String referrer;
    private String url;
}

