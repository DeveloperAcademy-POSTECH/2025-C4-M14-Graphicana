import ProjectDescription

let project = Project(
    name: "TtouchIsland",
    targets: [
        .target(
            name: "TtouchIsland",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.TtouchIsland",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["TtouchIsland/Sources/**"],
            resources: ["TtouchIsland/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "TtouchIslandTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.TtouchIslandTests",
            infoPlist: .default,
            sources: ["TtouchIsland/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TtouchIsland")]
        ),
    ]
)
