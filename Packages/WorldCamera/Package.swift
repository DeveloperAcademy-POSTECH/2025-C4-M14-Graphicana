// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
/*
 See the LICENSE.txt file for this sample’s licensing information.

 Abstract:
 The package for controlling camera movements in a RealityKit app.
 */

import PackageDescription

let package = Package(
    name: "WorldCamera",
    platforms: [.iOS(.v18)],
    products: [.library(name: "WorldCamera", targets: ["WorldCamera"])],
    targets: [.target(
        name: "WorldCamera",
        swiftSettings: [.enableUpcomingFeature("MemberImportVisibility")]
    )]
)
