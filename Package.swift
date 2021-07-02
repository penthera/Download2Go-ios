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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.0.2/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "1f2f64c93b4e8e24ff3fbf143f28643ab9542e09059a16eb17f465219048ac43"
        )
    ]
)
