//
//  File.swift
//
//
//  Created by kimi on 2024/4/2.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif
import AsyncHTTPClient
import Algorithms
import Logging
import NIO
import NIOCore
import NIOHTTP1
import NIOFoundationCompat
import NIOConcurrencyHelpers
import NIOPosix
import NIOSSL


/**
 该工具是对AsyncHTTPClient库进行了一些基本封装，在Linux平台上推荐使用该工具进行网络请求，推荐Swift 5.7+
 
 
 ⚠️⚠️警告：不要与curl_swift库同时混用，因为它们之间有冲突bug，会出现无法编译release版本的二进制文件。
 
 
 
 使用:
 .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
 
 .product(name: "AsyncHTTPClient", package: "async-http-client"),
 */
class VaporNetworkTool{
    /**
     响应数据校验模式, 默认:loose模式
     */
    public static var verifyMode:ResponseVerifyMode = .loose
    /**
     是否允许对URL进行CharacterSet.urlQueryAllowed编码, defualt = true
     */
    public static var allowedURLEncoding:Bool = true
    
    //设置请求超时，默认30s
    public static var timeout:Int = 60
}

//MARK: - 重写实现自定义配置
extension VaporNetworkTool{
    
    
    /**
     功能：对HTTPClient对象进行公共通用的自定义处理
     注意：重写是需要先super才能保留默认配置
     */
    public class func customHTTPClient(client:HTTPClient) -> HTTPClient {
        return client
    }
    
    /**
     功能：对HTTPClient.Configuration配置进行自定义处理
     注意：重写是先super才可以获取默认的配置信息
    */
    public class func customHTTPClientConfiguration(configuration:HTTPClient.Configuration) -> HTTPClient.Configuration{
        return configuration
    }
    
    
    /**
     功能：对HTTPClientRequest对象进行公共通用的自定义处理，
     注意：重写是需要先super才能获取默认配置
     */
    public class func customHTTPClientRequest(req:HTTPClientRequest) -> HTTPClientRequest {
        return req
    }
    
    /**
     功能：设置公共的headers信息，优先级低于请求方法中设置的headers
     注意：重写时如果不先执行super则不能获取默认的公用header配置。
     */
    public class func customHeaders() -> [String:String]? {
        let _headers = RequestHeaders.defaultHeader
        return _headers
    }
    
    /**
     重写，处理请求URL，比如是否添加公共请求域名，以及一些特殊的请求路劲绑定不同的域名。
     PS:可对请求url进行拼接
     @param url 请求传入的URL
     @param method 请求方式
     */
    public class func customRequestURL(url:String,method:RequestMethod) -> String {
        return url
    }
    
    
    /**
     重写，可对请求参数二次修改。
     比如:添加一些通用参数
     */
    public class func customRequestParameter(parameter:RequestParameter?, url:String) -> RequestParameter?{
        //示例:为通用参数添加字段
//        var dic = parameter?.associatedValue as? [String:Any?]
//        dic?["add"] = "add.."
//        let new = ParameterType.dictJson(dic)
//        TKLog("new:\(new)")
        
        return parameter
    }
    
    /**
     重写该方法可对响应Data进行重新定制处理，注意:该方法优先级最高，该方法最先处理从服务器拿到的数据，修改数据，然后再有通用基础方法处理后续操作。
     */
    public class func customResponseData(resultData:Data, request:HTTPClientRequest, response:HTTPClientResponse) -> Data{
        return resultData
    }


    /**
     重写该方法，进行通用错误处理;注意：该方法执行的顺序优于所有错误处理方法之前。
     */
    public class func customResponseError(request:HTTPClientRequest, error:Error){

    }
}






//MARK: -
extension VaporNetworkTool{
    

