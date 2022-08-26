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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.23/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "09435eb285c4d047ee305fbf9459276158b584fb8f517b553b1aa33ffa1b4e13"
        )
    ]
)
