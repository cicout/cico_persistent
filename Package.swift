// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CICOPersistent",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "CICOPersistent", targets: ["CICOPersistent"])
    ],
    dependencies: [
        .package(url: "https://github.com/cicout/cico_foundation_kit.git",
                 from: "0.2.13"),
        .package(url: "https://github.com/cicout/cico_auto_codable.git",
                 from: "0.30.44"),
        .package(url: "https://github.com/ccgus/fmdb.git",
                 from: "2.7.12")
    ],
    targets: [
        .target(
            name: "CICOPersistent",
            dependencies: [
                .product(name: "CICOFoundationKit", package: "cico_foundation_kit"),
                .product(name: "CICOAutoCodable", package: "cico_auto_codable"),
                .product(name: "FMDB", package: "fmdb")
            ],
            path: "CICOPersistent"
        )
    ],
    swiftLanguageModes: [.v5]
)