    /**
     功能：对创建的HTTPClientRequest对象进行通用配置
     - url：请求URL
     - parameter：body中的普通数据
     - fileParameter：向from-data中追加的文件(Data)数据列表(即可同时上传多个文件)；注意：
         1.如果body中只上传给一个Data而不需要其它参数则可以直接使用parameter参数提交。
         2.如果与parameter参数同时存在时，parameter中的数据必须是key:value的方式存在，并且parameter中不能只是一个单纯的Data数据(例如一个文本转换成的Data)
     - fileBoundary：向fromdata中最加数据时自定义的boundary值，如果不设置将会在内部随机生成一个值，一般可以使用UUID生成，注意：只有fileParameter存在时，该值才有效。
     - method：请求方式
     - headers：请求时带的header信息
     */
    private class func configRequest(url:String,
                                     parameter:RequestParameter? = nil,
                                     fileParameter:[RequestParameterFile]? = nil,
                                     fileBoundary:String? = nil,
                                     method:RequestMethod,
                                     headers:[String:String]? = nil) -> HTTPClientRequest?
    {
        var mUrl = customRequestURL(url: url, method: method)
        let urlString = mUrl
        TKLog("[\(self)]  请求方式:\(method)   请求地址:\(urlString)")
        if allowedURLEncoding, let encURL = mUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            mUrl = encURL
        }
        guard URL(string: mUrl) != nil else {
            let msg = "⚠️⚠️⚠️⚠️网络请求错误: URL对象创建失败! urlString:\(mUrl)"
            TKLog(msg)
            return nil
        }
        
        var req = HTTPClientRequest(url: mUrl)
        
        //重新自定义HTTPClientRequest属性
        req = customHTTPClientRequest(req: req)
        
        
        //配置专用的headers信息，将会替换掉具有相同名称的header值
        //先配置默认的header
        if let headers = customHeaders(){
            for (key,value) in headers{
                if key.isEmpty || value.isEmpty {
                    continue
                }
                req.headers.replaceOrAdd(name: key, value: value)
            }
        }
        //再配置请求时自带的header
        if let headers = headers {
            for (key,value) in headers{
                if key.isEmpty || value.isEmpty {
                    continue
                }
                req.headers.replaceOrAdd(name: key, value: value)
            }
        }
        //打印header
        if isLogHeaders{
            TKLog("----------------------------Headers----------------------------")
            for header in req.headers{
                TKLog("\(header.name):\(header.value)")
            }
            TKLog("----------------------------Headers----------------------------")
        }
        

        //配置请求方式
        req.method = .init(rawValue: method.rawValue)

        
        
        /**
         设置Body数据。
         注意：这儿暂时没有实现上传普通数据的同时上传文件(Data)数据
         */
        switch method{
        case .POST, .PUT, .PATCH:
            //向multipart/form-data中添加Data数据
            if let fileParameter, fileParameter.count > 0{
                //获取multipart/form-data传参时需要的boundary值
                let  boundary = fileBoundary != nil ? fileBoundary! : UUID().uuidString
                
                //用于收集parameter和fileParameter中的数据
                var buffer = ByteBufferAllocator().buffer(capacity: 0)
                
                //向buffer中添加parameter中的数据
                if let mParameter = customRequestParameter(parameter: parameter, url: urlString), let dict = mParameter.associatedValue as? [String:Any?] {
//                    TKLog("[\(self)]  请求参数编码方式:\(mParameter.format)    请求参数值:\(mParameter.reqString ?? "")")
                    for (name,value) in dict{
                        if let value {
                            buffer.writeString("--\(boundary)\r\n")
                            buffer.writeString("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
                            buffer.writeString("\(value)\r\n")
                            TKLog("[\(self)]  请求参数编码方式:multipart/form-data     name:\(name)     value:\(value) ")
                        }
                    }
                }
                
                //向buffer中添加fileParameter中的数据
                for item in fileParameter{
                    if let data = item.data{
                        buffer.writeString("--\(boundary)\r\n")
                        buffer.writeString("Content-Disposition: form-data; name=\"\(item.name)\"; filename=\"\(item.fileName)\"\r\n")
                        buffer.writeString("Content-Type: */*\r\n\r\n")
                        buffer.writeBytes(data)
                        buffer.writeString("\r\n")
                        TKLog("[\(self)]  请求参数编码方式:multipart/form-data     name:\(item.name)     value:\(data)   filename:\(item.fileName)")
                    }else{
                        TKLog("[\(self)]  请求参数编码方式:multipart/form-data     name:\(item.name)     value:\(String(describing: item.data))   filename:\(item.fileName)")
                    }
                }
                TKLog("")
                
                //结束multipart body：
                buffer.writeString("--\(boundary)--\r\n")
                
                //设置body
                req.body = .bytes(buffer)
                
                //设置Content-Type的值为:multipart/form-data
                req.headers.replaceOrAdd(name: RequestHeaders.Headers.ContentType, value: "\(RequestHeaders.Headers.ContentTypeVauleFormData); boundary=\(boundary)")
                
            }
            //向body中添加普通数据(即普通的基础数据，可以是:字符串，数字，bool类型)
            else{
                if let mParameter = customRequestParameter(parameter: parameter, url: urlString), let reqData = mParameter.reqData {
                    TKLog("[\(self)]  请求参数编码方式:\(mParameter.format)    请求参数值:\(mParameter.reqString ?? "")")
                    req.body = .bytes(ByteBuffer(data: reqData))
                }
            }
            
        default:
            break
        }
        
        return req
    }
    
