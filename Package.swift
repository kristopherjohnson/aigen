// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "aigen",
    platforms: [
        .macOS(.v15)  // macOS 26 will use version 15 in Package.swift
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "aigen",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
