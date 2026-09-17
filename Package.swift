// swift-tools-version: 5.10

import PackageDescription

let binaryParseSupportVersion: Version = "0.2.1"

let package = Package(
    name: "swift-fileio-extra",
    products: [
        .library(
            name: "FileIOBinary",
            targets: ["FileIOBinary"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/p-x9/swift-fileio.git",
            from: "0.15.0"
        ),
    ],
    targets: [
        .target(
            name: "FileIOBinary",
            dependencies: [
                .product(name: "FileIO", package: "swift-fileio"),
            ]
        ),
        .testTarget(
            name: "FileIOBinaryTests",
            dependencies: ["FileIOBinary"]
        ),
    ]
)

// MARK: - Binary Parse Support

let fileIOBinary = package.targets
    .first(where: { $0.name == "FileIOBinary" })

let isForBinaryKitFramework = Context.environment["BUILD_BINARY_KIT_FW"] != nil

if isForBinaryKitFramework {
    package.dependencies += [
        .package(
            url: "https://github.com/p-x9/swift-binary-parse-support-bin.git",
            from: binaryParseSupportVersion
        ),
    ]
    fileIOBinary?.dependencies += [
        .product(
            name: "BinaryParseSupport",
            package: "swift-binary-parse-support-bin"
        )
    ]
} else {
    package.dependencies += [
        .package(
            url: "https://github.com/p-x9/swift-binary-parse-support.git",
            from: binaryParseSupportVersion
        ),
    ]
    fileIOBinary?.dependencies += [
        .product(
            name: "BinaryParseSupport",
            package: "swift-binary-parse-support"
        )
    ]
}
