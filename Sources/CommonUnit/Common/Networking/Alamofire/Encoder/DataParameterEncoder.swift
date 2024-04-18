//
//  File.swift
//  
//
//  Created by kimi on 2024/4/3.
//

import Foundation
import Alamofire


/**
 自定义的Alamofire参数编码器，用于编码纯粹的Data数据，用来适配AF的参数编码器。
 DataParameterEncoder支持的参数类型：
 1. DataParameterEncoder.data    //参数类型为Data
 2. DataParameterEncoder.string  //参数类型为String
 提示：
 该编码器一般与RequestParameter协同工作，主要是用来适配RequestParameter类型的参数的。
 注意：
 1. 编码器只能将参数编码到HTTPBody区域，而不能编码到URL Quary区域，如果需要URL Query可以使用RequestParameter.reqString获取编码后的参数;
 2. 编码器编码不受支持的参数类型时，会跳过对HTTP Body值的设置；
 3. 编码器并不会修改ContentType的值。

 
 
 Alamofire自带的参数编码器:
 1. URLEncodedFormParameterEncoder: 该编码器会将参数编码为形如:key1=value1&key2=value2的格式，并且会根据method自动判断是追加到URL中还是body中。
 .urlEncodedForm // ==  URLEncodedFormParameterEncoder.urlEncodedForm
 .urlEncodedQueryString // == URLEncodedFormParameterEncoder.urlEncodedQueryString
 URLEncodedFormParameterEncoder.urlEncodedQueryString  // == URLEncodedFormParameterEncoder(destination: .queryString)
 URLEncodedFormParameterEncoder.urlEncodedForm // == URLEncodedFormParameterEncoder(destination: .methodDependent))
 URLEncodedFormParameterEncoder.default // == URLEncodedFormParameterEncoder(destination: .methodDependent))
 URLEncodedFormParameterEncoder(destination: .methodDependent)) //根据method判断是将参数编码到body区域还是URL Query区域。
 URLEncodedFormParameterEncoder(destination: .httpBody) //总是将参数编码到body区域，如果method不支持在body中追加参数，将会编码失败。
 URLEncodedFormParameterEncoder(destination: .queryString) //总是将参数编码到URL Query区域，并且不受method的类型影响。
 注意：
 URLEncodedFormParameterEncoder只能编码形如[key:value]字典格式的参数，其它参数格式如：String,Data类型的参数将会编码失败；
 并且会设置header：Content-Type: application/x-www-form-urlencoded; charset=utf-8  其中.queryString方式将不会修改Content-Type的值。
 
 
 2.JSONParameterEncoder：该编码器会将参数编码为形如:{"key1":"value1","key2":"value2"}的格式(JSON格式)，如果method类型不支持向body中添加数据将会编码失败。
 .json // == JSONParameterEncoder.json
 JSONParameterEncoder.json //会将参数编码成JSON格式并添加到body区域。
 JSONParameterEncoder.default  // == JSONParameterEncoder.json
 JSONParameterEncoder.prettyPrinted //会将参数编码成JSON格式并添加到body区域，并对JSON格式化了。
 JSONParameterEncoder.sortedKeys  //会将参数编码成JSON格式并添加到body区域，并对JSON的key进行了排序。

 注意：
 URLEncodedFormParameterEncoder只能将形如[key:value]字典格式的参数编码成JSON格式到body区域；
 如果传入参数类型为：Int，String, Bool等基础类型将会直接转换为对应的值，并添加到body中；
 如果传入参数类型为：Date则会将其转换成对应的时间戳，并添加到body中；
 如果传入参数类型为：Data则会将其转化成Base64字符串，并添加到body中；
 并且总会设置header：Content-Type: application/json

 */
open class DataParameterEncoder: ParameterEncoder {

    fileprivate enum ParameterType{
        case data
        case string
        
        static var allTypes:String{
            "\(self.data), \(self.string)"
        }
    }
    
    fileprivate var type:ParameterType

    
    fileprivate init(type: ParameterType) {
        self.type = type
    }
    
    
    
    
    open func encode<Parameters: Encodable>(_ parameters: Parameters?,
                                            into request: URLRequest) throws -> URLRequest {
        guard let parameters else { return request }

        var request = request
        
        let method = RequestMethod(rawValue: request.method?.rawValue ?? "GET")
        if method.hasRequestBody != .no  {
            
            switch parameters {
            case let data  as Data:
                request.httpBody = data
            case let string as String:
                let data = string.data(using: .utf8)
                request.httpBody = data
            default:
                print("[\(self)]⚠️⚠️⚠️⚠️ - HTTPBody数据添加失败，AF.request传入的parameters的数据类型不被DataParameterEncoder支持，当前支持的类型：\(ParameterType.allTypes)")
            }
        }

        return request
    }
}


extension ParameterEncoder where Self == DataParameterEncoder {
    /**
     parameters参数的类型为Data
     */
    public static var data: DataParameterEncoder { DataParameterEncoder(type: .data) }
    /**
     parameters参数的类型为String
    */
    public static var string: DataParameterEncoder { DataParameterEncoder(type: .string) }
    
}




extension ParameterEncoder where Self == URLEncodedFormParameterEncoder {
    /// Provides a default `URLEncodedFormParameterEncoder` instance.
    public static var urlEncodedQueryString: URLEncodedFormParameterEncoder { URLEncodedFormParameterEncoder(destination: .queryString) }

}
