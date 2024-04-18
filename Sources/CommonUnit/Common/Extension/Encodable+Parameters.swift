//
//  Encodable+Parameters.swift
//  
//
//  Created by kimi on 2024/1/7.
//

import Foundation

/**
 
 */


extension Encodable{
    
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
//MARK: - 这儿还有点问题，目前无法获取父类中的数据, 可以使用那个打印函数
    


}

extension Encodable{
    
    /**
     将实现了Encodable的模型转换成Quary格式的字符串， 形如： key1=value1&key2=value2 的String数据
     */
    var parametersQuaryString:String{
        var parts: [String] = []
        let data = self.parametersJSONData
//        let dict = self.dictParameters
        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
            for (key, value) in dict {
                let part = "\(key)=\(value)"
                parts.append(part as String)
            }
        }
        
        var result = parts.joined(separator: "&")
        if let enc = result.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            result = enc
            /**
             注意：将编码后的“+”替换成"%2B"；用来解决"+"解码后成为空格的问题
             */
            result = result.replacingOccurrences(of: "+", with: "%2B")
        }
        return result
        
        
//        let dict = self.dictParameters
//        for (key, value) in dict {
//            let part = "\(key)=\(value)"
//            parts.append(part as String)
//        }
//        var result = parts.joined(separator: "&")
//        if let enc = result.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
//            result = enc
//        }
//        return result
    }
    
    /**
     将实现了Encodable的模型转换成Quary格式字符串所对应的Data， 形如： key1=value1&key2=value2 格式的Data数据
     */
    var parametersQuaryData:Data{
        if let data = self.parametersQuaryString.data(using: .utf8) {
            return data
        }
        return Data()
    }
}


extension Encodable{

    /**
     将实现了Encodable的模型转换成JSON格式的字符串, 形如：{"key1":"value1","key2":"vaule2"} 的String数据
     */
    var parametersJSONString:String{
        if let jsonString = modelToJsonString(model: self){
            return jsonString
        }
        return "{}"
    }
    
    /**
     将实现了Encodable的模型转换成Quary格式字符串所对应的Data， 形如： key1=value1&key2=value2 格式的Data数据
     */
    var parametersJSONData:Data{
        if let data = modelToJsonData(model: self) {
            return data
        }
        return Data()
    }
}



