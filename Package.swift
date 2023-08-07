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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.45/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "c467e53589c823bb546a812452c882b36818dc6def210ddc3f297aeb9cdfd537"
        )
    ]
)
