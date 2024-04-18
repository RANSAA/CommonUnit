import Foundation
#if os(Linux)
import CoreFoundation
import FoundationNetworking
#endif

/**
	弱应用数组
	实现逻辑：为数组的元素创建一个使用weak标记的弱引用中间变量，然后让目标变量被中间变量弱引用，这就使得数组不会对目标对象强引用；
		而目标对象与中间变量是weak标记的所以目标对象就可以被自动释放掉。
	PS: https://www.jianshu.com/p/40ffcc41d933
*/

class WeakArray<T: AnyObject> {
	// 定义一个包装弱引用的类
    private class Weak<Element: AnyObject> {
            weak var value: Element?
            init(_ value: Element?) {
                self.value = value
            }
    }
    
	
	//用于存放中间变量的数组
	private var array: [Weak<T>] = []
	
	/**
	是否自动清理引用对象被释放掉的item元素；
	如果是将会在objects，count属性调用时，自动执行compact()清理方法。
	**/
	var autoclean:Bool = false
	
	
	func append(_ object: T?) {
		if let object = object {
			array.append(Weak(object))
		}
	}
	
	func remove(_ object: T?) {
		if let object = object, let index = array.firstIndex(where: { $0.value === object }) {
			array.remove(at: index)
		}
	}

	
	/**
	清除无效对对象，即清除已经被释放的的引用对象。
	**/
	func compact() {
		array = array.filter { $0.value != nil }
	}
	

	/**
	获取所有有效对象。
	*/
	var objects:[T] {
		if autoclean {
			compact()
		}
		return array.compactMap { $0.value }
	}
	
	
	/**
	功能：获取weakArray中item长度，其中item引用的值为nil的元素也在统计之中。
	*/
	var count:Int{
		if autoclean {
			compact()
		}
		return array.count
	}
	
	/**
	功能：获取有效数据的长度，即只统计未被释放掉的item的长度。
	说明：因为数组item中引用的对象可能会被释放掉，所以会造成item引用的值为nil，但是item的值却不为nil;
		 而item中引用的值才是被需要的值，所以一般需要的是真实有效还未被释放掉item的数量。
	*/
	var effectiveCount:Int{
		self.objects.count
	}

}



