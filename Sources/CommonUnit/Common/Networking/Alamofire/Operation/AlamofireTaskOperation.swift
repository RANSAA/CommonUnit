//
//  File.swift
//  
//
//  Created by kimi on 2024/4/3.
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
 */
class AlamofireTaskOperation:AsyncOperation{
    private var session:Session
    private var url:URLConvertible
    
    //编码 `MultipartFormData` 时使用的默认内存阈值，以字节为单位。
    private var usingThreshold: UInt64 =  10_000_000 //10M
    
    //MARK: -
    /**
     普通参数数据
     注意：必须使用RequestParameter.dictJson方式传输
     */
    private var parameter:RequestParameter? = nil
    /**
     需要向fromdata中传递的data数组
     */
    private var fileParameters:[RequestParameterFile]? = nil
    
    /**
     下载数据的保存地址
     */
    private var outputPath:String? = nil
    
    /**
     请求类型
     */
    private var method:RequestMethod
    
    /**
     headers
     */
    private var headers:HTTPHeaders? = nil
    
    private var interceptor:RequestInterceptor? = nil
    
    private var requestModifier:Session.RequestModifier? = nil
    
    
    
    //MARK: -
    private let responseQueue = DispatchQueue(label: "com.DispatchQueue.AlamofireTaskOperation", qos: .utility)
    
    
    
    private var isLogResponse:Bool
    
    
    //MARK: -
    /**
     上传进度block
     received：当前已经请求的大小
     expected：预期的总大小
     */
    var blockUploadProgress:((_ received:Int,_ expected:Int) -> Void)?
    
    /**
     下载进度block
     received：当前已经请求的大小
     expected：预期的总大小
     */
    var blockDownloadProgress:((_ received:Int,_ expected:Int) -> Void)?
    
    /**
    请求成功block
     resultData：响应数据
     statusCode：响应状态码
     request：请求对象
     response：响应对象
    */
    var blockSuccess:((_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void)?
    
    /**
     请求失败的block
     error：请求错误信息
     */
    var blockFail:((_ error:Error, _ request:URLRequest) -> Void)?
    
    
    //MARK: -
    /**
     初始化
     - session：Alamofire请求Session
     - url：请求URL
     - parameter：请求参数(普通参数)
     - fileParameters：需要向form-data中追加的参数
     - outputPath：请求数据的保存路径，如果该值存在，并且是一个正确的路径地址时，blockSuccess回调中的data将会返回为nil，注意该属性一般用于下载大文件到磁盘。
     - method：请求方式
     - headers：请求headers标头
     - interceptor：Alamofire请求拦截器
     - requestModifier：Alamofire请求修改器
     - blockUploadProgress：上传进度block
     - blockDownloadProgress：下载进度block
     - blockSuccess：请求成功回调
     - blockFail：请求失败回调
     */
    init(session: Session,
         url:URLConvertible,
         parameter: RequestParameter? = nil,
         fileParameters: [RequestParameterFile]? = nil,
         outputPath:String? = nil,
         method: RequestMethod,
         headers: HTTPHeaders? = nil,
         interceptor: RequestInterceptor? = nil,
         requestModifier: Session.RequestModifier? = nil,
         isLogResponse:Bool,
         blockUploadProgress: @escaping (_ received:Int,_ expected:Int) -> Void,
         blockDownloadProgress: @escaping (_ received:Int,_ expected:Int) -> Void,
         blockSuccess: @escaping (_ resultData:Data?,_ statusCode:Int,_ request:URLRequest, _ response:URLResponse?) -> Void,
         blockFail: @escaping (_ error:Error, _ request:URLRequest) -> Void)
    {
        self.session = session
        self.url = url
        
        self.parameter = parameter
        self.fileParameters = fileParameters
        self.outputPath = outputPath
        self.method = method
        self.headers = headers
        
        self.interceptor = interceptor
        self.requestModifier = requestModifier
        
        self.isLogResponse = isLogResponse
        
        self.blockUploadProgress = blockUploadProgress
        self.blockDownloadProgress = blockDownloadProgress
        
        self.blockSuccess = blockSuccess
        self.blockFail = blockFail
    }
    
    
    //MARK: -
    
    //AF的请求request
    var task:Request? = nil
    
    
    
    //MARK: - Operation OverWrite
    override func main() {
        if isCancelled {
            return
        }
        
        //启动请求任务
        startTask()
    }
    
    override func cancel() {
        //当你需要取消任务时
        task?.cancel()
        super.cancel()
    }
    
    override func finish() {
        clear()
        super.finish()
    }
    
    /**
     清理相数据
     */
     func clear(){
         task = nil
    }
    
    //MARK: - Operation OverWrite
}



extension AlamofireTaskOperation{
    
    /**
     启动请求任务
     */
    private func startTask(){
        if self.method.hasRequestBody == .yes {
            methodPOST()
        }else{
            methodGET()
        }
    }
    
}



extension AlamofireTaskOperation{
    
