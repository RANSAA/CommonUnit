//
//  File.swift
//
//
//  Created by kimi on 2024/3/23.
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
 该操作对AsyncHTTPClient网络请求工具进行了封装，并且使用了async/await特性，所有使用该代码是Swift的版本必须大于等于Swift 5.5；
 如果Swift版本小于5.5，这需要使用SwiftNIO EventLoopFuture方式处理网络请求，该操作中未实现，如果需要请自行参考官网示例。
 
 
 说明1：
 该封装的网络请求支持下载大文件
 
 说明2：
 关于如何获取request和response中的header信息，可以使用下面的方法获取
 for header in request.headers {//or response.headers
     let name = header.name
     let value = header.value
     print("\(name): \(value)")
 }
 
 */
class VaporTaskOperation:AsyncOperation{
    //用于在普通方法中调用async的Task
    private var task:Task<Void, Error>?

    
    //swift 5.5+
    var httpClient:HTTPClient
    var request:HTTPClientRequest
    
    //请求超时
    var timeout:Int
    
    /**
     请求body内容输出路径，如果该值不为空，则success block中的resultData将为空(即此状态下resultData的值不返回);
     该值的使用场景是请求大文件时，例如需要下载一个2G的文件就需要设置输出路径，每请求到一点数据就保存到磁盘；
     如果不这样，先将所有的数据缓存到内存，直到所有数据请求完毕后，再保存到磁盘，这样是需要很大的内存，所以这样的操作很不合理。
     */
    private(set) var outputPath:String?
    //是否将数据缓存到磁盘
    private var cacheDisk = false
    private var fileHandle:FileHandle?

    
//MARK: -
    /**
     请求进度回调block
     received：当前已经请求的大小
     expected：预期的总大小
     */
    var blockProgress:((_ received:Int,_ expected:Int) -> Void)?
    
    /**
    请求成功block
     resultData：响应数据
     statusCode：响应状态码
     request：请求对象
     response：响应对象
    */
    var blockSuccess:((_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void)?
    
    /**
     请求失败的block
     error：请求错误信息
     */
    var blockFail:((_ error:Error, _ request:HTTPClientRequest) -> Void)?
   

//MARK: -
    

    /// 初始化操作
    /// - Parameters:
    ///   - httpClient: 请求客户端
    ///   - request: 请求参数
    ///   - outputPath: 响应数据保存路径，可选。如果该值存在(即是一个正确的路径)那么success回调时就不会返回响应数据
    ///   - timeout: 请求超时时间
    ///   - progress: 请求进度回调
    ///   - success: 请求成功回调，其中是否返回响应数据与outputPath的值是否存在相关，如果存在并且是一个正确的路径那么将不会返回响应数据，反之一定会返回响应数据(如果响应数据为空则会返回一个空的Data数据)
    ///   - fail: 请求错误
    init(httpClient: HTTPClient,
         request: HTTPClientRequest,
         outputPath:String? = nil ,
         timeout:Int = 30,
         progress:@escaping (_ received:Int,_ expected:Int) -> Void,
         success:@escaping (_ resultData:Data?,_ statusCode:Int,_ request:HTTPClientRequest, _ response:HTTPClientResponse?) -> Void,
         fail:@escaping (_ error:Error, _ request:HTTPClientRequest) -> Void)
    {
        self.httpClient = httpClient
        self.request = request
        self.timeout = timeout
        
        if let outputPath{
            self.cacheDisk = FileManager.default.createFile(atPath: outputPath, contents: nil)
            if self.cacheDisk {
                self.fileHandle = FileHandle(forWritingAtPath: outputPath)
                self.outputPath = outputPath
            }
        }
        
        self.blockProgress = progress
        self.blockSuccess = success
        self.blockFail = fail
    }
    
   
    
    


//MARK: -
    
    override func main() {
        if isCancelled {
            return
        }
        
        
        //可以在这里启动Task任务
//        Task{
//            await startTask()
//        }
        
        // 创建任务并保留任务句柄
        self.task = Task.detached { [unowned self] in
            await startTask()
        }
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
    
//MARK: -
}



extension VaporTaskOperation{
    
    /**
     功能：开始执行AsyncHTTPClient网络请求
     注意：关于如何获取request和response中的header信息，可以使用下面的方法获取
     for header in request.headers {//or response.headers
         let name = header.name
         let value = header.value
         print("\(name): \(value)")
     }
     */
    private func startTask() async {
        do {
            let response:HTTPClientResponse = try await self.httpClient.execute(request, timeout: .seconds(Int64(self.timeout)))
            
            //响应状态码
            let statusCode = response.status.code
                        
            //获取数据总字节数，注意只有响应的header中包含content-length字段才能获取到文件的总大小
            let expectedBytes = response.headers.first(name: "content-length").flatMap(Int.init) ?? -1
            //已经请求的字节数
            var receivedBytes = 0
            
            //转载请求数据的buffer
            var buffer = ByteBuffer()
            
            for try await _buffer in response.body {
                //需要保存到磁盘
                if self.cacheDisk{
                    //注意：如果需要将每次获取的buffer转换成Data，通过过度tmpBuffer将无法获取转换成Data,即：var tmpBuffer = _buffer
                    //let data = _buffer.getData(at: _buffer.readerIndex, length: _buffer.readableBytes)
                    let fragmentData = Data(buffer: _buffer)
                    self.fileHandle?.write(fragmentData)
                }else{//缓存到内存
                    var tmpBuffer = _buffer
                    buffer.writeBuffer(&tmpBuffer)
                }
                
                //获取请求进度
                if expectedBytes != -1 {
                    receivedBytes += _buffer.readableBytes
                    self.blockProgress?(receivedBytes,expectedBytes)
                }
            }
            
            
            if self.cacheDisk{//设置了请求数据的保存路径后，blockSuccess回调时就不需要返回响应数据
                self.blockSuccess?(nil,Int(statusCode),request,response)
            }else{//获取内存中缓存的数据，并通过blockSuccess回调返回响应数据。
                //buffer.getData(at: buffer.readerIndex, length: buffer.readableBytes)
                let resultData = Data(buffer: buffer)
                self.blockSuccess?(resultData,Int(statusCode),request,response)
            }
            
  
            //无法从响应header中获取请求文件大小时，将会在文件请求完毕后直接返回为1的进度
            if expectedBytes == -1{
                self.blockProgress?(buffer.readableBytes,buffer.readableBytes)
            }
        
        } catch  {
            print("Error:\(error)")
            self.blockFail?(error, request)
        }
        
        
        //shutdown
        await self.httpClientShutdown()
        

    }
    
    
    /**
     对httpClient执行shutdown操作
     */
    private func httpClientShutdown() async{
        //完成操作 - 在HTTPClient关闭之前通知完成
        self.finish()
        
        
        //需要执行shutdown()操作
        if VaporNetworkTool.isCustomSession {
//            //方式一
//            Task{
//                do {
//                    try await httpClient.shutdown()
//                } catch {
//                    print("[\(self)]  ⚠️⚠️⚠️⚠️HTTPClient ShutDown Error:\(error)")
//                }
//            }
            
            //方式二:
            do {
                try await httpClient.shutdown()
            } catch {
                print("[\(self)]  ⚠️⚠️⚠️⚠️HTTPClient ShutDown Error:\(error)")
            }
        }
        

//        //完成操作 - 在HTTPClient关闭之后通知完成
//        self.finish()
    }
    
}
