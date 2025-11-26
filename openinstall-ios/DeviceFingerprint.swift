//
//  DeviceFingerprint.swift
//  OpenInstall iOS SDK
//
//  设备指纹收集
//

import UIKit
import Foundation

class DeviceFingerprint {
    
    /// 收集设备指纹
    static func collect() -> [String: Any] {
        let device = UIDevice.current
        let screen = UIScreen.main
        
        var fingerprint: [String: Any] = [
            "userAgent": getUserAgent(),
            "platform": "iOS",
            "osVersion": device.systemVersion,
            "deviceModel": device.model,
            "deviceName": device.name,
            "screenWidth": Int(screen.bounds.width * screen.scale),
            "screenHeight": Int(screen.bounds.height * screen.scale),
            "screenScale": screen.scale,
            "timezone": TimeZone.current.identifier,
            "timezoneOffset": TimeZone.current.secondsFromGMT() / 60, // 转换为分钟
            "language": Locale.current.languageCode ?? ""
        ]
        
        return fingerprint
    }
    
    /// 获取 User Agent
    static func getUserAgent() -> String {
        let device = UIDevice.current
        return "iOS/\(device.systemVersion) \(device.model)"
    }
    
    /// 生成设备指纹ID
    static func generateId(from fingerprint: [String: Any]) -> String {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: fingerprint, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        
        // 使用简单的哈希算法
        var hash = 0
        for char in jsonString.utf8 {
            hash = ((hash << 5) - hash) + Int(char)
            hash = hash & hash // Convert to 32bit integer
        }
        
        return String(abs(hash), radix: 36)
    }
}

