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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "7e496e348a1ab99f493e9599d474e5e2f592174b58dbe145311b79b4c0f47fa0"
        )
    ]
)
