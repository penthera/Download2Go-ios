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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.26/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "b0fcdcf9a8aa60f97000376fb3b01d9017d04ae0be07b2d290cfca8584fa2272"
        )
    ]
)
