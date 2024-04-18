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

// MARK: - 文件名相关
extension String{
    
    /** 文件后缀 */
    var fileExtension:String{
        get{
            let list = self.components(separatedBy: ".")
            if list.count > 1 {
                //这里可以添加判断一些如：tar.gz之类的多段文件类型
                return list.last!
            }else{
                return ""
            }
        }
    }
    
    /** path路径对应的文件后缀 */
    var pathExtension: String {
        fileExtension
    }

    //文件名称
    var fileName: String{
        get{
            var name = ""
            let ary = self.components(separatedBy: "/")
            if let last = ary.last {
                name = last
            }
            return name
        }
    }



    /**
     功能：从一个二进制文件中读取数据并创建String，读取规则是按照每个字节读取的。读取时与原文件的编码类型无关
     path:BinaryData的文件路径

     其它：
     下面几种方式依然可以利用FILE读取文件，但是如果文件是二进制(无编码，即打开文件呈现乱码的形式)的模式时，将会读取失败，
     读取全部内容
             let ln = UnsafeMutablePointer<Int>.allocate(capacity: length)
             var lineS = fgetln(fp, ln)
             print(String(cString: lineS!))

     读取全部内容，或者指定长度
         fseek(fp, 0, SEEK_END)
         let length = ftell(fp)
         fseek(fp, 0, SEEK_SET)
         let buffer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: length)
         fread(buffer, MemoryLayout<CUnsignedChar>.size, length, fp)//length
         fclose(fp)
         print(String(cString: buffer))

     读取指定长度
             let ln = UnsafeMutablePointer<Int8>.allocate(capacity: length)
             let lineS = fgets(ln, 10, fp)!
             print(String(cString: lineS))
     */

    public static func read(filePath path:String) -> String? {
        var resultStr = ""
        let fp = fopen(path, "r")
        if fp == nil {
            TKLog("文件打开失败！ \(path)")
            return nil
        }

        var ch: Int32 = fgetc(fp)
        while ch != EOF {
            //NSMutableString.appendFormat("%c", ch)
            resultStr.append(Character(UnicodeScalar(UInt32(ch))!))
            ch = fgetc(fp)
        }
        fclose(fp)
        return resultStr
    }
}







