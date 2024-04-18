//
//  File.swift
//  
//
//  Created by kimi on 2024/2/23.
//


import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif


//MARK: - URLSessionTaskDelegate:处理在linux平台下的请求重定向问题
class URLNetworkToolDelegate:NSObject,URLSessionTaskDelegate{
    static let shared:URLNetworkToolDelegate = .init()
    
//    private let lock:DispatchSemaphore
//    private let barrierQueue:DispatchQueue
//    private let syncQueue:DispatchQueue
    
    override init() {
//        barrierQueue = DispatchQueue(label: "com.array.concurrent", attributes: .concurrent)
//        syncQueue = DispatchQueue(label: "com.example.lockqueue")
//        lock = DispatchSemaphore(value: 1)
    }
}



extension URLNetworkToolDelegate{

    /**
     Linux下处理站点重定向还是有问题，比如有些站点证书未验证并且需要重定向的站点就会发生崩溃，并且在该代理方法处理重定向依然无效崩溃。
     这些情况再macOS上都不会出现，只有在Linux下才会出现，Linux下URLSession只是对lib-curl库进行封装（个人猜测应该是证书问题，如果在本地信任证书可能就不会崩溃)。
     目前在Linux下所有基于URLSession的网络框架都会出现这个问题，并且目前并未找到有效的解决方案，但是可以使用Vapor的HTTPClient框架就不会出现这个问题。
     */
    func urlSession(_ session: URLSession, task: URLSessionTask,
       willPerformHTTPRedirection response: HTTPURLResponse,
       newRequest request: URLRequest,
       completionHandler: @escaping (URLRequest?) -> Void) {

//        TKLog("⚠️⚠️----1----网址从定向-----:currentRequest:\(String(describing: task.currentRequest))")
//        TKLog("⚠️⚠️-----2---网址从定向-----:task:\(String(describing: task.currentRequest?.allHTTPHeaderFields))")
//        TKLog("⚠️⚠️----3----网址从定向-----:newRequest:\(request)")
//        TKLog("⚠️⚠️----4----网址从定向-----:response:\(response)")
//        TKLog("⚠️⚠️----5----网址从定向-----:newRequest:\(request.allHTTPHeaderFields)")
//        TKLog("⚠️⚠️---\(response.allHeaderFields)")


        var newRequest : URLRequest? = request
//        var newRequest : URLRequest? = task.currentRequest
//        newRequest?.url = request.url
//        TKLog(newRequest)
//        TKLog(newRequest?.allHTTPHeaderFields)
        
        

        // 判断响应的状态码
        if response.statusCode == 301 || response.statusCode == 302 || response.statusCode == 307 {
           // 修改newRequest的属性，如：超时时间
           newRequest?.timeoutInterval = 10
        } else{
           newRequest = nil    // 取消重定向
        }
        completionHandler(newRequest)
    }
    
    
    /**
     注意：这个方法在linux Swift 5.7.3下面不执行，但是async/await特性是在Swift 5.5引入的。这说明Linux下的有许多bug
     */
    func urlSession2(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest) async -> URLRequest? {
//        TKLog("⚠️⚠️--------网址从定向-----:currentRequest:\(String(describing: task.currentRequest))")
//        TKLog("⚠️⚠️--------网址从定向-----:newRequest:\(request)")
//        TKLog("⚠️⚠️--------网址从定向-----:response:\(response)")

        var newRequest:URLRequest? = request
//        var newRequest : URLRequest? = task.currentRequest
//        newRequest?.url = request.url
        
        // 判断响应的状态码
        if response.statusCode == 301 || response.statusCode == 302 || response.statusCode == 307 {
           // 修改newRequest的属性，如：超时时间
           newRequest?.timeoutInterval = 10
        } else{
           newRequest = nil    // 取消重定向
        }
        return newRequest
    }
    

}
