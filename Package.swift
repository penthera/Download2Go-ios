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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.3.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "897c1ced5980ef71a669f56f68210a0020b79b47a3dbacda33383084f6d67194"
        )
    ]
)
