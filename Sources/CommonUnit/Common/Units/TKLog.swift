//
//  TKLog.swift
//  
//
//  Created by kimi on 2024/1/7.
//

import Foundation



/**
 功能：该文件主要用来定制打印信息相关操作
 */


/**
 对TKLog的相关配置
 */
class _TKLogConfig{
    static let shared = _TKLogConfig()
    
    /**
     标记是否启用全局的TKLog打印函数，默认允许
     */
    var isTKLog = true
    
    
    private init(){
        
    }
}




@discardableResult
func TKLog(_ items: Any..., separator: String = " ", terminator: String = "", file: String = #file, function: String = #function, line: Int = #line) -> String {
    if !_TKLogConfig.shared.isTKLog {
        return ""
    }
    
    
    var output = "\(file.components(separatedBy: "/").last!) line:\(String(format: "%-4d", line)) - "
    var isFirst = true
    for item in items {
        if isFirst {
            isFirst = false
        }
        else {
            output += separator
        }
        output += "\(item)"
    }
    output += terminator

    print(output)

    
    //如果要保存print信息，可以在这里处理
//    TKLogSave(src: output + "\n")

    return output
}

private func TKLogSave(src:String){
//    Config.shared.saveLog(src: src)
}

