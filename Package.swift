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
            url: "https://github.com/ecobee/webrtc-ios/releases/download/86.0.0/WebRTC-Bitcode.xcframework.zip",
            checksum: "f8ed523c35e9758abcd5c1b41e9b9cc46a147883c7febab796ff00546ca1c8f8")
    ]
)
