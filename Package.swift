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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.10.1/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "98850c322b27b64cfd411cd619a386a2a9b23c121d56b079641e3a5d39dd0dc8"
        )
    ]
)
