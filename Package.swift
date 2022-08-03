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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.12/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "cf0aee1a5108213abedbd3752926a28f756bba76ec959b0ea27d0ddb25eba99d"
        )
    ]
)
