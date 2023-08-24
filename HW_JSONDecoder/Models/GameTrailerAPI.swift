//
//  GameTrailerAPI.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2023/8/22.
//

import Foundation

/// 用不到了，API的請求因為免費的關係，只能得到GTA5的影片。
struct GameTrailerResponse: Codable {
    let count: Int
    let results: [GameTrailer]
}

struct GameTrailer: Codable {
    let id: Int
    let name: String
    let data: TrailerData
}

struct TrailerData: Codable {
    let max: URL
}
