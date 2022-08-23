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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.19/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "e5951f2230c0d503de6605884f059a09980b07bff76f618b9dfa4fd9ecf57eb2"
        )
    ]
)
