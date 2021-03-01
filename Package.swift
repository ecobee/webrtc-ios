// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WebRTC",
    products: [
        .library(
            name: "WebRTC",
            targets: ["WebRTC"]),
        .library(
            name: "WebRTC-Bitcode",
            targets: ["WebRTC"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "WebRTC",
            path: "Frameworks/WebRTC.xcframework"),
        .binaryTarget(
            name: "WebRTC-Bitcode",
            url: "https://github.com/ecobee/webrtc-ios/releases/download/89.0.0/WebRTC-Bitcode.xcframework.zip",
            checksum: "6d0704ffe2e56ecae8e6722113013ae42a6ed38c4cc4af5238bbfefbdb6400c3")
    ]
)
