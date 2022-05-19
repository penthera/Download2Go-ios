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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.10/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "059868ab12fb001839f1c81e7b36bb671a949d40cf861906f2ba5993b2d0881f"
        )
    ]
)
