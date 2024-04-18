# CommonUnit
该工具封装了一些通用的Swift工具

### 一、基本扩展
一些常用类型的扩展，通用函数，以及模型转换工具等。


### 二、一些基础工具
一些基础的工具类，比如：
1. TKLog：日志打印
2. WeakArray：弱引用数组封装
3. OCMacro：一些Objecitve-C语言中的宏定义在Swift中的相似定义
4. Synchronized：模拟OC中相同关键之的线程锁。


### 三、网络工具
1. AFNetworkTool：Alamofire框架的封装
2. VaporNetworkTool：AsyncHTTPClient框架的封装，如果应用需要再Linux下运行，推荐使用该工具，因为URLSession在Linux下有系统级的bug
3. URLNetworkTool：对URLSession的简单封装
4. SwiftCurl：对curl工具调用的Swift封装，⚠️注意：在与Vapor框架混合使用时，会出现无法编译Release版本的二进制文件，并且该
