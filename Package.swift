// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "CICOPersistent",
    platforms: [.iOS(.v8)],
    products: [
        .library(name: "CICOPersistent", targets: ["CICOPersistent"])
    ],
    dependencies: [
        .package(url: "https://github.com/cicout/cico_auto_codable.git",
                 from: "0.20.24"),
        .package(url: "https://github.com/cicout/fmdb_with_sqlcipher_p2c.git",
                 PackageDescription.Package.Dependency.Requirement._branchItem("master"))
    ],
    targets: [
        .target(
            name: "CICOPersistent",
            path: "CICOPersistent"
        )
    ]
)
