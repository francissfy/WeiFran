//
//  Utility.swift
//  WeiFran
//
//  Created by francis on 2019/5/15.
//  Copyright © 2019 francis. All rights reserved.
//

import Foundation

enum TrendPicQuality {
    case Thumbnail
    case Bmiddle
    case Original
}


func numberAbbr(Num:Int)->String{
    if Num < 1000 {
        return String(Num)
    }else if Num < 10000 {
        return String.init(format: "%.2fK", Float(Num)/1000)
    }else {
        return String.init(format: "%.2fW", Float(Num)/10000)
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
