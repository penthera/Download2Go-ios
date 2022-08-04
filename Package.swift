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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.13/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "afe550d32d88c3b8c8b76e37e2740c64ceb07dd2c2456657b8108659b4028928"
        )
    ]
)
