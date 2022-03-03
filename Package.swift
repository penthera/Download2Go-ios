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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.7/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "d9ff55de1ab30f1edce3ff7edb0274cd67ff84c622dc440cefdac70c1f682067"
        )
    ]
)
