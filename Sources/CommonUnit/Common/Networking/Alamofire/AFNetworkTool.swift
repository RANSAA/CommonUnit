//
//  File.swift
//  
//
//  Created by kimi on 2024/4/2.
//

import Foundation
import Alamofire

/**
 该操作主要对Alamofire进行了一些基础功能的封装，要求Swift 5.7.1；
 包括一般的请求，上传，下载；
 但是不包括断点上传，断点下载。
 
 注意：
 1. 如果fileParameters参数有值Content-Type的类型将会自动更改为multipart/form-data（即使在headers中自定义了Content-Type）
 2. 如果Content-Type的值为multipart/form-data，那么在debugPrint(response)时，⚠️无法打印Request.Body的数据信息
 
 
 ⚠️⚠️警告：在Linux（非Applep平台）下不要使用Alamofire框架，因为它的很多功能(依赖的底层库)不被Linux支持。
 
 
 使用：
 .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
 
 .product(name: "Alamofire", package: "Alamofire"),
 */
class AFNetworkTool{
    /**
     响应数据校验模式, 默认:loose模式 - 目前未使用
     */
    public static var verifyMode:ResponseVerifyMode = .loose
    /**
     是否允许对URL进行CharacterSet.urlQueryAllowed编码, defualt = true
     */
    public static var allowedURLEncoding:Bool = true
    
}

//MARK: -
extension AFNetworkTool{
    
    /**
     功能：对URLRequest对象进行公共通用的自定义处理，
     */
    public class func customURLRequest(request:inout URLRequest) {
//        request.timeoutInterval = 30
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
    public class func customResponseData(resultData:Data?, statusCode:Int, request:URLRequest, response:URLResponse?) -> Data?{
        return resultData
    }
    
    /**
     重写该方法，进行通用错误处理;注意：该方法执行的顺序优于所有错误处理方法之前。
     */
    public class func customResponseError(request:URLRequest, error:Error){
        
    }
    
}




//MARK: -
extension AFNetworkTool{
//MARK: - 基础的网络请求方法

    /**
     功能：基础通用的网络请求方法
     注意：如果fileParameters参数存在时，parameter参数的类型只能为:RequestParameter.dictJson，RequestParameter.dictQuery；否则parameter中的参数将无法追加到form-data中。
     - url：请求URL
     - parameter：请求参数(普通参数)
     - fileParameters：需要向form-data中追加的参数
     - outputPath：请求数据的保存路径，如果该值存在，并且是一个正确的路径地址时，blockSuccess回调中的data将会返回为nil，注意该属性一般用于下载大文件到磁盘。
     - method：请求方式
     - headers：请求headers标头
     - operationQueue：操作队列，如果该值不为空，并设置maxConcurrentOperationCount=1，则可以让请求按顺序执行，即上一个请求获取数据后才会开始下一个请求。
     
     - interceptor：Alamofire请求拦截器 - 只能在该方法中修改
     - requestModifier：Alamofire请求修改器 - 在customURLRequest(request: &request)方法中对URLRequest对象修改。
     
     - uploadProgress：上传进度block
     - downloadProgress：下载进度block
     - success：请求成功回调
     - fail：请求失败回调
     */
    public class func baseRequest(url:String,
                                parameter:RequestParameter? = nil,
                                fileParameters:[RequestParameterFile]? = nil,
                                outputPath:String? = nil ,
                                method:RequestMethod = .GET,
                                headers:[String:String]? = nil,
                                operationQueue:OperationQueue? = nil,
                                uploadProgress:@escaping (_ received:Int,_ expected:Int) -> Void,
                                downloadProgress:@escaping (_ received:Int,_ expected:Int) -> Void,
                                success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                                fail:@escaping (_ error:Error, _ request:URLRequest) -> Void)
    {
        //URL
        var mUrl = self.customRequestURL(url: url, method: method)
        let urlString = mUrl
        TKLog("[\(self)]  请求方式:\(method)   请求地址:\(urlString)")
        if self.allowedURLEncoding, let encURL = mUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            mUrl = encURL
        }
        guard let url = URL(string: mUrl) else {
            let msg = "⚠️⚠️⚠️⚠️网络请求错误: URL对象创建失败! urlString:\(mUrl)"
            TKLog(msg)
            return
        }
        
