//
//  File.swift
//  
//
//  Created by kimi on 2024/1/20.
//

import Foundation

/**
 RequestParameter参数关联数据的类型
 */
enum RequestParameterAssociatedType{
    case string
    case data
    case dictJson
    case dictQuery
}

/**
 请求参数数据包装器
 */
enum RequestParameter {
    case string(String?)
    case data(Data?)
    /**
     将字段转换成JSON格式字符串所对应的Data， 形如：{"key1":"value1","key2":"vaule2"} 格式的Data数据
     */
    case dictJson([String: Any?]?)
    /**
     将字段转换成JSON格式字符串所对应的Data， 形如：key1=value1&key2=value2 格式的Data数据
     */
    case dictQuery([String: Any?]?)
    
    
    /**
     包装器具体数据关联的数据类型
     */
    var associatedType:RequestParameterAssociatedType{
        var type = RequestParameterAssociatedType.data
        switch self {
        case .data(_):
            type = .data
        case .string(_):
            type = .string
        case .dictJson(_):
            type = .dictJson
        case .dictQuery(_):
            type = .dictQuery
        }
        return type
    }
    

    /**
     获取枚举关联的值
     */
    var associatedValue:Any?{
        var value:Any? = nil
        switch self{
        case .data(let data):
            value = data
        case .string(let string):
            value = string
        case .dictQuery(let dic):
            value = dic
        case .dictJson(let dic):
            value = dic
        }
        return value
    }
    
    /**
     将枚举转换成用于请求的Data?
     */
    var reqData:Data?{
        var resData:Data? = nil
        switch self {
        case .string(let string):
            if let string, let data = string.data(using: .utf8) {
                resData = data
            }
        case .data(let data):
            resData = data
        case .dictJson(let dict):
            if let dictJson = dict {
                resData = dictJson.parametersJSONData
            }
        case .dictQuery(let dict):
            if let dictQuary = dict {
                resData = dictQuary.parametersQuaryData
            }
        }
        return resData
    }
    
    /**
     将reqData的String化
     */
    var reqString:String?{
        if let data = reqData{
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    

    /**
     获取参数编码格式
     */
    var format:String{
        var _fromat = ""
        
        switch self{
        case .data(_):
            _fromat = "Data"
        case .string(_):
            _fromat = "Text"
        case .dictQuery(_):
            _fromat = "Query URLEncoded"
        case .dictJson(_):
            _fromat = "JSON"
        }
        
        return _fromat
    }
    
    
}

