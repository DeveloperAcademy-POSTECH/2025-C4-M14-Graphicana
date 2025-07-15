import ProjectDescription

// let settings: Settings = .settings(
//    base: [:],
//    configurations: [
//        // --- Debug 빌드 설정 ---
//        .debug(name: "Debug", settings: [
//            // 1. 코드 서명 스타일을 'Manual'로 설정합니다.
//            "CODE_SIGN_STYLE": "Manual",
//            // 2. Team ID는 수동 서명에서도 필요합니다.
//            "DEVELOPMENT_TEAM": "4FCV7BL65G",
//            // 3. ✅ 여기에 사용하려는 Provisioning Profile의 '이름'을 정확하게 입력합니다.
//            "PROVISIONING_PROFILE_SPECIFIER": "CCC-AbundantLife-QT",
//            // 4. ✅ 서명 인증서 이름도 명시적으로 지정해주는 것이 좋습니다.
//            "CODE_SIGN_IDENTITY": "iPhone Developer",
//        ]),
//
//        // --- Release 빌드 설정 ---
//        .release(name: "Release", settings: [
//            // 1. 코드 서명 스타일을 'Manual'로 설정합니다.
//            "CODE_SIGN_STYLE": "Manual",
//            // 2. Team ID는 수동 서명에서도 필요합니다.
//            "DEVELOPMENT_TEAM": "4FCV7BL65G",
//            // 3. ✅ 여기에 사용하려는 Provisioning Profile의 '이름'을 정확하게 입력합니다.
//            "PROVISIONING_PROFILE_SPECIFIER": "CCC-AbundantLife-QT",
//            // 4. ✅ 서명 인증서 이름도 명시적으로 지정해주는 것이 좋습니다.
//            "CODE_SIGN_IDENTITY": "iPhone Developer",
//        ]),
//    ]
// )

let project = Project(
    name: "TtouchIsland",
    organizationName: "Graphicana",
    packages: [
        .local(path: "Packages/DummyAssets"),
        .local(path: "Packages/CharacterMovement"),
    ],
    targets: [
        .target(
            name: "TtouchIsland",
            destinations: .iOS,
            product: .app,
            bundleId: "org.graphicana.TtouchIsland",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationLandscapeLeft",
                        "UIInterfaceOrientationLandscapeRight",
                    ],
                    "CFBundleDisplayName": "Ttouch Island",
                    "LSApplicationCategoryType": "public.app-category.adventure-games",
                    // Version (앱 스토어에 표시될 버전, 예: 1.0.0)
//                        "CFBundleShortVersionString": .string("1.0.0"),
                    // Build (빌드 번호, 예: 1)
//                        "CFBundleVersion": .string("1"),
                ]
            ),
            sources: ["TtouchIsland/Sources/**"],
            resources: ["TtouchIsland/Resources/**"],
            dependencies: [
                .package(product: "DummyAssets"),
                .package(product: "CharacterMovement"),
            ]
//            settings: settings
        ),
        .target(
            name: "TtouchIslandTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "org.graphicana.TtouchIslandTests",
            infoPlist: .default,
            sources: ["TtouchIsland/Tests/**"],
            resources: [],
            dependencies: [.target(name: "TtouchIsland")]
        ),
    ]
)
