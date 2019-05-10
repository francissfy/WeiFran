import UIKit
import Foundation
import PlaygroundSupport

let queue = DispatchQueue.init(label: "cus")


func executeTask(array:[Int]){
    var taskCount = array.count
    for item in array{
        queue.async {
            print("exe task \(item) in Thread: \(Thread.current)")
            Thread.sleep(forTimeInterval: TimeInterval.init(1))
            taskCount -= 1
            if taskCount == 0{print("work finished")}
        }
        
    }
}

let array = [1,2,3,4,5,6,7,8,9]
executeTask(array: array)
