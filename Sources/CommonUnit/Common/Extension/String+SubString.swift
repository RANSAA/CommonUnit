//
//  File.swift
//  
//
//  Created by kimi on 2023/11/3.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif



//MARK: - subString
extension String {

    /**
     截取字符串：从index到结束处
     - Parameter index: 开始索引
     - Returns: 子字符串
     */
    func subStringFrom(_ index: Int) -> String {
        let theIndex = self.index(self.endIndex, offsetBy: index - self.count)

        return String(self[theIndex..<endIndex])
    }

    /**
     截取字符串：从开始到index处
     - Parameter index: 索引结束位置
     - Returns: 子字符串
     */
    func subStringTo(_ index:Int) -> String{
        let toIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[startIndex..<toIndex])
    }


    /**
     截取字符串：从from处开始，to处结束(PS:包含位置to处的字符)
     - from:开始位置
     - to:结束位置
     */
    func subStringFrom(_ from:Int, _ to:Int) ->String{
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(self.startIndex, offsetBy: to)
        return String(self[start...end])
    }


    /**
     获取指定位置的一个字符
     return 返回Character
     */
    func getOneCharacterWith(_ index:Int) -> Character{
        let subIndex = self.index(self.startIndex, offsetBy: index)
        return self[subIndex]
    }

    /**
     获取指定位置的一个字符
     return 返回String
     */
    func getOneStringWith(_ index:Int) -> String{
        let subIndex = self.index(self.startIndex, offsetBy: index)
        return String(self[subIndex])
    }


    /**
     从0索引处开始查找是否包含指定的字符串，返回Int类型的索引
     返回第一次出现的指定子字符串在此字符串中的索引
     */
     func findFirst(_ sub:String)->Int {
         var pos = -1
         if let range = range(of:sub, options: .literal ) {
             if !range.isEmpty {
                 pos = self.distance(from:startIndex, to:range.lowerBound)
             }
         }
         return pos
     }


    /**
     从0索引处开始查找是否包含指定的字符串，返回Int类型的索引
     返回最后出现的指定子字符串在此字符串中的索引
     */
     func findLast(_ sub:String)->Int {
         var pos = -1
         if let range = range(of:sub, options: .backwards ) {
             if !range.isEmpty {
                 pos = self.distance(from:startIndex, to:range.lowerBound)
             }
         }
         return pos
     }


    /**
     从指定索引处开始查找是否包含指定的字符串，返回Int类型的索引
     返回第一次出现的指定子字符串在此字符串中的索引
     */
     func findFirst(_ sub:String,_ begin:Int)->Int {
        let str:String = self.subStringFrom(begin)
        let pos:Int = str.findFirst(sub)
         return pos == -1 ? -1 : (pos + begin)
     }


    /**
     从指定索引处开始查找是否包含指定的字符串，返回Int类型的索引
     返回最后出现的指定子字符串在此字符串中的索引
     */
     func findLast(_ sub:String,_ begin:Int)->Int {
        let str:String = self.subStringFrom(begin)
        let pos:Int = str.findLast(sub)
         return pos == -1 ? -1 : (pos + begin)
     }
 }

