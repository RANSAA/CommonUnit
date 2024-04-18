//
//  RequestTool.swift
//  dfd
//
//  Created by PC on 2021/11/14.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif





class URLNetworkTool {
    
//MARK: - 基础配置

//MARK: -
    /**
     响应数据校验模式, 默认:loose模式
     */
    public static var verifyMode:ResponseVerifyMode = .loose
    
    /**
     是否允许对URL进行CharacterSet.urlQueryAllowed编码, defualt = true
     */
    public static var allowedURLEncoding:Bool = true

    
    
}

//MARK: -
extension URLNetworkTool{
    
    /**
     功能：对URLRequest对象进行公共通用的自定义处理，
     注意：重写是需要先super才能保留默认配置
     */
    public class func customURLRequest(req:URLRequest) -> URLRequest {
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
    public class func customResponseData(result:Data?, request:URLRequest, response:URLResponse?) -> Data?{
        return result
    }
    
    
    /**
     重写该方法，进行通用错误处理;注意：该方法执行的顺序优于所有错误处理方法之前。
     */
    public class func customResponseError(request:URLRequest, error:Error){
        
    }
    
}


//MARK: -
extension URLNetworkTool{
    
    /**
     创建URLRequest并对其进行通用配置
     */
    private class func configRequest(url:String,parameter:RequestParameter? = nil,method:RequestMethod, headers:[String:String]? = nil) -> URLRequest?{
        var mUrl = customRequestURL(url: url, method: method)
        let urlString = mUrl
        TKLog("[\(self)]  请求方式:\(method)   请求地址:\(urlString)")
        if allowedURLEncoding, let encURL = mUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed){
            mUrl = encURL
        }
        guard let url = URL(string: mUrl) else {
            let msg = "⚠️⚠️⚠️⚠️网络请求错误: URL对象创建失败! urlString:\(mUrl)"
            TKLog(msg)
            return nil
        }

        var req = URLRequest(url: url)
        

        
        
        //自定义通用属性
        req = customURLRequest(req: req)
        //配置专用的headers信息，将会替换掉具有相同名称的header值
        //先配置默认的header
        if let headers = customHeaders(){
            for (key,value) in headers{
                if key.isEmpty || value.isEmpty {
                    continue
                }
                req.setValue(value, forHTTPHeaderField: key)
            }
        }
        if let headers = headers {
            for (key,value) in headers{
                if key.isEmpty || value.isEmpty {
                    continue
                }
                /**
                 之前在这里设置header时遇到一个坑，
                 注意addValueXXX 和 setValueXXX的区别：
                 addValueXXX：添加时如果存在旧值时，新值将会被最加到旧值的后面
                 setValueXXX：设置时如果存在旧值时，新值将会替换旧值。
                 */
                req.setValue(value, forHTTPHeaderField: key)
            }
        }
        if isLogHeaders{
            TKLog("----------------------------Headers----------------------------")
            for (k,v) in req.allHTTPHeaderFields ?? [:] {
                TKLog("\(k):\(v)")
            }
            TKLog("----------------------------Headers----------------------------")
        }


        
        //设置请求方式
        req.httpMethod = method.rawValue
        
        
        //设置body

        
        switch method{
        case .POST, .PUT, .PATCH:
            if let mParameter = customRequestParameter(parameter: parameter, url: urlString) {
                TKLog("[\(self)]  请求参数编码方式:\(mParameter.format)    请求参数值:\(mParameter.reqString ?? "")")
                req.httpBody = mParameter.reqData
            }
        default:
            break
        }
        

        return req
    }
    
}

extension URLNetworkTool{
    
//MARK: - 基础的网络请求方法
    
