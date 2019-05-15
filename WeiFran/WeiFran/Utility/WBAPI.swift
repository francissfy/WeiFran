//
//  WBDataFetch.swift
//  WeiFran
//
//  Created by francis on 2019/5/5.
//  Copyright © 2019年 francis. All rights reserved.
//

import Foundation
import Alamofire
import SDWebImage

//Recommended
//如果只有一张图片则先缓存以计算尺寸
func WBFetchTrendsData(maxId:Int?,sinceId:Int?,asyncCallback:((_ numOfCached:Int)->Void)?){
    let param = ["access_token":global.kAccessToken,"max_id":maxId ?? 0,"since_id":sinceId ?? 0] as [String : Any]
    let baseUrl = URL.init(string: "https://api.weibo.com/2/statuses/home_timeline.json")!
    Alamofire.request(baseUrl, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
        .responseJSON(queue: DispatchQueue.global(), options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                let responseJSON = response.result.value as! NSDictionary
                let trends = responseJSON["statuses"] as! [NSDictionary]
                CacheManager.trendsCache.append(contentsOf: trends)
                //提前缓存小尺寸图片，加快cell的加载速度
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
                let bmiddlePic = convertImageUrlQuality(original: onePicTrendThumbNailUrls, quality: .Bmiddle)
                WBCachingSamllTrendPic(urls: bmiddlePic, batchCallBack: {
                    if let acb = asyncCallback {
                        acb(trends.count)
                    }
                })
                CacheManager.trendsNext_cursor = responseJSON["next_cursor"] as! Int
                CacheManager.trendsMax_id = responseJSON["since_id"] as! Int
            }
    }
}


func WBInitFetch(callBack:@escaping ()->Void){
    WBFetchTrendsData(maxId: nil, sinceId: nil) { (numOfCached) in
        callBack()
    }
}
//缓存微博图片
//改成SDWebImage
func WBCachingSamllTrendPic(urls:[String],batchCallBack:(()->Void)?){
    let picUrls = urls.map { (urlStr) -> URL in
        return URL.init(string: urlStr)!
    }
    /*
     //不重复缓存至CacheManager
    SDWebImagePrefetcher.shared().prefetchURLs(picUrls, progress: { (downloaded, total) in
    }) { (finished, skipped) in
        for (index,url) in picUrls.enumerated(){
            let id = String(urls[index].split(separator: "/").last!.split(separator: ".").first!)
            let key = SDWebImageManager.shared().cacheKey(for: url)!
            CacheManager.trendsPicCache[id] = SDImageCache.shared().imageFromCache(forKey: key)
        }
        if let bcb = batchCallBack{ bcb() }
    }
 */
    SDWebImagePrefetcher.shared().prefetchURLs(picUrls, progress: nil) { (finished, skipped) in
        print("finished:\(finished) with skipped:\(skipped)")
        if let bcb = batchCallBack {bcb()}
    }
}
//点赞
//不知道回传的结果是怎么样的
func WBGiveAttitudes(isSimle:Bool,trendId:Int,callBack:((_ isSuccess:Bool)->Void)?){
    let url = isSimle ? "https://api.weibo.com/2/attitudes/create.json":"https://api.weibo.com/2/attitudes/destroy.json"
    let parameter = ["access_token":global.kAccessToken,"id":trendId,"attitude":"simle"] as [String:Any]
    Alamofire.request(URL.init(string: url)!, method: .post, parameters: parameter, encoding: URLEncoding.default, headers: nil).response { (defaultDataResponse) in
        if let cb = callBack {
            cb(defaultDataResponse.error == nil)
        }
    }
}
//下拉获取新数据
func WBRefreshStatus(onFinished: @escaping(_ numOfNewTrends:Int)->Void){
    WBFetchTrendsData(maxId: nil, sinceId: CacheManager.trendsMax_id) { (numOfCached) in
        onFinished(numOfCached)
    }
}
func WBFetchingHistory(onFinished:@escaping(_ numOfHistoryFetched:Int)->Void){
    WBFetchTrendsData(maxId: CacheManager.trendsNext_cursor, sinceId: nil) { (numOfCached) in
        onFinished(numOfCached)
    }
}
//获取用户发布的微博
func WBFetechUserTrend(maxId:Int?,sinceId:Int?,uid:Int,callBack:@escaping(_ responseJSON:NSDictionary)->Void){
    let urlStr = "https://api.weibo.com/2/statuses/user_timeline.json"
    let parameter = ["access_token":global.kAccessToken,"uid":uid,"since_id":sinceId ?? 0,"max_id":maxId ?? 0] as [String:Any]
    Alamofire.request(URL.init(string: urlStr)!, method: .get, parameters: parameter, encoding: URLEncoding.default, headers: nil)
        .responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON = response.result.value as! NSDictionary
                callBack(responseJSON)
            }
    }
}
