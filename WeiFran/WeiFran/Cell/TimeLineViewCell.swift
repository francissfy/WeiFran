//
//  TimeLineViewCell.swift
//  WeiFran
//
//  Created by francis on 2019/5/9.
//  Copyright © 2019 francis. All rights reserved.
//
import UIKit
import SDWebImage
//受限于API限制，只能实现NIB中的赞的功能，评论以及转发功能未实现
func numberAbbr(floatNum:Int)->String{
    if floatNum < 1000 {
        return String(floatNum)
    }else if floatNum < 10000 {
        return String.init(format: "%.2fK", floatNum/1000)
    }else {
        return String.init(format: "%.2fW", floatNum/10000)
    }
}

func timeAbbr(decodingDateFormatter:DateFormatter,encodingDateFormatter:DateFormatter,timeStr:String)->String{
    let processedStr = timeStr[timeStr.index(timeStr.startIndex, offsetBy: 4)..<timeStr.endIndex]
    let date = decodingDateFormatter.date(from: String(processedStr))!
    let numOfSeconds = -date.timeIntervalSinceNow
    if numOfSeconds < 3600 {
        //min
        return "\(Int(numOfSeconds/60)) min ago"
    }else if numOfSeconds < 36000 {
        //hour
        return "\(Int(numOfSeconds/3600)) hour ago"
    }else {
        //exact
        return encodingDateFormatter.string(from: date)
    }
}
func timeAbbr(timeStr:String)->String{
    let decodingDF = DateFormatter.init()
    decodingDF.dateFormat = "MMM dd HH:mm:ss ZZZZ yyyy"
    let encodingDF = DateFormatter.init()
    encodingDF.dateFormat = "MMM dd HH:mm yyyy"
    return timeAbbr(decodingDateFormatter: decodingDF, encodingDateFormatter: encodingDF, timeStr: timeStr)
}


@objc protocol CellInteractionDelegate:NSObjectProtocol {
    func didTapPic(imageUrl:String,indexInSubView:Int)
    func didTapTweet(indexPath:IndexPath)
    @objc optional func didTapLike(trendId:Int)
    @objc optional func didTapComment(trendId:Int)
    @objc optional func didTapForward(trendId:Int)
    func didTapRetweetedView(trendId:Int)
    func didTapNickName(user:NSDictionary)
}

class TimeLineViewNormalCell: UITableViewCell,TrendPicViewDelegate{
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    @IBOutlet weak var trendPicView: TrendPicView!
    //bottom buttons
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var forwardsBtn: UIButton!
    //delegate
    weak var delegate:CellInteractionDelegate?
    
    var trend:NSDictionary!{
        didSet{
            let postTime = timeAbbr(timeStr: trend["created_at"] as! String)
            let textContent = trend["text"] as? String
            let trendId = trend["id"] as! Int
            let likesCount = trend["attitudes_count"] as! Int
            let commentsCount = trend["comments_count"] as! Int
            let repostsCount = trend["reposts_count"] as! Int
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
            self.likesBtn.setTitle(numberAbbr(floatNum: likesCount) + " Likes", for: .normal)
            self.commentsBtn.setTitle(numberAbbr(floatNum: commentsCount) + " Comments", for: .normal)
            self.forwardsBtn.setTitle(numberAbbr(floatNum: repostsCount) + " Forwards", for: .normal)
            self.tag = trendId
        }
    }
    //图片点击的代理方法
    func didTapPicView(imageUrl: String, imageFrame: CGRect, indexInSubView: Int) {
        //传递
        delegate?.didTapPic(imageUrl: imageUrl, indexInSubView: indexInSubView)
    }
    
    @objc func handleLike(_ sender:UIButton){
        delegate?.didTapLike?(trendId: trend["id"] as! Int)
    }
    @objc func handleComment(_ sender:UIButton){
        delegate?.didTapComment?(trendId: trend["id"] as! Int)
    }
    @objc func handleForward(_ sender:UIButton){
        delegate?.didTapForward?(trendId: trend["id"] as! Int)
    }
    @objc func handleTapNickName(_ sender:UILabel){
        let user = trend["user"] as! NSDictionary
        delegate?.didTapNickName(user: user)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImageView.layer.cornerRadius = 5
        avatarImageView.layer.masksToBounds = true
        likesBtn.layer.cornerRadius = 5
        likesBtn.backgroundColor = UIColor.white
        likesBtn.setTitleColor(UIColor.darkGray, for: .normal)
        likesBtn.layer.masksToBounds = true
        //图片代理
        trendPicView.picTappedDelegate = self
        //按钮事件
        likesBtn.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        commentsBtn.addTarget(self, action: #selector(handleComment), for: .touchUpInside)
        forwardsBtn.addTarget(self, action: #selector(handleForward), for: .touchUpInside)
        //用户名代理
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.addTarget(self, action: #selector(handleTapNickName))
        nickNameLabel.isUserInteractionEnabled = true
        nickNameLabel.addGestureRecognizer(tapGesture)
        //优化cell显示
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
}
class TimeLineViewRetweetedCell: UITableViewCell,TrendPicViewDelegate {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    @IBOutlet weak var retweetedView: UIView!
    @IBOutlet weak var retweetedTextContentLabel: UILabel!
    @IBOutlet weak var retweetedPicView: TrendPicView!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var commentsBtn: UIButton!
    @IBOutlet weak var forwardsBtn: UIButton!
    weak var delegate:CellInteractionDelegate?
    
    @objc func handleTapNickName(_ sender:UILabel){
        let user = trend["user"] as! NSDictionary
        delegate?.didTapNickName(user: user)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //
        self.retweetedView.layer.cornerRadius = 5
        self.avatarImageView.layer.cornerRadius = 5
        self.avatarImageView.layer.masksToBounds = true
        self.nickNameLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer.init()
        tapGesture.addTarget(self, action: #selector(handleTapNickName))
        self.layer.shouldRasterize = true
        self.layer.drawsAsynchronously = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    func didTapPicView(imageUrl: String, imageFrame: CGRect, indexInSubView: Int) {
        print("tapped at \(indexInSubView+1)")
    }
    
    //数据源
    var trend:NSDictionary!{
        didSet{
            let postTime = timeAbbr(timeStr: trend["created_at"] as! String)
            let textContent = trend["text"] as? String
            let trendId = trend["id"] as! Int
            let likesCount = trend["attitudes_count"] as! Int
            let commentsCount = trend["comments_count"] as! Int
            let repostsCount = trend["reposts_count"] as! Int
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
            self.retweetedTextContentLabel.numberOfLines = 5
            self.retweetedTextContentLabel.sizeToFit()
            self.retweetedPicView.viewModel = viewModel
            self.likesBtn.setTitle(numberAbbr(floatNum: likesCount) + " Likes", for: .normal)
            self.commentsBtn.setTitle(numberAbbr(floatNum: commentsCount) + " Comments", for: .normal)
            self.forwardsBtn.setTitle(numberAbbr(floatNum: repostsCount) + " Forwards", for: .normal)
        }
    }

}
