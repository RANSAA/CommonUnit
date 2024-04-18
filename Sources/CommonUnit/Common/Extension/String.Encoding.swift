//
//  File.swift
//  
//
//  Created by kimi on 2024/1/5.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif

// MARK: - String.Encoding编码扩展
extension String.Encoding{
    //GBK原始获取方式
    //let cfEnc = CFStringEncodings.GB_18030_2000
    //let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
    //let gbk = String.Encoding.init(rawValue: enc)
    //enc的值为：0x80001021，所以可以直接使用这个值创建GBK编码
    //enc的值为：2147485234，所以可以直接使用这个值创建GBK编码（对应的10进制的值）
    //GBK编码, 使用GB18030是因为它向下兼容GBK
    //public static let gbk1: String.Encoding = .init(rawValue: 2147485234)
    public static let gbk: String.Encoding = {
        let cfEnc = CFStringEncodings.GB_18030_2000
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
        let gbk = String.Encoding.init(rawValue: enc)
        return gbk
    }()
}
