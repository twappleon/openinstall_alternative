package com.openinstall.example

import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.openinstall.tracking.TrackingAPI
import kotlinx.coroutines.launch

/**
 * MainActivity - OpenInstall Android SDK 使用示例
 */
class MainActivity : AppCompatActivity() {
    
    companion object {
        private const val TAG = "OpenInstall"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        // 获取安装参数
        lifecycleScope.launch {
            val params = TrackingAPI.getInstallParams(this@MainActivity)
            
            if (params != null) {
                Log.d(TAG, "✅ 获取到安装参数: $params")
                
                // 处理参数
                params["inviteCode"]?.let { inviteCode ->
                    Log.d(TAG, "📝 邀请码: $inviteCode")
                    handleInviteCode(inviteCode)
                }
                
                params["channelId"]?.let { channelId ->
                    Log.d(TAG, "📊 渠道ID: $channelId")
                    handleChannelId(channelId)
                }
                
                params["userId"]?.let { userId ->
                    Log.d(TAG, "👤 用户ID: $userId")
                    handleUserId(userId)
                }
                
                // 发送广播通知
                sendParamsReceivedBroadcast(params)
            } else {
                Log.d(TAG, "❌ 未匹配到安装参数")
            }
        }
        
        // 处理深度链接
        handleDeepLink(intent)
    }
    
    override fun onNewIntent(intent: android.content.Intent?) {
        super.onNewIntent(intent)
        handleDeepLink(intent)
    }
    
    /**
     * 处理深度链接
     */
    private fun handleDeepLink(intent: android.content.Intent?) {
        intent?.data?.let { uri ->
            Log.d(TAG, "🔗 收到深度链接: $uri")
            
            val params = mutableMapOf<String, String>()
            uri.queryParameterNames.forEach { key ->
                uri.getQueryParameter(key)?.let { value ->
                    params[key] = value
                }
            }
            
            // 处理深度链接参数
            params["inviteCode"]?.let { handleInviteCode(it) }
            params["channelId"]?.let { handleChannelId(it) }
            params["userId"]?.let { handleUserId(it) }
            
            // 发送广播通知
            sendDeepLinkReceivedBroadcast(params)
        }
    }
    
    /**
     * 处理邀请码
     */
    private fun handleInviteCode(code: String) {
        // 保存邀请码
        val prefs = getSharedPreferences("app_prefs", MODE_PRIVATE)
        prefs.edit().putString("inviteCode", code).apply()
        
        // 建立邀请关系（调用你的业务 API）
        // YourAPI.establishInviteRelation(code)
    }
    
    /**
     * 处理渠道ID
     */
    private fun handleChannelId(channelId: String) {
        // 保存渠道ID
        val prefs = getSharedPreferences("app_prefs", MODE_PRIVATE)
        prefs.edit().putString("channelId", channelId).apply()
        
        // 上报渠道信息（调用你的业务 API）
        // YourAPI.reportChannel(channelId)
    }
    
    /**
     * 处理用户ID
     */
    private fun handleUserId(userId: String) {
        // 保存用户ID
        val prefs = getSharedPreferences("app_prefs", MODE_PRIVATE)
        prefs.edit().putString("userId", userId).apply()
        
        // 跳转到用户页面等业务逻辑
        // navigateToUserPage(userId)
    }
    
    /**
     * 发送参数接收广播
     */
    private fun sendParamsReceivedBroadcast(params: Map<String, String>) {
        val intent = android.content.Intent("com.openinstall.PARAMS_RECEIVED")
        params.forEach { (key, value) ->
            intent.putExtra(key, value)
        }
        sendBroadcast(intent)
    }
    
    /**
     * 发送深度链接接收广播
     */
    private fun sendDeepLinkReceivedBroadcast(params: Map<String, String>) {
        val intent = android.content.Intent("com.openinstall.DEEP_LINK_RECEIVED")
        params.forEach { (key, value) ->
            intent.putExtra(key, value)
        }
        sendBroadcast(intent)
    }
}


