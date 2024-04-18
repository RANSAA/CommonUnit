//
//  Dictionary+Parameters.swift
//  
//
//  Created by kimi on 2024/1/7.
//

import Foundation



/**
 该扩展为字典添加快速转换成JSONString，QuaryString和Data类型的可用于参数传递的常用类型。
 */

extension Dictionary where Key == String {

    

    /**
     获取所有Key-Value(如果是可选值就获取它的解包值)对组成的新字典，如果Value的真实值为nil，则该K-V对将会被排除在新字典之外。
     PS:新字典的所有值一定是不可选的。
     */
    var keyAndUnwrappedValues:[String:Any]{
        var dict:[String:Any] = [:]
        for (key, value) in self {
            if Mirror(reflecting: value).displayStyle == .optional {
                //只保留值为非nil得K-V
                if let unwrappedValue = Mirror(reflecting: value).children.first?.value {
                    dict[key] = unwrappedValue
                }
            }else{
                dict[key] = value
            }
        }
        return dict
    }
        
    
    
    /**
     是否允许keyAndUnwrappedValues，keyAndJSONValues属性获取的[String:Any]字典的Value的实际值能否为nil，默认false。
     如果允许：
     keyAndUnwrappedValues获取的字典中值为nil的Value将由NSNull()对象填充；
     keyAndValues获取的字典中值为nil的Value将由null表示；
     */
    var allowParametersNilValue:Bool{
        false
    }
    
    

    
    /**
     获取所有Key-Value(如果是可选值就获取它的解包值)对组成的新字典。新字典可以通过JSONSerialization序列化。
     并且将所有类型不为Bool,Number的Value将其类型转化成String,即调用Vlaue.describing方法。
     如果allowParametersNilValue的值为true时，所有值为nil的Value不会被排除，在被JSON String化后将由null表示nil值。
     如果allowParametersNilValue的值为false时，所有值为nil的K-V对将会被排除在新的字典之外。
     注意：如果允许nil,则其真实值为：Optional(nil)
     */
    var keyAndJSONValues:[String:Any]{
        var dict:[String:Any] = [:]
        for (key, value) in self {
            if Mirror(reflecting: value).displayStyle == .optional {
                //留值为非nil得K-V
                if let unwrappedValue = Mirror(reflecting: value).children.first?.value {
                    switch unwrappedValue{
                    case is Bool, is NSNumber:
                        dict[key] = unwrappedValue
                    default:
                        dict[key] = String(describing: unwrappedValue)
                    }
                }else{
                    //nil -> null
                    if self.allowParametersNilValue{
                        dict[key] = value
                    }
                }
            }else{
                switch value {
                case is Bool, is NSNumber:
                    dict[key] = value
                default:
                    dict[key] = String(describing: value)
                }
            }
        }
        return dict
    }
    
    
    /**
     将字典转换成JSON格式的字符串, 形如：{"key1":"value1","key2":"vaule2"} 的String数据
     */
    var parametersJSONString:String{
        var result = ""
        if let data = try? JSONSerialization.data(withJSONObject: self.keyAndJSONValues, options: .prettyPrinted),
            let jsonString = String(data: data, encoding: .utf8) {
            result = jsonString
        } else {
            print("parametersJSONString转换失败")
        }
        return result
    }
    
    /**
     将字段转换成JSON格式字符串所对应的Data， 形如：{"key1":"value1","key2":"vaule2"} 格式的Data数据
     */
    var parametersJSONData:Data{
        return self.parametersJSONString.data(using: .utf8) ?? Data()
    }
    
    /**
     将字典转换成Quary格式的字符串， 形如： key1=value1&key2=value2 的String数据
     */
    var parametersQuaryString:String{
        
        var parts: [String] = []
        for (key, value) in self.keyAndJSONValues {
            let part = "\(key)=\(value)"
            parts.append(part as String)
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
    }
    
    /**
     将字典转换成Quary格式字符串所对应的Data， 形如： key1=value1&key2=value2 格式的Data数据
     */
    var parametersQuaryData:Data{
        return self.parametersQuaryString.data(using: .utf8) ?? Data()
    }
    
}
