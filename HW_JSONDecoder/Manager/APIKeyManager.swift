//
//  APIKeyManager.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2025/4/3.
//

import Foundation

/// 管理 API 金鑰的工具類別（目前用於 RAWG API）
/// - 用途：將私密金鑰從程式碼中抽離，改存放於 Secrets.plist，避免上傳到 GitHub
enum APIKeyManager {
    
    /// 從 Secrets.plist 中讀取 RAWG API 的金鑰
    static var rawgApiKey: String {
        
        // 嘗試取得 Secrets.plist 的路徑（必須存在於專案中且已加入 target）
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["RAWG_API_KEY"] as? String else {
            fatalError("Missing RAWG_API_KEY in Secrets.plist")
        }
        return key
    }
    
}
