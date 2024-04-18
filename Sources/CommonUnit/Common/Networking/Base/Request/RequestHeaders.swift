//
//  File.swift
//  
//
//  Created by kimi on 2024/4/2.
//

import Foundation

/**
 请求header的默认配置
 */
struct RequestHeaders{
    

}

//MARK: -

extension RequestHeaders{
    /**
     为Headers提供一些默认的参数与值
     */
    struct Headers{
        /**
         注意ContentType的值与Body传输方式有关
         ContentTypeVauleText：body值直接以字符串的方式传递
         ContentTypeVauleJson：body值以JSON格式编码传递，形如：{"key1":"value1","key2":"vaule2"} 格式对应的Data数据
         ContentTypeVauleUrlEncoded：body值以Query参数格式编码传递，形如：key1=value1&key2=value2 格式对应的Data数据
         ContentTypeVauleFormData：body值直接以Data表单的方式传递，传递参数是可支持不同的类型同时传递，比如同时传递“字符串”和最加的“Data”数据；
         并且还要在后面最加一个动态的boundary=UUID, 一个完整的示例:multipart/form-data; charset=utf-8; boundary=FrEgn4lXbSC2PaKmGn3DDA6idrVloJ5u
                
         */
        static let ContentType = "Content-Type"
        static let ContentTypeVauleText = "text/plain; charset=utf-8"
        static let ContentTypeVauleJson = "application/json; charset=utf-8"
        static let ContentTypeVauleUrlEncoded = "application/x-www-form-urlencoded; charset=utf-8"
        static let ContentTypeVauleFormData = "multipart/form-data; charset=utf-8"
        
        
        /**
         User-Agent
         UserAgentValueIPhone：移动iPhone设备
         UserAgentValueAndroid：移动安卓设备
         UserAgentValuePCEdge：PC版的Edge浏览器
         UserAgentValuePCSafari：PC版的Safari浏览器
         */
        static let UserAgent = "User-Agent"
        static let UserAgentValueIPhone = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_4 like Mac OS X) AppleWebKit/624.2 (KHTML, like Gecko) Version/11.7.22 Mobile/HRP3A5 Safari/624.2"
        static let UserAgentValueAndroid = "Mozilla/5.0 (Linux; Android 14; SM-T970) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6304.196 Mobile Safari/537.36"
        static let UserAgentValuePCEdge = "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.6271.212 Safari/537.36 Edg/120.0.2340.79"
        static let UserAgentValuePCSafari = "Mozilla/5.0 (Macintosh; Intel Mac OS X 11_17) AppleWebKit/631.8.13 (KHTML, like Gecko) Version/13.2 Safari/631.8.13"

        
        
        /**
         Accept
         */
        static let Accept = "Accept"
        static let AcceptValueAll = "*/*"
        static let AcceptValueDefault = "text/html,application/xhtml+xml,application/xml,application/json,text/javascript;q=0.9,*/*;q=0.8"

    }
}

//MARK: -

extension RequestHeaders{
    
    //提供的一个默认的header
    static var defaultHeader:[String:String]  {
        [
            Headers.ContentType: Headers.ContentTypeVauleUrlEncoded,
            Headers.UserAgent: Headers.UserAgentValuePCEdge,
            Headers.Accept: Headers.AcceptValueAll,
//            "Accept-Encoding":"br;q=1.0, gzip;q=0.8, deflate;q=0.6",
        ]
    }
    
}
