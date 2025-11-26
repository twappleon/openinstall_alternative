package com.openinstall.tracking

import android.content.Context
import android.os.Build
import android.util.DisplayMetrics
import android.view.WindowManager
import org.json.JSONObject
import java.security.MessageDigest
import java.util.*

/**
 * 设备指纹收集工具类
 */
object DeviceFingerprint {
    
    /**
     * 收集设备指纹
     */
    fun collect(context: Context): JSONObject {
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)
        
        return JSONObject().apply {
            put("userAgent", getUserAgent())
            put("platform", "Android")
            put("osVersion", Build.VERSION.RELEASE)
            put("deviceModel", Build.MODEL)
            put("deviceBrand", Build.BRAND)
            put("deviceManufacturer", Build.MANUFACTURER)
            put("screenWidth", displayMetrics.widthPixels)
            put("screenHeight", displayMetrics.heightPixels)
            put("screenDensity", displayMetrics.density)
            put("screenDensityDpi", displayMetrics.densityDpi)
            put("timezone", TimeZone.getDefault().id)
            put("timezoneOffset", TimeZone.getDefault().rawOffset / 1000 / 60) // 转换为分钟
            put("language", Locale.getDefault().language)
        }
    }
    
    /**
     * 获取 User Agent
     */
    private fun getUserAgent(): String {
        return "Android/${Build.VERSION.RELEASE} ${Build.MODEL}"
    }
    
    /**
     * 生成设备指纹ID
     */
    fun generateId(fingerprint: JSONObject): String {
        val jsonString = fingerprint.toString()
        val bytes = MessageDigest.getInstance("MD5").digest(jsonString.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }
}


