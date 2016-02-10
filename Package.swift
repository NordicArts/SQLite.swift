import PackageDescription

let package = Package(
  name: "SwiftSQLite",
  dependencies: [
    .Package(url: "https://github.com/NordicArts/SQLite.module", majorVersion: 1)
  ]
)
