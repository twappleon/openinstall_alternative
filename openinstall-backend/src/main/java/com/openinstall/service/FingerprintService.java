package com.openinstall.service;

import com.openinstall.model.DeviceFingerprint;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * 设备指纹服务
 */
@Service
public class FingerprintService {
    
    /**
     * 生成设备指纹ID
     */
    public String generateFingerprintId(DeviceFingerprint fingerprint) {
        try {
            StringBuilder sb = new StringBuilder();
            sb.append(fingerprint.getUserAgent()).append("|");
            sb.append(fingerprint.getPlatform()).append("|");
            sb.append(fingerprint.getScreenWidth()).append("|");
            sb.append(fingerprint.getScreenHeight()).append("|");
            sb.append(fingerprint.getTimezone()).append("|");
            if (fingerprint.getCanvasFingerprint() != null) {
                sb.append(fingerprint.getCanvasFingerprint().substring(0, Math.min(50, fingerprint.getCanvasFingerprint().length())));
            }
            
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] hash = md.digest(sb.toString().getBytes(StandardCharsets.UTF_8));
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("生成指纹ID失败", e);
        }
    }
    
    /**
     * 计算两个指纹的相似度
     * @return 相似度分数 (0.0 - 1.0)
     */
    public double calculateSimilarity(DeviceFingerprint fp1, DeviceFingerprint fp2) {
        if (fp1 == null || fp2 == null) {
            return 0.0;
        }
        
        int matchCount = 0;
        int totalCount = 0;
        
        // 比较关键字段
        if (compareField(fp1.getUserAgent(), fp2.getUserAgent())) matchCount++;
        totalCount++;
        
        if (compareField(fp1.getScreenWidth(), fp2.getScreenWidth())) matchCount++;
        totalCount++;
        
        if (compareField(fp1.getScreenHeight(), fp2.getScreenHeight())) matchCount++;
        totalCount++;
        
        if (compareField(fp1.getTimezone(), fp2.getTimezone())) matchCount++;
        totalCount++;
        
        if (compareField(fp1.getPlatform(), fp2.getPlatform())) matchCount++;
        totalCount++;
        
        // Canvas 指纹部分匹配
        if (fp1.getCanvasFingerprint() != null && fp2.getCanvasFingerprint() != null) {
            String c1 = fp1.getCanvasFingerprint();
            String c2 = fp2.getCanvasFingerprint();
            if (c1.length() > 20 && c2.length() > 20) {
                if (c1.substring(0, Math.min(20, c1.length()))
                    .equals(c2.substring(0, Math.min(20, c2.length())))) {
                    matchCount++;
                }
            }
            totalCount++;
        }
        
        return totalCount > 0 ? (double) matchCount / totalCount : 0.0;
    }
    
    private boolean compareField(Object field1, Object field2) {
        if (field1 == null && field2 == null) return true;
        if (field1 == null || field2 == null) return false;
        return field1.equals(field2);
    }
}

