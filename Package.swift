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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.37/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "46fe0a61e4bdd4b871edcb49354ef920b30ec1c1943dc7415ec145ef06f200bc"
        )
    ]
)
