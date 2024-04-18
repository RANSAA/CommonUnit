//
//  File.swift
//  
//
//  Created by kimi on 2024/4/2.
//

import Foundation



/**
 RequestParameter参数关联数据的类型
 */
enum RequestParameterFileAssociatedType{
    case unknown //未知类型，即不需要向from-data写入数据
    case url    //URL
    case data   //Data
    case stream //输入流
}


/**
 向from-data中添加文件上传时的参数封装
 */
struct RequestParameterFile{
    var name:String //参数名称
    var fileName:String //上传的文件名
    
    //需要上传的Data数据
    var data:Data?{
        if let _data  {
            return _data
        }
        if let url{
            return try? Data(contentsOf: url)
        }
        return nil
    }
    
    //需要上传文件的URL路径
    var url:URL?
    
    private var _data:Data?
    
    
    /**
     具体数据关联的数据类型
     */
    var associatedType:RequestParameterFileAssociatedType

    
    /**
     参数说明:
     - name：参数名
     - data：向from-data中添加的数据，可以是String,URL,Data
     - fileName：文件名
     */
    init(name: String, data: Any?, fileName: String? = nil) {
        self.name = name
        if let fileName{
            self.fileName = fileName
        }else{
            self.fileName = "\(Int(Date().timeIntervalSince1970))"+"\(Int.random(in: 1...1000))"
        }
        

        switch data {
        case let path as String:
            self.url = URL(fileURLWithPath: path)
            associatedType = .url
        case let url as URL:
            self.url = url
            associatedType = .url
        case let data_ as Data:
            self._data = data_
            associatedType = .data
        default:
            associatedType = .unknown
            break
        }

    }
    
}
