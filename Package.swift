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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.38/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "a9a802ead158f4eb202fee25ca89e22190ff0780fe3778b1c1585a43848fb403"
        )
    ]
)
