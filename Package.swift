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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.30/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "08629d0356dd3f33631c783fcaa418988ca690b724b0a27149bada479727ad2d"
        )
    ]
)
