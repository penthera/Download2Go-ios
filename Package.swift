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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.18/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "0c7d4dae3256988b1c5234efc1121d53a174c9380c2bbcd4ed67621a1255b7e0"
        )
    ]
)
