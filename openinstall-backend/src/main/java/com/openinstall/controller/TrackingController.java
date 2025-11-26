package com.openinstall.controller;

import com.openinstall.dto.ApiResponse;
import com.openinstall.dto.GetTrackingRequest;
import com.openinstall.dto.SaveTrackingRequest;
import com.openinstall.model.TrackingData;
import com.openinstall.service.TrackingService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 追踪控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/tracking")
@CrossOrigin(origins = "*")
public class TrackingController {
    
    @Autowired
    private TrackingService trackingService;
    
    /**
     * 保存追踪数据（Web端调用）
     */
    @PostMapping("/save")
    public ApiResponse<ApiResponse.SaveTrackingResponse> saveTracking(
            @Valid @RequestBody SaveTrackingRequest request,
            HttpServletRequest httpRequest) {
        
        try {
            // 获取客户端IP
            String clientIp = getClientIp(httpRequest);
            
            // 构建追踪数据
            TrackingData data = new TrackingData();
            data.setFingerprintId(request.getFingerprintId());
            data.setFingerprint(request.getFingerprint());
            data.setParams(request.getParams());
            data.setTimestamp(request.getTimestamp() != null ? request.getTimestamp() : System.currentTimeMillis());
            data.setClientIp(clientIp);
            
            // 保存数据
            String fingerprintId = trackingService.saveTrackingData(data);
            
            return ApiResponse.success(new ApiResponse.SaveTrackingResponse(fingerprintId));
            
        } catch (Exception e) {
            log.error("保存追踪数据失败", e);
            return ApiResponse.error("保存失败: " + e.getMessage());
        }
    }
    
    /**
     * 获取追踪数据（App端调用）
     */
    @PostMapping("/get")
    public ApiResponse<ApiResponse.GetTrackingResponse> getTracking(
            @Valid @RequestBody GetTrackingRequest request) {
        
        try {
            // 通过设备指纹匹配数据
            TrackingData data = trackingService.matchTrackingData(request.getFingerprint());
            
            ApiResponse.GetTrackingResponse response = new ApiResponse.GetTrackingResponse();
            
            if (data != null) {
                response.setParams(data.getParams());
                response.setMatched(true);
                response.setFingerprintId(data.getFingerprintId());
            } else {
                response.setParams(new java.util.HashMap<>());
                response.setMatched(false);
            }
            
            return ApiResponse.success(response);
            
        } catch (Exception e) {
            log.error("获取追踪数据失败", e);
            return ApiResponse.error("获取失败: " + e.getMessage());
        }
    }
    
    /**
     * 健康检查
     */
    @GetMapping("/health")
    public ApiResponse<String> health() {
        return ApiResponse.success("服务运行正常");
    }
    
    /**
     * 获取客户端真实IP
     */
    private String getClientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("WL-Proxy-Client-IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_CLIENT_IP");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getHeader("HTTP_X_FORWARDED_FOR");
        }
        if (ip == null || ip.isEmpty() || "unknown".equalsIgnoreCase(ip)) {
            ip = request.getRemoteAddr();
        }
        
        // 如果是多级代理，取第一个IP
        if (ip != null && ip.contains(",")) {
            ip = ip.split(",")[0].trim();
        }
        
        return ip;
    }
}

