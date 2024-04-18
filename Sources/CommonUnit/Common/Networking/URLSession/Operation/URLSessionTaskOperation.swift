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
 AsyncOperation
 AsynchronousOperation
 实现Operation，可使URLSession任务按顺序执行，当: opeationQueue.maxConcurrentOperationCount = 1时。
 */
class URLSessionTaskOperation:AsyncOperation {
    weak private var task:URLSessionDataTask!
    weak private var session:URLSession!
    
    
    init(session:URLSession, req:URLRequest, completionHandler:@escaping (_ data:Data?, _ response:URLResponse?, _ error:Error?) -> Void ){
        super.init()
        self.session = session
        
        //request
        self.task = self.session.dataTask(with: req, completionHandler: {[weak self] data, response, error in
            guard let self = self else {
                print("⚠️⚠️⚠️⚠️:URLSession的引用对象已被提前销毁   ->  req：\(req)")
                return
            }
            defer{
                self.finish()
            }
            completionHandler(data,response,error)
        })
    }
        
    override func main() {
        if isCancelled {
            return
        }
        
        task?.resume()
    }
    
    override func cancel() {
        task?.cancel()
        super.cancel()
    }
    

    override func finish() {
        clear()
        super.finish()
    }
    
    /**
     清理URLSession相关内存
     说明:
        Operation对象需要OperationQueue将所有任务执行完毕才会释放，所有可以先将URLSession操作的相关对象置空
     */
     func clear(){
        if session != URLSession.shared {
//            session.finishTasksAndInvalidate()
        }
        session = nil
        task = nil
    }
    
    
}
