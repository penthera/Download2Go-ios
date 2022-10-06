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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.31/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "1ed7c8adc7729eb0d937055aa523e8348280bf301fd38085ecac4e83d82d69fb"
        )
    ]
)
