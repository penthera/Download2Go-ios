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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "d42cc43c2edb600da916b0b4e015ce2e875beb7078af77ce89dad65a290ef5ae"
        )
    ]
)
