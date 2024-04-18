//
//  File.swift
//  
//
//  Created by kimi on 2024/4/17.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif
//import curl_swift
//import AsyncHTTPClient

import SwiftSoup




/**
 域名重定向地址获取
 说明:
 之前使用curl_swift的curl可以获取重定向地址，但是他与AsyncHTTPClient混用时会出现无法编译release文件的bug;
 所有目前直接使用URLSession来获取重定向地址。
 注意：如果URLSession无法获取重定向地址则可以尝试使用curl_swift
 */
class Redirect{
    private static let shared:Redirect = Redirect()
    private let semaphore:DispatchSemaphore
    
    private init(){
        semaphore = DispatchSemaphore(value: 0)
    }
    
    /** 利用URLSession进行请求 */
    private static func fech(url:String, task: @escaping (_ data: Data?,_ response: URLResponse?,_ error:Error?) -> Void ){
        let req = URLRequest(url: URL(string: url)!)
        let task = URLSession.shared.dataTask(with: req) { data , response, error in
            if let error {
                TKLog("重定向地址获取失败！    originalUrl:\(url)    error:\(error)")
            }
            task(data,response,error)
            self.shared.semaphore.signal()
        }
        task.resume()
        self.shared.semaphore.wait()
    }
}


extension Redirect{
    
    /**
     获取FourColorAV站点的重定向地址
     该方法用来解决URLSession在Linux新出现301重定向时崩溃的临时解决方案。
     */
    @discardableResult
    static func redirectFourColorAV(fechUrl:String = "https://www.666rro.com" ) -> String {
        let host = fechUrl
        var redirectUrl = host
        fech(url: fechUrl) { data, response, error in
            if let response, let url = response.url {
                redirectUrl = url.absoluteString
            }
        }
        if redirectUrl.last == "/"{
            redirectUrl.removeLast()
        }
        
        TKLog("FourColorAV重定向地址获取完成:   originalUrl:\(host)     redirectUrl:\(redirectUrl)")
        return redirectUrl
    }
    
}


extension Redirect{
    
    /**
     iKuuuVPN域名获取
     fechUrl:请求域名的地址 - https://ikuuu.club/
     ps:iKuuuVPN的默认重定向地址：https://ikuuu.pw/
     */
    @discardableResult
    static func redirectIKuuuVPN(fechUrl:String = "https://ikuuu.club/") -> String {
        let host = "https://ikuuu.pw/"
        var redirectUrl = host
        fech(url: fechUrl) { data, response, error in
            if let data, let html = String(data: data, encoding: .utf8){
                do {
                    let doc = try SwiftSoup.parse(html)
                    let rowline = try doc.select("body center p a")
                    if rowline.count > 0 {
                        let url = try rowline.first()!.attr("href")
                        redirectUrl = url
                    }
                } catch {
                    TKLog("iKuuuVPN重定向地址获取错误     HTML解析错误    Error:\(error)")
                }
            }
            
        }

        TKLog("iKuuuVPN重定向地址获取完成:   originalUrl:\(host)     redirectUrl:\(redirectUrl)")
        return redirectUrl
    }
    
}
