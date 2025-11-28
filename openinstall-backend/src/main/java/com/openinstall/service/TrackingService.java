package com.openinstall.service;

import com.openinstall.model.DeviceFingerprint;
import com.openinstall.model.TrackingData;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.concurrent.TimeUnit;

/**
 * 追踪服务
 */
@Slf4j
@Service
public class TrackingService {
    
    @Autowired
    private RedisTemplate<String, Object> redisTemplate;
    
    @Autowired
    private FingerprintService fingerprintService;
    
    private static final String REDIS_KEY_PREFIX = "tracking:";
    private static final String REDIS_INDEX_PREFIX = "tracking:index:";
    private static final long DEFAULT_EXPIRE_HOURS = 24; // 默认24小时过期
    
    /**
     * 保存追踪数据
     */
    public String saveTrackingData(TrackingData data) {
        long now = System.currentTimeMillis();
        
        // 设置过期时间
        if (data.getExpiresAt() == null) {
            data.setExpiresAt(now + DEFAULT_EXPIRE_HOURS * 60 * 60 * 1000);
        }
        
        if (data.getTimestamp() == null) {
            data.setTimestamp(now);
        }
        
        // 重要：使用后端统一的算法重新计算 fingerprintId
        // 确保无论前端（Web/Flutter）发送什么格式，后端都用统一算法计算
        // 这样保存和匹配时使用的 fingerprintId 完全一致
        String fingerprintId = fingerprintService.generateFingerprintId(data.getFingerprint());
        data.setFingerprintId(fingerprintId);
        
        String key = REDIS_KEY_PREFIX + fingerprintId;
        
        // 保存到 Redis，设置过期时间
        long expireSeconds = (data.getExpiresAt() - now) / 1000;
        redisTemplate.opsForValue().set(key, data, expireSeconds, TimeUnit.SECONDS);
        
        // 创建索引用于模糊匹配（基于关键指纹特征）
        String indexKey = buildIndexKey(data.getFingerprint());
        redisTemplate.opsForSet().add(REDIS_INDEX_PREFIX + indexKey, data.getFingerprintId());
        redisTemplate.expire(REDIS_INDEX_PREFIX + indexKey, expireSeconds, TimeUnit.SECONDS);
        
        log.info("保存追踪数据: fingerprintId={}, params={}", data.getFingerprintId(), data.getParams());
        
        return data.getFingerprintId();
    }
    
    /**
     * 获取追踪数据（精确匹配）
     */
    public TrackingData getTrackingData(String fingerprintId) {
        String key = REDIS_KEY_PREFIX + fingerprintId;
        TrackingData data = (TrackingData) redisTemplate.opsForValue().get(key);
        
        if (data != null && data.getExpiresAt() > System.currentTimeMillis()) {
            return data;
        }
        
        return null;
    }
    
    /**
     * 通过设备指纹匹配追踪数据
     */
    public TrackingData matchTrackingData(DeviceFingerprint fingerprint) {
        // 1. 先尝试精确匹配
        String fingerprintId = fingerprintService.generateFingerprintId(fingerprint);
        TrackingData data = getTrackingData(fingerprintId);
        log.info("精确匹配: fingerprintId={}, data={}", fingerprintId, data);

        if (data != null && !data.getMatched() && data.getMatchCount() < 3) {
            // 匹配成功，标记为已使用
            data.setMatched(true);
            data.setMatchCount(data.getMatchCount() + 1);
            saveTrackingData(data);
            
            log.info("精确匹配成功: fingerprintId={}, params={}", fingerprintId, data.getParams());
            return data;
        }
        
        // 2. 如果精确匹配失败，尝试模糊匹配
        return fuzzyMatch(fingerprint);
    }
    
    /**
     * 模糊匹配
     */
    private TrackingData fuzzyMatch(DeviceFingerprint targetFingerprint) {
        String indexKey = buildIndexKey(targetFingerprint);
        Set<Object> candidateIds = redisTemplate.opsForSet().members(REDIS_INDEX_PREFIX + indexKey);
        log.info("模糊匹配成功: candidateIds={}, indexKey={}", candidateIds, indexKey);

        if (candidateIds == null || candidateIds.isEmpty()) {
            return null;
        }
        
        TrackingData bestMatch = null;
        double highestScore = 0.0;
        double threshold = 0.8; // 相似度阈值 80%
        
        for (Object idObj : candidateIds) {
            String fingerprintId = (String) idObj;
            TrackingData candidate = getTrackingData(fingerprintId);
            log.info("模糊匹配成功: fingerprintId={}, candidate={}", fingerprintId, candidate);

            if (candidate == null || candidate.getMatched() || candidate.getMatchCount() >= 3) {
                continue;
            }
            
            double score = fingerprintService.calculateSimilarity(
                targetFingerprint, 
                candidate.getFingerprint()
            );
            
            if (score > highestScore && score >= threshold) {
                highestScore = score;
                bestMatch = candidate;
            }
        }
        
        if (bestMatch != null) {
            // 匹配成功，标记为已使用
            bestMatch.setMatched(true);
            bestMatch.setMatchCount(bestMatch.getMatchCount() + 1);
            saveTrackingData(bestMatch);
            
            log.info("模糊匹配成功: fingerprintId={}, score={}, params={}", 
                bestMatch.getFingerprintId(), highestScore, bestMatch.getParams());
        }
        log.info("模糊匹配成功: fingerprintId={}, params={}", targetFingerprint, bestMatch);

        return bestMatch;
    }
    
    /**
     * 构建索引键（用于快速查找候选数据）
     */
    private String buildIndexKey(DeviceFingerprint fingerprint) {
        StringBuilder sb = new StringBuilder();
        sb.append(fingerprint.getPlatform()).append(":");
        sb.append(fingerprint.getScreenWidth()).append("x").append(fingerprint.getScreenHeight()).append(":");
        if (fingerprint.getTimezone() != null) {
            sb.append(fingerprint.getTimezone());
        }
        return sb.toString();
    }
    
    /**
     * 清理过期数据（由定时任务调用）
     */
    public void cleanExpiredData() {
        // Redis 会自动清理过期的 key，这里可以添加额外的清理逻辑
        log.debug("清理过期数据任务执行");
    }
}

