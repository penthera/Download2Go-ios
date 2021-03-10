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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.1.3/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "37412ca51218c494df1c8c4c91670297a4bb89742092e4f166c471e3b5c823b0"
        )
    ]
)