    /**
     功能：向body中添加普通的数据
     */
    private class func addBodyDataParameter(parameter:RequestParameter? = nil,
                                            fileParameter:[RequestParameterFile]? = nil,
                                            fileBoundary:String? = nil)
    {
        
        
    }
    
    /**
     功能：向from-data中添加数据(例如文本，视频等对应的Data数据)
     */
    private class func addFromDataParameter(){
        
    }
}


//MARK: -
extension VaporNetworkTool{
//MARK: - 基础的网络请求方法
    /**
     功能：基础的网络请求方法
     - url：请求URL
     - parameter：body中的普通数据
     - fileParameter：向from-data中追加的文件(Data)数据列表(即可同时上传多个文件)；注意：
         1.如果body中只上传给一个Data而不需要其它参数则可以直接使用parameter参数提交。
         2.如果与parameter参数同时存在时，parameter中的数据必须是key:value的方式存在，并且parameter中不能只是一个单纯的Data数据(例如一个文本转换成的Data)
     - fileBoundary：向from-data中最加数据时自定义的boundary值，如果不设置将会在内部随机生成一个值，一般可以使用UUID生成，注意：只有fileParameter存在时，该值才有效。
     - outputPath：响应数据保存路径，可选。如果该值存在(即是一个正确的路径)那么success回调时就不会返回响应数据
     - method：请求方式
     - headers：请求时带的header信息
     - operationQueue：操作队列，如果该值不为空，并设置maxConcurrentOperationCount=1，则可以让请求按顺序执行，即上一个请求获取数据后才会开始下一个请求。
     - progress：请求进度
     - success：响应成功回调
     - fail：相应失败回调
     */
    public class func baseRequest(url:String,
                                  parameter:RequestParameter? = nil,
                                  fileParameter:[RequestParameterFile]? = nil,
                                  fileBoundary:String? = nil,
                                  outputPath:String? = nil ,
                                  method:RequestMethod = .GET,
                                  headers:[String:String]? = nil,
                                  operationQueue:OperationQueue? = nil,
                                  progress:@escaping (_ received:Int,_ expected:Int) -> Void,
                                  success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                                  fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void)
    {
        guard let request:HTTPClientRequest = configRequest(url: url, parameter: parameter, fileParameter: fileParameter, fileBoundary: fileBoundary, method: method, headers: headers) else {
            return
        }
        //
        let client = self.session
        
        
        //创建操作对象
        let operation = VaporTaskOperation(httpClient: client, request: request,outputPath:outputPath,timeout:self.timeout, progress: progress) { resultData, statusCode, request, response in
            self.finishResponseSuccess(resultData: resultData, statusCode: statusCode, request: request, response: response, success: success)
        } fail: { error, request in
            self.finishResponseFail(error: error, request: request, fail: fail)
        }
        
        //加入到消息队列
        let queue = configOperationQueue(queue: operationQueue)
        queue.addOperation(operation)
    }
    
    /**
     响应数据成功通用处理
     */
    private class func finishResponseSuccess(resultData:Data?,
                                             statusCode:Int,
                                             request:HTTPClientRequest,
                                             response:HTTPClientResponse?,
                                             success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void)
    {
        var _resultData = resultData
        //自定义响应数据
        if let resultData, let response {
            _resultData = self.customResponseData(resultData: resultData, request: request, response: response)
        }
        success(_resultData,statusCode,request,response)
    }
    
