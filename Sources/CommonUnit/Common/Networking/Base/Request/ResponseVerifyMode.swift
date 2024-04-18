//
//  File.swift
//  
//
//  Created by kimi on 2024/1/20.
//

import Foundation

/**
 HTTPURLResponse响应数据校验模式
 body中有数据而且可能需要解析数据，如header中的状态码为304但是用户需要解析body的数据并返回给用户,这又分为两种校验状态(AFNetworking框架回出现这种情况)
 loose:只校验body中是否有数据，只要有数据就当做解析成功，默认使用这种方式校验
 strict:只校验header中的状态码，不管是body中否有数据，只要code != 200 统统视为网络请求失败，即使body中数据对用户来说有效。
 */
enum ResponseVerifyMode{
    case loose   //宽松，默认
    case strict  //严格
}
