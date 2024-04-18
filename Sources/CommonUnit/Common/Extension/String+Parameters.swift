//
//  File.swift
//  
//
//  Created by kimi on 2024/1/24.
//

import Foundation



extension String{
 
    /**
     将空格，"-"符号移除，并转化成大写
     */
    var removeSpacesAndHyphensToUpperCase:String{
        var str = self.replacingOccurrences(of: "-", with: "")
        str = str.replacingOccurrences(of: " ", with: "")
        str = str.uppercased()
        return str
    }
    
    
    /**
     将?之后的quary查询参数解码成以K-V格式的Dict并返回。
     并并解决url中的特殊编码：
     1. 解决将实际URL字符串中的+被解码成" "空格的问题
     */
    var toQuaryDictParameters:[String:String]{
        var dict:[String:String] = [:] //解析后的quary参数名：值
        var input = self.replacingOccurrences(of: "%2B+", with: "❎") //  "%2B+" 表示 "+ "
        input = input.replacingOccurrences(of: "+", with: "❌") //  "+" 表示 " "
        if let ver_ = input.removingPercentEncoding{
            input = ver_
        }
        input = input.replacingOccurrences(of: "❎", with: "+ ")
        input = input.replacingOccurrences(of: "❌", with: " ")
        
        let compares = input.components(separatedBy: "?")
        if  compares.count > 1  {
            let quary:String = compares[1]
            print("⚠️Original Input Quary:\(quary)")
            for node in quary.components(separatedBy: "&") {
                let pars = node.components(separatedBy: "=")
                let k:String = pars[0]
                let v:String = pars[1]
                dict[k] = v
            }
        }
                
        return dict
    }
    
    
}



extension String {
    /**
     判断字符串中是否包含中文
     */
    var containsChineseCharacters: Bool {
        for chr in self.unicodeScalars {
            if chr >= "\u{4E00}" && chr <= "\u{9FFF}" {
                return true
            }
        }
        return false
    }
}
