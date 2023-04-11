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
            url: "https://github.com/penthera/Download2Go-ios/releases/download/v4.2.40/VirtuosoClientDownloadEngine-spm.xcframework.zip",
            checksum: "9517755d6dc39a897b9b4cdff65cb038fc276023bab44b484bcc9a130a5d1ccf"
        )
    ]
)
