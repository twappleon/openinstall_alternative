package com.openinstall.dto;

import com.openinstall.model.DeviceFingerprint;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 获取追踪数据请求
 */
@Data
public class GetTrackingRequest {
    
    @NotBlank(message = "fingerprintId不能为空")
    private String fingerprintId;
    
    @NotNull(message = "fingerprint不能为空")
    @Valid
    private DeviceFingerprint fingerprint;
}

