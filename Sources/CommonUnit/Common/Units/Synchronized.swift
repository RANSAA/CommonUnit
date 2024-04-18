//
//  Synchronized.swift
//  
//
//  Created by kimi on 2024/4/14.
//

import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif



/**
 功能简介： 模拟:@synchronized(self){}
 使用方法： synchronized(self){}
 注意事项： 只能对class进行加锁操作
 
 
 常用的加锁方式：
 1. NSLock
 2. DispatchSemaphore
 3. synchronized
 4. GCD同步模拟
 5. 其它
 */






/**
 使用DispatchSemaphore（它的value值应该设置为1）信号量实现同步加锁操作(就是先wait再signal操作)，并且适用于高并发场景。提示：该方法不是一个同步操作。
 注意：如果你打算在代码中多次使用这个线程锁，可以将用来加锁的对象(DispatchSemaphore，DispatchQueue，NSLock)存储在类的属性中或者其他方便存取的位置。这种方式可以帮助我们确保所有相应的异步操作是有序的，并且不会同时进行，从而可以避免许多常见的并发问题，例如竞争条件（race condition）和数据不一致。
 */
public func synchronized<T>(_ semaphore: DispatchSemaphore, _ body: () throws -> T) rethrows -> T {
    semaphore.wait()   // 等待信号
    defer { semaphore.signal() }  // 发送信号
    return try body()
}





/**
 DispatchQueue串行队列(警告：不能是并发队列)的sync的同步操作来实现同步加锁操作。提示：该方法是一个同步操作
 注意：如果你打算在代码中多次使用这个线程锁，可以将用来加锁的对象(DispatchSemaphore，DispatchQueue，NSLock)存储在类的属性中或者其他方便存取的位置。这种方式可以帮助我们确保所有相应的异步操作是有序的，并且不会同时进行，从而可以避免许多常见的并发问题，例如竞争条件（race condition）和数据不一致。
 */
public func synchronized<T>(_ queue: DispatchQueue, _ body: () throws -> T) rethrows -> T {
    return try queue.sync {
        return try body()
    }
}



/**
 NSLocking协议实现同步加锁操作(例如：NSLock，实现NSLocking协议的对象)，但不适用于高并发场景。提示：该方法是一个同步操作
 注意：如果你打算在代码中多次使用这个线程锁，可以将用来加锁的对象(DispatchSemaphore，DispatchQueue，NSLock)存储在类的属性中或者其他方便存取的位置。这种方式可以帮助我们确保所有相应的异步操作是有序的，并且不会同时进行，从而可以避免许多常见的并发问题，例如竞争条件（race condition）和数据不一致。
 */
public func synchronized<T>(_ lock: NSLocking, _ body: () throws -> T) rethrows -> T {
    lock.lock()
    defer { lock.unlock() }
    return try body()
}



#if !os(Linux)

/**
 使用objc中的方法实现线程锁，不支持Linux，因为它使用objc的相关特性实现的线程加锁
 功能简介： 模拟:@synchronized(self){}
 使用方法： synchronized(self){}
 注意事项： 只能对class进行加锁操作
 */
public func synchronized<T>(_ object: AnyObject, _ body: () throws -> T) rethrows -> T {
    objc_sync_enter(object)
    defer { objc_sync_exit(object) }
    return try body()
}



#endif
