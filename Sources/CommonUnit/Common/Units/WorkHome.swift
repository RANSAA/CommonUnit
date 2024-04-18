//
//  File.swift
//  
//
//  Created by kimi on 2024/1/19.
//

import Foundation


/**
 管理需要的路径，并且适配了Vapor常用的目录
 */
//struct WorkHome:Codable{
//    public static let shared:WorkHome = .init()
//
//    /** 执行程序所在的目录 */
//    private(set) var executableDirectory:String
//
//    /** 工作目录，默认为程序可执行目录 */
//    var workingDirectory:String{
//        executableDirectory
//    }
//
//    /** Public目录 */
//    var publicDirectory:String{
//        executableDirectory+"Public/"
//    }
//
//    /** Resources目录 */
//    var resourcesDirectory:String{
//        executableDirectory+"Resources/"
//    }
//
//    /** Resources/Viewsm目录*/
//    var viewsDirectory:String{
//        executableDirectory+"Resources/Views/"
//    }
//
//    /**
//           设置程序的工作目录，如果未设置则使用程序所在的目录为workingDirectory
//        **/
//        public static func config(_ workingDirectory:String?){
//            if let workingDirectory {
//                self.workingDirectory = workingDirectory.hasSuffix("/") ? workingDirectory : workingDirectory+"/"
//            }
//        }
//
//        init(){
//            let bundlePath:String
//            if let workPath = Self.workingDirectory{
//                bundlePath = workPath
//            }else{
//                bundlePath = Bundle.main.bundlePath+"/"
//            }
//
//            execDirectory = Bundle.main.bundlePath+"/"
//
//            workingDirectory = bundlePath
//            publicDirectory = bundlePath + "Public/"
//            resourcesDirectory = bundlePath + "Resources/"
//            viewsDirectory = bundlePath + "Resources/Views/"
//            shellDirectory = bundlePath + "Resources/Tasks/"
//
//            info()
//        }
//
//        public func info(){
//            print("execDirectory  :\(execDirectory)")
//            print("workingDirectory  :\(workingDirectory)")
//            print("publicDirectory   :\(publicDirectory)")
//            print("resourcesDirectory:\(resourcesDirectory)")
//            print("viewsDirectory    :\(viewsDirectory)")
//            print("shellDirectory    :\(shellDirectory)")
//        }
//
//}






/**
 管理应用程序的工作目录
**/
public struct WorkHome{
    private static var workingDirectory:String? = nil
    public static let shared = Self.init()


    //程序当前所在的工作目录
    public let workingDirectory:String
    //Public 目录
    public let publicDirectory:String
    //Resources 目录
    public let resourcesDirectory:String
    //Views 目录
    public let viewsDirectory:String
    //Shell Task 目录
    public let shellDirectory:String
    //当前程序所在的目录
    public let execDirectory:String

    /**
       设置程序的工作目录，如果未设置则使用程序所在的目录为workingDirectory
    **/
    public static func config(_ workingDirectory:String?){
        if let workingDirectory {
            self.workingDirectory = workingDirectory.hasSuffix("/") ? workingDirectory : workingDirectory+"/"
        }
    }

    init(){
        let bundlePath:String
        if let workPath = Self.workingDirectory{
            bundlePath = workPath
        }else{
            bundlePath = Bundle.main.bundlePath+"/"
        }

        execDirectory = Bundle.main.bundlePath+"/"
        
        workingDirectory = bundlePath
        publicDirectory = bundlePath + "Public/"
        resourcesDirectory = bundlePath + "Resources/"
        viewsDirectory = bundlePath + "Resources/Views/"
        shellDirectory = bundlePath + "Resources/Tasks/"

//        info()
    }

    public func info(){
        print("execDirectory  :\(execDirectory)")
        print("workingDirectory  :\(workingDirectory)")
        print("publicDirectory   :\(publicDirectory)")
        print("resourcesDirectory:\(resourcesDirectory)")
        print("viewsDirectory    :\(viewsDirectory)")
        print("shellDirectory    :\(shellDirectory)")
    }
}
