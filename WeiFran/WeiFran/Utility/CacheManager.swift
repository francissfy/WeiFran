//
//  CacheManager.swift
//  WeiFran
//
//  Created by francis on 2019/5/6.
//  Copyright © 2019年 francis. All rights reserved.
//

import Foundation

enum TrendPicQuality {
    case Thumbnail
    case Bmiddle
    case Original
}


class CacheManager {
    //用户ID为索引idstr,用户头像缓存
    //static var userAvatarCache:[String:UIImage] = [:]
    //微博动态图片缓存，50X50规格,索引为图片的名称,只用来缓存只有一张照片的t微博图像
    static var trendsPicCache:[String:UIImage] = [:]
    //微博JSON缓存,索引为微博id,NSObject为NSDictionary
    static var trendsCache:[NSDictionary] = []
    static var trendsNext_cursor:Int = 0
    static var trendsMax_id:Int = 0
}
//relavent methods
func trendPicUrls(trend:NSDictionary,quality:TrendPicQuality?)->[String]{
    let picUrlsDic = trend["pic_urls"] as! [NSDictionary]
    let picUrlsThumbnail = picUrlsDic.map { (urlDic) -> String in
        return urlDic["thumbnail_pic"] as! String
    }
    if quality == nil{
        return picUrlsThumbnail
    }else{
        switch quality!{
        case .Thumbnail:
            return picUrlsThumbnail
        case .Bmiddle:
            return picUrlsThumbnail.map { (thumbnail) -> String in
                return thumbnail.replacingOccurrences(of: "thumbnail", with: "bmiddle")
            }
        case .Original:
            return picUrlsThumbnail.map { (thumbnail) -> String in
                return thumbnail.replacingOccurrences(of: "thumbnail", with: "large")
            }
        }
    }
}
func convertImageUrlQuality(original:[String],quality:TrendPicQuality)->[String]{
    switch quality {
    case .Thumbnail:
        return original
    case .Bmiddle:
        return original.map { (thumbnail) -> String in
            return thumbnail.replacingOccurrences(of: "thumbnail", with: "bmiddle")
        }
    case .Original:
        return original.map { (thumbnail) -> String in
            return thumbnail.replacingOccurrences(of: "thumbnail", with: "large")
        }
    }
}
