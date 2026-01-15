// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "swift-fileio-extra",
    products: [
        .library(
            name: "FileIOBinary",
            targets: ["FileIOBinary"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/p-x9/swift-fileio.git", from: "0.13.0"),
        .package(url: "https://github.com/p-x9/swift-binary-parse-support.git", branch: "main")
    ],
    targets: [
        .target(
            name: "FileIOBinary",
            dependencies: [
                .product(name: "FileIO", package: "swift-fileio"),
                .product(name: "BinaryParseSupport", package: "swift-binary-parse-support")
            ]
        ),
        .testTarget(
            name: "FileIOBinaryTests",
            dependencies: ["FileIOBinary"]
        ),
    ]
)
