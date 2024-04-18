//
//  File.swift
//  
//
//  Created by kimi on 2024/3/18.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif



/**
 用于获取HTTPCookie
 */
struct URLNetworkToolHTTPCookie {
    private let response:URLResponse
    private let url:URL
    
    //获取的到cookie列表，以HTTPCookie对象的方式存储
    private(set) var cookies:[HTTPCookie]
    //获取的到cookie列表，以k:v键值对的方式存储
    let cookieDict:[String:String]
    //获取的到cookie列表，以字符串编码方式存储
    let cookieString:String
    
    init(response: URLResponse) {
        self.response = response
        url = response.url!
        
        var _cookies:[HTTPCookie] = []
#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
        //TKLog("-----all cookies----:\(HTTPCookieStorage.shared.cookies)")
        if let __cookies = HTTPCookieStorage.shared.cookies(for: url ){
            _cookies = __cookies
        }
#else
        if let httpResponse = response as? HTTPURLResponse, let headerFields = httpResponse.allHeaderFields as? [String: String]{
            _cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: url)
        }
#endif
        cookies = _cookies
        
        var _cookiesDict:[String:String] = [:]
        var _cookieString:String = ""
        for (index, cookie) in cookies.enumerated(){
            let name = cookie.name
            let value = cookie.value
            _cookiesDict[name] = value
            if index == 0 {
                _cookieString += "\(name)=\(value)"
            }else{
                _cookieString += "; \(name)=\(value)"
            }
        }
        
        cookieDict = _cookiesDict
        cookieString = _cookieString
    }
    
}

extension URLNetworkToolHTTPCookie{
    
    /**
     获取指定域名中的所有HTTPCookie
     */
    static func cookies(with url:String) -> [HTTPCookie]{
        let url = URL(string: url)
        return cookies(with: url)
    }
    
    /**
     获取指定域名中的所有HTTPCookie
     */
    static func cookies(with url:URL?) -> [HTTPCookie]{
        var cookies:[HTTPCookie] = []
        if let url = url{
            if let __cookies = HTTPCookieStorage.shared.cookies(for: url ){
                cookies = __cookies
            }
        }
        return cookies
    }
    
    
}



extension URLNetworkToolHTTPCookie{
    /**
     删除HTTPCookieStorage.shared中的HTTPCookie
     */
    static func remove(cookie:HTTPCookie){
        HTTPCookieStorage.shared.deleteCookie(cookie)
    }
    
    /**
     删除HTTPCookieStorage.shared中的HTTPCookie
     */
    static func removes(cookies:[HTTPCookie]){
        for cookie in cookies{
            remove(cookie: cookie)
        }
    }
    
}


