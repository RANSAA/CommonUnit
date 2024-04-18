//
//  File.swift
//  
//
//  Created by kimi on 2024/1/5.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif





/**
 QueryParameters:将模型转换成网络各种请求参数的协议
 */
protocol QueryParameters{

}


extension QueryParameters{
    
    /// 将属性与值转换成字典时，是否解包可选值
    var isUnwrappedValue:Bool{
        true
    }
    
    /// 将属性与值转换成字典时，是否获取值为nil的属性，true：排除值为nil的属性 false：nil对应属性的值为Optional(nil)
    var isNilValue:Bool{
        false
    }
    
    /**
     获取属性与值组成的字典。
     形如: [key1:value1,key2:value2]
     */
    var dictParameters:[String:Any]{
        let dict = getAllPropertiesAndValues(of: self, isNilValue: self.isNilValue, isUnwrappedValue: self.isUnwrappedValue)
        return dict
    }
    
}

extension QueryParameters{

    /**
     该方法将model的属性与值生成形如: key1=value1&key2=value2 的参数字符串
     */
    var queryParameters: String {
        let dirt = self.dictParameters
        var parts: [String] = []
        for (key, value) in dirt {
            let part = "\(key)=\(value)"
            parts.append(part as String)
        }
        return parts.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    
    var queryParametersData: Data? {
        queryParameters.data(using: .utf8)
    }
    
    
    
    /**
     该方法将model的属性与值生成形如: key1=value1&key2=value2 的参数字符串
     */
    var queryStringParameters: String {
        let dirt = self.dictParameters
        var parts: [String] = []
        for (key, value) in dirt {
            let part = "\(key)=\(value)"
            parts.append(part as String)
        }
        return parts.joined(separator: "&").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    var queryDataParameters: Data? {
        queryParameters.data(using: .utf8)
    }

}


extension QueryParameters{
    /**
     该方法将model的属性与值生成形如: {"key1":"value1","key2":"vaule2"} 的JSON参数字符串
     注意与jsonStringParameters方法的区别。
     */
    var jsonStringParameters:String {
        if let data = self.jsonDataParameters, let string = String(data: data, encoding: .utf8) {
            return string
        }
        return ""
    }
    
    /**
     将jsonParameters的值转换成的Data的值
     */
    var jsonDataParameters:Data? {
        let dict = self.dictParameters
        var resData:Data? = nil
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            resData = data
        } catch {
            print("转换错误: \(error)")
        }
        return resData
    }
    
    
    
    
    
}




extension QueryParameters where Self:Encodable {
    

    /**
     该方法将model的属性与值生成形如: {"key1":"value1","key2":"vaule2"} 的JSON参数字符串
     注意与jsonStringParameters方法的区别。
     */
    var jsonParameters:String {
        modelToJsonString(model: self) ?? "{}"
    }
    
    /**
     将jsonParameters的值转换成的Data的值
     */
    var jsonParametersData:Data? {
        jsonParameters.data(using: .utf8)
    }
    

    /**
     该方法将model的属性与值生成形如: "{\"key1\":\"value1\",\"key2\":\"vaule2\"}" 的字符串。
     注意与jsonParameters方法的区别。
     */
    var jsonStringParameters: String?{
        guard let data = self.jsonStringParametersData else {
            return nil
        }
        let jsonStr = String(data: data , encoding: .utf8)
        return jsonStr
    }
    
    
    /**
     jsonStringParameters对应字符串的Data数据
     */
    var jsonStringParametersData:Data?{
        let jsonStringData = try? JSONSerialization.data(withJSONObject: self.jsonParameters, options: .fragmentsAllowed)
        return jsonStringData
    }
    

}