    /**
     执行形如POST方式可向body传输数据的请求
     */
    private func methodPOST(){

        var hasParameter = false
        var hasFileParameters = false
        if self.parameter != nil{
            hasParameter = true
        }
        if self.fileParameters != nil{
            hasFileParameters = true
        }
        
        let _method = HTTPMethod(rawValue: self.method.rawValue)

        

        //fileParameters位置存在参数数据
        if hasFileParameters {
            let formData:MultipartFormData = MultipartFormData()
            //两个位置的参数同时存在
            //将parameter区域中的参数追加到form-data中
            if hasParameter{
                if let parameter, let dictJson = parameter.associatedValue as? [String:Any?] {
                    for (name,value) in dictJson {
                        //⚠️提示：先将基础类型转换成String，再将String转换成Data
                        if let value{
                            let data = "\(value)".data(using: .utf8)!
                            formData.append(data, withName: name)
                        }else{
                            TKLog("[\(self)]  ⚠️⚠️⚠️⚠️parameter中出现了值为空的参数值,  name:\(name)   value:nil")
                        }
                    }
                }else{
                    TKLog("[\(self)]  ⚠️⚠️⚠️⚠️parameter参数添加失败，parameter参数应该形如[key:value]的字典格式。")
                }
            }
            //将fileParameters区域中的参数追加到form-data中
            if let fileParameters {
                for itemPar in fileParameters {
                    switch itemPar.associatedType {
                    case .url :
                        let fileURL = itemPar.url!
                        formData.append(fileURL, withName: itemPar.name)
                        TKLog("[\(self)]  请求参数编码方式:multipart/form-data     name:\(itemPar.name)     value:\(fileURL)")
                    case .data :
                        formData.append(itemPar.data!, withName: itemPar.name, fileName: itemPar.fileName)
                        TKLog("[\(self)]  请求参数编码方式:multipart/form-data     name:\(itemPar.name)     value:\(String(describing: itemPar.data))   filename:\(itemPar.fileName)")
                    default:
                        TKLog("[\(self)]  ⚠️⚠️⚠️⚠️FileParameters参数中关联的参数类型不为Data,URL或String Path类型。 name:\(itemPar.name)   ")
                        break
                    }
                }
            }
//            TKLog("[\(self)]  multipart/form-data contentLength:\(formData.contentLength)")
           
            
            //请求上传
            self.task = session.upload(multipartFormData: formData, to: self.url, usingThreshold: self.usingThreshold, method: _method, headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier)
                .uploadProgress { [weak self] progress in
                    if let self {
                        self.taskUploadProgress(progress: progress)
                    }
                }
                .downloadProgress { [weak self] progress in
                    if let self {
                        self.taskDownloadProgress(progress: progress)
                    }
                }
                .responseData(queue: responseQueue ) { [weak self] response in
                    //outputPath
                    if let self {
                        self.taskResponseFinish(response: response)
                    }
                }
            
        }
        //只有parameter位置存在参数数据
        else if hasParameter, let data = parameter?.reqData {
            if let outputPath {
                let destination: DownloadRequest.Destination = { _, _ in
                    var fileURL:URL = URL(string: outputPath)!
                    if !fileURL.absoluteString.hasPrefix("file://"){
                        fileURL = URL(fileURLWithPath: outputPath)
                    }
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                self.task = session.download(self.url, method: _method, headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier, to: destination)
                    .downloadProgress { [weak self] progress in
                        if let self {
                            self.taskDownloadProgress(progress: progress)
                        }
                    }
                    .responseData(queue: responseQueue ) {[weak self] response in
                        if let self {
                            self.taskResponseFinish(response: response)
                        }
                    }
            }else{
                self.task = session.upload(data, to: self.url, method: _method , headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier)
                    .uploadProgress { [weak self]  progress in
                        if let self {
                            self.taskUploadProgress(progress: progress)
                        }
                    }
                    .downloadProgress { [weak self]  progress in
                        if let self {
                            self.taskDownloadProgress(progress: progress)
                        }
                    }
                    .responseData(queue: responseQueue ) { [weak self] response in
                        //outputPath
                        if let self {
                            self.taskResponseFinish(response: response)
                        }
                    }
            }
        }
        //两个位置的参数都不存在
        else{
            //如果指定了文件下载路径
            if let outputPath {
                let destination: DownloadRequest.Destination = { _, _ in
                    var fileURL:URL = URL(string: outputPath)!
                    if !fileURL.absoluteString.hasPrefix("file://"){
                        fileURL = URL(fileURLWithPath: outputPath)
                    }
                    return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                }
                self.task = session.download(self.url, method: _method, headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier, to: destination)
                    .downloadProgress { [weak self] progress in
                        if let self {
                            self.taskDownloadProgress(progress: progress)
                        }
                    }
                    .responseData(queue: responseQueue ) {[weak self] response in
                        if let self {
                            self.taskResponseFinish(response: response)
                        }
                    }
            }else{
                self.task = session.request(self.url, method: _method, headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier)
                    .downloadProgress {[weak self] progress in
                        if let self {
                            self.taskDownloadProgress(progress: progress)
                        }
                    }
                    .responseData(queue: responseQueue ) {[weak self] response in
                        if let self {
                            self.taskResponseFinish(response: response)
                        }
                    }
            }
            
        }
        
    }

    
}


extension AlamofireTaskOperation{
    
