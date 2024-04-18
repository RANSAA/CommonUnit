//
//  File.swift
//  
//
//  Created by kimi on 2024/4/2.
//

import Foundation


/**
 自定义网络响应错误Error
 */
struct ResponseError:Error,CustomStringConvertible{
    var msg:String //错误提示
    var info:Any?  //附加的数据
    
    var description: String{
        var res = "error:\(msg)"
        if let info {
            res = "error:\(msg)   info:\(info)"
        }
        return res
    }
}