        //parameter
        var _parameter:RequestParameter? = nil
        if let mParameter = customRequestParameter(parameter: parameter, url: urlString) {
            TKLog("[\(self)]  请求参数编码方式:\(mParameter.format)    请求参数值:\(mParameter.reqString ?? "")")
            _parameter = mParameter
        }
        
        
        //headers
        var _headers = HTTPHeaders()
        if let publicHeaders = self.customHeaders(){
            for (name,value) in publicHeaders {
                _headers.update(name: name, value: value)
            }
        }
        if let headers = headers {
            for (name,value) in headers {
                _headers.update(name: name, value: value)
            }
        }
        if self.isLogHeaders{
            TKLog("----------------------------Headers----------------------------")
            for header in _headers{
                TKLog(header)
            }
            TKLog("----------------------------Headers----------------------------")
        }

        
        //Alamofire配置的请求拦截器
        let _interceptor:RequestInterceptor? = nil
        
        
        
        //创建操作对象
        let operation = AlamofireTaskOperation(session: self.session,
                         url:url ,
                         parameter: _parameter,
                         fileParameters: fileParameters,
                         outputPath: outputPath,
                         method: method,
                         headers: _headers,
                         interceptor: _interceptor,
                         requestModifier: { request in
                            //对request自定义配置，比如设置超时等
                            self.customURLRequest(request: &request)
                        },
                        isLogResponse: self.isLogResponse,
                        blockUploadProgress: uploadProgress,
                        blockDownloadProgress: downloadProgress,
                        blockSuccess: { resultData, statusCode, request, response in
                            //成功回调
                            self.finishResponseSuccess(resultData: resultData, statusCode: statusCode, request: request, response: response, success: success)
                        }, blockFail: { error, request in

                        })


        //加入到消息队列
        let queue = self.configOperationQueue(queue: operationQueue)
        queue.addOperation(operation)

    }
    
    
    
    /**
     响应数据成功通用处理
     */
    private class func finishResponseSuccess(resultData:Data?,
                                             statusCode:Int,
                                             request:URLRequest,
                                             response:URLResponse?,
                                             success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void)
    {
        var _resultData = resultData
        //自定义响应数据
        if let resultData, let response {
            _resultData = self.customResponseData(resultData: resultData, statusCode: statusCode, request: request, response: response)
        }
        success(_resultData,statusCode,request,response)
    }
    
    
    /**
     响应数据失败通用处理
     */
    private class func finishResponseFail(error:Error,
                                          request:URLRequest,
                                          fail:@escaping (_ error:Error, _ request:URLRequest) -> Void)
    {
        let errmsg = "[\(self)]  ⚠️⚠️⚠️⚠️网络请求失败：\(String(describing: request.url))   error:\(error)"
        TKLog("\(errmsg)")
        
        //自定义响应错误
        self.customResponseError(request: request, error: error)
        fail(error,request)
    }
    
}



//MARK: -
extension AFNetworkTool{
    
    public class func data(url:String,
                           parameter:RequestParameter? = nil ,
                           fileParameters:[RequestParameterFile]? = nil,
                           outputPath:String? = nil ,
                           method:RequestMethod = .GET,
                           headers:[String:String]? = nil ,
                           operationQueue:OperationQueue? = nil,
                           success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                           fail:@escaping (_ error:Error, _ request:URLRequest) -> Void)
    {
        
        baseRequest(url: url, parameter: parameter, fileParameters: fileParameters, outputPath: outputPath, method: method, headers: headers, operationQueue: operationQueue, uploadProgress: { received, expected in
            //uploadProgress
        }, downloadProgress: { received, expected in
            //downloadProgress
        }, success: success, fail: fail)
    }
    
    
    public class func string(url:String,
                            parameter:RequestParameter? = nil ,
                            fileParameters:[RequestParameterFile]? = nil,
                            outputPath:String? = nil ,
                            method:RequestMethod = .GET,
                            headers:[String:String]? = nil ,
                            encoding:String.Encoding = .utf8,
                            operationQueue:OperationQueue? = nil,
                            success:@escaping (_ resultData:String?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                            fail:@escaping (_ error:Error, _ request:URLRequest) -> Void)
    {
        data(url: url, parameter: parameter, fileParameters: fileParameters, outputPath: outputPath, method: method, headers: headers, operationQueue: operationQueue, success: { resultData, statusCode, request, response in
            var resultStr:String? = nil
            if let resultData{
                resultStr = String(data: resultData, encoding: encoding)
            }
            success(resultStr,statusCode,request,response)
        }, fail: fail)
        
    }
    
}



//MARK: -
extension AFNetworkTool{
    
