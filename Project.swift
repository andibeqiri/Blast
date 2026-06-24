import ProjectDescription

let project = Project(
    name: "Blast",
    targets: [
        .target(
            name: "Blast",
            destinations: .iOS,
            product: .app,
            bundleId: "com.andibeqiri.Blast",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchStoryboardName": "",
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [:],
                ],
            ]),
            sources: ["Sources/**"],
            resources: []
        )
    ]
)
