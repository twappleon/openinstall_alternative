//
//  AppDelegate.swift
//  OpenInstall iOS SDK 使用示例
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 配置 API 基础 URL（生产环境请修改为实际地址）
        let trackingAPI = TrackingAPI(baseURL: "http://localhost:8080/api")
        
        // 获取安装参数
        trackingAPI.getInstallParams { [weak self] params in
            if let params = params {
                print("✅ 获取到安装参数:", params)
                
                // 处理参数
                if let inviteCode = params["inviteCode"] {
                    print("📝 邀请码: \(inviteCode)")
                    self?.handleInviteCode(inviteCode)
                }
                
                if let channelId = params["channelId"] {
                    print("📊 渠道ID: \(channelId)")
                    self?.handleChannelId(channelId)
                }
                
                if let userId = params["userId"] {
                    print("👤 用户ID: \(userId)")
                    self?.handleUserId(userId)
                }
                
                // 发送通知
                NotificationCenter.default.post(
                    name: NSNotification.Name("OpenInstallParamsReceived"),
                    object: nil,
                    userInfo: params
                )
            } else {
                print("❌ 未匹配到安装参数")
            }
        }
        
        return true
    }
    
    // MARK: - Universal Link 处理
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }
        
        handleDeepLink(url: url)
        return true
    }
    
    // MARK: - URL Scheme 处理
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        handleDeepLink(url: url)
        return true
    }
    
    // MARK: - 深度链接处理
    
    private func handleDeepLink(url: URL) {
        print("🔗 收到深度链接: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            return
        }
        
        var params: [String: String] = [:]
        for item in queryItems {
            params[item.name] = item.value
        }
        
        // 处理深度链接参数
        if let inviteCode = params["inviteCode"] {
            handleInviteCode(inviteCode)
        }
        
        // 发送通知
        NotificationCenter.default.post(
            name: NSNotification.Name("OpenInstallDeepLinkReceived"),
            object: nil,
            userInfo: params
        )
    }
    
    // MARK: - 业务逻辑处理
    
    private func handleInviteCode(_ code: String) {
        // 保存邀请码
        UserDefaults.standard.set(code, forKey: "inviteCode")
        
        // 建立邀请关系（调用你的业务 API）
        // YourAPI.establishInviteRelation(code: code)
    }
    
    private func handleChannelId(_ channelId: String) {
        // 保存渠道ID
        UserDefaults.standard.set(channelId, forKey: "channelId")
        
        // 上报渠道信息（调用你的业务 API）
        // YourAPI.reportChannel(channelId: channelId)
    }
    
    private func handleUserId(_ userId: String) {
        // 保存用户ID
        UserDefaults.standard.set(userId, forKey: "userId")
        
        // 跳转到用户页面等业务逻辑
        // navigateToUserPage(userId: userId)
    }
}



