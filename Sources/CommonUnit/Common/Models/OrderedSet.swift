import Foundation

/**
功能：自定义有序的Set集合，并且实现了线程安全

总结与选择：
DispatchQueue + sync：适合简洁的同步需求，保证线程安全。
NSLock 或 ReentrantLock：适用于需要手动管理锁的场景，尤其是复杂操作。
DispatchBarrier：对于高并发写操作，DispatchBarrier 使得多个写操作顺序执行，避免同时访问共享资源。
使用现成的线程安全容器：例如第三方库的 ConcurrentSet，如果可以接受额外的依赖。
对于性能要求较高的场景，DispatchBarrier 是一个非常高效的方案，它能确保写操作不会与读操作发生冲突，同时不必在每次读取时加锁。
 */





//MARK: - OrderedSet + DispatchBarrier
//使用DispatchBarrier实现的线程安全，且高效的OrderedSet
class OrderedSet<T: Hashable> {
    private var set: Set<T> = []
    private var order: [T] = []
    private let queue = DispatchQueue(label: "com.example.orderedSetQueue", attributes: .concurrent)

    // 插入元素，确保线程安全
    func insert(_ element: T) {
        queue.async(flags: .barrier) {
            if self.set.insert(element).inserted {
                self.order.append(element)
            }
        }
    }

    // 插入数组，并确保线程安全
    func inserts(_ elements: [T]) {
        queue.async(flags: .barrier) {
            for element in elements {
                if self.set.insert(element).inserted {
                    self.order.append(element)
                }
            }
        }
    }

    // 删除元素，确保线程安全
    func remove(_ element: T) {
        queue.async(flags: .barrier) {
            if self.set.remove(element) != nil {
                self.order.removeAll { $0 == element }
            }
        }
    }

    // 检查元素是否存在
    func contains(_ element: T) -> Bool {
        return queue.sync {
            return set.contains(element)
        }
    }

    // 获取元素数量
    var count: Int {
        return queue.sync {
            return set.count
        }
    }

    // 获取所有元素
    func allElements() -> [T] {
        return queue.sync {
            return self.order
        }
    }

    // 清空集合
    func clear() {
        queue.async(flags: .barrier) {
            self.set.removeAll()
            self.order.removeAll()
        }
    }
}













//MARK: - OrderedSet NSLock 
// 自定义 OrderedSet 类型, 使用NSLock实现线程安全
// class OrderedSet<T: Hashable> {
//     private var set: Set<T> = []
//     private var order: [T] = []
//     private let lock = NSLock()

//     // 插入元素，确保线程安全
//     func insert(_ element: T) {
//         lock.lock()
//         defer { lock.unlock() }
//         if set.insert(element).inserted {
//             order.append(element)
//         }
//     }

//     // 删除元素，确保线程安全
//     func remove(_ element: T) {
//         lock.lock()
//         defer { lock.unlock() }
//         if set.remove(element) != nil {
//             order.removeAll { $0 == element }
//         }
//     }

//     // 检查元素是否存在
//     func contains(_ element: T) -> Bool {
//         lock.lock()
//         defer { lock.unlock() }
//         return set.contains(element)
//     }

//     // 获取元素数量
//     var count: Int {
//         lock.lock()
//         defer { lock.unlock() }
//         return set.count
//     }

//     // 获取所有元素
//     func allElements() -> [T] {
//         lock.lock()
//         defer { lock.unlock() }
//         return order
//     }

//     // 清空集合
//     func clear() {
//         lock.lock()
//         defer { lock.unlock() }
//         set.removeAll()
//         order.removeAll()
//     }
// }














//MARK: - OrderedSet DispatchQueue + sync
// 自定义 OrderedSet 类型, DispatchQueue + sync实现线程安全
// struct OrderedSet<T: Hashable> {
//     private var set: Set<T> = []
//     private var order: [T] = []
    
//     private let queue = DispatchQueue(label: "com.example.orderedSetQueue")

//     // 插入元素，确保线程安全
//     mutating func insert(_ element: T) {
//         queue.sync {
//             if set.insert(element).inserted {
//                 order.append(element)
//             }
//         }
//     }

//     // 获取所有元素
//     func allElements() -> [T] {
//         return queue.sync {
//             return order
//         }
//     }
// }
