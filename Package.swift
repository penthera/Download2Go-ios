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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "c42bf14dc894393940155a26577c0ac32614cc5831f52b9d9c6fbc0da400968d"
        )
    ]
)
