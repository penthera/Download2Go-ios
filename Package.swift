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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.22/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "12ce7cdb7bcc8c5a0865fb61800c1c73108bbee1752951098abc6a4ec4b7fe25"
        )
    ]
)
