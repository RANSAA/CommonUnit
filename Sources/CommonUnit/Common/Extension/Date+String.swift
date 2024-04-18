//
//  File.swift
//  
//
//  Created by kimi on 2024/4/14.
//

import Foundation


extension Date{
    
    /**
     获取当前系统时间的字符串
     */
    static var nowString:String{
        // 创建一个 DateFormatter 实例
        let dateFormatter = DateFormatter()
        // 设置日期格式
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // 设置时区为当前系统的时区
        dateFormatter.timeZone = TimeZone.current
        
        // 获取当前日期和时间
        let now = Date()
        // 将日期转换为字符串
        let dateString = dateFormatter.string(from: now)
        return dateString
    }
    
}
