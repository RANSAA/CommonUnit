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


// MARK: - Base64 safe url
extension String{

    /**Base64 编码 */
    public func encBase64() -> String{
        var base64String = ""
        if let data = self.data(using: .utf8) {
            base64String = data.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        }else{
            print("⚠️⚠️Base64 编码失败!\tString:\(self)_TagEnd")
        }
        return base64String
    }


    /** Base64 解码 */
    public func decBase64() -> String{
        var decodeString = ""
        if let deData = Data(base64Encoded: self, options: .init(rawValue: 0)) {
            decodeString = String(data: deData, encoding: .utf8) ?? decodeString
        }else{
            print("⚠️⚠️Base64 解码失败!\tString:\(self)_TagEnd")
        }
        return decodeString
    }


    /** Base64 url safe 编码 */
    public func encBase64WebSafe() ->String{
        var base64String = ""
        if let data = self.data(using: .utf8) {
            base64String = data.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
            // %替换为_
            base64String = base64String.replacingOccurrences(of: "%", with: "_")
            // =替换为空
            base64String = base64String.replacingOccurrences(of: "=", with: "")
            // +替换为—
            base64String = base64String.replacingOccurrences(of: "+", with: "-")
            // /替换为_
            base64String = base64String.replacingOccurrences(of: "/", with: "_")
        }else{
            print("⚠️⚠️Base64 WebSafe 编码失败!\tString:\(self)_TagEnd")
        }
        return base64String
    }


    /** Base64 url safe 解码 */
    public func decBase64WebSafe() -> String{
        var decodeString = ""
        // -替换为+
        var base64Str = self.replacingOccurrences(of: "-", with: "+")
        // _替换为/
        base64Str = base64Str.replacingOccurrences(of: "_", with: "/")
        let mod4 = base64Str.count % 4
        if mod4 > 0 {
                let appStr = ("====" as NSString).substring(to: (4 - mod4))
            base64Str += appStr
        }
        if let data = Data(base64Encoded: base64Str, options: .init(rawValue: 0)) {
            decodeString = String(data: data, encoding: .utf8) ?? decodeString
        }else{
            print("⚠️⚠️Base64 WebSafe 解码失败!\tString:\(self)_TagEnd")
        }
        return decodeString
    }

}

