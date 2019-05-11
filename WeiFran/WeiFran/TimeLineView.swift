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
    var heightCache:[IndexPath:CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLineView.dataSource = self
        timeLineView.delegate = self
        timeLineView.estimatedRowHeight = 457
        timeLineView.register(UINib.init(nibName: "TimeLineViewNormalCell", bundle: nil), forCellReuseIdentifier: "TimeLineViewNormalCell")
        timeLineView.register(UINib.init(nibName: "TimeLineViewRetweetedCell", bundle: nil), forCellReuseIdentifier: "TimeLineViewRetweetedCell")
        WBInitFetch {
            DispatchQueue.main.async {
                self.timeLineView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightCache[indexPath] = cell.frame.height
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CacheManager.trendsCache.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //自动布局并缓存高度
        return heightCache[indexPath] ?? UITableView.automaticDimension
    }
    //需要重写数据源方法
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trend = CacheManager.trendsCache[indexPath.row]
        let trendId = trend["id"] as! Int
        if trend["retweeted_status"] != nil{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineViewRetweetedCell") as! TimeLineViewRetweetedCell
            if cell.tag == trendId {
                return cell
            }else{
                cell.trend = trend
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineViewNormalCell") as! TimeLineViewNormalCell
            if cell.tag == trendId {
                return cell
            }else{
                cell.trend = trend
                return cell
            }
        }
    }
}

