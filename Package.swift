// swift-tools-version:5.10

import PackageDescription

let package = Package(
  name: "swift-prelude",
  platforms: [
    .iOS(.v13),
    .macOS(.v14),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(name: "Either", targets: ["Either"]),
    .library(name: "Frp", targets: ["Frp"]),
    .library(name: "Optics", targets: ["Optics"]),
    .library(name: "Prelude", targets: ["Prelude"]),
    .library(name: "Reader", targets: ["Reader"]),
    .library(name: "State", targets: ["State"]),
    .library(name: "Tuple", targets: ["Tuple"]),
    .library(name: "ValidationSemigroup", targets: ["ValidationSemigroup"]),
    .library(name: "ValidationNearSemiring", targets: ["ValidationNearSemiring"]),
    .library(name: "Writer", targets: ["Writer"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "Either",
      dependencies: [
        "Prelude",
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "EitherTests", dependencies: ["Either"]),

    .target(
      name: "Frp",
      dependencies: ["Prelude", "ValidationSemigroup"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "FrpTests", dependencies: ["Frp"]),

    .target(
      name: "Optics",
      dependencies: ["Prelude", "Either"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "OpticsTests", dependencies: ["Optics"]),

    .target(
      name: "Prelude",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
      ],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "PreludeTests", dependencies: ["Prelude"]),

    .target(
      name: "Reader",
      dependencies: ["Prelude"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "ReaderTests", dependencies: ["Reader"]),

    .target(
      name: "State",
      dependencies: ["Prelude"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "StateTests", dependencies: ["State"]),

    .target(
      name: "Tuple",
      dependencies: ["Prelude"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "TupleTests", dependencies: ["Tuple"]),

    .target(
      name: "ValidationSemigroup",
      dependencies: ["Prelude"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "ValidationSemigroupTests", dependencies: ["ValidationSemigroup"]),

    .target(
      name: "ValidationNearSemiring",
      dependencies: ["Prelude", "Either"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "ValidationNearSemiringTests", dependencies: ["ValidationNearSemiring"]),

    .target(
      name: "Writer",
      dependencies: ["Prelude"],
      swiftSettings: [
          .enableUpcomingFeature("InferSendableFromCaptures"),
          .enableExperimentalFeature("StrictConcurrency=complete")
      ]
    ),
    .testTarget(name: "WriterTests", dependencies: ["Writer"]),
  ]
)
