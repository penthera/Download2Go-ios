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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.28/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "b49345e9b4d22fd9e7149f0c9555dcece681ccac2e6ae0861fdb12da6ef41a1d"
        )
    ]
)
