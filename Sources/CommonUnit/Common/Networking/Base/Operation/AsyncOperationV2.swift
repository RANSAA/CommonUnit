//
//  File.swift
//  
//
//  Created by kimi on 2023/11/3.
//
import Dispatch
import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif

/**
 参考地址:
 https://www.itguest.com/post/bhagbj1a2.html
 https://www.jianshu.com/p/65b3b3cfe9c7
 */

/// Asynchronous operation base class  实现方式二
///
/// This is abstract to class emits all of the necessary KVO notifications of `isFinished`
/// and `isExecuting` for a concurrent `Operation` subclass. You can subclass this and
/// implement asynchronous operations. All you must do is:
///
/// - override `main()` with the tasks that initiate the asynchronous task;
///
/// - call `completeOperation()` function when the asynchronous task is done;
///
/// - optionally, periodically check `self.cancelled` status, performing any clean-up
///   necessary and then ensuring that `finish()` is called; or
///   override `cancel` method, calling `super.cancel()` and then cleaning-up
///   and ensuring `finish()` is called.
/**
 AsyncOperationV2
 AsynchronousOperation
 */
class AsyncOperationV2: Operation {
     
    /// State for this operation.
     
    @objc private enum OperationState: Int {
        case ready
        case executing
        case finished
    }
     
    /// Concurrent queue for synchronizing access to `state`.
     
    private let stateQueue = DispatchQueue(label: (Bundle.main.bundleIdentifier ?? "com.apple.null") + ".rw.state", attributes: .concurrent)
     
    /// Private backing stored property for `state`.
     
    private var rawState: OperationState = .ready
     
    /// The state of the operation
   
//    macOS,iOS
//    @objc private dynamic var state: OperationState {
//        get { return stateQueue.sync { rawState } }
//        set { stateQueue.sync(flags: .barrier) { rawState = newValue } }
//    }
    //适配Linux
    private var state: OperationState {
        get {
            return stateQueue.sync { rawState }
        }
        set {
            willChangeValue(forKey: "state")
            stateQueue.sync(flags: .barrier) { rawState = newValue }
            didChangeValue(forKey: "state")
        }
    }


    // MARK: - Various `Operation` properties
    open         override var isReady:        Bool { return state == .ready && super.isReady }
    public final override var isExecuting:    Bool { return state == .executing }
    public final override var isFinished:     Bool { return state == .finished }
     
    // KVO for dependent properties
//    macOS,iOS
//    open override class func keyPathsForValuesAffectingValue(forKey key: String) -> Set<String> {
//        if ["isReady", "isFinished", "isExecuting"].contains(key) {
//            return [#keyPath(state)]
//        }
//        return super.keyPathsForValuesAffectingValue(forKey: key)
//    }
     
    
    // Start
    public final override func start() {
        if isCancelled {
            finish()
            return
        }
        state = .executing
        main()
    }
     
    /// Subclasses must implement this to perform their work and they must not call `super`. The default implementation of this function throws an exception.
    open override func main() {
        fatalError("Subclasses must implement `main`.")
    }
     
    /// Call this function to finish an operation that is currently executing
    public final func finish() {
        if !isFinished { state = .finished }
    }
} 
