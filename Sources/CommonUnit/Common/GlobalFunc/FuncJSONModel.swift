//
//  File.swift
//  
//
//  Created by kimi on 2024/1/5.
//

import Foundation

//MARK: - JSON To Model


/// Model转JSONData
/// - Parameter model: 实现了Encodable协议的变量
/// - Returns: JSONData
func modelToJsonData<T:Encodable>(model:T) -> Data? {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init(rawValue: 0)
        let jsonData = try encoder.encode(model)
        return jsonData
    } catch {
        return nil
    }
}



/// Model转JSONString
/// - Parameter model: 实现了Encodable协议的变量
/// - Returns: JSONString
func modelToJsonString<T:Encodable>(model:T) -> String? {
    if let jsonData = modelToJsonData(model: model), let jsonString = String(data: jsonData, encoding: .utf8)  {
        return jsonString
    }
    return nil
}



/// JSONData转Model
/// - Parameters:
///   - jsonData: 内容为JSONString的Data数据
///   - type: 转换的模型类型，模型需要实现Decodable协议
/// - Returns: 返回转化的模型对象
func jsonDataToModel<T:Decodable>(jsonData:Data?, type:T.Type) -> T? {
    guard let jsonData else {
        return nil
    }
    do {
        let decodedObject = try JSONDecoder().decode(type, from: jsonData)
        return decodedObject
    } catch {
        print("Error decoding JSON: \(error)")
        return nil
    }
}


/// JSONString 转 model
/// - Parameters:
///   - jsonString: 内容为JSON格式的字符串
///   - type: 转换的模型类型，模型需要实现Decodable协议
/// - Returns: 返回转化的模型对象
func jsonStringToModel<T:Decodable>(jsonString:String?, type:T.Type) -> T? {
    guard let jsonString else {
        return nil
    }
    let jsonData = jsonString.data(using: .utf8)
    return jsonDataToModel(jsonData: jsonData, type: type)
}




//MARK: - Json To Dictionary



/// 将model转换成[String:Any]类型的变量
/// - Parameter model: 需要转换的model对象
/// - Returns: 转换后的[String:Any]类型的变量
func modelToDictionary<T>(model: T) -> [String: Any]{
    let mirror = Mirror(reflecting: model)
    var dict = [String: Any]()
    for case let (label?, value) in mirror.children {
        dict[label] = value
    }
    return dict
}
