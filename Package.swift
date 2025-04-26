// swift-tools-version:5.5

import PackageDescription

var sources = [
    "src/llama.cpp",
    "src/llama-vocab.cpp",
    "src/llama-grammar.cpp",
    "src/llama-sampling.cpp",
    "src/unicode.cpp",
    "src/unicode-data.cpp",
    "ggml/src/ggml.c",
    "ggml/src/ggml-alloc.c",
    "ggml/src/ggml-backend.cpp",
    "ggml/src/ggml-quants.c",
    "ggml/src/ggml-aarch64.c",
    "ggml/src/ggml-metal.m", // 常にMetalコードを入れる
]

var resources: [Resource] = [
    .process("ggml/src/ggml-metal.metal") // Metalのシェーダファイルも常にリソースにする
]

var linkerSettings: [LinkerSetting] = [
    .linkedFramework("Accelerate"), // 常にAccelerate.frameworkリンク
    .linkedFramework("Metal"),      // Metal.frameworkもリンクしておくとより安全！
    .linkedFramework("MetalKit")
]

var cSettings: [CSetting] = [
    .unsafeFlags(["-Wno-shorten-64-to-32", "-O3", "-DNDEBUG"]),
    .unsafeFlags(["-fno-objc-arc"]),
    .define("GGML_USE_ACCELERATE"), // Accelerateを常に有効
    .define("GGML_USE_METAL"),      // Metalを常に有効
]

#if os(Linux)
cSettings.append(.define("_GNU_SOURCE"))
#endif

let package = Package(
    name: "llama",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .watchOS(.v4),
        .tvOS(.v14)
    ],
    products: [
        .library(name: "llama", targets: ["llama"]),
    ],
    targets: [
        .target(
            name: "llama",
            path: ".",
            exclude: [
                "cmake",
                "examples",
                "scripts",
                "models",
                "tests",
                "CMakeLists.txt",
                "Makefile"
            ],
            sources: sources,
            resources: resources,
            publicHeadersPath: "spm-headers",
            cSettings: cSettings,
            linkerSettings: linkerSettings
        )
    ],
    cxxLanguageStandard: .cxx11
)
