//
//  GameDetailAPI.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2023/8/21.
//

import Foundation

// 此API endpoint用於獲取特定遊戲的詳細資訊，其中 {id} 是該遊戲的唯一識別符。
// https://api.rawg.io/api/games/{id}


/// 用於解析從RAWG API返回的遊戲詳細資訊的結構體。
struct GameDetailResponse: Codable {
    let id: Int                        // 遊戲的唯一識別符
    let name: String                   // 遊戲名稱
    let metacritic : Int?              // 遊戲的Metacritic評分
    let backgroundImage: URL           // 遊戲的背景圖片URL
    let website: String?               // 遊戲的官方網站URL，可能為nil
    let developers: [GameDeveloper]    // 該遊戲的開發者列表
    let genres: [GameDetailGenres]     // 該遊戲的類型列表
    let descriptionRaw: String         // 遊戲的簡介描述
}

/// 代表遊戲開發者的結構體。
struct GameDeveloper: Codable {
    let name: String                   // 開發者的名稱
}

/// 代表遊戲的類型（如：動作、冒險、策略等）的結構體。
struct GameDetailGenres: Codable {
    let name: String
}