    /**
     执行形如GET方式不可向body中传递数据的请求
     */
    private func methodGET(){
        let _method = HTTPMethod(rawValue: self.method.rawValue)
        
        if let outputPath {
            let destination: DownloadRequest.Destination = { _, _ in
                var fileURL:URL = URL(string: outputPath)!
                if !fileURL.absoluteString.hasPrefix("file://"){
                    fileURL = URL(fileURLWithPath: outputPath)
                }
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            self.task = session.download(self.url, method: _method, headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier, to: destination)
                .downloadProgress { [weak self] progress in
                    if let self {
                        self.taskDownloadProgress(progress: progress)
                    }
                }
                .responseData(queue: responseQueue ) {[weak self] response in
                    if let self {
                        self.taskResponseFinish(response: response)
                    }
                }
        }else{
            self.task = session.request(self.url, method: _method, headers: self.headers, interceptor: self.interceptor, requestModifier: self.requestModifier)
                .downloadProgress {[weak self] progress in
                    if let self {
                        self.taskDownloadProgress(progress: progress)
                    }
                }
                .responseData(queue: responseQueue ) {[weak self] response in
                    if let self {
                        self.taskResponseFinish(response: response)
                    }
                }
        }
    }
    
}


extension AlamofireTaskOperation{
    
    /**
     上传进度
     */
    private func taskUploadProgress(progress:Progress){
        let completed = Int(progress.completedUnitCount)
        let total = Int(progress.totalUnitCount)
        self.blockUploadProgress?(completed,total)
    }
    
    
    
    /**
     下载进度
     */
    private func taskDownloadProgress(progress:Progress){
        let completed = Int(progress.completedUnitCount)
        let total = Int(progress.totalUnitCount)
        self.blockDownloadProgress?(completed,total)
    }
    
    

    
    /**
     请求任务完成(也可以是请求失败)
     */
    private func taskResponseFinish(response:AFDataResponse<Data> ) {
//        //标记当前操作完成
//        self.finish()
        
        
        if isLogResponse {
            debugPrint(response)
        }


        //请求错误
        if let error = response.error {
            _taskResponseError(error: error, request: response.request)
        }else{
            let _statusCode = response.response?.statusCode ?? 200
            let _request = response.request
            let _response = response.response
            
            if outputPath != nil{
                _taskResponseBody(data: nil, statusCode: _statusCode, request: _request, response: _response)
            }else{
                let _data = response.data
                _taskResponseBody(data: _data, statusCode: _statusCode, request: _request, response: _response)
            }
        }
    }
    
    private func taskResponseFinish(response:AFDownloadResponse<Data>){
//        //标记当前操作完成
//        self.finish()
        
        
        if isLogResponse {
            debugPrint(response)
        }

        
        if let error = response.error {
            _taskResponseError(error: error, request: response.request)
        }else{
            //注意：仅返回下载数据保存在本地的路径
//            response.resumeData //恢复数据，用于断点续传 -- 该工具没有实现断点续传(下载)功能
            
            let _statusCode = response.response?.statusCode ?? 200
            let _request = response.request
            let _response = response.response
            
            //数据下载后保存的保存的路径
            if let fileURL = response.fileURL{
                TKLog("File URL:\(fileURL)")
            }
                        
            _taskResponseBody(data: nil, statusCode: _statusCode, request: _request, response: _response)
        }
    }
    
}


extension AlamofireTaskOperation{
    
    /**
     response error
     提示：request一定可以被解包，因为传入的URL一定能创建URLRequest
     */
    private func _taskResponseError(error:AFError, request:URLRequest?){
        TKLog("[\(self)] - ⚠️⚠️⚠️⚠️请求失败。 error：\(error)")
        self.blockFail?(error, request!)
        
        //标记当前操作完成 - 等待回调完成
        self.finish()
    }
    
    /**
     response success body
     提示：request一定可以被解包，因为传入的URL一定能创建URLRequest
     */
    private func _taskResponseBody(data:Data?, statusCode:Int, request:URLRequest?, response:URLResponse?){
        self.blockSuccess?(data, statusCode,request!,response)
        
        //标记当前操作完成 - 等待回调完成
        self.finish()
    }
    
}
