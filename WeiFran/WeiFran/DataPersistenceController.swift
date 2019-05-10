//
//  DataPersistenceController.swift
//  WeiFran
//
//  Created by francis on 2019/5/5.
//  Copyright © 2019年 francis. All rights reserved.
//

import Foundation
class DataPersistenceController {
    static var timeLineCache:[NSDictionary] = []
    static var timeLineSince_id = 0
    static var timeLineNext_cursor = 0
    
    
    func createPlistCache(fileName:String)->String{
        let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        let filePath = cacheDirectoryPath + "/\(fileName).plist"
        return filePath
    }
    func writeArraytoPlistCache(with data:NSDictionary,at filePath:String)->Bool{
        return data.write(toFile: filePath, atomically: true)
    }
    func fillTimeLineWithCached()->Bool{
        
        return true
    }
    
    
    
    
}
