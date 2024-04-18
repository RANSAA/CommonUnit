//
//  File.swift
//  
//
//  Created by kimi on 2024/1/5.
//

import Foundation



//MARK: - Description


/**
 将model转换成JSONString
 */
func descriptionModel<T:Encodable>(_ model:T) -> String{
    let objName = "\(type(of: model))"
    var res = objName
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // 可选：使JSON数据格式化输出，便于阅读
        let jsonData = try encoder.encode(model)
        
        // 将JSON数据转为字符串
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            res = "<\(objName)>\n" + jsonString + "\n</\(objName)>"
        }
    } catch {
        print("Error encoding person to JSON: \(error)")
    }
    return res
}
