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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.3.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "07a3b57fb688c581807cf1c0a8cfba244b6cbd5e8badfb1c98cdd415f8152b6d"
        )
    ]
)
