@main
public struct CommonUnit {
    public private(set) var text = "Hello, World!"

    public static func main() {
        print(CommonUnit().text)
        
        TestNetwork.test()
    }
}
