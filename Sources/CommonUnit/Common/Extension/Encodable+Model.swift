//
//  File.swift
//  
//
//  Created by kimi on 2024/1/18.
//

import Foundation



extension Encodable{
    
    /**
     将model转换成Data
     */
    func convertToData() -> Data?{
        var data:Data? = nil
        do{
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            data = try encoder.encode(self)
        }catch{
            print("JSON Encoder 失败!   model:\(self)")
        }
        return data
    }
}



extension Data{
    
    /**
     将Data转化成model
     */
    func convertToModel<T: Decodable>(type:T.Type) -> T?{
        do {
            let decoder = JSONDecoder()
            let model = try decoder.decode(T.self, from: self)
            return model
        } catch {
            print("JSON Decoder 失败!   type:\(T.self)   data:\(self)")
        }
        return nil
    }
    
}
