//
//  static.swift
//  WeiFran
//
//  Created by francis on 2019/5/4.
//  Copyright © 2019年 francis. All rights reserved.
//

import Foundation
//用来定义https访问信息
class global{
    //user authenticate
    static var kAppkey:String = "1647017583"
    static var kRedirectURI:String = "https://api.weibo.com/oauth2/default.html"
    static var kAppSecret = "e4c64164144f8d7835c6dc80f239df60"
    static var kAccessToken = "2.00lK6p5GjVi9nB89e86841ccdpsYVC"
    static var kAuthCode = "e4c979da69b266593f1b5b19b36878b5"
    static var uid = ""
    //trends array
    static var trends:[NSDictionary] = []
    static var trendsNext_cursor = 0
}


