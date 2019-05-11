import UIKit
import Foundation
import PlaygroundSupport

func numberAbbr(num:String)->String{
    let floatNum = Float(num)!
    if floatNum < 1000 {
        return num
    }else if floatNum < 10000 {
        return String.init(format: "%.2fK", floatNum/1000)
    }else {
        return String.init(format: "%.2fW", floatNum/10000)
    }
}
print(numberAbbr(num: "9999"))