    /**
     功能：基础的网络请求方法
     url: 请求URL
     parameter:请求参数
     method: 请求参数
     operationQueue: 操作队列，如果该值不为空，并设置maxConcurrentOperationCount=1，则可以让请求按顺序执行，即上一个请求获取数据后才会开始下一个请求。
     success: 请求成功回调
        resultData: 响应数据
        statusCode: 响应状态码
     fail: 请求错误回调
        error:请求错误error
     */
    public class func baseRequest(url:String,
                                  parameter:RequestParameter? = nil ,
                                  method:RequestMethod = .GET,
                                  headers:[String:String]? = nil,
                                  operationQueue:OperationQueue? = nil,
                                  success:@escaping(_ resultData:Data?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                                  fail:@escaping (_ error:Error, _ request:URLRequest) -> Void ) {
        guard let req:URLRequest = configRequest(url: url, parameter: parameter, method: method, headers: headers) else {
            return
        }
        
        let session = self.sharedSession(queue: operationQueue)
        
        if let operationQueue {
            let operation = URLSessionTaskOperation(session: session, req: req) { data, response, error in
                let resultData = self.customResponseData(result: data, request: req, response: response)
                self.finishResponse(req: req, resData: resultData, response: response, error: error, success: success, fail: fail)
            }
            operationQueue.addOperation(operation)
        }else{
            let task = session.dataTask(with: req) { data, response, error in
                let resultData = self.customResponseData(result: data, request: req, response: response)
                self.finishResponse(req: req, resData: resultData, response: response, error: error, success: success, fail: fail)
            }
            task.resume()
        }
        
    }
    
    
    //响应数据通用处理
    private class func finishResponse(req:URLRequest,
                                      resData:Data?,
                                      response:URLResponse?,
                                      error:Error?,
                                      success:@escaping(_ resultData:Data?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                                      fail:@escaping (_ error:Error, _ request:URLRequest) -> Void ) {
        var errmsg:String = ""
        var statusCode = -1
        
        let url:URL! = req.url
        if let response = response as? HTTPURLResponse{//statusCode != 200
            statusCode = response.statusCode
        }
        
        if let error {
            let nserror = error as NSError
            let localizedDescription = "error:\(error.localizedDescription)"
            
            //在宽松模式下，如果error.userinfo.data中有数据，或者resData不为空则直接获取error.userinfo.data中的数据为正确响应数据
            if let resData, self.verifyMode == .loose {
                errmsg = "[\(self)]  ✅✅✅✅注意：当前网络请求出现错误，但是响应body存在数据，，所有本次请求依然作为成功响应。  url：\(url.absoluteString)   error:\(localizedDescription)"
                TKLog("\(errmsg)")
                
                statusCode = 200
                success(resData,statusCode,req,response)
            }else{
                if self.verifyMode == .loose, let data:Data = nserror.userInfo["data"] as? Data{
                    errmsg = "[\(self)]  ✅✅✅✅注意：当前网络请求出现错误，但是error.userinfo.data中存在数据，所有本次请求依然作为成功响应；并且将erro.userinfo.data的数据作为响应数据。 url：\(url.absoluteString)   error:\(localizedDescription)"
                    TKLog("\(errmsg)")
                    
                    statusCode = 200
                    success(data,statusCode,req,response)
                }else{
                    errmsg = "[\(self)]  ⚠️⚠️⚠️⚠️网络请求失败：\(url.absoluteString)   error:\(localizedDescription)"
                    TKLog("\(errmsg)")
                    
                    self.customResponseError(request: req, error: error)
                    fail(error,req)
                }
            }
        }else{
            success(resData,statusCode,req,response)
        }
    }
    
    
//MARK: -
}


extension URLNetworkTool{

    public class func data(url:String,
                           parameter:RequestParameter? = nil ,
                           method:RequestMethod = .GET,
                           headers:[String:String]? = nil ,
                           operationQueue:OperationQueue? = nil,
                           success:@escaping(_ resultData:Data?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                           fail:@escaping (_ error:Error, _ request:URLRequest) -> Void ){
        
        baseRequest(url: url, parameter: parameter, method: method, headers: headers, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    public class func string(url:String,
                             parameter:RequestParameter? = nil ,
                             method:RequestMethod = .GET,
                             headers:[String:String]? = nil,
                             encoding:String.Encoding = .utf8,
                             operationQueue:OperationQueue? = nil,
                             success:@escaping(_ resultStr:String?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                             fail:@escaping (_ error:Error, _ request:URLRequest) -> Void ) {
        
        data(url: url,parameter: parameter,method: method,headers: headers,operationQueue: operationQueue) { resultData, statusCode, request, response in
            var resultStr:String? = nil
            if let resultData{
                resultStr = String(data: resultData, encoding: encoding)
            }
            success(resultStr,statusCode,request,response)
        } fail: { error,request in
            fail(error,request)
        }
    }
    
}


extension URLNetworkTool{
    
    /**
     获取Data数据，并且参数使用JSON格式编码，参数传递形式为[String:Any?]?
     */
    public class func dataJSON(url:String,
                               parameter:[String:Any?]? = nil,
                               method:RequestMethod = .GET,
                               headers:[String:String]? = nil,
                               operationQueue:OperationQueue? = nil,
                               success:@escaping(_ resultData:Data?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                               fail:@escaping (_ error:Error, _ request:URLRequest) -> Void )  {
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleJson
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        let parameter = RequestParameter.dictJson(parameter)
        data(url: url,parameter: parameter,method: method,headers: _headers ,operationQueue: operationQueue, success: success, fail: fail)
    }
    

    /**
     获取Data数据，并且参数使用URL Query格式编码，参数传递形式为[String:Any?]?
     */
    public class func dataQuery(url:String,
                               parameter:[String:Any?]? = nil,
                               method:RequestMethod = .GET,
                               headers:[String:String]? = nil,
                               operationQueue:OperationQueue? = nil,
                               success:@escaping(_ resultData:Data?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                               fail:@escaping (_ error:Error, _ request:URLRequest) -> Void )  {
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleUrlEncoded
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        let parameter = RequestParameter.dictQuery(parameter)
        data(url: url,parameter: parameter,method: method,headers: _headers ,operationQueue: operationQueue, success: success, fail: fail)
    }
    
    

    
    /**
     获取String字符串数据，并且参数使用JSON格式编码，参数传递形式为[String:Any?]?
     */
    public class func stringJSON(url:String,
                                 parameter:[String:Any?]? = nil,
                                 method:RequestMethod = .GET,
                                 headers:[String:String]? = nil,
                                 encoding:String.Encoding = .utf8 ,
                                 operationQueue:OperationQueue? = nil,
                                 success:@escaping(_ resultStr:String?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                                 fail:@escaping (_ error:Error, _ request:URLRequest) -> Void ) {
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleJson
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        let parameter = RequestParameter.dictJson(parameter)
        string(url: url,parameter: parameter,method: method,headers: _headers , encoding: encoding, operationQueue: operationQueue, success: success, fail: fail)
    }
    
    
    
    /**
     获取String字符串数据，并且参数使用URL Query格式编码，参数传递形式为[String:Any?]?
     */
    public class func stringQuery(url:String,
                                  parameter:[String:Any?]? = nil,
                                  method:RequestMethod = .GET,
                                  headers:[String:String]? = nil,
                                  encoding:String.Encoding = .utf8 ,
                                  operationQueue:OperationQueue? = nil,
                                  success:@escaping(_ resultStr:String?, _ statusCode:Int, _ request:URLRequest, _ response:URLResponse?) -> Void,
                                  fail:@escaping (_ error:Error, _ request:URLRequest) -> Void ) {
        var _headers:[String:String] = [
            RequestHeaders.Headers.ContentType:RequestHeaders.Headers.ContentTypeVauleUrlEncoded
        ]
        if let headers{
            for (key,value) in headers{
                _headers[key] = value
            }
        }
        let parameter = RequestParameter.dictQuery(parameter)
        string(url: url,parameter: parameter,method: method, headers: _headers, encoding: encoding, operationQueue: operationQueue, success: success, fail: fail)
    }
    
}



//MARK: -
extension URLNetworkTool{
    /**
     是否使用自定义的URLSession
     */
    static var isCustomSession = true
        
    /**
     注意：创建大量的URLSession对象会有严重的内存泄漏问题，这个问题是URLSession自带的一个旧未解决的问题；
     所以：需要大量网络请求时只需要创建一个URLSession对象来进行网络请求处理即可。
     特别注意：在使用一个URLSession对象进行网络请求管理时不要使用: finishTasksAndInvalidate()和invalidateAndCancel()方法
     失URLSession对象失效，因为失效的URLSession对象重新请求网络时会触发一个运行时的错误。
     */
    static func sharedSession(queue:OperationQueue?) -> URLSession{
        if isCustomSession{
            return _customSession
        }else{
            return URLSession.shared
        }
    }
    
    private static let _customSession = customSession()
    private static func customSession() -> URLSession{
        TKLog("NetworkTool Custom Session......")
        //添加代理，解决网址重定向引起的崩溃问题(linux下)
        let configuration = URLSessionConfiguration.default // .ephemeral
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        
        unowned let delegate = URLNetworkToolDelegate.shared // or URLNetworkToolDelegate()
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
        return session
    }
}


//MARK: - TKLog
extension URLNetworkTool{
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
