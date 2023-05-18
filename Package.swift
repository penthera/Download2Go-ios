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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.43/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "832682d8aa6a4d29fced64c4205d5314a419d6a672f34abcaf1ea63ef093475d"
        )
    ]
)
