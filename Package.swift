// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VirtuosoClientDownloadEngine",
    products: [
        .library(name: "VirtuosoClientDownloadEngine", targets: ["VirtuosoClientDownloadEngine"])
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "VirtuosoClientDownloadEngine",
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.32/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "52c727b3ed00b34405a51501ef9102a66205c17599fc72beaffbd923476ec55c"
        )
    ]
)
