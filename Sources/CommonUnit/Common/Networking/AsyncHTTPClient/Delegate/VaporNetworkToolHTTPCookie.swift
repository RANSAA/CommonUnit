//
//  File.swift
//  
//
//  Created by kimi on 2024/4/17.
//

import Foundation
import AsyncHTTPClient


/**
 用于获取AsyncHTTPClient请求的cookie
 
 说明：
 1.该cookie是从HTTPClientResponse响应中的headers中获取的；
 并且每个cookie是分开的(猜想-未验证)，同一站点的请求并不会自动添加存在的cookie；
 URLSession在macOS，iOS下就会自动添加同站cookie信息。
 
 2. 该cookie是通过headers中的"set-cookie" 和 "cookie"字段获取的，其中“cookie”字段是自己添加的(非HTTP标准)。
 
 3. 其中执提取cookie的名称和值，其中过期时间、有效时间以及适用路径等信息将回被丢弃。
 
 
 注意：
 该工具目前并没有存储cookie，所有根据输入的URL获取对应的cookie值是不能实现的。
 */

class VaporNetworkToolHTTPCookie{
//    private let response:HTTPClientResponse
    
    
    //获取cookie原始数据列表，即包含所有cookie信息如：名称，值，过期时间，有效时间，即适用路径。
    let cookieOriginal:[String]
    
    //获取的到cookie列表，以k:v键值对的方式存储
    let cookieDict:[String:String]
    //获取的到cookie列表，以字符串编码方式存储
    let cookieString:String
    
    init(response:HTTPClientResponse){
//        self.response = response
        
        var _cookieOriginal:[String] = []
        var _cookiesDict:[String:String] = [:]
        var _cookieString:String = ""
        
        let cookies = response.headers["set-cookie"]
        for (index, cookie) in cookies.enumerated() {
//            TKLog("cookie:\(cookie)")
            _cookieOriginal.append(cookie)
            
            //获取每一个cookie的名称与值
            if let item = cookie.components(separatedBy: ";").first{
                let compare = item.components(separatedBy: "=")
                let name = compare[0]
                let value = compare[1]
                //
                _cookiesDict[name] = value
                if index == 0 {
                    _cookieString += "\(name)=\(value)"
                }else{
                    _cookieString += "; \(name)=\(value)"
                }
            }
        }
        
        cookieOriginal = _cookieOriginal
        cookieDict = _cookiesDict
        cookieString = _cookieString
    }
}
