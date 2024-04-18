//
//  File.swift
//  
//
//  Created by kimi on 2024/1/6.
//

import Foundation



//MARK: - Description
/**
 Class 或 Struct 实现该协议就可以使用print方法答应属性名称与值
 */
protocol Description:CustomStringConvertible{
    
}

extension Description{
    var description: String{
        printAllIvars(self,hasSuper:true,isPrint: false)
    }
}

extension Description where Self:Encodable{
    var description: String{
        descriptionModel(self)
    }
}


// MARK: - Swift：使对象自动支持description的解决方法
/**
 要求：需要继承NSObject或者实现CustomStringConvertible，CustomDebugStringConvertible协议
 并在 var description:String{ get }协议中实现下列操作
 var description:String {
     return printAllIvars(self, false)
 }
 */






//MARK: - 获取变量的内存地址：address
func address<T: AnyObject>(o: T) -> String {
    let res = String.init(format: "%018p", unsafeBitCast(o, to: Int.self))
    return res
}

func address(o: UnsafeRawPointer) -> String {
    return String.init(format: "%018p", Int(bitPattern: o))
}














// MARK: - Swift:获取任何类型对象中的所有变量名称 -- 使用Mirror反射获取（推荐使用）


/**
 获取对象的所有变量名称
 - any:指定对象
 - hasSuper:是否获取父类的变量，默认 true
 - return 返回变量名列表
 */
@discardableResult
public func getAllIvars(_ any: Any?, _ hasSuper:Bool = true) -> [String]{
    var result:[String] = []
    if let any = any {
        let mirror = Mirror(reflecting: any)
        mirror.children.forEach { (child) in
            if let porperty = child.label{
                result.append(porperty)
            }
        }
        if hasSuper == true {
            var superMirror = mirror.superclassMirror
            while superMirror != nil {
                superMirror?.children.forEach { (child) in
                    if let porperty = child.label{
                        result.append(porperty)
                    }
                }
                superMirror = superMirror?.superclassMirror
            }
        }
    }
    print("result:\(result)")
    return result
}



/**
 打印对象所有变量名与值,并返回
 - object:打印的Any对象
 - hasSuper:是否获取父类的变量，默认 true
 - hasAddress:是否打印class变量的内存地址，默认 true
 - isPrint:是否打印信息 默认 true
 - return 返回打印信息
 */
@discardableResult
public func printAllIvars(_ any: Any?, hasSuper:Bool = true, hasAddress:Bool = true, isPrint:Bool = true) -> String{
    var res = ""
    if let model = any {
        let mirror = Mirror(reflecting: model)

        var tagName = "<\(type(of: model))>"
        if hasAddress == true {
            if mirror.displayStyle == Mirror.DisplayStyle.class {
                tagName = "<\(type(of: model)):\(address(o: model as AnyObject))>"
            }
        }
        res += tagName + "\n"

        mirror.children.forEach { (child) in
            if let porperty = child.label{
                res += "    \(porperty): \(child.value)\n"
            }
        }

        if hasSuper == true {
            var superMirror = mirror.superclassMirror
            while superMirror != nil {
                superMirror?.children.forEach { (child) in
                    if let porperty = child.label{
                        res += "    \(porperty): \(child.value)\n"
                    }
                }
                superMirror = superMirror?.superclassMirror
            }
        }
        res += tagName
    }else{
        res += "nil"
    }
    if isPrint {
        print(res)
    }
    return res
}
