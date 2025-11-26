package com.openinstall.flutter

import android.content.Context
import android.os.Build
import android.util.DisplayMetrics
import android.view.WindowManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.util.*

class OpenInstallPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.openinstall.flutter/screen")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getScreenInfo" -> {
                val screenInfo = getScreenInfo()
                result.success(screenInfo)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    private fun getScreenInfo(): Map<String, Any> {
        val context = this.context ?: return emptyMap()
        val windowManager = context.getSystemService(Context.WINDOW_SERVICE) as WindowManager
        val displayMetrics = DisplayMetrics()
        windowManager.defaultDisplay.getMetrics(displayMetrics)

        return mapOf(
            "width" to displayMetrics.widthPixels,
            "height" to displayMetrics.heightPixels,
            "colorDepth" to 24, // Android 默认
            "pixelRatio" to displayMetrics.density.toDouble(),
            "scale" to displayMetrics.density.toDouble(),
            "density" to displayMetrics.density.toDouble()
        )
    }
}


