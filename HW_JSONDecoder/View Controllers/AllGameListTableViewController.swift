//
//  AllGameListTableViewController.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2023/8/21.
//

/*
 預先加載遊戲詳細資訊：可以在加載遊戲列表時預先加載所有遊戲的詳細信息，並將它們存儲在本地。
 這樣，當用戶點擊 cell 時，可以立即顯示詳細信息，而無需等待網路請求。這可以消除延遲感，但會增加初始加載時間。
 */

import UIKit
import Kingfisher

/// 預先加載的版本
class AllGameListTableViewController: UITableViewController {
    
    /// 搜尋 Bar
    @IBOutlet weak var searchBar: UISearchBar!
    
    /// 儲存從API獲取的遊戲列表
    var gameItems = [GameResult]()
    /// 儲存預先加載的遊戲詳細資訊，以遊戲ID作為key
    var gameDetails = [Int: GameDetailResponse]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 在View載入時獲取遊戲列表（URL已經加入metacritic參數（確保只搜尋75-100評分的）、以及PC平台、使用search特性）
        fetchGameList()
    }
    
    // MARK: - Table view data source

    // 返回表格的行數，等於遊戲項目的數量
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameItems.count
    }
    
    /// 當使用者點擊表格中的一行時會調用這個方法
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // 找出使用者點擊的遊戲ID
        let selectedGameId = gameItems[indexPath.row].id
        
        // print("Game with ID \(selectedGameId) was selected.")   // 測試：當遊戲被選中時
        
        // 如果已經有這個遊戲的詳細資訊，就進行下一步
        if let selectedGameDetail = gameDetails[selectedGameId] {
            // 跳轉到遊戲的GameDetailViewController頁面，並將遊戲的詳細資訊傳遞給下一個視圖控制器
            performSegue(withIdentifier: "showGameDetail", sender: selectedGameDetail)
        }
    }
    
    /// 將要跳轉到下一個視圖控制器之前，系統會調用這個方法
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 檢查是否正在執行正確的轉場，並且所有的數據類型都是正確的
        if segue.identifier == "showGameDetail",
           let destinationVC = segue.destination as? GameDetailViewController,
           let selectedGameDetail = sender as? GameDetailResponse {
            // 如果一切都正確，將使用者選定的遊戲詳細資訊設置到下一個視圖控制器中
            destinationVC.gameDetail = selectedGameDetail
            // print("Preparing to show details for game with ID \(selectedGameDetail.id).")   // 測試：當遊戲詳細資訊被傳遞前
        }
    }

    // 配置每一行的單元格cell（客製化）
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(GameTableViewCell.self)", for: indexPath) as? GameTableViewCell else {
            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
        }
        // 從遊戲列表中獲取當前行的遊戲
        let item = gameItems[indexPath.row]
        
        // 使用cell的configure方法進行cell配置
        cell.configre(with: item)
        
        return cell
    }
    
    
    /// 請求遊戲列表數據。（用於初始化加載、searchBarSearchButtonClicked使用）
    /// - Parameter searchQuery: 選填。當提供時，此函數將使用該查詢條件搜尋遊戲。預設為nil。
    func fetchGameList(searchQuery: String? = nil) {

        // 清空之前獲得的 gameDetails，以防舊數據影響新的數據
        gameDetails.removeAll()

        // 使用 'buildAPIURL' 建立遊戲列表的API URL
        if let gameUrl = buildAPIURL(forGameId: nil, searchQuery: searchQuery) {
            print("Fetching from URL: \(gameUrl)")      // 測試檢查完整的URL
            
            // 使用URLSession發起異步網絡請求
            URLSession.shared.dataTask(with: gameUrl) { data, response, error in
                if let data = data {
                    
                    // print(String(data: data, encoding: .utf8) ?? "Invalid data")    // print收到的JSON數據檢查錯誤
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase

                    do {
                        // 嘗試解碼從API獲得的數據
                        let gameListResponse = try decoder.decode(GameListResponse.self, from: data)
                        
                        self.gameItems = gameListResponse.results
                        // 預先加載每個遊戲的詳細資訊
                        for game in self.gameItems {
                            self.fetchGameDetail(withId: game.id)
                        }

                        // 在主線程上重新加載表格數據(確保UI操作在主線程上執行)
                        DispatchQueue.main.async {
                            // 重新加載表格以顯示新數據
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Error decoding JSON: \(error)") // 打印任何解碼錯誤
                    }
                }
            }.resume()  // 開始任務
        }
    }
    
    
    /// 遊戲的詳細內容（用於fetchGameList函數內加載每個遊戲Id）
    /// 預先加載每個遊戲的詳細資訊，並儲存在 gameDetails 字典裡
    func fetchGameDetail(withId id: Int) {
        
        // 這個方法負責預先加載遊戲詳細資訊 (使用buildAPIURL生成URL)
        if let gameDetailUrl = buildAPIURL(forGameId: id, searchQuery: nil) {
            
            // print 顯示正在獲取哪個遊戲的詳細資訊
            // print("Fetching details for game with ID: \(id)")
            
            URLSession.shared.dataTask(with: gameDetailUrl) { data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
    
                    do {
                        let gameDetail = try decoder.decode(GameDetailResponse.self, from: data)
                        // 將詳細資訊存儲在字典中，以便以後訪問
                        self.gameDetails[id] = gameDetail
                        
                        // print 來顯示已成功存儲哪個遊戲的詳細資訊
                        // print("Successfully fetched and stored details for game with ID: \(id)")
                    } catch {
                        print("Error decoding game detail: \(error)")
                    }
                }
            }.resume()
        }
    }

    
    /// 用於建立API URL的function。
    /// - Parameters:
    ///  - forGameId: 一個可選的遊戲ID。如果提供，將構建該遊戲的詳細資訊URL。否則，將構建一個遊戲列表URL。
    ///  - searchQuery: 一個可選的搜索查詢。如果提供，將在遊戲列表URL中加入搜索參數。
    /// - Returns: 一個表示API URL的可選URL對象。如果構建URL失敗，則返回nil。
    /// - Note: 主要考慮了兩種URL：一個用於檢索特定遊戲的詳細資訊，另一個用於檢索遊戲列表，還包括搜尋參數。
    func buildAPIURL(forGameId id: Int? = nil, searchQuery: String? = nil) -> URL? {
        
        // 使用API密鑰
        let myApiKey = APIKeyManager.rawgApiKey
        
        var urlString: String
        
        // 檢查是否提供遊戲ID
        if let gameId = id {
            // 建立「特定遊戲」的詳細資訊URL（用來得到其特定遊戲的JSON）
            urlString = "https://api.rawg.io/api/games/\(gameId)?key=\(myApiKey)"
            // print(urlString)    // 觀察遊戲Id生成的URL
        } else {
            // 預設狀態，建立「遊戲列表」URL（加入metacritic參數（確保只搜尋75-100評分的）、以及PC平台、使用search特性）
            urlString = "https://api.rawg.io/api/games?key=\(myApiKey)&metacritic=75,100&platforms=4&search_exact=true"
            
            // 檢查是否提供了搜索查詢
            if let query = searchQuery {
                // 對查詢字符串進行編碼並將其添加到URL中（重要：當有空格或特殊符號時進行轉碼）
                if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    urlString += "&search=\(encodedQuery)"
                }
            }
        }
        // 返回構建的URL
        return URL(string: urlString)
    }
    
}


