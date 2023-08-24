//
//  GameTableViewCell.swift
//  HW_JSONDecoder
//
//  Created by 曹家瑋 on 2023/8/21.
//

import UIKit

// 欄位部分客製化
class GameTableViewCell: UITableViewCell {
    /// 位於cell的遊戲封面
    @IBOutlet weak var gameImageView: UIImageView!
    /// 位於cell的遊戲名稱
    @IBOutlet weak var gameNameLabel: UILabel!
    /// 位於cell的遊戲發行日期
    @IBOutlet weak var gameReleasedLabel: UILabel!
    /// 位於cell的遊戲評分
    @IBOutlet weak var gameMetaciticRatingLabel: UILabel!
    /// 位於cell的遊戲風格
    @IBOutlet weak var gameGenresLabel: UILabel!
    /// 位於cell的圓環進度條
    @IBOutlet weak var circularProgressView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    /// 客製化遊戲 cell。
    /// - Parameters:
    ///  - cell: 要配置的 GameTableViewCell。
    ///  - item: 提供配置資訊的GameResult模型。
    func configre(with item: GameResult) {
        
        // 設置遊戲名稱
        gameNameLabel.text = item.name

        // 如果有遊戲封面圖片的URL，則使用Kingfisher加載並顯示它
        if let imageUrl = item.backgroundImage {
            gameImageView.kf.setImage(with: imageUrl)
        }

        // 由於我已經設置搜尋的條件一定要有分數75~100，但還是使用可選型別
        // 使用遊戲的metacritic評分來更新 評分Label 和 圓環進度條（如果沒有評分，則使用預設值顯示）
        if let metacriticValue = item.metacritic {
            gameMetaciticRatingLabel.text = metacriticValue.formatted()
            setupCircularProgress(for: metacriticValue)
        } else {
            gameMetaciticRatingLabel.text = "？"      // 當評分為nil時顯示問號（不會發生）
            setupCircularProgress(for: 0)        // 沒有評分時，圓環進度為0
        }

        // 更新遊戲的發行日期，如果沒有發行日期則顯示"Unknown"
        gameReleasedLabel.text = item.released ?? "Unknown"

        // 由於genres是array，因此將遊戲類型連接為一個字符串並設置到標籤上
        var genresText = ""
        for genre in item.genres ?? [] {
            if genresText.isEmpty {
                genresText = genre.name
            } else {
                genresText += ", " + genre.name
            }
        }
        gameGenresLabel.text = genresText
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
