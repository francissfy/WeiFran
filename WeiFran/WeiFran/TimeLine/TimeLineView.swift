//
//  TimeLineView.swift
//  WeiFran
//
//  Created by francis on 2019/5/5.
//  Copyright © 2019年 francis. All rights reserved.
//
import UIKit
import SDWebImage

class TimeLineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CellInteractionDelegate {
    
    
    @IBOutlet weak var timeLineView: UITableView!
    var heightCache:[IndexPath:CGFloat] = [:]
    var pullPromptFooterView:PullPromptView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeLineView.dataSource = self
        timeLineView.delegate = self
        timeLineView.estimatedRowHeight = 457
        timeLineView.register(UINib.init(nibName: "TimeLineViewNormalCell", bundle: nil), forCellReuseIdentifier: "TimeLineViewNormalCell")
        timeLineView.register(UINib.init(nibName: "TimeLineViewRetweetedCell", bundle: nil), forCellReuseIdentifier: "TimeLineViewRetweetedCell")
        let refreshControl = UIRefreshControl.init()
        refreshControl.addTarget(self, action: #selector(refreshTrends), for: .valueChanged)
        timeLineView.refreshControl = refreshControl
        //footer
        let nibView = UINib.init(nibName: "TimeLinePullPrompt", bundle: nil)
        pullPromptFooterView = (nibView.instantiate(withOwner: nil, options: nil).first as! PullPromptView)
        
        WBInitFetch {
            DispatchQueue.main.async {
                self.timeLineView.reloadData()
            }
        }
    }
    //刷新控制
    @objc func refreshTrends(){
        WBRefreshStatus { (numOfCached) in
            DispatchQueue.main.async {
                self.timeLineView.refreshControl?.endRefreshing()
            }
            if numOfCached > 0 {
                DispatchQueue.main.async {
                    self.timeLineView.reloadData()
                }
            }
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {return 0}
        return 40
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {return nil}
        return pullPromptFooterView
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        heightCache[indexPath] = cell.frame.height
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {return 0}
        return CacheManager.trendsCache.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //自动布局并缓存高度
        return heightCache[indexPath] ?? UITableView.automaticDimension
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.height + 100 {
            pullPromptFooterView.startLoading()
            WBFetchingHistory { (numOfHistory) in
                var indexArray:[IndexPath] = []
                for i in CacheManager.trendsCache.count-numOfHistory..<CacheManager.trendsCache.count {
                    indexArray.append(IndexPath.init(row: i, section: 0))
                }
                DispatchQueue.main.async {
                    self.pullPromptFooterView.endLoading()
                    self.timeLineView.insertRows(at: indexArray, with: .bottom)
                }
            }
        }
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
                cell.delegate = self
                return cell
            }
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineViewNormalCell") as! TimeLineViewNormalCell
            if cell.tag == trendId {
                return cell
            }else{
                cell.trend = trend
                cell.delegate = self
                return cell
            }
        }
    }
    //cell中的代理方法
    //因为API问题不做补充
    func didTapPic(imageUrl: String, indexInSubView: Int) {
        //print("did tap pic \(indexInSubView+1)")
    }
    
    func didTapTweet(indexPath: IndexPath) {
        //print("did tap tweete")
    }
    
    func didTapRetweetedView(trendId: Int) {
        //print("did tap retweeted view")
    }
    //用户名点击跳转代理
    func didTapNickName(user: NSDictionary) {
        let userViewController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UserView") as! UserViewController
        userViewController.user = user
        userViewController.view.backgroundColor = UIColor.white
        self.navigationController?.pushViewController(userViewController, animated: true)
    }
}

class PullPromptView:UIView{
    @IBOutlet weak var promptLabel: UILabel!
    func startLoading(){
        promptLabel.text = "Loading ..."
    }
    func endLoading(){
        promptLabel.text = "Pull To Load More ..."
    }
}
