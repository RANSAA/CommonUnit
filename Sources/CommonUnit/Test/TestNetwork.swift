//
//  File.swift
//  
//
//  Created by kimi on 2024/4/14.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif
import AsyncHTTPClient
import NIO
import NIOCore
import NIOHTTP1
import NIOFoundationCompat


import Alamofire

/**
 测试封装的3中网络请求工具
 */


class TestNetwork{
    
    //启动所有测试任务
    static func test(){
//        self.testVaporNetworkTool()
//
//        self.testURLNetworkTool()
        
//        self.testAFNetworkTool()
        
        self.testAFNetworkToolRedirect()
    }

}


extension TestNetwork{
    
    //测试VaporNetworkTool
    static func testVaporNetworkTool(){
//        let url = "https://apple.com/"
//        let url = "https://mirror.ghproxy.com/https://raw.githubusercontent.com/ctsfork/web/main/iptv/hd-live.txt"
//        let url = "https://m1.m3u8111222333.com/I0330/jrjs/jrjs.m3u8"
//        let url = "https://www.666rro.com"
        let url = "https://www.999ddk.com/"
//        let url = "http://335pai.com"
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        var path:String? = "/Users/kimi/Desktop/http-test-1122-test.txt"
        path = nil
        
        let par = ["VaporNetworkTool":"vv"]
        let filepar = [RequestParameterFile(name: "test", data: path )]
        
        
        VaporNetworkTool.dataJSON(url: url, parameter: par, fileParameters: filepar, outputPath: path,method: .GET, operationQueue: queue) { resultData, statusCode, request, response in
            TKLog("Success Data:\(String(describing: resultData))  statusCode:\(statusCode)")
//            TKLog("Request:\(request)")
//            TKLog("Response:\(response)")
        } fail: { error, request in
        }
        
        
//        //测试取消
//        DispatchQueue.global().asyncAfter(deadline: .now()+2.5) {
//            TKLog("2.5后取消下载...")
//            queue.cancelAllOperations()
//        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
    
    

    
    
    
    //测试URLNetworkTool
    static func testURLNetworkTool(){
//        let url = "https://apple.com/"
        let url = "https://mirror.ghproxy.com/https://raw.githubusercontent.com/ctsfork/web/main/iptv/hd-live.txt"
//        let url = "https://m1.m3u8111222333.com/I0330/jrjs/jrjs.m3u8"
//        let url = "https://www.666rro.com"
//        let url = "https://www.999ddk.com/"
//        let url = "http://335pai.com"
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        
        let par = ["URLNetworkTool":"vv"]
        
        URLNetworkTool.dataJSON(url: url,parameter: par, method: .POST, operationQueue: queue) { resultData, statusCode, request, response in
            TKLog("Success Data:\(String(describing: resultData))  statusCode:\(statusCode)")
        } fail: { error,request in
            TKLog("ERROR:\(error)")
        }

        queue.waitUntilAllOperationsAreFinished()
    }
    
    
    
    
    
    
    //测试AFNetworkTool
    static func testAFNetworkTool(){
        let url = "https://apple.com/"
//        let url = "https://www.jianshu.com/u/321ee974f45c"
//        let url = "https://mirror.ghproxy.com/https://raw.githubusercontent.com/ctsfork/web/main/iptv/hd-live.txt"
//        let url = "https://m1.m3u8111222333.com/I0330/jrjs/jrjs.m3u8"
//        let url = "https://www.666rro.com"
//        let url = "https://www.999ddk.com/"
//        let url = "http://335pai.com"
        
        AFNetworkTool.isLogResponse = true
        AFNetworkTool.isLog = true
        AFNetworkTool.isLogHeaders = true
        
        
        
        let headers:[String:String] = ["header-test":"11111"]
        
        let par:[String:Any] = [
            "string":"vv",
            "int":Int(111),
            "float":Float(222.22),
            "double":Double(333.33),
            "bool":true
        ]
        let filepars:[RequestParameterFile] = [
            RequestParameterFile(name: "file", data: "/Users/kimi/Desktop/111.txt"),
            RequestParameterFile(name: "data", data: "123".data(using: .utf8)!)
        ]
        
//        AFNetworkTool.dataJSON(url: url,parameter: par, fileParameters: nil,method: .POST,headers: headers) { resultData, statusCode, request, response in
//            TKLog("resultData:\(resultData)")
//            TKLog("statusCode:\(statusCode)")
//            TKLog("request:\(request)")
//            TKLog("response:\(response)")
//        } fail: { error, request in
//
//        }
        
//        AFNetworkTool.dataQuery(url: url, parameter: par, fileParameters: filepars, method: .POST, headers: headers) { resultData, statusCode, request, response in
//            TKLog("resultData:\(resultData)")
//            TKLog("statusCode:\(statusCode)")
//            TKLog("request:\(request)")
//            TKLog("response:\(response)")
//        } fail: { error, request in
//
//        }

        
        
        let queue = OperationQueue()
        
        var savePath:String? = "/Users/kimi/Desktop/123.txt"
        savePath = nil
        
        AFNetworkTool.dataJSON(url: url,parameter: par, fileParameters: filepars, outputPath: savePath, method: .POST,headers: headers, operationQueue: queue) { resultData, statusCode, request, response in
            TKLog("resultData:\(resultData)")
            TKLog("statusCode:\(statusCode)")
            TKLog("request:\(request)")
            TKLog("response:\(response)")
        } fail: { error, request in

        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        
//        let seamp = DispatchSemaphore(value: 0)
//        seamp.wait()
    }
    
    
    static func testAFNetworkToolRedirect(){
        let url = "https://www.999ccp.com"
        let queue = OperationQueue()
        
//        AFNetworkTool.string(url: url,operationQueue: queue) { resultData, statusCode, request, response in
//            TKLog("success:\n\(resultData?.count) \nstatusCode:\n\(statusCode)\nrequest:\n\(request)\nresponse:\n\(response)")
//        } fail: { error, request in
//            TKLog("error:\(error)   request:\(request)")
//        }

        
        URLNetworkTool.string(url: url,operationQueue: queue) { resultData, statusCode, request, response in
            TKLog("success:\n\(resultData?.count) \nstatusCode:\n\(statusCode)\nrequest:\n\(request)\nresponse:\n\(response)")
        } fail: { error,request in
            TKLog("error:\(error)   ")
        }
        
        queue.waitUntilAllOperationsAreFinished()
    }
}
