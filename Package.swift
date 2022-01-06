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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.5/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "261662b2c0599e71067315658ec4b285fab5c1161a4324d3c389157845b07a6b"
        )
    ]
)