    /**
     响应数据失败通用处理
     */
    private class func finishResponseFail(error:Error,
                                          request:HTTPClientRequest,
                                          fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void)
    {
        let errmsg = "[\(self)]  ⚠️⚠️⚠️⚠️网络请求失败：\(request.url)   error:\(error)"
        TKLog("\(errmsg)")
        
        //自定义响应错误
        self.customResponseError(request: request, error: error)
        fail(error,request)
    }
    
}


//MARK: -
extension VaporNetworkTool{
    

    public class func data(url:String,
                           parameter:RequestParameter? = nil ,
                           fileParameters:[RequestParameterFile]? = nil,
                           fileBoundary:String? = nil,
                           outputPath:String? = nil ,
                           method:RequestMethod = .GET,
                           headers:[String:String]? = nil ,
                           operationQueue:OperationQueue? = nil,
                           success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                           fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void){
        
        baseRequest(url: url, parameter: parameter, fileParameter: fileParameters, fileBoundary: fileBoundary, outputPath: outputPath, method: method, headers: headers, operationQueue: operationQueue, progress: { received, expected in
            //progress
        }, success: success, fail: fail)
    }
    
    
    public class func string(url:String,
                             parameter:RequestParameter? = nil ,
                             fileParameters:[RequestParameterFile]? = nil,
                             fileBoundary:String? = nil,
                             outputPath:String? = nil ,
                             method:RequestMethod = .GET,
                             headers:[String:String]? = nil ,
                             encoding:String.Encoding = .utf8,
                             operationQueue:OperationQueue? = nil,
                             success:@escaping (_ resultData:String?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                             fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void){
        
        data(url: url, parameter: parameter, fileParameters: fileParameters, fileBoundary: fileBoundary, outputPath: outputPath, method: method, headers: headers, operationQueue: operationQueue, success: { resultData, statusCode, request, response in
            var resultStr:String? = nil
            if let resultData{
                resultStr = String(data: resultData, encoding: encoding)
            }
            success(resultStr,statusCode,request,response)
        }, fail: fail)
        
    }
    
}


//MARK: -
extension VaporNetworkTool{
    
