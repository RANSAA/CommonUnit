//
//  File.swift
//  
//
//  Created by kimi on 2023/11/3.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif


/**
 自定义一个异步可处理状态的Operation  - 实现方式一
 请注意:
 为了正确处理操作的状态，我们还覆盖了 `isExecuting` 和 `isFinished` 的属性，并在适当的时候调用 `finish()` 方法来更新操作的状态。
 这是确保操作队列能够正确管理操作的关键部分。
 
 参考地址:
 https://www.itguest.com/post/bhagbj1a2.html
 https://www.jianshu.com/p/65b3b3cfe9c7
 */
class AsyncOperation:Operation{
    override var isAsynchronous: Bool{
        true
    }


    private var _isExecuting = false
    override var isExecuting: Bool {
        get{
            return _isExecuting
        }
        set{
            willChangeValue(forKey: "isExecuting")
            _isExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }

    private var _isFinished = false
    override var isFinished: Bool {
        get{
            return _isFinished
        }
        set{
            willChangeValue(forKey: "isFinished")
            _isFinished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }

    final override func start() {
        if isCancelled {
            finish()
            return
        }

        willChangeValue(forKey: "isExecuting")
        _isExecuting = true
        didChangeValue(forKey: "isExecuting")

        main()
    }

    override func main() {
        fatalError("Subclasses must implement `main`.")
    }


    /** 标记当前Operation任务完成，重写时需要执行super */
    func finish() {
        willChangeValue(forKey: "isExecuting")
        willChangeValue(forKey: "isFinished")

        _isExecuting = false
        _isFinished = true

        didChangeValue(forKey: "isExecuting")
        didChangeValue(forKey: "isFinished")
    }
}