    /**
     获取Data数据，并且参数使用JSON格式编码，参数传递形式为[String:Any?]?
     */
    public class func dataJSON(url:String,
                               parameter:[String:Any?]? = nil,
                               fileParameters:[RequestParameterFile]? = nil,
                               outputPath:String? = nil ,
                               method:RequestMethod = .GET,
                               headers:[String:String]? = nil ,
                               operationQueue:OperationQueue? = nil,
                               success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                               fail:@escaping (_ error:Error, _ request:URLRequest) -> Void){
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleJson
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictJson(parameter)
        data(url: url, parameter: parameter, fileParameters: fileParameters, outputPath: outputPath, method: method, headers: _headers, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    /**
     获取Data数据，并且参数使用URL Query格式编码，参数传递形式为[String:Any?]?
     */
    public class func dataQuery(url:String,
                               parameter:[String:Any?]? = nil,
                               fileParameters:[RequestParameterFile]? = nil,
                               outputPath:String? = nil ,
                               method:RequestMethod = .GET,
                               headers:[String:String]? = nil ,
                               operationQueue:OperationQueue? = nil,
                               success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                               fail:@escaping (_ error:Error, _ request:URLRequest) -> Void){
    
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleUrlEncoded
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictQuery(parameter)
        data(url: url, parameter: parameter, fileParameters: fileParameters,  outputPath: outputPath, method: method, headers: _headers, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    
    /**
     获取String字符串数据，并且参数使用JSON格式编码，参数传递形式为[String:Any?]?
     */
    public class func stringJSON(url:String,
                                 parameter:[String:Any?]? = nil,
                                 fileParameters:[RequestParameterFile]? = nil,
                                 outputPath:String? = nil ,
                                 method:RequestMethod = .GET,
                                 headers:[String:String]? = nil ,
                                 encoding:String.Encoding = .utf8,
                                 operationQueue:OperationQueue? = nil,
                                 success:@escaping (_ resultData:String?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                                 fail:@escaping (_ error:Error, _ request:URLRequest) -> Void){
        
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleJson
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictJson(parameter)
        string(url: url, parameter: parameter, fileParameters: fileParameters, outputPath: outputPath, method: method, headers: _headers, encoding: encoding, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    
    /**
     获取String字符串数据，并且参数使用URL Query格式编码，参数传递形式为[String:Any?]?
     */
    public class func stringQuery(url:String,
                                 parameter:[String:Any?]? = nil,
                                 fileParameters:[RequestParameterFile]? = nil,
                                 outputPath:String? = nil ,
                                 method:RequestMethod = .GET,
                                 headers:[String:String]? = nil ,
                                 encoding:String.Encoding = .utf8,
                                 operationQueue:OperationQueue? = nil,
                                 success:@escaping (_ resultData:String?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
                                 fail:@escaping (_ error:Error, _ request:URLRequest) -> Void){
        
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleUrlEncoded
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        
        let parameter = RequestParameter.dictQuery(parameter)
        string(url: url, parameter: parameter, fileParameters: fileParameters,  outputPath: outputPath, method: method, headers: _headers, encoding: encoding, operationQueue: operationQueue, success: success, fail: fail)
        
    }
    
}



//MARK: -
extension AFNetworkTool{
    
}



//MARK: -
extension AFNetworkTool{
    
    /**
     配置默认的OperationQueue
     */
    private static var _operationQueue = loadOperationQueue()
    private static func loadOperationQueue() -> OperationQueue{
        let queue = OperationQueue()
        queue.name = "com.AFNetworkTool.concurrent"
        return queue
    }
    private static func configOperationQueue(queue:OperationQueue?) -> OperationQueue{
        var _queue = _operationQueue
        if let queue{
            _queue = queue
        }
        return _queue
    }
    
    
    
    
    /**
     配置Alamofire Session，提示可在Session构造方法中配置其它信息，比如证书验证等
     */
    static let session:Session = loadSession()
    /**
     提示可在Session构造方法中配置其它信息，比如证书验证等
     */
    private static func loadSession() -> Session{

        
//        //SessionURLSessionConfiguration - URLSessionConfiguration配置
//        let configuration = URLSessionConfiguration.af.default
//        configuration.allowsCellularAccess = false
//        let session = Session(configuration: configuration)
        
        
//        //SessionDelegate - 代理
//        let delegate = SessionDelegate(fileManager: .default)
//        let session = Session(delegate:delegate)
        
        
        
//        //startRequestsImmediately - 是否立即请求
//        let session = Session(startRequestsImmediately: false)

        
        
//        //SessionDispatchQueue - 请求所在的消息队列
//        let rootQueue = DispatchQueue(label: "com.app.session.rootQueue")
//        let requestQueue = DispatchQueue(label: "com.app.session.requestQueue")
//        let serializationQueue = DispatchQueue(label: "com.app.session.serializationQueue")
//        let session = Session(rootQueue: rootQueue,
//                              requestQueue: requestQueue,
//                              serializationQueue: serializationQueue)
        
        
        
//        //RequestInterceptor - 拦截器
//        let policy = RetryPolicy()
//        let session = Session(interceptor: policy)
        
        
        
        
//        //ServerTrustManager - TLS验证
//        let manager = ServerTrustManager(evaluators: ["httpbin.org": PinnedCertificatesTrustEvaluator()])
//        let session = Session(serverTrustManager: manager)
        
        
        
//        //RedirectHandler - 重定向
//        let redirector = Redirector(behavior: .follow)
//        let session = Session(redirectHandler: redirector)
        
        
        
        
//        //CachedResponseHandler - 缓存
//        let cacher = ResponseCacher(behavior: .cache)
//        let session = Session(cachedResponseHandler: cacher)
        
        
        
        
//        //EventMonitor - 日志
//        let monitor = ClosureEventMonitor()
//        monitor.requestDidCompleteTaskWithError = { (request, task, error) in
//            debugPrint(request)
//        }
//        let session = Session(eventMonitors: [monitor])
        
        
        
        
        
        
        //配置任意网站都不校验证书
        var trustManager:ServerTrustManager? = nil
        #if DEBUG
        /**
         创建一个包含上述评估器的 ServerTrustManager 实例
         注意将 `allHostsMustBeEvaluated` 设为 `false`，这样就算没有为某个主机名指定评估器，它也会被信任
         */
        trustManager = ServerTrustManager(allHostsMustBeEvaluated:false,evaluators: ["www.apple.com":DisabledTrustEvaluator()])
        
        /**
         注意：下面方式需配置要指定域名才能跳过TLS证书验证
         */
//        trustManager = ServerTrustManager(evaluators: [
//            "www.apple.com": DisabledTrustEvaluator(),
//            "apple.com": DisabledTrustEvaluator(),
//            "www.apple.com.cn": DisabledTrustEvaluator(),
//            "apple.com.cn": DisabledTrustEvaluator(),
//        ])
        #endif
        
        
        //允许重定向
        let redirector = Redirector(behavior: .follow)
        
        //
        let session = Session(serverTrustManager:trustManager, redirectHandler: redirector)

        return session
    }
    
    
}






//MARK: - TKLog
extension AFNetworkTool{
    /** 是否启用NetworkTool的日志 */
    static var isLog = true
    /** 是否打印请求时Headers的信息，注意需要isLog==true时才有效*/
    static var isLogHeaders = false
    /** 是否打印Alamofire响应response数据（即可以打印所有数据包括：请求数据，响应数据，错误信息）*/
    static var isLogResponse = false
    
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



class DisabledEvaluator: ServerTrustEvaluating {
    func evaluate(_ trust: SecTrust, forHost host: String) throws {
        // 不执行任何操作，允许所有证书
    }
}

//class DisabledTrustEvaluator: ServerTrustEvaluating {
//    /// Creates an instance.
//    public init() {}
//
//    public func evaluate(_ trust: SecTrust, forHost host: String) throws {
//        // 不执行任何操作，允许所有证书
//    }
//}


