//
//  TimeLineViewCell.swift
//  WeiFran
//
//  Created by francis on 2019/5/9.
//  Copyright © 2019 francis. All rights reserved.
//
import UIKit
import SDWebImage

func numberAbbr(num:String)->String{
    let floatNum = Float(num)!
    if floatNum < 1000 {
        return num
    }else if floatNum < 10000 {
        return String.init(format: "%.2fK", floatNum/1000)
    }else {
        return String.init(format: "%.2fW", floatNum/10000)
    }
}

class TimeLineViewNormalCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    @IBOutlet weak var trendPicView: TrendPicView!
    var trend:NSDictionary!{
        didSet{
            let postTime = trend["created_at"] as! String
            let textContent = trend["text"] as? String
            let trendId = trend["id"] as! Int
            let usr = trend["user"] as! NSDictionary
            let avatarUrl = usr["avatar_large"] as! String
            let nickName = usr["screen_name"] as! String
            let urls = trendPicUrls(trend: trend, quality: TrendPicQuality.Bmiddle)
            let viewModel = TrendPicViewModel.init(picUrls: urls, trendId: trendId)
            self.avatarImageView.sd_setImage(with: URL.init(string: avatarUrl)!, placeholderImage: UIImage.init(named: "placeholder.png"), options: SDWebImageOptions.progressiveDownload, completed: nil)
            self.nickNameLabel.text = nickName
            self.postTimeLabel.text = postTime
            self.textContentLabel.text = textContent
            self.textContentLabel.numberOfLines = 0
            self.textContentLabel.sizeToFit()
            self.trendPicView.viewModel = viewModel
            self.tag = trendId
        }
    }
    
    override func awakeFromNib() {
        print("cell wake from nib")
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.layer.masksToBounds = true
        //优化cell显示
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
}
class TimeLineViewRetweetedCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    @IBOutlet weak var retweetedView: UIView!
    @IBOutlet weak var retweetedTextContentLabel: UILabel!
    @IBOutlet weak var retweetedPicView: TrendPicView!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        self.retweetedView.layer.cornerRadius = 5
        self.avatarImageView.layer.cornerRadius = 5
        self.avatarImageView.layer.masksToBounds = true
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    //数据源
    var trend:NSDictionary!{
        didSet{
            print("retweeted cell model setted")
            let postTime = trend["created_at"] as! String
            let textContent = trend["text"] as? String
            let trendId = trend["id"] as! Int
            let usr = trend["user"] as! NSDictionary
            let avatarUrl = usr["avatar_large"] as! String
            let nickName = usr["screen_name"] as! String
            let retweetedStatue = trend["retweeted_status"] as! NSDictionary
            let retweetedSourceUser = retweetedStatue["user"] as! NSDictionary
            let retweetedUserNickname = retweetedSourceUser["screen_name"] as! String
            let retweetedText = retweetedStatue["text"] as? String
            let retweetedPicUrls = trendPicUrls(trend: retweetedStatue, quality: TrendPicQuality.Bmiddle)
            let viewModel = TrendPicViewModel.init(picUrls: retweetedPicUrls, trendId: trendId)
            //
            self.tag = trendId
            self.avatarImageView.sd_setImage(with: URL.init(string: avatarUrl)!, placeholderImage: UIImage.init(named: "placeholder.png"), options: SDWebImageOptions.progressiveDownload, completed: nil)
            self.nickNameLabel.text = nickName
            self.postTimeLabel.text = postTime
            self.textContentLabel.text = textContent
            self.textContentLabel.numberOfLines = 0
            self.textContentLabel.sizeToFit()
            self.retweetedTextContentLabel.text = "@" + retweetedUserNickname + ":" + (retweetedText ?? "")
            self.retweetedTextContentLabel.numberOfLines = 4
            self.retweetedTextContentLabel.sizeToFit()
            self.retweetedPicView.viewModel = viewModel
        }
    }

}
