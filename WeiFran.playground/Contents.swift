import UIKit
import Foundation
import PlaygroundSupport
func numberAbbr(Num:Int)->String{
    if Num < 1000 {
        return String(Num)
    }else if Num < 10000 {
        return String.init(format: "%.2fK", Float(Num)/1000)
    }else {
        return String.init(format: "%.2fW", Float(Num)/10000)
    }
}

print(numberAbbr(Num: 34567))
