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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.0.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "dd275dc2a40daa49d54e075a23bcbbae907a4cb5a2a46984803df522bd2ad61b"
        )
    ]
)
