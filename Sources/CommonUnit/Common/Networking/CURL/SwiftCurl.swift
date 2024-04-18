//
//  File.swift
//  
//
//  Created by kimi on 2024/3/13.
//

import Foundation
//import curl_swift

/**
 curl_swift: Swift包装的libcurl类
 
 ⚠️⚠️警告：不要与async-http-client（AsyncHTTPClient）库同时混用，因为它们之间有冲突bug，会出现无法编译release版本的二进制文件。
 ⚠️⚠️推荐：如果非必要情况不需要使用改库，因为原生的URLSession基本能实现改库的功能。
 
 
 .package(url: "https://github.com/khoi/curl-swift.git", branch: "main"),
 .product(name: "curl-swift", package: "curl-swift"),
 */
class SwiftCurl{
    
//    /**
//     获取FourColorAV站点的重定向地址
//     该方法用来解决URLSession在Linux新出现301重定向时崩溃的临时解决方案。
//     */
//    static func redirectFourColorAV(host:String = "https://www.666rro.com" ) -> String {
//        var host = host
//        print("四色AV站点Host地址重定向检测......")
//        print("输入Host地址:\(host)")
//        
//        do {
//            let req = CURL(method: "GET", url: host)
//            let res = try req.perform()
////            print("SwiftCurl res:\n\(res)")
//
//                    
//            for item in res.headers{
//                let text = item.description
//                if text.hasPrefix("location") {
//                    if let _host = text.components(separatedBy: ":").last?.trimmingCharacters(in: .whitespaces) {
//                        host = _host
//                        //这里的一个坑，有时候通过location获取的的从定向地址时协议后面没有":"冒号，形如：https//www.999cca.com
//                        //注意这个坑是curl_swift造成的。
//                        if host.hasPrefix("https//"){
//                            host = host.replacingOccurrences(of: "https//", with: "https://")
//                        }
//                        if host.hasPrefix("http//"){
//                            host = host.replacingOccurrences(of: "http//", with: "http://")
//                        }
//                        break
//                    }
//                }
//            }
//        } catch  {
//            print("SwiftCurl Error:\(error)")
//        }
//        
//        if host.last == "/"{
//            host.removeLast()
//        }
//        
//        print("重定向Host地址:\(host)")
//        return host
//    }
//    
    
}
