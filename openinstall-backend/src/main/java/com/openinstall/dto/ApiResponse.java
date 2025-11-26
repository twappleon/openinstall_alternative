package com.openinstall.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * 统一API响应格式
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
    
    private Boolean success;
    private String message;
    private T data;
    
    public static <T> ApiResponse<T> success(T data) {
        return new ApiResponse<>(true, "操作成功", data);
    }
    
    public static <T> ApiResponse<T> success(String message, T data) {
        return new ApiResponse<>(true, message, data);
    }
    
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null);
    }
    
    /**
     * 获取追踪数据响应
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class GetTrackingResponse {
        private Map<String, String> params;
        private Boolean matched;
        private String fingerprintId;
    }
    
    /**
     * 保存追踪数据响应
     */
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class SaveTrackingResponse {
        private String fingerprintId;
    }
}

