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
func WBFetchTrendsData(maxId:Int,asyncCallback:(()->Void)?){
    let param = ["access_token":global.kAccessToken,"max_id":maxId] as [String : Any]
    let baseUrl = URL.init(string: "https://api.weibo.com/2/statuses/home_timeline.json")!
    Alamofire.request(baseUrl, method: .get, parameters: param, encoding: URLEncoding.default, headers: nil)
        .responseJSON(queue: DispatchQueue.global(), options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                let responseJSON = response.result.value as! NSDictionary
                let trends = responseJSON["statuses"] as! [NSDictionary]
                CacheManager.trendsCache.append(contentsOf: trends)
                //提前缓存小尺寸图片，加快cell的加载速度
                let onePicTrendThumbNailUrls = trends.flatMap({ (trend) -> [String] in
                    let picUrls = trend["pic_urls"] as! [NSDictionary]
                    return picUrls.count == 1 ? [picUrls.first!["thumbnail_pic"] as! String] : []
                })
                WBCachingSamllTrendPic(urls: onePicTrendThumbNailUrls, batchCallBack: {
                    if let acb = asyncCallback {acb()}
                })
                CacheManager.trendsNext_cursor = responseJSON["next_cursor"] as! Int
            }
    }
}

func WBInitFetch(callBack:@escaping ()->Void){
    WBFetchTrendsData(maxId: 0, asyncCallback: callBack)
}
//缓存用户头像
func WBFetchUserAvatar(url:String,userId:String,callBack:(()->Void)?){
    Alamofire.request(URL.init(string: url)!).responseData { (response) in
        let imageData = response.result.value!
        let avatar = UIImage.init(data: imageData)!
        CacheManager.userAvatarCache[userId] = avatar
        if let cb = callBack{cb()}
    }
}
//缓存微博图片
//改成SDWebImage
func WBCachingSamllTrendPic(urls:[String],batchCallBack:(()->Void)?){
    let picUrls = urls.map { (urlStr) -> URL in
        return URL.init(string: urlStr)!
    }
    SDWebImagePrefetcher.shared().prefetchURLs(picUrls, progress: { (downloaded, total) in
        print("\(downloaded)/\(total)")
    }) { (finished, skipped) in
        print("number of skipped:\(skipped)")
        for (index,url) in picUrls.enumerated(){
            let id = String(urls[index].split(separator: "/").last!.split(separator: ".").first!)
            let key = SDWebImageManager.shared().cacheKey(for: url)!
            CacheManager.trendsPicCache[id] = SDImageCache.shared().imageFromCache(forKey: key)
            print(CacheManager.trendsPicCache[id] == nil)
        }
        if let bcb = batchCallBack{ bcb() }
    }
}

