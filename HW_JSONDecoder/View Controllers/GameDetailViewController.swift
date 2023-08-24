//
//  GameDetailViewController.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2023/8/21.
//


import UIKit
import Kingfisher
import SafariServices

/// 遊戲詳細資料頁面
class GameDetailViewController: UIViewController {
    
    /// 詳細資訊頁面的主圖
    @IBOutlet weak var gameDetailImageView: UIImageView!
    /// 詳細資訊頁面的背景圖
    @IBOutlet weak var gameDetailBackgroundImageView: UIImageView!
    /// 詳細資訊頁面的遊戲描述
    @IBOutlet weak var gameDetailDescriptionTextView: UITextView!
    /// 詳細資訊頁面的遊戲名稱
    @IBOutlet weak var gameDetailName: UILabel!
    /// 詳細資訊頁面的遊戲開發商
    @IBOutlet weak var gameDetailGameDeveloper: UILabel!
    /// 遊戲類型
    @IBOutlet weak var gameDetailGenreLabel: UILabel!
    /// 評分
    @IBOutlet weak var gameDetailMetacriticLabel: UILabel!
    /// 圓環進度條（根據評分展示進度）
    @IBOutlet weak var circularProgressView: UIView!
    
    /// 選中的遊戲詳細資料
    var gameDetail: GameDetailResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設置遊戲詳細資訊
        setupGameDetails()
        
        // 創建透明的導航欄外觀
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        // 設置標準外觀和滾動外觀
        navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }

    /// 點擊前往遊戲官方網站（如果為nil則前往https://rawg.io/"）
    @IBAction func webSiteButtonTapped(_ sender: UIButton) {
        // 如果API請求的website為nil的話則使用defaultURL
        let defaultURL = URL(string: "https://rawg.io/")!
        let websiteURLString = gameDetail?.website
        let actualURL = URL(string: websiteURLString ?? "") ?? defaultURL
        
        // 創建一個SFSafariViewController實例來顯示網站
        let controller = SFSafariViewController(url: actualURL)
        // 呈現SFSafariViewController
        present(controller, animated: true, completion: nil)
    }
    
    /// 分享遊戲的詳細資訊
    @IBAction func shareInfoButtonTapped(_ sender: UIBarButtonItem) {
        
        // 準備分享的內容，遊戲名稱和網站URL
        let gameName = gameDetail?.name ?? "Game Name"
        let gameWebsiteURL = URL(string: gameDetail?.website ?? "https://rawg.io/")
        let gameDescription = gameDetail?.descriptionRaw
        
        // 創建一個包含要分享的項目的數組
        var shareItems: [Any] = [gameName]
        
        // 如果gameWebsiteURL不是nil，則添加到shareItems
        if let url = gameWebsiteURL {
            shareItems.append(url)
        }
          
        // 如果gameDescription不是nil，則添加到shareItems
        if let description = gameDescription {
            shareItems.append(description)
        }
        
        // 使用項目數組創建UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        // 呈現UIActivityViewController
        present(activityViewController, animated: true, completion: nil)
    }
    
    /// 設定遊戲詳細內容
    func setupGameDetails() {
        guard let gameDetail = gameDetail else { return }

        // 設置遊戲圖片、背景圖
        setupImages(from: gameDetail)
        // 設置描述內容
        gameDetailDescriptionTextView.text = gameDetail.descriptionRaw
        // 設置遊戲名稱
        gameDetailName.text = gameDetail.name

        // 使用for-in迴圈解析開發者名稱並設置到UILabel
        var developerNames: [String] = []
        for developer in gameDetail.developers {
            developerNames.append(developer.name)
        }
        let developerString = developerNames.joined(separator: ", ")
        gameDetailGameDeveloper.text = "\(developerString)"
        
        // 解析遊戲類型並設置到UILabel
        var genreNames: [String] = []
        for genre in gameDetail.genres {
            genreNames.append(genre.name)
        }
        let genresString = genreNames.joined(separator: ", ")
        gameDetailGenreLabel.text = genresString
        
        // 設置評分：由於我已經設置搜尋的條件一定要有分數75~100，但還是使用可選型別
        // 使用遊戲的metacritic評分來更新 評分Label 和 圓環進度條（如果沒有評分，則使用預設值顯示）
        if let metacriticValue = gameDetail.metacritic {
            gameDetailMetacriticLabel.text = metacriticValue.formatted()
            setupCircularProgress(for: metacriticValue)
        } else {
            gameDetailMetacriticLabel.text = "？"      // 當評分為nil時顯示問號（不會發生）
            setupCircularProgress(for: 0)        // 沒有評分時，圓環進度為0
        }
        
    }
    
    /// 設定圖片（背景圖、遊戲圖片）
    func setupImages(from detail: GameDetailResponse) {
        gameDetailImageView.kf.setImage(with: detail.backgroundImage)
        gameDetailBackgroundImageView.kf.setImage(with: detail.backgroundImage)
    }
    
    /// 設定圓環進度條
    func setupCircularProgress(for score: Int) {
        // 計算進度值，範圍從 0.0 到 1.0
        let progress = CGFloat(score) / 100.0
        
        // 設置圓環的半徑和線寬
        let radius = circularProgressView.frame.width / 2
        let lineWidth: CGFloat = 8
        
        // 創建一個圓形的路徑
        let circularPath = UIBezierPath(arcCenter: .zero, radius: radius - lineWidth / 2, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        // 創建背景圓環，作為進度條的背景
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor(red: 100 / 255, green: 108 / 255, blue: 118 / 255, alpha: 1).cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.position = CGPoint(x: circularProgressView.frame.width / 2, y: circularProgressView.frame.height / 2)
        circularProgressView.layer.addSublayer(backgroundLayer)
        
        // 創建進度圓環，根據遊戲評分展示進度
        let progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor(red: 213 / 255, green: 165 / 255, blue: 27 / 255, alpha: 1).cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.transform = CATransform3DMakeRotation(-.pi / 2, 0, 0, 1) // 旋轉以使進度條從頂部開始
        progressLayer.strokeEnd = progress // 設置進度
        progressLayer.position = CGPoint(x: circularProgressView.frame.width / 2, y: circularProgressView.frame.height / 2)
        circularProgressView.layer.addSublayer(progressLayer)
    }
}






//import UIKit
//import Kingfisher
//
//class GameDetailViewController: UIViewController {
//
//    @IBOutlet weak var gameDetailImageView: UIImageView!
//
//    @IBOutlet weak var gameDetailDescriptionTextView: UITextView!
//
//
//    var gameDetail: GameDetailResponse?
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setupGameDetails()
//
//    }
//
//    /// 設置詳細資料
//    func setupGameDetails() {
//        // 檢查gameDetail是否已設置
//        guard let gameDetail = gameDetail else { return }
//                setupImageView(with: gameDetail.backgroundImage)
//    }
//
//
//    func setupImageView(with imageUrl: URL) {
//        // 使用Kingfisher設置圖片
//        gameDetailImageView.kf.setImage(with: imageUrl)
//    }
//
//}
