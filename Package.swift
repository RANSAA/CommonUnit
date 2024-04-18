// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonUnit",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1"),
        .package(url: "https://github.com/iwill/ExCodable.git", from: "0.5.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.19.0"),
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.9.1")),
//        .package(url: "https://github.com/khoi/curl-swift.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "CommonUnit",
            dependencies: [
                .product(name: "SwiftSoup", package: "SwiftSoup"),
                .product(name: "ExCodable", package: "ExCodable"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "Alamofire", package: "Alamofire"),
//                .product(name: "curl-swift", package: "curl-swift"),
            ]),
        .testTarget(
            name: "CommonUnitTests",
            dependencies: ["CommonUnit"]),
    ]
)
