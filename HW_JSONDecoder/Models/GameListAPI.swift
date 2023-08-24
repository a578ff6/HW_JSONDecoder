//
//  GameListAPI.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2023/8/21.
//

import Foundation

// 該API endpoint用於獲取遊戲列表（ Get a list of games）。這些遊戲列表將被顯示在tableView的cell中。
// https://api.rawg.io/api/games?key= "\(APIKey)"


/// 定義從RAWG API返回的遊戲列表的結構體。
/// 這個 struct 將被用於解碼JSON響應中的`results`部分。
struct GameListResponse: Codable {
    let results:[GameResult]          // 包含多個遊戲詳情的列表
}

/// 用於描述API返回的單個遊戲的資訊結構體
struct GameResult: Codable {
    let id: Int                       // 遊戲的唯一識別碼。當使用者點擊tableView的cell時，這個ID將用於獲取該遊戲的更多詳細信息
    let name: String?                 // 遊戲的名稱
    let released: String?             // 遊戲的發售日期。使用String代替Date，因為API返回的是格式化的字符串
    let backgroundImage: URL?         // 代表遊戲的背景圖片的URL
    let metacritic: Int?              // 遊戲在Metacritic平台上的評分
    let genres: [GameGenres]?         // 這款遊戲所屬的類型列表，例如：動作、冒險等
}

/// 描述API返回的遊戲類型的結構體
struct GameGenres: Codable {
    let name: String                  // 遊戲類型的名稱，動作、冒險等。
}
