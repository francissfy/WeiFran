//
//  TimeLineView.swift
//  WeiFran
//
//  Created by francis on 2019/5/5.
//  Copyright © 2019年 francis. All rights reserved.
//
import UIKit
import SDWebImage

class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var timeLineView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLineView.dataSource = self
        timeLineView.delegate = self
        timeLineView.estimatedRowHeight = 200
        timeLineView.register(UINib.init(nibName: "TimeLineViewNormalCell", bundle: nil), forCellReuseIdentifier: "TimeLineViewNormalCell")
        WBInitFetch {
            DispatchQueue.main.async {
                print("Finishing loading json")
                print(CacheManager.trendsPicCache)
                self.timeLineView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CacheManager.trendsCache.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //自动布局
        return UITableView.automaticDimension
    }
    //需要重写数据源方法
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineViewNormalCell") as! TimeLineViewNormalCell
        let trend = CacheManager.trendsCache[indexPath.row]
        let trendId = trend["id"] as! Int
        let urls = trendPicUrls(trend: trend)
        //cell config
        if cell.tag == trendId {
            //no action
        }else{
            //图像
            cell.tag = trendId
            let viewModel = TrendPicViewModel.init(picUrls: urls, trendId: trendId, index: indexPath)
            (cell.trendPicView as! TrendPicView).viewModel = viewModel
            //
            let usr = trend["user"] as! NSDictionary
            let avatarUrl = usr["profile_image_url"] as! String
            cell.avatarImageView.sd_setImage(with: URL.init(string: avatarUrl)!) { (opImage, opError, SDImageCacheType, opUrl) in
                if opError != nil {print(opError!.localizedDescription)}
            }
            cell.nickNameLabel.text = usr["screen_name"] as? String
            cell.postTimeLabel.text = trend["created_at"] as? String
            cell.textContentLabel.text = trend["text"] as? String
            cell.textContentLabel.numberOfLines = 0
            cell.textContentLabel.sizeToFit()
        }
        return cell
    }
    
}
class TimeLineViewCell:UITableViewCell{
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usrNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    @IBOutlet weak var textContentLabel: UILabel!
    @IBOutlet weak var picsView: UIView!
    @IBOutlet weak var picsViewHeightConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        // preparation for reuse
    }
}

