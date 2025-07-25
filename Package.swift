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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.6/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "f8bde494bae1916fd32f5e66a05ab9c22b2f43380a61834b95ff59eca3631ba4"
        )
    ]
)
