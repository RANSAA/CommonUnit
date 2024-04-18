//
//  File.swift
//  
//
//  Created by kimi on 2024/1/15.
//

import Foundation


/**
 注意：该代码不能在Linux下运行
 */


#if os(macOS)




// MARK: - 获取class中的所有属性名称，变量名称， 利用objc runtime 特性获取

/**
 获取指定class对象的变量名，PS:不包括父类变量
 */
public func getAllIvars(class cls:AnyClass?) -> [String]{
    var result = [String]()
    let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
    let buff = class_copyIvarList(cls, count)
    let countInt = Int(count[0])
    for i in 0..<countInt {
        if let temp = buff?[i],let cname = ivar_getName(temp) {
            let proper = String(cString: cname)
            result.append(proper)
        }
    }
    free(count)
    free(buff)
    return result
}



/**
 获取class变量的所有属性名， PS:只能获取被@objc标记的属性
 - object:目标对象
 - hasSuper:是否获取父类属性，默认 true
 - return: 返回属性名列表
 */
public func getAllPropertys(object:AnyObject?, _ hasSuper:Bool = true) -> [String]{

    func getCurrentPropertys(class cls:AnyClass?) -> [String]{
        var result: Set<String> = Set()
        let count = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
        let buff = class_copyPropertyList(cls, count)
        let countInt = Int(count[0])
        for i in 0..<countInt {
            if let temp = buff?[i] {
                let cname = property_getName(temp)
                let proper = String(cString: cname)
                result.insert(proper)
            }
        }
        free(count)
        free(buff)
        return Array(result)
    }


    var res: Set<String> = Set(getCurrentPropertys(class: object_getClass(object)))
    if hasSuper == true {
        var superCls:AnyClass? = object?.superclass
        while superCls != nil {
            let nodeRes = getCurrentPropertys(class: superCls)
            if nodeRes.contains("isa") {
                superCls = nil
            }else{
                res.formUnion(nodeRes)//合并集合
                superCls = superCls?.superclass()
            }
        }
    }
    return Array(res)
}


/**
 打印对象的所有变量与值
 */
public func printAllPropertys(object:AnyObject?, _ hasSuper:Bool = true) {
    let res = getAllPropertys(object:object,hasSuper)
    print(res)
}



#endif
