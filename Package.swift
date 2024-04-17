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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.3.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "8612d51811d5bae8a5cb8dd4e7799f0d7f746529f571ae8bcf48dc9095c4779e"
        )
    ]
)