    /**
     获取Data数据，并且参数使用JSON格式编码，参数传递形式为[String:Any?]?
     */
    public class func dataJSON(url:String,
                               parameter:[String:Any?]? = nil,
                               fileParameters:[RequestParameterFile]? = nil,
                               fileBoundary:String? = nil,
                               outputPath:String? = nil ,
                               method:RequestMethod = .GET,
                               headers:[String:String]? = nil ,
                               operationQueue:OperationQueue? = nil,
                               success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                               fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void){
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleJson
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictJson(parameter)
        data(url: url, parameter: parameter, fileParameters: fileParameters, fileBoundary: fileBoundary, outputPath: outputPath, method: method, headers: _headers, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    /**
     获取Data数据，并且参数使用URL Query格式编码，参数传递形式为[String:Any?]?
     */
    public class func dataQuery(url:String,
                               parameter:[String:Any?]? = nil,
                               fileParameters:[RequestParameterFile]? = nil,
                               fileBoundary:String? = nil,
                               outputPath:String? = nil ,
                               method:RequestMethod = .GET,
                               headers:[String:String]? = nil ,
                               operationQueue:OperationQueue? = nil,
                               success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                               fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void){
    
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleUrlEncoded
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictQuery(parameter)
        data(url: url, parameter: parameter, fileParameters: fileParameters, fileBoundary: fileBoundary, outputPath: outputPath, method: method, headers: _headers, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    
    /**
     获取String字符串数据，并且参数使用JSON格式编码，参数传递形式为[String:Any?]?
     */
    public class func stringJSON(url:String,
                                 parameter:[String:Any?]? = nil,
                                 fileParameters:[RequestParameterFile]? = nil,
                                 fileBoundary:String? = nil,
                                 outputPath:String? = nil ,
                                 method:RequestMethod = .GET,
                                 headers:[String:String]? = nil ,
                                 encoding:String.Encoding = .utf8,
                                 operationQueue:OperationQueue? = nil,
                                 success:@escaping (_ resultData:String?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                                 fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void){
        
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleJson
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictJson(parameter)
        string(url: url, parameter: parameter, fileParameters: fileParameters, fileBoundary: fileBoundary, outputPath: outputPath, method: method, headers: _headers, encoding: encoding, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    
    /**
     获取String字符串数据，并且参数使用URL Query格式编码，参数传递形式为[String:Any?]?
     */
    public class func stringQuery(url:String,
                                 parameter:[String:Any?]? = nil,
                                 fileParameters:[RequestParameterFile]? = nil,
                                 fileBoundary:String? = nil,
                                 outputPath:String? = nil ,
                                 method:RequestMethod = .GET,
                                 headers:[String:String]? = nil ,
                                 encoding:String.Encoding = .utf8,
                                 operationQueue:OperationQueue? = nil,
                                 success:@escaping (_ resultData:String?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
                                 fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void){
        
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleUrlEncoded
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictQuery(parameter)
        string(url: url, parameter: parameter, fileParameters: fileParameters, fileBoundary: fileBoundary, outputPath: outputPath, method: method, headers: _headers, encoding: encoding, operationQueue: operationQueue, success: success, fail: fail)
        
    }
    
    
}




//MARK: -
extension VaporNetworkTool{
    
    /**
     是否使用自定义的HTTPClient， 默认使用单利
     - true：每次请求都创建一个HTTPClient对象，注意：每次请求完毕后必须执行shutdown()操作。
     - false：整个应用中只使用一个HTTPClient单利对象， 注意每次请求完毕后可以不执行shutdown()操作；
            如果多次出现HTTPClientError.alreadyShutdown错误，则不需要执行shutdown()操作，出现该错误的原因就是多次shutdown()操作引起的；
            如果不执行shutdown()操作出现错误，可以在VaporTaskOperation中修改添加执行shutdown()操作。
     */
    static var isCustomSession = false
    
    
    /**
     配置默认的HTTPClient客户端
     */
    private static var session:HTTPClient{
        if isCustomSession {
            return createSession()

        }else{
            return _httpClient
        }
    }
    private static let _httpClient:HTTPClient = createSession()
    private static func createSession() -> HTTPClient{
        var configuration = HTTPClient.Configuration()
        //配置允许重定向
        configuration.redirectConfiguration = .follow(max: 5, allowCycles: false)
        /**
         功能： 设置代理
         - 这儿出现过一个小问题，在请求某些需要代理的URL时，并在Mac系统中开启Clash代理，并且在VMWare启动Ubuntu；
         - 在Ubuntu运行时请求正确，在macOS上运行就会出现status: 400 Bad Request，且body数据为空；
         - 此时就可以通过设置代理解决这个问题，出现这个问题的具体原因还未知，可能是VPN引起的。
         */
//        configuration.proxy = .server(host: "127.0.0.1", port: 7890)
        
        //自定义
        configuration = customHTTPClientConfiguration(configuration: configuration)
        
        //创建HTTPClient
        var httpClient = HTTPClient(eventLoopGroupProvider: .singleton, configuration: configuration)
        
        
        //自定义配置HTTPClient
        httpClient = customHTTPClient(client: httpClient)
        
        
        return httpClient
    }
    
}





//MARK: -
extension VaporNetworkTool{
    
    /**
     配置默认的OperationQueue
     */
    private static var _operationQueue = createOperationQueue()
    private static func createOperationQueue() -> OperationQueue{
        let queue = OperationQueue()
        queue.name = "com.asyncHTTPClient.concurrent"
        return queue
    }
    private static func configOperationQueue(queue:OperationQueue?) -> OperationQueue{
        var _queue = _operationQueue
        if let queue{
            _queue = queue
        }
        return _queue
    }
    
}




//MARK: - TKLog
extension VaporNetworkTool{
    /** 是否启用NetworkTool的日志 */
    static var isLog = true
    /** 是否打印请求时Headers的信息，注意需要isLog==true时才有效*/
    static var isLogHeaders = false
    
    @discardableResult
    private func TKLog(_ items: Any..., separator: String = " ", terminator: String = "", file: String = #file, function: String = #function, line: Int = #line) -> String{
        return Self.TKLog(items, separator: separator, terminator: terminator)
    }
    
    @discardableResult
    private static func TKLog(_ items: Any..., separator: String = " ", terminator: String = "", file: String = #file, function: String = #function, line: Int = #line) -> String {
        if !isLog{
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
        TKLogSave(src: output + "\n")

        return output
    }
    
    //保存log
    private  static func TKLogSave(src:String){
    //    Config.shared.saveLog(src: src)
    }
}


