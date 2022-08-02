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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.11/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "352ec4dfc7b72bc58ceb337859ac8343708ae9a4416e963d7def0901a0660f68"
        )
    ]
)
