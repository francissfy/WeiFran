//
//  UserView.swift
//  WeiFran
//
//  Created by francis on 2019/5/13.
//  Copyright © 2019 francis. All rights reserved.
//

import UIKit
import SDWebImage
class UserViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CellInteractionDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var userTableView: UITableView!
    var userTrendsCache:[NSDictionary] = []
    var maxId:Int = 0
    var nextCursor:Int = 0
    
    var user:NSDictionary!{
        didSet{
            /*
            FetchTrends(maxId: nil, sinceId: nil) { (numFetched) in
                DispatchQueue.main.async {
                    self.userTableView.reloadData()
                }
            }
             */
        }
    }
    
    //获取微博数据
    func FetchTrends(maxId:Int?,sinceId:Int?,callback:@escaping(_ numFetched:Int)->Void){
        WBFetechUserTrend(maxId: maxId, sinceId: sinceId, uid: user["id"] as! Int) { (responseJSON) in
            let trends = responseJSON["statuses"] as! [NSDictionary]
            self.userTrendsCache.append(contentsOf: trends)
            self.nextCursor = responseJSON["next_cursor"] as! Int
            self.maxId = responseJSON["since_id"] as! Int
            let onePicTrendThumbNailUrls = trends.flatMap({ (trend) -> [String] in
                var retweetedUrl:[String] = []
                if let retweeted = trend["retweeted_status"] as? NSDictionary {
                    if retweeted["pic_urls"] != nil && (retweeted["pic_urls"] as! [NSDictionary]).count == 1 {
                        retweetedUrl.append((retweeted["pic_urls"] as! [NSDictionary]).first!["thumbnail_pic"] as! String)
                    }
                }
                let picUrls = trend["pic_urls"] as! [NSDictionary]
                return picUrls.count == 1 ? [picUrls.first!["thumbnail_pic"] as! String]+retweetedUrl : retweetedUrl
            })
            let onePicUrls = onePicTrendThumbNailUrls.map({ (urlStr) -> URL in
                return URL.init(string: urlStr)!
            })
            SDWebImagePrefetcher.shared().prefetchURLs(onePicUrls, progress: nil, completed: { (finished, skipped) in
                //
                callback(trends.count)
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //界面中要用到的Cell注册
        userTableView.register(UINib.init(nibName: "UserPageHead", bundle: nil), forCellReuseIdentifier: "UserPageHead")
        userTableView.dataSource = self
        userTableView.delegate = self
        //userTableView.register(UINib.init(nibName: "TimeLineViewNormalCell", bundle: nil), forCellReuseIdentifier: "normalCell")
        //userTableView.register(UINib.init(nibName: "TimeLineViewRetweetedCell", bundle: nil), forCellReuseIdentifier: "retweetedCell")
    }
    override func viewDidAppear(_ animated: Bool) {
        //导航栏透明
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    //顶部动效offset监听
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -88 && scrollView.contentOffset.y > -300 {
            (userTableView.cellForRow(at: IndexPath.init(row: 0, section: 0)) as! UserPageHeaderCell).modifyCoverImageTopMargin(constant: (300+scrollView.contentOffset.y)*150/212)
        }
    }
    //数据方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {return 1}
        return 0
        //垃圾微博封API
        //return userTrendsCache.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let head = tableView.dequeueReusableCell(withIdentifier: "UserPageHead") as! UserPageHeaderCell
        head.user = user
        return head
        /*
        if indexPath.section == 0 {
            let head = tableView.dequeueReusableCell(withIdentifier: "UserPageHead") as! UserPageHeaderCell
            head.user = user
            return head
        }
        let trend = userTrendsCache[indexPath.row]
        if trend["retweeted_status"] != nil {
            let cell = tableView.dequeueReusableCell(withIdentifier: "retweetedCell") as! TimeLineViewRetweetedCell
            cell.trend = trend
            cell.delegate = self
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "normalCell") as! TimeLineViewNormalCell
            cell.trend = trend
            cell.delegate = self
            return cell
        }
        */
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 480
    }
    //交互代理方法
    func didTapPic(imageUrl: String, indexInSubView: Int) {
        //
    }
    
    func didTapTweet(indexPath: IndexPath) {
        //
    }
    
    func didTapRetweetedView(trendId: Int) {
        //
    }
    
    func didTapNickName(user: NSDictionary) {
        //
    }
}
