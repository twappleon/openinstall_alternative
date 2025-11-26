package com.openinstall.tracking

import android.content.Context
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.concurrent.TimeUnit

/**
 * 追踪 API 服务
 */
object TrackingAPI {
    
    private const val BASE_URL = "http://localhost:8080/api"
    
    private val client = OkHttpClient.Builder()
        .connectTimeout(10, TimeUnit.SECONDS)
        .readTimeout(10, TimeUnit.SECONDS)
        .writeTimeout(10, TimeUnit.SECONDS)
        .build()
    
    /**
     * 获取安装参数
     * @param context 上下文
     * @return 参数映射，如果匹配失败返回 null
     */
    suspend fun getInstallParams(context: Context): Map<String, String>? = withContext(Dispatchers.IO) {
        try {
            val fingerprint = DeviceFingerprint.collect(context)
            val fingerprintId = DeviceFingerprint.generateId(fingerprint)
            
            val requestBody = JSONObject().apply {
                put("fingerprintId", fingerprintId)
                put("fingerprint", fingerprint)
            }
            
            val request = Request.Builder()
                .url("$BASE_URL/tracking/get")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .addHeader("Content-Type", "application/json")
                .build()
            
            val response = client.newCall(request).execute()
            val responseBody = response.body?.string() ?: return@withContext null
            
            val json = JSONObject(responseBody)
            
            if (json.optBoolean("success", false)) {
                val data = json.optJSONObject("data")
                if (data != null && data.optBoolean("matched", false)) {
                    val params = data.optJSONObject("params")
                    if (params != null) {
                        val result = mutableMapOf<String, String>()
                        val keys = params.keys()
                        while (keys.hasNext()) {
                            val key = keys.next()
                            result[key] = params.optString(key, "")
                        }
                        return@withContext result
                    }
                }
            }
            
            null
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
    
    /**
     * 保存追踪数据（可选，用于调试）
     */
    suspend fun saveTrackingData(
        context: Context,
        params: Map<String, String>
    ): Boolean = withContext(Dispatchers.IO) {
        try {
            val fingerprint = DeviceFingerprint.collect(context)
            val fingerprintId = DeviceFingerprint.generateId(fingerprint)
            
            val requestBody = JSONObject().apply {
                put("fingerprintId", fingerprintId)
                put("fingerprint", fingerprint)
                put("params", JSONObject(params))
                put("timestamp", System.currentTimeMillis())
            }
            
            val request = Request.Builder()
                .url("$BASE_URL/tracking/save")
                .post(requestBody.toString().toRequestBody("application/json".toMediaType()))
                .addHeader("Content-Type", "application/json")
                .build()
            
            val response = client.newCall(request).execute()
            val responseBody = response.body?.string() ?: return@withContext false
            
            val json = JSONObject(responseBody)
            json.optBoolean("success", false)
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}



