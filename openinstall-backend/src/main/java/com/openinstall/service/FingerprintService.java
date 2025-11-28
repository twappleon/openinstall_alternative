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
     * 使用标准化后的字段值，确保 Web 端和移动端在相同设备上生成相同的 fingerprintId
     */
    public String generateFingerprintId(DeviceFingerprint fingerprint) {
        try {
            StringBuilder sb = new StringBuilder();
            
            // 标准化字段值，确保 Web 端和移动端格式一致
            String normalizedUserAgent = normalizeUserAgent(fingerprint.getUserAgent());
            String normalizedPlatform = normalizePlatform(fingerprint.getPlatform());
            String normalizedTimezone = normalizeTimezone(fingerprint.getTimezone(), fingerprint.getTimezoneOffset());
            
            // 构建字符串（使用标准化后的值）
            sb.append(normalizedUserAgent).append("|");
            sb.append(normalizedPlatform).append("|");
            sb.append(fingerprint.getScreenWidth() != null ? fingerprint.getScreenWidth().toString() : "").append("|");
            sb.append(fingerprint.getScreenHeight() != null ? fingerprint.getScreenHeight().toString() : "").append("|");
            sb.append(normalizedTimezone).append("|");
            
            // Canvas 指纹：Web 端有，移动端没有，所以不参与计算
            // 如果包含 Canvas 指纹，会导致 Web 端和移动端的 fingerprintId 不同
            // 因此这里不使用 Canvas 指纹
            
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
    
    /**
     * 标准化 platform 字段
     * Web 端: "Win32", "MacIntel", "Linux x86_64" -> "windows", "macos", "linux"
     * Flutter 端: "android", "ios" -> "android", "ios"
     */
    private String normalizePlatform(String platform) {
        if (platform == null || platform.isEmpty()) {
            return "";
        }
        String lower = platform.toLowerCase();
        if (lower.contains("win")) return "windows";
        if (lower.contains("mac")) return "macos";
        if (lower.contains("linux")) return "linux";
        if (lower.equals("android")) return "android";
        if (lower.equals("ios")) return "ios";
        // 保持原值（可能是其他格式）
        return platform;
    }
    
    /**
     * 标准化 timezone 字段
     * Web 端: "Asia/Shanghai" (IANA 格式)
     * Flutter 端: "CST", "UTC" (时区缩写) -> 转换为 IANA 格式
     */
    private String normalizeTimezone(String timezone, Integer timezoneOffset) {
        if (timezone == null || timezone.isEmpty()) {
            // 如果没有时区名称，使用时区偏移量转换为时区
            if (timezoneOffset != null) {
                return convertOffsetToTimezone(timezoneOffset);
            }
            return "";
        }
        
        // 如果已经是 IANA 格式（包含 "/"），直接返回
        if (timezone.contains("/")) {
            return timezone;
        }
        
        // 如果是时区缩写（如 "CST", "PST"），需要转换为 IANA 格式
        // 这里使用简化的映射，实际应该使用时区偏移量来精确判断
        String normalized = convertAbbreviationToIANA(timezone, timezoneOffset);
        return normalized != null ? normalized : timezone;
    }
    
    /**
     * 将时区偏移量（分钟）转换为 IANA 时区名称
     */
    private String convertOffsetToTimezone(Integer offsetMinutes) {
        if (offsetMinutes == null) {
            return "";
        }
        // 简化的映射，实际应该使用更完整的时区数据库
        int offsetHours = offsetMinutes / 60;
        switch (offsetHours) {
            case 8: return "Asia/Shanghai";  // UTC+8
            case 9: return "Asia/Tokyo";      // UTC+9
            case 0: return "UTC";             // UTC+0
            case -5: return "America/New_York"; // UTC-5
            case -8: return "America/Los_Angeles"; // UTC-8
            default:
                // 返回 UTC 偏移量格式
                return String.format("UTC%+d", offsetHours);
        }
    }
    
    /**
     * 将时区缩写转换为 IANA 时区名称
     */
    private String convertAbbreviationToIANA(String abbreviation, Integer timezoneOffset) {
        if (abbreviation == null || abbreviation.isEmpty()) {
            return null;
        }
        
        // 简化的映射，结合时区偏移量来精确判断
        String upper = abbreviation.toUpperCase();
        
        // 如果有时区偏移量，优先使用它
        if (timezoneOffset != null) {
            return convertOffsetToTimezone(timezoneOffset);
        }
        
        // 否则使用缩写映射（可能不准确）
        switch (upper) {
            case "CST":
                // CST 可能是 China Standard Time (UTC+8) 或 Central Standard Time (UTC-6)
                // 默认使用中国标准时间
                return "Asia/Shanghai";
            case "PST":
                return "America/Los_Angeles";
            case "EST":
                return "America/New_York";
            case "UTC":
            case "GMT":
                return "UTC";
            default:
                return null;
        }
    }
    
    /**
     * 标准化 userAgent 字段
     * 提取关键信息：操作系统和版本
     * Web 端: "Mozilla/5.0 (Windows NT 10.0; Win64; x64)..." -> "Windows 10"
     * Flutter 端: "Android/13 Pixel 6" -> "Android 13"
     */
    private String normalizeUserAgent(String userAgent) {
        if (userAgent == null || userAgent.isEmpty()) {
            return "";
        }
        
        // 如果是 Flutter 端的格式（"Android/13" 或 "iOS/16"），直接返回
        if (userAgent.startsWith("Android/") || userAgent.startsWith("iOS/")) {
            // 提取 "Android/13" 或 "iOS/16"
            int spaceIndex = userAgent.indexOf(' ');
            if (spaceIndex > 0) {
                return userAgent.substring(0, spaceIndex);
            }
            return userAgent;
        }
        
        // 如果是 Web 端的格式，提取操作系统信息
        String lower = userAgent.toLowerCase();
        
        // 提取 Windows 版本
        if (lower.contains("windows")) {
            if (lower.contains("windows nt 10.0") || lower.contains("windows 10")) {
                return "Windows 10";
            }
            if (lower.contains("windows nt 6.3") || lower.contains("windows 8.1")) {
                return "Windows 8.1";
            }
            if (lower.contains("windows nt 6.1") || lower.contains("windows 7")) {
                return "Windows 7";
            }
            return "Windows";
        }
        
        // 提取 macOS 版本
        if (lower.contains("mac os x") || lower.contains("macintosh")) {
            // 尝试提取版本号
            if (lower.contains("mac os x 10")) {
                return "macOS 10";
            }
            return "macOS";
        }
        
        // 提取 Linux
        if (lower.contains("linux")) {
            return "Linux";
        }
        
        // 提取 Android（从 Web 端）
        if (lower.contains("android")) {
            // 尝试提取版本号
            return "Android";
        }
        
        // 提取 iOS（从 Web 端）
        if (lower.contains("iphone") || lower.contains("ipad") || lower.contains("ipod")) {
            return "iOS";
        }
        
        // 如果无法识别，返回原值的前 50 个字符
        return userAgent.length() > 50 ? userAgent.substring(0, 50) : userAgent;
    }
}

