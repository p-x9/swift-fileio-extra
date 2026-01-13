// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "FileIOBinary",
    products: [
        .library(
            name: "FileIOBinary",
            targets: ["FileIOBinary"]
        ),
    ],
    targets: [
        .target(
            name: "FileIOBinary"
        ),
        .testTarget(
            name: "FileIOBinaryTests",
            dependencies: ["FileIOBinary"]
        ),
    ]
)
