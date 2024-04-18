//
//  File.swift
//  
//
//  Created by kimi on 2024/4/13.
//

import Foundation



/**
 BasicData+Data
 功能：将基础数据类型转换成Data
 注意：转换的结果与String样式的形态有区别，比如true通过String方式转换Data生成的数据是“true”，而该工具转换Data生成的数据是“0x01”
 */
extension Data {
    
    init<T>(from value: T) {
        var value = value
        self = withUnsafePointer(to: &value) {
            Data(bytes: $0, count: MemoryLayout<T>.size)
        }
    }
    
    // 泛型扩展，支持将任何基础数据类型转换为Data
    init<T>(from value: T) where T: FixedWidthInteger {
        var value = value // 复制一份变量，以便它有一个可变的内存地址
        self = Swift.withUnsafeBytes(of: &value) { Data($0) }
    }
    
}


// 字符串扩展不需要改变
extension String {
    var data: Data {
//        self.data(using: .utf8)!
        Data(self.utf8)
    }
}


// Int 扩展
extension Int {
    var data: Data {
        Data(from: self)
    }
}

extension FixedWidthInteger {
    // 将FixedWidthInteger类型（如Int，UInt，Int8等）转换为Data
    var data: Data {
        Data(from: self)
    }
}


// Float 扩展
extension Float {
    var data: Data {
        Data(from: self)
        
//        // Float的特殊扩展，转换为Data
//        self.bitPattern.data
    }
}


// Double 扩展
extension Double {
    var data: Data {
        Data(from: self)
        
//        // Double的特殊扩展，转换为Data
//        self.bitPattern.data
    }
}

// Bool 扩展
extension Bool {
    var data: Data {
        Data(from: self)
        
//        Data(from: self ? 1 : 0)
    }
}
