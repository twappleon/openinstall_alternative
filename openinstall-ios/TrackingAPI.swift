//
//  TrackingAPI.swift
//  OpenInstall iOS SDK
//
//  追踪 API 服务
//

import Foundation

class TrackingAPI {
    
    static let shared = TrackingAPI()
    
    private let baseURL: String
    
    init(baseURL: String = "http://localhost:8080/api") {
        self.baseURL = baseURL
    }
    
    /// 获取安装参数
    /// - Parameter completion: 回调函数，返回参数字典或 nil
    func getInstallParams(completion: @escaping ([String: String]?) -> Void) {
        let fingerprint = DeviceFingerprint.collect()
        let fingerprintId = DeviceFingerprint.generateId(from: fingerprint)
        
        guard let url = URL(string: "\(baseURL)/tracking/get") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "fingerprintId": fingerprintId,
            "fingerprint": fingerprint
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(nil)
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool,
                  success == true,
                  let dataDict = json["data"] as? [String: Any],
                  let matched = dataDict["matched"] as? Bool,
                  matched == true,
                  let params = dataDict["params"] as? [String: String] else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(params)
            }
        }.resume()
    }
    
    /// 保存追踪数据（可选，用于调试）
    func saveTrackingData(params: [String: String], completion: @escaping (Bool) -> Void) {
        let fingerprint = DeviceFingerprint.collect()
        let fingerprintId = DeviceFingerprint.generateId(from: fingerprint)
        
        guard let url = URL(string: "\(baseURL)/tracking/save") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "fingerprintId": fingerprintId,
            "fingerprint": fingerprint,
            "params": params,
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(false)
            return
        }
        
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let success = json["success"] as? Bool else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(success)
            }
        }.resume()
    }
}

