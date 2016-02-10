import PackageDescription

let package = Package(
  name: "SwiftSQLite",
  dependencies: [
    .Package(url: "https://github.com/NordicArts/SQLite.wrapper", majorVersion: 1)
  ]
)
