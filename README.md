# 🎮 HW_JSONDecoder – RAWG 遊戲資料查詢 App

這是一個使用 [RAWG Video Games Database API](https://rawg.io/apidocs) 製作的 iOS 小專案。
使用 Swift + UIKit 實作，主要練習 JSON 解碼、API 資料串接與 TableView 資料展示。

---

## 🚀 專案目標

1. 練習申請 API Key，閱讀 API 文件與觀察網站資料
2. 選擇合適的 API endpoint，取得 JSON 並進行解析
3. 實作搜尋功能，搜尋特定遊戲資料
4. 使用 `SPM` 安裝第三方套件：Kingfisher，顯示圖片

---

## 🧩 使用技術

- UIKit / Storyboard
- RESTful API 串接（URLSession）
- JSONDecoder + Codable 結構
- UISearchBar + UITableView
- SFSafariViewController（網站開啟）
- Kingfisher（圖片快取）
- 手刻圓環進度條（CAShapeLayer）

---

## 🔄 專案流程概述

1. 在 `AllGameListTableViewController` 中向 RAWG API 請求遊戲清單。
2. 取得清單後，使用每個遊戲的 ID 向 API 預先請求詳細資料。
3. 詳細資料以 `gameDetails[ID]` 字典方式快取儲存。
4. 當使用者點擊 cell，根據該 ID 傳遞詳細資料給 `GameDetailViewController`。
5. 顯示圖片、文字描述、開發商、類型、評分圓環等資訊。

---

## 📡 使用的 API

- `GET /games`：取得遊戲清單，支援搜尋與條件過濾（metacritic, platforms）
- `GET /games/{id}`：取得特定遊戲的詳細資訊

API 文件清楚易懂，且支援免費帳號使用。

---

## 📷 畫面預覽（可放 Screenshot）

- 遊戲清單（含搜尋）
- 詳細頁（圖片、描述、評分圓環、分享、開啟網站）

## 📦 安裝方式

1. Clone 專案
2. 使用 Xcode 開啟 `.xcodeproj`
3. 安裝依賴（Kingfisher via Swift Package Manager）
4. 將 `buildAPIURL` 中的 `myApiKey` 替換為你自己的 RAWG API key
5. Run 起來！

---

## 📝 備註

- 該專案僅為練習用途，無使用影片 API（免費帳號限制）
- 如果遇到 API 無法連線，請檢查 key 是否有效

---

## 🙋‍♂️ 聯絡我 Contact

- GitHub: [你的帳號](https://github.com/你的帳號)
- Medium: [你的 Medium 名稱](https://medium.com/@你的帳號)