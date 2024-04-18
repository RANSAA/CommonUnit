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


class URLSessionDownloadOperation : AsyncOperationV2 {
    var task: URLSessionTask!
     
    init(session: URLSession, url: URL) {
        super.init()
         
        task = session.downloadTask(with: url) { temporaryURL, response, error in
            defer { self.finish() }
             
            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode
            else {
                // handle invalid return codes however you'd like
                return
            }
 
            guard let temporaryURL = temporaryURL, error == nil else {
                print(error ?? "Unknown error")
                return
            }
             
            do {
                let manager = FileManager.default
                let destinationURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                    .appendingPathComponent(url.lastPathComponent)
                try? manager.removeItem(at: destinationURL)                   // remove the old one, if any
                try manager.moveItem(at: temporaryURL, to: destinationURL)    // move new one there
            } catch let moveError {
                print("\(moveError)")
            }
        }
    }
     
    override func cancel() {
        task.cancel()
        super.cancel()
    }
     
    override func main() {
        task.resume()
    }
     
} 
