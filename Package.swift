// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "TaskManagerAPI",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "TaskManagerAPI", targets: ["App"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.100.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.8.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "4.2.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.4.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-metrics.git", from: "2.4.0"),
    ],
    targets: [
        // --- Core (Shared utilities, logging, config) ---
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Metrics", package: "swift-metrics"),
            ],
            path: "Sources/Core"
        ),
        // --- Domain (Entities, Value Objects, Protocols) ---
        .target(
            name: "Domain",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Fluent", package: "fluent"),
            ],
            path: "Sources/Domain"
        ),
        // --- Infrastructure (Repositories, External Clients, DB) ---
        .target(
            name: "Infrastructure",
            dependencies: [
                "Domain",
                "Core",
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "JWT", package: "jwt"),
            ],
            path: "Sources/Infrastructure"
        ),
        // --- App (Main executable, routes, controllers, middleware) ---
        .executableTarget(
            name: "App",
            dependencies: [
                "Domain",
                "Infrastructure",
                "Core",
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "JWT", package: "jwt"),
            ],
            path: "Sources/App",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        // --- Unit Tests ---
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .target(name: "Domain"),
                .target(name: "Infrastructure"),
                .target(name: "Core"),
                .product(name: "XCTVapor", package: "vapor"),
            ],
            path: "Tests/AppTests"
        ),
    ]
)
