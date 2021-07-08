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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.0.3/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "09c2c45559bb71d906a1a56c34321d2154e67473ff17d185fab7a1de1d645fe7"
        )
    ]
)
