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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.6/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "3c4bfa97b64d8c11561f61ef7dae9f82756b7137345ef940378998b5bcec7704"
        )
    ]
)
