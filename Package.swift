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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.47/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "f7e813c3d8001abef59186e4a967ca4060510eee60b6af4c0183757e57a4f870"
        )
    ]
)
