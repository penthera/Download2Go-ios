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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.4.4/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "f1fe2fc50bef682357a340180b49a2ed5095feba4ed654046d2ec4af2476f5a4"
        )
    ]
)