/// UISearchBarDelegate的extension，處理與搜尋相關的事件。
extension AllGameListTableViewController: UISearchBarDelegate {
    
    /// 當用戶點擊搜尋欄的搜尋按鈕時，此方法將被調用。
    /// - Parameter searchBar: 觸發此代理方法的UISearchBar實例。
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 隱藏鍵盤
        searchBar.resignFirstResponder()
        
        // 檢查搜尋欄位是否有有效的查詢字符串。
        if let query = searchBar.text, !query.isEmpty {
            // print("Searching for: \(query)")   // 輸出查詢字符串測試。
            // 使用查詢字符串來搜尋遊戲。
            fetchGameList(searchQuery: query)
        } else {
            // 如果搜索欄位為空，則獲取所有遊戲列表
            fetchGameList()
        }
    }
}


// 初始版本（將遊戲 ID 傳遞給詳細資訊本身）
//import UIKit
//import Kingfisher
//
//class AllGameListTableViewController: UITableViewController {
//
//    /// 儲存從API獲取的遊戲列表
//    var gameItems = [GameResult]()
//    /// 用於儲存選定的遊戲詳細資訊
//    var selectedGameDetail: GameDetailResponse?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 在視圖載入時獲取遊戲列表
//        fetchItems()
//
//    }
//
//
//    @IBSegueAction func showGameDetail(_ coder: NSCoder) -> GameDetailViewController? {
//        // 檢查是否已經設置了選定的遊戲詳細資訊（selectedGameDetail）
//
//        if let selectedGameDetail = selectedGameDetail {
//            // 如果選定的遊戲詳細資訊存在，則使用它初始化GameDetailViewController
//            // 並返回該視圖控制器的實例
//            return GameDetailViewController(coder: coder, gameDetail: selectedGameDetail)
//        }
//        return nil   // 如果未設置選定的遊戲詳細資訊，則返回nil
//    }
//
//
//    // MARK: - Table view data source
//
//    // 返回表格的行數，等於遊戲項目的數量
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return gameItems.count
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedGame = gameItems[indexPath.row]
//        fetchGameDetail(withId: selectedGame.id)
//    }
//
//
//    // 配置每一行的單元格（客製化）
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(GameTableViewCell.self)", for: indexPath) as? GameTableViewCell else {
//
//            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
//        }
//
//        // 從遊戲列表中獲取當前行的遊戲
//        let item = gameItems[indexPath.row]
//
//        cell.gameNameLabel.text = item.name
//        cell.gameMetaciticRating.text = item.metacritic.formatted()
//        cell.gameReleasedLabel.text = item.released
//        cell.gameImageView.kf.setImage(with: item.backgroundImage)
//
//        // 由於genres是array，因此將遊戲類型連接為一個字符串並設置到標籤上（目前還不會高階函數）
//        var genresText = ""
//        for genre in item.genres {
//            if genresText.isEmpty {
//                genresText = genre.name
//            } else {
//                genresText += ", " + genre.name
//            }
//        }
//        cell.gameGenresLabel.text = genresText
//        return cell
//    }
//
//
//    // 從RAWG API獲取遊戲列表
//    func fetchItems() {
//
//        let myApiKey = ""
//        let gameListUrlString = "https://api.rawg.io/api/games?key=\(myApiKey)"
//
//        if let gameUrl = URL(string: gameListUrlString) {
//            URLSession.shared.dataTask(with: gameUrl) { data, response, error in
//                if let data = data {
//
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                    do {
//                        // 使用JSONDecoder解碼gameListResponse
//                        let gameListResponse = try decoder.decode(GameListResponse.self, from: data)
//                        self.gameItems = gameListResponse.results
//
//                        // 在主線程上重新加載表格數據
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
//
//                    } catch {
//                        print("Error decoding JSON: \(error)") // 打印任何解碼錯誤
//                    }
//                }
//            }.resume()  // 開始數據任務
//        }
//    }
//
//    /// 遊戲的詳細內容
//    func fetchGameDetail(withId id: Int) {
//        let myApiKey = ""
//        let gameDetailUrlString = "https://api.rawg.io/api/games/\(id)?key=\(myApiKey)"
//
//        if let gameDetailUrl = URL(string: gameDetailUrlString) {
//            URLSession.shared.dataTask(with: gameDetailUrl) { data, response, error in
//                if let data = data {
//
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                    do {
//                        let gameDetail = try decoder.decode(GameDetailResponse.self, from: data)
//
//                        DispatchQueue.main.async {
//                            self.selectedGameDetail = gameDetail     // 更新新屬性
//                            self.performSegue(withIdentifier: "showGameDetail", sender: self) // 執行segue
//                        }
//                        print(gameDetail)   // 測試用
//                    } catch {
//                        print(error)
//                    }
//                }
//            }.resume()
//        }
//    }
//
//
//}


//import UIKit
//import Kingfisher
//
//class AllGameListTableViewController: UITableViewController {
//
//    /// 儲存從API獲取的遊戲列表
//    var gameItems = [GameResult]()
//    /// 用於儲存選定的遊戲詳細資訊
//    var selectedGameDetail: GameDetailResponse?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // 在視圖載入時獲取遊戲列表
//        fetchItems()
//
//    }
//
//
//    @IBSegueAction func showGameDetail(_ coder: NSCoder) -> GameDetailViewController? {
//        // 檢查是否已經設置了選定的遊戲詳細資訊（selectedGameDetail）
//        if let selectedGameDetail = selectedGameDetail {
//            // 如果選定的遊戲詳細資訊存在，則使用它初始化GameDetailViewController
//            // 並返回該視圖控制器的實例
//            let controller = GameDetailViewController(coder: coder)
//            controller?.gameDetail = selectedGameDetail         // 設置遊戲詳細信息
//
//            return controller
//        }
//        return nil      // 如果未設置選定的遊戲詳細資訊，則返回nil
//    }
//
//
//    // MARK: - Table view data source
//
//    // 返回表格的行數，等於遊戲項目的數量
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return gameItems.count
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedGame = gameItems[indexPath.row]
//        fetchGameDetail(withId: selectedGame.id)
//    }
//
//
//    // 配置每一行的單元格（客製化）
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(GameTableViewCell.self)", for: indexPath) as? GameTableViewCell else {
//
//            fatalError("The dequeued cell is not an instance of GameTableViewCell.")
//        }
//
//        // 從遊戲列表中獲取當前行的遊戲
//        let item = gameItems[indexPath.row]
//
//        cell.gameNameLabel.text = item.name
//        cell.gameMetaciticRating.text = item.metacritic.formatted()
//        cell.gameReleasedLabel.text = item.released
//        cell.gameImageView.kf.setImage(with: item.backgroundImage)
//
//        // 由於genres是array，因此將遊戲類型連接為一個字符串並設置到標籤上（目前還不會高階函數）
//        var genresText = ""
//        for genre in item.genres {
//            if genresText.isEmpty {
//                genresText = genre.name
//            } else {
//                genresText += ", " + genre.name
//            }
//        }
//        cell.gameGenresLabel.text = genresText
//        return cell
//    }
//
//
//    // 從RAWG API獲取遊戲列表
//    func fetchItems() {
//
//        let myApiKey = " "
//        let gameListUrlString = "https://api.rawg.io/api/games?key=\(myApiKey)"
//
//        if let gameUrl = URL(string: gameListUrlString) {
//            URLSession.shared.dataTask(with: gameUrl) { data, response, error in
//                if let data = data {
//
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                    do {
//                        // 使用JSONDecoder解碼gameListResponse
//                        let gameListResponse = try decoder.decode(GameListResponse.self, from: data)
//
//                        self.gameItems = gameListResponse.results
//
//                        // 在主線程上重新加載表格數據
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
//
//                    } catch {
//                        print("Error decoding JSON: \(error)") // 打印任何解碼錯誤
//                    }
//                }
//            }.resume()  // 開始數據任務
//        }
//    }
//
//    /// 遊戲的詳細內容
//    func fetchGameDetail(withId id: Int) {
//        let myApiKey = ""
//        let gameDetailUrlString = "https://api.rawg.io/api/games/\(id)?key=\(myApiKey)"
//
//        if let gameDetailUrl = URL(string: gameDetailUrlString) {
//            URLSession.shared.dataTask(with: gameDetailUrl) { data, response, error in
//                if let data = data {
//
//                    let decoder = JSONDecoder()
//                    decoder.keyDecodingStrategy = .convertFromSnakeCase
//
//                    do {
//                        let gameDetail = try decoder.decode(GameDetailResponse.self, from: data)
//
//                        DispatchQueue.main.async {
//                            self.selectedGameDetail = gameDetail     // 更新新屬性
//                            self.performSegue(withIdentifier: "showGameDetail", sender: self) // 執行segue
//                        }
//                        print(gameDetail)   // 測試用
//                    } catch {
//                        print(error)
//                    }
//                }
//            }.resume()
//        }
//    }
//
//
//}


/*
 當用戶選擇一個遊戲以查看其詳細信息時，您的應用程序將從API獲取該遊戲的詳細信息，並將其存儲在selectedGameDetail屬性中。
 然後，可以在 @IBSegueAction 方法中使用此屬性來初始化GameDetailViewController。
 */

//        @IBSegueAction func showGameDetail(_ coder: NSCoder) -> GameDetailViewController? {
//            // 檢查是否已經設置了選定的遊戲詳細資訊（selectedGameDetail）
//            if let selectedGameDetail = selectedGameDetail {
//                // 如果選定的遊戲詳細資訊存在，則使用它初始化GameDetailViewController
//                // 並返回該視圖控制器的實例
//                return GameDetailViewController(coder: coder, gameDetail: selectedGameDetail)
//            }
//            return nil      // 如果未設置選定的遊戲詳細資訊，則返回nil
//        }
