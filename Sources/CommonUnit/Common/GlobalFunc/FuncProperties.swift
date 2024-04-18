//
//  File.swift
//  
//
//  Created by kimi on 2024/1/5.
//

import Foundation


//MARK: - PropertiesAndValues




/// 获取对象的所有属性及其值组成的字典
/// - Parameters:
///   - object: 需要获取的对象
///   - isNilValue: 是否获取值为nil的属性。 true:获取值为nil的属性，即如果属性的值为nil则则它的值为Optional(nil)。 false：表示如果属性的值为nil，则该属性与值将被忽略，即该属性与值将不会再返回的字典中。
///   - isUnwrappedValue: 是否对可选属性的值(非nil)进行解包。
/// - Returns: 生成的字典
func getAllPropertiesAndValues<T>(of object: T, isNilValue:Bool = true, isUnwrappedValue:Bool = false) -> [String: Any] {
    let mirror = Mirror(reflecting: object)
    var properties = [String: Any]()
    
    for case let (label?, value) in mirror.children {
        //表示该值是一个可选值
        if Mirror(reflecting: value).displayStyle == .optional {
            //可选属性的值不为nil
            if let unwrappedValue = Mirror(reflecting: value).children.first?.value {
                if isUnwrappedValue {
                    properties[label] = unwrappedValue
                }else{
                    properties[label] = value
                }
            }else{
                if isNilValue {
                    properties[label] = value
                }
            }
        }else{
            properties[label] = value
        }
    }
    
    return properties
}
